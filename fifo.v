`include "edge_detector.v"

`ifndef FIFO
	`define FIFO
	module fifo(
		output reg [7:0] leds, 
		output full, empty,
		input [7:0] in,
		input clk, reset, push, pop //push, pop active-low
	);
			
		parameter N=16;
		localparam EMPTY=0, PROC=1, FULL=2;	
	
		wire do_push, do_pop;
		wire read_en = 1;

		edge_detector #(.MODE(0)) push_detect( //fall mode
			.tick(do_push),
			.clk(clk),
			.reset(reset),
			.in(push)
		);
		edge_detector #(.MODE(0)) pop_detect(
			.tick(do_pop),
			.clk(clk),
			.reset(reset),
			.in(pop)
		);


		reg write_en;	
		reg [1:0] state;
		
		reg [log(N)-1:0] write_addr, read_addr;	
		wire [log(N)-1:0] nxt_write_addr = write_addr + 2'd1;
		wire [log(N)-1:0] nxt_read_addr = read_addr + 2'd1;
		reg [7:0] mem [0:N-1];
		always @(posedge clk, posedge reset) begin
			if (reset) leds <= 0;
			else begin
			if (write_en) mem[write_addr] <= in;
			if (read_en) leds <= mem[read_addr];
			end
		end

		assign full = state == FULL;
		assign empty = state == EMPTY;
		
		always @(posedge clk, posedge reset) begin
			if (reset) begin
				write_addr <= 0; 
				read_addr <= 0; 
				write_en <= 1;	
				state <= 0;
			end	
			else begin
				case (state) 
					EMPTY: begin
						if (do_push) begin
							write_addr <= nxt_write_addr;
							state <= PROC;
						end
					end
					PROC: begin
						if (do_push) begin
							write_addr <= nxt_write_addr;
							if (nxt_write_addr == read_addr) begin
								state <= FULL;
								write_en <= 0;
							end	
						end
						if (do_pop) begin
							read_addr <= nxt_read_addr;
							if (nxt_read_addr == write_addr) 
								state <= EMPTY;
						end
					end
					FULL: begin
						if (do_pop) begin
							read_addr <= nxt_read_addr;
							state <= PROC;
							write_en <= 1;
						end
					end
				endcase
			end
		end
		function integer log;
			input [7:0] N;
			integer i;
			begin
				for (i=7; !N[7]; i = i-1) 
					N = N << 1;	
				log = i;	
			end	
		endfunction
	endmodule
`endif
