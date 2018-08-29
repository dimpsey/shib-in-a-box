BUILD := get-sealer-keys
DEPS := $(BUILD).go

all: $(BUILD)

deps:
	go get github.com/golang/lint/golint
	go get -u github.com/aws/aws-sdk-go

$(BUILD): $(DEPS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build $?

clean:
	rm -f $(BUILD)
