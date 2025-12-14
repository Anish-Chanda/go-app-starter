package models

import "github.com/google/uuid"

// authprovider enum
type AuthProvider string

const (
	AuthProviderLocal  AuthProvider = "local"
	AuthProviderGoogle AuthProvider = "google"
	AuthProviderGithub AuthProvider = "github"
	// NOTE: add other auth providers as needed
)

type User struct {
	Id           uuid.UUID    `db:"id"`
	Name         string       `db:"name"`
	Email        string       `db:"email"`
	PasswordHash string       `db:"password_hash"`
	AuthProvider AuthProvider `db:"auth_provider"`
	CreatedAt    int64        `db:"created_at"`
	UpdatedAt    int64        `db:"updated_at"`
}
