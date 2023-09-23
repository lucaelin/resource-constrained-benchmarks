package main

import (
	"flag"
	"fmt"
	"net/http"
	"time"
	"io/ioutil"

	"github.com/google/uuid"
)

var baseURL string
var run string

func init() {
	flag.StringVar(&baseURL, "url", "http://localhost:8080", "Target URL")
	flag.StringVar(&run, "run", "0", "run number")
}

func main() {
	flag.Parse()

	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	initialStart := time.Now()
	initalElapsed := time.Since(initialStart)

	successfulRequests := 0
	for successfulRequests < 100 {
		uuid := uuid.New().String()
		
		start := time.Now()
		// Replace the URL and Method according to your server endpoint
		resp, err := client.Get(fmt.Sprintf("%s/%s/query", baseURL, uuid))
		if err != nil {
			// fmt.Println("Error making the request:", err)
			initalElapsed = time.Since(initialStart)
			time.Sleep(1 * time.Millisecond)
			continue
		}
		ioutil.ReadAll(resp.Body)
		resp.Body.Close()

		elapsed := time.Since(start)
		if successfulRequests == 0 {
			fmt.Printf("service up - %s - 0 - %.5f seconds\n", run, initalElapsed.Seconds())
		}
		if resp.StatusCode >= 200 && resp.StatusCode < 300 {
			fmt.Printf("warmup request - %s - %d - %.5f seconds\n", run, successfulRequests+1, elapsed.Seconds())
			successfulRequests++
		} else {
			fmt.Printf("warmup request failure - %s - %d - %.5f seconds - %v\n", run, successfulRequests+1, elapsed.Seconds(), resp.StatusCode)
		}

		// Sleep between requests if necessary
		//time.Sleep(10 * time.Millisecond)
	}
}