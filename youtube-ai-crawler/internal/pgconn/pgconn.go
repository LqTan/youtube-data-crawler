package pgconn

import (
	"context"
	"errors"
	"net"
	"net/url"
	"os"

	"github.com/jackc/pgx/v5/pgxpool"

	"youtube-ai-crawler/internal/env"
)

func Connect(ctx context.Context) (*pgxpool.Pool, error) {
	host := env.Get("DB_HOST", "localhost")
	port := env.Get("POSTGRES_PORT", "5432")
	dbName := os.Getenv("POSTGRES_DB")
	user := os.Getenv("POSTGRES_USER")
	password := os.Getenv("POSTGRES_PASSWORD")

	if dbName == "" || user == "" || password == "" {
		return nil, errors.New("missing POSTGRES_DB, POSTGRES_USER, or POSTGRES_PASSWORD")
	}

	u := &url.URL{
		Scheme: "postgres",
		User:   url.UserPassword(user, password),
		Host:   net.JoinHostPort(host, port),
		Path:   dbName,
	}

	q := u.Query()
	q.Set("sslmode", "disable")
	u.RawQuery = q.Encode()

	config, err := pgxpool.ParseConfig(u.String())
	if err != nil {
		return nil, err
	}

	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, err
	}

	if err := pool.Ping(ctx); err != nil {
		return nil, err
	}

	return pool, nil
}
