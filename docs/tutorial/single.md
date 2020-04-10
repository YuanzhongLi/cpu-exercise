# シングルサイクルマシン
- このページでは，あらかじめ用意してあるシングルサイクルマシンのひな形について説明します．
- ひな形のファイルはtutorial/processor 内にあります．

## ファイルの内容
以下は，各ファイルの簡単な説明です

|  |  |
|--|--|
| CPU.v | CPU の実装．基本的にはこの CPU モジュール以下に実装をおこなっていきます．|
| DMem.v | データメモリ．このファイルは基本的には書き換えません．|
| DMem.dat | データメモリの中身．ソートの入力データなどをここに記述します．|
| IMem.v | 命令メモリ．このファイルは基本的には書き換えません．|
| IMem.dat | 命令メモリの中身．命令コードをここに記述します．|
| IOCtrl.v | I/Oインターフェースの実装．このファイルは書き換えません．|
| MainSim.v | シミュレーション入力などの検証用コード．|
| Main.v | メインモジュール．ここに CPU やデータメモリ，命令メモリなどを含みます．|
| Makefile | コンパイルのための設定．|
| Types.v | 型や定数の定義．|

## メモリについて
チュートリアル内のコードでは，メモリのみ4倍速で動作するようにしてあります

- 使用する FPGA の仕様により，メモリからの読み出しでは，アドレスを与えた1サイクル後にデータが得られます．
- このままではシングルサイクルマシンが作れないため，メモリに対してのみCPUのクロック（clk）の4倍速のクロック（clkX4）を与えています．
- その他の PC や レジスタ・ファイルなどのクロック同期で動くユニットは全て等速のクロック（clk）に同期して動作するようにしてください．
- データメモリへの書き込みについては，等速クロック（clk）の後半のみで行うよう気をつけてください（Main.v 内のコメント参照）．

## 作業のすすめかた

- ALU や PC，レジスタ・ファイルなどの各モジュールを作成し，それぞれのモジュールの検証を行ってください．
    - 検証はこれまでのチュートリアルなどを参考にして行ってください．
- 作成したモジュールを CPU モジュール内でインスタンシエイトし，それらの入出力を接続してください．
- データメモリや命令メモリの接続は，
    1. 適切な信号線を CPU モジュールの入出力に追加し，
    2. Main モジュール内で各メモリの入出力と接続してください