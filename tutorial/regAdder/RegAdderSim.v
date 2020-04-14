`include "Types.v"

`timescale 1ns/1ns

module H3_RegAdderSim;

  parameter CYCLE_TIME = 10; // 1 cycle 10ns

  integer cycle;

  logic clk;

  `DataPath dst; // 足し算の出力

  `RegNumPath rfRdNumA;	// 読み出しレジスタ番号A
	`RegNumPath rfRdNumB;	// 読み出しレジスタ番号B

  `DataPath   rfWrData;	// 書き込みデータ
	`RegNumPath rfWrNum;	// 書き込みレジスタ番号
  logic       rfWrEnable;	// 書き込み制御 1の場合，書き込みを行う

  RegAdder regAdder(
    .clk ( clk ),
    .wrEnable( rfWrEnable ),
    .wrNum( rfWrNum ),
    .rdNumA( rfRdNumA ),
    .rdNumB( rfRdNumB ),
    .dst( dst ),
    .wrData( rfWrData )
  );

  // clock
  initial begin
    clk <= 1'b1;
    cycle <= 0;

  	// 半サイクルごとに clk を反転
			forever #(CYCLE_TIME / 2) begin
				clk <= !clk ;
				cycle <= cycle + 1;
			end
  end

  // 検証動作を記述する
  initial begin
    // 初期化
		rfRdNumA   = 0;
		rfRdNumB   = 0;
		rfWrData   = 0;
		rfWrNum    = 0;
		rfWrEnable = 0;

		//
		// シミュレーション開始
		//
		rfWrEnable = 0; rfRdNumA = 0; rfRdNumB = 1; // dst = [$0] + [$1]
    #CYCLE_TIME

    rfWrEnable = 1;	rfWrNum = 0;	rfWrData = 15;  // $0に15を代入
		#CYCLE_TIME

		rfWrEnable = 1;	rfWrNum = 1;	rfWrData = 14;	// $1に14を代入
		#CYCLE_TIME

		$finish;
  end

  // シミュレーション結果の表示（クロックの立ち上がり時と立ち下がり時）
	always @( posedge clk or negedge clk ) begin

		$write(
			"%s\n",
			( clk == 0 ) ?
		  		"=====================================================" :
		  		"-----------------------------------------------------");

		$write(
			"cycle -> %0d\n",
		  	cycle
		);

		$write(
			"    %s WrNum[%d] WrData[%d]\n",
			(rfWrEnable) ? "Write" : "     ",
			rfWrNum,
			rfWrData
		);

		$write(
			"  %s\n",
		  ( clk == 1 ) ? "posedge clk" : "negedge clk"
		);

		$write(
			"strage[$%d] + strage[$%d] = %d \n",
			rfRdNumA,
			rfRdNumB,
			dst
		);

	end

endmodule
