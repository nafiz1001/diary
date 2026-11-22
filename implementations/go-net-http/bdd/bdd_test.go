package bdd

import (
	"context"
	"fmt"
	"html"
	"net/http"
	"net/http/httptest"
	"net/url"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/cucumber/godog"

	"diary/internal/diary"
)

var (
	textareaRe = regexp.MustCompile(`(?s)<textarea[^>]*>(.*?)</textarea>`)
	statusRe   = regexp.MustCompile(`(?s)<div id="submission-status"([^>]*)>(.*?)</div>`)
	reasonRe   = regexp.MustCompile(`data-reason="([^"]*)"`)

	// Step text escapes (specs/02-specification/technical-spec.md, step conventions).
	unescape = strings.NewReplacer("{space}", " ", "{tab}", "\t", "{newline}", "\n")
)

type world struct {
	t       *testing.T
	store   *diary.Store
	handler http.Handler
	page    string // body of the last page the user sees
	status  int    // status of the last submission
}

func (w *world) reset() error {
	store, err := diary.OpenStore(filepath.Join(w.t.TempDir(), "diary.db"))
	if err != nil {
		return err
	}
	w.store, w.handler, w.page, w.status = store, diary.NewHandler(store), "", 0
	return nil
}

func (w *world) get(target string) *httptest.ResponseRecorder {
	rec := httptest.NewRecorder()
	w.handler.ServeHTTP(rec, httptest.NewRequest(http.MethodGet, target, nil))
	return rec
}

func (w *world) submit(text string) error {
	form := url.Values{"submission": {unescape.Replace(text)}}
	req := httptest.NewRequest(http.MethodPost, "/", strings.NewReader(form.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	w.handler.ServeHTTP(rec, req)
	w.status = rec.Code
	w.page = rec.Body.String()
	if rec.Code == http.StatusSeeOther {
		w.page = w.get(rec.Header().Get("Location")).Body.String()
	}
	return nil
}

func (w *world) formText() (string, error) {
	m := textareaRe.FindStringSubmatch(w.page)
	if m == nil {
		return "", fmt.Errorf("no form on the page")
	}
	// A browser drops the first line feed after the text area start tag.
	return strings.TrimPrefix(html.UnescapeString(m[1]), "\n"), nil
}

func (w *world) message() (text, reason string) {
	m := statusRe.FindStringSubmatch(w.page)
	if m == nil {
		return "", ""
	}
	if r := reasonRe.FindStringSubmatch(m[1]); r != nil {
		reason = r[1]
	}
	return html.UnescapeString(m[2]), reason
}

func (w *world) rejectedWith(reason string) error {
	_, got := w.message()
	if got != reason {
		return fmt.Errorf("reason: want %q, got %q", reason, got)
	}
	return nil
}

func TestFeatures(t *testing.T) {
	w := &world{t: t}
	suite := godog.TestSuite{
		ScenarioInitializer: func(sc *godog.ScenarioContext) {
			sc.Before(func(ctx context.Context, _ *godog.Scenario) (context.Context, error) {
				return ctx, w.reset()
			})
			sc.After(func(ctx context.Context, _ *godog.Scenario, err error) (context.Context, error) {
				w.store.Close()
				return ctx, nil
			})

			sc.Step(`^an empty diary$`, func() error { return nil })
			sc.Step(`^the entry store is unavailable$`, func() error { return w.store.Close() })

			sc.Step(`^the user submits the entry text "(.*)"$`, w.submit)

			sc.Step(`^the diary has (\d+) entr(?:y|ies)$`, func(want int) error {
				got, err := w.store.Count(context.Background())
				if err != nil {
					return err
				}
				if got != want {
					return fmt.Errorf("entries: want %d, got %d", want, got)
				}
				return nil
			})
			sc.Step(`^the newest entry has the text "(.*)"$`, func(want string) error {
				e, err := w.store.Newest(context.Background())
				if err != nil {
					return err
				}
				if e == nil {
					return fmt.Errorf("the diary has no entry")
				}
				if want = unescape.Replace(want); e.Text != want {
					return fmt.Errorf("text: want %q, got %q", want, e.Text)
				}
				return nil
			})
			sc.Step(`^the creation instant of the newest entry is within (\d+) seconds of now$`, func(secs string) error {
				n, _ := strconv.Atoi(secs)
				e, err := w.store.Newest(context.Background())
				if err != nil || e == nil {
					return fmt.Errorf("no newest entry: %v", err)
				}
				if d := time.Since(e.CreatedAt).Abs(); d > time.Duration(n)*time.Second {
					return fmt.Errorf("instant is %s away from now", d)
				}
				return nil
			})

			sc.Step(`^the submission is rejected with the reason "(.*)"$`, w.rejectedWith)
			sc.Step(`^the submission fails with the reason "(.*)"$`, w.rejectedWith)
			sc.Step(`^the form still holds the text "(.*)"$`, func(want string) error {
				got, err := w.formText()
				if err != nil {
					return err
				}
				if want = unescape.Replace(want); got != want {
					return fmt.Errorf("form: want %q, got %q", want, got)
				}
				return nil
			})
			sc.Step(`^the form is empty$`, func() error {
				got, err := w.formText()
				if err != nil {
					return err
				}
				if got != "" {
					return fmt.Errorf("form holds %q", got)
				}
				return nil
			})
			sc.Step(`^the user is told that the entry was saved$`, func() error {
				if msg, _ := w.message(); msg != "Entry saved." {
					return fmt.Errorf("message: %q", msg)
				}
				return nil
			})
		},
		Options: &godog.Options{
			Format: "pretty",
			// Only the features that this implementation has step bindings for.
			// Phase 6 adds the other files.
			Paths:    []string{filepath.Join("..", "..", "..", "specs", "features", "submit.feature")},
			Tags:     "~@manual",
			Strict:   true,
			TestingT: t,
		},
	}
	if suite.Run() != 0 {
		t.Fatal("scenarios failed")
	}
}
