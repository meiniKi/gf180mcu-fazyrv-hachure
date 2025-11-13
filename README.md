# gf180mcu FazyRV globefish SoC

FazyRV globefish SoC WiP.

## Pin Map

| Pad           | Pin               | Dir | Description                               |
| ------------- | ----------------- | --- | ----------------------------------------- |
| input_PAD[0]  | en_wb             | in  | Enable Wishbon bus                        |
| input_PAD[1]  | en_p2             | in  | Enable secondary peripherals              |
| input_PAD[2]  | en_p              | in  | Enable peripherals                        |
| input_PAD[3]  | en_frv1           | in  | Enable 1-bit FazyRV core                  |
| input_PAD[4]  | en_frv2           | in  | Enable 2-bit FazyRV core                  |
| input_PAD[5]  | en_frv4           | in  | Enable 4-bit FazyRV core                  |
| input_PAD[6]  | en_frv8           | in  | Enable 8-bit FazyRV core                  |
| input_PAD[7]  | en_frv4ccx        | in  | Enable 4-bit FazyRV CCX core              |
| input_PAD[7]  |                   |     |                                           |
| input_PAD[8]  |                   |     |                                           |
| input_PAD[9]  |                   |     |                                           |
| input_PAD[10] |                   |     |                                           |
| input_PAD[11] |                   |     |                                           |
| input_PAD[12] |                   |     |                                           |
| bidir_PAD[0]  | qspi_mem_cs_rom_n | out | QSPI ROM / Flash chip enable (low active) |
| bidir_PAD[1]  | qspi_mem_cs_ram_n | out | QSPI RAM chip enable (low active)         |
| bidir_PAD[2]  | qspi_mem_sck      | out | QSPI clock                                |
| bidir_PAD[3]  | qspi_mem_sdio[0]  | io  | QSPI bidir data                           |
| bidir_PAD[4]  | qspi_mem_sdio[1]  | io  | QSPI bidir data                           |
| bidir_PAD[5]  | qspi_mem_sdio[2]  | io  | QSPI bidir data                           |
| bidir_PAD[6]  | qspi_mem_sdio[3]  | io  | QSPI bidir data                           |
| bidir_PAD[7]  | uart_tx           | out | UART TX output                            |
| bidir_PAD[8]  | uart_rx           | in  | UART RX input                             |
| bidir_PAD[9]  | spi_oled_sck      | out | SPI OLED clock                            |
| bidir_PAD[10] | spi_oled_sdo      | out | SPI OLED data                             |
| bidir_PAD[11] | spi_cs            | out | SPI chip select (low active)              |
| bidir_PAD[12] | spi_sck           | out | SPI clock                                 |
| bidir_PAD[13] | spi_sdo           | out | SPI data output (copi)                    |
| bidir_PAD[14] | spi_sdi           | in  | SPI data input (cipo)                     |
| bidir_PAD[15] |                   |     |                                           |
| bidir_PAD[16] |                   |     |                                           |
| bidir_PAD[17] |                   |     |                                           |
| bidir_PAD[18] |                   |     |                                           |
| bidir_PAD[19] |                   |     |                                           |
| bidir_PAD[20] |                   |     |                                           |
| bidir_PAD[21] |                   |     |                                           |
| bidir_PAD[22] |                   |     |                                           |
| bidir_PAD[23] |                   |     |                                           |
| bidir_PAD[24] |                   |     |                                           |
| bidir_PAD[25] |                   |     |                                           |
| bidir_PAD[26] |                   |     |                                           |
| bidir_PAD[27] |                   |     |                                           |
| bidir_PAD[28] |                   |     |                                           |
| bidir_PAD[29] |                   |     |                                           |
| bidir_PAD[30] |                   |     |                                           |
| bidir_PAD[31] |                   |     |                                           |
| bidir_PAD[32] |                   |     |                                           |
| bidir_PAD[33] |                   |     |                                           |
| bidir_PAD[34] |                   |     |                                           |
| bidir_PAD[35] |                   |     |                                           |
| bidir_PAD[36] |                   |     |                                           |
| bidir_PAD[37] |                   |     |                                           |
| bidir_PAD[38] |                   |     |                                           |
| bidir_PAD[39] |                   |     |                                           |

