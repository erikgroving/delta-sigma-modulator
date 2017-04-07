sh clear
remove_design -all

set design_name BF_TOP
set SYN_ROOT "/afs/eecs.umich.edu/analog/users/boyizh/TSMC_N45GS/digital/dsm/syn"
set COMMON_ROOT "${SYN_ROOT}/../../common/"
set VERILOG_ROOT "${SYN_ROOT}/../verilog/"
set OUTPUT_ROOT "${SYN_ROOT}/output/"

#set module_list [list $design_name beamformer_core ch_unit cwm_adder cwm_output_selector cwm decimator_250M decimator_2G down_mixer down_sample_16b sampler_2G_3b sampler_2G_set]

set module_list [list $design_name SPI PHASESHIFT MIXER_IQ DSM_TOP INTERPOLATE LFSR]

# this has a list of names to avoid things:
set tsmc_name_file "${COMMON_ROOT}/namingrules.tcl"

# this is a file full of timing constraints
#set load_cons_file [format "%s%s"  "./" [format "%s%s"  $design_name ".constraints"] ]

# Clean up and create the design library 
sh rm -f -r WORK*
sh mkdir WORK
define_design_lib WORK -path ./WORK

sh rm -f -r verilog_out
sh mkdir verilog_out

# rvt
set search_path [list "/afs/eecs.umich.edu/kits/TSMC/N45GS/2014.03/N45GS_std_cell_lib_12t/digital/Front_End/timing_power_noise/CCS/tcbn45gsbwp12t_200a"]


# rvt
set target_library "tcbn45gsbwp12ttc_ccs.db"
set synthetic_library [list "dw_foundation.sldb"]
set link_library "
*
standard.sldb
$synthetic_library
$target_library
"
#tcbn45gsbwptc_ccs.db

# tell synthesis not to mess with unloaded flip-flops 
#set hdlin_preserve_sequential ff
# tell compiler tool not to delete unloaded flip-flops
#set compile_delete_unloaded_sequential_cells false
# check to make sure i did indeed change variable states
print_variable_group hdl
print_variable_group compile

#set_min_library   /afs/eecs.umich.edu/kits/ARM/TSMC_65gp/sc_rvt/aci/sc-ad10/synopsys/scadv10_cln65gp_rvt_ss_0p9v_125c.db -min_version /afs/eecs.umich.edu/kits/ARM/TSMC_65gp/sc_rvt/aci/sc-ad10/synopsys/scadv10_cln65gp_rvt_ff_1p1v_m40c.db


set my_path "${SYN_ROOT}/../verilog"

# /* Analyze and elaborate */ 
set verilog_files " \
	$my_path/bf_top.v \
	$my_path/dsm.v \
	$my_path/interp.v \
	$my_path/phaseShift.v \
	$my_path/lfsr.v \
	$my_path/mixer_iq.v \
	$my_path/spi.v \
	$my_path/parameters.vh
	
"
# read_file -autoread $verilog_files -top $top_level
analyze -format sverilog $verilog_files
elaborate $design_name

list_designs
current_design $design_name

set_fix_multiple_port_nets -feedthroughs -outputs -buffer_constants

#Source the file that sets the Search path and the libraries
#source -echo -verbose $defaults_file

# Timing setup for synthesis

# Clock period
set clk_period 		0.72
set clk_uncertainty 	0.1
set clk_transition 	0.05
set clk_latency 	0.00
set sclk_period 	6.25
set sclk_uncertainty 0.5
set sclk_transition 0.2
set sclk_latency	0.00

#set clk_port "clk"
#If no waveform is specified, 50% duty cycle is assumed
#create_clock -name clk_to_dut -period $clk_period -waveform {0 0.5} $clk_port

#set clk_name "clk_xor_phase_detector"  
#create_clock -name $clk_name -period $clk_period "xor_1/Y"
#create_generated_clock -name $clk_name -source [get_ports $clk_port] -divide_by 1 [get_pins xor_1/Y] "xor_1/Y"

# GENERATE CLOCK
set clk_port "CLOCK"
set clk_name "CLOCK"
set sclk_port "SCLK"
set sclk_name "SCLK"

set typical_input_delay [expr 0.1 * $clk_period]
#set typical_output_delay [expr 0.25 * $clk_period]

create_clock -name $clk_name -period $clk_period [get_ports $clk_port]
create_clock -name $sclk_name -period $sclk_period [get_ports $sclk_port]

#create_generated_clock –divide_by 8 –source [get_ports {clock}]  [get_pins {bf_top:ps_clock/Q}]

create_generated_clock -name ps_clock -source [get_ports $clk_port] -divide_by 8 [get_pins ps_clock_reg/Q]

