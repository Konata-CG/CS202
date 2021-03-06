`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/27 11:54:44
// Design Name: 
// Module Name: IFetc32
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


module Ifetc32(Instruction,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr,pco);
    // input
    //from ALU
    input[31:0]  Addr_result;   // the calculated address from ALU
    input        Zero;          // while Zero is 1, it means the ALUresult is zero
    
    input[31:0]  Read_data_1;   // the address of instruction used by jr instruction
    input        Branch;
    input        nBranch;
    input        Jmp;
    input        Jal;
    input        Jr;
    input        clock;
    input        reset;     //1'b1 is 'reset' enable, 1'b0 means 'reset' disable. while 'reset' enable, the value of PC is set as 32'h0000_0000

    // output
    output[31:0] Instruction;            
    output[31:0] branch_base_addr;
    output reg[31:0] link_addr;
    output[31:0] pco;      // bind with the new output port 'pco' in IFetc32 
    
    //Calculate PC
    reg[31:0] PC, Next_PC;
    wire branch_ctr;

    assign branch_ctr = (nBranch & (~Zero)) | (Branch & (Zero));
    assign branch_base_addr = PC + 4'b0100;
    assign pco = PC;

    always @(negedge clock, posedge reset)
    begin
        if(reset)
        begin
            PC <= 32'h0000_0000;
        end
        else
        begin
            PC <= ((Jal | Jmp) == 0) ? ((Jr == 0) ? ((branch_ctr == 0 ? (branch_base_addr) : (Addr_result * 4))) : (Read_data_1 * 4)) : ({PC[31:28], Instruction[25:0], 2'b00});
            link_addr = ((Jal | Jmp) == 0) ? link_addr : (PC + 4'b0100) / 4;
        end
    end
    
    prgrom instmem(.clka(clock), .addra(PC/4), .douta(Instruction));

endmodule
