package main

import (
	"fmt"
)

func checkStatusCode(expected int, code int) error {
	if expected != code {
		return fmt.Errorf(
			"Bad Response code: %d\nExpected Response code: %d\n",
			code,
			expected,
		)
	}

	return nil
}
