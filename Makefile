MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

RUN_TAG = $(shell ls librelane/runs/ | tail -n 1)
TOP = chip_top

PDK_ROOT ?= $(MAKEFILE_DIR)/gf180mcu
PDK ?= gf180mcuD
PDK_TAG ?= 1.1.0

.DEFAULT_GOAL := help

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'
.PHONY: help

all: librelane ## Build the project (runs LibreLane)
.PHONY: all

clone-pdk: ## Clone the GF180MCU PDK repository
	rm -rf $(MAKEFILE_DIR)/gf180mcu
	git clone https://github.com/wafer-space/gf180mcu.git $(MAKEFILE_DIR)/gf180mcu --depth 1 --branch ${PDK_TAG}
.PHONY: clone-pdk

librelane-macro-test:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro
.PHONY: librelane-macro-test

librelane-macro-test-or:
	librelane macros/frv_1/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInOpenROAD
.PHONY: librelane-macro-test-or


chip: librelane-macro copy-macro librelane copy-final
	echo "Done."
.PHONY: chip

librelane-macro:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro && \
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro
.PHONY: librelane-macro

librelane-macro-nodrc:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc && \
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro-nodrc
.PHONY: librelane-macro-nodrc

librelane-macro-fast:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro &
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" macro
.PHONY: librelane-macro-fast

copy-macro: librelane-macro-fast
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy && \
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" copy
.PHONY: copy-macro

backup-macro:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup && \
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" backup
.PHONY: backup-macro


clean-macro:
	$(MAKE) -C macros/frv_1 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_2 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_4 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_8 PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_4ccx PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_1bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean && \
	$(MAKE) -C macros/frv_8bram PDK_ROOT="$(PDK_ROOT)" PDK="${PDK}" clean
.PHONY: clean-macro

librelane-macro-openroad:
	librelane macros/frv_8/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInOpenROAD
.PHONY: librelane-macro-openroad


librelane: copy-macro ## Run LibreLane flow (synthesis, PnR, verification)
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk
.PHONY: librelane

librelane-nodrc: ## Run LibreLane flow without DRC checks
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip KLayout.DRC --skip Magic.DRC
.PHONY: librelane-nodrc

librelane-klayoutdrc: ## Run LibreLane flow without magic DRC checks
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip Magic.DRC
.PHONY: librelane-klayoutdrc

librelane-magicdrc: ## Run LibreLane flow without KLayout DRC checks
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --skip KLayout.DRC
.PHONY: librelane-magicdrc

librelane-openroad: ## Open the last run in OpenROAD
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInOpenROAD
.PHONY: librelane-openroad

librelane-klayout: ## Open the last run in KLayout
	librelane librelane/config.yaml --pdk ${PDK} --pdk-root ${PDK_ROOT} --manual-pdk --last-run --flow OpenInKLayout
.PHONY: librelane-klayout


#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_toggle.py
#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_sram_simple.py
#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_sram.py
#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_uart.py
#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_spi.py
#cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_efspi.py
sim:
	cd cocotb; PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_xip.py
.PHONY: sim


#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_toggle.py
#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_sram_simple.py
#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_sram.py
#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_uart.py
#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_spi.py
#cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_efspi.py
sim-gl: ## Run gate-level simulation with cocotb
	cd cocotb; GL=1 PDK_ROOT=${PDK_ROOT} PDK=${PDK} python3 test_sram.py
.PHONY: sim-gl

sim-view: ## View simulation waveforms in GTKWave
	gtkwave cocotb/sim_build/chip_top.fst
.PHONY: sim-view

copy-final: ## Copy final output files from the last run
	rm -rf final/
	cp -r librelane/runs/${RUN_TAG}/final/ final/
.PHONY: copy-final


SRC_SOC =   src/reset_sync.sv \
			src/gen/CSR.v \
			src/gen/wb_intercon.v \
			src/ram512x8.sv \
			src/ram512x32.sv \
			src/wb_ram.sv \
			src/wb_spi.sv \
			src/wb_qspi_mem.sv \
			src/tiny_wb_dma_oled_spi.sv \
			macros/frv_1/frv_1_nl.sv \
			src/hachure_soc.sv \
			ip/rggen-verilog-rtl/rggen_adapter_common.v \
			ip/rggen-verilog-rtl/rggen_wishbone_adapter.v \
			ip/rggen-verilog-rtl/rggen_mux.v \
			ip/rggen-verilog-rtl/rggen_bit_field.v \
			ip/rggen-verilog-rtl/rggen_default_register.v \
			ip/rggen-verilog-rtl/rggen_register_common.v \
			ip/rggen-verilog-rtl/rggen_address_decoder.v \
			ip/rggen-verilog-rtl/rggen_or_reducer.v \
			ip/verilog-arbiter/src/arbiter.v \
      		ip/wb_intercon/rtl/verilog/wb_cdc.v \
      		ip/wb_intercon/rtl/verilog/wb_arbiter.v \
      		ip/wb_intercon/rtl/verilog/wb_data_resize.v \
      		ip/wb_intercon/rtl/verilog/wb_mux.v \
			ip/EF_IP_UTIL/hdl/ef_util_lib.v \
			ip/EF_UART/hdl/rtl/EF_UART.v \
			ip/EF_UART/hdl/rtl/bus_wrappers/EF_UART_WB.v


INC_SOC =   ip/rggen-verilog-rtl

lint-soc-slang:
	slang --lint-only -I$(INC_SOC) $(SRC_SOC)
.PHONY: lint-soc-slang

lint-soc-verilator:
	verilator --lint-only -I$(INC_SOC) $(SRC_SOC)
.PHONY: lint-soc-verilator
