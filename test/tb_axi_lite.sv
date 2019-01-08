`timescale 1ns / 1ps

module tb_axi_lite;

	localparam STEP = 10;
	
	axi_lite_if axi_lite_if();
	axi_lite_master master(.m_axi_lite(axi_lite_if));
	axi_lite_slave  slave (.s_axi_lite(axi_lite_if));

	always begin
		axi_lite_if.clk = 1; #(STEP / 2);
		axi_lite_if.clk = 0; #(STEP / 2);
	end

	initial begin
		axi_lite_if.rst = 0;
		#(STEP * 10) axi_lite_if.rst = 1;
		#(STEP * 10) axi_lite_if.rst = 0;

		#(STEP * 100);
	end

endmodule
