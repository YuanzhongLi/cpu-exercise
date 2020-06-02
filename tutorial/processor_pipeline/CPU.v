`include "Types.v"

module CPU(

	input logic clk,	// クロック
	input logic rst,	// リセット

	output `InsnAddrPath insnAddr,		// 命令メモリへのアドレス出力
	output `DataAddrPath dataAddr,		// データバスへのアドレス出力
	output `DataPath     dataOut,		// 書き込みデータ出力
										// dataAddr で指定したアドレスに対して書き込む値を出力する．
	output logic         dataWrEnable,	// データ書き込み有効

	input  `InsnPath 	 	 insn,			// 命令メモリからの入力
	input  `DataPath     dataIn			// 読み出しデータ入力
										// dataAddr で指定したアドレスから読んだ値が入力される．
);
	// PC
	`InsnAddrPath pcOut;		// アドレス出力
	`InsnAddrPath pcIn;			// 外部書き込みをする時のアドレス
	logic pcWrEnable;

	// IMem
	`InsnPath imemInsnCode; // 命令コード

	// Decoder
	`OpPath dcOp;				// OP フィールド
	`RegNumPath dcRS;			// RS フィールド
	`RegNumPath dcRT;			// RT フィールド
	`RegNumPath dcRD;			// RD フィールド
	`ShamtPath dcShamt;			// SHAMT フィールド
	`FunctPath dcFunct;			// FUNCT フィールド
	`ConstantPath dcConstant;	// CONSTANT フィールド

	// Controll
	`ALUCodePath dcALUCode;		// ALU の制御コード
	`BrCodePath dcBrCode;		// ブランチの制御コード
	logic dcIsSrcA_Rt;			// ソースの1個目が Rt かどうか
	logic dcIsDstRt;			// ディスティネーションがRtかどうか
	logic dcIsALUInConstant;	// ALU の入力が Constant かどうか
	logic dcIsLoadInsn;			// ロード命令かどうか
	logic dcIsStoreInsn;		// ストア命令かどうか

	// レジスタ・ファイル
	`DataPath rfRdDataS;		// 読み出しデータ rs
	`DataPath rfRdDataT;		// 読み出しデータ rt
	`DataPath   rfWrData;		// 書き込みデータ
	`RegNumPath rfWrNum;		// 書き込み番号
	logic       rfWrEnable;		// 書き込み制御 1の場合，書き込みを行う

	// ALU
	`DataPath aluOut;			// ALU 出力
	`DataPath aluInA;			// ALU 入力A
	`DataPath aluInB;			// ALU 入力B

	// Forwarding
	// `ForwardCodePath aluInASelectFromID;
	// `ForwardCodePath aluInBSelectFromID;
	// `ForwardCodePath aluInASelectToEX;
	// `ForwardCodePath aluInBSelectToEX;
	`DataPath dataFromWB;

	// Pipeline

	// IFsatge
	`InsnPath insnToDecoder;

	// IDstage

	// EXstage
	`DataPath rdDataAToEX;
	`DataPath rdDataBToEX;
	`DataPath aluInAFromID;			// ALU 入力A
	`DataPath aluInBFromID;			// ALU 入力B
	`OpPath opToEX;

	`ShamtPath shamtToEX;			// SHAMT フィールド
	`FunctPath functToEX;			// FUNCT フィールド
	`ConstantPath constantToEX;	// CONSTANT フィールド

	`ALUCodePath aluCodeToEX;		// ALU の制御コード
	`BrCodePath brCodeToEX;		// ブランチの制御コード
	logic isSrcA_RtToEX;			// ソースの1個目が Rt かどうか
	logic isALUInConstantToEX;	// ALU の入力が Constant かどうか
	logic isLoadInsnToEX;			// ロード命令かどうか
	logic isStoreInsnToEX;		// ストア命令かどうか
	logic pcWrEnableToEX;
	logic wrEnableToEX;
	`RegNumPath wrNumToEX;


	// MEMstage
	`DataPath rdDataAToMEM;
	`DataPath rdDataBToMEM;
	`DataPath aluOutToMEM;
	`BrCodePath brCodeToMEM;
	`ConstantPath constantToMEM;
	`DataPath dataToDMem;
	logic isLoadInsnToMEM;			// ロード命令かどうか
	logic isStoreInsnToMEM;		// ストア命令かどうか
	logic wrEnableToMEM;
	`RegNumPath wrNumToMEM;
	logic pcWrEnableToMEM;
	`DataPath dataFromDMem;
	logic pcWrEnableToIF;

	// WBstage
	`DataPath wrDataToWB;
	`RegNumPath wrNumToWB;
	`DataPath aluOutToWB;
	logic wrEnableToWB;
	logic isLoadInsnToWB;

	PC pc (
		.clk( clk ), // in
		.rst( rst ), // in

		.addrOut( pcOut ), // out

		.addrIn( pcIn ), // in: 外部書き込みのアドレス
		.wrEnable( pcWrEnableToIF ) // in
	);

	// Branch Unit
	BranchUnit branch(
		.pcOut( pcIn ),	// out: BranchUnit への入力は in と out が逆になるのを注意

		.pcIn( pcOut ), // in
		.brCode( brCodeToMEM ), // in
		.regRS( rdDataAToMEM ), // in
		.regRT( rdDataBToMEM ), // in
		.constant( constantToMEM ), // in

		.outPcWrEnable( pcWrEnableToIF ) // out
	);

	// Decoder
	Decoder decoder(
		.op( dcOp ), // out
		.rs( dcRS ), // out
		.rt( dcRT ), // out
		.rd( dcRD ), // out
		.shamt( dcShamt ), // out
		.funct( dcFunct ), // out
		.constant( dcConstant ), // out
		.aluCode( dcALUCode ), // out
		.brCode( dcBrCode ), // out
		.pcWrEnable( pcWrEnable ), // out: PC 書き込みを行うかどうか
		.isLoadInsn( dcIsLoadInsn ),	// out: ロード命令かどうか
		.isStoreInsn( dcIsStoreInsn ),	// out: ストア命令かどうか
		.isSrcA_Rt( dcIsSrcA_Rt ), // out: ソースの1個目が Rt かどうか
		.isDstRt( dcIsDstRt ),	// out: ディスティネーションがRtかどうか
		.rfWrEnable( rfWrEnable ),	// out: ディスティネーション書き込みを行うかどうか
		.isALUInConstant( dcIsALUInConstant ),	// out :ALU の入力が Constant かどうか

		.insn( insnToDecoder ) // in
	);

	RegisterFile regFile(
		.clk( clk ), // in

		.rdDataA( rfRdDataS ), // out
		.rdDataB( rfRdDataT ), // out

		.rdNumA( dcRS ), // in
		.rdNumB( dcRT ), // in

		.wrData( rfWrData ), // in
		.wrNum( wrNumToWB ), // in
		.wrEnable( wrEnableToWB ) // in
	);

	ALU alu (
		.aluOut( aluOut ), // out

		.aluInA( aluInA ), // in
		.aluInB( aluInB ), // in
		.code( aluCodeToEX ) // in
	);

	FirstStage firstStage(
		.clk (clk), // in
		.rst (rst), // in
		.insnFromIMem (imemInsnCode), // in

		.insnToDecoder (insnToDecoder) //	out
	);

	SecondStage secondStage(
		.clk ( clk ),
		.rst ( rst ),
		.inRdDataA ( rfRdDataS ),
		.inRdDataB ( rfRdDataT ),
		.inWrNum ( rfWrNum ),
		.inWrEnable ( rfWrEnable ),
		.inConstant ( dcConstant ),
		.inOp ( dcOp ),
		.inShamt ( dcShamt ),
		.inFunct ( dcFunct ),
		.inAluCode ( dcALUCode ),
		.inBrCode ( dcBrCode ),
		.inIsLoadInsn ( dcIsLoadInsn ),
		.inIsStoreInsn ( dcIsStoreInsn ),
		.inIsALUInConstant ( dcIsALUInConstant ),
		.inIsSrcA_Rt ( dcIsSrcA_Rt ),
		.inPcWrEnable ( pcWrEnable ),

		.outRdDataA ( rdDataAToEX ),
		.outRdDataB ( rdDataBToEX ),
		.outWrNum ( wrNumToEX ),
		.outWrEnable ( wrEnableToEX ),
		.outConstant ( constantToEX ),
		.outOp ( opToEX ),
		.outShamt ( shamtToEX ),
		.outFunct ( functToEX ),
		.outAluCode ( aluCodeToEX ),
		.outBrCode ( brCodeToEX ),
		.outIsLoadInsn ( isLoadInsnToEX ),
		.outIsStoreInsn ( isStoreInsnToEX ),
		.outIsALUInConstant ( isALUInConstantToEX ),
		.outIsSrcA_Rt ( isSrcA_RtToEX ),
		.outPcWrEnable ( pcWrEnableToEX )
	);

	ThirdStage thirdStage(
		.clk ( clk ),
		.rst ( rst ),

		.inRdDataA( rdDataAToEX ),
		.inRdDataB( rdDataBToEX ),
		.inAluOut ( aluOut ),
		.inBrCode ( brCodeToEX ),
		.dataFromRegister ( aluInA ),
		.inIsLoadInsn ( isLoadInsnToEX ),
		.inIsStoreInsn ( isStoreInsnToEX ),
		.inRgWrEnable ( wrEnableToEX ),
		.inConstant ( constantToEX ),
		.inWrRg ( wrNumToEX ),
		.inPcWrEnable ( pcWrEnableToEX ),

		.outRdDataA( rdDataAToMEM ),
		.outRdDataB( rdDataBToMEM ),
		.wrData ( dataToDMem ),
		.outAluOut ( aluOutToMEM ),
		.outBrCode ( brCodeToMEM ),
		.outIsLoadInsn ( isLoadInsnToMEM ),
		.outIsStoreInsn ( isStoreInsnToMEM ),
		.outRgWrEnable ( wrEnableToMEM ),
		.outConstant ( constantToMEM ),
		.outWrRg ( wrNumToMEM ),
		.outPcWrEnable ( pcWrEnableToMEM ),

		.inWrData ( rfWrData ),

		.outWrData ( dataFromWB )
	);

	FourthStage fourthStage(
		.clk ( clk ),
		.rst ( rst ),

		.dataFromDMem ( dataFromDMem ),
		.inWrNum (wrNumToMEM),
		.inIsLoadInsn ( isLoadInsnToMEM ),
		.wrEnable ( wrEnableToMEM ),
		.aluOut ( aluOutToMEM ),

		.outData ( wrDataToWB ),
		.outWrNum ( wrNumToWB ),
		.regWrite ( wrEnableToWB ),
		.memToReg ( isLoadInsnToWB ),
		.dataFromEX ( aluOutToWB )
	);

	// Forwarding forwarding(
	// 	.rsNumFromID ( dcRS ),
	// 	.rtNumFromID ( dcRT ),

	// 	.wrNumFromEX ( wrNumToEX ),
	// 	.rgWrEnableFromEX ( wrEnableToEX ),

	// 	.wrNumFromMEM ( wrNumToMEM ),
	// 	.rgWrEnableFromMEM ( wrEnableToMEM ),

	// 	.wrNumFromWB ( wrNumToWB ),
	// 	.rgWrEnableFromWB ( wrEnableToWB ),

	// 	.aluInASelect ( aluInASelectFromID ),
	// 	.aluInBSelect ( aluInBSelectFromID )
	// );

	always_comb begin
		// IMem
		imemInsnCode = insn;
		insnAddr     = pcOut;

		// Register write data
		rfWrData = isLoadInsnToWB ? wrDataToWB : aluOutToWB;

		// Register write num
		rfWrNum = dcIsDstRt ? dcRT : dcRD;

		// ALU
		aluInA = isSrcA_RtToEX ? rdDataBToEX : rdDataAToEX;
		aluInB = isALUInConstantToEX ? constantToEX : rdDataBToEX;

		// DMem
		dataOut = rdDataBToEX;
		dataFromDMem = dataIn;
		// dataAddr = rfRdDataS[ `DATA_ADDR_WIDTH - 1 : 0 ] + `EXPAND_ADDRESS( dcconstant );
		dataAddr = constantToEX + aluInA;

		dataWrEnable = isStoreInsnToEX;

	end

endmodule

