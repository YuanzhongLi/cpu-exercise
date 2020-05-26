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
		.clk( clk ), // in
		.clkLed( clk ), // in
		.rst( rst ), // in

		.dmemWrEnable( dmemWrEnable ), // out
		.dataToCPU( dataToCPU ), // out

		.led( led ),	// out: LED
		.gate( gate ),	// out: select 7seg
		.lamp( lamp ),	// out: Lamp?

		.addrFromCPU( dataAddr ), // in
		.dataFromCPU( dataFromCPU ), // in
		.dataFromDMem( dataFromDMem ), // in
		.weFromCPU( dataWE_Req ), // in

		.sigCH( sigCH ), // in
		.sigCE( sigCE ), // in
		.sigCP( sigCP ) // in
	);

	// CPU
	CPU cpu(
		.clk( clk ),
		.rst( rst ),

		.insnAddr( imemAddr ),		// out: 命令メモリへのアドレス出力
		.dataAddr( dataAddr ),		// out: データメモリへのアドレス出力
		.dataOut( dataFromCPU ),	// out: データメモリへの入力
		.dataWrEnable( dataWE_FromCPU ),	// out: データメモリ書き込み有効

		.insn( imemDataToCPU ),	// in: 命令メモリからの出力
		.dataIn( dataToCPU )	// in: データメモリからの出力
	);

	// IMem
	IMem imem(
		.clk( clk ),
		.rst( rst ), // in

		.insn( imemDataToCPU ), // out
		.addr( imemAddr ) // in
	);

	// Data memory
	DMem dmem(
		.clk( clk ),
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
		// dataWE_Req = !clk && dataWE_FromCPU;
		dataWE_Req = clk && dataWE_FromCPU;

 	end

	initial
	$monitor(
		$stime,
		"\n imemDataToCPU(%h)",
		imemDataToCPU
	);

endmodule


