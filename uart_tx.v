module uart_tx
	#(parameter DBIT = 8,		//data bits
					SB_TICK = 16	//ticks for stop bits. 16 is 1 and 24 is 1.5
	)
	(
	 input wire clk, reset, tx_start, s_tick,
	 input wire [7:0] din,
	 output reg tx_done_tick,
	 output wire tx
	);
	
	//symbolic state declarations
	localparam [1:0]
		idle = 2'b00,
		start = 2'b01,
		data = 2'b10,
		stop = 2'b11;
	
	//signal declarations
	reg [1:0] state, next_state;
	reg [3:0] s_reg, s_next;
	reg [2:0] n_reg, n_next;
	reg [7:0] din_reg, din_next;
	reg tx_reg, tx_next;
	
	//FSMD state & data registers
	always @(posedge clk, negedge reset)
		if(!reset) begin
			state <= 0;
			s_reg <= 0;
			n_reg <= 0;
			din_reg <= 0;
			tx_reg <= 1'b1;
		end else begin
			state <= next_state;
			s_reg <= s_next;
			n_reg <= n_next;
			din_reg <= din_next;
			tx_reg <= tx_next;
		end
	
	//next-state logic & functional units
	always @*
	begin
		next_state = state;
		tx_done_tick = 1'b0;
		s_next = s_reg;
		n_next = n_reg;
		din_next = din_reg;
		tx_next = tx_reg;
		case(state)
			idle:
				begin
					tx_next = 1'b1;
					if(tx_start)
						begin
							next_state = start;
							s_next = 0;
							din_next = din;
						end
				end
			start:
				begin
					tx_next = 1'b0;
					if(s_tick)
						if(s_reg ==15)
							begin
								next_state = data;
								s_next = 0;
								n_next = 0;
							end
						else
							s_next = s_reg + 1'b1;
				end
			data:
				begin
					tx_next = din_reg[0];
					if(s_tick)
						if(s_reg==15)
							begin
								s_next = 0;
								din_next = din_reg >> 1;
								if(n_reg == (DBIT-1))
									next_state = stop;
								else
									n_next = n_reg + 1'b1;
							end
						else
							s_next = s_reg +1'b1;
				end
			stop:
				begin
					tx_next = 1'b1;
					if(s_tick)
						if(s_reg == (SB_TICK-1))
							begin
								next_state = idle;
								tx_done_tick = 1'b1;
							end
						else
							s_next = s_reg + 1'b1;
				end
		endcase
	end
	
	//output
	assign tx = tx_reg;
	

endmodule
