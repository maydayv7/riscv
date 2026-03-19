import os
import sys
import subprocess
import shutil
from pathlib import Path


def load_env():
    env_path = Path(".env")
    if env_path.exists():
        with open(env_path, "r") as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    parts = line.split("=", 1)
                    if len(parts) == 2:
                        os.environ[parts[0].strip()] = parts[1].strip()


def setup_path():
    load_env()
    # Add Vivado to PATH
    vivado_bin = os.environ.get("VIVADO_BIN_DIR")
    if vivado_bin:
        os.environ["PATH"] = f"{vivado_bin}{os.pathsep}{os.environ['PATH']}"

    # Add XPacks to PATH
    xpack_bin = Path("xpacks/.bin").absolute()
    if xpack_bin.exists():
        os.environ["PATH"] = f"{xpack_bin}{os.pathsep}{os.environ['PATH']}"


def run_cmd(cmd, cwd=None):
    print(f"==> Running: {' '.join(cmd)}")
    is_win = sys.platform == "win32"
    try:
        result = subprocess.run(cmd, cwd=cwd, shell=is_win)
        if result.returncode != 0:
            print(f"Error: Command failed with code {result.returncode}")
            sys.exit(result.returncode)
    except FileNotFoundError:
        print(
            f"Error: Command '{cmd[0]}' not found. Ensure toolchains are installed (xpm install) and PATH is correct."
        )
        sys.exit(1)


def build(program):
    print(f"--- Building {program} ---")
    cwd = Path("firmware")
    src = f"code_{program}.c"
    if not (cwd / src).exists():
        print(f"Error: Source file {src} not found in {cwd}.")
        sys.exit(1)

    run_cmd(
        [
            "riscv-none-elf-gcc",
            "-c",
            src,
            "-o",
            "code.elf",
            "-march=rv32i",
            "-mabi=ilp32",
        ],
        cwd=cwd,
    )
    run_cmd(
        ["riscv-none-elf-objcopy", "-O", "binary", "code.elf", "imem_dmem/imem.bin"],
        cwd=cwd,
    )
    run_cmd(
        [
            "riscv-none-elf-objcopy",
            "-j",
            ".data",
            "-O",
            "binary",
            "code.elf",
            "imem_dmem/dmem.bin",
        ],
        cwd=cwd,
    )

    with open(cwd / "imem_dmem" / "code.dis", "w") as f:
        print("==> Running: riscv-none-elf-objdump -d code.elf > imem_dmem/code.dis")
        is_win = sys.platform == "win32"
        subprocess.run(
            ["riscv-none-elf-objdump", "-d", "code.elf"],
            cwd=cwd,
            stdout=f,
            shell=is_win,
        )

    run_cmd([sys.executable, "bin2hex.py"], cwd=cwd / "imem_dmem")
    print("--- Build successful ---")


def sim():
    print("--- Running simulation ---")
    cwd = Path("simulation")

    # Copy hex files
    for hex_file in Path("firmware/imem_dmem").glob("*.hex"):
        shutil.copy(hex_file, cwd)

    run_cmd(["xvlog", "-i", "../modules", "-f", "filelist.txt"], cwd=cwd)
    run_cmd(
        ["xelab", "-top", "testbench", "-snapshot", "riscv_sim", "-debug", "typical"],
        cwd=cwd,
    )
    run_cmd(
        ["xsim", "riscv_sim", "-tclbatch", "simulate.tcl", "-log", "simulation.log"],
        cwd=cwd,
    )
    print("--- Simulation complete ---")


def synth():
    print("--- Running synthesis & implementation ---")
    cwd = Path("fpga/build")
    cwd.mkdir(exist_ok=True, parents=True)

    # Copy hex files
    for hex_file in Path("firmware/imem_dmem").glob("*.hex"):
        shutil.copy(hex_file, cwd)

    run_cmd(["vivado", "-mode", "batch", "-source", "../synth.tcl"], cwd=cwd)
    print("--- Synthesis complete ---")


def program_fpga():
    print("--- Programming FPGA ---")
    cwd = Path("fpga/build")
    if not (cwd / "fpga.bit").exists():
        print("Error: fpga.bit not found. Run synthesis first.")
        sys.exit(1)

    run_cmd(["vivado", "-mode", "batch", "-source", "../program.tcl"], cwd=cwd)
    print("--- Programming complete ---")


def clean():
    print("--- Cleaning project ---")
    # Clean firmware
    for f in Path("firmware").glob("code.elf"):
        f.unlink()
    for ext in ["*.bin", "*.hex", "*.dis"]:
        for f in Path("firmware/imem_dmem").glob(ext):
            f.unlink()

    # Clean simulation
    sim_dir = Path("simulation")
    for ext in ["*.log", "*.pb", "*.jou", "*.hex", "*.wdb", "*.vcd"]:
        for f in sim_dir.glob(ext):
            f.unlink()
    if (sim_dir / "xsim.dir").exists():
        shutil.rmtree(sim_dir / "xsim.dir")

    # Clean Vivado build and logs
    if Path("fpga/build").exists():
        shutil.rmtree("fpga/build")
    for f in Path(".").glob("vivado*.log"):
        f.unlink()
    for f in Path(".").glob("vivado*.jou"):
        f.unlink()
    if Path(".Xil").exists():
        shutil.rmtree(".Xil")

    print("--- Clean complete ---")


if __name__ == "__main__":
    setup_path()
    if len(sys.argv) < 2:
        print(
            "Usage: python run.py [ build <program> | sim | synth | program | clean ]"
        )
        sys.exit(1)

    cmd = sys.argv[1]
    if cmd == "build":
        if len(sys.argv) < 3:
            print("Please specify the program to build, e.g. 'addition'")
            sys.exit(1)
        build(sys.argv[2])
    elif cmd == "sim":
        sim()
    elif cmd == "synth":
        synth()
    elif cmd == "program":
        program_fpga()
    elif cmd == "clean":
        clean()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
