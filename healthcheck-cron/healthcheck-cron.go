// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"time"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

var (
	Trace   *log.Logger
	Info    *log.Logger
	Warning *log.Logger
	Error   *log.Logger
)

// Healthy - healthcheck is good
const Healthy = 0

// Unhealthy - Unable to pass the health check
const Unhealthy = 1

// NoDataSealer - Unable to fine the data sealer file
const NoSealerKeyFile = 2

// BadArgs - Too many or bad arguments passed
const BadArgs = 3

// Init for logging
func InitLoggers(logLevel string) {

	var traceHandle io.Writer = os.Stderr
	var infoHandle io.Writer = os.Stderr
	var warningHandle io.Writer = os.Stderr
	var errorHandle io.Writer = os.Stderr

	switch strings.ToLower(logLevel) {
	case "trace":
		break
	case "error":
		warningHandle = ioutil.Discard
		fallthrough
	case "warning", "warn":
		infoHandle = ioutil.Discard
		fallthrough
	default:
		// default log level is info
		traceHandle = ioutil.Discard
	}
	Trace = log.New(traceHandle,
		"TRACE: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Info = log.New(infoHandle,
		"INFO: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Warning = log.New(warningHandle,
		"WARNING: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Error = log.New(errorHandle,
		"ERROR: ",
		log.Ldate|log.Ltime|log.Lshortfile)
}

func args() (string, string) {
	filePtr := flag.StringP("file", "f", "", "a file used to store the sealer keys.")
	flag.Usage = func() {
		Info.Printf("Usage: healthcheck-cron [options] keyname\n\n")
		flag.PrintDefaults()
	}

	flag.Parse()
	if len(flag.Args()) != 1 {
		flag.Usage()
		os.Exit(BadArgs)
	}

	return *filePtr, flag.Args()[0]
}

func isOlderThan(t time.Time, hour time.Duration) bool {
	Trace.Println("age of file is: ", time.Since(t))
	Trace.Println("expected max age: ", hour)

	return time.Since(t) > hour
}

func main() {

	InitLoggers(os.Getenv("LOG_LEVEL"))

	_, filename := args()

	file, err := os.Stat(filename)

	if err != nil {
		Error.Println("Failed to find key file")
		os.Exit(NoSealerKeyFile)
	}

	var keyDuration string = os.Getenv("KEY_DURATION")

	hour, err := time.ParseDuration(keyDuration)

	if err != nil || keyDuration == "" {
		hour = 24 * time.Hour
	}

	if isOlderThan(file.ModTime(), hour) {
		Error.Println("Uh-oh! The file is modified more than", hour, "ago.")
		os.Exit(Unhealthy)
	} else {
		Info.Println("Great! The file is modified less than", hour, "ago.")
		os.Exit(Healthy)
	}
}
