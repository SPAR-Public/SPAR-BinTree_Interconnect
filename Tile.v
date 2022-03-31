module Tile #(parameter TILE_DIM = 1)(
		input clk,
		input reset,
		input start,
		input[31:0] instruction,
		input external,
		input[7:0] BRAM_i,
		input[7:0] BRAM_j,
		input WEA,
		input WEB,
		input[9:0] ADDRA,
		input[9:0] ADDRB,
		input[15:0] DIA,
		input[15:0] DIB,
		output[15:0] DOA,
		output[15:0] DOB,
		//input[0:TILE_DIM*8*8-1] WIN,
		//input[0:TILE_DIM*8*8-1] EIN,
		//input[0:TILE_DIM*8*8-1] SIN,
		//input[0:TILE_DIM*8*8-1] NIN,
		input[0:TILE_DIM*8-1] Ein_Win_0,
		input[0:TILE_DIM*8-1] Nin_Sin_0,
		input[0:TILE_DIM*8-1] Ein_Win_1,
		input[0:TILE_DIM*8-1] Nin_Sin_1,
		input[0:TILE_DIM*8-1] Ein_Win_2,
		input[0:TILE_DIM*8-1] Nin_Sin_2,
		input[0:TILE_DIM*8-1] Ein_Win_3,
		input[0:TILE_DIM*8-1] Nin_Sin_3,
		//output[0:TILE_DIM*8-1] WOUT,
		//output[0:TILE_DIM*8-1] EOUT,
		//output[0:TILE_DIM*8-1] SOUT,
		//output[0:TILE_DIM*8-1] NOUT
		output[0:TILE_DIM*8-1] Eout_Wout_0,
		output[0:TILE_DIM*8-1] Nout_Sout_0, 
		output[0:TILE_DIM*8-1] Eout_Wout_1,
		output[0:TILE_DIM*8-1] Nout_Sout_1,		
		output[0:TILE_DIM*8-1] Eout_Wout_2,
		output[0:TILE_DIM*8-1] Nout_Sout_2,	
		output[0:TILE_DIM*8-1] Eout_Wout_3,
		output[0:TILE_DIM*8-1] Nout_Sout_3

    );

wire[3:0] alu_op;

wire[9:0] addra;
wire[9:0] addrb;
wire[1:0] east_mode;
wire[1:0] west_mode;
wire[1:0] south_mode;
wire[1:0] north_mode;
wire[4:0] num_shift;
//other helper signals
wire[7:0] count; //debug: was [6:0]
wire[2:0] state; //debug:


//wire[7:0] EtoW[TILE_DIM-1:0][TILE_DIM-1:0][3:0];
//wire[7:0] WtoE[TILE_DIM-1:0][TILE_DIM-1:0][3:0];
//wire[7:0] StoN[TILE_DIM-1:0][TILE_DIM-1:0][3:0];
//wire[7:0] NtoS[TILE_DIM-1:0][TILE_DIM-1:0][3:0];
wire[7:0] EtoW_WtoE[TILE_DIM-1:0][TILE_DIM-1:0][3:0];
wire[7:0] NtoS_StoN[TILE_DIM-1:0][TILE_DIM-1:0][3:0];

wire[15:0] wDOA[TILE_DIM-1:0][TILE_DIM-1:0];
wire[15:0] wDOB[TILE_DIM-1:0][TILE_DIM-1:0];

assign DOA = wDOA[BRAM_i][BRAM_j];
assign DOB = wDOB[BRAM_i][BRAM_j];

Controller #(32) FSM
		(
			clk, 
			reset,
			start,
			instruction,
			//alu control
			alu_op,
			//bram control
			wea,
			web,
			addra, 
			addrb,
			//move control
			east,	
			west,	
			south,	
			north,
			east_mode,
			west_mode,
			south_mode,
			north_mode,
			num_shift,
			//other helper signals
			count,
			state
		);


generate

genvar gi;
genvar gj;

