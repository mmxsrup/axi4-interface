import axi_stream_pkg::*;

module axi_stream_slave (
	axi_stream_if.slave s_axi_stream
);

	typedef enum logic {IDLE, RECV} state_type;
	state_type state, next_state;

	data_t buffer [0 : 7];
	logic [3 : 0] packet_len_cnt;

	assign s_axi_stream.tready = (state == RECV) ? 1 : 0;

	always_ff @(posedge s_axi_stream.aclk) begin
		if (~s_axi_stream.areset_n) begin
			packet_len_cnt <= 0;
		end else begin
			if (s_axi_stream.tvalid && s_axi_stream.tready) begin
				buffer[packet_len_cnt] <= s_axi_stream.tdata;
				packet_len_cnt <= (s_axi_stream.tlast) ? 0 : packet_len_cnt + 1;
			end
		end
	end

	always_comb begin
		case (state)
			IDLE : next_state = RECV;
			RECV : next_state = RECV;
			default : next_state = IDLE;
		endcase
	end

	always_ff @(posedge s_axi_stream.aclk) begin
		if (~s_axi_stream.areset_n) begin
			state <= IDLE;
		end else begin
			state <= next_state;
		end
	end

endmodule // axi_stream_slave
