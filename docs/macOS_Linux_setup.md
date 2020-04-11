# 実験の準備
## macOSの方
virtual boxでUbuntu18.04LTSの仮想環境を作成
メモリ8GB, ストレージ64GB以上（Modelsimのフリー版が約15GB以上あるため）

macOSのshortcut keyを使いたい方
```
sudo apt install gnome-tweaks
```
以下のようにemacsのkey bindを有効化
todo 図

以下Ubuntu18.04LTSを前提で説明していく
## インストール
詳しくない場合以下の手順通りに実行することを推奨

* vscodeとgitをインストール
    * Ubuntu vscode(or git)インストールと調べたやり方で基本的によい cf)[vscode](https://qiita.com/yoshiyasu1111/items/e21a77ed68b52cb5f7c8), [git](https://qiita.com/tommy_g/items/771ac45b89b02e8a5d64)

* Modelsim フリー版をインストール
    * [Downloadリンク](https://fpgasoftware.intel.com/19.1/?edition=lite&platform=linux)
    アドレスは割とコロコロ変わるので注意
    * リンクを進んで「個別ファイル」のところの Intel FPGA Edition のところにある
    * アドレスは割とコロコロかわるので，そこにない場合はググって探してください
    * cygwin を導入しておいてください
    * WSL でも大丈夫かもしれませんが，試してないです
        * GUI の起動などにおいて問題が起きるかもしれません
* 共通
    * git, make が必要ですので，インストールしておいてください
    * エディタとしては VSCode を使うことを前提に説明します．
        * 下記拡張をいれておいてください
            * SystemVerilog - Language Support
            * svls-vscode
* 環境変数の設定
    * tools/setenv/ に移動し，SetEnv.bat/SetEnv.sh を使用して環境変数を設定
*


## シミュレーションのテスト

ここまでの設定がうまく行っているかを確認するため，加算器のシミュレーションを行ってみます．

* tutorial/adder に移動
* make と打って Enter を押す．
    * 下のように出ればOK
        ```
        Model Technology ModelSim ALTERA vlog 6.6d Compiler 2010.11 Nov  2 2010
        -- Compiling module Adder
        -- Compiling module H3_Simulator

        Top level modules:
                H3_Simulator
        ```
* make sim-gui と打って Enter を押す．
    * シミュレータが立ち上がり，シミュレータ内の下の方に以下のように加算の結果が出ていればOK
        ```
            #  run 50ns
            #          0 a(    1) *  b(    8) = c(    9)
            #         40 a(    9) *  b(    6) = c(   15)
        ```