set_clock_latency $clk_latency [get_clocks $clk_name]
set_clock_transition $clk_transition [get_clocks $clk_name]
set_clock_uncertainty $clk_uncertainty [get_clocks $clk_name]
set_clock_latency $sclk_latency [get_clocks $sclk_name]
set_clock_transition $sclk_transition [get_clocks $sclk_name]
set_clock_uncertainty $sclk_uncertainty [get_clocks $sclk_name]

set_optimize_registers true
#set_balance_registers true

# Set delays: Input, Output
#set_input_delay $typical_input_delay [get_ports IN*] -clock $clk_name 

##########!!!
set_input_delay $typical_input_delay [get_ports VIN*] -clock $clk_name
set_input_delay $typical_input_delay [get_ports MOSI*] -clock $clk_name



#set_output_delay $typical_output_delay [all_outputs] -clock $clk_name 
remove_input_delay -clock $clk_name [get_ports $clk_port]
remove_input_delay -clock $sclk_name [get_ports $sclk_port]


#source -echo -verbose $load_cons_file
source -echo -verbose  $tsmc_name_file

# FANOUT & TRANSITION CONSTRAINTS
#set_max_fanout	10		$design_name

#set_clock_latency 0.06 [get_clocks DIV_4_CLK]
#set_clock_transition 0.06 [get_clocks DIV_4_CLK]
#set_clock_uncertainty 0.06 [get_clocks DIV_4_CLK]

#set some variables to give nice synthesized verilog
set verilogout_no_tri true
set verilogout_equation false
set_fix_multiple_port_nets -all

#define output files
set netlist_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".vg"]
set db_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".db"]
set rep_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".rep"]
set spef_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".spef"]
set sdc_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".sdc"]
set sdf_file [format "%s%s"  [format "%s%s"  "./verilog_out/" $design_name] ".sdf"]

#set_operating_conditions -max ss_0p9v_125c  -min ff_1p1v_m40c
set_fix_hold [all_clocks]

# check design before compile
check_design

# Uniquify repeated modules
uniquify

# compile
#set_flatten true
#set_structure true
compile_ultra -no_autoungroup -no_boundary_optimization
#compile_ultra

change_names -rule verilog -verbose -hierarchy

# check design after compile
check_design

#Writing out verilog netlist, db files and sdf files
write -hier -format verilog -output $netlist_file
##write -xg_force_db -hier -format db -output $db_file
write_sdf -version 2.1 $sdf_file

#Generating the design reports for record purposes
redirect $rep_file { report_design -nosplit }
redirect -append $rep_file { report_clock }
redirect -append $rep_file { report_area }
redirect -append $rep_file { report_power }
redirect -append $rep_file { get_attribute [all_clocks] capacitance }
redirect -append $rep_file { report_net_fanout -threshold 50}
redirect -append $rep_file { report_constraint -all_violators -verbose -nosplit }
redirect -append $rep_file { report_timing -max_paths 20 -input_pins -nets -transition_time -capacitance -nosplit }

##Add the Report timing part
#redirect -append $rep_file { report_timing -loops -max_paths 500 }
redirect -append $rep_file { report_timing -path end -delay max -max_paths 20 -nworst 2 }
redirect -append $rep_file { report_reference }


#copied from wiki.eecs from joshua, spef is used for primepower
write_sdc $sdc_file -version "1.5"
write_parasitics -output $spef_file

#report_timing_requirements -ignored > simple.ignored.constraints.report
#report_constraint -all_violators  -verbose > simple.constraints.report

#  current_design MASTER_DIGITAL

#} else {
#   sh echo 'Analyze Error at end:' $file_name
#  quit
#}


exit
#report_path_group
#report_timing -group output_grp
#report_timing -group input_grp

#report_timing_requirements -ignored > ENCODER.ignored.constraints.report
#report_timing_requirements -ignored

#report_constraint -all_violators  -verbose > ENCODER.constraints.report
#report_constraint -verbose

#report_port -type slew_limit
#get_attribute find(pin,compBankScanReg/SCAN_REG_31/SCAN_REG/clk) max_transition
#get_attribute find(pin,compBankScanReg/SCAN_REG_31/SCAN_REG/Q_reg/CP) max_transition

#get_cells -hier filter(find(cells,"*"),"@is_black_box==true")
#get_find(cell,compBankScanReg/SCAN_REG_31/SCAN_REG/Q_reg)

#report_lib CORE90GPLVT
#set_prefer CORE90GPLVT/FA1LVTX1
#alib_analyze_libs



#report_lib -timing_arcs
#report_design
