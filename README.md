# gf180mcu FazyRV globefish SoC

FazyRV globefish SoC WiP.

## Pin Map

| Pad           | Pin               | Package | Dir | Description                                                  |
| ------------- | ----------------- | ------- | --- | ------------------------------------------------------------ |
| clk_pad       | clk_i             | S[0]    | in  | System clock                                                 |
| rst_n_pad     | rst_in            | S[1]    | in  | System reset (low active)                                    |
| bidir_PAD[0]  | spi_oled_sck      | S[2]    | out | SPI OLED clock                                               |
| bidir_PAD[1]  | spi_oled_sdo      | S[3]    | out | SPI OLED data                                                |
| input_PAD[0]  | en_wb             | S[4]    | in  | Enable Wishbon bus                                           |
| input_PAD[1]  | en_p              | S[5]    | in  | Enable peripherals                                           |
| input_PAD[2]  | en_p2             | S[6]    | in  | Enable redundant peripherals                                 |
| input_PAD[3]  | en_frv1           | S[7]    | in  | Enable 1-bit FazyRV core                                     |
| input_PAD[4]  | en_frv2           | S[9]    | in  | Enable 2-bit FazyRV core                                     |
| input_PAD[5]  | en_frv4           | S[10]   | in  | Enable 4-bit FazyRV core                                     |
| input_PAD[6]  | en_frv8           | S[11]   | in  | Enable 8-bit FazyRV core                                     |
| input_PAD[7]  | en_frv4ccx        | S[12]   | in  | Enable 4-bit FazyRV CCX core                                 |
| bidir_PAD[2]  | ccx4_sel[0]       | S[13]   | out | CCX cinsn select                                             |
| bidir_PAD[3]  | ccx4_sel[1]       | S[14]   | out | CCX cinsn select                                             |
| bidir_PAD[4]  | ccx4_req          | S[15]   | out | CCX request                                                  |
| input_PAD[8]  | ccx4_resp         | S[16]   | in  | CCX handshaking                                              |
| bidir_PAD[5]  | ccx4_rs_a[0]      | E[2]    | out | CCX operand a chunk                                          |
| bidir_PAD[6]  | ccx4_rs_a[1]      | E[3]    | out | CCX operand a chunk                                          |
| bidir_PAD[7]  | ccx4_rs_a[2]      | E[4]    | out | CCX operand a chunk                                          |
| bidir_PAD[8]  | ccx4_rs_a[3]      | E[5]    | out | CCX operand a chunk                                          |
| bidir_PAD[9]  | ccx4_rs_b[0]      | E[6]    | out | CCX operand b chunk                                          |
| bidir_PAD[10] | ccx4_rs_b[1]      | E[7]    | out | CCX operand b chunk                                          |
| bidir_PAD[11] | ccx4_rs_b[2]      | E[10]   | out | CCX operand b chunk                                          |
| bidir_PAD[12] | ccx4_rs_b[3]      | E[11]   | out | CCX operand b chunk                                          |
| input_PAD[9]  | ccx4_res[0]       | E[12]   | in  | CCX result chunk, Enable 1-bit BRAM FazyRV (if CCX disabled) |
| input_PAD[10] | ccx4_res[1]       | E[13]   | in  | CCX result chunk, Enable 8-bit BRAM FazyRV (if CCX disabled) |
| input_PAD[11] | ccx4_res[2]       | E[14]   | in  | CCX result chunk                                             |
| input_PAD[12] | ccx4_res[3]       | E[15]   | in  | CCX result chunk                                             |
| analog[0]     | reserved          | N[0]    | in  | reserved                                                     |
| bidir_PAD[13] | gpio[0]           | N[1]    | io  | General Purpose I/O                                          |
| bidir_PAD[14] | gpio[1]           | N[2]    | io  | General Purpose I/O                                          |
| bidir_PAD[15] | gpio[2]           | N[3]    | io  | General Purpose I/O                                          |
| bidir_PAD[16] | gpio[3]           | N[4]    | io  | General Purpose I/O                                          |
| input_PAD[13] | uart_rx           | N[5]    | in  | UART RX input                                                |
| bidir_PAD[17] | uart_tx           | N[6]    | out | UART TX output                                               |
| bidir_PAD[18] | spi_cs            | N[7]    | out | SPI chip select (low active)                                 |
| bidir_PAD[19] | spi_sck           | N[9]    | out | SPI clock                                                    |
| bidir_PAD[20] | spi_sdo           | N[10]   | out | SPI data output (copi)                                       |
| input_PAD[14] | spi_sdi           | N[11]   | in  | SPI data input (cipo)                                        |
| bidir_PAD[21] | efspi_cs          | N[12]   | out | SPI chip select (low active)                                 |
| bidir_PAD[22] | efspi_sck         | N[13]   | out | SPI clock                                                    |
| bidir_PAD[23] | efspi_sdo         | N[14]   | out | SPI data out                                                 |
| input_PAD[15] | efspi_sdi         | N[15]   | in  | SPI data in                                                  |
| bidir_PAD[24] | xip_cs_n          | N[16]   | out | XIP chip select                                              |
| bidir_PAD[25] | xip_sck           | W[0]    | out | XIP clock                                                    |
| bidir_PAD[26] | xip_sdi[0]        | W[1]    | io  | XIP bidir data                                               |
| bidir_PAD[27] | xip_sdi[1]        | W[4]    | io  | XIP bidir data                                               |
| bidir_PAD[28] | xip_sdi[2]        | W[5]    | io  | XIP bidir data                                               |
| bidir_PAD[29] | xip_sdi[3]        | W[6]    | io  | XIP bidir data                                               |
| bidir_PAD[30] | qspi_mem_cs_rom_n | W[7]    | out | QSPI ROM / Flash chip enable (low active)                    |
| bidir_PAD[31] | qspi_mem_cs_ram_n | W[10]   | out | QSPI RAM chip enable (low active)                            |
| bidir_PAD[32] | qspi_mem_sck      | W[11]   | out | QSPI clock                                                   |
| bidir_PAD[33] | qspi_mem_sdio[0]  | W[12]   | io  | QSPI bidir data                                              |
| bidir_PAD[34] | qspi_mem_sdio[1]  | W[13]   | io  | QSPI bidir data                                              |
| bidir_PAD[35] | qspi_mem_sdio[2]  | W[14]   | io  | QSPI bidir data                                              |
| bidir_PAD[36] | qspi_mem_sdio[3]  | W[15]   | io  | QSPI bidir data                                              |




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
