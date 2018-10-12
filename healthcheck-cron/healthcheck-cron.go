// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"os"
	"time"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

// NoDataSealer - Unable to create the data sealer file
const NoSealerKeyFile = 1

// BadArgs - Too many or bad arguments passed
const BadArgs = 2

func args() (string, string) {
        filePtr := flag.StringP("file", "f", "", "a file used to store the sealer keys.")
        flag.Usage = func() {
                fmt.Printf("Usage: healthcheck-cron [options] keyname\n\n")
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
	fmt.Println("age of file is: ", time.Since(t))
	fmt.Println("expected max age: ", hour)

	return time.Since(t) > hour
}

func main() {
        _, filename := args()

	file, err := os.Stat(filename)

	if err != nil {
		fmt.Println("Failed to find key file")
                os.Exit(NoSealerKeyFile)
	}

	var keyDuration string = os.Getenv("KEY_DURATION")

	hour, err := time.ParseDuration(keyDuration)

	if err != nil || keyDuration == "" {
		hour = 24 * time.Hour
	}

	if isOlderThan(file.ModTime(), hour) {
		fmt.Println("This file is too old.")
	} else {
		fmt.Println("This file is young enough.")
	}
}
