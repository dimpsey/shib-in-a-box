// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"sync"
)

import "github.com/robfig/cron"

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

var lock sync.Mutex

// Return codes

// UnknownError - Unknown Error
const UnknownError = 127

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

// NoDataSealer - Unable to create the data sealer file
const NoDataSealer = 2

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
func SprintDataSealer(svc *secretsmanager.SecretsManager, secretID string) (string, error) {
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
		return "", err
	}
	SprintGetSecret("AWSPREVIOUS")

	return r, nil
}

func getDataSealer(filename string, secretID string) error {
	// I do not know if this code is thread safe so let's serialize
	// it to be sure...
	lock.Lock()
	defer lock.Unlock()

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := secretsmanager.New(sess)

	dataSealer, err := SprintDataSealer(svc, secretID)
	if err != nil {
		return err
	}
	err = ioutil.WriteFile(filename, []byte(dataSealer), 0600)

	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return err
	}

	fmt.Fprint(os.Stderr, "Wrote data sealer to file: '", filename, "'.  Retrieved from AWS secret: '", secretID, ".'\n")
	return err
}

func getEnv(key string) string {
	value := os.Getenv(key)

	if value == "" {
		fmt.Fprint(os.Stderr, "Environment variable is undef: ", key, "\n\a")
		os.Exit(NoEnvVar)
	}
	return value
}

func main() {
	filename, secretID, schedule := getEnv("KEYS"), getEnv("SECRET_ID"), getEnv("SCHEDULE")

	err := getDataSealer(filename, secretID)
	if err != nil {
		os.Exit(NoDataSealer)
	}

	c := cron.New()
	c.AddFunc(schedule, func() { getDataSealer(filename, secretID) })
	c.Run()

	os.Exit(UnknownError)
}
