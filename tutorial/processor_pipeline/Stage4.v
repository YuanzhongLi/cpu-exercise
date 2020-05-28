//
//  命令実行とアドレス生成の制御 / データメモリアクセス
//

`include "Types.v"

module FourthStage(
	input logic clk,
	input logic rst,

	input `DataPath dataFromDMem,
  input `RegNumPath inWrNum,
  input logic inIsLoadInsn,
  input logic wrEnable,
  input `DataPath aluOut,

  output `DataPath outData,
  output `RegNumPath outWrNum,
  output logic regWrite,
  output logic memToReg,
  output `DataPath dataFromEX
);

	always_ff @( posedge clk or negedge rst ) begin
		if( !rst ) begin
			outData <= `FALSE;
			outWrNum <= `FALSE;
			regWrite <= `FALSE;
			memToReg <= `FALSE;
			dataFromEX <= `FALSE;
		end
		else begin
      outData <= dataFromDMem;
			outWrNum <= inWrNum;
			regWrite <= wrEnable;
			memToReg <= inIsLoadInsn;
			dataFromEX <= aluOut;
		end
	end

endmodule
