all: build

.PHONY: build
build:
	coffee --output lib --compile src

.PHONY: test
test: build
	#rm -rf examples/*/*
	mocha test \
		--require should \
		--compilers coffee:coffee-script/register
