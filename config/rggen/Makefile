RGGEN ?= rggen
PLUGIN ?= rggen-verilog
CONFIG ?= config.yml
MAP ?= register_map.yml

BUILD_DIR = build
DST_DIR = ../../src/gen

.PHONY: all gen clean

all: gen

gen:
	mkdir -p $(BUILD_DIR)
	$(RGGEN) --output $(BUILD_DIR) --plugin $(PLUGIN) -c $(CONFIG) $(MAP)

copy: gen
	cp $(BUILD_DIR)/CSR.v $(DST_DIR)
	cp $(BUILD_DIR)/CSR.vh $(DST_DIR)

clean:
	rm -rf $(BUILD_DIR)