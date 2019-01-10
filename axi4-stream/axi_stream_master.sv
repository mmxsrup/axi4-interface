import axi_stream_pkg::*;

module axi_stream_master (
	input aclk,
	input areset_n,
	axi_stream_if.master m_axi_stream,
	input logic start
);

	localparam PACKET_LEN = 8;

	typedef enum logic {IDLE, SEND} state_type;
	state_type state, next_state;

	data_t data = 32'hdeadbeef;
	logic start_delay;
	logic [3 : 0] packet_len_cnt;

	assign m_axi_stream.tvalid = (state == SEND) ? 1 : 0;
	assign m_axi_stream.tlast  = (state == SEND && packet_len_cnt == PACKET_LEN) ? 1 : 0;
	assign m_axi_stream.tdata  = (state == SEND) ? data + packet_len_cnt : 32'h0;

	always_ff @(posedge aclk) begin
		if(~areset_n) begin
			start_delay <= 0;
		end else begin
			start_delay <= start;
		end
	end

	always_ff @(posedge aclk) begin
		if (~areset_n) begin
			packet_len_cnt <= 0;
		end else begin
			if (m_axi_stream.tvalid && m_axi_stream.tready) packet_len_cnt <= packet_len_cnt + 1;
		end
	end

	always_comb begin
		case (state)
			IDLE : if (start_delay) next_state = SEND;
			SEND : if (m_axi_stream.tlast) next_state = IDLE;
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

endmodule // axi_stream_master
