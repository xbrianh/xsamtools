include common.mk

MODULES=xsamtools tests
SAMTOOLS_VERSION=1.10

export TNU_TESTMODE?=workspace_access

test: lint mypy test-samtools tests

lint:
	flake8 $(MODULES) *.py

mypy:
	mypy --ignore-missing-imports --no-strict-optional $(MODULES)

tests:
	PYTHONWARNINGS=ignore:ResourceWarning coverage run --source=xsamtools \
		-m unittest discover --start-directory tests --top-level-directory . --verbose

package_samtools: clean_samtools samtools.tar.bz2 htslib.tar.bz2 bcftools.tar.bz2

samtools.tar.bz2:
	git clone --depth 1 -b $(SAMTOOLS_VERSION) https://github.com/samtools/samtools.git
	(cd samtools ; rm -rf .git ; autoheader && autoconf)
	tar cjf samtools.tar.bz2 samtools
	rm -rf samtools

htslib.tar.bz2:
	git clone --depth 1 -b xbrianh-readers-idx https://github.com/xbrianh/htslib
	(cd htslib ; rm -rf .git ; autoheader && autoconf)
	tar cjf htslib.tar.bz2 htslib
	rm -rf htslib

bcftools.tar.bz2:
	git clone --depth 1 -b xbrianh-no-index https://github.com/xbrianh/bcftools
	(cd bcftools ; rm -rf .git)
	tar cjf bcftools.tar.bz2 bcftools
	rm -rf bcftools

clean_samtools:
	rm -rf samtools samtools.tar.bz2 bcftools bcftools.tar.bz2 htslib htslib.tar.bz2

version: xsamtools/version.py

xsamtools/version.py: setup.py
	echo "__version__ = '$$(python setup.py --version)'" > $@

clean:
	git clean -dfx

sdist: clean version
	python setup.py sdist

build: clean version
	python setup.py bdist_wheel

install: build
	pip install --upgrade dist/*.whl

test-samtools: build/samtools/samtools build/htslib/htsfile build/bcftools/bcftools
build/htslib/htsfile:
	python setup.py bdist_wheel
build/bcftools/bcftools:
	python setup.py bdist_wheel
build/samtools/samtools:
	python setup.py bdist_wheel

.PHONY: test lint mypy tests clean sdist build install package_samtools
