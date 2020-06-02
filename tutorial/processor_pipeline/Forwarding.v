`include "Types.v"

module Forwarding(
  input `RegNumPath rsNumFromID,
  input `RegNumPath rtNumFromID,

  .wrNumFromEX ( wrNumToEX ),
  .rgWrEnableFromEX ( wrEnableToEX ),

  .wrNumFromMEM ( wrNumToMEM ),
  .rgWrEnableFromMEM ( wrEnableToMEM ),

  .wrNumFromWB ( wrNumToWB ),
  .rgWrEnableFromWB ( wrEnableToWB ),

  .aluInASelect ( aluInASelectFromID ),
  .aluInBSelect ( aluInBSelectFromID )
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
