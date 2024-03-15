module Moving_Average #(parameter N = 16)(
  input wire [N-1:0] data_in,
  input clk, rst, fit_data,
  output wire isFiltered,
  output wire [N-1:0] data_out
);

  parameter WINDOW_SIZE = 4;
  
  reg [N-1:0] data_out_reg;
  reg [N+1:0] sum;
  reg isFiltered_reg;
  integer i;
  
  always @(posedge clk or negedge rst) begin
	if(!rst) begin
		data_out_reg <= 0;
		sum <= 0;
		isFiltered_reg <= 0;
		i <= 0;
	end else if(fit_data) begin
		sum <= sum + data_in;
		isFiltered_reg <= 0;
		i <= i + 1;
	end else begin
		if(i >= 4) begin
			data_out_reg <= sum / WINDOW_SIZE;
			isFiltered_reg <= 1'b1;
			sum <= 0;
			i <= 0;
		end
		else
			isFiltered_reg <= 0;
	end
  end
      
  assign data_out = data_out_reg;
  assign isFiltered = isFiltered_reg;
endmodule
