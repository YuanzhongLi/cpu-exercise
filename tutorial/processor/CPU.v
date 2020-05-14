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
	`ConstantPath dcConstat;	// CONSTANT フィールド

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

	// Branch
	// BranchUnit 内で分岐かどうかを判断する変数なのでCPUではいらないのでは？
	logic brTaken;

	PC pc (
		.clk( clk ), // in
		.rst( rst ), // in

		.addrOut( pcOut ), // out

		.addrIn( pcIn ), // in: 外部書き込みのアドレス
		.wrEnable( pcWrEnable ) // in
	);

	// Branch Unit
	BranchUnit branch(
		.pcOut( pcIn ),	// out: BranchUnit への入力は in と out が逆になるのを注意

		.pcIn( pcOut ), // in
		.brCode( dcBrCode ), // in
		.regRS( rfRdDataS ), // in
		.regRT( rfRdDataT ), // in
		.constant( dcConstat ) // in
	);

	// Decoder
	Decoder decoder(
		.op( dcOp ), // out
		.rs( dcRS ), // out
		.rt( dcRT ), // out
		.rd( dcRD ), // out
		.shamt( dcShamt ), // out
		.funct( dcFunct ), // out
		.constat( dcConstat ), // out
		.aluCode( dcALUCode ), // out
		.brCode( dcBrCode ), // out
		.pcWrEnable( pcWrEnable ), // out: PC 書き込みを行うかどうか
		.isLoadInsn( dcIsLoadInsn ),	// out: ロード命令かどうか
		.isStoreInsn( dcIsStoreInsn ),	// out: ストア命令かどうか
		.isSrcA_Rt( dcIsSrcA_Rt ), // out: ソースの1個目が Rt かどうか
		.isDstRt( dcIsDstRt ),	// out: ディスティネーションがRtかどうか
		.rfWrEnable( rfWrEnable ),	// out: ディスティネーション書き込みを行うかどうか
		.isALUInConstant( dcIsALUInConstant ),	// out :ALU の入力が Constant かどうか

		.insn( imemInsnCode ) // in
	);

	RegisterFile regFile(
		.clk( clk ), // in

		.rdDataA( rfRdDataS ), // out
		.rdDataB( rfRdDataT ), // out

		.rdNumA( dcRS ), // in
		.rdNumB( dcRT ), // in

		.wrData( rfWrData ), // in
		.wrNum( rfWrNum ), // in
		.wrEnable( rfWrEnable ) // in
	);

	ALU alu (
		.aluOut( aluOut ), // out

		.aluInA( aluInA ), // in
		.aluInB( aluInB ), // in
		.code( dcALUCode ) // in
	);

	always_comb begin
		// IMem
		imemInsnCode = insn;
		insnAddr     = pcOut;

		// DMem
		dataOut = rfRdDataT;
		dataAddr = rfRdDataS[ `DATA_ADDR_WIDTH - 1 : 0 ] + `EXPAND_ADDRESS( dcConstat );

		// Register write data
		rfWrData = dcIsLoadInsn ? dataIn : aluOut;

		// Register write num
		rfWrNum = dcIsDstRt ? dcRT : dcRD;

		// ALU
		aluInA = dcIsSrcA_Rt ? rfRdDataT : rfRdDataS;
		aluInB = dcIsALUInConstant ? dcConstat : rfRdDataT;

		// DMem write enable;
		dataWrEnable = dcIsStoreInsn;

	end

endmodule

