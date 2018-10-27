.PHONY: all image push pull clean

GSRC := get-shib-keys/Makefile get-shib-keys/get-shib-keys.go
SRCS := Dockerfile entrypoint.sh $(GSRC) ../base/.image
IMAGE:= $(ORG)shibd-config

all: image

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
