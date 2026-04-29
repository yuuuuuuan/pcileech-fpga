#
# RUN FROM WITHIN "Vivado Tcl Shell" WITH COMMAND:
# source vivado_build.tcl -notrace
#
puts "-------------------------------------------------------"
puts " STARTING SYNTHESIS STEP.                              "
puts "-------------------------------------------------------"
launch_runs -jobs 4 synth_1
puts "-------------------------------------------------------"
puts " WAITING FOR SYNTHESIS STEP TO FINISH ...              "
puts " THIS IS LIKELY TO TAKE A VERY LONG TIME.              "
puts "-------------------------------------------------------"
wait_on_run synth_1
puts "-------------------------------------------------------"
puts " STARTING IMPLEMENTATION STEP.                         "
puts "-------------------------------------------------------"
# Workaround: Vivado PCIe 7x IP core (v3.3) bug - when Class Code is 040300
# (Multimedia/Audio), opt_design incorrectly trims the LUT1 input pin I0 of
# pcie_block_i_i_1, raising a false Opt 31-67 ERROR. The LUT is internal to
# the PCIe hard block wrapper and its trimming does not affect functionality.
set_msg_config -id {Opt 31-67} -new_severity WARNING
launch_runs -jobs 4 impl_1 -to_step write_bitstream
puts "-------------------------------------------------------"
puts " WAITING FOR IMPLEMENTATION STEP TO FINISH ...         "
puts " THIS IS LIKELY TO TAKE A VERY LONG TIME.              "
puts "-------------------------------------------------------"
wait_on_run impl_1
file copy -force ./pcileech_75t484_x1_soundcard/pcileech_75t484_x1_soundcard.runs/impl_1/pcileech_75t484_x1_top.bin pcileech_75t484_x1_soundcard.bin
puts "-------------------------------------------------------"
puts " BUILD HOPEFULLY COMPLETED.                            "
puts "-------------------------------------------------------"
