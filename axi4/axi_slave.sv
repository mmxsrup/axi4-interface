import axi_pkg::*;

module axi_slave (
	input aclk,
	input areset_n,
	axi_if.slave s_axi
);

	typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
	state_type state, next_state;

	addr_t addr;
	len_t len;
	size_t size;
	burst_t burst;
	data_t data;

	size_t len_cnt;
	data_t buffer[0 : 7];

	// AR
	assign s_axi.arready = (state == RADDR) ? 1 : 0;

	// R
	assign s_axi.rdata  = (state == RDATA) ? buffer[addr + len_cnt] : 0;
	assign s_axi.rresp  = RESP_OKAY;
	assign s_axi.rvalid = (state == RDATA) ? 1 : 0;
	assign s_axi.rlast  = (state == RDATA && len_cnt == len && s_axi.rvalid  && s_axi.rready) ? 1 : 0;

	// AW
	assign s_axi.awready = (state == WADDR) ? 1 : 0;

	// W
	assign s_axi.wready = (state == WDATA) ? 1 : 0;

	// B
	assign s_axi.bvalid = (state == WRESP) ? 1 : 0;
	assign s_axi.bresp  = RESP_OKAY;


	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			addr  <= 0;
			len   <= 0;
			size  <= 0;
			burst <= 0;
		end else begin
			case (state)
				RADDR : begin
					addr  <= s_axi.araddr;
					len   <= s_axi.arlen;
					size  <= s_axi.arsize;
					burst <= s_axi.arburst;
				end
				WADDR : begin
					addr  <= s_axi.awaddr;
					len   <= s_axi.awlen;
					size  <= s_axi.awsize;
					burst <= s_axi.awburst;
				end
			endcase
		end
	end

	always_ff @(posedge aclk) begin
		if(~areset_n) begin
			len_cnt <= 0;
			for (int i = 0; i < 8; i++) begin
				buffer[i] <= 32'h0;
			end
		end else begin
			case (state)
				RDATA : begin
					if (s_axi.rvalid && s_axi.rready) begin
						len_cnt <= len_cnt + 1;		
					end
				end
				WDATA : begin
					if (s_axi.wvalid && s_axi.wready) begin
						if (burst == BURST_INCR) buffer[addr + len_cnt] <= s_axi.wdata;
						else buffer[addr] <= s_axi.wdata;
						len_cnt <= len_cnt + 1;
					end
				end
				default : len_cnt <= 0;
			endcase
		end
	end

	always_comb begin
		case (state)
			IDLE : next_state = (s_axi.arvalid) ? RADDR : (s_axi.awvalid) ? WADDR : IDLE;
			RADDR : if (s_axi.arvalid && s_axi.arready) next_state = RDATA;
			RDATA : if (s_axi.rvalid  && s_axi.rready && len == len_cnt) next_state = IDLE;
			WADDR : if (s_axi.awvalid && s_axi.awready) next_state = WDATA;
			WDATA : if (s_axi.wvalid  && s_axi.wready && s_axi.wlast) next_state = WRESP;
			WRESP : if (s_axi.bvalid  && s_axi.bready ) next_state = IDLE;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_slave






