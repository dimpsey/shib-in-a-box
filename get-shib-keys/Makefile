BUILD := get-shib-keys
DEPS := $(BUILD).go

export CGO_ENABLED=0
export GOOS=linux

all: $(BUILD)

deps:
	go get golang.org/x/lint/golint
	go get -d -v

$(BUILD): $(DEPS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build -ldflags "-s" -a -installsuffix cgo -o $@

clean:
	rm -f $(BUILD)
