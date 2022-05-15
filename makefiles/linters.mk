yamllint:
	yamllint -f parsable .

# Diagnostic output; useful when run in a git hook
_start-check:
	@echo 'Running "make check"'

# Run all tests and linters
check lint: _start-check yamllint
	@echo '**** LGTM! ****'
