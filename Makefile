# All targets that are not files
.PHONY: all configure build open run help

# Only show the output
.SILENT: help

# The default target to run
.DEFAULT_GOAL := help

# Variables
pwdname := $(shell basename `pwd`)

# Try to detect the OS, falling back to 'uname' if $(OS) is empty
ifndef $(OS)
	OS := $(shell uname -s)
endif


help:             ## show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sort \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m      %s\n", $$1, $$2}'

dist:             ## create a distribution tar file for this program
	git bundle create $(pwdname).bundle HEAD
	git archive --output=$(pwdname).zip HEAD
	git archive --output=$(pwdname).tar.gz HEAD
	git archive --output=$(pwdname).tar.xz HEAD

distclean: $(pwdname).bundle $(pwdname).zip $(pwdname).tar.gz $(pwdname).tar.xz  ## like clean but do not clean installdirs and parent dirs
	$(RM) $^
clean:            ## delete all files that are normally created by running 'make all'.
	$(RM) -r .venv
check:            ## run self-tests
	uv check
configure:        ## configure the build environment
	command -v uv
dependencies:     ## install the dependencies
	uv sync
dependencies-update: ## update the configuration of the build environment
	uv lock --upgrade
dependencies-check:            ## run self-tests
	uv pip list --outdated
server:
	uv run --env-file .env uvicorn api.main:app --port 8000
repl: 	          ## Read Eval Print Loop
	uv run --env-file .env python
shell:            ## Start the UV shell
	@echo "source .venv/bin/activate"
	@echo run the above command
