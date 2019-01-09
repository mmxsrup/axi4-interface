package axi_lite_pkg;

	localparam ADDR_WIDTH = 32;
	localparam DATA_WIDTH = 32;
	localparam STRB_WIDTH = DATA_WIDTH / 8;

	localparam RESP_OKAY   = 2'b00;
	localparam RESP_EXOKAY = 2'b01;
	localparam RESP_SLVERR = 2'b10;
	localparam RESP_DECERR = 2'b11;

	typedef logic [ADDR_WIDTH - 1 : 0] addr_t;
	typedef logic [DATA_WIDTH - 1 : 0] data_t;
	typedef logic [STRB_WIDTH - 1 : 0] strb_t;
	typedef logic [1 : 0] resp_t;

endpackage
