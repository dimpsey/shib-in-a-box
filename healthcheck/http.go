package main

import (
	"bytes"
	"fmt"
	"net/http"
	"net/http/httputil"
)

func httpClient(code int, url string, args Args) error {
	var err error
	var method string

	// disable redirects
	client := &http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

REDIRECT:
	if args.get {
		method = "GET"
	} else {
		method = "HEAD"
	}

	req, err := http.NewRequest(method, url, nil)
	if err != nil {
		return err
	}
	req.Header.Set("User-Agent", "HTTP/Healthcheck")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	dump, err := httputil.DumpResponse(resp, args.body)
	if err != nil {
		return err
	}

	if !args.quiet {
		fmt.Printf("%s\n\n", bytes.TrimSpace(dump))
	}

	if args.redirect {
		u, err := resp.Location()
		if err == nil {
			url = u.String()
			goto REDIRECT
		}
	}

	return checkStatusCode(code, resp.StatusCode)
}
