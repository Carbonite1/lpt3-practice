module bitwise(clk, reset, s, op, in, out, done);
    input clk, reset, s;
    input [7:0] in;
    input [3:0] op;
    output [7:0] out;
    output wire done;
    wire [1:0] sr, Rn, aluop;
    wire w, lt;
    wire [2:0] bsel, tsel;
    datapath DP(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);
    // IMPLEMENT YOUR CONTROLLER HERE
    wire [5:0] pState;
    FSM fsm(clk, reset, s, op, done, pState);
    FSMDec fsmDec(pState, Rn, w, sr, tsel, lt, aluop, bsel, op);

endmodule : bitwise

`define State_Wait 6'd0
`define State_Decode 6'd1

`define State_MOV_Ri_in 6'd2

`define State_XOR_1 6'd3
`define State_XOR_2 6'd4
`define State_XOR_3 6'd5

`define State_ASL_1 6'd6
`define State_ASL_2 6'd7
`define State_ASL_3 6'd8
`define State_ASL_4 6'd9

`define State_SWP_1 6'd10
`define State_SWP_2 6'd11
`define State_SWP_3 6'd12


module FSM(clk, reset, s, op, done, pState);
    input clk, reset, s;
    input [3:0] op;
    output reg done;
    reg [5:0] State;
    output [5:0] pState;
    assign pState = State;
    assign done = State == `State_Wait;
    always_ff @(posedge clk) begin
        if(reset) begin
            State <= `State_Wait;
            
        end else if(State == `State_Wait && s) begin
            State <= `State_Decode;
            
        end else if(State == `State_Decode) begin
            casex(op)
                4'b00xx: begin
                    State <= `State_MOV_Ri_in;
                    
                end
                4'b01xx: begin
                    State <= `State_XOR_1;
                    
                end
                4'b10xx: begin 
                    State <= `State_ASL_1;
                    
                end
                4'b11xx: begin
                    State <= `State_SWP_1;
                     
                end
                default: begin 
                    State <= `State_Wait;
                    
                end
            endcase
        end else if(State == `State_MOV_Ri_in) begin 
            State <= `State_Wait;
            
        end else if(State == `State_XOR_1) begin 
            State <= `State_XOR_2;
            
        end else if(State == `State_XOR_2) begin 
            State <= `State_XOR_3;
            
        end else if(State == `State_XOR_3) begin 
            State <= `State_Wait;
            
        end else if (State == `State_ASL_1) begin 
            State <= `State_ASL_2;
            
        end else if (State == `State_ASL_2) begin 
            State <= `State_ASL_3;
            
        end else if (State == `State_ASL_3) begin 
            State <= `State_ASL_4;
            
        end else if(State == `State_ASL_4) begin 
            State <= `State_Wait;
            
        end else if (State == `State_SWP_1) begin 
            State <= `State_SWP_2;
            
        end else if (State == `State_SWP_2) begin 
            State <= `State_SWP_3;
            
        end else if (State == `State_SWP_3) begin 
            State <= `State_Wait;
            
        end else begin
            State <= `State_Wait;
            
        end
    end
endmodule : FSM

