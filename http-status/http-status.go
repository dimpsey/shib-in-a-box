// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"net/http"
	"os"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

// better logger
import "go.uber.org/zap"

var SLogger *zap.SugaredLogger

// Success - returned status code is good
const Success = 0

// Fail - returned status code is bad
const BadResponse = 1

// BadArgs - Bad arguments passed
const BadArgs = 2

// HttpError - Http call error
const HttpError = 3

// GoodResonseCode - Expected respose code
const GoodResponse = 202

func InitSugarLogger() {
	logger, _ := zap.NewDevelopment()
	defer logger.Sync() // flushes buffer, if any

	SLogger = logger.Sugar()
}

func args() (string, string) {
	urlPtr := flag.StringP("url", "c", "", "URL to test the status")
	flag.Usage = func() {
		SLogger.Info("Usage: http-status [options] url\n\n")
		flag.PrintDefaults()
	}

	flag.Parse()
	if len(flag.Args()) != 1 {
		flag.Usage()
		os.Exit(BadArgs)
	}

	return *urlPtr, flag.Args()[0]
}

func main() {
	InitSugarLogger()

	_, url := args()

	resp, err := http.Head(url)
	if err != nil {
		SLogger.Error("Something went wrong with http call")
		SLogger.Error(err.Error())
		os.Exit(HttpError)
	}

	defer resp.Body.Close()

	if resp.StatusCode != GoodResponse {
		SLogger.Infof("Bad Response code: %d", resp.StatusCode)
		os.Exit(BadResponse)
	}
}
