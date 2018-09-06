// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"io/ioutil"
	"os"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
)

// Return codes

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

// BadArgs - Too many or bad arguments passed
const BadArgs = 2

// NoSecret - Not able to retrieve secret
const NoSecret = 3

// FileError - File system error
const FileError = 4

func getParamKey(svc *ssm.SystemsManager, keyname string) (string, error) {

    input := &ssm.GetParameterInput{
            Name: aws.String(keyname),
            WithDecryption: aws.Bool(decription)
    }

    result, err := svc.GetParameter(input)

    if err != nil {
        fmt.Fprint(os.Stderr, "Failed to find param for keyname: ", keyname, "\n\n\a")

        if aerr, ok := err.(awserr.Error); ok {
                switch aerr.Code() {
                case ssm.ErrCodeInternalServerError:
                        fmt.Fprintln(os.Stderr, ssm.ErrCodeInternalServerError, aerr.Error())
                case ssm.ErrCodeInvalidKeyId:
                        fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidKeyId, aerr.Error())
                case ssm.ErrCodeParameterNotFound:
                        fmt.Fprintln(os.Stderr, ssm.ErrCodeParameterNotFound, aerr.Error())
                case ssm.ErrCodeParameterVersionNotFound:
                        fmt.Fprintln(os.Stderr, ssm.ErrCodeParameterVersionNotFound, aerr.Error())
                default:
                        fmt.Fprintln(os.Stderr, aerr.Error())
                }
        } else {
                // Print the error, cast err to awserr.Error to get the Code and
                // Message from an error.
                fmt.Fprintln(os.Stderr, err.Error())
        }
        return "", err
    }

    return *result.Parameter.Value, nil
}

func args() (string, string) {
    filePtr := flag.StringP("file", "f", "", "a file used to store the data sealer.")
    flag.Usage = func() {
            fmt.Printf("Usage: get-sealer-keys [options] secret-id\n\n")
            flag.PrintDefaults()
    }

    flag.Parse()
    if len(flag.Args()) != 1 {
            flag.Usage()
            os.Exit(BadArgs)
    }

    return *filePtr, flag.Args()[0]
}

func main() {
    filename, secretID := args()

    sess := session.Must(session.NewSessionWithOptions(session.Options{
            SharedConfigState: session.SharedConfigEnable,
    }))
    svc := ssm.New(sess)

    param, err := getParamKey(svc, keyname, false)

    if err == nil {
          r += fmt.Sprint(c, ":", secret, "\n")
          c++
    }

    return err

    dataSealer := SprintDataSealer(svc, secretID)
    if filename == "" {
            fmt.Print(dataSealer)
    } else {
            err := ioutil.WriteFile(filename, []byte(dataSealer), 0600)

            if err != nil {
                    fmt.Fprintln(os.Stderr, err)
                    os.Exit(FileError)
            }

            fmt.Fprint(os.Stderr, "Wrote data sealer to file: '", filename, "'.  Retrieved from AWS secret: '", secretID, ".'\n")
    }
}
