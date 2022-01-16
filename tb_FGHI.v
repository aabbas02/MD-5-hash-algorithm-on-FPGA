`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2019 05:08:51 PM
// Design Name: 
// Module Name: tb_FGHI
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


module tb_FGHI(

    );
    
    
    reg reset_n = 0;;
    reg go = 0;
    reg clk = 0;
    reg [31 : 0] M_0;           
    reg [31 : 0] M_1;
    reg [31 : 0] M_2;
    reg [31 : 0] M_3;
    reg [31 : 0] M_4;
    reg [31 : 0] M_5;
    reg [31 : 0] M_6;
    reg [31 : 0] M_7;
    reg [31 : 0] M_8;
    reg [31 : 0] M_9;
    reg [31 : 0] M_10;
    reg [31 : 0] M_11;
    reg [31 : 0] M_12;	
    reg [31 : 0] M_13;					  //32'h80000000 if message is 13 words = 52 bytes long
    reg [31 : 0] M_14;					  //low  order word of length //little endian
    reg [31 : 0] M_15;					  //high order word of length
    
    
    wire [31 : 0] Oword_0;
    wire [31 : 0] Oword_1;
    wire [31 : 0] Oword_2;
    wire [31 : 0] Oword_3;
    wire [127 : 0] output_word;
    
    initial begin
    clk     = 0;
    reset_n = 0;
    go      = 0;
    M_0  =  32'd32817;            
    M_1  =  32'h00000000;
    M_2  =  32'h00000000;
    M_3  =  32'h00000000;
    M_4  =  32'h00000000;
    M_5  =  32'h00000000;
    M_6  =  32'h00000000;
    M_7  =  32'h00000000;
    M_8  =  32'h00000000;
    M_9  =  32'h00000000;
    M_10 =  32'h00000000;
    M_11 =  32'h00000000;
    M_12 =	32'h00000000;
    M_13 =	32'h00000000;				  //32'h80000000 if message is 13 words = 52 bytes long
    M_14 =	32'd8;			  	          //low  order word of length //little endian
    M_15 =	32'h00000000;                 //high order word of length  
    
    #35 reset_n = 1;
    #45 go      = 1;
            end
    
    
 FGHI uut(
    .clk(clk),
    .reset_n(reset_n),
    .go(go),
    .M_0(M_0),           
    .M_1(M_1),
    .M_2(M_2),
    .M_3(M_3),
    .M_4(M_4),
    .M_5(M_5),
    .M_6(M_6),
    .M_7(M_7),
    .M_8(M_8),
    .M_9(M_9),
    .M_10(M_10),
    .M_11(M_11),
    .M_12(M_12),	
    .M_13(M_13),					  //32'h80000000 if message is 13 words = 52 bytes long
    .M_14(M_14),					  //low  order word of length //little endian
    .M_15(M_15),					  //high order word of length  
    .valid(valid),
    .Oword_0(Oword_0),
    .Oword_1(Oword_1),
    .Oword_2(Oword_2),
    .Oword_3(Oword_3)
    );
    always @ (*) begin  
    #5 clk <= ~clk;
                end
    assign output_word = {Oword_3,Oword_2,Oword_1,Oword_0};
    
endmodule
