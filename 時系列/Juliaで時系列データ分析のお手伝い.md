#前振り
かなり前にデータ収集デバイスから得られた時系列データ(具体的には1時間毎)を集計するミドルウェアを作った事がありました。
JSONで受け取ったデータを分解しSQLiteに格納し必要に応じてゴリゴリSQL文で取り出していたのです。

動作としてはC++で書いたJSON受取モジュールで分解しSQLiteに落とし込んで集計、その後JSONで別サーバに送り込むというシンプルな物です。データの保持期間は1ヶ月で良くストレージは/mnt以下にマウントされたSSD。
環境はLinux、動作形態はDeamonというUnix系プログラマにとっては割とよくあるスタイルです。
もっとも日時データも別サーバに送っているので、そのサーバで集計処理すれば良いじゃ無いかと思っていましたが、発注主にはかなわない。仰せの通り、へへー、毎度ありがとうございます。メモリリークも無く頑張って動いているようです。流行の言葉で言えばIoTのエッジサーバという事でしょうか。
#Juliaならどうする？
ふと思い立ってJuliaで書いたらどうなるのか試してみました。
JSON廻りは既にJSON.jlがあり、RESTfull廻りはHTTP.jlで何とかなる。
データを受信したらDataFrames.jlで処理すればよさげ。
RESTfull関係は良いとしてデータ処理で面倒なのはSQLで頑張っていた時系列データの処理
週次、月次をどう扱うか。後は何とでもなりそうです。

