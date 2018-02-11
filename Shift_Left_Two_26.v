module Shift_Left_Two_26(
    data_i,
    data_o
    );

//I/O ports                    
input [26-1:0] data_i;
output [28-1:0] data_o;


//shift left 2
assign data_o[27:2]=data_i; 
assign data_o[1:0]=2'b00; 
endmodule
