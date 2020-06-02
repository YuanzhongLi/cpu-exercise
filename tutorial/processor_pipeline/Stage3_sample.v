//
//  ���ߎ��s�ƃA�h���X�����̐��� / �f�[�^�������A�N�Z�X
//

`include "Types.v"

module ThirdStage(
	input logic clk,
	input logic rst,
	input `DataPath inAluOut,
	input `BrCodePath inBrCode,
	input `DataPath dataFromRegister,
	input logic inIsLoadInsn,		// ���[�h���߂��ǂ���
	input logic inIsStoreInsn,		// �X�g�A���߂��ǂ���
	input logic inRgWrEnable,
	input `ConstantPath inConstant,
	input `RegNumPath inWrRg,	// �������݃��W�X�^�ԍ�
	input logic inPcWrEnable,

	output `DataPath wrData,	// �f�[�^�������ɏ������ޓ��e
	output `DataPath outAluOut,
	output `BrCodePath outBrCode,
	output logic outIsLoadInsn,		// ���[�h���߂��ǂ���
	output logic outIsStoreInsn,		// �X�g�A���߂��ǂ���
	output logic outRgWrEnable,
	output `ConstantPath outConstant,
	output `RegNumPath outWrRg,
	output logic outPcWrEnable,

	input logic flush,
	input `DataPath inWrData,

	output `DataPath outWrData
);

	always_ff @( posedge clk or negedge rst ) begin
		if( !rst ) begin
			outAluOut <= `FALSE;
			wrData <= `FALSE;
			outIsLoadInsn <= `FALSE;
			outIsStoreInsn <= `FALSE;
			outRgWrEnable <= `FALSE;
			outWrRg <= `FALSE;
			outBrCode <= `FALSE;
			outConstant <= `FALSE;
			outPcWrEnable <= `FALSE;
			outWrData <= `FALSE;
		end
		else if ( flush ) begin
			outAluOut <= `FALSE;
			wrData <= `FALSE;
			outIsLoadInsn <= `FALSE;
			outIsStoreInsn <= `FALSE;
			outRgWrEnable <= `FALSE;
			outWrRg <= `FALSE;
			outBrCode <= `FALSE;
			outConstant <= `FALSE;
			outPcWrEnable <= `FALSE;
			outWrData <= inWrData;
		end
		else begin
			outAluOut <= inAluOut;
			wrData <= dataFromRegister;
			outIsLoadInsn <= inIsLoadInsn;
			outIsStoreInsn <= inIsStoreInsn;
			outRgWrEnable <= inRgWrEnable;
			outWrRg <= inWrRg;
			outBrCode <= inBrCode;
			outConstant <= inConstant;
			outPcWrEnable <= inPcWrEnable;
			outWrData <= inWrData;
		end
	end

endmodule
