
SUBDIRS := frv_1 frv_2 frv_4 frv_8 frv_4ccx

.PHONY: all
all: $(SUBDIRS)

.PHONY: $(SUBDIRS)
$(SUBDIRS):
	@echo "===> Entering directory '$@'"
	cd $@ && yosys -s prep.ys && cd ..
	@echo "<=== Leaving directory '$@'"


.PHONY: build clean

build: 
	@$(MAKE) -s all
