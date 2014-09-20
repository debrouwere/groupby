all: build

.PHONY: build
build:
	coffee --output lib --compile src

oldtest:
	./bin/groupby examples/countries.json 'examples/regions/{region}.json' \
		--index

.PHONY: test
test: build
	rm -rf examples/*/*
	mocha test \
		--require should \
		--compilers coffee:coffee-script/register
