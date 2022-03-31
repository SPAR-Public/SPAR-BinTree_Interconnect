//(* dont_touch="true" *)

module PE16_Block #(parameter SIZE = 1, parameter MAX_WORD_LENGTH = 32)
	(
		input clk,
		input reset,
		// input[5:0] LENGTH,
		
		//alu control
		input[3:0] alu_op,

		//bram control
		input wea,
		input web,
		input[9:0] addra,
		input[9:0] addrb,
		input[15:0] DINA,
        input[15:0] DINB,
		output[15:0] DOUTA,
        output[15:0] DOUTB,
        input external,

		//other helper signals
		input[7:0] count, //debug: was [6:0]
		// input bram_init_flag,
		// input[15:0]  bram_init_d,
		input[2:0] state, //debug:
		
		//move control
		input east,
		input west,
		input south,
		input north,
		//move data
		input[7:0] Ein_Win_0,
		input[7:0] Nin_Sin_0,
		input[7:0] Ein_Win_1,
		input[7:0] Nin_Sin_1,
		input[7:0] Ein_Win_2,
		input[7:0] Nin_Sin_2,
		input[7:0] Ein_Win_3,
		input[7:0] Nin_Sin_3,
		output[7:0] Eout_Wout_0,
		output[7:0] Nout_Sout_0,
		output[7:0] Eout_Wout_1,
		output[7:0] Nout_Sout_1,		
		output[7:0] Eout_Wout_2,
		output[7:0] Nout_Sout_2,	
		output[7:0] Eout_Wout_3,
		output[7:0] Nout_Sout_3,
		
		input [4:0] num_shift
		
	);

//Bram data
wire[15:0] DIA; 
wire[15:0] DIB;
wire[15:0] DOB;
wire[15:0] DOA;
//move data
wire[15:0] W1, W2;
wire[15:0] E1, E2;
wire[15:0] N1, N2;
wire[15:0] S1, S2;

//alu signals
wire[15:0] alu_out;	
reg[15:0] q1_reg, q0_reg;
wire[15:0] q0;
wire[15:0] q1;

wire[1:0] Q [15:0];

generate 
genvar g;
	for (g=0; g<16; g=g+1) begin
		assign Q[g] = {q1[g],q0[g]};
	end
endgenerate

//booth comparison variable
assign q0 = (state != 2)? q0_reg : 16'hFFFF; //debug: was q0 = state != 2? q0_reg : 16'hFFFF not 4, 5
assign q1 = (state != 2)? q1_reg : 16'h0000; //debug: was q1 = state != 2? q1_reg : 16'h0000

always@(posedge clk) begin
	if(!reset) begin
		q0_reg <= 0;
		q1_reg <= 0;
	end
	else begin
		if(count==2 && state != 2) q1_reg	<= DOB; //debug: was count==2 && state != 2 changed to count==3
		if(count==2 && state != 2) q0_reg	<= q1_reg;  //debug: was count==2 && state != 2 changed to count==3
	end
end

assign E1 = (num_shift == 1) ?
			{	
				DOA[14],DOA[13],DOA[12],Ein_Win_0[0 ],
				DOA[10],DOA[9 ],DOA[8 ],Ein_Win_0[2 ],
				DOA[6 ],DOA[5 ],DOA[4 ],Ein_Win_0[4 ],
				DOA[2 ],DOA[1 ],DOA[0 ],Ein_Win_0[6 ]	
			}
			:(num_shift == 2) ?
			{
				DOA[13],DOA[12],Ein_Win_1[0 ],Ein_Win_0[0 ],
				DOA[9 ],DOA[8 ],Ein_Win_1[2 ],Ein_Win_0[2 ],
				DOA[5 ],DOA[4 ],Ein_Win_1[4 ],Ein_Win_0[4 ],
				DOA[1 ],DOA[0 ],Ein_Win_1[6 ],Ein_Win_0[6 ]	
			}
			:(num_shift >= 4) ?
			{
				Ein_Win_3[0 ],Ein_Win_2[0 ],Ein_Win_1[0 ],Ein_Win_0[0 ],
				Ein_Win_3[2 ],Ein_Win_2[2 ],Ein_Win_1[2 ],Ein_Win_0[2 ],
				Ein_Win_3[4 ],Ein_Win_2[4 ],Ein_Win_1[4 ],Ein_Win_0[4 ],
				Ein_Win_3[6 ],Ein_Win_2[6 ],Ein_Win_1[6 ],Ein_Win_0[6 ]	
			}
			: 15'bz;                          
				                        
