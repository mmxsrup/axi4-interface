import axi_stream_pkg::*;

interface axi_stream_if;

	logic tvalid;
	logic tready;
	logic tlast;
	data_t tdata;


	modport master (
		input tvalid, output tready, input tlast, tdata
	);

	modport slave (
		output tvalid, input tready, output tlast, tdata
	);

endinterface
