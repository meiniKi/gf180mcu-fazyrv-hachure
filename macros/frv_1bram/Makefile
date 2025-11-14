RUN_TAG = $(shell ls runs/ -1 | tail -n 1)

ifndef PDK_ROOT
$(error PDK_ROOT is not set. Please pass it: make PDK_ROOT=/path/to/pdk)
endif

ifndef PDK
$(error PDK_ROOT is not set. Please pass it: make PDK=pdk)
endif

macro:
	yosys -s prep.ys
	librelane config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk
.PHONY: macro

macro-nodrc:
	yosys -s prep.ys
	librelane config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip KLayout.DRC --skip Magic.DRC
.PHONY: macro-nodrc

copy:
	cp -r runs/${RUN_TAG}/final .
.PHONY: copy

clean:
	rm -rf runs
	rm -rf final
	rm -f *_nl.sv
.PHONY: clean
