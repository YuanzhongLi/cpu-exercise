//
// DC/EX
//

`include "Types.v"

module SecondStage(
  input logic clk,
  input logic rst,

 	input `DataPath inRdDataA,
  input `DataPath inRdDataB,
  input `RegNumPath inWrNum,
  input logic inWrEnable,
  input `ConstantPath inConstant,
  input `OpPath inOp,
  input `ShamtPath inShamt,
  input `FunctPath inFunct,
  input `ALUCodePath inAluCode,
  input `BrCodePath inBrCode,
  input logic inIsLoadInsn,
  input logic inIsStoreInsn,
  input logic inIsALUInConstant,
  input logic inIsSrcA_Rt,
  input logic inPcWrEnable,

  output `DataPath outRdDataA,
  output `DataPath outRdDataB,
  output `RegNumPath outWrNum,
  output logic outWrEnable,
  output `ConstantPath outConstant,
  output `OpPath outOp,
  output `ShamtPath outShamt,
  output `FunctPath outFunct,
  output `ALUCodePath outAluCode,
  output `BrCodePath outBrCode,
  output logic outIsLoadInsn,
  output logic outIsStoreInsn,
  output logic outIsALUInConstant,
  output logic outIsSrcA_Rt,
  output logic outPcWrEnable
);

  always_ff @( posedge clk or negedge rst ) begin
    if ( !rst ) begin
      outRdDataA <= `FALSE;
      outRdDataB <= `FALSE;
      outWrNum <= `FALSE;
      outWrEnable <= `FALSE;
      outConstant <= `FALSE;
      outOp <= `FALSE;
      outShamt <= `FALSE;
      outFunct <= `FALSE;
      outAluCode <= `FALSE;
      outBrCode <= `FALSE;
      outIsLoadInsn <= `FALSE;
      outIsStoreInsn <= `FALSE;
      outIsALUInConstant <= `FALSE;
      outIsSrcA_Rt <= `FALSE;
      outPcWrEnable <= `FALSE;
    end
    else begin
      outRdDataA <= inRdDataA;
      outRdDataB <= inRdDataB;
      outWrNum <= inWrNum;
      outWrEnable <= inWrEnable;
      outConstant <= inConstant;
      outOp <= inOp;
      outShamt <= inShamt;
      outFunct <= inFunct;
      outAluCode <= inAluCode;
      outBrCode <= inBrCode;
      outIsLoadInsn <= inIsLoadInsn;
      outIsStoreInsn <= inIsStoreInsn;
      outIsALUInConstant <= inIsALUInConstant;
      outIsSrcA_Rt <= inIsSrcA_Rt;
      outPcWrEnable <= inPcWrEnable;
    end
  end

endmodule
