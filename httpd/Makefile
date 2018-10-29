.PHONY: all image push pull clean

CGI   := root/var/www/html/cgi-bin
CONF  := root/etc/httpd/conf
CONFD := root/etc/httpd/confd

ROOT := root/entrypoint.sh $(CGI)/environment $(CONF)/httpd.conf $(wildcard $(CONFD)/*)
SRCS := Dockerfile $(ROOT) ../http-status/.image ../common/.image
IMAGE:= $(ORG)httpd

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
