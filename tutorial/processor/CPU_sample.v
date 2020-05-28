`include "Types.v"

module CPU(

	input logic clk,	// クロック
	input logic rst,	// リセット
	
	output `InsnAddrPath insnAddr,		// 命令メモリへのアドレス出力
	output `DataAddrPath dataAddr,		// データバスへのアドレス出力
	output `DataPath     dataOut,		// 書き込みデータ出力
										// dataAddr で指定したアドレスに対して書き込む値を出力する．
	output logic         dataWrEnable,	// データ書き込み有効

	input  `InsnPath 	 insn,			// 命令メモリからの入力
	input  `DataPath     dataIn,			// 読み出しデータ入力
										// dataAddr で指定したアドレスから読んだ値が入力される．
	output logic flush,
	output logic stall
);
	
	// PC
	`InsnAddrPath pcOut;		// アドレス出力
	`InsnAddrPath pcIn;			// 外部書き込みをする時のアドレス
	logic pcWrEnable;			// 外部書き込み有効
	
	// IMem
	`InsnPath imemInsnCode;		// 命令コード
	
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
	
	// Forwarding
	`ForwardCodePath aluInASelectFromID;
	`ForwardCodePath aluInBSelectFromID;
	`ForwardCodePath aluInASelectToEX;
	`ForwardCodePath aluInBSelectToEX;
	`DataPath dataFromWB;

	// Pipeline
	
	// IFstage
	`InsnPath insnToDecorder;
	
	
	// IDstage
	
	// EXstage
	`DataPath rdDataAToEX;
	`DataPath rdDataBToEX;
	`DataPath aluInAFromID;			// ALU 入力A
	`DataPath aluInBFromID;			// ALU 入力B
	`OpPath opToEX;
	
	`ShamtPath shamtToEX;			// SHAMT フィールド
	`FunctPath functToEX;			// FUNCT フィールド
	`ConstantPath constatToEX;	// CONSTANT フィールド
	
	`ALUCodePath aluCodeToEX;		// ALU の制御コード
	`BrCodePath brCodeToEX;		// ブランチの制御コード
	logic isSrcA_RtToEX;			// ソースの1個目が Rt かどうか
	logic isALUInConstantToEX;	// ALU の入力が Constant かどうか
	logic isLoadInsnToEX;			// ロード命令かどうか
	logic isStoreInsnToEX;		// ストア命令かどうか
	logic pcWrEnableToEX;
	logic wrEnableToEX;
	`RegNumPath wrNumToEX;
	//`DataAddrPath dataAddrOnEX;
	
	
	// MEMstage
	`DataPath aluOutToMEM;
	`BrCodePath brCodeToMEM;
	`ConstantPath constatToMEM;
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
	
	
	
	// PC
	PC pc(
		.clk (clk),
		.rst (rst),
		.addrOut (pcOut),
		.addrIn (pcIn),
		.wrEnable (pcWrEnableToIF),
		.stall (stall)
	);

	// Branch Unit
	BranchUnit branch(
		.pcOut (pcIn),	// BranchUnit への入力は in と out が逆になるのを注意
		.brCode (brCodeToMEM),
		.aluOut (aluOutToMEM),
		.constant (constatToMEM),
		.inPcWrEnable (pcWrEnableToMEM),
		.outPcWrEnable (pcWrEnableToIF)
	);
	

	// Decoder
	Decoder decoder(
		.op (dcOp),
		.rs (dcRS),
		.rt (dcRT),
		.rd (dcRD),
		.shamt (dcShamt),
		.funct (dcFunct),
		.constat (dcConstat),	
		.aluCode (dcALUCode),
		.brCode (dcBrCode),
		.pcWrEnable (pcWrEnable),			// PC 書き込みを行うかどうか
		.isLoadInsn (dcIsLoadInsn),		// ロード命令かどうか
		.isStoreInsn (dcIsStoreInsn),		// ストア命令かどうか
		.isSrcA_Rt (dcIsSrcA_Rt),		// ソースの1個目が Rt かどうか
		.isDstRt (dcIsDstRt),			// ディスティネーションがRtかどうか
		.rfWrEnable (rfWrEnable),			// ディスティネーション書き込みを行うかどうか
		.isALUInConstant (dcIsALUInConstant),	// ALU の入力が Constant かどうか
		.insn (insnToDecorder)
	);
	
	// RegisterFile
	RegisterFile regFile(
		.clk (clk),
		.rdDataA (rfRdDataS),
		.rdDataB (rfRdDataT),
		.rdNumA (dcRS),
		.rdNumB (dcRT),
		.wrData (rfWrData),
		.wrNum (wrNumToWB),
		.wrEnable (wrEnableToWB)
	);
	
	// ALU
	ALU alu(
		.aluOut (aluOut),
		.aluInA (aluInA),
		.aluInB (aluInB),
		.code (aluCodeToEX)
	);
	
	FirstStage firstStage(
		.clk (clk),
		.rst (rst),
		.insnFromIMem (imemInsnCode),
		.insnToDecorder (insnToDecorder),
		.stall (stall),
		.flush (flush)
	);
	
	SecondStage secondStage(
		.clk (clk),
		.rst (rst),
		.inRdDataA (rfRdDataS),
		.inRdDataB (rfRdDataT),
		.inWrNum (rfWrNum),
		.inWrEnable (rfWrEnable),
		.inConstat (dcConstat),
		.inOp (dcOp),
		.inShamt (dcShamt),
		.inFunct (dcFunct),
		.inAluCode (dcALUCode),
		.inBrCode (dcBrCode),
		.inIsLoadInsn (dcIsLoadInsn),
		.inIsStoreInsn (dcIsStoreInsn),
		.inIsALUInConstant (dcIsALUInConstant),
		.inIsSrcA_Rt (dcIsSrcA_Rt),
		.inPcWrEnable (pcWrEnable),
		.outRdDataA (rdDataAToEX),
		.outRdDataB (rdDataBToEX),
		.outWrNum (wrNumToEX),
		.outWrEnable (wrEnableToEX),
		.outConstat (constatToEX),
		.outOp (opToEX),
		.outShamt (shamtToEX),
		.outFunct (functToEX),
		.outAluCode (aluCodeToEX),
		.outBrCode (brCodeToEX),
		.outIsLoadInsn (isLoadInsnToEX),
		.outIsStoreInsn (isStoreInsnToEX),
		.outIsALUInConstant (isALUInConstantToEX),
		.outIsSrcA_Rt (isSrcA_RtToEX),
		.outPcWrEnable (pcWrEnableToEX),
		.aluInASelectFromID (aluInASelectFromID),
		.aluInBSelectFromID (aluInBSelectFromID),
		.aluInASelectToEX (aluInASelectToEX),
		.aluInBSelectToEX (aluInBSelectToEX),
		.flush (flush),
		.stall (stall)
	);
	
	ThirdStage thirdStage(
		.clk (clk),
		.rst (rst),
		.inAluOut (aluOut),
		.inBrCode (brCodeToEX),
		.dataFromRegister (aluInA),
		.inIsLoadInsn (isLoadInsnToEX),
		.inIsStoreInsn (isStoreInsnToEX),
		.inRgWrEnable (wrEnableToEX),
		.inConstat (constatToEX),
		.inWrRg (wrNumToEX),
		.inPcWrEnable (pcWrEnableToEX),
		.wrData (dataToDMem),
		.outAluOut (aluOutToMEM),
		.outBrCode (brCodeToMEM),
		.outIsLoadInsn (isLoadInsnToMEM),
		.outIsStoreInsn (isStoreInsnToMEM),
		.outRgWrEnable (wrEnableToMEM),
		.outConstat (constatToMEM),
		.outWrRg (wrNumToMEM),
		.outPcWrEnable (pcWrEnableToMEM),
		.flush (flush),
		.inWrData (rfWrData),
		.outWrData (dataFromWB)
	);
	FourthStage fourthStage(
		.clk (clk),
		.rst (rst),
		.dataFromDMem (dataFromDMem),
		.inWrNum (wrNumToMEM),
		.inIsLoadInsn (isLoadInsnToMEM),
		.wrEnable (wrEnableToMEM),
		.aluOut (aluOutToMEM),
		.outData (wrDataToWB),
		.outWrNum (wrNumToWB),
		.regWrite (wrEnableToWB),
		.memToReg (isLoadInsnToWB),
		.dataFromEX (aluOutToWB)
	);
	
	Forwarding forwarding(
		.rsNumFromID (dcRS),
		.rtNumFromID (dcRT),
		.wrNumFromEX (wrNumToEX),
		.rgWrEnableFromEX (wrEnableToEX),
		.wrNumFromMEM (wrNumToMEM),
		.rgWrEnableFromMEM (wrEnableToMEM),
		.wrNumFromWB (wrNumToWB),
		.rgWrEnableFromWB (wrEnableToWB),
		.aluInASelect (aluInASelectFromID),
		.aluInBSelect (aluInBSelectFromID)
	
	);
	
	// Connections & multiplexers
	always_comb begin
		
		// IMem
		imemInsnCode = insn;
		
		insnAddr     = pcOut;
		

		
		// Register write data
		rfWrData = isLoadInsnToWB ? wrDataToWB : aluOutToWB;
		
		// Register write num
		rfWrNum = dcIsDstRt ? dcRT : dcRD;

		// ALU
		
		case( aluInASelectToEX )
				default:			aluInAFromID = rdDataAToEX;
				`FORWARD_CODE_EX:	aluInAFromID = aluOutToMEM;
				`FORWARD_CODE_MEM:	aluInAFromID = rfWrData;
				`FORWARD_CODE_WB:	aluInAFromID = dataFromWB;
		endcase
		
		case( aluInBSelectToEX )
				default:			aluInBFromID = rdDataBToEX;
				`FORWARD_CODE_EX:	aluInBFromID = aluOutToMEM;
				`FORWARD_CODE_MEM:	aluInBFromID = rfWrData;
				`FORWARD_CODE_WB:	aluInBFromID = dataFromWB;
		endcase
		
		if (opToEX == `OP_CODE_ALU && functToEX == `FUNCT_CODE_SRL || opToEX == `OP_CODE_ALU && functToEX == `FUNCT_CODE_SLL) begin
			aluInA = aluInAFromID;
			aluInB = shamtToEX;
		end
		else begin
			aluInA = isSrcA_RtToEX ? aluInBFromID : aluInAFromID;
			aluInB = isALUInConstantToEX ? constatToEX : aluInBFromID;
		end
		
		// Data memory
		dataOut  = aluInBFromID;
		dataFromDMem = dataIn;
		//dataAddrOnEX = rdDataAToEX[ `DATA_ADDR_WIDTH - 1 : 0 ] + `EXPAND_ADDRESS( constatToEX );
		dataAddr = constatToEX + aluInA;
		
		// DMem write enable
		dataWrEnable = isStoreInsnToEX;
		
		// Flush
		flush = pcWrEnableToIF;
		
		// Stall
		if ( opToEX == `OP_CODE_LD && dcRS == wrNumToEX || opToEX == `OP_CODE_LD && dcRT == wrNumToEX ) begin
			stall = `TRUE;
		end
		else begin
			stall = `FALSE;
		end
			
		
 	end

endmodule

