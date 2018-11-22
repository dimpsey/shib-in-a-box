.PHONY: all clean compress deps

include common.mk

export CGO_ENABLED=0

all: $(BUILD)

deps:
	go get golang.org/x/lint/golint
	go get -d -v

compress: $(BUILD)
	upx -q --brute $(BUILD)
	upx -t $(BUILD)

$(BUILD): $(GSRCS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build -ldflags "-w -s" -a -installsuffix cgo -o $@

test: $(BUILD)
	./$(BUILD) http://localhost/auth/elmr/config
	./$(BUILD) -c 302 http://localhost/auth/elmr/attributes
	./$(BUILD) -Lc 400 http://localhost/auth/elmr/attributes
	
	./$(BUILD) ajp://localhost/auth/elmr/config
	./$(BUILD) ajp://localhost:8009/auth/elmr/config
	./$(BUILD) -c 200 ajp://localhost:8009/auth/elmr/config
	./$(BUILD) -c 302 ajp://localhost:8009/auth/elmr/attributes
	./$(BUILD) -c 404 ajp://localhost:8009
	
	./$(BUILD) -c 302 ajp://localhost:8009/auth/elmr ajp://localhost:8009/auth/elmr
	./$(BUILD) -c 200 ajp://localhost:8009/auth/elmr/config -c 302 ajp://localhost:8009/auth/elmr
	
	! ./$(BUILD) -c 200 ajp://localhost:8009/auth/elmr/config -c 302
	! ./$(BUILD) -c 200 ajp://localhost:8009/auth/elmr/config -c 302 ajp://localhost:8009/auth/elmr/config ajp://localhost:8009/auth/elmr/config

clean:
	rm -f $(BUILD)
