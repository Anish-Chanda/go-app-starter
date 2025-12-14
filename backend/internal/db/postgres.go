package db

import (
	"context"
	"time"

	cfg "github.com/anish-chanda/go-app-starter/internal/config"
	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresDB struct {
	Pool *pgxpool.Pool
}

// NewPosgresDb create a new connection pool and pings the database

func NewPostgresDb(cfg cfg.DbConfig, ctx context.Context) (*PostgresDB, error) {
	poolConfig, err := pgxpool.ParseConfig(cfg.DSN)
	if err != nil {
		return nil, err
	}

	// set  pool settings
	poolConfig.MaxConns = int32(cfg.MaxConn)
	poolConfig.MinConns = int32(cfg.MinConn)
	poolConfig.MaxConnLifetime = time.Duration(cfg.MaxConnLifetime) * time.Minute

	// create pool
	pool, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, err
	}

	// ping database
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, err
	}

	return &PostgresDB{Pool: pool}, nil
}
