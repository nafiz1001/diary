package diary

import (
	"embed"
	"encoding/json"
	"html/template"
	"io/fs"
	"net/http"
	"strings"
	"time"
)

//go:embed templates/index.html
var templateFS embed.FS

//go:embed static
var staticFS embed.FS

const (
	reasonEmptyText        = "empty_text"
	reasonStoreUnavailable = "store_unavailable"

	msgSaved       = "Entry saved."
	msgEmptyText   = "Write some text before you submit."
	msgStoreFailed = "The entry was not saved. Try again."
)

var indexTemplate = template.Must(template.ParseFS(templateFS, "templates/index.html"))

type pageData struct {
	Text    string
	Message string
	Role    string // "status" or "alert"
	Reason  string
}

// NewHandler returns the diary HTTP handler (specs/04-design/api/openapi.yaml).
func NewHandler(store *Store) http.Handler {
	mux := http.NewServeMux()
	static, _ := fs.Sub(staticFS, "static")
	mux.Handle("GET /static/", http.StripPrefix("/static/", http.FileServerFS(static)))
	mux.HandleFunc("GET /{$}", func(w http.ResponseWriter, r *http.Request) {
		data := pageData{Role: "status"}
		if r.URL.Query().Get("saved") == "1" {
			data.Message = msgSaved
		}
		render(w, http.StatusOK, data)
	})
	mux.HandleFunc("POST /{$}", func(w http.ResponseWriter, r *http.Request) {
		submit(store, w, r)
	})
	return mux
}

func submit(store *Store, w http.ResponseWriter, r *http.Request) {
	text := r.FormValue("submission")
	wantsJSON := strings.Contains(r.Header.Get("Accept"), "application/json")

	reject := func(status int, reason, msg string) {
		if wantsJSON {
			writeJSON(w, status, map[string]string{"error": reason})
			return
		}
		render(w, status, pageData{Text: text, Message: msg, Role: "alert", Reason: reason})
	}

	if IsWhitespaceOnly(text) {
		reject(http.StatusUnprocessableEntity, reasonEmptyText, msgEmptyText)
		return
	}
	entry, err := store.Add(r.Context(), text, time.Now())
	if err != nil {
		reject(http.StatusServiceUnavailable, reasonStoreUnavailable, msgStoreFailed)
		return
	}
	if wantsJSON {
		writeJSON(w, http.StatusCreated, map[string]any{
			"id":         entry.ID,
			"created_at": entry.CreatedAt.Format(time.RFC3339Nano),
		})
		return
	}
	http.Redirect(w, r, "/?saved=1", http.StatusSeeOther)
}

// IsWhitespaceOnly implements BR-SUB-1 and TS-TEXT-3: only space, tab, line feed
// and carriage return count as whitespace. An empty text is whitespace only.
func IsWhitespaceOnly(text string) bool {
	return strings.Trim(text, " \t\n\r") == ""
}

func render(w http.ResponseWriter, status int, data pageData) {
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	w.WriteHeader(status)
	_ = indexTemplate.Execute(w, data)
}

func writeJSON(w http.ResponseWriter, status int, body any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(body)
}