assign E2 = (num_shift == 1) ?
			{	                        
				DOB[14],DOB[13],DOB[12],Ein_Win_0[1 ],
				DOB[10],DOB[9 ],DOB[8 ],Ein_Win_0[3 ],
				DOB[6 ],DOB[5 ],DOB[4 ],Ein_Win_0[5 ],
				DOB[2 ],DOB[1 ],DOB[0 ],Ein_Win_0[7 ]	
			}
			:(num_shift == 2) ?
			{	                        
				DOB[13],DOB[12],Ein_Win_1[1 ],Ein_Win_0[1 ],
				DOB[9 ],DOB[8 ],Ein_Win_1[3 ],Ein_Win_0[3 ],
				DOB[5 ],DOB[4 ],Ein_Win_1[5 ],Ein_Win_0[5 ],
				DOB[1 ],DOB[0 ],Ein_Win_1[7 ],Ein_Win_0[7 ]	
			}
			:(num_shift >= 4) ?
			{
				Ein_Win_3[1 ],Ein_Win_2[1 ],Ein_Win_1[1 ],Ein_Win_0[1 ],
				Ein_Win_3[3 ],Ein_Win_2[3 ],Ein_Win_1[3 ],Ein_Win_0[3 ],
				Ein_Win_3[5 ],Ein_Win_2[5 ],Ein_Win_1[5 ],Ein_Win_0[5 ],
				Ein_Win_3[7 ],Ein_Win_2[7 ],Ein_Win_1[7 ],Ein_Win_0[7 ]	
			}
			: 15'bz;
			
assign W1 = (num_shift == 1) ?
			{	
				Ein_Win_3[0 ],DOA[15],DOA[14],DOA[13],
				Ein_Win_3[2 ],DOA[11],DOA[10],DOA[9 ],
				Ein_Win_3[4 ],DOA[7 ],DOA[6 ],DOA[5 ],
				Ein_Win_3[6 ],DOA[3 ],DOA[2 ],DOA[1 ]	
			}
			:(num_shift == 2) ?
			{	
				Ein_Win_3[0 ],Ein_Win_2[0 ],DOA[15],DOA[14],
				Ein_Win_3[2 ],Ein_Win_2[2 ],DOA[11],DOA[10],
				Ein_Win_3[4 ],Ein_Win_2[4 ],DOA[7 ],DOA[6 ],
				Ein_Win_3[6 ],Ein_Win_2[6 ],DOA[3 ],DOA[2 ]	
			}
			:(num_shift >= 4) ?
			{
				Ein_Win_3[0 ],Ein_Win_2[0 ],Ein_Win_1[0 ],Ein_Win_0[0 ],
				Ein_Win_3[2 ],Ein_Win_2[2 ],Ein_Win_1[2 ],Ein_Win_0[2 ],
				Ein_Win_3[4 ],Ein_Win_2[4 ],Ein_Win_1[4 ],Ein_Win_0[4 ],
				Ein_Win_3[6 ],Ein_Win_2[6 ],Ein_Win_1[6 ],Ein_Win_0[6 ]	
			}
			: 15'bz;
			
