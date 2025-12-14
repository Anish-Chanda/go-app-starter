package cfg

import (
	"fmt"
	"io"
	"os"
	"strconv"
	"strings"

	"github.com/rs/zerolog"
)

type AuthConfig struct {
	JWTSecret      string // secret key for signing JWT tokens
	TokenDuration  int    // token duration in minutes
	CookieDuration int    // cookie duration in minutes
	DisableXSRF    bool   // disable XSRF protection
}

type LogMode string

const (
	LogModeConsole LogMode = "console"
	LogModeJSON    LogMode = "json"
)

type LogConfig struct {
	Mode  LogMode // logging mode: "console" or "json"
	Level zerolog.Level

	// time.RFC3339Nano, time.RFC3339, etc., for Pretty mode. defaults to RFC3339.
	PrettyTimeFormat string
	// JSON: prefer Unix for size/speed (zerolog.TimeFormatUnix) or RFC3339Nano for readability.
	JSONTimeFieldFormat string
	// Output destination (defaults to os.Stdout).
	Out io.Writer
}

type DbConfig struct {
	// Database connection string
	DSN string
	// Max connections
	MaxConn int
	// Min connections
	MinConn int
	// Max conntection lifetime in minutes
	MaxConnLifetime int
}

type Config struct {
	// Server configuration
	APIPort int
	Host    string

	// Authentication configuration
	Auth AuthConfig

	// Logging configuration
	Log LogConfig

	// Database configuration
	Db DbConfig
}

func LoadConfig() (*Config, error) {

	jwtSecret, err := getRequiredEnvString("JWT_SECRET")
	if err != nil {
		return nil, err
	}

	logMode, err := getEnvAsLogMode("LOG_MODE", LogModeConsole)
	if err != nil {
		return nil, err
	}

	logLevel, err := getEnvAsZerologLevel("LOG_LEVEL", zerolog.InfoLevel)
	if err != nil {
		return nil, err
	}
	dsn, err := getRequiredEnvString("DATABASE_DSN")
	if err != nil {
		return nil, err
	}

	config := &Config{
		APIPort: getEnvAsInt("API_PORT", 8080),
		Host:    getEnvAsString("HOST", "127.0.0.1"),

		Auth: AuthConfig{
			JWTSecret:      jwtSecret,
			TokenDuration:  getEnvAsInt("TOKEN_DURATION", 60),  // default 60 minutes
			CookieDuration: getEnvAsInt("COOKIE_DURATION", 60), // default 60 minutes
			DisableXSRF:    getEnvAsBool("DISABLE_XSRF", false),
		},

		Log: LogConfig{
			Mode:                logMode,
			Level:               logLevel,
			PrettyTimeFormat:    getEnvAsString("LOG_PRETTY_TIME_FORMAT", "2006-01-02T15:04:05Z07:00"),
			JSONTimeFieldFormat: getEnvAsString("LOG_JSON_TIME_FIELD_FORMAT", zerolog.TimeFormatUnix),
			Out:                 os.Stdout,
		},

		Db: DbConfig{
			DSN:             dsn,
			MaxConn:         getEnvAsInt("DB_MAX_CONN", 20),
			MinConn:         getEnvAsInt("DB_MIN_CONN", 5),
			MaxConnLifetime: getEnvAsInt("DB_MAX_CONN_LIFETIME", 60), // in minutes
		},
	}
	return config, nil

}

// getEnvAsInt gets an environment variable as an integer with a fallback value
func getEnvAsInt(key string, fallback int) int {
	if value := os.Getenv(key); value != "" {
		if intVal, err := strconv.Atoi(value); err == nil {
			return intVal
		}
	}
	return fallback
}

// getEnvAsString gets an environment variable as a string with a fallback value
func getEnvAsString(key string, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

// getRequiredEnvString gets a required environment variable as a string
func getRequiredEnvString(key string) (string, error) {
	if value := os.Getenv(key); value != "" {
		return value, nil
	}
	return "", fmt.Errorf("required environment variable not set: %s", key)
}

// getEnvAsBool gets an environment variable as a boolean with a fallback value
func getEnvAsBool(key string, fallback bool) bool {
	if value := os.Getenv(key); value != "" {
		if boolVal, err := strconv.ParseBool(value); err == nil {
			return boolVal
		}
	}
	return fallback
}

// getEnvAsLogMode gets an environment variable as a LogMode with a fallback value
func getEnvAsLogMode(key string, fallback LogMode) (LogMode, error) {
	v := strings.ToLower(strings.TrimSpace(os.Getenv(key)))
	if v == "" {
		return fallback, nil
	}
	switch LogMode(v) {
	case LogModeConsole, LogModeJSON:
		return LogMode(v), nil
	default:
		return "", fmt.Errorf("invalid %s: %q (expected %q or %q)", key, v, LogModeConsole, LogModeJSON)
	}
}

// getEnvAsZerologLevel gets an environment variable as a zerolog.Level with a fallback value
func getEnvAsZerologLevel(key string, fallback zerolog.Level) (zerolog.Level, error) {
	v := strings.ToLower(strings.TrimSpace(os.Getenv(key)))
	if v == "" {
		return fallback, nil
	}

	switch v {
	case "panic":
		return zerolog.PanicLevel, nil
	case "fatal":
		return zerolog.FatalLevel, nil
	case "error":
		return zerolog.ErrorLevel, nil
	case "warn", "warning":
		return zerolog.WarnLevel, nil
	case "info":
		return zerolog.InfoLevel, nil
	case "debug":
		return zerolog.DebugLevel, nil
	case "trace":
		return zerolog.TraceLevel, nil
	case "disabled", "off":
		return zerolog.Disabled, nil
	default:
		return zerolog.NoLevel, fmt.Errorf("invalid %s: %q (expected panic|fatal|error|warn|info|debug|trace|disabled)", key, v)
	}
}
