// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"os"
	"strings"
)

import "github.com/go-redis/redis"

var (
	Trace   *log.Logger
	Info    *log.Logger
	Warning *log.Logger
	Error   *log.Logger
)

// Return codes

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

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

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		Error.Println("Environment variable is undef: ", key, "\n\a")
		os.Exit(NoEnvVar)
	}
	return value
}

func RedisNewClient() *redis.Client {
	client := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379",
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	// pong, err := client.Ping().Result()
	// fmt.Println(pong, err)

	// Output: PONG <nil>
	return client
}

func GetSessionValue(sessionKey string) (string, error) {

	client := RedisNewClient()

	val, err := client.Get(sessionKey).Result()

	if err != nil {
		Error.Println(err)
	}

	return val, nil
}

func main() {
	InitLoggers(os.Getenv("LOG_LEVEL"))

	value, err := GetSessionValue(getEnv("AJP_Shib-Session-ID"))

	if err != nil {
		Error.Println(err)
	}

	fmt.Println("Session Value:", value)
}