## Memory Map

| Base Address | Name      | Description                    |
| ------------ | --------- | ------------------------------ |
| 0x0000_0000  | XIP_ROM   | QSPI XIP ROM                   |
| 0x1000_0000  | QSPI_SRAM | QSPI SRAM                      |
| 0x2000_0000  | RAM       | On-Chip RAM                    |
| 0x3000_0000  | UART      | UART Peripheral                |
| 0x4000_0000  | SPI       | SPI Peripheral                 |
| 0x5000_0000  | CSRs      | GPIOs, SPI Config, Oled Config |
| 0x6000_0000  | EF_SPI    | Secondary SPI Peripheral       |
| 0x7000_0000  | EF_XIP    | Secondary XIP Peripheral       |


## Prerequisites

We use a custom fork of the [gf180mcuD PDK variant](https://github.com/wafer-space/gf180mcu) until all changes have been upstreamed.

To clone the latest PDK version, simply run `make clone-pdk`.

In the next step, install LibreLane by following the Nix-based installation instructions: https://librelane.readthedocs.io/en/latest/installation/nix_installation/index.html

## Implement the Design

This repository contains a Nix flake that provides a shell with the [`leo/gf180mcu`](https://github.com/librelane/librelane/tree/leo/gf180mcu) branch of LibreLane.

Simply run `nix-shell` in the root of this repository.

> [!NOTE]
> Since we are working on a branch of LibreLane, OpenROAD needs to be compiled locally. This will be done automatically by Nix, and the binary will be cached locally. 

With this shell enabled, run the implementation:

```
make librelane
```

## View the Design

After completion, you can view the design using the OpenROAD GUI:

```
make librelane-openroad
```

Or using KLayout:

```
make librelane-klayout
```

## Copying the Design to the Final Folder

To copy your latest run to the `final/` folder in the root directory of the repository, run the following command:

```
make copy-final
```

This will only work if the last run was completed without errors.

## Verification and Simulation

We use [cocotb](https://www.cocotb.org/), a Python-based testbench environment, for the verification of the chip.
The underlying simulator is Icarus Verilog (https://github.com/steveicarus/iverilog).

The testbench is located in `cocotb/chip_top_tb.py`. To run the RTL simulation, run the following command:

```
make sim
```

To run the GL (gate-level) simulation, run the following command:

```
make sim-gl
```

> [!NOTE]
> You need to have the latest implementation of your design in the `final/` folder. After implementing the design, execute 'make copy-final' to copy all necessary files.

In both cases, a waveform file will be generated under `cocotb/sim_build/chip_top.fst`.
You can view it using a waveform viewer, for example, [GTKWave](https://gtkwave.github.io/gtkwave/).

```
make sim-view
```

You can now update the testbench according to your design.

## Implementing Your Own Design

The source files for this template can be found in the `src/` directory. `chip_top.sv` defines the top-level ports and instantiates `chip_core`, chip ID (QR code) and the wafer.space logo. To allow for the default bonding setup, do not change the number of pads in order to keep the original bondpad positions. To be compatible with the default breakout PCB, do not change any of the power or ground pads. However, you can change the type of the signal pads, e.g. to bidirectional, input-only or e.g. analog pads. The template provides the `NUM_INPUT` and `NUM_BIDIR` parameters for this purpose.

The actual pad positions are defined in the LibreLane configuration file under `librelane/config.yaml`. The variables `PAD_SOUTH`/`PAD_EAST`/`PAD_NORTH`/`PAD_WEST` determine the respective pad placement. The LibreLane configuration also allows you to customize the flow (enable or disable steps), specify the source files, set various variables for the steps, and instantiate macros. For more information about the configuration, please refer to the LibreLane documentation: https://librelane.readthedocs.io/en/latest/

To implement your own design, simply edit `chip_core.sv`. The `chip_core` module receives the clock and reset, as well as the signals from the pads defined in `chip_top`. As an example, a 42-bit wide counter is implemented.

> [!NOTE]
> For more comprehensive SystemVerilog support, enable the `USE_SLANG` variable in the LibreLane configuration.

## Precheck

To check whether your design is suitable for manufacturing, run the [gf180mcu-precheck](https://github.com/wafer-space/gf180mcu-precheck) with your layout.
