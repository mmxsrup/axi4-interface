`timescale 1ns / 1ps

import axi_stream_pkg::*;

module tb_axi_stream;

	localparam STEP = 10;

	logic aclk, areset_n;	
	axi_stream_if axi_stream_if();
	logic start;

	axi_stream_master master(
		.aclk(aclk), .areset_n(areset_n),
		.m_axi_stream(axi_stream_if), .start(start)
	);

	axi_stream_slave slave(
		.aclk(aclk), .areset_n(areset_n),
		.s_axi_stream(axi_stream_if)
	);

	always begin
		aclk = 1; #(STEP / 2);
		aclk = 0; #(STEP / 2);
	end

	initial begin
		start = 0;
		areset_n = 1;
		#(STEP * 10) areset_n = 0;
		#(STEP * 10) areset_n = 1;
		#(STEP * 10) start = 1; #(STEP) start = 0;
		#(STEP * 100);

		test();

		$finish;
	end


	data_t data = 32'hdeadbeef;
	int flag = 1;
	
	task test;
		for (int i = 0; i < 8; i++) begin
			$display("%d: actual:%h expected:%h\n", i, slave.buffer[i], data + i);
			if (slave.buffer[i] != data + i) flag = 0;
		end
		if (flag) $display("Pass");
		else $display("Fail");
	endtask : test

endmodule
