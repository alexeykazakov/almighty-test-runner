PROJECT_NAME=almighty-test-runner

PACKAGE_NAME := github.com/almighty/almighty-test-runner
BINARY=alm-test

SOURCEDIR=.
SOURCES := $(shell find $(SOURCEDIR) -name '*.go')

# Tools
GLIDE_BIN := $(shell command -v glide 2> /dev/null)

# Build configuration
BUILD_TIME=`date -u '+%Y-%m-%d_%I:%M:%S%p'`
COMMIT=$(shell git rev-parse HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GITUNTRACKEDCHANGES),)
	COMMIT := $(COMMIT)-dirty
endif

# Pass in build time variables to main
LDFLAGS="-X main.Commit=${COMMIT} -X main.BuildTime=${BUILD_TIME}"

.DEFAULT_GOAL := all

help: ## Get help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-10s\033[0m %s\n", $$1, $$2}'

.PHONY: clean 
clean: ## Removes binary
	if [ -f ${BINARY} ] ; then rm ${BINARY} ; fi

.PHONY: test
test: ## Runs ginkgo tests
	ginkgo -r

.PHONY: deps 
deps: ## Fetches all dependencies using Glide
	$(GLIDE_BIN) --verbose install

.PHONY: all 
all: clean deps $(BINARY) test ## (default) Performs clean deps build test

$(BINARY): $(SOURCES)
	go build -v -ldflags ${LDFLAGS} -o ${BINARY}