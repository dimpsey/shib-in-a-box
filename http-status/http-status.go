// http-status is used to check the http status code returned by a website.
// This is command is intended to be used as Docker health check for web
// services.
//
// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"net/http"
	"net/http/httputil"
	"os"
	"strconv"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

// Healthy - returned status code is good
const Healthy = 0

// Unhealthy - returned status code is bad
const Unhealthy = 1

type Args struct {
	body  bool
	get   bool
	quiet bool
}

func args() ([]string, []string, Args) {
	get := flag.BoolP("get", "g", false,
		"Use GET instead of HEAD")
	body := flag.BoolP("body", "b", false,
		"Print full body of response. By default only headers are shown")
	quiet := flag.BoolP("quiet", "q", false,
		"Quiet mode (don't output anything)")
	statusCodes := flag.StringArrayP("expected-status-code", "c", []string{"200"},
		"Check expected status code is returned.")

	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: http-status URL1 URL2 ... URLN")
		flag.PrintDefaults()
	}

	flag.Parse()
	if len(flag.Args()) == 0 {
		flag.Usage()
		os.Exit(1)
	}

	if len(*statusCodes) > 1 {
		if len(*statusCodes) > len(flag.Args()) {
			fmt.Println("Too many status codes given!\a")
			os.Exit(1)
		} else if len(*statusCodes) < len(flag.Args()) {
			fmt.Println("Not enough status codes given!\a")
			os.Exit(1)
		}
	}

	if *body {
		*get = true
	}

	return *statusCodes, flag.Args(), Args{*body, *get, *quiet}
}

func atoi(s string) int {
	n, err := strconv.Atoi(s)

	if err != nil {
		fmt.Fprintf(os.Stderr, "%s is out of range!\n\a", s)
		os.Exit(1)
	}

	return n
}

func main() {
	codes, urls, arguments := args()

	code := atoi(codes[0])
	for i, url := range urls {
		if i > 0 && len(codes) > 1 {
			code = atoi(codes[i])
			fmt.Println("")
		}

		healthcheck(code, url, arguments)
	}

	os.Exit(0)
}

func healthcheck(code int, url string, args Args) {
	var err error
	var resp *http.Response

	if args.get {
		resp, err = http.Get(url)
	} else {
		resp, err = http.Head(url)
	}

	if err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(Unhealthy)
	}
	defer resp.Body.Close()

	dump, err := httputil.DumpResponse(resp, args.body)
	if err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(Unhealthy)
	}

	if !args.quiet {
		fmt.Printf("%s", dump)
	}

	if resp.StatusCode != code {
		if !args.quiet {
			fmt.Printf("Bad Response code: %d\n", resp.StatusCode)
			fmt.Printf("Expected Response code: %d\n", code)
		}
		os.Exit(Unhealthy)
	}
}
