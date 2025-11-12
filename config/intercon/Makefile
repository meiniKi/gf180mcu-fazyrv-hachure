
PYTHON ?= python3
CONFIG ?= wb.yml

GENSCRIPT = ../../ip/wb_intercon/sw/wb_intercon_gen2.py
BUILD_DIR = build
DST_DIR = ../../src/gen

.PHONY: all gen clean

all: gen

gen:
	mkdir -p $(BUILD_DIR)
	$(PYTHON) $(GENSCRIPT) wb.yml
	mv wb_intercon.v $(BUILD_DIR)
	mv wb_intercon.vh $(BUILD_DIR)
	mv wb.core $(BUILD_DIR)

copy: gen
	cp $(BUILD_DIR)/wb_intercon.v $(DST_DIR)
	cp $(BUILD_DIR)/wb_intercon.vh $(DST_DIR)

clean:
	rm -rf $(BUILD_DIR)