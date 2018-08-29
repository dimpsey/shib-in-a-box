// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"fmt"
	"os"
)

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/secretsmanager"
)

// This function is based on code taken from:
// https://docs.aws.amazon.com/sdk-for-go/api/service/secretsmanager/#example_SecretsManager_GetSecretValue_shared00
func getSecret(secretID string, versionStage string) (string, error) {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	svc := secretsmanager.New(sess)

	input := &secretsmanager.GetSecretValueInput{
		SecretId:     aws.String(secretID),
		VersionStage: aws.String(versionStage),
	}

	result, err := svc.GetSecretValue(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case secretsmanager.ErrCodeResourceNotFoundException:
				fmt.Println(secretsmanager.ErrCodeResourceNotFoundException, aerr.Error())
			case secretsmanager.ErrCodeInvalidParameterException:
				fmt.Println(secretsmanager.ErrCodeInvalidParameterException, aerr.Error())
			case secretsmanager.ErrCodeInvalidRequestException:
				fmt.Println(secretsmanager.ErrCodeInvalidRequestException, aerr.Error())
			case secretsmanager.ErrCodeDecryptionFailure:
				fmt.Println(secretsmanager.ErrCodeDecryptionFailure, aerr.Error())
			case secretsmanager.ErrCodeInternalServiceError:
				fmt.Println(secretsmanager.ErrCodeInternalServiceError, aerr.Error())
			default:
				fmt.Println(aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Println(err.Error())
		}
		return "", err
	}

	return *result.SecretString, nil
}

func main() {
	var c = 1
	var secretID = os.Getenv("SECRET_ID")
	var current, previous string
	var err error

	if secretID == "" {
		fmt.Println("Environment variable SECRET_ID is empty or not set!")
		os.Exit(1)
	}

	current, err = getSecret(secretID, "AWSCURRENT")
	if err != nil {
		os.Exit(2)
	}

    // For details on data format see:
    // https://wiki.shibboleth.net/confluence/display/SP3/VersionedDataSealer
	previous, err = getSecret(secretID, "AWSPREVIOUS")
	if err == nil {
		fmt.Print(c, ":", previous)
        fmt.Println()
        c++;
	}

	fmt.Print(c, ":", current)
    fmt.Println()
}
