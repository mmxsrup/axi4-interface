module axi_lite_interconnect #(
	parameter int NUM_MASTER = 2,
	parameter int NUM_SLAVE  = 2,
	parameter int LOW_ADDR_TABLE[2] = '{32'h0, 32'h10},
	parameter int HIGH_ADDR_TABLE[2] = '{32'h10, 32'h20}
)(
	input aclk,
	input areset_n,
	axi_lite_if.master axim[0 : NUM_MASTER - 1],
	axi_lite_if.slave axis[0 : NUM_SLAVE - 1]
);

	typedef enum logic [1 : 0] {IDLE, READ, WRITE} state_type;
	state_type state, next_state;

	logic [$clog2(NUM_MASTER) - 1 : 0] sel_m;
	logic [$clog2(NUM_SLAVE)  - 1 : 0] sel_s;
	logic start_r, start_w;

	axi_lite_bus_t axibus_m[NUM_MASTER];
	axi_lite_bus_t axibus_s[NUM_SLAVE];
	axi_lite_bus_t tmp;

	for (genvar i = 0; i < NUM_MASTER; i++) begin
		assign axibus_m[i].ar.addr = axim[i].araddr;
		assign axibus_m[i].ar.valid = axim[i].arvalid;
		assign axim[i].arready = axibus_m[i].ar.ready;
		assign axim[i].rdata = axibus_m[i].r.data;
		assign axim[i].rresp = axibus_m[i].r.resp;
		assign axim[i].rvalid = axibus_m[i].r.valid;
		assign axibus_m[i].r.ready = axim[i].rready;
		assign axibus_m[i].aw.addr = axim[i].awaddr;
		assign axibus_m[i].aw.valid = axim[i].awvalid;
		assign axim[i].awready = axibus_m[i].aw.ready;
		assign axibus_m[i].w.data = axim[i].wdata;
		assign axibus_m[i].w.strb = axim[i].wstrb;
		assign axibus_m[i].w.valid = axim[i].wvalid;
		assign axim[i].wready = axibus_m[i].w.ready;
		assign axim[i].bresp = axibus_m[i].b.resp;
		assign axim[i].bvalid = axibus_m[i].b.valid;
		assign axibus_m[i].b.ready = axim[i].bready;
	end

	for (genvar i = 0; i < NUM_SLAVE; i++) begin
		assign axis[i].araddr = axibus_s[i].ar.addr;
		assign axis[i].arvalid = axibus_s[i].ar.valid;
		assign axibus_s[i].ar.ready = axis[i].arready;
		assign axibus_s[i].r.data = axis[i].rdata;
		assign axibus_s[i].r.resp = axis[i].rresp;
		assign axibus_s[i].r.valid = axis[i].rvalid;
		assign axis[i].rready = axibus_s[i].r.ready;
		assign axis[i].awaddr = axibus_s[i].aw.addr;
		assign axis[i].awvalid = axibus_s[i].aw.valid;
		assign axibus_s[i].aw.ready = axis[i].awready;
		assign axis[i].wdata = axibus_s[i].w.data;
		assign axis[i].wstrb = axibus_s[i].w.strb;
		assign axis[i].wvalid = axibus_s[i].w.valid;
		assign axibus_s[i].w.ready = axis[i].wready;
		assign axibus_s[i].b.resp = axis[i].bresp;
		assign axibus_s[i].b.valid = axis[i].bvalid;
		assign axis[i].bready = axibus_s[i].b.ready;
	end

	always_comb begin
		if (state == IDLE) begin
			if (axibus_m[0].ar.valid) begin 
				sel_m = 0; start_r = 1; start_w = 0;
			end else if (axibus_m[1].ar.valid) begin
				sel_m = 1; start_r = 1; start_w = 0;
			end else if (axibus_m[0].aw.valid) begin
				sel_m = 0; start_w = 1; start_r = 0;
			end else if (axibus_m[1].aw.valid) begin
				sel_m = 1; start_w = 1; start_r = 0;
			end else begin
				sel_m = 0; start_r = 0; start_w = 0;
			end
		end
	end	

	always_comb begin
		if (state == IDLE) begin
			if (start_r) begin
				if (LOW_ADDR_TABLE[0] <= axibus_m[sel_m].ar.addr && axibus_m[sel_m].ar.addr < HIGH_ADDR_TABLE[0]) 
					sel_s <= 0;
				else if (LOW_ADDR_TABLE[1] <= axibus_m[sel_m].ar.addr && axibus_m[sel_m].ar.addr < HIGH_ADDR_TABLE[1])
					sel_s <= 1;
				else 
					sel_s <= 0;
			end else if (start_w) begin
				if (LOW_ADDR_TABLE[0] <= axibus_m[sel_m].aw.addr && axibus_m[sel_m].aw.addr < HIGH_ADDR_TABLE[0]) 
					sel_s <= 0;
				else if (LOW_ADDR_TABLE[1] <= axibus_m[sel_m].aw.addr && axibus_m[sel_m].aw.addr < HIGH_ADDR_TABLE[1])
					sel_s <= 1;
				else 
					sel_s <= 0;
			end else begin
				sel_s <= 0;
			end
		end
	end

	// Arbitor
	assign tmp.ar.addr  = (sel_m == 0) ? axibus_m[0].ar.addr : axibus_m[1].ar.addr;
	assign tmp.ar.valid = (sel_m == 0) ? axibus_m[0].ar.valid : axibus_m[1].ar.valid ;
	assign tmp.r.ready  = (sel_m == 0) ? axibus_m[0].r.ready : axibus_m[1].r.ready;
	assign tmp.aw.addr  = (sel_m == 0) ? axibus_m[0].aw.addr : axibus_m[1].aw.addr;
	assign tmp.aw.valid = (sel_m == 0) ? axibus_m[0].aw.valid : axibus_m[1].aw.valid;
	assign tmp.w.data   = (sel_m == 0) ? axibus_m[0].w.data : axibus_m[1].w.data;
	assign tmp.w.strb   = (sel_m == 0) ? axibus_m[0].w.strb : axibus_m[1].w.strb;
	assign tmp.w.valid  = (sel_m == 0) ? axibus_m[0].w.valid : axibus_m[1].w.valid;
	assign tmp.b.ready  = (sel_m == 0) ? axibus_m[0].b.ready : axibus_m[1].b.ready;

	// Router
	for (genvar i = 0; i < NUM_SLAVE; i++) begin
		assign axibus_s[i].ar.addr  = (i == sel_s) ? tmp.ar.addr : 0;
		assign axibus_s[i].ar.valid = (i == sel_s) ? tmp.ar.valid : 0;
		assign axibus_s[i].r.ready  = (i == sel_s) ? tmp.r.ready : 0;
		assign axibus_s[i].aw.addr  = (i == sel_s) ? tmp.aw.addr : 0;
		assign axibus_s[i].aw.valid = (i == sel_s) ? tmp.aw.valid : 0;
		assign axibus_s[i].w.data   = (i == sel_s) ? tmp.w.data : 0;
		assign axibus_s[i].w.strb   = (i == sel_s) ? tmp.w.strb : 0;
		assign axibus_s[i].w.valid  = (i == sel_s) ? tmp.w.valid : 0;
		assign axibus_s[i].b.ready  = (i == sel_s) ? tmp.b.ready : 0;
	end

	// Arbitor
	assign tmp.ar.ready = (sel_s == 0) ? axibus_s[0].ar.ready : axibus_s[1].ar.ready;
	assign tmp.r.data   = (sel_s == 0) ? axibus_s[0].r.data : axibus_s[1].r.data;
	assign tmp.r.resp   = (sel_s == 0) ? axibus_s[0].r.resp : axibus_s[1].r.resp;
	assign tmp.r.valid  = (sel_s == 0) ? axibus_s[0].r.valid : axibus_s[1].r.valid;
	assign tmp.aw.ready = (sel_s == 0) ? axibus_s[0].aw.ready : axibus_s[1].aw.ready;
	assign tmp.w.ready  = (sel_s == 0) ? axibus_s[0].w.ready : axibus_s[1].w.ready;
	assign tmp.b.resp   = (sel_s == 0) ? axibus_s[0].b.resp : axibus_s[1].b.resp;
	assign tmp.b.valid  = (sel_s == 0) ? axibus_s[0].b.valid : axibus_s[1].b.valid;

	// Router
	for (genvar i = 0; i < NUM_MASTER; i++) begin
		assign axibus_m[i].ar.ready = (i == sel_m) ? tmp.ar.ready : 0;
		assign axibus_m[i].r.data   = (i == sel_m) ? tmp.r.data : 0;
		assign axibus_m[i].r.resp   = (i == sel_m) ? tmp.r.resp : 0;
		assign axibus_m[i].r.valid  = (i == sel_m) ? tmp.r.valid : 0;
		assign axibus_m[i].aw.ready = (i == sel_m) ? tmp.aw.ready : 0;
		assign axibus_m[i].w.ready  = (i == sel_m) ? tmp.w.ready : 0;
		assign axibus_m[i].b.resp   = (i == sel_m) ? tmp.b.resp : 0;
		assign axibus_m[i].b.valid  = (i == sel_m) ? tmp.b.valid : 0;
	end


	always_comb begin
		case (state)
			IDLE :  next_state = (start_r) ? READ : (start_w) ? WRITE : IDLE;
			READ :  next_state = (axibus_s[sel_s].r.valid && axibus_m[sel_m].r.ready) ? IDLE : READ;
			WRITE : next_state = (axibus_s[sel_s].b.valid && axibus_m[sel_m].b.ready) ? IDLE : WRITE;
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

endmodule
