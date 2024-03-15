module mux #(parameter N = 8)(
	input wire select,
	input wire [N-1:0] in_1, in_2,
	output wire [N-1:0] out
);

	assign out = (select ? in_2 : in_1);

endmodule
