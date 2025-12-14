package migrations

import (
	"context"
	"embed"
	"fmt"
	"time"

	"github.com/golang-migrate/migrate/v4"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/source/iofs"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
)

//go:embed postgres/*.sql
var PgMigrations embed.FS

func RunMigrations(ctx context.Context, pool *pgxpool.Pool, logger *zerolog.Logger) error {
	if logger == nil {
		return fmt.Errorf("logger is nil")
	}

	l := log.With().Str("component", "migrations").Logger()
	start := time.Now()
	l.Info().Msg("running database migrations")

	// Create source driver from embedded filesystem
	source, err := iofs.New(PgMigrations, "postgres")
	if err != nil {
		return fmt.Errorf("create migration source: %w", err)
	}
	defer func() { _ = source.Close() }()

	// Convert pgxpool to sql.Db for golang-migrate
	sqlDB := stdlib.OpenDBFromPool(pool)
	defer sqlDB.Close()

	// Create postgres database driver for migrate
	driver, err := postgres.WithInstance(sqlDB, &postgres.Config{})
	if err != nil {
		return fmt.Errorf("create postgres driver: %w", err)
	}

	// Create migrate instance
	m, err := migrate.NewWithInstance("iofs", source, "postgres", driver)
	if err != nil {
		return fmt.Errorf("create migrate instance: %w", err)
	}
	defer func() {
		_, _ = m.Close()
	}()

	// Log current version
	if v, dirty, err := m.Version(); err == nil {
		if dirty {
			return fmt.Errorf("database is dirty at version %d", v)
		}
		l.Info().Uint("version", v).Msg("current migration version")
	} else if err == migrate.ErrNilVersion {
		l.Info().Msg("no existing migrations applied yet")
	} else {
		return fmt.Errorf("read current migration version: %w", err)
	}

	// Run migrations
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		return fmt.Errorf("apply migrations: %w", err)
	}

	if err == migrate.ErrNoChange {
		l.Info().Dur("duration", time.Since(start)).Msg("migrations up-to-date")
		return nil
	}

	// Log final version
	if v, dirty, err := m.Version(); err == nil {
		if dirty {
			return fmt.Errorf("database became dirty at version %d", v)
		}
		l.Info().
			Uint("version", v).
			Dur("duration", time.Since(start)).
			Msg("migrations applied successfully")
		return nil
	}

	l.Info().Dur("duration", time.Since(start)).Msg("migrations applied successfully")
	return nil
}