for (gi=0; gi<TILE_DIM; gi=gi+1) begin : ROW
	for (gj=0; gj<TILE_DIM; gj=gj+1) begin : COL
		PE16_Block #(TILE_DIM, 32) block 
		(
			clk,
			reset,
            // LENGTH,
			//alu control
			alu_op,
			//bram control
			(gi==BRAM_i && gj==BRAM_j? (external? WEA : wea) : wea),
			(gi==BRAM_i && gj==BRAM_j? (external? WEB : web) : web),
			(gi==BRAM_i && gj==BRAM_j? (external? ADDRA : addra) : addra),
			(gi==BRAM_i && gj==BRAM_j? (external? ADDRB : addrb) : addrb),
            gi==BRAM_i && gj==BRAM_j? DIA : 16'hzzzz,
            gi==BRAM_i && gj==BRAM_j? DIB : 16'hzzzz,
		    wDOA[gi][gj],
            wDOB[gi][gj],
            external,
			//other helper signals
			count,
			// bram_init_flag,
			// bram_init_flag? bram_init_d : 16'hzzzz,
			state,
			//move control
			east,	
			west,	
			south,		
			north,		
			//move data
			//gj==TILE_DIM-1              ? EIN[8*gi+:8] : EtoW_WtoE[gi][gj+1][0], //shW
			//gj==0                   ? WIN[8*gi+:8] : EtoW_WtoE[gi][gj-1][0],	//shE
			//gi==0   			    ? NIN[8*gj+:8] : NtoS_StoN[gi-1][gj][0],	//shS
			//gi==TILE_DIM-1              ? SIN[8*gj+:8] : NtoS_StoN[gi+1][gj][0],	//shN
			(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][1]:
							  (east)?(gj==0)?Ein_Win_0[8*gi+:8]:EtoW_WtoE[gi][gj-1][3]:8'bz	//Ein_Win_0
			:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][2]:
							  (east)?(gj==0)?Ein_Win_0[8*gi+:8]:EtoW_WtoE[gi][gj-1][2]:8'bz	//Ein_Win_0
			:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?Ein_Win_0[8*gi+:8]:EtoW_WtoE[gi][gj+num_shift/4][0]:
							  (east)?(gj==num_shift/4-1)?Ein_Win_0[8*gi+:8]:EtoW_WtoE[gi][gj-num_shift/4][0]:8'bz:8'bz,	//Ein_Win_0


			(num_shift == 1)? (north)?NtoS_StoN[gi][gj][1]:
							  (south)?(gi==0)?Nin_Sin_0[8*gj+:8]:NtoS_StoN[gi-1][gj][3]:8'bz	//Nin_Sin_0
			:(num_shift == 2)?(north)?NtoS_StoN[gi][gj][2]:
							  (south)?(gi==0)?Nin_Sin_0[8*gj+:8]:NtoS_StoN[gi-1][gj][2]:8'bz	//Nin_Sin_0
			:(num_shift >= 4)?(north)?(gi==TILE_DIM-num_shift/4)?Nin_Sin_0[8*gj+:8]:NtoS_StoN[gi+num_shift/4][gj][0]:
							  (south)?(gj==num_shift/4-1)?Nin_Sin_0[8*gj+:8]:NtoS_StoN[gi-num_shift/4][gj][0]:8'bz:8'bz,	//Nin_Sin_0
									 
			
			(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][2]:
							  (east)?(gj==0)?Ein_Win_1[8*gi+:8]:EtoW_WtoE[gi][gj][0]:8'bz	//Ein_Win_1
			:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][3]:
							  (east)?(gj==0)?Ein_Win_1[8*gi+:8]:EtoW_WtoE[gi][gj-1][3]:8'bz	//Ein_Win_1
			:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?Ein_Win_1[8*gi+:8]:EtoW_WtoE[gi][gj+num_shift/4][0]:
							  (east)?(gj==num_shift/4-1)?Ein_Win_1[8*gi+:8]:EtoW_WtoE[gi][gj-num_shift/4][1]:8'bz:8'bz,	//Ein_Win_1


			(num_shift == 1)? (north)?NtoS_StoN[gi][gj][2]:
							  (south)?NtoS_StoN[gi][gj][0]:8'bz	//Nin_Sin_1
			:(num_shift == 2)?(north)?NtoS_StoN[gi][gj][3]:
							  (south)?(gi==0)?Nin_Sin_1[8*gj+:8]:NtoS_StoN[gi-1][gj][3]:8'bz	//Nin_Sin_1
			:(num_shift >= 4)?(north)?(gi==TILE_DIM-num_shift/4)?Nin_Sin_1[8*gj+:8]:NtoS_StoN[gi+num_shift/4][gj][1]:
							  (south)?(gi==num_shift/4-1)?Nin_Sin_1[8*gj+:8]:NtoS_StoN[gi-num_shift/4][gj][1]:8'bz:8'bz,	//Nin_Sin_1
									 
			
			(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][3]:
							  (east)?EtoW_WtoE[gi][gj][1]:8'bz	//Ein_Win_2
			:(num_shift == 2)?(west)?(gj==TILE_DIM-1)?Ein_Win_2[8*gi+:8]:EtoW_WtoE[gi][gj+1][0]:
							  (east)?EtoW_WtoE[gi][gj][0]:8'bz
			:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?Ein_Win_2[8*gi+:8]:EtoW_WtoE[gi][gj+num_shift/4][2]:
							  (east)?(gj==num_shift/4-1)?Ein_Win_2[8*gi+:8]:EtoW_WtoE[gi][gj-num_shift/4][2]:8'bz:8'bz,	//Ein_Win_2


			(num_shift == 1)? (north)?NtoS_StoN[gi][gj][3]:
							  (south)?NtoS_StoN[gi][gj][1]:8'bz	//Nin_Sin_2
			:(num_shift == 2)?(north)?(gi==TILE_DIM-1)?Nin_Sin_2[8*gj+:8]:NtoS_StoN[gi+1][gj][0]:							  
							  (south)?NtoS_StoN[gi][gj][0]:8'bz	//Nin_Sin_2
			:(num_shift >= 4)?(north)?(gj==TILE_DIM-num_shift/4)?Nin_Sin_2[8*gj+:8]:NtoS_StoN[gi+num_shift/4][gj][2]:
							  (south)?(gj==num_shift/4-1)?Nin_Sin_2[8*gj+:8]:NtoS_StoN[gi-num_shift/4][gj][0]:8'bz:8'bz,	//Nin_Sin_2
									 
			
			(num_shift == 1)? (west)?(gj==TILE_DIM-1)?Ein_Win_3[8*gi+:8]:EtoW_WtoE[gi][gj+1][0]:
							  (east)?EtoW_WtoE[gi][gj][2]:8'bz	//Ein_Win_3
			:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][1]:
							  (east)?(gj==TILE_DIM-1)?Ein_Win_3[8*gi+:8]:EtoW_WtoE[gi][gj+1][1]:8'bz	//Ein_Win_3
			:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?Ein_Win_3[8*gi+:8]:EtoW_WtoE[gi][gj+num_shift/4][3]:
							  (east)?(gj==num_shift/4-1)?Ein_Win_3[8*gi+:8]:EtoW_WtoE[gi][gj-num_shift/4][0]:8'bz:8'bz,	//Ein_Win_3


			(num_shift == 1)? (north)?(gj==TILE_DIM-1)?Nin_Sin_3[8*gj+:8]:NtoS_StoN[gi+1][gj][0]:
							  (south)?NtoS_StoN[gi][gj][2]:8'bz	//Nin_Sin_3
			:(num_shift == 2)?(north)?(gj==TILE_DIM-1)?Nin_Sin_3[8*gj+:8]:NtoS_StoN[gi+1][gj][1]:
							  (south)?NtoS_StoN[gi][gj][1]:8'bz	//Nin_Sin_3
			:(num_shift >= 4)?(north)?(gj==TILE_DIM-num_shift/4)?Nin_Sin_3[8*gj+:8]:NtoS_StoN[gi+num_shift/4][gj][3]:
							  (south)?(gj==num_shift/4-1)?Nin_Sin_3[8*gj+:8]:NtoS_StoN[gi-num_shift/4][gj][3]:8'bz:8'bz,	//Nin_Sin_3
			
			
			EtoW_WtoE[gi][gj][0], //Eout //Wout
			NtoS_StoN[gi][gj][0], //Nout //Sout
			
			EtoW_WtoE[gi][gj][1], //Eout //Wout
			NtoS_StoN[gi][gj][1], //Nout //Sout
			
			EtoW_WtoE[gi][gj][2], //Eout //Wout
			NtoS_StoN[gi][gj][2], //Nout //Sout
			
			EtoW_WtoE[gi][gj][3], //Eout //Wout
			NtoS_StoN[gi][gj][3], //Nout //Sout
		
			num_shift
		
		);
		//assign EOUT[8*gi+:8] = EtoW_WtoE[gi][TILE_DIM-1][num_shift];
		//assign WOUT[8*gi+:8] = EtoW_WtoE[gi][0][num_shift]; //debug: was [0][gi]
		//assign SOUT[8*gj+:8] = NtoS_StoN[TILE_DIM-1][gj][num_shift];
		//assign NOUT[8*gj+:8] = NtoS_StoN[0][gj][num_shift];
		
		assign Eout_Wout_0[8*gi+:8] = (east)?EtoW_WtoE[gi][TILE_DIM-1][0]:(west)?EtoW_WtoE[gi][0][0]:8'bz;
		assign Nout_Sout_0[8*gj+:8] = (north)?NtoS_StoN[0][gj][0]:(south)?NtoS_StoN[TILE_DIM-1][gj][0]:8'bz;
		assign Eout_Wout_1[8*gi+:8] = (east)?EtoW_WtoE[gi][TILE_DIM-1][1]:(west)?EtoW_WtoE[gi][0][1]:8'bz;
		assign Nout_Sout_1[8*gj+:8] = (north)?NtoS_StoN[0][gj][1]:(south)?NtoS_StoN[TILE_DIM-1][gj][1]:8'bz;
		assign Eout_Wout_2[8*gi+:8] = (east)?EtoW_WtoE[gi][TILE_DIM-1][2]:(west)?EtoW_WtoE[gi][0][2]:8'bz;
		assign Nout_Sout_2[8*gj+:8] = (north)?NtoS_StoN[0][gj][2]:(south)?NtoS_StoN[TILE_DIM-1][gj][2]:8'bz;
		assign Eout_Wout_3[8*gi+:8] = (east)?EtoW_WtoE[gi][TILE_DIM-1][3]:(west)?EtoW_WtoE[gi][0][3]:8'bz;
		assign Nout_Sout_3[8*gj+:8] = (north)?NtoS_StoN[0][gj][3]:(south)?NtoS_StoN[TILE_DIM-1][gj][3]:8'bz;
		
		//assign Eout_Wout_0[8*(gj+(gi*(TILE_DIM)))+:8] = EtoW_WtoE[gi][gj][0];
		//assign Nout_Sout_0[8*(gj+(gi*(TILE_DIM)))+:8] = NtoS_StoN[gi][gj][0];
		//assign Eout_Wout_1[8*(gj+(gi*(TILE_DIM)))+:8] = EtoW_WtoE[gi][gj][1];
		//assign Nout_Sout_1[8*(gj+(gi*(TILE_DIM)))+:8] = NtoS_StoN[gi][gj][1];
		//assign Eout_Wout_2[8*(gj+(gi*(TILE_DIM)))+:8] = EtoW_WtoE[gi][gj][2];
		//assign Nout_Sout_2[8*(gj+(gi*(TILE_DIM)))+:8] = NtoS_StoN[gi][gj][2];
		//assign Eout_Wout_3[8*(gj+(gi*(TILE_DIM)))+:8] = EtoW_WtoE[gi][gj][3];
		//assign Nout_Sout_3[8*(gj+(gi*(TILE_DIM)))+:8] = NtoS_StoN[gi][gj][3];
		
		
		
		/*assign EOUT[8*gi+:8] = (num_shift == 1)? EtoW_WtoE[gi][TILE_DIM-1][3] : 
							   (num_shift == 2)? EtoW_WtoE[gi][TILE_DIM-1][2]: 
							   (num_shift >= 4)? EtoW_WtoE[gi][TILE_DIM-num_shift/4][0]: 8'bz;
									  
		assign WOUT[8*gi+:8] = (num_shift == 1)? EtoW_WtoE[gi][0][0] : 
							   (num_shift == 2)? EtoW_WtoE[gi][0][1]: 
							   (num_shift >= 4)? EtoW_WtoE[gi][num_shift/4-1][3]: 8'bz;

		assign NOUT[8*gj+:8] = (num_shift == 1)? NtoS_StoN[TILE_DIM-1][gj][3] : 
							   (num_shift == 2)? NtoS_StoN[TILE_DIM-1][gj][2]: 
							   (num_shift >= 4)? NtoS_StoN[TILE_DIM-num_shift/4][gj][0]: 8'bz;

		assign SOUT[8*gj+:8] = (num_shift == 1)? NtoS_StoN[0][gj][0] : 
							   (num_shift == 2)? NtoS_StoN[0][gj][1]: 
							   (num_shift >= 4)? NtoS_StoN[num_shift/4-1][gj][3]: 8'bz;
		*/
	end
  end
  
endgenerate
endmodule