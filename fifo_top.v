`include "fifo.v"
`include "bin2bcd.v"
`include "bcd2sseg_active_low.v"
`include "edge_detector.v"
module fifo_top(
	output [7:0] sseg5,
				 sseg4,
				 sseg3,
				 sseg2,
				 sseg1,
				 sseg0,
	output [7:0] leds,
	output full, empty,
	input [7:0] in_bin,
	input reset, clk, push, pop // push, pop active-low
);	
	wire [3:0] bcd5,
			   bcd4,
			   bcd3,
			   bcd2,
			   bcd1,
			   bcd0;
	wire [7:0] fifo_leds;
	wire do_pop;
		
	assign leds = in_bin;		
	assign {
		sseg5[7],
		sseg4[7],
		sseg3[7],	
		sseg2[7],
		sseg1[7],
		sseg0[7]
	} = 6'b111_111;

	fifo mem_fifo(
		.leds(fifo_leds),
		.full(full),
		.empty(empty),
		.clk(clk),
		.reset(reset),
		.in(in_bin),
		.push(push),
		.pop(pop)
	);	

	edge_detector #(.MODE(0)) ed(
		.clk(clk),
		.reset(reset),
		.in(pop),
		.tick(do_pop)
	);

	bin2bcd get_bcd(
		.clk(clk),
		.reset(reset),
		.start(do_pop),
		.bcd5(bcd5),
		.bcd4(bcd4),
		.bcd3(bcd3),
		.bcd2(bcd2),
		.bcd1(bcd1),
		.bcd0(bcd0),
		.bin({12'd0, fifo_leds})
	);

	bcd2sseg_active_low get_sseg(
		.bcd5(bcd5),
		.bcd4(bcd4),
		.bcd3(bcd3),
		.bcd2(bcd2),
		.bcd1(bcd1),
		.bcd0(bcd0),
		.sseg5(sseg5[6:0]),
		.sseg4(sseg4[6:0]),
		.sseg3(sseg3[6:0]),
		.sseg2(sseg2[6:0]),
		.sseg1(sseg1[6:0]),
		.sseg0(sseg0[6:0])
	);
	
endmodule	

