`timescale 1ns / 1ps

////////////////////////////////////////////////////////////
// Testbench
////////////////////////////////////////////////////////////

module testbench;

  reg clk;
  reg reset;

  // 100 MHz clock
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Active low CPU Reset
  initial begin
    reset = 0;
    #100;
    reset = 1;
  end

  // Pipe <-> Memory Signals
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

  wire [31:0] pc_out;

  assign inst_mem_is_valid = 1'b1;
  assign dmem_write_valid  = 1'b1;
  assign dmem_read_valid   = 1'b1;

  wire exception;

  // DUT - Pipelined CPU
  pipe DUT (
      .clk(clk),
      .reset(reset),
      .stall(1'b0),
      .exception(exception),
      .pc_out(pc_out),

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


  // Instruction Memory
  instr_mem IMEM (
      .clk(clk),
      .pc(inst_mem_address),
      .instr(inst_mem_read_data)
  );


  // Data Memory
  data_mem DMEM (
      .clk(clk),

      .re(dmem_read_ready),
      .raddr(dmem_read_address),
      .rdata(dmem_read_data),

      .we(dmem_write_ready),
      .waddr(dmem_write_address),
      .wdata(dmem_write_data),
      .wstrb(dmem_write_byte)
  );


  // Simulation
  initial begin
    $dumpfile("pipeline.vcd");
    $dumpvars(0, testbench);
    #20000;  // Run long enough to see program execute
    $finish;
  end

  // Track clock cycles and mute switch
  integer cycle = 0;

  always @(posedge clk) begin
    if (reset) cycle <= cycle + 1;
  end

  // Print comprehensive pipeline status on negative edge
  always @(negedge clk) begin
    if (reset) begin 
      // 1. Timing Info
      $write("Time: %6t | Cyc: %3d | ", $time, cycle);

      // 2. Stage 1: IF/ID
      $write("IF: fetch_pc=%h Inst=%h | ", DUT.fetch_pc, DUT.instruction);

      // 3. Stage 2: EX
      $write("EX: PC=%h next_pc=%h ", DUT.execute.pc, DUT.next_pc);
      
      // Flag if a branch is actively taken this cycle
      if (DUT.branch_taken) begin
        $write("[TAKEN] "); 
      end else begin
        $write("        "); 
      end
      $write("| ");

      // 4. Stage 3: WB 
      $write("WB: ");
      if (DUT.wb_alu_to_reg && DUT.wb_dest_reg_sel != 0) begin
        $write("Reg[x%0d]=%0d ", DUT.wb_dest_reg_sel, $signed(DUT.wb_result));
      end else begin
        $write("             "); 
      end

      if (DUT.wb_mem_write) begin
        $write("Mem[%h]=%0d ", DUT.dmem_write_address, $signed(DUT.dmem_write_data));
      end

      // 5. Pipeline Status
      if (DUT.stall_read) begin
        $write(" *[STALL]*");
      end

      $display(""); 
    end
  end

  // Finish condition
  always @(posedge clk) begin
    if (inst_mem_read_data == 32'h00008067) begin // ret instruction
      #20; // Hardware finish
      $finish;
    end
  end

endmodule
