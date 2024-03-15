module Crypto_Module #(parameter N = 8) (
	input wire clk, rst, en,
	input wire [N-1:0] plain_text,
	output wire [N-1:0] cipher_text,
	output wire [N-1:0] plain_text_reg,
	output wire send_to_uart
);

	wire [N-1:0] seed;
	wire send;

	scrambler #(.N(N)) scram(
		.clk(clk),
		.rst(rst),
		.en(send),
		.data_in(plain_text),
		.seed(seed),
		.data_out(cipher_text),
		.send_to_uart(send_to_uart),
		.data_in_reg(plain_text_reg)
	);
	
	Tausworthe #(.N(N)) taus(
		.clk_in(clk),
		.reset_in(rst),
		.en_in(en),
		.send(send),
		.urng_out(seed)
	);
	
endmodule
