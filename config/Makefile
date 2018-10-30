.PHONY: all image push pull clean

# http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

ROOT := $(call rwildcard,root,*)
GSRC := get-shib-keys/Makefile get-shib-keys/get-shib-keys.go
SRCS := Dockerfile $(ROOT) $(GSRC) ../base/.image
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
