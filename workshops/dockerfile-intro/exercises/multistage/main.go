package main

import (
	"fmt"
	"net/http"
	"runtime"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "<h1>Multi-Stage Build Demo</h1>"+
			"<p>Hello from a Go application!</p>"+
			"<p>Go version: <strong>%s</strong></p>"+
			"<p>Architecture: <strong>%s/%s</strong></p>",
			runtime.Version(), runtime.GOOS, runtime.GOARCH)
	})
	fmt.Println("Server starting on port 8080...")
	http.ListenAndServe(":8080", nil)
}
