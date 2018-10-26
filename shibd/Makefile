.PHONY: all image push pull clean

SRCS := Dockerfile ../common/.image
IMAGE:= $(ORG)shibd

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