assign W2 = (num_shift == 1) ?
			{	
				Ein_Win_3[1 ],DOB[15],DOB[14],DOB[13],
				Ein_Win_3[3 ],DOB[11],DOB[10],DOB[9 ],
				Ein_Win_3[5 ],DOB[7 ],DOB[6 ],DOB[5 ],
				Ein_Win_3[7 ],DOB[3 ],DOB[2 ],DOB[1 ]	
			}
			:(num_shift == 2) ?
			{	
				Ein_Win_3[1 ],Ein_Win_2[1 ],DOB[15],DOB[14],
				Ein_Win_3[3 ],Ein_Win_2[3 ],DOB[11],DOB[10],
				Ein_Win_3[5 ],Ein_Win_2[5 ],DOB[7 ],DOB[6 ],
				Ein_Win_3[7 ],Ein_Win_2[7 ],DOB[3 ],DOB[2 ]	
			}
			:(num_shift >= 4) ?
			{
				Ein_Win_3[1 ],Ein_Win_2[1 ],Ein_Win_1[1 ],Ein_Win_0[1 ],
				Ein_Win_3[3 ],Ein_Win_2[3 ],Ein_Win_1[3 ],Ein_Win_0[3 ],
				Ein_Win_3[5 ],Ein_Win_2[5 ],Ein_Win_1[5 ],Ein_Win_0[5 ],
				Ein_Win_3[7 ],Ein_Win_2[7 ],Ein_Win_1[7 ],Ein_Win_0[7 ]	
			}			
			: 15'bz;
			
assign S1 = (num_shift == 1) ?
			{	
				DOA[11],DOA[10],DOA[9 ],DOA[8 ],
				DOA[7 ],DOA[6 ],DOA[5 ],DOA[4 ],
				DOA[3 ],DOA[2 ],DOA[1 ],DOA[0 ],
				Nin_Sin_0[0 ],Nin_Sin_0[2 ],Nin_Sin_0[4 ],Nin_Sin_0[6 ]
			}
			:(num_shift == 2) ?
			{	
				DOA[7 ],DOA[6 ],DOA[5 ],DOA[4 ],
				DOA[3 ],DOA[2 ],DOA[1 ],DOA[0 ],
				Nin_Sin_1[0 ],Nin_Sin_1[2 ],Nin_Sin_1[4 ],Nin_Sin_1[6 ],
				Nin_Sin_0[0 ],Nin_Sin_0[2 ],Nin_Sin_0[4 ],Nin_Sin_0[6 ]
			}
			:(num_shift >= 4) ?
			{	
				Nin_Sin_3[0 ],Nin_Sin_3[2 ],Nin_Sin_3[4 ],Nin_Sin_3[6 ],
				Nin_Sin_2[0 ],Nin_Sin_2[2 ],Nin_Sin_2[4 ],Nin_Sin_2[6 ],
				Nin_Sin_1[0 ],Nin_Sin_1[2 ],Nin_Sin_1[4 ],Nin_Sin_1[6 ],
				Nin_Sin_0[0 ],Nin_Sin_0[2 ],Nin_Sin_0[4 ],Nin_Sin_0[6 ]
			}
			: 15'bz;
			
assign S2 = (num_shift == 1) ?
			{	
				DOB[11],DOB[10],DOB[9 ],DOB[8 ],
				DOB[7 ],DOB[6 ],DOB[5 ],DOB[4 ],
				DOB[3 ],DOB[2 ],DOB[1 ],DOB[0 ],	
				Nin_Sin_0[1 ],Nin_Sin_0[3 ],Nin_Sin_0[5 ],Nin_Sin_0[7 ] 	
			}
			:(num_shift == 2) ?
			{	
				DOB[7 ],DOB[6 ],DOB[5 ],DOB[4 ],
				DOB[3 ],DOB[2 ],DOB[1 ],DOB[0 ],
				Nin_Sin_1[1 ],Nin_Sin_1[3 ],Nin_Sin_1[5 ],Nin_Sin_1[7 ],	
				Nin_Sin_0[1 ],Nin_Sin_0[3 ],Nin_Sin_0[5 ],Nin_Sin_0[7 ] 	
			}
			:(num_shift >= 4) ?
			{	
				Nin_Sin_3[1 ],Nin_Sin_3[3 ],Nin_Sin_3[5 ],Nin_Sin_3[7 ],
				Nin_Sin_2[1 ],Nin_Sin_2[3 ],Nin_Sin_2[5 ],Nin_Sin_2[7 ],
				Nin_Sin_1[1 ],Nin_Sin_1[3 ],Nin_Sin_1[5 ],Nin_Sin_1[7 ],
				Nin_Sin_0[1 ],Nin_Sin_0[3 ],Nin_Sin_0[5 ],Nin_Sin_0[7 ]
			}
			: 15'bz;
			
