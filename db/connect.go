package db

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	cfg, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return nil, fmt.Errorf("failed to parse database URL: %w", err)
	}
	// optional tuning
	cfg.MaxConns = 10
	cfg.MinConns = 2
	
	// Create a context with timeout for connection
	connectCtx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	
	pool, err := pgxpool.NewWithConfig(connectCtx, cfg)
	if err != nil {
		return nil, fmt.Errorf("failed to create connection pool: %w", err)
	}
	
	return pool, nil
}
