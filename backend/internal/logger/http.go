package logger

import (
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/rs/xid"
	"github.com/rs/zerolog"
)

func Http(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Skip noisy endpoints like health
		// TODO: skip web file server logs as well
		if r.URL.Path == "/api/health" {
			next.ServeHTTP(w, r)
			return
		}

		start := time.Now()

		sw := &statusWriter{ResponseWriter: w, status: http.StatusOK}
		reqID := strings.TrimSpace(r.Header.Get("X-Request-Id"))
		if reqID == "" {
			reqID = xid.New().String()
		}
		sw.Header().Set("X-Request-Id", reqID)

		path := r.URL.Path
		if r.URL.RawQuery != "" {
			path += "?" + r.URL.RawQuery
		}

		ip := clientIP(r)

		reqLog := L().With().
			Str("req_id", reqID).
			Str("client_ip", ip).
			Logger()

		// put logger into context so handlers can use logger.Ctx(r.Context())
		ctx := reqLog.WithContext(r.Context())
		r = r.WithContext(ctx)

		// call handler chain
		next.ServeHTTP(sw, r)

		// access log after response is written
		dur := time.Since(start)
		ms := float64(dur.Nanoseconds()) / 1e6

		evt := reqLog.WithLevel(levelForStatus(sw.status)).
			Int("bytes", sw.bytes).
			Float64("duration_ms", ms)

		evt.Msgf("%d %s %s", sw.status, r.Method, path)
	})
}

func clientIP(r *http.Request) string {
	// If you run behind a reverse proxy you trust, you can prefer X-Forwarded-For
	// (otherwise, keep RemoteAddr to avoid spoofing).
	// xff := r.Header.Get("X-Forwarded-For")
	// if xff != "" { ... }

	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil && host != "" {
		return host
	}
	return r.RemoteAddr
}

func levelForStatus(status int) zerolog.Level {
	switch {
	case status >= 500:
		return zerolog.ErrorLevel
	case status >= 400:
		return zerolog.WarnLevel
	default:
		return zerolog.InfoLevel
	}
}

type statusWriter struct {
	http.ResponseWriter
	status int
	bytes  int
}

func (w *statusWriter) WriteHeader(code int) {
	w.status = code
	w.ResponseWriter.WriteHeader(code)
}

func (w *statusWriter) Write(p []byte) (int, error) {
	n, err := w.ResponseWriter.Write(p)
	w.bytes += n
	return n, err
}