DataFrameMeta、Queryを組み合わせて作成し順調だったのですが、既存のライブラリを探してみると、TimeSeriesとその周辺のライブラリを発見。
#TimeSeriesとTimeSeriesResampler
TimeSeries.jl は　[https://github.com/JuliaStats/TimeSeries.jl](https://github.com/JuliaStats/TimeSeries.jl)

TimeSeriesResampler.jlは、[https://github.com/femtotrader/TimeSeriesResampler.jl](https://github.com/femtotrader/TimeSeriesResampler.jl)
です。

TimeSeries.jlの最終更新日は数ヶ月前、TimeSeriesResampler.jlは2年前。
若干の不安を不安を抱えつつトライ。
私の結論としては使えます。
当方の環境は以下です。
OS OSX Catalina 
開発環境 ATOM + Juno + Julia 1.5.3になります。

#実践
調べてみると[https://github.com/femtotrader/TimeSeriesResampler.jl](https://github.com/femtotrader/TimeSeriesResampler.jl)にサンプルがありました。
ちょっと改造してコメントを追加

```Julia
using MarketData: AAPL		# サンプルデータ
using Dates						# 日付データ処理用
using TimeSeriesResampler	# 時系列計算用ライブラリ
using Statistics					# 統計処理用ライブラリ
ta = AAPL						# サンプルデータを読み込む

 # 1週毎のデータを集計する。対象となるカラムは :Volumeとなる
tsum  = sum(resample(ta[:Volume], Dates.Month(1)))

tohoc = ohlc(resample(ta[Symbol("Adj. Close")], Dates.Month(1)))
```
ohicとは、株価の表示などで使うローソク足の事です。
私は使ったことはありません。
これだけではサンプルにもならないし面白くないので実践的な時系列データ表示をやってみます。

その前に説明をすると、これらのライブラリが使うデータ型はTimeArrayが基本となっており
その構造はTimeArray{Float64,1,Date,Array{Float64,1}}です。
途中の1は時間格納カラムを除くカラム数です。
従ってデータの扱いはTimeArrayを中心とする演算になります。
時系列だけ扱うのであれば良いのですが、やはりDetaFrame型に比べると見劣りがするので、
相互変換を行ってみます。
先ずはDataFrameからの変換は必須と思いますのでやってみる。簡単でした。

```Julia
julia> ta = AAPL	
julia> tadf = DataFrame(ta)    # Convert to DataFrame from TimeSeries
8336×13 DataFrame. Omitted printing of 9 columns
│ Row  │ timestamp  │ Open    │ High    │ Low     │
│      │ Date       │ Float64 │ Float64 │ Float64 │
├──────┼────────────┼─────────┼─────────┼─────────┤
│ 1    │ 1980-12-12 │ 28.75   │ 28.88   │ 28.75   │
│ 2    │ 1980-12-15 │ 27.38   │ 27.38   │ 27.25   │
│ 3    │ 1980-12-16 │ 25.38   │ 25.38   │ 25.25   │
│ 
```
**【重要】**_日付データが :timestamp  というカラム名になっています。
これは固定のようです。_

逆はもう少し面倒くさい

```Julia
ta = TimeArray(df,timestamp = :DATE)
```
これは、DataFrameの中でどのカラムを時間カラム?として扱うかを指定する訳です。
joinっぽい変換の方法です。

#時系列データの集計
サンプルが用意されているので、実際に実行してみます。
サンプルにはコメントが無かったのでグラフ表示も追加してます。

```Julia
using MarketData: AAPL		# サンプルデータ
using Dates					# 日付データ処理用
using TimeSeriesResampler	# 時系列計算用ライブラリ
using Plots					# グラフ表示用
ta = AAPL						# サンプルデータを読み込む

 # 1日毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Day(1)))
p0 = plot(tsum)

 # 1週毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Week(1)))
p1 = plot(tsum)
 # 1月毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Month(1)))
p2 = plot(tsum)

# 1年毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Year(1)))
p3 = plot(tsum)

plot(p0, p1, p2 , p3, label = "")
```
すごく簡単。もう少し説明すると

```
resample(ta, Dates.Day(1))
resample(ta, Dates.Week(1))
resample(ta, Dates.Month(1))
resample(ta, Dates.Year(1))
```
Dates.**Week(**1)で指定するのは集計する単位(日、週、月、年)
最後の数値は2日単位とか3ヶ月単位とか指定できる。
これは簡単で便利。
取得するカラムを指定する場合には
ta[:Volume]のように指定することが出来る。当然複数をカンマで区切って指定することも可能。
全体を指定する場合には、resample(ta, Dates.Week(1))のように指定する

**sum**(resample(ta, Dates.Week(1)))は、週単位の合計値となる。
週単位の平均値はmeanを使う
mean(resample(ta, Dates.Week(1)))

ついでに説明すると平均という概念は難しい。欠損日があった場合にはその日数を含めるのか
それとも週なら7で割って良い事案なのか。これはビジネスロジックに影響するので仕様検討を事前に行う必要がある。
ついでにStatistics.jlに渡してみると上手く動作しない。
多分DateFrame等に変換してから使った方が良いかもしれない。

こんな感じです。

```
sum(resample(ta, Dates.Week(1)))
mean(resample(ta, Dates.Week(1)))
```

さて、サンプルを作ってみます。
簡単なのでコメント少なめですが・・・

```
using HTTP, CSV                 # Webサイトからデータを取得するために使用
using DataFrames                # 取得したCSVを加工用にDataFrameとして扱うために使用
using Plots                     # グラフ描画用
using Dates                     # 日付データ処理用
using TimeSeries                # 時系列計算ライブラリ
using TimeSeriesResampler	# 時系列集計ライブラリ

# 厚生労働省からCOVID-19の入院治療を要する者のデータを持ってきています。
df = CSV.File(HTTP.request("GET","https://www.mhlw.go.jp/content/cases_total.csv").body; dateformat="yyyy/mm/dd") |> DataFrame

# DataFrame型からの変換
ta = TimeArray(df,timestamp = :日付)

# 1日毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Day(1)))
p0 = plot(tsum)

# 1週毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Week(1)))
p1 = plot(tsum)

# 1月毎のデータを集計する。
tsum  = sum(resample(ta, Dates.Month(1)))
p2 = plot(tsum)

# グラフ3つを表示。年単位は今回意味が無いのでパス
plot(p0, p1, p2 , label = "")

# That's all folks.
```
以上