// healthcheck is used to check the http status code returned by a website.
// This is command is intended to be used as Docker health check for web
// services.
//
// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"net/url"
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
	body     bool
	get      bool
	redirect bool
	quiet    bool
}

func args() ([]string, []string, Args) {
	get := flag.BoolP("get", "g", false,
		"Use GET instead of HEAD")
	loc := flag.BoolP("location", "L", false,
		"Follow redirects in Location header field.")
	body := flag.BoolP("body", "b", false,
		"Print full body of response. By default only headers are shown")
	quiet := flag.BoolP("quiet", "q", false,
		"Quiet mode (don't output anything)")
	statusCodes := flag.StringArrayP("expected-status-code", "c", []string{"200"},
		"Check expected status code is returned.")

	flag.Usage = func() {
		fmt.Fprintln(os.Stderr, "Usage: healthcheck URL1 URL2 ... URLN")
		flag.PrintDefaults()
	}

	flag.Parse()
	if len(flag.Args()) == 0 {
		flag.Usage()
		os.Exit(Unhealthy)
	}

	if len(*statusCodes) > 1 {
		if len(*statusCodes) > len(flag.Args()) {
			fmt.Println("Too many status codes given!\a")
			os.Exit(Unhealthy)
		} else if len(*statusCodes) < len(flag.Args()) {
			fmt.Println("Not enough status codes given!\a")
			os.Exit(Unhealthy)
		}
	}

	if *body {
		*get = true
	}

	return *statusCodes, flag.Args(), Args{*body, *get, *loc, *quiet}
}

func atoi(s string) int {
	n, err := strconv.Atoi(s)

	if err != nil {
		fmt.Fprintf(os.Stderr, "%s is out of range!\n\a", s)
		os.Exit(Unhealthy)
	}

	return n
}

func healthCheck(code int, userUrl string, args Args) error {
	u, err := url.Parse(userUrl)
	if err != nil {
		return err
	}

	switch u.Scheme {
	case "ajp":
		return ajpClient(code, u.String(), args)
	default:
		return httpClient(code, u.String(), args)
	}
}

func main() {
	codes, urls, arguments := args()

	code := atoi(codes[0])
	for i, url := range urls {
		if i > 0 && len(codes) > 1 {
			code = atoi(codes[i])
			fmt.Println("")
		}

		err := healthCheck(code, url, arguments)
		if err != nil {
			fmt.Fprintln(os.Stderr, err.Error())
			os.Exit(Unhealthy)
		}
	}

	os.Exit(Healthy)
}
