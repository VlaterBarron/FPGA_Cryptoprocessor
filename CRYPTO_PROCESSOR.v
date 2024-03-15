module CRYPTO_PROCESSOR #(parameter DBITS = 8)(
	input wire clk, rst, en, select,
	input wire [DBITS-1:0] plain_text,
	output wire [DBITS-1:0] led_out,
	output wire tx
);

	wire [DBITS-1:0] cipher_text, plain_text_reg;
	wire send_to_uart, send_to_crypto;
	
	parameter N = 9, M = 325;
	wire tx_done_tick;
	wire [N-1:0] q;
	
	debounce btn_debounce(
		.clk(clk),
		.rst(rst),
		.btn(en),
		.db_level(),
		.db_tick(send_to_crypto)
	);

	Crypto_Module #(.N(DBITS)) crypto_mod(
		.clk(clk),
		.rst(rst),
		.en(!send_to_crypto),
		.plain_text(plain_text),
		.send_to_uart(send_to_uart),
		.cipher_text(cipher_text),
		.plain_text_reg(plain_text_reg)
	);
	
	uart_tx uart_tx_mod(
		.clk(clk),
		.reset(rst),
		.tx_start(send_to_uart),
		.s_tick(s_tick),
		.din(cipher_text),
		.tx_done_tick(tx_done_tick),
		.tx(tx)
	);
	
	mux #(.N(DBITS)) mux1 (
		.select(select),
		.in_1(cipher_text),
		.in_2(plain_text_reg),
		.out(led_out)
	);
	
	mod_m_counter #(.N(N),.M(M)) counter(
		.clk(clk),
		.rst(rst),
		.max_tick(s_tick),
		.q(q)
	);

endmodule
