package handlers

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/anish-chanda/go-app-starter/internal/logger"
	"github.com/anish-chanda/go-app-starter/internal/models"
	"github.com/go-pkgz/auth/v2/token"
	"golang.org/x/crypto/argon2"
)

// argon2id params based on OWASP recommendations: https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id
const (
	argonTime    = 1
	argonMemory  = 19456 // 19 MB
	argonThreads = 2
	argonSaltLen = 16
	argonKeyLen  = 32
)

// hashPassword applies Argon2id with OWASP‐recommended params and returns
// a single string in the standard “$argon2id$v=19$m=…,t=…,p=…$salt$hash” format.
func hashPassword(password string) (string, error) {
	salt := make([]byte, argonSaltLen)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	hash := argon2.IDKey(
		[]byte(password),
		salt,
		argonTime,
		argonMemory,
		argonThreads,
		argonKeyLen,
	)
	b64Salt := base64.RawStdEncoding.EncodeToString(salt)
	b64Hash := base64.RawStdEncoding.EncodeToString(hash)
	parts := []string{
		"argon2id",
		fmt.Sprintf("v=%d", argon2.Version),
		fmt.Sprintf("m=%d,t=%d,p=%d", argonMemory, argonTime, argonThreads),
		b64Salt,
		b64Hash,
	}
	return "$" + strings.Join(parts, "$"), nil
}

// verifyPassword parses and verifies an encoded Argon2id hash.
func verifyPassword(password, encoded string) (bool, error) {
	// encoded: $argon2id$v=19$m=...,t=...,p=...$<salt>$<hash>
	fields := strings.Split(encoded, "$")
	if len(fields) != 6 || fields[1] != "argon2id" {
		return false, fmt.Errorf("invalid hash format")
	}
	var memory, timeParam, threads uint32
	if _, err := fmt.Sscanf(fields[3], "m=%d,t=%d,p=%d", &memory, &timeParam, &threads); err != nil {
		return false, err
	}
	salt, err := base64.RawStdEncoding.DecodeString(fields[4])
	if err != nil {
		return false, err
	}
	hash, err := base64.RawStdEncoding.DecodeString(fields[5])
	if err != nil {
		return false, err
	}

	computed := argon2.IDKey([]byte(password), salt, timeParam, memory, uint8(threads), uint32(len(hash)))
	// constant-time compare
	if subtle.ConstantTimeCompare(computed, hash) == 1 {
		return true, nil
	}
	return false, nil
}

// Request and response structs
type SignupRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

