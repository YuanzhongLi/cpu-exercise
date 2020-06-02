//
// 検証用モジュール
//



// 基本的な型を定義したファイルの読み込み
`include "Types.v"



// シミュレーションの単位時間の設定
// #~ と書いた場合，この時間が経過する．
`timescale 1ns/1ns


//
// 全体の検証用モジュール
//
module H3_MainSim;

	parameter CYCLE_TIME = 200; // 1サイクルを 200ns に設定

	integer i;

	integer cycle;		// サイクル

	logic countCycle;

	logic clk;
	logic rst;

	logic sigCH;
	logic sigCE;
	logic sigCP;

	`DD_OutArray led;
	`DD_GateArray gate;
	`LampPath lamp;	// Lamp?


	// Main モジュール
	Main main(
		.sigCH( sigCH ),
		.sigCE( sigCE ),
		.sigCP( sigCP ),

		.led( led ),
		.gate( gate ),
		.lamp( lamp ),	// Lamp?

		.clkBase( clk ),
		.rst( rst ), 	// リセット（0でリセット）
		.clkled( clk )
	);

	// 検証動作を記述する
	initial begin

		//
		// 初期化
		//
		sigCE = 1'b0;
		sigCH = 1'b0;
		sigCP = 1'b0;


		//
		// リセット
		//
		rst = 1'b0;
		#(CYCLE_TIME/8*3)

		rst = 1'b1;
		#(CYCLE_TIME/8)
		#(CYCLE_TIME)
		#(CYCLE_TIME)

		// CH On
		sigCH = 1'b1;

		//
		// シミュレーション開始
		//

		// 100 サイクル
		#(CYCLE_TIME*100000)
		$finish;

	end

	// クロック
	initial begin
		countCycle = 0;
		clk   = 1'b1;
		cycle = 0;

	    forever #(CYCLE_TIME / 2 / 4) begin
	    	clk = !clk ;

	    	if( countCycle ) begin
					cycle = cycle + 1;
				end


		    // カウント開始
		    if( rst && clk ) begin
		    	countCycle = 1;
		    end
	    end
	end

endmodule


