package db

import (
	"context"
	"fmt"
	"time"

	cfg "github.com/anish-chanda/go-app-starter/internal/config"
	"github.com/anish-chanda/go-app-starter/internal/models"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/rs/zerolog"
)

type PostgresDB struct {
	Pool   *pgxpool.Pool
	Logger *zerolog.Logger
}

// NewPosgresDb create a new connection pool and pings the database

func NewPostgresDb(cfg cfg.DbConfig, ctx context.Context, logger *zerolog.Logger) (*PostgresDB, error) {
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

	// create logger with service context
	dbLogger := logger.With().Str("service", "db").Logger()

	return &PostgresDB{Pool: pool, Logger: &dbLogger}, nil
}

// EmailExists checks if an email already exists in the users table
func (db *PostgresDB) EmailExists(ctx context.Context, email string) (bool, error) {
	query := "SELECT EXISTS(SELECT 1 FROM users WHERE email = $1)"

	var exists bool
	err := db.Pool.QueryRow(ctx, query, email).Scan(&exists)
	if err != nil {
		return false, err
	}

	db.Logger.Debug().Str("email", email).Bool("exists", exists).Msg("email exists in database")
	return exists, nil
}

func (db *PostgresDB) CreateUser(ctx context.Context, user models.User) (*models.User, error) {
	query := `
		INSERT INTO users (name, email, password_hash, auth_provider, created_at, updated_at)
		VALUES ($1, $2, $3, $4, NOW(), NOW())
		RETURNING id, name, email, password_hash, auth_provider, 
				  EXTRACT(EPOCH FROM created_at)::bigint as created_at,
				  EXTRACT(EPOCH FROM updated_at)::bigint as updated_at
	`

	db.Logger.Debug().Str("email", user.Email).Str("auth_provider", string(user.AuthProvider)).Msg("creating new user")

	var createdUser models.User
	err := db.Pool.QueryRow(ctx, query,
		user.Name,
		user.Email,
		user.PasswordHash,
		user.AuthProvider,
	).Scan(
		&createdUser.Id,
		&createdUser.Name,
		&createdUser.Email,
		&createdUser.PasswordHash,
		&createdUser.AuthProvider,
		&createdUser.CreatedAt,
		&createdUser.UpdatedAt,
	)

	if err != nil {
		return nil, err
	}

	db.Logger.Debug().Str("user_id", createdUser.Id.String()).Str("email", createdUser.Email).Msg("user created successfully")
	return &createdUser, nil
}

// GetUserByEmail retrieves a user by email address
func (db *PostgresDB) GetUserByEmail(ctx context.Context, email string) (*models.User, error) {
	query := `
		SELECT id, name, email, password_hash, auth_provider,
			   EXTRACT(EPOCH FROM created_at)::bigint as created_at,
			   EXTRACT(EPOCH FROM updated_at)::bigint as updated_at
		FROM users 
		WHERE email = $1
	`

	db.Logger.Debug().Str("email", email).Msg("retrieving user by email")

	var user models.User
	err := db.Pool.QueryRow(ctx, query, email).Scan(
		&user.Id,
		&user.Name,
		&user.Email,
		&user.PasswordHash,
		&user.AuthProvider,
		&user.CreatedAt,
		&user.UpdatedAt,
	)

	if err != nil {
		if err.Error() == "no rows in result set" {
			db.Logger.Debug().Str("email", email).Msg("user not found")
			return nil, fmt.Errorf("user not found")
		}
		db.Logger.Debug().Err(err).Str("email", email).Msg("failed to retrieve user")
		return nil, err
	}

	db.Logger.Debug().Str("user_id", user.Id.String()).Str("email", email).Msg("user retrieved successfully")
	return &user, nil
}
