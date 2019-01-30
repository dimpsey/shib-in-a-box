FEATURES=$(wildcard *.feature)
TESTS=$(FEATURES:%.feature=%)

all: $(DEPS)

%.feature:
	@test -e ../all/$@ || (echo ../all/$@: File does not exist! ; exit 1)
	ln -s ../all/$@

$(TOP_LEVEL):
	@test -e ../$@ || (echo ../$@: File does not exist! ; exit 1)
	ln -s ../$@

test:
	@export FLAGS="-D DISABLE_DOCKER_DOWN"; \
	test -f .up && export FLAGS="-D DISABLE_DOCKER_UP $$FLAGS"; \
	touch .up; \
    echo behave $$FLAGS; \
	behave $$FLAGS

$(TESTS):
	@export FLAGS="-D DISABLE_DOCKER_DOWN"; \
	test -f .up && export FLAGS="-D DISABLE_DOCKER_UP $$FLAGS"; \
	touch .up; \
    echo behave $$FLAGS $@.feature; \
	behave $$FLAGS $@.feature

down:
	docker-compose down
	-rm .up

clean: 
	rm -f $(DEPS)
