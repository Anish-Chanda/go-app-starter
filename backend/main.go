package main

import (
	"fmt"
	"net/http"

	cfg "github.com/anish-chanda/go-app-starter/internal/config"
	"github.com/anish-chanda/go-app-starter/internal/handlers"
	"github.com/anish-chanda/go-app-starter/internal/logger"
)

func main() {
	config, err := cfg.LoadConfig()
	if err != nil {
		panic(fmt.Sprintf("failed to load config: %v", err))
	}

	// initialize logger
	logger.Init(config.Log)

	logger.L().Info().Msg("Application started")

	// TODO: add db and auth stuff here

	setupHandlers(config.Host, config.APIPort)
}

// sets up http handlers and starts the server
func setupHandlers(host string, port int) {
	api := http.NewServeMux()

	api.HandleFunc("GET /health", handlers.Health)

	// test hello endpoitn
	api.HandleFunc("GET /hello", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Hello, World!"))
	})

	mainMux := http.NewServeMux()
	mainMux.Handle("/api/", http.StripPrefix("/api", api))

	// wrap with logging middleware and serve
	addr := fmt.Sprintf("%s:%d", host, port)
	handler := logger.Http(mainMux)
	if err := http.ListenAndServe(addr, handler); err != nil {
		logger.L().Fatal().Err(err).Msg("Server failed")
	}
}
