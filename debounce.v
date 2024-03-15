module debounce (
	input wire clk, rst, btn,
	output reg db_level, db_tick
);

localparam [1:0]
				zero = 2'b00,
				wait0 = 2'b01,
				one = 2'b10,
				wait1 = 2'b11;

localparam N = 21;  //21 for FPGA btn  4 for testing

reg [N-1:0] q_reg, q_next;
reg [1:0] state, next_state;

always @(posedge clk, negedge rst) begin
	if(!rst) begin
		state <= zero;
		q_reg <= 0;
	end else begin
		state <= next_state;
		q_reg <= q_next;
	end
end

always @* begin
	next_state = state; // default state: the same
	q_next = q_reg; // default q: unchnaged
	db_tick = 1'b0; // default output: 0
	case (state)
	zero : begin
		db_level = 1'b0;
		if (!btn) begin
			next_state = wait1;
			q_next = {N{1'b1}}; // load I..]
		end
	end
	wait1 : begin
	db_level = 1'b0;
		if (!btn) begin
			q_next = q_reg - 1;
			if (q_next == 0) begin
				next_state = one;
				db_tick = 1'b1;
			end
		end else // btn == 1
			next_state = zero;
	end
	one : begin
	db_level = 1'b1;
	if (btn) begin
		next_state = wait0;
		q_next = {N{1'b1}}; // load I.. I
		end
	end
	wait0 : begin  //state = 01
	db_level = 1'b1;
	if (btn) begin
		q_next = q_reg - 1;
		if (q_next == 0)
		next_state = zero;
		end
	else // btn==l
		next_state = one;
	end
	default : next_state = zero;
	endcase
end



endmodule
