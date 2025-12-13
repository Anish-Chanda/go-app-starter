package logger

import (
	"context"
	"net/http"

	"github.com/rs/zerolog"
	"github.com/rs/zerolog/hlog"
)

// Ctx returns the logger stored in ctx
// If none is found, it falls back to zerolog's default context logger behavior.
func Ctx(ctx context.Context) *zerolog.Logger {
	return zerolog.Ctx(ctx)
}

// WithLogger attaches l to ctx and returns the derived context.
func WithLogger(ctx context.Context, l *zerolog.Logger) context.Context {
	return l.WithContext(ctx)
}

// FromRequest returns the logger attached to the request by hlog.NewHandler.
// If the middleware isn't installed, this returns a no-op logger.
func FromRequest(r *http.Request) *zerolog.Logger {
	return hlog.FromRequest(r)
}
