`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Cryptoprocessor design in FPGAs for wireless healthcare monitoring measurements
// Engineer: Vladimir Barrón
// 
// Create Date:    10:23:56 03/22/2024 
// Design Name: Uniform Random Noise Generator Design.
// Module Name:    Tausworthe V.2
// Project Name: MIMO emulator channel 
//
//////////////////////////////////////////////////////////////////////////////////
module Tausworthe #(parameter N = 8)(
    input wire clk_in,
	 input wire reset_in,
    input wire en_in,
	 output wire send,
    output wire [N-1:0] urng_out
);

localparam IDLE = 1'b0, GENERATE = 1'b1;

////Iniciar semillas
reg [31:0] s0, s1, s2;
reg [31:0] next_s0, next_s1, next_s2;
reg [31:0] urng_out_r, next_urng_out;
reg state, next_state;
reg done, next_done;

//Declaracion de constantes del metodo
reg [31:0] c0, c1, c2;

	always@(posedge clk_in or negedge reset_in) begin
		if(!reset_in) begin
			state <= 0;
			s0 <= 32'h00FFFFFF;
			s1 <= 32'h00CCCCCC;
			s2 <= 32'h00FF00FF;
			c0 <= 32'hFFFFFFFE;
			c1 <= 32'hFFFFFFF8;
			c2 <= 32'hFFFFFFF0;
			urng_out_r <= 0;
			done <= 0;
		end else begin
			state <= next_state;
			s0 <= next_s0;
			s1 <= next_s1;
			s2 <= next_s2;
			urng_out_r <= next_urng_out;
			done <= next_done;
		end
	end
	
	
	always @* begin
		next_state = state;
		next_urng_out = urng_out_r;
		next_done = 0;
		next_s0 = s0;
		next_s1 = s1;
		next_s2 = s2;
		case(state) 
			IDLE: begin
				if(!en_in) begin
					next_state = GENERATE;
				end 
			end
			GENERATE: begin
				next_s0 = ((s0 & c0) << 12) ^ (((s0 << 13) ^ s0) >> 19);
            next_s1 = ((s1 & c1) << 4) ^ (((s1 << 2) ^ s1) >> 25);
            next_s2 = ((s2 & c2) << 17) ^ (((s2 << 3) ^ s2) >> 11);
            next_urng_out = next_s0 ^ next_s1 ^ next_s2;
				next_done = 1'b1;
				next_state = IDLE;
			end
		endcase
	end

	assign urng_out = urng_out_r[N-1:0];
	assign send = done;
	
endmodule
