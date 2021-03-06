# レジスタ・ファイル

レジスタ・ファイルの実現にはいくつかの方法がありますが，最も簡単なのは，配列とクロック同期の順序回路を表す always_ff 構文を組み合わせる方法です．
* この方法の利点は，簡単にマルチポート（=複数の読み書きを同時に行える）のレジスタ・ファイルを作ることができる点です．
* 欠点は，この方法でマルチポートのレジスタ・ファイルを作ると，回路がものすごく大きくなってしまうことがある点です．場合によっては FPGA にのらなくなることもあるので，注意してください．

以下では、レジスタ・ファイル（16ビット×8エントリ、2リードポート、1ライトポート）について説明します．

## コンパイルとシミュレーション
1. 加算器の時と同様に，H3/tutorial/regfile を開きます
    * RegFile がレジスタ・ファイル本体，RegFileSim が検証用コードです．それぞれをエディタで開いて読んでください．
1. 加算器の時と同様に，make を行ってください
1. 同じく "make sim-gui" を行ってください．
1. ModelSim 上でシミュレーションを行ってください
    * 使い方は[[ModelSim>LSI/ツール/ModelSim]]を参照

レジスタ・ファイルの読み書きの様子が波形として観測できれば成功です．

## 課題
> レジスタ・ファイル とそのレジスタ・ファイルから読み出した値を加算する回路で構成されるモジュール（RegAdder.v）とそのシミュレーション記述（RegAdderSim.v）を作成し、回路が意図した動作をしているかを確認せよ．作成した RegAdder.v と RegAdderSim.v および結果は進捗レポートにまとめ提出すること

- サンプルの Adder.v と RegFile.v をそのまま使って実現すること．''RegFile.v や RegFileSim.v を編集するのは禁止です''．
    - RegAdder の中で，Adder と RegFile を作り，それらをつなげるとよいです．
-シミュレーション記述は，RegFileSim.v を参考にするとよいです．
    - RegFileSim では，initial 節内で読み出しレジスタ番号や書き込みを行なっています．
    - これをまねして，まずレジスタファイルに値を書き込み，それを読みだして加算が行われていることを確かめるとよいです．
- この課題ではひな形を用意していません．regfile 内の各ファイルを丸ごとコピーして，そこにファイルを自分で付け加えていって下さい．
    - 以下はこの課題でつくるもののイメージ
        ```
        // RegAdder.v の内容のイメージ
        module RegAdder(
            ... // RegAdder のために必要な入出力を考えて定義
                // たとえば RegisterFile を動かすためには clk がいるなぁとか，
                // レジスタファイルへの書き込みのための信号線がいるな，とか．
        )
            // Adder と RegisterFile を作ってそれを繋いで作る
            `DataPath signal; // RegAdder を作るのに必要な線を考えて定義する
        
            Adder adder(  // 加算器の実体を作る
                ...  // 加算器に繋ぐ線を考えて
            );
        
            RegisterFile regFile(  // レジスタ・ファイルの実体
                clk,
                ... 
            );
        
        endmodule
        
        // RegAdderSim .v のイメージ
        module H3_RegAdderSim;
        
            RegAdder regAdder(
                ...
            );
            initial begin
                ...
                ... // まず regAddr の中のレジスタファイルに値を書き込む
                ...
                ... // regAddr にレジスタ番号を２つ指定し，先ほど書き込んだ値が足されて出力されていることを確かめる．
            end
        endmodule
        ```
### 新しくコンパイルするファイルの追加方法
新しいファイルをコンパイル対象に加える場合，Makefile を開いて編集する必要があります

1. SOURCES で定義される部分に コンパイルしたいファイルを加えてください
    * ファイルの末尾に \ がいることと，各ファイル名はタブの後に来ないといけないことに気をつけてください
    * 以下は RegFile の Makefile に RegAdder.v を足す場合の例
        ```
        # コンパイル対象のファイル
        SOURCES = \
            RegFile.v \
            RegFileSim.v \
            RegAdder.v \   <== この行を追加
        ```
1. シミュレーションを行うモジュールの設定を変えて下さい
    * そのままでは，RegFileSim 内の H3_Simulator のシミュレーションが行われてしまいます．
        ```
        # ライブラリ名とトップレベルモジュール（シミュレーション対象）
        LIBRARY_NAME    = H3_Modules
        TOPLEVEL_MODULE = H3_Simulator <== ここを RegAdderSim 内で定義する検証用のモジュール名（H3_RegAdderSim）に変えてください
        ```