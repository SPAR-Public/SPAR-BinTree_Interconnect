/*
 * Copyright (c) 2022, SPAR-Internal
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */


// Simple Dual-Port Block RAM with One Clock
// File: simple_dual_one_clock.v
module BRAM  //#(parameter SIZE = 5, parameter MAX_WORD_LENGTH = 32, parameter RAM_SIZE = MAX_WORD_LENGTH*32-1) //debug:
	(	
		clk,
		reset,
		wea,
		web,
		addra,
		addrb,
		dia,
		dib,
		doa,
		dob
		//id //debug:
	);
input clk, reset, wea, web;
//input[SIZE-1:0] id; //debug:
input [9:0] addra,addrb;
input [15:0] dia, dib;
output reg [15:0] doa,dob;
reg[159:0] ram[15:0] ;
integer i;

always @(posedge clk) 
begin

	// if(!reset) begin
	
	// for (i=0; i<16; i=i+1) begin
		// ram[i] 	= {18'h0,id,i[3:0],18'h0,id,i[3:0],96'h00000000_00000000_00000000};
	// end
	
	// end
	// else begin
		if (wea) begin
		   for(i=0; i<16; i=i+1) begin
			   ram[i][addra] = dia[i];
		   end
		end
		
		for(i=0; i<16; i=i+1) begin
		   doa[i] = ram[i][addra];
		end
	// end
end
always @(posedge clk) 
begin  
	if (web) begin
	   for(i=0; i<16; i=i+1) begin
	       ram[i][addrb] = dib[i];
	   end
	end
    for(i=0; i<16; i=i+1) begin
	   dob[i] = ram[i][addrb];
	end 
end

endmodule
