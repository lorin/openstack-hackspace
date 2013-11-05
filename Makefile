#
# Use pandoc to generate docs
#
.PHONY: all

all: boot-instance.html devstack.html getting-started.html object-storage.html under-the-hood.html

%.html: %.md
	pandoc $< -o $@

