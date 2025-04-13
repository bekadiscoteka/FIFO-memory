`ifndef EDGE_DETECT
	`define EDGE_DETECT
	module edge_detector(
		output tick,
		input reset, clk, in
	);
		parameter MODE=1; //rise edge by default

		localparam 
		UNKNOWN=0,
		LOW=1,	
		HIGH=2,
		TICK=3;

		reg [1:0] state;
		reg fall;
		assign tick = state == TICK;
		always @(posedge clk, posedge reset) begin
			if (reset) begin
			   	state <= 0;
				fall <= 0;
			end
			else begin
				if (fall == MODE) begin
					case (state) 
						UNKNOWN, TICK, LOW: state <= in ? HIGH : LOW;
						HIGH: state <= ~in ? TICK : HIGH;
					endcase
				end
				else begin
					case (state) 
						UNKNOWN, TICK, HIGH: state <= in ? HIGH : LOW;
						LOW: state <= in ? TICK : HIGH;
					endcase
				end
			end
		end
	endmodule
`endif
