package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
)

func httpClient(code int, url string, args Args) error {
	var err error
	var resp *http.Response

	// disable redirects
	client := &http.Client{
		CheckRedirect: func(req *http.Request, via []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}

REDIRECT:
	if args.get {
		resp, err = client.Get(url)
	} else {
		resp, err = client.Head(url)
	}

	if err != nil {
		return err
	}
	defer resp.Body.Close()

	dump, err := httputil.DumpResponse(resp, args.body)
	if err != nil {
		return err
	}

	if !args.quiet {
		fmt.Printf("%s", dump)
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
