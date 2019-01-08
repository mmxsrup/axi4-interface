#
# create_project.tcl  Tcl script for creating project
#
# set     project_directory   [file dirname [info script]]
set     project_directory  "./build"
set     project_name        "project"
set board_part [get_board_parts -quiet -latest_file_version "*zc706*"]

#
# Create project
#
create_project -force $project_name $project_directory

#
# Set project properties
#
if {[info exists board_part ] && [string equal $board_part  "" ] == 0} {
    set_property "board_part"     $board_part      [current_project]
} elseif {[info exists device_part] && [string equal $device_part "" ] == 0} {
    set_property "part"           $device_part     [current_project]
} else {
    puts "ERROR: Please set board_part or device_part."
    return 1
}

#
# Add souce file
#
add_file ./axi4-lite/axi_lite_pkg.sv
add_file ./axi4-lite/axi_lite_if.sv
add_file ./axi4-lite/axi_lite_master.sv
add_file ./axi4-lite/axi_lite_slave.sv
add_file ./test/tb_axi_lite.sv

# close_project
