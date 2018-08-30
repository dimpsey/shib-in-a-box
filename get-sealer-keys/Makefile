BUILD := get-sealer-keys
DEPS := $(BUILD).go

export CGO_ENABLED=0
export GOOS=linux

all: $(BUILD)

deps:
	go get github.com/golang/lint/golint
	go get -u github.com/aws/aws-sdk-go

$(BUILD): $(DEPS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build -ldflags "-s" -a -installsuffix cgo -o $@

clean:
	rm -f $(BUILD)
