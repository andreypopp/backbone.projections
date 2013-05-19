BIN = ../node_modules/.bin

test: test-commonjs test-globals

test-commonjs: spec.js
	@$(BIN)/mocha -b -R spec ./spec.js

test-globals: spec.js
	@$(BIN)/mocha-phantomjs ./runner.html

%.js: %.coffee
	@$(BIN)/coffee -bcp $< > $@
