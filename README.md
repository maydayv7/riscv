# RISC-V Pipelined Processor

This repository contains a 3-stage pipelined RISC-V processor implementation in Verilog, along with a C-to-RISC-V cross-compilation toolchain and simulation environment.

Click [here](./Diagrams.pdf) to view the hand-drawn block diagrams.

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

### `firmware/`

Provides the toolchain to write C code and convert it into memory initialization files for the Verilog simulator.

### `simulation/`

Contains the environment to run the Verilog simulation using Vivado's `xsim`.

### `fpga/`

Includes scripts to synthesize and implement the processor for the **Nexys A7 (xc7a100tcsg324-1)**.

## How to Run

### Prerequisites

- NodeJS and [xPack](https://xpack.github.io/)
- Python 3
- [Vivado](https://www.amd.com/en/products/software/adaptive-socs-and-fpgas/vivado.html) tools

### Initial Setup

1. **Install Toolchain**:
   ```bash
   xpm install
   ```
2. **Configure Vivado Path**:
   Create a `.env` file in the root directory and set `VIVADO_BIN_DIR` to your Vivado binary directory (where `vivado.bat` or `vivado` is located). For example:
   `VIVADO_BIN_DIR=C:\AMDDesignTools\2025.2\Vivado\bin`

### Building Memory Files

To compile the C programs into `.hex` files, use `python run.py build <program>`.

This will generate `imem.hex` and `dmem.hex` in the `firmware/imem_dmem/` directory.

### Running Simulations

After running the build action, use `python run.py sim` to run the simulation.

Once finished, you can find the generated waveform file `pipeline.vcd` inside the `simulation/` directory.

### FPGA Synthesis and Implementation

1. First, compile the C program you want to run on the FPGA (Eg. `python run.py build addition`)
2. Run the synthesis and implementation pipeline using `python run.py synth`

### Programming the FPGA

Once the bitstream (`fpga/build/fpga.bit`) is generated, you can program the connected board directly:

1. Ensure the board is connected via USB and turned ON
2. Run `python run.py program`
