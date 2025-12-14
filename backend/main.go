package main

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	cfg "github.com/anish-chanda/go-app-starter/internal/config"
	"github.com/anish-chanda/go-app-starter/internal/db"
	"github.com/anish-chanda/go-app-starter/internal/handlers"
	"github.com/anish-chanda/go-app-starter/internal/logger"
	"github.com/anish-chanda/go-app-starter/migrations"
	authpkg "github.com/go-pkgz/auth/v2"
	"github.com/go-pkgz/auth/v2/provider"
	"github.com/go-pkgz/auth/v2/token"
)

const (
	shutdownTimeout    = 10 * time.Second
	startupTimeout     = 5 * time.Second
	dbMigrationTimeout = 60 * time.Second
)

func main() {

	// Cancel ctx on SIGINT/SIGTERM
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	config, err := cfg.LoadConfig()
	if err != nil {
		panic(fmt.Sprintf("failed to load config: %v", err))
	}

	// initialize logger
	logger.Init(config.Log)

	logger.L().Info().Msg("Application started")

	startCtx, cancel := context.WithTimeout(ctx, startupTimeout)
	defer cancel()

	database, err := db.NewPostgresDb(config.Db, startCtx, logger.L())
	if err != nil {
		logger.L().Fatal().Err(err).Msg("Failed to connect to database")
		return
	}

	// run db migrations
	migCtx, cancel := context.WithTimeout(ctx, dbMigrationTimeout)
	defer cancel()
	if err := migrations.RunMigrations(migCtx, database.Pool, logger.L()); err != nil {
		logger.L().Fatal().Err(err).Msg("Failed to run database migrations")
		return
	}

	// setup auth service
	h := handlers.New(database)
	authService := setupAuth(config.Auth, h)

	server := buildServer(config.Host, config.APIPort, database, authService)

	// Run server
	go func() {
		logger.L().Info().Msgf("Starting server on %s", server.Addr)
		err := server.ListenAndServe()
		if err != nil && !errors.Is(err, http.ErrServerClosed) {
			logger.L().Fatal().Err(err).Msg("Server failed")
		}
	}()

	// Wait for signal
	<-ctx.Done()
	logger.L().Warn().Msg("Shutting down server...")

	// Give active requests time to finish
	shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
	defer cancel()

	if err := server.Shutdown(shutdownCtx); err != nil {
		// Shutdown timed out or failed, Close() force-closes connections.
		logger.L().Error().Err(err).Msg("Graceful shutdown failed, forcing close")
		_ = server.Close()
	}

	// Now close DB pool
	logger.L().Debug().Msgf("closing %d database connections", database.Pool.Stat().TotalConns())
	database.Pool.Close()

	logger.L().Info().Msg("Shutdown complete")

}

func buildServer(host string, port int, database *db.PostgresDB, authService *authpkg.Service) *http.Server {
	h := handlers.New(database)

	api := http.NewServeMux()
	api.HandleFunc("GET /health", h.Health)
	api.HandleFunc("GET /hello", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("Hello, World!"))
	})

	mainMux := http.NewServeMux()
	mainMux.Handle("/api/", http.StripPrefix("/api", api))

	// mount auth handlers
	// TODO: handle avatars
	authHandlers, _ := authService.Handlers()
	mainMux.HandleFunc("POST /auth/local/signup", h.SignupHandler)
	mainMux.Handle("/auth/", http.StripPrefix("/auth", authHandlers))

	addr := fmt.Sprintf("%s:%d", host, port)
	handler := logger.Http(mainMux)

	return &http.Server{
		Addr:    addr,
		Handler: handler,
	}
}

func setupAuth(cfg cfg.AuthConfig, h *handlers.Handler) *authpkg.Service {
	authOptions := authpkg.Opts{
		SecretReader: token.SecretFunc(func(aud string) (string, error) {
			return cfg.JWTSecret, nil
		}),
		TokenDuration:  time.Duration(cfg.TokenDuration) * time.Minute,
		CookieDuration: time.Duration(cfg.CookieDuration) * time.Minute,
		// TODO: Change the issuer based on your project
		Issuer:      "app",
		DisableXSRF: cfg.DisableXSRF,
	}

	authService := authpkg.NewService(authOptions)

	// add local provider
	authService.AddDirectProvider("local", provider.CredCheckerFunc(h.LocalCredChecker))

	return authService
}
