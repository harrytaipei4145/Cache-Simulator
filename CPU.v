module CPU(
      clk_i,
		rst_i
		);
		
//I/O port
input         clk_i;
input         rst_i;

//Internal Signles
wire clk_i;
wire rst_i;
wire [31:0] pc_in_i,pc_in_i_2;

wire [31:0] pc_out_o;
wire [31:0] instr_o;
wire RegWrite_o;
wire [3:0] ALU_op_o ;
wire ALUSrc_o ; 
wire RegDst_o ;  
wire Branch_o ;
wire [4:0] Mux_Write_Reg_o;
wire Mux_PC_Source_1;
wire [31:0] RSdata_o;
wire [31:0] RTdata_o;
wire [31:0] SE_o;
wire [31:0] Mux_ALUSrc_o;
wire [4:0] ALUCtrl_o;
wire zero_o;
wire [31:0] ALU_o;
wire [31:0] Shifter_o;
wire [31:0] Adder_1_o;
wire [31:0] Adder_2_o;

wire [31:0] readdata_o;
wire Jump_o;
wire MemRead_o;
wire MemWrite_o;
wire [1:0]MemtoReg_o;
wire mux_in3;
wire ALU_o_not;
wire zero_o_not;
wire [31:0]Jump_add;
wire [1:0]Branch_type_o;
wire Mux_4to1_o;
wire[27:0] instr_o_shift2;

wire [31:0]Mux_3to1_o;

ProgramCounter PC(
        .clk_i(clk_i),      
	    .rst_i (rst_i),     
	    .pc_in_i(pc_in_i_2) ,   
	    .pc_out_o(pc_out_o) 
	    );
	
Adder Adder1(
        .src1_i(32'd4),     
	    .src2_i(pc_out_o),     
	    .sum_o(Adder_1_o)    
	    );
	
Instruction_Memory IM(
       .addr_i(pc_out_o),  
	    .instr_o(instr_o)    
	    );

MUX_2to1 #(.size(5)) Mux_Write_Reg(
        .data0_i(instr_o[20:16]),
        .data1_i(instr_o[15:11]),
        .select_i(RegDst_o),
        .data_o(Mux_Write_Reg_o)
        );	
		
Reg_File RF(
        .clk_i(clk_i),      
	     .rst_i(rst_i) ,     
        .RSaddr_i(instr_o[25:21]) ,  
        .RTaddr_i(instr_o[20:16]) ,  
        .RDaddr_i(Mux_Write_Reg_o) ,  
        .RDdata_i(Mux_3to1_o)  , 
        .RegWrite_i (RegWrite_o),
        .RSdata_o(RSdata_o) ,  
        .RTdata_o(RTdata_o)   
        );
	
Decoder Decoder(
       .instr_op_i(instr_o[31:26]), 
	    .RegWrite_o(RegWrite_o), 
	    .ALU_op_o(ALU_op_o),   
	    .ALUSrc_o(ALUSrc_o),   
	    .RegDst_o(RegDst_o),   
		 .Branch_o(Branch_o),
		 .Jump_o(Jump_o),
		 .MemRead_o(MemRead_o),
		 .MemWrite_o(MemWrite_o),
		 .MemtoReg_o(MemtoReg_o),
		 .Branch_type_o(Branch_type_o)
	    );

ALU_Ctrl AC(
        .funct_i(instr_o[5:0]),   
        .ALUOp_i(ALU_op_o),   
        .ALUCtrl_o(ALUCtrl_o) 
        );
	
Sign_Extend SE(
        .data_i(instr_o[15:0]),
        .data_o(SE_o)
        );

MUX_2to1 #(.size(32)) Mux_ALUSrc(
        .data0_i(RTdata_o),
        .data1_i(SE_o),
        .select_i(ALUSrc_o),
        .data_o(Mux_ALUSrc_o)
        );	
		  
		  
		  
		
ALU ALU(
       .src1_i(RSdata_o),
	    .src2_i(Mux_ALUSrc_o),
	    .ctrl_i(ALUCtrl_o),
	    .result_o(ALU_o),
		 .zero_o(zero_o)
	    );
		

Data_Memory DM

(
	.clk_i(clk_i),
	.addr_i(ALU_o),
	.data_i(RTdata_o),
	.MemRead_i(MemRead_o),
	.MemWrite_i(MemWrite_o),
	.data_o(readdata_o)
);


		
MUX_4to1 #(.size(1)) Mux_branch(
        .data0_i(zero_o),
        .data1_i(mux_in3),
		  .data2_i(ALU_o_not),
		  .data3_i(zero_o_not),
        .select_i(Branch_type_o),
        .data_o(Mux_4to1_o)
        );	
		  

assign zero_o_not=~zero_o;
assign ALU_o_not=~ALU_o[31];
assign mux_in3=~(ALU_o[31]|zero_o);
		
MUX_3to1 #(.size(32)) Mux_Write_Data(
        .data0_i(ALU_o),
        .data1_i(readdata_o),
		  .data2_i(SE_o),
        .select_i(MemtoReg_o),
        .data_o(Mux_3to1_o)
        );	
		  
		  
Adder Adder2(
        .src1_i(Adder_1_o),     
	    .src2_i(Shifter_o),     
	    .sum_o(Adder_2_o)      
	    );
		
Shift_Left_Two_32 Shifter(
        .data_i(SE_o),
        .data_o(Shifter_o)
        ); 		
		  
Shift_Left_Two_26 Shifter2(
        .data_i(instr_o[25:0]),
        .data_o(instr_o_shift2)
        ); 		
		  
MUX_2to1 #(.size(32)) Mux_PC_Source(
        .data0_i(Adder_1_o),
        .data1_i(Adder_2_o),
        .select_i(Mux_PC_Source_1),
        .data_o(pc_in_i)
        );	
		  
MUX_2to1 #(.size(32)) Mux_PC_Source2(
        .data0_i(Jump_add),
        .data1_i(pc_in_i),
        .select_i(Jump_o),
        .data_o(pc_in_i_2)
        );			  
		  
assign Jump_add[27:0]=instr_o_shift2;
assign Jump_add[31:28]=Adder_1_o[31:28];

and AND_1(Mux_PC_Source_1,Branch_o,Mux_4to1_o);
endmodule


