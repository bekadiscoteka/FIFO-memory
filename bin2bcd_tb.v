`include "bin2bcd.v"
`timescale 1ns / 1ns
module bin2bcd_tb;
	reg clk=0, reset=0, start=0;
	reg [19:0] in=20'd699999;
	wire done_tick;
	bin2bcd conv(
		.clk(clk),
		.reset(reset),
		.start(start),
		.bin(in),
		.done_tick(done_tick)
	);	
	initial forever #1 clk = ~clk;

	initial begin
		reset=1;
		@(posedge clk);
		reset=0;
		@(posedge clk);

		start=1;

		wait(done_tick);		
		repeat(5) @(posedge clk);
		$finish;
	end
endmodule
