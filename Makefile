vivado = vivado

create_project: ./scripts/create_project.tcl
	vivado -source ./scripts/create_project.tcl
	
clean: 
	rm -rf vivado* build