assign N1 = (num_shift == 1) ?
			{	
				Nin_Sin_3[0 ],Nin_Sin_3[2 ],Nin_Sin_3[4 ],Nin_Sin_3[6 ],
				DOA[15],DOA[14],DOA[13],DOA[12],
				DOA[11],DOA[10],DOA[9 ],DOA[8 ],
				DOA[7 ],DOA[6 ],DOA[5 ],DOA[4 ]	
			}
			:(num_shift == 2) ?
			{	
				Nin_Sin_3[0 ],Nin_Sin_3[2 ],Nin_Sin_3[4 ],Nin_Sin_3[6 ],
				Nin_Sin_2[0 ],Nin_Sin_2[2 ],Nin_Sin_2[4 ],Nin_Sin_2[6 ],
				DOA[15],DOA[14],DOA[13],DOA[12],
				DOA[11],DOA[10],DOA[9 ],DOA[8 ]	
			}
			:(num_shift >= 4) ?
			{	
				Nin_Sin_3[0 ],Nin_Sin_3[2 ],Nin_Sin_3[4 ],Nin_Sin_3[6 ],
				Nin_Sin_2[0 ],Nin_Sin_2[2 ],Nin_Sin_2[4 ],Nin_Sin_2[6 ],
				Nin_Sin_1[0 ],Nin_Sin_1[2 ],Nin_Sin_1[4 ],Nin_Sin_1[6 ],
				Nin_Sin_0[0 ],Nin_Sin_0[2 ],Nin_Sin_0[4 ],Nin_Sin_0[6 ]	
			}
			: 15'bz;
			
assign N2 = (num_shift == 1) ?
			{	
				Nin_Sin_3[1 ],Nin_Sin_3[3 ],Nin_Sin_3[5 ],Nin_Sin_3[7 ],	
				DOB[15],DOB[14],DOB[13],DOB[12],	
				DOB[11],DOB[10],DOB[9 ],DOB[8 ],
				DOB[7 ],DOB[6 ],DOB[5 ],DOB[4 ]	
			}
			:(num_shift == 2) ?
			{	
				Nin_Sin_3[1 ],Nin_Sin_3[3 ],Nin_Sin_3[5 ],Nin_Sin_3[7 ],	
				Nin_Sin_2[1 ],Nin_Sin_2[3 ],Nin_Sin_2[5 ],Nin_Sin_2[7 ],	
				DOB[15],DOB[14],DOB[13],DOB[12],
				DOB[11],DOB[10],DOB[9 ],DOB[8 ]	
			}
			:(num_shift >= 4) ?
			{	
				Nin_Sin_3[1 ],Nin_Sin_3[3 ],Nin_Sin_3[5 ],Nin_Sin_3[7 ],
				Nin_Sin_2[1 ],Nin_Sin_2[3 ],Nin_Sin_2[5 ],Nin_Sin_2[7 ],
				Nin_Sin_1[1 ],Nin_Sin_1[3 ],Nin_Sin_1[5 ],Nin_Sin_1[7 ],
				Nin_Sin_0[1 ],Nin_Sin_0[3 ],Nin_Sin_0[5 ],Nin_Sin_0[7 ]	
			}
			: 15'bz;
		
