package main

import (
	"flag"
	"log"
	"net/http"

	"diary/internal/diary"
)

func main() {
	dbPath := flag.String("db", "diary.db", "path of the entry store file")
	addr := flag.String("addr", "127.0.0.1:8000", "listen address")
	flag.Parse()

	store, err := diary.OpenStore(*dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer store.Close()

	log.Printf("listening on http://%s", *addr)
	log.Fatal(http.ListenAndServe(*addr, diary.NewHandler(store)))
}
