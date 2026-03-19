create_project -in_memory -part xc7a100tcsg324-1
set_property include_dirs {../../modules} [current_fileset]

read_verilog ../../modules/pipeline.v
read_verilog ../fpga.v
read_xdc ../constraints.xdc

# Run Synthesis
synth_design -top fpga -part xc7a100tcsg324-1

# Run Implementation
opt_design
place_design
route_design

# Generate utilization and timing reports
report_utilization -file top_fpga_utilization_impl.rpt
report_timing_summary -file top_fpga_timing_impl.rpt

# Generate Bitstream
write_bitstream -force fpga.bit
