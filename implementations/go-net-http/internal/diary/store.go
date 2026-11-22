package diary

import (
	"context"
	"database/sql"
	"errors"
	"time"

	_ "modernc.org/sqlite"
)

// Same text layout as the legacy store, so a later import keeps ordering by text compare.
const timeLayout = "2006-01-02 15:04:05.000000"

// specs/04-design/data/schema.sql, with the identity column translated to the
// engine form (ADR-0005, ADR-0006).
const schema = `
CREATE TABLE IF NOT EXISTS entries (
    id          INTEGER PRIMARY KEY,
    entry_text  TEXT NOT NULL,
    created_at  TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS entries_created_at_idx ON entries (created_at);
`

type Entry struct {
	ID        int64
	Text      string
	CreatedAt time.Time
}

type Store struct {
	db *sql.DB
}

func OpenStore(path string) (*Store, error) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}
	if _, err := db.Exec(schema); err != nil {
		db.Close()
		return nil, err
	}
	return &Store{db: db}, nil
}

func (s *Store) Close() error { return s.db.Close() }

// Add stores one entry. It is atomic: a failed insert leaves no row.
func (s *Store) Add(ctx context.Context, text string, createdAt time.Time) (Entry, error) {
	createdAt = createdAt.UTC()
	res, err := s.db.ExecContext(ctx,
		`INSERT INTO entries (entry_text, created_at) VALUES (?, ?)`,
		text, createdAt.Format(timeLayout))
	if err != nil {
		return Entry{}, err
	}
	id, err := res.LastInsertId()
	if err != nil {
		return Entry{}, err
	}
	return Entry{ID: id, Text: text, CreatedAt: createdAt}, nil
}

// Newest returns the entry with the latest creation instant, or nil when the diary is empty.
func (s *Store) Newest(ctx context.Context) (*Entry, error) {
	var e Entry
	err := s.db.QueryRowContext(ctx,
		`SELECT id, entry_text, created_at FROM entries ORDER BY created_at DESC, id DESC LIMIT 1`,
	).Scan(&e.ID, &e.Text, &e.CreatedAt)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	e.CreatedAt = e.CreatedAt.UTC()
	return &e, nil
}

func (s *Store) Count(ctx context.Context) (int, error) {
	var n int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM entries`).Scan(&n)
	return n, err
}
