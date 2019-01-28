DIRS := $(wildcard dev*) $(wildcard prod*)
TEST := $(DIRS:%=%.test)
CLEAN := $(DIRS:%=%.clean)

# TODO this does not work yet... Need to make sure each
# docker-compose binds to different external ports!
# MAKEFLAGS='-j 8'

.PHONY: all clean $(DIRS) $(CLEAN)

all: $(DIRS)

$(DIRS):
	$(MAKE) -C $@

test: $(TEST)

$(TEST): %.test:
	$(MAKE) -C $* test

clean: $(CLEAN)

$(CLEAN): %.clean:
	$(MAKE) -C $* clean
