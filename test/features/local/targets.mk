all: $(DEPS)

test:
	behave

clean: 
	rm -f $(DEPS)
