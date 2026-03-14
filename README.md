# RISC-V Pipelined Processor

This repository contains a 3-stage pipelined RISC-V processor implementation in Verilog, along with a C-to-RISC-V cross-compilation toolchain and simulation environment.

## Project Structure

### `modules/`

Contains the Verilog source code for the RISC-V processor.

- **`pipeline.v`**: The top-level module integrating all pipeline stages
- **`IF_ID.v`**: Instruction Fetch and Decode stage logic, including the pipeline register
- **`execute.v`**: Execution stage containing the ALU and branch resolution
- **`memory.v`**: Instruction and Data memory modules
- **`wb.v`**: Write-back stage logic
- **`testbench.v`**: The simulation testbench for verifying the processor
- **`fpga/`**: Contains the Vivado constraints (`.xdc`) and the top-level FPGA wrapper (`fpga.v`) for deployment to a Nexys A7 board

### `mem_generator/`

Provides the toolchain to write C code and convert it into memory initialization files for the Verilog simulator.

### `simulation/`

Contains the environment to run the Verilog simulation using Vivado's `xsim`.

## How to Run

### Prerequisites

- NodeJS and [xPack](https://xpack.github.io/)
- [`make`](https://www.gnu.org/software/make/)
- Python 3
- [Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html) tools in PATH

> [!NOTE]
> This project has been tested exclusively on Windows 11 using [MSYS2](https://www.msys2.org/) UCRT `make` and Vivado 2025.2  
> Compatibility with other operating systems or tool versions is not guaranteed

### Running Simulations

You can run the simulation tests using the xPack actions (`xpm run <action>`) defined in `package.json`.

Available simulation targets:

- `xpm run sim-addition`
- `xpm run sim-sort`
- `xpm run sim-negative`
- `xpm run sim-fibonacci`
- `xpm run sim-xor`

After simulation, you can find the generated waveform file `pipeline.vcd` inside the `simulation/` directory.

### Building Memory Files

If you just want to compile the C programs into `.hex` files without running the Vivado simulator, you can use the build actions:

- `xpm run build-addition`
- `xpm run build-sort`
- `xpm run build-negative`
- `xpm run build-fibonacci`
- `xpm run build-xor`

This will generate `imem.hex` and `dmem.hex` in the `mem_generator/imem_dmem/` directory.

### FPGA Synthesis and Implementation

The project includes scripts to synthesize and implement the processor for the **Nexys A7 (xc7a100tcsg324-1)**.

1. First, compile the C program you want to run on the FPGA (Eg. `xpm run build-addition`)
2. Run the synthesis and implementation pipeline using `xpm run synth`

### Programming the FPGA

Once the bitstream (`fpga.bit`) is generated, you can program the connected Nexys A7 board directly:

1. Ensure the board is connected via USB and turned ON
2. Run `xpm run program`
