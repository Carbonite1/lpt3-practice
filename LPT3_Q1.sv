module datapath(clk,in,sr,Rn,w,aluop,lt,tsel,bsel,out);
    input clk, w, lt;
    input [7:0] in;
    input [1:0] sr, Rn, aluop;
    input [2:0] bsel, tsel;
    output [7:0] out;

    reg [3:0] decoded_load;
    reg [7:0] R0,R1,R2,R3;
    reg [7:0] rin;
    reg [7:0] tmp;
    reg [7:0] Bin;
    reg [7:0] alu_out;

    //loader 
    loader load_in(.reg_num(Rn), .w(w), .load_out(decoded_load));

    //load_enabler
    load_enabler load_zero (.load_in(decoded_load[0]), .in(rin), .clk(clk), .out(R0));
    load_enabler load_one (.load_in(decoded_load[1]), .in(rin), .clk(clk), .out(R1));
    load_enabler load_two (.load_in(decoded_load[2]), .in(rin), .clk(clk), .out(R2));
    load_enabler load_three (.load_in(decoded_load[3]), .in(rin), .clk(clk), .out(R3));

    //Assigning R0 straight to out
    assign out = R0;

    //ALU
    ALU alu_one (.tmp(tmp),.Bin(Bin),.alu_out(alu_out),.aluop(aluop));


    //bsel MUX
    always_comb begin
        case(bsel)
            3'b001: Bin = R1;
            3'b010: Bin = R2;
            3'b100: Bin = R3;
            default: Bin = 8'bxxxxxxxx;
        endcase
    end

    //tsel MUX
    reg[7:0] tselOut; //Connecting tsel MUX -> lt

    always_comb begin
        case(tsel)
            3'b001: tselOut = alu_out;
            3'b010: tselOut = out;
            3'b100: tselOut = Bin;
            default: tselOut = 8'bxxxxxxxx;
        endcase
    end

    //lt
    load_enabler load_lt (.load_in(lt), .in(tselOut), .clk(clk), .out(tmp));

    //sr MUX
    always_comb begin
        case(sr)
            2'b00: rin = in;
            2'b01: rin = alu_out;
            2'b10: rin = tmp;
            default: rin = 8'bxxxxxxxx;
        endcase
    end


   

    endmodule


    //loader module
    module loader (reg_num, w, load_out); 
        input [1:0] reg_num;
        input w;
        output reg [3:0] load_out;

        always_comb begin 
            if (w==1) begin
                case(reg_num)
                    2'b00: load_out = 4'b0001;
                    2'b01: load_out = 4'b0010;
                    2'b10: load_out = 4'b0100;
                    2'b11: load_out = 4'b1000;
                    default load_out = 4'bxxxx; 
                endcase
            end else begin
                    load_out = 4'b0000; // w = 0, no register is picked
        end
        end
    endmodule


    module ALU (tmp,Bin,alu_out,aluop);
        input [7:0] tmp,Bin;
        input [1:0] aluop; 
        output reg [7:0] alu_out;

        always_comb begin

            case(aluop)

                2'b00: alu_out = tmp ^ Bin;
                2'b01: alu_out = tmp & Bin;
                2'b10: alu_out = tmp << 1;
                2'b11: alu_out = Bin;
                default: alu_out = 8'bxxxxxxxx;       
            endcase

			end
endmodule


module load_enabler (load_in,in,clk,out);

input [7:0] in;
input load_in, clk;
output reg [7:0] out;

always_ff @(posedge clk) begin

    if (load_in)
			out <= in;
end

endmodule

