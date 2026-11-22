package contract

import (
	"bytes"
	"context"
	"io"
	"net/http/httptest"
	"net/url"
	"path/filepath"
	"strings"
	"testing"

	"github.com/getkin/kin-openapi/openapi3"
	"github.com/getkin/kin-openapi/openapi3filter"
	"github.com/getkin/kin-openapi/routers/gorillamux"

	"diary/internal/diary"
)

// Checks live responses against specs/04-design/api/openapi.yaml.
func TestOpenAPIContract(t *testing.T) {
	ctx := context.Background()
	doc, err := openapi3.NewLoader().LoadFromFile(
		filepath.Join("..", "..", "..", "specs", "04-design", "api", "openapi.yaml"))
	if err != nil {
		t.Fatal(err)
	}
	if err := doc.Validate(ctx); err != nil {
		t.Fatal(err)
	}
	router, err := gorillamux.NewRouter(doc)
	if err != nil {
		t.Fatal(err)
	}
	openapi3filter.RegisterBodyDecoder("text/html", openapi3filter.PlainBodyDecoder)

	form := func(text string) (io.Reader, string) {
		return strings.NewReader(url.Values{"submission": {text}}.Encode()), "application/x-www-form-urlencoded"
	}

	cases := []struct {
		name       string
		method     string
		target     string
		text       string
		json       bool
		closeStore bool
		want       int
	}{
		{"show page", "GET", "/", "", false, false, 200},
		{"show page saved", "GET", "/?saved=1", "", false, false, 200},
		{"page saved", "POST", "/", "hello", false, false, 303},
		{"page empty", "POST", "/", "  ", false, false, 422},
		{"page store down", "POST", "/", "hello", false, true, 503},
		{"json saved", "POST", "/", "hello", true, false, 201},
		{"json empty", "POST", "/", "", true, false, 422},
		{"json store down", "POST", "/", "hello", true, true, 503},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			store, err := diary.OpenStore(filepath.Join(t.TempDir(), "diary.db"))
			if err != nil {
				t.Fatal(err)
			}
			if c.closeStore {
				store.Close()
			} else {
				defer store.Close()
			}

			var body io.Reader
			var contentType string
			if c.method == "POST" {
				body, contentType = form(c.text)
			}
			req := httptest.NewRequest(c.method, c.target, body)
			if contentType != "" {
				req.Header.Set("Content-Type", contentType)
			}
			if c.json {
				req.Header.Set("Accept", "application/json")
			}

			route, params, err := router.FindRoute(req)
			if err != nil {
				t.Fatal(err)
			}
			reqInput := &openapi3filter.RequestValidationInput{Request: req, PathParams: params, Route: route}
			if err := openapi3filter.ValidateRequest(ctx, reqInput); err != nil {
				t.Fatalf("request: %v", err)
			}

			rec := httptest.NewRecorder()
			diary.NewHandler(store).ServeHTTP(rec, req)
			if rec.Code != c.want {
				t.Fatalf("status: want %d, got %d", c.want, rec.Code)
			}
			respBody := rec.Body.Bytes()
			err = openapi3filter.ValidateResponse(ctx, &openapi3filter.ResponseValidationInput{
				RequestValidationInput: reqInput,
				Status:                 rec.Code,
				Header:                 rec.Header(),
				Body:                   io.NopCloser(bytes.NewReader(respBody)),
				Options:                &openapi3filter.Options{IncludeResponseStatus: true},
			})
			if err != nil {
				t.Fatalf("response: %v", err)
			}
		})
	}
}
