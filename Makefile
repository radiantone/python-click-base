.DEFAULT_GOAL := all
black = black --target-version py39 pcb
isort = isort --profile black pcb

.PHONY: depends
depends:
	bash ./bin/depends.sh

.PHONY: init
init: depends
	echo "Setting up virtual environment in venv/"
	python3 -m venv venv
	echo "Virtual environment complete."
	echo
	echo "Now run:"
	echo "$ source venv/bin/activate"

.PHONY: format
format:
	$(isort)
	$(black)

.PHONY: lint
lint:
	mypy --show-error-codes pcb
	flake8 --ignore=E203,F841,E501,E722,W503  pcb
	$(isort) --check-only --df
	$(black) --check --diff

.PHONY: install
install: depends init
	pip install -r requirements.txt
	python setup.py install
	python setup.py clean

.PHONY: update
update: format lint
	pip freeze | grep -v pcb > requirements.txt
	git add setup.py docs bin pcb requirements.txt Makefile
	git commit --allow-empty -m "Updates"
	git push origin main
	python setup.py install
	git status

.PHONY: docs
docs:
	cd docs
	make -C docs html

.PHONY: clean
clean:
	python setup.py clean
	git status

.PHONY: test
test: format lint
	python setup.py install
	pytest
	
.PHONY: all
all: format lint update docs install test clean
	git status