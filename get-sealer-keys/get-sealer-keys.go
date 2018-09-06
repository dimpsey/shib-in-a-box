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
	"github.com/aws/aws-sdk-go/service/secretsmanager"
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

// This function is based on code taken from:
// https://docs.aws.amazon.com/sdk-for-go/api/service/secretsmanager/#example_SecretsManager_GetSecretValue_shared00
func getSecret(svc *secretsmanager.SecretsManager, secretID string, versionStage string) (string, error) {

	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretID),
		VersionStage: aws.String(versionStage),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		fmt.Fprint(os.Stderr, "Failed to find secret: ", secretID, ", version: ", versionStage, "\n\n\a")

		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeResourceNotFoundException:
				fmt.Fprintln(os.Stderr, secretsmanager.ErrCodeResourceNotFoundException, aerr.Error())
			case secretsmanager.ErrCodeInvalidParameterException:
				fmt.Fprintln(os.Stderr, secretsmanager.ErrCodeInvalidParameterException, aerr.Error())
			case secretsmanager.ErrCodeInvalidRequestException:
				fmt.Fprintln(os.Stderr, secretsmanager.ErrCodeInvalidRequestException, aerr.Error())
			case secretsmanager.ErrCodeDecryptionFailure:
				fmt.Fprintln(os.Stderr, secretsmanager.ErrCodeDecryptionFailure, aerr.Error())
			case secretsmanager.ErrCodeInternalServiceError:
				fmt.Fprintln(os.Stderr, secretsmanager.ErrCodeInternalServiceError, aerr.Error())
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

	return *result.SecretString, nil
}

// SprintDataSealer returns a data sealer string
func SprintDataSealer(svc *secretsmanager.SecretsManager, secretID string) string {
	c := 1
	r := ""

	SprintGetSecret := func(versionStage string) error {
		secret, err := getSecret(svc, secretID, versionStage)

		// For details on data format see:
		// https://wiki.shibboleth.net/confluence/display/SP3/VersionedDataSealer
		if err == nil {
			r += fmt.Sprint(c, ":", secret, "\n")
			c++
		}

		return err
	}

	err := SprintGetSecret("AWSCURRENT")
	if err != nil {
		os.Exit(NoSecret)
	}
	SprintGetSecret("AWSPREVIOUS")

	return r
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
	svc := secretsmanager.New(sess)

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
