RGGEN ?= rggen
PLUGIN ?= rggen-verilog
CONFIG ?= config.yml
MAP ?= register_map.yml

.PHONY: all gen clean

all: gen

gen:
	mkdir -p build
	$(RGGEN) --output build --plugin $(PLUGIN) -c $(CONFIG) $(MAP)

clean:
	rm -rf build