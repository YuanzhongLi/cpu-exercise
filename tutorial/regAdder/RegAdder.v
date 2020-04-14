`include "Types.v"

// regFile[rdNumA] + regFile[rdNumB]
module RegAdder (
  input logic clk, //　clock
  input logic wrEnable, // 1: write
  input `RegNumPath wrNum,	// 書き込みレジスタ番号
  input `RegNumPath rdNumA,
  input `RegNumPath rdNumB,

  output `DataPath dst,

  input `DataPath wrData	// 書き込みデータ
);

  `DataPath rfRdDataA;	// 読み出しデータA
	`DataPath rfRdDataB;	// 読み出しデータB

  Adder adder (
    .dst( dst ),
    .srcA( rfRdDataA ),
    .srcB( rfRdDataB )
  );

  RegisterFile regFile (
    .clk( clk ),
		.rdDataA ( rfRdDataA  ),
		.rdDataB ( rfRdDataB  ),
		.rdNumA  ( rdNumA   ),
		.rdNumB  ( rdNumB   ),
		.wrData  ( wrData   ),
		.wrNum   ( wrNum    ),
		.wrEnable( wrEnable )
  );

endmodule
