import axi_stream_pkg::*;

interface axi_stream_if;

	logic aclk;
	logic areset_n;

	logic tvalid;
	logic tready;
	logic tlast;
	data_t tdata;


	modport master (
		input aclk, areset_n,
		input tvalid, output tready, input tlast, tdata
	);

	modport slave (
		output aclk, areset_n,
		output tvalid, input tready, output tlast, tdata
	);

endinterface
