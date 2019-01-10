import axi_lite_pkg::*;

interface axi_lite_if;

	// Read Address Channel
	addr_t araddr;
	logic arvalid;
	logic arready;

	// Read Data Channel
	data_t rdata;
	resp_t rresp;
	logic rvalid;
	logic rready;

	// Write Address Channel
	addr_t awaddr;
	logic awvalid;
	logic awready;

	// Write Data Channel
	data_t wdata;
	strb_t wstrb;
	logic wvalid;
	logic wready;

	// Write Response Channel
	resp_t bresp;
	logic bvalid;
	logic bready;

	modport master (
		output araddr, arvalid, input arready,
		input rdata, rresp, rvalid, output rready,
		output awaddr, awvalid, input awready,
		output 	wdata, wstrb, wvalid, input wready,
		input bresp, bvalid, output bready
	);

	modport slave (
		input araddr, arvalid, output arready,
		output rdata, rresp, rvalid, input rready,
		input awaddr, awvalid, output awready,
		input wdata, wstrb, wvalid, output wready,
		output bresp, bvalid, input bready
	);

endinterface