module FSMDec(State, Rn, w, sr, tsel, lt, aluop, bsel, op);
    input [5:0] State;
    output reg [1:0] Rn, sr, aluop;
    output reg w, lt;
    output reg [2:0] bsel, tsel;
    input [3:0] op;
    wire [2:0] outBsel;

    dec #(2, 3) d(op[1:0], outBsel);

    always_comb begin 
        case(State)
            `State_MOV_Ri_in: begin
                Rn = op[1:0];
                w = 1'b1;
                sr = 2'b00;
                //dont cares shall be marked with x
                tsel = 3'b001; //x
                lt = 1'b0; //x
                aluop = 2'b11; //x
                bsel = 3'b001; //x
            end
            `State_XOR_1: begin
                Rn = 2'b00;//x
                w = 1'b0;
                sr = 2'b00; //x
                tsel = 3'b100;
                lt = 1'b1;
                aluop = 2'b00; //x
                bsel = 3'b001;
            end
            `State_XOR_2: begin
                Rn = 2'b01;//x
                w = 1'b0;
                sr = 2'b00;//x
                tsel = 3'b001;
                lt = 1'b1;
                aluop = 2'b00;
                bsel = 3'b010;
            end
            `State_XOR_3: begin
                Rn = 2'b00;
                w = 1'b1;
                sr = 2'd2;
                tsel = 3'b001;//x
                lt = 1'b0;
                aluop = 2'b00;//x
                bsel = 3'b010;//x
            end
            `State_ASL_1: begin
                Rn = 2'b00;//x
                w = 1'b0;
                sr = 2'b00;//x
                tsel = 3'b100;
                lt = 1'b1;
                aluop = 2'b01;//x
                bsel = 3'b001;
            end
            `State_ASL_2: begin
                Rn = 2'b01;//x
                w = 1'b0;
                sr = 2'b00; //x
                tsel = 3'b001; 
                lt = 1'b1;
                aluop = 2'b01;
                bsel = 3'b010;
            end
            `State_ASL_3: begin
                Rn = 2'b10;//x
                w = 1'b0; //x
                sr = 2'b00; //x
                tsel = 3'b001;
                lt = 1'b1;
                aluop = 2'b10;
                bsel = 3'b001; //x
            end
            `State_ASL_4: begin
                Rn = 2'b00;
                w = 1'b1;
                sr = 2'd2;
                tsel = 3'b001; //x
                lt = 1'b0; 
                aluop = 2'b10;//x
                bsel = 3'b001; //x
            end
            `State_SWP_1: begin
                Rn = 2'b00;//x
                w = 1'b0; //x
                sr = 2'b00; //x
                tsel = 3'b010; 
                lt = 1'b1;
                aluop = 2'b10; //x
                bsel = 3'b001; //x
            end
            `State_SWP_2: begin
                Rn = 2'b00;
                w = 1'b1;
                sr = 2'd1; 
                tsel = 3'b010; //x
                lt = 1'b0; 
                aluop = 2'b11;
                bsel = outBsel;
            end
            `State_SWP_3: begin
                Rn = op[1:0];
                w = 1'b1;
                sr = 2'd2;
                tsel = 3'b100; //x
                lt = 1'b0; 
                aluop = 2'b11; //x
                bsel = 3'b001; //x
            end
            default: begin
                Rn = 2'b00;
                w = 1'b0;
                sr = 2'b00;
                tsel = 3'b001;
                lt = 1'b0;
                aluop = 2'b11;
                bsel = 3'b001;
            end
        endcase
    end
endmodule : FSMDec

module datapath(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);
	input clk, w, lt;
	input [7:0] in;
	input [1:0] sr, Rn, aluop;
	input [2:0] bsel, tsel;
	output wire [7:0] out;
    wire [7:0] R0, R1, R2, R3, tmp, Bin, rin, alu_out, outFromMuxBtmp;
    wire loadR0, loadR1, loadR2, loadR3;

    assign out = R0;

    loader l0(Rn, w, loadR0, loadR1, loadR2, loadR3);
    //in load clk out
    Reg r0(rin, loadR0, clk, R0);
    Reg r1(rin, loadR1, clk, R1);
    Reg r2(rin, loadR2, clk, R2);
    Reg r3(rin, loadR3, clk, R3);
    Reg tmpReg(outFromMuxBtmp, lt, clk, tmp);

    MUX3aOneHot #(8) muxBtmp(Bin, R1, R2, R3, bsel);
    MUX3aOneHot #(8) muxTtmp(outFromMuxBtmp, alu_out, R0, Bin, tsel);
    MUX3a #(8) muxT(rin, in, alu_out, tmp, sr);

    ALU alu(tmp, Bin, aluop, alu_out);
  
endmodule : datapath

module loader(Rn, w, loadR0, loadR1, loadR2, loadR3);
    input [1:0] Rn;
    input w;
    output loadR0, loadR1, loadR2, loadR3;
    assign loadR0 = (Rn == 2'b00) & w;
    assign loadR1 = (Rn == 2'b01) & w;
    assign loadR2 = (Rn == 2'b10) & w;
    assign loadR3 = (Rn == 2'b11) & w;
endmodule : loader

`define XOR 2'b00
`define ASL 2'b01
`define SHIFT 2'b10
`define IT 2'b11

module ALU(Ain, Bin, ALUop, out);
    input [7:0] Ain, Bin;
    input [1:0] ALUop;
    output reg [7:0] out;
    always_comb begin 
        case(ALUop) 
            `XOR: begin 
                out = Ain ^ Bin; 
            end
            `ASL: begin 
                out = Ain & Bin; 
            end
            `SHIFT: begin 
                out = Ain << 1; 
            end
            `IT: begin 
                out = Bin;
            end
            default: out = {8{1'bx}};
        endcase
    end
endmodule : ALU

module Reg(in, load, clk, out);
  parameter k = 8;
  input [k-1:0] in;
  output wire [k-1:0] out;
  input clk, load;
  wire [k-1:0] outOfMux; 
  vDFF #(k) dff0(.in(outOfMux), .clk(clk), .out(out));
  MUX2a #(k) mux0(.out(outOfMux), .input0(out), .input1(in), .select(load));
endmodule : Reg

module MUX2a(out, input0, input1, select);
  parameter k = 1;
  input [k-1:0] input0, input1;
  output reg [k-1:0] out;
  input select; 
  always_comb begin
    case(select)
      0: out = input0;
      1: out = input1;
      default: out = {k{1'bx}};
    endcase
  end
endmodule : MUX2a

module vDFF(in, clk, out);
  parameter k = 1;
  input [k-1:0] in;
  output reg [k-1:0] out;
  input clk;
  always_ff @(posedge clk) begin 
    out <= in;
  end
endmodule : vDFF

module dec(in, out);
    parameter n = 2; 
    parameter m = 4; 
    input [n-1:0] in; 
    output [m-1:0] out; 
    assign out = 1 << in;
endmodule : dec

module MUX3aOneHot(out, in0, in1, in2, select);
  parameter k = 1;
  input [k-1:0] in0, in1, in2;
  output reg [k-1:0] out;
  input [2:0] select; 
  always_comb begin
    case(select)
      3'b001: out = in0;
      3'b010: out = in1;
      3'b100: out = in2;
      default: out = {k{1'bx}};
    endcase
  end
endmodule : MUX3aOneHot

module MUX3a(out, in0, in1, in2, select);
  parameter k = 1;
  input [k-1:0] in0, in1, in2;
  output reg [k-1:0] out;
  input [1:0] select; 
  always_comb begin
    case(select)
      0: out = in0;
      1: out = in1;
      2: out = in2;
      default: out = {k{1'bx}};
    endcase
  end
endmodule : MUX3a