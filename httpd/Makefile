rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

ROOT := $(call rwildcard,root,*)
SRCS := Dockerfile $(ROOT) ../common/.image
NAME := httpd

include ../Common.mk
