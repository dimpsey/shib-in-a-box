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

// NoRedisKey - Unable to find the redis key
const NoRedisKey = 2

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
		fmt.Println("{\"error\": \"Environment variable is undef: ", key, "\"}")
		//   os.Exit(NoEnvVar)
		os.Exit(0)
	}
	return value
}

// Create new Redis clinet
func RedisNewClient() *redis.Client {
	host := getEnv("REDIS_HOSTNAME")

	client := redis.NewClient(&redis.Options{
		Addr:     host,
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	// pong, err := client.Ping().Result()
	// fmt.Println(pong, err)

	// Output: PONG <nil>
	return client
}

// Retrieve the value for the Elmr session key
func GetSessionValue(sessionKey string) (string, error) {

	client := RedisNewClient()

	val, err := client.Get(sessionKey).Result()

	if err != nil {
		Error.Println("No Redis value with key", sessionKey, "found!")
		return "", err
	}

	return val, nil
}

func main() {
	// InitLoggers(os.Getenv("LOG_LEVEL"))

	// fmt.Println("content-type: application/json; charset=utf-8\n")
	// value, err := GetSessionValue(getEnv("AJP_Shib_Session_ID"))
	/*
		if err != nil {
	                fmt.Println("{\"error\": \"No Redis key is found\"}")
			// os.Exit(NoRedisKey)
			os.Exit(0)
		}

		fmt.Println(value)
	*/

	fmt.Println("Content-type: text/plain\n")
	fmt.Println("{\"a\":\"b\"}")
}
