// https://gobyexample.com/ is very helpful if you do not know Go.
package main

import (
	"io/ioutil"
	"os"
)

// GNU style POSIX standard alternative to flag
// https://godoc.org/github.com/spf13/pflag
import flag "github.com/spf13/pflag"

// better logger
import "go.uber.org/zap"

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/ssm"
)

var SLogger *zap.SugaredLogger

// NoEnvVar - Environment variable empty or missing
const NoEnvVar = 1

// BadArgs - Too many or bad arguments passed
const BadArgs = 2

// NoSecret - Not able to retrieve secret
const NoSecret = 3

// FileError - File system error
const FileError = 4

// File name and path for shibboleth private key
const KeyName = "/service/shibd/private.key"
const KeyPath = "/var/run/shibboleth/sp-key.pem"

// File name and path for shibboleth public cert
const CertName = "/service/shibd/public.key"
const CertPath = "/var/run/shibboleth/sp-cert.pem"

// Working code but it won't be used in the production
/*
func GetParamKey(svc *ssm.SSM, keyname string) (string, error) {

	input := &ssm.GetParameterInput{
		Name:           aws.String(keyname),
		WithDecryption: aws.Bool(false),
	}

	result, err := svc.GetParameter(input)

	if err != nil {
		SLogger.Errorf("Failed to find param for keyname: %s", keyname)

		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case ssm.ErrCodeInternalServerError:
				SLogger.Error(ssm.ErrCodeInternalServerError)
			case ssm.ErrCodeInvalidKeyId:
				SLogger.Error(ssm.ErrCodeInvalidKeyId)
			case ssm.ErrCodeParameterNotFound:
				SLogger.Error(ssm.ErrCodeParameterNotFound)
			case ssm.ErrCodeParameterVersionNotFound:
				SLogger.Error(ssm.ErrCodeParameterVersionNotFound)
			}

			SLogger.Error(aerr.Error())
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			SLogger.Error(os.Stderr, err.Error())
		}
		return "", err
	}

	return *result.Parameter.Value, nil
}
*/

// GetParamKeys returns next token as a string and ssm.Parameter
func GetParamKeys(svc *ssm.SSM, nextToken *string, path string) (*string, []*ssm.Parameter) {

	input := &ssm.GetParametersByPathInput{
		NextToken:      nextToken,
		Path:           aws.String(path),
		Recursive:      aws.Bool(false),
		WithDecryption: aws.Bool(true),
	}

	results, err := svc.GetParametersByPath(input)

	if err != nil {
		SLogger.Errorf("Failed to find params for path page: %s", path)

		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case ssm.ErrCodeInternalServerError:
				SLogger.Error(ssm.ErrCodeInternalServerError)
			case ssm.ErrCodeInvalidFilterKey:
				SLogger.Error(ssm.ErrCodeInvalidFilterKey)
			case ssm.ErrCodeInvalidFilterOption:
				SLogger.Error(ssm.ErrCodeInvalidFilterOption)
			case ssm.ErrCodeInvalidFilterValue:
				SLogger.Error(ssm.ErrCodeInvalidFilterValue)
			case ssm.ErrCodeInvalidKeyId:
				SLogger.Error(ssm.ErrCodeInvalidKeyId)
			case ssm.ErrCodeInvalidNextToken:
				SLogger.Error(ssm.ErrCodeInvalidNextToken)
			}

			SLogger.Error(aerr.Error())
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			SLogger.Error(err.Error())
		}
		os.Exit(1)
	}

	return results.NextToken, results.Parameters
}

func InitSugarLogger() {
	logger, _ := zap.NewDevelopment()
	defer logger.Sync() // flushes buffer, if any

	SLogger = logger.Sugar()
}

func args() (string, string) {
	filePtr := flag.StringP("file", "f", "", "a file used to store the shib keys.")
	flag.Usage = func() {
		SLogger.Info("Usage: get-shib-keys [options] keyname\n\n")
		flag.PrintDefaults()
	}

	flag.Parse()
	if len(flag.Args()) != 1 {
		flag.Usage()
		os.Exit(BadArgs)
	}

	return *filePtr, flag.Args()[0]
}

func GetParamMap(svc *ssm.SSM, path string) map[string]string {
	var nextToken *string
	var params []*ssm.Parameter

	// make a map to return
	m := make(map[string]string)

	for {
		nextToken, params = GetParamKeys(svc, nextToken, path)
		for _, e := range params {
			m[*e.Name] = *e.Value
		}
		if nextToken == nil {
			break
		}
	}

	return m
}

func writeParamFile(param map[string]string, key string, path string) {

	err := ioutil.WriteFile(path, []byte(param[key]), 0640)

	if err != nil {
		SLogger.Error(err)
		os.Exit(FileError)
	}

	SLogger.Infof("Wrote to file: '%s'. Retrieved from AWS Parameter: '%s'\n", path, key)
}

func main() {
	InitSugarLogger()

	_, keyname := args()

	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))
	svc := ssm.New(sess)

	param := GetParamMap(svc, keyname)

	// now write to public and private key file
	writeParamFile(param, KeyName, KeyPath)
	writeParamFile(param, CertName, CertPath)
}
