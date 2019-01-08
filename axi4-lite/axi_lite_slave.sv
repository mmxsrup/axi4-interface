import axi_pkg::*;

module axi_lite_slave (
	axi_lite_if.slave s_axi_lite
);

	typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	state_type [2 : 0] state, next_state;

	logic [ADDR_WIDTH - 1 : 0] addr;
	logic [ADDR_WIDTH - 1 : 0] data[0 : 31];

	// AR
	assign s_axi_lite.arready = (next_state == RADDR) ? 1 : 0;

	// R
	assign s_axi_lite.rdata  = (next_state == RDATA) ? data[addr] : 0;
	assign s_axi_lite.rresp  = RESP_OKAY;
	assign s_axi_lite.rvalid = (next_state == RDATA) ? 1 : 0;

	// AW
	assign s_axi_lite.awready = (next_state == WADDR) ? 1 : 0;

	// W
	assign s_axi_lite.wready = (next_state == WDATA) ? 1 : 0;

	// B
	assign s_axi_lite.bvalid = (next_state == WRESP) ? 1 : 0;
	assign s_axi_lite.bresp  = RESP_OKAY;


	always_ff @(posedge s_axi_lite.clk) begin
		if (s_axi_lite.rst) begin
			addr <= 0;
		end else begin
			case (state)
				RADDR : addr <= s_axi_lite.araddr;
				WADDR : addr <= s_axi_lite.awaddr;
				default : addr <= 32'h0;
			endcase
		end
	end

	always_comb begin
		case (state)
			IDLE : next_state = (s_axi_lite.arvalid) ? RADDR : (s_axi_lite.awvalid) ? WADDR : IDLE;
			RADDR : if (s_axi_lite.arvalid && s_axi_lite.arready) next_state = RDATA;
			RDATA : if (s_axi_lite.rvalid  && s_axi_lite.rready ) next_state = IDLE;
			WADDR : if (s_axi_lite.awvalid && s_axi_lite.awready) next_state = WDATA;
			WDATA : if (s_axi_lite.wvalid  && s_axi_lite.wready ) next_state = WRESP;
			WRESP : if (s_axi_lite.bvalid  && s_axi_lite.bready ) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge s_axi_lite.clk) begin
		if (s_axi_lite.rst) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_lite_slave
