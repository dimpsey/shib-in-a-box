DIRS := $(wildcard dev*) $(wildcard prod*)
TEST := $(DIRS:%=%.test)
DOWN := $(DIRS:%=%.down)
CLEAN := $(DIRS:%=%.clean)

# MAKEFLAGS='-j 2'

.PHONY: all clean $(DIRS) $(CLEAN)

all: $(DIRS)

$(DIRS):
	$(MAKE) -C $@

test: $(TEST)

$(TEST): %.test:
	$(MAKE) -C $* test
	$(MAKE) -C $* down

down: $(DOWN)

$(DOWN): %.down:
	$(MAKE) -C $* down

clean: $(CLEAN)

$(CLEAN): %.clean:
	$(MAKE) -C $* clean
