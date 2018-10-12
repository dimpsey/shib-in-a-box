// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"os"
    "time"
)

func isOlderThanOneDay(t time.Time, hour time.Duration) bool {
     fmt.Println("age of file is: ", time.Since(t))
     fmt.Println("expected max age: ", hour)

     return time.Since(t) > hour
}

func main() {
    file, err := os.Stat("./foo")

    if err != nil {
        fmt.Println("Failed to find key file")
    }
   
    var keyDuration string = os.Getenv("KEY_DURATION")

    hour, err := time.ParseDuration(keyDuration)

    if err != nil || keyDuration == "" {
        hour = 24*time.Hour 
    }

    if isOlderThanOneDay(file.ModTime(), hour) {
        fmt.Println("This file is too enough!")
    } else {
        fmt.Println("This file is young enough!")
    }
}
