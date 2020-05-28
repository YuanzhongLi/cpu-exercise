//
//  命令実行とアドレス生成の制御 / データメモリアクセス
//

`include "Types.v"

module ThirdStage(
	input logic clk,
	input logic rst,
  input `DataPath inRdDataA,
  input `DataPath inRdDataB,
	input `DataPath inAluOut,
	input `BrCodePath inBrCode,
	input `DataPath dataFromRegister,
	input logic inIsLoadInsn,		// ロード命令かどうか
	input logic inIsStoreInsn,		// ストア命令かどうか
	input logic inRgWrEnable,
	input `ConstantPath inConstat,
	input `RegNumPath inWrRg,	// 書き込みレジスタ番号
	input logic inPcWrEnable,

  output `DataPath outRdDataA,
  output `DataPath outRdDataB,
	output `DataPath wrData,	// データメモリに書き込む内容
	output `DataPath outAluOut,
	output `BrCodePath outBrCode,
	output logic outIsLoadInsn,		// ロード命令かどうか
	output logic outIsStoreInsn,		// ストア命令かどうか
	output logic outRgWrEnable,
	output `ConstantPath outConstat,
	output `RegNumPath outWrRg,
	output logic outPcWrEnable,

	input `DataPath inWrData,

	output `DataPath outWrData
);

	always_ff @( posedge clk or negedge rst ) begin
		if( !rst ) begin
      outRdDataA <= `FALSE;
      outRdDataB <= `FALSE;
			outAluOut <= `FALSE;
			wrData <= `FALSE;
			outIsLoadInsn <= `FALSE;
			outIsStoreInsn <= `FALSE;
			outRgWrEnable <= `FALSE;
			outWrRg <= `FALSE;
			outBrCode <= `FALSE;
			outConstat <= `FALSE;
			outPcWrEnable <= `FALSE;
			outWrData <= `FALSE;
		end
		else begin
      outRdDataA <= inRdDataA;
      outRdDataB <= inRdDataB;
			outAluOut <= inAluOut;
			wrData <= dataFromRegister;
			outIsLoadInsn <= inIsLoadInsn;
			outIsStoreInsn <= inIsStoreInsn;
			outRgWrEnable <= inRgWrEnable;
			outWrRg <= inWrRg;
			outBrCode <= inBrCode;
			outConstat <= inConstat;
			outPcWrEnable <= inPcWrEnable;
			outWrData <= inWrData;
		end
	end

endmodule
