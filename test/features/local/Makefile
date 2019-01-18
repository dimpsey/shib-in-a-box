DIRS := $(wildcard dev*) $(wildcard prod*)
CLEAN := $(DIRS:%=%.clean)

.PHONY: all clean $(DIRS) $(CLEAN)

all: $(DIRS)

$(DIRS):
	$(MAKE) -C $@

clean: $(CLEAN)

$(CLEAN): %.clean:
	$(MAKE) -C $* clean
