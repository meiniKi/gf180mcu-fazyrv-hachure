
# Find all subdirectories starting with test_
SUBDIRS := $(wildcard test_*)

.PHONY: firmware $(SUBDIRS)

firmware: $(SUBDIRS)

# For each test_* directory, run "make all" inside it
$(SUBDIRS):
	$(MAKE) -C $@ all

clean:
	@for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done