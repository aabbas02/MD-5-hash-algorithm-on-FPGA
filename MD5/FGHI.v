`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2019 07:51:36 PM
// Design Name: 
// Module Name: FGHI
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
// Engineer: Ahmed Alia Abbasi
// Target Devices: Xilinx/Altera FPGA
// Description: This verilog file is a standalone implementation of the MD5 hash algorithm.
// The syntehsis was tested on Vivado 2018; the hash values were tested with a separate test bench (also included in the repo)
// The 512-bit input string is input to the registers M_0,...M_15 in Big-endian order.
//////////////////////////////////////////////////////////////////////////////////


module FGHI(
    input clk,
    input reset_n,
    input go,
    input [31 : 0] M_0,           
    input [31 : 0] M_1,
    input [31 : 0] M_2,
    input [31 : 0] M_3,
    input [31 : 0] M_4,
    input [31 : 0] M_5,
    input [31 : 0] M_6,
    input [31 : 0] M_7,
    input [31 : 0] M_8,
    input [31 : 0] M_9,
    input [31 : 0] M_10,
    input [31 : 0] M_11,
    input [31 : 0] M_12,	
    input [31 : 0] M_13,					  
    input [31 : 0] M_14,					  //low  order word of length //little endian
    input [31 : 0] M_15,					  //high order word of length  
    output reg valid,
    output reg [31 : 0] Oword_0,
    output reg [31 : 0] Oword_1,
    output reg [31 : 0] Oword_2,
    output reg [31 : 0] Oword_3
    );

reg [3 : 0]  state_machine = 4'b0000;       //state-machine


reg [31 : 0] AA = 32'h01234567;             //starting values
reg [31 : 0] BB = 32'h89abcdef;
reg [31 : 0] CC = 32'hfedcba98;
reg [31 : 0] DD = 32'h76543210;


reg [31 : 0] A = 32'h01234567;			    //updated after each operation
reg [31 : 0] B = 32'h89abcdef;
reg [31 : 0] C = 32'hfedcba98;
reg [31 : 0] D = 32'h76543210;



reg [31 : 0] X_0;
reg [31 : 0] X_1;
reg [31 : 0] X_2;
reg [31 : 0] X_3;
reg [31 : 0] X_4;
reg [31 : 0] X_5;
reg [31 : 0] X_6;
reg [31 : 0] X_7;
reg [31 : 0] X_8;
reg [31 : 0] X_9;
reg [31 : 0] X_10;
reg [31 : 0] X_11;
reg [31 : 0] X_12;
reg [31 : 0] X_13;
reg [31 : 0] X_14;
reg [31 : 0] X_15;
                                             //operational arguments for example F(b,c,d) b = second c = third d = fourth
reg [31 : 0] first_argument  = 32'h01234567; //doesn't matter instantiating them like this; but good for synthesis   
reg [31 : 0] second_argument = 32'h89abcdef;
reg [31 : 0] third_argument  = 32'hfedcba98;
reg [31 : 0] fourth_argument = 32'h76543210;
reg [4 : 0]  s = 5'b00100;                  //left shift
reg [3 : 0]  k = 4'b0000;                   //message chunk (M_k) look up
reg [31 : 0] X_k;                           //output of X mux ---combinational (select line reg [3 : 0] k)
reg [31 : 0] T_i;                           //output of T mux ---combinational (select line {round_counter[1 : 0],argument_counter [3 : 0]} )
reg [31 : 0] shift_s;                       //circular shift left plus_T (register) by s units --- combinational (select line reg [4 : 0] s)



                                            //F,G,H,I outputs
reg [31 : 0] F;
reg [31 : 0] G;
reg [31 : 0] H;
reg [31 : 0] I;
reg [31 : 0] op_result;                     //mux output of F,G,H,I
reg [31 : 0] plus_first_arg;                //plus_first_arg = op_result + first_argument
reg [31 : 0] plus_X;                        //plus_X = plus_first_arg + X[k]
reg [31 : 0] plus_T;                        //plux_T = plus_X + plus_X;
reg [31 : 0] lhs;                           //lhs = shift_s + second_argument - one of 16 opearations for each round ends                 
                     


reg [3 : 0]  argument_counter = 4'b0000;    //2 lsbs [1 : 0]
                                            //sets first_argument....before each operation
                                            //sets A or D or C or B equal to  lhs after each operation
                                            //sets k,i as function of both round counter and arugment counter ---
                                            //[3 : 0] == 4'b1111, increment round counter
                                            
reg [1 : 0]  round_counter    = 2'b00;      //00 = F 01 = G 10 = H 11 = I // also used in setting k,i with argument counter
                                            //sets s
                                            


//Combinational Logic - Muxes

always @ (*) begin
//Message Chunk Look up
case (k) 
4'd0  : X_k <=  X_0;
4'd1  : X_k <=  X_1;
4'd2  : X_k <=  X_2;
4'd3  : X_k <=  X_3;
4'd4  : X_k <=  X_4;
4'd5  : X_k <=  X_5;
4'd6  : X_k <=  X_6;
4'd7  : X_k <=  X_7;
4'd8  : X_k <=  X_8;
4'd9  : X_k <=  X_9;
4'd10 : X_k <=  X_10;
4'd11 : X_k <=  X_11;
4'd12 : X_k <=  X_12;
4'd13 : X_k <=  X_13;
4'd14 : X_k <=  X_14;
4'd15 : X_k <=  X_15;
endcase 
//Sine Look up
case({round_counter[1 : 0],argument_counter [3 : 0]})
6'd0   :   T_i <=      32'hd76aa478;                             
6'd1   :   T_i <=      32'he8c7b756;
6'd2   :   T_i <=      32'h242070db;
6'd3   :   T_i <=      32'hc1bdceee;
6'd4   :   T_i <=      32'hf57c0faf;
6'd5   :   T_i <=      32'h4787c62a;
6'd6   :   T_i <=      32'ha8304613;
6'd7   :   T_i <=      32'hfd469501;     
6'd8   :   T_i <=      32'h698098d8;
6'd9   :   T_i <=      32'h8b44f7af;
6'd10  :   T_i <=      32'hffff5bb1;
6'd11  :   T_i <=      32'h895cd7be;
6'd12  :   T_i <=      32'h6b901122;
6'd13  :   T_i <=      32'hfd987193;
6'd14  :   T_i <=      32'ha679438e;
6'd15  :   T_i <=      32'h49b40821;
//Round F ends
6'd16  :   T_i <=      32'hf61e2562;
6'd17  :   T_i <=      32'hc040b340;
6'd18  :   T_i <=      32'h265e5a51;
6'd19  :   T_i <=      32'he9b6c7aa;
6'd20  :   T_i <=      32'hd62f105d;
6'd21  :   T_i <=      32'h2441453 ;
6'd22  :   T_i <=      32'hd8a1e681;
6'd23  :   T_i <=      32'he7d3fbc8;
6'd24  :   T_i <=      32'h21e1cde6;
6'd25  :   T_i <=      32'hc33707d6;
6'd26  :   T_i <=      32'hf4d50d87;
6'd27  :   T_i <=      32'h455a14ed;
6'd28  :   T_i <=      32'ha9e3e905;
6'd29  :   T_i <=      32'hfcefa3f8;
6'd30  :   T_i <=      32'h676f02d9;
6'd31  :   T_i <=      32'h8d2a4c8a;
//Round G ends
6'd32  :   T_i <=      32'hfffa3942;
6'd33  :   T_i <=      32'h8771f681;
6'd34  :   T_i <=      32'h6d9d6122;
6'd35  :   T_i <=      32'hfde5380c;
6'd36  :   T_i <=      32'ha4beea44;
6'd37  :   T_i <=      32'h4bdecfa9;
6'd38  :   T_i <=      32'hf6bb4b60;
6'd39  :   T_i <=      32'hbebfbc70;
6'd40  :   T_i <=      32'h289b7ec6;
6'd41  :   T_i <=      32'heaa127fa;
6'd42  :   T_i <=      32'hd4ef3085;
6'd43  :   T_i <=      32'h4881d05 ;
6'd44  :   T_i <=      32'hd9d4d039;
6'd45  :   T_i <=      32'he6db99e5;
6'd46  :   T_i <=      32'h1fa27cf8;
6'd47  :   T_i <=      32'hc4ac5665;
//Round H ends
6'd48  :   T_i <=      32'hf4292244;
6'd49  :   T_i <=      32'h432aff97;
6'd50  :   T_i <=      32'hab9423a7;
6'd51  :   T_i <=      32'hfc93a039;
6'd52  :   T_i <=      32'h655b59c3;
6'd53  :   T_i <=      32'h8f0ccc92;
6'd54  :   T_i <=      32'hffeff47d;
6'd55  :   T_i <=      32'h85845dd1;
6'd56  :   T_i <=      32'h6fa87e4f;
6'd57  :   T_i <=      32'hfe2ce6e0;
6'd58  :   T_i <=      32'ha3014314;
6'd59  :   T_i <=      32'h4e0811a1;
6'd60  :   T_i <=      32'hf7537e82;
6'd61  :   T_i <=      32'hbd3af235;
6'd62  :   T_i <=      32'h2ad7d2bb;
6'd63  :   T_i <=      32'heb86d391;
endcase                          
//Shift
case(s)                                                            //Could save a bit by offsetting by 4
5'd4    : begin shift_s <= {plus_T[27 : 0],plus_T[31 : 28]}; end
5'd5    : begin shift_s <= {plus_T[26 : 0],plus_T[31 : 27]}; end
5'd6    : begin shift_s <= {plus_T[25 : 0],plus_T[31 : 26]}; end
5'd7    : begin shift_s <= {plus_T[24 : 0],plus_T[31 : 25]}; end
5'd8    : begin shift_s <= {plus_T[23 : 0],plus_T[31 : 24]}; end
5'd9    : begin shift_s <= {plus_T[22 : 0],plus_T[31 : 23]}; end
5'd10   : begin shift_s <= {plus_T[21 : 0],plus_T[31 : 22]}; end
5'd11   : begin shift_s <= {plus_T[20 : 0],plus_T[31 : 21]}; end
5'd12   : begin shift_s <= {plus_T[19 : 0],plus_T[31 : 20]}; end
5'd13   : begin shift_s <= {plus_T[18 : 0],plus_T[31 : 19]}; end
5'd14   : begin shift_s <= {plus_T[17 : 0],plus_T[31 : 18]}; end
5'd15   : begin shift_s <= {plus_T[16 : 0],plus_T[31 : 17]}; end
5'd16   : begin shift_s <= {plus_T[15 : 0],plus_T[31 : 16]}; end
5'd17   : begin shift_s <= {plus_T[14 : 0],plus_T[31 : 15]}; end
5'd18   : begin shift_s <= {plus_T[13 : 0],plus_T[31 : 14]}; end
5'd19   : begin shift_s <= {plus_T[12 : 0],plus_T[31 : 13]}; end
5'd20   : begin shift_s <= {plus_T[11 : 0],plus_T[31 : 12]}; end
5'd21   : begin shift_s <= {plus_T[10 : 0],plus_T[31 : 11]}; end
5'd22   : begin shift_s <= {plus_T[9  : 0],plus_T[31 : 10]}; end
5'd23   : begin shift_s <= {plus_T[8  : 0],plus_T[31 : 09]}; end   //Use default statemnt-otherwise latch
default : begin shift_s <= plus_T;                           end
endcase

F <= ( second_argument & third_argument )   | ( (~second_argument) & fourth_argument );
G <= ( second_argument & fourth_argument )  | ( third_argument & (~fourth_argument)  );
H <= ( second_argument ) 				    ^ ( third_argument ^ fourth_argument     );
I <= ( third_argument  ) 				    ^ ( second_argument | (~fourth_argument) );

case(round_counter)
2'b00 : begin op_result <= F; end
2'b01 : begin op_result <= G; end
2'b10 : begin op_result <= H; end
2'b11 : begin op_result <= I; end
endcase
             end



//Sequential Logic starts here
always @ (posedge clk) begin
if(!reset_n) begin
             state_machine    <= 0;
			 round_counter 	  <= 0; 
			 argument_counter <= 0;
	//		 AA <= 32'h01234567;             //starting values
	//		 BB <= 32'h89abcdef;
	//		 CC <= 32'hfedcba98;
	//		 DD <= 32'h76543210;
			 
	//		 A <= 32'h01234567;			    //updated after each operation
	//		 B <= 32'h89abcdef;
	//		 C <= 32'hfedcba98;
	//		 D <= 32'h76543210;
	         //reverse endianness
	         AA <= 32'h67452301;
	         BB <= 32'hefcdab89;
	         CC <= 32'h98badcfe;
	         DD <= 32'h10325476;


	         A <= 32'h67452301;
	         B <= 32'hefcdab89;
	         C <= 32'h98badcfe;
	         D <= 32'h10325476;
			 
			 valid <= 0;
             end
else begin
case(state_machine) 
    4'b0000 : begin                                 //wait for go signal
			  if(go) begin
			  X_0  <=  M_0;
			  X_1  <=  M_1;
			  X_2  <=  M_2;
			  X_3  <=  M_3;
			  X_4  <=  M_4;
			  X_5  <=  M_5;
			  X_6  <=  M_6;
			  X_7  <=  M_7;
			  X_8  <=  M_8;
			  X_9  <=  M_9;
			  X_10 <=  M_10;
			  X_11 <=  M_11;
			  X_12 <=  M_12;
			  X_13 <=  M_13;
			  X_14 <=  M_14;
			  X_15 <=  M_15;
			  state_machine <= 4'b0001;
					 end                   
              end
                               
    4'b0001 : begin     
                    case ( {round_counter[1 : 0],argument_counter [3 : 0]}) 
                    6'd0  : begin k <= 0;   s <= 7;  end
                    6'd1  : begin k <= 1;   s <= 12; end
                    6'd2  : begin k <= 2;   s <= 17; end
                    6'd3  : begin k <= 3;   s <= 22; end
                    6'd4  : begin k <= 4;   s <= 7;  end
                    6'd5  : begin k <= 5;   s <= 12; end
                    6'd6  : begin k <= 6;   s <= 17; end
                    6'd7  : begin k <= 7;   s <= 22; end
                    6'd8  : begin k <= 8;   s <= 7;  end
                    6'd9  : begin k <= 9;   s <= 12; end
                    6'd10 : begin k <= 10;  s <= 17; end
                    6'd11 : begin k <= 11;  s <= 22; end
                    6'd12 : begin k <= 12;  s <= 7;  end
                    6'd13 : begin k <= 13;  s <= 12; end
                    6'd14 : begin k <= 14;  s <= 17; end
                    6'd15 : begin k <= 15;  s <= 22; end  
                    //Round F ends
                    6'd16 : begin k <= 1;   s <= 5;  end
                    6'd17 : begin k <= 6;   s <= 9;  end
                    6'd18 : begin k <= 11;  s <= 14; end
                    6'd19 : begin k <= 0;   s <= 20; end
                    6'd20 : begin k <= 5;   s <= 5;  end
                    6'd21 : begin k <= 10;  s <= 9;  end
                    6'd22 : begin k <= 15;  s <= 14; end
                    6'd23 : begin k <= 4;   s <= 20; end
                    6'd24 : begin k <= 9;   s <= 5;  end
                    6'd25 : begin k <= 14;  s <= 9;  end
                    6'd26 : begin k <= 3;   s <= 14; end
                    6'd27 : begin k <= 8;   s <= 20; end
                    6'd28 : begin k <= 13;  s <= 5;  end
                    6'd29 : begin k <= 2;   s <= 9; end
                    6'd30 : begin k <= 7;   s <= 14; end
                    6'd31 : begin k <= 12;  s <= 20; end
                    //Round G ends
                    6'd32 : begin k <= 5;   s <= 4;  end
                    6'd33 : begin k <= 8;   s <= 11; end
                    6'd34 : begin k <= 11;  s <= 16; end
                    6'd35 : begin k <= 14;  s <= 23; end
                    6'd36 : begin k <= 1;   s <= 4;  end
                    6'd37 : begin k <= 4;   s <= 11; end
                    6'd38 : begin k <= 7;   s <= 16; end
                    6'd39 : begin k <= 10;  s <= 23; end
                    6'd40 : begin k <= 13;  s <= 4;  end
                    6'd41 : begin k <= 0;   s <= 11; end
                    6'd42 : begin k <= 3;   s <= 16; end
                    6'd43 : begin k <= 6;   s <= 23; end
                    6'd44 : begin k <= 9;   s <= 4;  end
                    6'd45 : begin k <= 12;  s <= 11; end
                    6'd46 : begin k <= 15;  s <= 16; end
                    6'd47 : begin k <= 2;   s <= 23; end
                    //...Round H ends
                    6'd48 : begin k <= 0;   s <= 6;  end
                    6'd49 : begin k <= 7;   s <= 10; end
                    6'd50 : begin k <= 14;  s <= 15; end
                    6'd51 : begin k <= 5;   s <= 21; end
                    6'd52 : begin k <= 12;  s <= 6;  end
                    6'd53 : begin k <= 3;   s <= 10; end
                    6'd54 : begin k <= 10;  s <= 15; end
                    6'd55 : begin k <= 1;   s <= 21; end
                    6'd56 : begin k <= 8;   s <= 6;  end
                    6'd57 : begin k <= 15;  s <= 10; end
                    6'd58 : begin k <= 6;   s <= 15; end
                    6'd59 : begin k <= 13;  s <= 21; end
                    6'd60 : begin k <= 4;   s <= 6;  end
                    6'd61 : begin k <= 11;  s <= 10; end
                    6'd62 : begin k <= 2;   s <= 15; end
                    6'd63 : begin k <= 9;   s <= 21; end
                    endcase
                    case (argument_counter[1 : 0])
                    2'b00 : begin first_argument <= A; second_argument <= B; third_argument <= C; fourth_argument <= D; end
                    2'b01 : begin first_argument <= D; second_argument <= A; third_argument <= B; fourth_argument <= C; end
                    2'b10 : begin first_argument <= C; second_argument <= D; third_argument <= A; fourth_argument <= B; end
                    2'b11 : begin first_argument <= B; second_argument <= C; third_argument <= D; fourth_argument <= A; end               
                    endcase 
                    state_machine  <= 4'b0010;
              end                
    4'b0010 : begin																
					plus_first_arg <=  first_argument +  op_result;
					state_machine <= 4'b0011;
			  end
    4'b0011 : begin
					plus_X <= plus_first_arg + X_k;
					state_machine <= 4'b0100;
			  end 
    4'b0100 : begin 
					plus_T <= plus_X + T_i;
					state_machine <= 4'b0101;
			  end
	4'b0101 : begin
					lhs    	      <= shift_s + second_argument;
					state_machine <= 4'b0110; 
			  end
	4'b0110 : begin
              case (argument_counter[1 : 0])  		//set A or D or C or B equal to lhs where lhs = function of (first....fourth argument and k,s,i)
                    2'b00 : begin A <= lhs; end
                    2'b01 : begin D <= lhs; end
                    2'b10 : begin C <= lhs; end
                    2'b11 : begin B <= lhs; end
              endcase
				    state_machine <= 4'b0111;
			  end
    4'b0111 : begin                                                       
              argument_counter <= argument_counter + 1;
              round_counter    <= (argument_counter == 4'b1111)? round_counter + 1 : round_counter;
		      state_machine    <= (argument_counter == 4'b1111 && round_counter == 2'b11)? 4'b1000 : 4'b0001;   
              end
	4'b1000 : begin
			  AA <= AA + A;
			  BB <= BB + B;
			  CC <= CC + C;
			  DD <= DD + D;
			  state_machine    <= 4'b1001;
			  end
	4'b1001 : begin 
			  Oword_0 		   <=  AA;
			  Oword_1          <=  BB;
			  Oword_2          <=  CC;
			  Oword_3 		   <=  DD;
			  valid            <= 1'b1;		                                //stay here forever
			  end
               
endcase 
     end
                       end

endmodule

