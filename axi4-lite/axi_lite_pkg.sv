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


	// Read Address Channel
	typedef struct packed {
		addr_t addr;
		logic valid;
		logic ready;
	} ar_chan_t;

	// Read Data Channel
	typedef struct packed {
		data_t data;
		resp_t resp;
		logic valid;
		logic ready;
	} r_chan_t;

	// Write Address Channel
	typedef struct packed {
		addr_t addr;
		logic valid;
		logic ready;
	} aw_chan_t;

	// Write Data Channel
	typedef struct packed {
		data_t data;
		strb_t strb;
		logic valid;
		logic ready;
	} w_chan_t;

	// Write Response Channel
	typedef struct packed {
		resp_t resp;
		logic valid;
		logic ready;
	} b_chan_t;


	typedef struct packed {
		ar_chan_t ar;
		r_chan_t r;
		aw_chan_t aw;
		w_chan_t w;
		b_chan_t b;
	} axi_lite_bus_t;


endpackage
