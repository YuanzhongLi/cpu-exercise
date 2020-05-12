`include "Types.v"

module CPU(

	input logic clk,	// クロック
	// input logic clkX4, // 4 倍のクロック
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
	// pc
	InsnAddrPath addrIn;
	logic pcWrEnable;
	PC pc (
		.clk( clk ), // in
		.rst( rst ), // in

		.addrOut( insnAddr ), // out

		.addrIn( adderIn ), // in: 外部書き込みのアドレス
		.wrEnable( pcWrEnable ) // in
	);

	// alu
	`DataPath
	`DataPath aluInA;
	`DataPath aluInB;
	`ALUcodePath aluCodePath;

	ALU alu (
		.aluOut( aluOut ),

		.aluInA( aluInA ),
		.aluInB( aluInB ),
		.code( aluCodePath )
	);


	// register file
	`DataPath rdDataA;
	`DataPath rdDataB;
	`RegNumPath rdNumA;
	`RegNumPath rdNumB;
	`DataPath regFileWrData;
	`RegNumPath regFileWrNum;
	logic regFileWrEnable;

	RegisterFile regFile(
		.clk( clk ), // in

		.rdDataA( rdDataA ), // out
		.rdDataB( rdDataB ), // out

		.rdNumA( rdNumA ), // in
		.rdNumB( rdNumB ), // in

		.wrData( regFileWrData ), // in
		.wrNum( regFileWrNum ), // in
		.wrEnable( regFileWrEnable ) // in
	);



	`OpPath op;
	`FunctPath funct;
	`ShamtPath shamt;
	`DataPath  shift;
	`ConstantPath constant;

	`RegNumPath rs;
	`RegNumPath rt;
	`RegNumPath rd;

	`DataPath rsData;
	`DataPath rtData;
	`DataPath rdData;

	always_ff @( posedge clk) begin
		// ID
		op <= insn[ `OP_POS : `OP_POS+`OP_WIDTH-1 ];
		funct <= insn[ `FUNCT_POS : `FUNCT_POS+`FUNCT_WIDTH-1 ];
		shamt <= insn[ `SHANT_POS : `SHAMT_POS+`SHAMT_WIDTH-1 ];
		constant <= EXPAND_CONSTANT( insn );

		rs <= insn[ `RS_POS : `RS_POS+`REG_NUM_WIDTH-1 ];
		rt <= insn[ `RT_POS : `RT_POS+`REG_NUM_WIDTH-1 ];
		rd <= insn[ `RD_POS : `RD_POS+`REG_NUM_WIDTH-1 ];

		// register fileからrt, rsの中身を取り出す
		regFileWrEnable <= `FALSE; // データの読み出しのみを行うので書き込み不可にする

		rdNumA <= rs;
		rdNumB <= rt;

		rsData <= rdDataA;
		rtData <= rdDataB;

		// EX and
		case ( op )
		`OP_CODE_ALU:
			pcWrEnable <= `FALSE; // aluなのでpcの外部書き込みなし

			case ( funct ) // functによってaluでの処理を決める
				`FUNCT_CODE_SLL: // [rt]を左シフトしてrsに入れる
					aluCodePath <= ALU_CODE_SLL;
					aluInA <= rtData; // [rt]
					aluInB <= constant; // alu内でGET_SHIFTによってshiftに変換させられる

					regFileWrData <= aluOut;
					regFileWrNum <= rs;
					regFileWrEnable <= `TRUE;


				`FUNCT_CODE_SRL: // [rt]を右シフトしてrsに入れる
					aluCodePath <= ALU_CODE_SRL;
					aluInA <= rtData; // [rt]
					aluInB <= constant; // alu内でGET_SHIFTによってshiftに変換させられる

					regFileWrData <= aluOut;
					regFileWrNum <= rs;
					regFileWrEnable <= `TRUE;

				`FUNCT_CODE_ADD: // [rs] + [rt]をrdに入れる
					aluCodePath <= ALU_CODE_ADD;
					aluInA <= rsData; // [rs]
					aluInB <= rtData; // [rt]

					regFileWrData <= aluOut;
					regFileWrNum <= rd;
					regFileWrEnable <= `TRUE;

				`FUNCT_CODE_SUB: // [rs] - [rt]をrdに入れる
					aluCodePath <= ALU_CODE_SUB;
					aluInA <= rsData; // [rs]
					aluInB <= rtData; // [rt]

					regFileWrData <= aluOut;
					regFileWrNum <= rd;
					regFileWrEnable <= `TRUE;

				`FUNCT_CODE_AND: // [rs] & [rt]をrdに入れる
					aluCodePath <= ALU_CODE_AND;
					aluInA <= rsData; // [rs]
					aluInB <= rtData; // [rt]

					regFileWrData <= aluOut;
					regFileWrNum <= rd;
					regFileWrEnable <= `TRUE;

				`FUNCT_CODE_OR: // [rs] | [rt]をrdに入れる
					aluCodePath <= ALU_CODE_OR;
					aluInA <= rsData; // [rs]
					aluInB <= rtData; // [rt]

					regFileWrData <= aluOut;
					regFileWrNum <= rd;
					regFileWrEnable <= `TRUE;

				`FUNCT_CODE_SLT: // ([rs] < [rt])をrdに入れる
					aluCodePath <= ALU_CODE_SLT;
					aluInA <= rsData; // [rs]
					aluInB <= rtData; // [rt]

					regFileWrData <= aluOut;
					regFileWrNum <= rd;
					regFileWrEnable <= `TRUE;

		`OP_CODE_LD: // load word
			pcWrEnable <= `FALSE; // load wordなのでpcの外部書き込みなし

			dataAddr <= EXPAND_ADDRESS( rtData + EXPAND_CONSTANT( constant ) ); // [rt]+constant
			dataWrEnable <= `FALSE; // データメモリからの読み出しなので書き込み不可

			// rs にデータメモリからの読み出しを入れる
			regFileWrData <= dataIn;
			regFileWrEnable <= `TRUE;
			regFileWrNum <= rs;

		`OP_CODE_ST: // store word
			pcWrEnable <= `FALSE; // store wordなのでpcの外部書き込みなし

			dataAddr <= EXPAND_ADDRESS( rtData + EXPAND_CONSTANT( constant ) );
			dataWrEnable <= `TRUE; // データメモリへ読み込むので書き込み許可

			dataOut <= rsData; // [rs]をデータメモリに書き込む

		`OP_CODE_ADDI: // [rt] + constantをrsに入れる
			pcWrEnable <= `FALSE; // addiなのでpcの外部書き込みなし

			regFileWrData <= rtData + EXPAND_CONSTANT( constant );
			regFileWrNum <= rs;
			regFileWrEnable <= `TRUE;

		`OP_CODE_ANDI: // [rt] & constantをrsに入れる
			pcWrEnable <= `FALSE; // andiなのでpcの外部書き込みなし

			regFileWrData <= rtData & EXPAND_CONSTANT( constant );
			regFileWrNum <= rs;
			regFileWrEnable <= `TRUE;

		`OP_CODE_ORI: // [rt] | constantをrsに入れる
			pcWrEnable <= `FALSE; // oriなのでpcの外部書き込みなし

			regFileWrData <= rtData | EXPAND_CONSTANT( constant );
			regFileWrNum <= rs;
			regFileWrEnable <= `TRUE;

		`OP_CODE_BEQ: // [rs] == [rt]でjmp
			if (rsData == rtData) begin
				adderIn <= insnAddr + EXPAND_BR_DISPLACEMENT( constant );
				pcWrEnable <= `TRUE;
			end
			else begin
				pcWrEnable <= `FALSE;
			end

		`OP_CODE_BNE:
			if (rsData != rtData) begin // [rs] != [rt]でjmp
				adderIn <= insnAddr + EXPAND_BR_DISPLACEMENT( constant );
				pcWrEnable <= `TRUE;
			end
			else
				pcWrEnable <= `FALSE;
			end
	end

endmodule