func (h *Handler) SignupHandler(w http.ResponseWriter, r *http.Request) {
	ctx := r.Context()
	log := logger.Ctx(ctx)

	// Parse request
	var req SignupRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "invalid request", http.StatusBadRequest)
		return
	}
	if err := ValidateSignupRequest(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	email := strings.TrimSpace(strings.ToLower(req.Email))

	// Check if email exists
	exists, err := h.DB.EmailExists(ctx, email)
	if err != nil {
		log.Error().Err(err).Msg("failed to check email existence")
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}
	if exists {
		log.Info().Str("email", email).Msg("signup attempt with existing email")
		http.Error(w, "email already exists", http.StatusConflict)
		return
	}

	// Hash password
	hashedPassword, err := hashPassword(req.Password)
	if err != nil {
		log.Error().Err(err).Msg("failed to hash password")
		http.Error(w, "internal server error", http.StatusInternalServerError)
		return
	}

	// Create user in DB
	user := models.User{
		Name:         req.Name,
		Email:        email,
		PasswordHash: hashedPassword,
		AuthProvider: models.AuthProviderLocal,
	}

	createdUser, err := h.DB.CreateUser(ctx, user)
	if err != nil {
		log.Error().Err(err).Str("email", email).Msg("failed to create user")
		http.Error(w, "failed to create user", http.StatusInternalServerError)
		return
	}

	log.Info().Str("user_id", createdUser.Id.String()).Str("email", email).Msg("user created successfully")

	// Return success response (excluding sensitive data like password hash)
	response := map[string]interface{}{
		"id":       createdUser.Id,
		"email":    createdUser.Email,
		"provider": createdUser.AuthProvider,
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(response)
}

func ValidateSignupRequest(req *SignupRequest) error {
	// password cannot be empty
	if strings.TrimSpace(req.Password) == "" {
		return fmt.Errorf("password cannot be empty")
	}
	// email cannot be empty
	if strings.TrimSpace(req.Email) == "" {
		return fmt.Errorf("email cannot be empty")
	}
	// name cannot be empty for local auth
	if strings.TrimSpace(req.Name) == "" {
		return fmt.Errorf("name cannot be empty")
	}
	// name length validation
	if len(strings.TrimSpace(req.Name)) > 255 {
		return fmt.Errorf("name must be less than 255 characters")
	}

	// Note: other validations cna be added here absed on your requirements
	return nil
}

// LocalCredChecker validates local user credentials for authentication
// This function is designed to be used with go-pkgz/auth library
func (h *Handler) LocalCredChecker(user, password string) (bool, error) {
	if user == "" || password == "" {
		return false, fmt.Errorf("email and password cannot be empty")
	}

	// Use timeout context for database operations
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	email := strings.TrimSpace(strings.ToLower(user))

	// Get user from database
	dbUser, err := h.DB.GetUserByEmail(ctx, email)
	if err != nil {
		// Don't reveal whether user exists or not for security reasons
		return false, nil
	}

	if dbUser == nil {
		// User not found
		return false, nil
	}

	// Check if user is local auth provider
	if dbUser.AuthProvider != models.AuthProviderLocal || dbUser.PasswordHash == "" {
		return false, fmt.Errorf("user uses %s authentication", dbUser.AuthProvider)
	}

	// Verify password
	valid, err := verifyPassword(password, dbUser.PasswordHash)
	if err != nil {
		return false, fmt.Errorf("password verification failed: %w", err)
	}

	return valid, nil
}

// UserIDFunc returns a function that provides the actual database UUID for a user
// This is used by go-pkgz/auth to set the user ID in JWT tokens
func (h *Handler) UserIDFunc() func(user string, r *http.Request) string {
	return func(user string, r *http.Request) string {
		ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
		defer cancel()

		email := strings.TrimSpace(strings.ToLower(user))

		// Get user from database to retrieve their UUID
		dbUser, err := h.DB.GetUserByEmail(ctx, email)
		if err != nil || dbUser == nil {
			// Return empty string as fallback - library will use hash
			return ""
		}

		// Return the actual database UUID
		return dbUser.Id.String()
	}
}

// ClaimsUpdater returns a function that adds email, database UUID, and auth provider to JWT claims
// This is used by go-pkgz/auth to populate additional user information in tokens
func (h *Handler) ClaimsUpdater() func(claims token.Claims) token.Claims {
	return func(claims token.Claims) token.Claims {
		if claims.User == nil {
			return claims
		}

		// Get user from database to enrich claims with database UUID
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		// Determine email based on provider type:
		// - For OAuth2 providers (google, github, etc.): Email is already set by provider
		// - For local/direct provider: User.Name contains the email used for login
		var email string
		if claims.User.Email != "" {
			// OAuth2 provider - email is already populated
			email = strings.TrimSpace(strings.ToLower(claims.User.Email))
		} else {
			// Local/direct provider - User.Name contains the email
			email = strings.TrimSpace(strings.ToLower(claims.User.Name))
		}

		// Fetch user from database
		dbUser, err := h.DB.GetUserByEmail(ctx, email)
		if err == nil && dbUser != nil {
			// Always set email
			claims.User.Email = dbUser.Email

			// For local provider, overwrite Name with display name from DB
			// For OAuth2 providers (google, github, etc.), keep the name from provider
			if dbUser.AuthProvider == models.AuthProviderLocal {
				claims.User.Name = dbUser.Name
			}

			// Always store database UUID as an attribute for backend use
			claims.User.SetStrAttr("uid", dbUser.Id.String())
			// Always store auth provider as an attribute for frontend display
			claims.User.SetStrAttr("provider", string(dbUser.AuthProvider))
		}

		return claims
	}
}
