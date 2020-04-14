//
// 減算器の検証用モジュール
//



// 基本的な型を定義したファイルの読み込み
`include "Types.v"



// シミュレーションの単位時間の設定
// #~ と書いた場合，この時間が経過する．
`timescale 1ns/1ns


//
// 減算器の検証用のモジュール
//
module H3_Simulator;
  `DataPath subInA, subInB;
  `DataPath subOut;

  Sub sub (
    .dst ( subOut ),
    .srcA ( subInA ),
    .srcB ( subInB )
  );

  initial begin
    // simulation start
    subInA = 10;
    subInB = 3;

    #40 // 40ns

    subInA = 9;
    subInB = 6;

    #20 // 20ns

    subInA = 456;
    subInB = 321;

    #20 // 20ns

    $finish;

  end

  initial
    $monitor(
      $stime, // now time
      "a(%d) - b(%d) = c(%d)",
      subInA,
      subInB,
      subOut
    );

endmodule


