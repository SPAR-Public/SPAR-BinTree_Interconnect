module Top #(parameter[7:0] ARRAY_DIM = 8'h01, parameter[7:0] TILE_DIM = 8'h01, parameter MAX_WORD_LENGTH = 32)
		(
			input clk,
			input reset,
			input start,
			input[31:0] instruction,
			input external,
			input[7:0] Tile_i,
			input[7:0] Tile_j,
			input[7:0] Block_i,
			input[7:0] Block_j,
			input WEA,
            input WEB,
			input[9:0] ADDRA,
            input[9:0] ADDRB,
            input[15:0] DIA,
			input[15:0] DIB,
			output[15:0] DOA,
            output[15:0] DOB,
            input[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_I,
			input[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_I,
			input[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_I,
			input[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_I,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Ein_Win_0,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Nin_Sin_0,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Ein_Win_1,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Nin_Sin_1,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Ein_Win_2,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Nin_Sin_2,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Ein_Win_3,
			//input[0:ARRAY_DIM*ARRAY_DIM*8-1] Nin_Sin_3,
			
			output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_O,
			output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_O,
			output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_O,
			output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_O
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Eout_Wout_0,
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Nout_Sout_0, 
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Eout_Wout_1,
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Nout_Sout_1,		
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Eout_Wout_2,
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Nout_Sout_2,	
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Eout_Wout_3,
			//output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] Nout_Sout_3
			
		);
	
//parameter[7:0] ARRAY_DIM = DIM[15:8];
//parameter[7:0] TILE_DIM = DIM[7:0];

//wire[(TILE_DIM*8)-1:0] EtoW[ARRAY_DIM-1:0][ARRAY_DIM-1:0];
//wire[(TILE_DIM*8)-1:0] WtoE[ARRAY_DIM-1:0][ARRAY_DIM-1:0];
//wire[(TILE_DIM*8)-1:0] StoN[ARRAY_DIM-1:0][ARRAY_DIM-1:0];
//wire[(TILE_DIM*8)-1:0] NtoS[ARRAY_DIM-1:0][ARRAY_DIM-1:0];
wire[(TILE_DIM*8)-1:0] EtoW_WtoE[ARRAY_DIM-1:0][ARRAY_DIM-1:0][3:0];
wire[(TILE_DIM*8)-1:0] NtoS_StoN[ARRAY_DIM-1:0][ARRAY_DIM-1:0][3:0];

wire[15:0] wDOA[ARRAY_DIM-1:0][ARRAY_DIM-1:0];
wire[15:0] wDOB[ARRAY_DIM-1:0][ARRAY_DIM-1:0];

wire[0:ARRAY_DIM*TILE_DIM*8-1] WOUT;
wire[0:ARRAY_DIM*TILE_DIM*8-1] EOUT;
wire[0:ARRAY_DIM*TILE_DIM*8-1] SOUT;
wire[0:ARRAY_DIM*TILE_DIM*8-1] NOUT;
wire[0:ARRAY_DIM*TILE_DIM*8-1] WIN;
wire[0:ARRAY_DIM*TILE_DIM*8-1] EIN;
wire[0:ARRAY_DIM*TILE_DIM*8-1] SIN;
wire[0:ARRAY_DIM*TILE_DIM*8-1] NIN;

wire[9:0] addra;
wire[9:0] addrb;
wire[1:0] east_mode;
wire[1:0] west_mode;
wire[1:0] south_mode;
wire[1:0] north_mode;
wire[4:0] num_shift;

wire[3:0] alu_op;
//other helper signals
wire[7:0] count; //debug: was [6:0]
wire[2:0] state; //debug:
wire finish_W, finish_E, finish_N, finish_S;

generate

genvar gi;
genvar gj;

Controller #(MAX_WORD_LENGTH) FSM
		(
        clk, 
        reset,
        start,
		// input[5:0] LENGTH,
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
		// output reg bram_init_flag,
		// output reg[15:0] bram_init_d,
		// output reg finish_flag,
		state
			
		);

PSC_Tile_Array #(MAX_WORD_LENGTH, ARRAY_DIM, TILE_DIM) WEST_IO
//Parallel_Serial_Converter # (ARRAY_DIM*TILE_DIM, MAX_WORD_LENGTH, MAX_WORD_LENGTH) WEST_IO //debug
(
	clk,  
	reset, 
    west_mode,
    start,
    finish_W,
    WOUT,
    WEST_I,
    WIN,
    WEST_O
);

PSC_Tile_Array #(MAX_WORD_LENGTH, ARRAY_DIM, TILE_DIM) EAST_IO
//Parallel_Serial_Converter # (ARRAY_DIM*TILE_DIM, MAX_WORD_LENGTH, MAX_WORD_LENGTH) EAST_IO //debug
(
	clk,  
	reset, 
    east_mode,
    start,
    finish_E,
    EOUT,
    EAST_I,
    EIN,
    EAST_O
);

PSC_Tile_Array #(MAX_WORD_LENGTH, ARRAY_DIM, TILE_DIM) NORTH_IO
//Parallel_Serial_Converter # (ARRAY_DIM*TILE_DIM, MAX_WORD_LENGTH, MAX_WORD_LENGTH) NORTH_IO //debug
(
	clk,  
	reset, 
    north_mode,
    start,
    finish_N,
    NOUT,
    NORTH_I,
    NIN,
    NORTH_O
);

PSC_Tile_Array #(MAX_WORD_LENGTH, ARRAY_DIM, TILE_DIM) SOUTH_IO
//Parallel_Serial_Converter # (ARRAY_DIM*TILE_DIM, MAX_WORD_LENGTH, MAX_WORD_LENGTH) SOUTH_IO //debug
(
	clk,  
	reset, 
    south_mode,
    start,
    finish_S,
    SOUT,
    SOUTH_I,
    SIN,
    SOUTH_O
);

for (gi=0; gi<ARRAY_DIM; gi=gi+1) begin : ROW
	for (gj=0; gj<ARRAY_DIM; gj=gj+1) begin : COL

		Tile #(TILE_DIM) tile(
				clk, 
				reset,
				start,
				instruction,
				external,
				Block_i,
				Block_j,
				(gi==Tile_i && gj==Tile_j? (external? WEA : wea) : wea),            //debug: was WEA,
				(gi==Tile_i && gj==Tile_j? (external? WEB : web) : web),            //debug: was WEB,
				(gi==Tile_i && gj==Tile_j? (external? ADDRA : addra) : addra),      //debug: was ADDRA,
				(gi==Tile_i && gj==Tile_j? (external? ADDRB : addrb) : addrb),      //debug: was ADDRB,
				gi==Tile_i && gj==Tile_j? DIA : 16'hzzzz,                           //debug: was DIA,
				gi==Tile_i && gj==Tile_j? DIB : 16'hzzzz,                           //debug: was DIB,
				wDOA[gi][gj],
            	wDOB[gi][gj],
				//gj==ARRAY_DIM-1              ? EIN[8*TILE_DIM*gi+:8*TILE_DIM] : WtoE[gi][gj+1],//Ein
				//gj==0                    	 ? WIN[8*TILE_DIM*gi+:8*TILE_DIM] : EtoW[gi][gj-1],//Win
				//gi==0   			      	 ? NIN[8*TILE_DIM*gj+:8*TILE_DIM] : StoN[gi-1][gj],//Nin was gi+1
				//gi==ARRAY_DIM-1              ? SIN[8*TILE_DIM*gj+:8*TILE_DIM] : NtoS[gi+1][gj],//Sin was gi-1
				(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][1]:
								  (east)?(gj==0)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-1][3]:8'bz	//Ein_Win_0
				:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][2]:
								  (east)?(gj==0)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-1][2]:8'bz	//Ein_Win_0
				:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+num_shift/4][0]:
								  (east)?(gj==num_shift/4-1)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-num_shift/4][0]:8'bz:8'bz,	//Ein_Win_0


				(num_shift == 1)? (north)?NtoS_StoN[gi][gj][1]:
								  (south)?(gi==0)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-1][gj][3]:8'bz	//Nin_Sin_0
				:(num_shift == 2)?(north)?NtoS_StoN[gi][gj][2]:
								  (south)?(gi==0)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-1][gj][2]:8'bz	//Nin_Sin_0
				:(num_shift >= 4)?(north)?(gi==TILE_DIM-num_shift/4)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+num_shift/4][gj][0]:
								  (south)?(gj==num_shift/4-1)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-num_shift/4][gj][0]:8'bz:8'bz,	//Nin_Sin_0
										 
				
				(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][2]:
								  (east)?(gj==0)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj][0]:8'bz	//Ein_Win_1
				:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][3]:
								  (east)?(gj==0)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-1][3]:8'bz	//Ein_Win_1
				:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+num_shift/4][0]:
								  (east)?(gj==num_shift/4-1)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-num_shift/4][1]:8'bz:8'bz,	//Ein_Win_1


				(num_shift == 1)? (north)?NtoS_StoN[gi][gj][2]:
								  (south)?NtoS_StoN[gi][gj][0]:8'bz	//Nin_Sin_1
				:(num_shift == 2)?(north)?NtoS_StoN[gi][gj][3]:
								  (south)?(gi==0)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-1][gj][3]:8'bz	//Nin_Sin_1
				:(num_shift >= 4)?(north)?(gi==TILE_DIM-num_shift/4)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+num_shift/4][gj][1]:
								  (south)?(gi==num_shift/4-1)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-num_shift/4][gj][1]:8'bz:8'bz,	//Nin_Sin_1
										 
				
				(num_shift == 1)? (west)?EtoW_WtoE[gi][gj][3]:
								  (east)?EtoW_WtoE[gi][gj][1]:8'bz	//Ein_Win_2
				:(num_shift == 2)?(west)?(gj==TILE_DIM-1)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+1][0]:
								  (east)?EtoW_WtoE[gi][gj][0]:8'bz
				:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+num_shift/4][2]:
								  (east)?(gj==num_shift/4-1)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-num_shift/4][2]:8'bz:8'bz,	//Ein_Win_2


				(num_shift == 1)? (north)?NtoS_StoN[gi][gj][3]:
								  (south)?NtoS_StoN[gi][gj][1]:8'bz	//Nin_Sin_2
				:(num_shift == 2)?(north)?(gi==TILE_DIM-1)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+1][gj][0]:							  
								  (south)?NtoS_StoN[gi][gj][0]:8'bz	//Nin_Sin_2
				:(num_shift >= 4)?(north)?(gj==TILE_DIM-num_shift/4)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+num_shift/4][gj][2]:
								  (south)?(gj==num_shift/4-1)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-num_shift/4][gj][0]:8'bz:8'bz,	//Nin_Sin_2
										 
				
				(num_shift == 1)? (west)?(gj==TILE_DIM-1)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+1][0]:
								  (east)?EtoW_WtoE[gi][gj][2]:8'bz	//Ein_Win_3
				:(num_shift == 2)?(west)?EtoW_WtoE[gi][gj][1]:
								  (east)?(gj==TILE_DIM-1)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+1][1]:8'bz	//Ein_Win_3
				:(num_shift >= 4)?(west)?(gj==TILE_DIM-num_shift/4)?EIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj+num_shift/4][3]:
								  (east)?(gj==num_shift/4-1)?WIN[8*TILE_DIM*gi+:8*TILE_DIM]:EtoW_WtoE[gi][gj-num_shift/4][0]:8'bz:8'bz,	//Ein_Win_3


				(num_shift == 1)? (north)?(gj==TILE_DIM-1)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+1][gj][0]:
								  (south)?NtoS_StoN[gi][gj][2]:8'bz	//Nin_Sin_3
				:(num_shift == 2)?(north)?(gj==TILE_DIM-1)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+1][gj][1]:
								  (south)?NtoS_StoN[gi][gj][1]:8'bz	//Nin_Sin_3
				:(num_shift >= 4)?(north)?(gj==TILE_DIM-num_shift/4)?SIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi+num_shift/4][gj][3]:
								  (south)?(gj==num_shift/4-1)?NIN[8*TILE_DIM*gj+:8*TILE_DIM]:NtoS_StoN[gi-num_shift/4][gj][3]:8'bz:8'bz,	//Nin_Sin_3

				
				//EtoW[gi][gj], //Eout
				//WtoE[gi][gj], //Wout
				//NtoS[gi][gj], //Nout
				//StoN[gi][gj],  //Sout
				EtoW_WtoE[gi][gj][0], //Eout //Wout
				NtoS_StoN[gi][gj][0], //Nout //Sout
				
				EtoW_WtoE[gi][gj][1], //Eout //Wout
				NtoS_StoN[gi][gj][1], //Nout //Sout
				
				EtoW_WtoE[gi][gj][2], //Eout //Wout
				NtoS_StoN[gi][gj][2], //Nout //Sout
				
				EtoW_WtoE[gi][gj][3], //Eout //Wout
				NtoS_StoN[gi][gj][3] //Nout //Sout
								
		);
		//assign EOUT[8*TILE_DIM*gi+:8*TILE_DIM] = EtoW[gi][ARRAY_DIM-1]; //debug: was EtoW[gi][ARRAY_DIM*TILE_DIM-1]
		//assign WOUT[8*TILE_DIM*gi+:8*TILE_DIM] = WtoE[gi][0];
		//assign SOUT[8*TILE_DIM*gj+:8*TILE_DIM] = StoN[ARRAY_DIM-1][gj]; //debug: was [8*TILE_DIM*gi+:8*TILE_DIM] and StoN[ARRAY_DIM*TILE_DIM-1][gj]
		//assign NOUT[8*TILE_DIM*gj+:8*TILE_DIM] = NtoS[0][gj]; //debug: was NOUT[8*TILE_DIM*gi+:8*TILE_DIM]
		
		assign EOUT[8*TILE_DIM*gi+:8*TILE_DIM] = EtoW_WtoE[gi][ARRAY_DIM-1][3];
		assign WOUT[8*TILE_DIM*gi+:8*TILE_DIM] = EtoW_WtoE[gi][0][0];
		assign SOUT[8*TILE_DIM*gj+:8*TILE_DIM] = NtoS_StoN[ARRAY_DIM-1][gj][3];
		assign NOUT[8*TILE_DIM*gj+:8*TILE_DIM] = NtoS_StoN[0][gj][0];
		
		//assign Eout_Wout_0[8*(gj+(gi*(ARRAY_DIM)))+:8] = EtoW_WtoE[gi][gj][0];
		//assign Nout_Sout_0[8*(gj+(gi*(ARRAY_DIM)))+:8] = NtoS_StoN[gi][gj][0];
		//assign Eout_Wout_1[8*(gj+(gi*(ARRAY_DIM)))+:8] = EtoW_WtoE[gi][gj][1];
		//assign Nout_Sout_1[8*(gj+(gi*(ARRAY_DIM)))+:8] = NtoS_StoN[gi][gj][1];
		//assign Eout_Wout_2[8*(gj+(gi*(ARRAY_DIM)))+:8] = EtoW_WtoE[gi][gj][2];
		//assign Nout_Sout_2[8*(gj+(gi*(ARRAY_DIM)))+:8] = NtoS_StoN[gi][gj][2];
		//assign Eout_Wout_3[8*(gj+(gi*(ARRAY_DIM)))+:8] = EtoW_WtoE[gi][gj][3];
		//assign Nout_Sout_3[8*(gj+(gi*(ARRAY_DIM)))+:8] = NtoS_StoN[gi][gj][3];
		
		/*assign EOUT[8*gi+:8] = (num_shift == 1)? EtoW_WtoE[gi][ARRAY_DIM-1][3] : 
							   (num_shift == 2)? EtoW_WtoE[gi][ARRAY_DIM-1][2]: 
							   (num_shift >= 4)? EtoW_WtoE[gi][ARRAY_DIM-num_shift/4][0]: 8'bz;
							   
		assign WOUT[8*gi+:8] = (num_shift == 1)? EtoW_WtoE[gi][0][0] : 
							   (num_shift == 2)? EtoW_WtoE[gi][0][1]: 
							   (num_shift >= 4)? EtoW_WtoE[gi][num_shift/4-1][3]: 8'bz;
							   
		assign SOUT[8*gj+:8] = (num_shift == 1)? NtoS_StoN[ARRAY_DIM-1][gj][3] : 
							   (num_shift == 2)? NtoS_StoN[ARRAY_DIM-1][gj][2]: 
							   (num_shift >= 4)? NtoS_StoN[ARRAY_DIM-num_shift/4][gj][0]: 8'bz;
							   
		assign NOUT[8*gj+:8] = (num_shift == 1)? NtoS_StoN[0][gj][0] : 
							   (num_shift == 2)? NtoS_StoN[0][gj][1]: 
							   (num_shift >= 4)? NtoS_StoN[num_shift/4-1][gj][3]: 8'bz;*/
	end
  end
  

  
endgenerate

assign DOA = wDOA[Tile_i][Tile_j];
assign DOB = wDOB[Tile_i][Tile_j];


endmodule