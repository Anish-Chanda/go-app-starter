package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/anish-chanda/go-app-starter/internal/db"
)

type Handler struct {
	DB *db.PostgresDB
}

func New(database *db.PostgresDB) *Handler {
	return &Handler{DB: database}
}

func (h *Handler) Health(w http.ResponseWriter, r *http.Request) {
	// ping database
	ctx, cancel := context.WithTimeout(r.Context(), 1*time.Second)
	defer cancel()

	if err := h.DB.Pool.Ping(ctx); err != nil {
		http.Error(w, "not ready", http.StatusServiceUnavailable)
		return
	}
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))
}
