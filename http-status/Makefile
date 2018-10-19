.PHONY: all image push pull clean compress

BUILD := http-status
DEPS := $(BUILD).go

SRCS := Dockerfile $(DEP)
IMAGE:= $(ORG)$(BUILD)

export CGO_ENABLED=0

all: $(BUILD)

deps:
	go get golang.org/x/lint/golint
	go get -d -v

compress: $(BUILD)
	upx -q --brute $(BUILD)
	upx -t $(BUILD)

$(BUILD): $(DEPS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build -ldflags "-w -s" -a -installsuffix cgo -o $@

image: .image
.image: $(SRCS)
	docker build -f Dockerfile -t $(IMAGE) .
	@touch $@

push: .push
.push: image
	docker push $(IMAGE)
	@touch $@

pull:
	docker pull $(IMAGE)

clean:
	-docker rmi $(IMAGE)
	-rm -f .image .push
	rm -f $(BUILD)