//assign Wout[0] = {DOB[0] , DOA[0] , DOB[4] , DOA[4] , DOB[8]  , DOA[8]  , DOB[12] , DOA[12]};//{DOA[15] , DOA[11] , DOA[7] , DOA[3] , DOB[15] , DOB[11] , DOB[7] , DOB[3]};
//assign Eout[0] = {DOB[3] , DOA[3] , DOB[7] , DOA[7] , DOB[11] , DOA[11] , DOB[15] , DOA[15]};//{DOA[12] , DOA[8] , DOA[4] , DOA[0] , DOB[12] , DOB[8] , DOB[4] , DOB[0]};
//assign Nout[0] = {DOB[0] , DOA[0] , DOB[1] , DOA[1] , DOB[2]  , DOA[2]  , DOB[3]  , DOA[3] }; //{DOA[15] , DOA[14] , DOA[13] , DOA[12] , DOB[15] , DOB[14] , DOB[13] , DOB[12]}; 
//assign Sout[0] = {DOB[12], DOA[12], DOB[13], DOA[13], DOB[14] , DOA[14] , DOB[15] , DOA[15]}; //{DOA[3] , DOA[2] , DOA[1] , DOA[0] , DOB[3] , DOB[2] , DOB[1] , DOB[0]}; 

assign Eout_Wout_0 = {DOB[0] , DOA[0] , DOB[4] , DOA[4] , DOB[8]  , DOA[8]  , DOB[12] , DOA[12]};
assign Nout_Sout_0 = {DOB[0] , DOA[0] , DOB[1] , DOA[1] , DOB[2]  , DOA[2]  , DOB[3] , DOA[3]};

assign Eout_Wout_1 = {DOB[1] , DOA[1] , DOB[5] , DOA[5] , DOB[9]  , DOA[9]  , DOB[13] , DOA[13]};
assign Nout_Sout_1 = {DOB[4] , DOA[4] , DOB[5] , DOA[5] , DOB[6]  , DOA[6]  , DOB[7] , DOA[7]};

assign Eout_Wout_2 = {DOB[2] , DOA[2] , DOB[6] , DOA[6] , DOB[10]  , DOA[10]  , DOB[14] , DOA[14]};
assign Nout_Sout_2 = {DOB[8] , DOA[8] , DOB[9] , DOA[9] , DOB[10]  , DOA[10]  , DOB[11] , DOA[11]};

assign Eout_Wout_3 = {DOB[3] , DOA[3] , DOB[7] , DOA[7] , DOB[11]  , DOA[11]  , DOB[15] , DOA[15]};
assign Nout_Sout_3 = {DOB[12] , DOA[12] , DOB[13] , DOA[13] , DOB[14]  , DOA[14]  , DOB[15] , DOA[15]};

assign DOUTA = DOA;
assign DOUTB = DOB;

//update
assign DIA = external? DINA : east ? E1 : west ? W1 : south ? S1 : north ? N1 : alu_out ; //: north ? N1 : south ? S1 : 0;
assign DIB = external? DINB : east ? E2 : west ? W2 : south ? S2 : north ? N2 : 16'hzzzz;

//Bram temp data
wire[15:0] DOB_temp;
wire[15:0] DOA_temp;

BRAM regfile
(
	clk,
	reset,
	wea,
	web,
	addra,
	addrb,
	DIA,
	DIB,	
	DOA, //DOA_temp //debug: changed to DOA_temp
	DOB  //DOB_temp //debug: changed to DOB_temp
);

generate
genvar gi;
  for (gi=0; gi<16; gi=gi+1) begin : ALU
	Serialized_ALU #(MAX_WORD_LENGTH) alu 
	(
		clk,  
		reset, 
		alu_out[gi],  
		DOA[gi], 
		DOB[gi],   
		alu_op,		
		count,	
		wea,
		Q[gi]
		// LENGTH
	);
  end
  

endgenerate

/*generate
genvar i;
  for (i=0; i<16; i=i+1) begin : criticalPathBreaker
  FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_DOA (
      .Q(DOA[i]),      // 1-bit Data output
      .C(clk),      // 1-bit Clock input
      .CE(1),    // 1-bit Clock enable input
      .R(!reset),      // 1-bit Synchronous reset input
      .D(DOA_temp[i])       // 1-bit Data input
   );
   
   
   FDRE #(
      .INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
   ) FDRE_DOB (
      .Q(DOB[i]),      // 1-bit Data output
      .C(clk),      // 1-bit Clock input
      .CE(1),    // 1-bit Clock enable input
      .R(!reset),      // 1-bit Synchronous reset input
      .D(DOB_temp[i])       // 1-bit Data input
   );
end
endgenerate*/


endmodule