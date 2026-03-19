open_hw_manager
connect_hw_server
open_hw_target

# Get first connected FPGA
set device [lindex [get_hw_devices] 0]
current_hw_device $device
refresh_hw_device -update_hw_probes false $device

# Set bitstream file and program
set_property PROGRAM.FILE "fpga.bit" $device
program_hw_devices $device

close_hw_manager
