import axi_pkg::*;

module axi_master (
	axi_if.master m_axi,
	input logic start_read,
	input logic start_write
);

	typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	state_type state, next_state;

	localparam LEN = 4;

	addr_t addr = 32'h4;
	data_t data = 32'hdeadbeef;
	len_t len_cnt;
	data_t rdata [0 : 7];
	logic [2 : 0] rdata_cnt;
	logic start_read_delay, start_write_delay;

	
	// AR
	assign m_axi.araddr  = (state == RADDR) ? addr : 32'h0;
	assign m_axi.arvalid = (state == RADDR) ? 1 : 0;
	assign m_axi.arlen = LEN - 1;
	assign m_axi.arsize = SIZE_4_BYTE;
	assign m_axi.arburst = BURST_INCR;

	// R
	assign m_axi.rready = (state == RDATA) ? 1 : 0;

	// AW
	assign m_axi.awaddr  = (state == WADDR) ? addr : 32'h0;
	assign m_axi.awvalid = (state == WADDR) ? 1 : 0;
	assign m_axi.awlen = LEN - 1;
	assign m_axi.awsize = SIZE_4_BYTE;
	assign m_axi.awburst = BURST_INCR;

	// W
	assign m_axi.wdata  = (state == WDATA) ? data + len_cnt : 32'h0;
	assign m_axi.wstrb  = 4'b1111;
	assign m_axi.wvalid = (state == WDATA) ? 1 : 0;
	assign m_axi.wlast = (state == WDATA && len_cnt == LEN) ? 1 : 0;

	// B
	assign m_axi.bready = (state == WRESP) ? 1 : 0;

	always_ff @(posedge m_axi.aclk) begin
		if (~m_axi.areset_n) begin
			for (int i = 0; i < 8; i++) begin
				rdata[i] <= 32'h0;
			end
			rdata_cnt <= 0;
			len_cnt <= 0;
		end else begin
			if (state == RDATA && m_axi.rvalid  && m_axi.rready) begin
				rdata[addr + rdata_cnt] <= m_axi.rdata;
				rdata_cnt <= rdata_cnt + 1;
			end
			if (state == WDATA && m_axi.wvalid  && m_axi.wready) len_cnt <= len_cnt + 1;
		end
	end

	always_ff @(posedge m_axi.aclk) begin
		if (~m_axi.areset_n) begin
			start_read_delay  <= 0;
			start_write_delay <= 0;
		end else begin
			start_read_delay  <= start_read;
			start_write_delay <= start_write;
		end
	end

	always_comb begin
		case (state)
			IDLE : next_state = (start_read_delay) ? RADDR : ((start_write_delay) ? WADDR : IDLE);
			RADDR : if (m_axi.arvalid && m_axi.arready) next_state = RDATA;
			RDATA : if (m_axi.rvalid  && m_axi.rready && m_axi.rlast) next_state = IDLE;
			WADDR : if (m_axi.awvalid && m_axi.awready) next_state = WDATA;
			WDATA : if (m_axi.wvalid  && m_axi.wready && m_axi.wlast) next_state = WRESP;
			WRESP : if (m_axi.bvalid  && m_axi.bready) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge m_axi.aclk) begin
		if (~m_axi.areset_n) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_lite_master
