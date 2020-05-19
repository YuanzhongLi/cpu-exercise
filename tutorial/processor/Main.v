`include "Types.v"

module Main(
	input logic sigCH,
	input logic sigCE,
	input logic sigCP,

	output `DD_OutArray  led,	// 7seg
	output `DD_GateArray gate,	// 7seg gate
	output `LampPath     lamp,	// Lamp?

	input logic clkBase,	// 4倍速クロック
	input logic rst, 		// リセット（0でリセット）
	input logic clkled   // LED用クロック
);
	// 命令メモリとデータメモリは，FPGA の仕様により
	// アドレスを入力した1サイクル後にデータが読み出される．
	// このままではシングルサイクルマシンが作れないので，メモリには
	// 4倍速のクロックを入れてある．

	// Clock/Reset
	logic clkX4;
	logic clk;

	// IMem
	`InsnAddrPath imemAddr;			// アドレス出力
	`InsnPath 	  imemDataToCPU;	// 命令コード

	// Data Memory
	logic         dmemWrEnable;		// 書き込み有効

	// IOCtrl
	logic         dataWE_Req;

	// データ
	`DataPath     dataToCPU;		// 出力
	`DataAddrPath dataAddr;			// アドレス
	`DataPath     dataFromCPU;		// 入力
	`DataPath     dataFromDMem;		// データメモリ読み出し
	logic         dataWE_FromCPU;

	// Clock divider
	ClockDivider clockDivider(
		.clk( clk ),
		.rst( rst ),
		.clkX4( clkX4 )
	);

	// IO
	IOCtrl ioCtrl(
		.clk( clkX4 ),
		.clkLed( clkled ),
		.rst( rst ),
		.dmemWrEnable( dmemWrEnable ),
		.dataToCPU( dataToCPU ),

		.led( led ),	// LED
		.gate( gate ),	// select 7seg
		.lamp( lamp ),	// Lamp?

		.addrFromCPU( dataAddr ),
		.dataFromCPU( dataFromCPU ),
		.dataFromDMem( dataFromDMem ),
		.weFromCPU( dataWE_Req ),

		.sigCH( sigCH ),
		.sigCE( sigCE ),
		.sigCP( sigCP )
	);

	// CPU
	CPU cpu(
		.clk( clk ),
		.rst( rst ),

		.insnAddr( imemAddr ),		// 命令メモリへのアドレス出力
		.dataAddr( dataAddr ),		// データメモリへのアドレス出力
		.dataOut( dataFromCPU ),	// データメモリへの入力
		.dataWrEnable( dataWE_FromCPU ),	// データメモリ書き込み有効

		.insn( imemDataToCPU ),	// 命令メモリからの出力
		.dataIn( dataToCPU )	// データメモリからの出力
	);

	// IMem
	IMem imem(
		.clk( clkX4 ), 			// メモリは4倍速
		.rst( rst ),
		.insn( imemDataToCPU ),
		.addr( imemAddr )
	);

	// Data memory
	DMem dmem(
		.clk( clkX4 ),			// メモリは4倍速
		.rst( rst ),			// リセット

		.dataOut( dataFromDMem ), // out
		.addr( dataAddr ), // in
		.dataIn( dataFromCPU ), // in
		.wrEnable( dmemWrEnable ) // in
	);

	// Connections & multiplexers
	always_comb begin

		// クロック
		clkX4  = clkBase;

		// データメモリへの書き込みはクロックサイクル後半のみ有効
		dataWE_Req = !clk && dataWE_FromCPU;

 	end

	initial
	$monitor(
		$stime,
		" insn(%h) ", 	// printf と同様の書式設定
		imemDataToCPU
	);


endmodule


