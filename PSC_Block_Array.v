`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2020 01:27:21 PM
// Design Name: 
// Module Name: PSC_Block_Array
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PSC_Block_Array
    #(parameter MAX_WORD_LENGTH = 32, parameter[7:0] TILE_DIM = 8'h01)(
        input clk, 
        input reset, 
        input [1:0] mode,
        input start,
        output finish,
        input [8*TILE_DIM-1:0] serial_data_in,
        input [4*MAX_WORD_LENGTH*TILE_DIM-1:0] parallel_data_in,
        output[8*TILE_DIM-1:0] serial_data_out,
        output[4*MAX_WORD_LENGTH*TILE_DIM-1:0] parallel_data_out
    );
    

genvar gi;
// generate and endgenerate is optional
generate
    for (gi=0; gi<TILE_DIM; gi=gi+1) begin : psc_block
        Parallel_Serial_Converter # (1, MAX_WORD_LENGTH, MAX_WORD_LENGTH) ps_convert_block
        (
            clk,  
            reset, 
            mode,
            start,
            finish,
            serial_data_in[8*gi+:8],
            parallel_data_in[4*MAX_WORD_LENGTH*gi+:4*MAX_WORD_LENGTH],
            serial_data_out[8*gi+:8],
            parallel_data_out[4*MAX_WORD_LENGTH*gi+:4*MAX_WORD_LENGTH]
        );
    end
endgenerate
endmodule