import axi_lite_pkg::*;

module axi_lite_master (
	axi_lite_if.master m_axi_lite
);

	typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	state_type [2 : 0] state, next_state;

	logic [ADDR_WIDTH - 1 : 0] addr = 32'h0;
	logic [DATA_WIDTH - 1 : 0] data = 32'hdeadbeef;
	logic sel = 0;

	// AR
	assign m_axi_lite.araddr  = addr;
	assign m_axi_lite.arvalid = (next_state == RADDR) ? 1 : 0;

	// R
	assign m_axi_lite.rready = (next_state == RDATA) ? 1 : 0;

	// AW
	assign m_axi_lite.awvalid = (next_state == WADDR) ? 1 : 0;
	assign m_axi_lite.awaddr  = addr;

	// W
	assign m_axi_lite.wvalid = (next_state == WDATA) ? 1 : 0;
	assign m_axi_lite.wdata  = data;
	assign m_axi_lite.wstrb  = 4'b0000;

	// B
	assign m_axi_lite.bready = (state == WRESP) ? 1 : 0;


	// Select Write or Read
	// assign sel = ((state == RADDR && sel == 0) || (state == WADDR && sel == 1)) ? ~sel : sel;
	// assign sel = 0;


	always_comb begin
		case (state)
			IDLE : next_state = (sel == 0) ? WADDR : RADDR;
			RADDR : if (m_axi_lite.arvalid && m_axi_lite.arready) next_state = RDATA;
			RDATA : if (m_axi_lite.rvalid  && m_axi_lite.rready ) next_state = IDLE;
			WADDR : if (m_axi_lite.awvalid && m_axi_lite.awready) next_state = WDATA;
			WDATA : if (m_axi_lite.wvalid  && m_axi_lite.wready ) next_state = WRESP;
			WRESP : if (m_axi_lite.bvalid  && m_axi_lite.bready ) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge m_axi_lite.clk) begin
		if (m_axi_lite.rst) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_lite_master
