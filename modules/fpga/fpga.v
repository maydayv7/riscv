// Nexys A7 - xc7a100tcsg324-1

`timescale 1ns / 1ps

module fpga #(
    parameter IMEMSIZE = 4096,
    parameter DMEMSIZE = 4096
) (
    input wire clk,
    input wire reset,  // Active-High Reset
    output [15:0] led
);

  wire [31:0] current_pc;
  wire [15:0] pc_disp = current_pc[15:0];

  wire        exception;

  ////////////////////////////////////////////////////////////
  // Clock divider
  ////////////////////////////////////////////////////////////
  parameter DIVISOR = 100_000_000;
  reg [26:0] clk_cnt;
  reg        slow_clk;

  always @(posedge clk) begin
    if (reset) begin
      clk_cnt  <= 0;
      slow_clk <= 1'b0;
    end else if (clk_cnt == DIVISOR - 1) begin
      clk_cnt  <= 0;
      slow_clk <= ~slow_clk;
    end else begin
      clk_cnt <= clk_cnt + 1;
    end
  end

  ////////////////////////////////////////////////////////////
  // Pipe <-> Memory Wires
  ////////////////////////////////////////////////////////////
  wire        inst_mem_is_ready;
  wire        inst_mem_is_valid;
  wire [31:0] inst_mem_address;
  wire [31:0] inst_mem_read_data;

  wire        dmem_read_ready;
  wire        dmem_read_valid;
  wire        dmem_write_ready;
  wire        dmem_write_valid;
  wire [ 3:0] dmem_write_byte;
  wire [31:0] dmem_read_address;
  wire [31:0] dmem_read_data;
  wire [31:0] dmem_write_address;
  wire [31:0] dmem_write_data;

  assign inst_mem_is_valid = 1'b1;
  assign dmem_write_valid = 1'b1;
  assign dmem_read_valid = 1'b1;
  assign led = pc_disp;

  ////////////////////////////////////////////////////////////
  // Pipeline CPU
  ////////////////////////////////////////////////////////////
  pipe pipe_u (
      .clk(slow_clk),
      .reset(~reset),
      .stall(1'b0),
      .exception(exception),
      .pc_out(current_pc),

      .inst_mem_address  (inst_mem_address),
      .inst_mem_is_valid (inst_mem_is_valid),
      .inst_mem_read_data(inst_mem_read_data),
      .inst_mem_is_ready (inst_mem_is_ready),

      .dmem_read_address(dmem_read_address),
      .dmem_read_ready(dmem_read_ready),
      .dmem_read_data_temp(dmem_read_data),
      .dmem_read_valid(dmem_read_valid),
      .dmem_write_address(dmem_write_address),
      .dmem_write_ready(dmem_write_ready),
      .dmem_write_data(dmem_write_data),
      .dmem_write_byte(dmem_write_byte),
      .dmem_write_valid(dmem_write_valid)
  );

  ////////////////////////////////////////////////////////////
  // Instruction Memory
  ////////////////////////////////////////////////////////////
  instr_mem IMEM (
      .clk(slow_clk),
      .pc(inst_mem_address),
      .instr(inst_mem_read_data)
  );

  ////////////////////////////////////////////////////////////
  // Data Memory
  ////////////////////////////////////////////////////////////
  data_mem DMEM (
      .clk(slow_clk),

      .re(dmem_read_ready),
      .raddr(dmem_read_address),
      .rdata(dmem_read_data),

      .we(dmem_write_ready),
      .waddr(dmem_write_address),
      .wdata(dmem_write_data),
      .wstrb(dmem_write_byte)
  );

endmodule
