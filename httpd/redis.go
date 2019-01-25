// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"os"
)

import "github.com/go-redis/redis"

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		PrintError("Environment variable is undef: "+key, nil)
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

	return client
}

// Retrieve the value for the Elmr session key
func GetSessionValue(sessionKey string) string {

	client := RedisNewClient()

	val, err := client.Get(sessionKey).Result()

	if err != nil {
		PrintError("Redis key not found:"+sessionKey, err)
	}

	return val
}

func PrintError(errMsg string, err error) {
	fmt.Println("\n")
	if err != nil {
		fmt.Println("{\"error\": \"" + errMsg + "\", \"redisError\": \"" + err.Error() + "\"}")
	} else {
		fmt.Println("{\"error\": \"" + errMsg + "\"}")
	}
	os.Exit(0)
}

func main() {
	fmt.Println("content-type: application/json; charset=utf-8")
	value := GetSessionValue(getEnv("AJP_Shib_Session_ID"))

	fmt.Println("\n")
	fmt.Println(value)
}
