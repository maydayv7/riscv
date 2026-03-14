# Cross Compiler
CC      = riscv-none-elf-gcc
AR      = riscv-none-elf-ar
OBJDUMP = riscv-none-elf-objdump
OBJCOPY = riscv-none-elf-objcopy
READELF = riscv-none-elf-readelf


# Flags for RV32i architecture
CFLAGS  = -march=rv32i -mabi=ilp32


# Sources
SRC_ADDITION = code_addition.c
SRC_SORT     = code_sort.c
SRC_NEGATIVE = code_negative.c

TARGET = code.elf


.PHONY: clean

# 1. Generating .text file of code cross-compiled from high-level C to RISC-V
# 2. Copying and converting the text file into binary files
# 3. Python script to convert the binary files into the required hex files

%: code_%.c
	$(CC) -c $< -o $(TARGET) $(CFLAGS)
	$(OBJCOPY) -O binary $(TARGET) ./imem_dmem/imem.bin
	$(OBJCOPY) -j .data -O binary $(TARGET) ./imem_dmem/dmem.bin
	$(OBJDUMP) -d $(TARGET) > ./imem_dmem/code.dis
	cd imem_dmem && python bin2hex.py


clean:
	del /Q /F $(TARGET) imem_dmem\imem.bin imem_dmem\mem.hex imem_dmem\dmem.bin imem_dmem\dmem.hex imem_dmem\code.dis
