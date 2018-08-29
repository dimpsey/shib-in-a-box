all: deps get-sealer-keys

deps:
	go get -u github.com/aws/aws-sdk-go

get-sealer-keys: get-sealer-keys.go
	go build get-sealer-keys.go

clean:
	rm -f get-sealer-keys
