module Asynchronous_fifo #(parameter WIDTH = 8, DEPTH = 16)(
	input wire rd_clk, rd_en,  
	input wire wr_clk, wr_en,
	input wire rd_rstn, wr_rstn,
	input wire [WIDTH-1:0] Data_in,
	output reg full,
	output reg empty,
	output reg [WIDTH-1:0] Data_out
);

reg [WIDTH-1:0] fifo_mem [DEPTH-1:0];

reg [$clog2(DEPTH):0] read_ptr;			// Extra one bit for full & empty logic
reg [$clog2(DEPTH):0] write_ptr;

//Read Operation
always @ (posedge rd_clk or negedge rd_rstn) begin
	if(!rd_rstn) begin
		Data_out <= 'b0;
		read_ptr <= 'b0;
	end
	else begin
		if(rd_en) begin
			Data_out <= fifo_mem[read_ptr];
			read_ptr <= read_ptr + 1;
		end
		else begin
			Data_out <= Data_out;
			read_ptr <= read_ptr;
		end
	end
end

// Write Operation
always @ (posedge wr_clk or negedge wr_rstn) begin
	if(!wr_rstn) begin
		for (i=0; i<DEPTH; i=i+1) begin
			fifo_mem[i] <= 'b0;
		end
		write_ptr <= 'b0;
	end
	else begin
		if(wr_en) begin
			fifo_mem[write_ptr] <= Data_in;
			write_ptr <= write_ptr + 1;
		end
		else begin
			fifo_mem[write_ptr] <= fifo_mem[write_ptr];
			write_ptr <= write_ptr;
		end
	end
end


bin2grey #(.WIDTH(8)) inst1 (.bin(write_ptr), .grey(gr_write_ptr));
DFF inst2 (.clk(wr_clk), .rst(wr_rstn), .Din(gr_write_ptr), .Q(gwptr));

sync_2ff #(.WIDTH(8)) inst5(.clk(rd_clk), .rst(rd_rstn), .Din(gwptr), .Syn_out(gwptr_sync));

bin2grey #(.WIDTH(8)) inst3 (.bin(read_ptr), .grey(gr_read_ptr));
DFF inst4 (.clk(rd_clk), .rst(rd_rstn), .Din(gr_read_ptr), .Q(grptr));

sync_2ff inst6(.clk(wr_clk), .rst(wr_rstn), .Din(grptr), .Syn_out(grptr_sync));


// Full Condition
always @ * begin
	if()
end



























































module DFF #(parameter WIDTH = 8)(
	input wire clk, rst,
	input wire [WIDTH-1:0] Din,
	output reg [WIDTH-1:0] Q
);
always @ (posedge clk or negedge rst) begin
	if(!rst) begin
		Q <= 0;
	end
	else begin
		Q <= Din;
	end
end
endmodule

module sync_2ff #(parameter WIDTH = 8)(
	input wire clk, rst,
	input wire [WIDTH-1:0]Din,
	output reg [WIDTH-1:0] Syn_out
);
reg [WIDTH-1:0] R1;
always @ (posedge clk or negedge rst) begin
	if(!rst) begin
		R1 <= 0;
		Syn_out <= 0;
	end
	else begin
		R1 <= Din;
        Syn_out <= R1;
	end
end
endmodule

module bin2grey #(parameter WIDTH = 8)(
	input wire [WIDTH-1:0] bin,
	output wire [WIDTH-1:0] grey
);
	assign grey = bin ^ (bin >> 1);
endmodule

module grey2bin #(parameter WIDTH = 8)(
	input wire [WIDTH-1:0] grey,
	output wire [WIDTH-1:0] bin
);
integer i;

always @ * begin
	for(i=0; i<WIDTH; i=i+1) begin
		bin[i] = ^(grey >> i);
	end
end
endmodule
	