//
// 2 Read / 1 Write レジスタ・ファイル
//


// 基本的な型を定義したファイルの読み込み
`include "Types.v"

module RegisterFile(
	input logic clk,			// クロック

	output `DataPath rdDataA,	// 読み出しデータA
	output `DataPath rdDataB,	// 読み出しデータB


	input `RegNumPath rdNumA,	// 読み出しレジスタ番号A
	input `RegNumPath rdNumB,	// 読み出しレジスタ番号B

	input `DataPath   wrData,	// 書き込みデータ
	input `RegNumPath wrNum,	// 書き込みレジスタ番号
	input logic       wrEnable	// 書き込み制御 1の場合，書き込みを行う
);

	// 実際に値が入るストレージ
	// `DataPath の配列（サイズ：`REG_FILE_SIZE）
	`DataPath strage[ 0 : `REG_FILE_SIZE-1 ];
	`DataPath r0;

	`DataPath r1;
	`DataPath r2;
	`DataPath r3;
	`DataPath r4;
	`DataPath r5;
	`DataPath r6;
	`DataPath r7;

	// 書き込みと，レジスタ・ファイルの実現
	// クロックの立ち上がりによって書き込みが行われる と言う動作を書くことで，
	// コンパイラはこれを順序回路だと解釈する．
	always_ff @( posedge clk ) begin
		if( wrEnable ) begin			// 書き込み制御
			strage[ wrNum ] <= wrData;	// 順序回路では，ノンブロッキング代入で
		end
	end

	// 読み出し
	always_comb begin
		if ( rdNumA ) begin
			rdDataA = strage[ rdNumA ];
		end
		else begin
			rdDataA = 0;
		end

		if ( rdNumB ) begin
			rdDataB = strage[ rdNumB ];
		end
		else begin
			rdDataB = 0;
		end
		r0 = 0;
		r1 = strage[1];
		r2 = strage[2];
		r3 = strage[3];
		r4 = strage[4];
		r5 = strage[5];
		r6 = strage[6];
		r7 = strage[7];
	end

	initial
	$monitor(
		$stime,
		"\nr0(%d)\n r1(%d)\n r2(%d)\n r3(%d)\n r4(%d)\n r5(%d)\n r6(%d)\n r7(%d)\n", 	// printf と同様の書式設定
		r0,
		r1,
		r2,
		r3,
		r4,
		r5,
		r6,
		r7
	);

endmodule

