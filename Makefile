#!/usr/bin/env false

# vim: set tabstop=8 shiftwidth=8 noexpandtab:

.DELETE_ON_ERROR:
SHELL   := /bin/bash

# BIN_DIR := /usr/local/opt/gcc-musl-cross/bin
BIN_DIR := /usr/local/Cellar/gcc-musl-cross/7.2.0/bin

TARGETS := $(patsubst %-gcc-7, %, $(notdir $(wildcard $(BIN_DIR)/*-gcc-7)))
TESTS   := $(addprefix test-, $(TARGETS))

CFLAGS  := -Os -Wall -Wextra
LDFLAGS := -static

.DEFAULT_GOAL := default

$(TESTS):  CC = $(BIN_DIR)/$(patsubst test-%,%-gcc-7,$@)
$(TESTS):  test.c
	$(LINK.c) $^ $(LDLIBS) -o $@

TEST_HOST := mario@sylvester

$(TESTS:=.out):
%.out:  %
	@rsync $* $(TEST_HOST):/tmp
	set -o pipefail && ssh $(TEST_HOST) -- /tmp/$(notdir $*) | tee $@

# DOCKER_RUN_FLAGS := -v /bin/bash-static:/bin/sh:ro

$(TESTS:=.dock):
%.dock: % Dockerfile
	@chmod 755 $*
	docker build --build-arg APP=$* --tag $* .
	set -o pipefail && docker run $$(cat qemu-static) --rm $(DOCKER_RUN_FLAGS) --name $* $* | tee $@

default::  $(TESTS)
run::      $(TESTS:=.out)
docker::   $(TESTS:=.dock)

file::  $(TESTS)
	@file $^

audit:: gcc-musl-cross.rb
	chmod 644 $<
	brew audit --strict $<
	brew audit --new-formula $<

clean::
	$(RM) $(wildcard $(TESTS:=.out) $(TESTS:=.dock))

distclean::  clean
	$(RM) $(wildcard $(TESTS))

# ***** end of source *****
