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
		fmt.Fprint(os.Stderr, "Failed to find params for path page: ", path, "\n\n\a")

		if aerr, ok := err.(awserr.Error); ok {
			switch aerr.Code() {
			case ssm.ErrCodeInternalServerError:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInternalServerError, aerr.Error())
			case ssm.ErrCodeInvalidFilterKey:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidFilterKey, aerr.Error())
			case ssm.ErrCodeInvalidFilterOption:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidFilterOption, aerr.Error())
			case ssm.ErrCodeInvalidFilterValue:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidFilterValue, aerr.Error())
			case ssm.ErrCodeInvalidKeyId:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidKeyId, aerr.Error())
			case ssm.ErrCodeInvalidNextToken:
				fmt.Fprintln(os.Stderr, ssm.ErrCodeInvalidNextToken, aerr.Error())
			default:
				fmt.Fprintln(os.Stderr, aerr.Error())
			}
		} else {
			// Print the error, cast err to awserr.Error to get the Code and
			// Message from an error.
			fmt.Fprintln(os.Stderr, err.Error())
		}
		os.Exit(1)
	}

	return results.NextToken, results.Parameters
}

func args() (string, string) {
	filePtr := flag.StringP("file", "f", "", "a file used to store the shib keys.")
	flag.Usage = func() {
		fmt.Printf("Usage: get-shib-keys [options] keyname\n\n")
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
		fmt.Fprintln(os.Stderr, err)
		os.Exit(FileError)
	}

	fmt.Fprint(os.Stderr, "Wrote to file: '", path, "'.  Retrieved from AWS Parameter: '", key, ".'\n")
}

func main() {
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
