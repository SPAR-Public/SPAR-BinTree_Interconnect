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



`timescale 1 ns / 1 ps

	module ARP_wo_DFF_v1_0 #
	(
		// Users to add parameters here
        parameter [7:0] ARRAY_DIM = 1,
        parameter [7:0] TILE_DIM = 2,
        parameter integer MAX_WORD_LENGTH = 32,
		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
//        output[4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1:0] debug_EAST_O_0,
//        output[ARRAY_DIM*TILE_DIM*8-1:0] debug_EOUT_0,
//        output[4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1:0] debug_NORTH_I_0,
//        output[ARRAY_DIM*TILE_DIM*8-1:0] debug_NIN_0,
//        output[4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1:0] debug_EAST_I_0,
//        output[ARRAY_DIM*TILE_DIM*8-1:0] debug_EIN_0,
//        output[4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1:0] debug_NORTH_O_0,
//        output[ARRAY_DIM*TILE_DIM*8-1:0] debug_NOUT_0,
//        output west_debug_in_mode_1_0,
//        output west_debug_in_mode_2_0,
//        output east_debug_in_mode_1_0,
//        output east_debug_in_mode_2_0,
//        output north_debug_in_mode_1_0,
//        output north_debug_in_mode_2_0,
//        output south_debug_in_mode_1_0,
//        output south_debug_in_mode_2_0,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready
	);
// Instantiation of Axi Bus Interface S00_AXI
	ARP_wo_DFF_v1_0_S00_AXI # ( 
		.ARRAY_DIM(ARRAY_DIM),
		.TILE_DIM(TILE_DIM),
        .MAX_WORD_LENGTH(MAX_WORD_LENGTH),
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) ARP_wo_DFF_v1_0_S00_AXI_inst (
//	    .debug_EAST_O_0(debug_EAST_O_0),
//        .debug_EOUT_0(debug_EOUT_0),
//        .debug_NORTH_I_0(debug_NORTH_I_0),
//        .debug_NIN_0(debug_NIN_0),
//        .debug_EAST_I_0(debug_EAST_I_0),
//        .debug_EIN_0(debug_EIN_0),
//        .debug_NORTH_O_0(debug_NORTH_O_0),
//        .debug_NOUT_0(debug_NOUT_0),        
//        .west_debug_in_mode_1_0(west_debug_in_mode_1_0),
//        .west_debug_in_mode_2_0(west_debug_in_mode_2_0),
//        .east_debug_in_mode_1_0(east_debug_in_mode_1_0),
//        .east_debug_in_mode_2_0(east_debug_in_mode_2_0),
//        .north_debug_in_mode_1_0(north_debug_in_mode_1_0),
//        .north_debug_in_mode_2_0(north_debug_in_mode_2_0),
//        .south_debug_in_mode_1_0(south_debug_in_mode_1_0),
//        .south_debug_in_mode_2_0(south_debug_in_mode_2_0),        
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
