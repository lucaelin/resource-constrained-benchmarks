package main

import (
	"fmt"
	"net/http"
	"sync"
	"time"

	"bytes"
	"encoding/json"
	"io/ioutil"

	"github.com/google/uuid"
	"flag"
)
type Payload struct {
	Data string `json:"data"`
}

var (
	run 							string
	baseURL           string
	numGoroutines     int
	durationInSeconds int
)

func init() {
	flag.StringVar(&run, "run", "0", "run number")
	flag.StringVar(&baseURL, "url", "http://localhost:8080", "Target URL")
	flag.IntVar(&numGoroutines, "connections", 1000, "Number of connections/goroutines")
	flag.IntVar(&durationInSeconds, "duration", 60, "Duration of the test in seconds")
}

func main() {
	flag.Parse()
	var wg sync.WaitGroup
	ch := make(chan int, numGoroutines)
	quit := make(chan struct{})

	for i := 0; i < numGoroutines; i++ {
		wg.Add(1)
		go doRequests(&wg, ch, quit)
	}

	timer := time.NewTimer(time.Duration(durationInSeconds) * time.Second)
	<-timer.C

	close(quit)
	wg.Wait()
	close(ch)

	var total int
	for count := range ch {
		total += count
	}

	throughput := float64(total) / float64(durationInSeconds)
	//fmt.Printf("total requests - %s - 0 - %v\n", run, total)
	fmt.Printf("throughput - %s - %v - %v req/sec\n", run, numGoroutines, throughput)
}

func doRequests(wg *sync.WaitGroup, ch chan int, quit <-chan struct{}) {
	defer wg.Done()

	client := &http.Client{
		Transport: &http.Transport{
			MaxIdleConns:        1,
			MaxIdleConnsPerHost: 1,
			IdleConnTimeout:     30 * time.Second,
		},
		Timeout: 10 * time.Second,
	}

	count := 0
	for {
		select {
		case <-quit:
			ch <- count
			return
		default:
			uuid := uuid.New().String()

			// fmt.Println("Making requests:", uuid)

			_, err := makePostRequest(client, fmt.Sprintf("%s/%s/command", baseURL, uuid), &Payload{Data: "string1"})
			if err != nil {
				//fmt.Println("Error making first POST request:", err)
				time.Sleep(10 * time.Millisecond)
				continue
			}
			count++;

			_, err = makePostRequest(client, fmt.Sprintf("%s/%s/command", baseURL, uuid), &Payload{Data: "string2"})
			if err != nil {
				//fmt.Println("Error making second POST request:", err)
				time.Sleep(10 * time.Millisecond)
				continue
			}
			count++;

			_, err = makeGetRequest(client, fmt.Sprintf("%s/%s/query", baseURL, uuid))
			if err != nil {
				//fmt.Println("Error making GET request:", err)
				time.Sleep(10 * time.Millisecond)
				continue
			}
			count++;
			// fmt.Println("Completed requests:", uuid)
		}
	}
}

func makePostRequest(client *http.Client, url string, payload *Payload) (*http.Response, error) {
	reqbody, err := json.Marshal(payload)
	if err != nil {
		return nil, err
	}

	resp, err := client.Post(url, "application/json", bytes.NewBuffer(reqbody))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("unexpected status code: got %v, response body: %s", resp.StatusCode, body)
	}

	return resp, nil
}

func makeGetRequest(client *http.Client, url string) (*http.Response, error) {
	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	body, _ := ioutil.ReadAll(resp.Body)

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("unexpected status code: got %v, response body: %s", resp.StatusCode, body)
	}

	return resp, nil
}