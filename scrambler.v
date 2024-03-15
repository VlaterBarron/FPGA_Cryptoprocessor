//1 + x^3 + x^15 + x^16

module scrambler
#(parameter N = 8)(
	input wire clk, rst, en,
	input wire [N-1:0] seed, data_in,
	output wire send_to_uart,
	output wire [N-1:0] data_out,
	output reg [N-1:0] data_in_reg
);

localparam IDLE = 1'b0, SCRAM = 1'b1;
reg state, next_state;
reg send_to_uart_reg, next_send_to_uart_reg;
reg [N-1:0] seed_reg, next_seed_reg;
reg [N-1:0] data_scram, next_data_scram;

reg [3:0] counter, counter_reg;

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		state <= 0;
		send_to_uart_reg <= 0;
		seed_reg <= {N{1'b0}};
		data_scram <= {N{1'b0}};
		counter <= 0;
	end else begin
		state <= next_state;
		data_scram <= next_data_scram;
		seed_reg <= next_seed_reg;
		send_to_uart_reg <= next_send_to_uart_reg;
		counter <= counter_reg;
	end
end

always @* begin
	next_state = state;
	next_data_scram = data_scram;
	next_seed_reg = seed_reg;
	next_send_to_uart_reg = send_to_uart_reg;
	counter_reg = counter;
	case(state)
		IDLE: begin
			next_send_to_uart_reg = 0;
			counter_reg = 0;
			data_in_reg = data_in;
			if(en) begin
				next_state = SCRAM;
				next_seed_reg = seed;
				next_data_scram = data_scram;
			end
		end
		SCRAM: begin
			if(counter == 4'b0111) begin
				next_state = IDLE;
				next_data_scram = next_seed_reg;
				next_send_to_uart_reg = 1'b1;
			end else begin
				counter_reg = counter_reg + 1;
				next_seed_reg = {seed_reg[N-2:0], seed_reg[N-1] ^ seed_reg[N-2] ^ seed_reg[2]};
			end
		end
	endcase
end

assign data_out = data_in ^ data_scram;
assign send_to_uart = send_to_uart_reg;

endmodule
