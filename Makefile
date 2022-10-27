# Build and test
build:
	nile compile
test:
	pytest tests/
check: 
	cairo-format contracts/**/*.cairo -c
format:
	cairo-format contracts/**/*.cairo -i