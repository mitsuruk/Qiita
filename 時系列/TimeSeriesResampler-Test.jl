# https://juliastats.org/TimeSeries.jl/dev/
#=
    時系列データ分析用テストプログラム
    2020/12/13
    Julia 1.5.3 on MacBook Air 10.15.7

=#
using HTTP, CSV                 # Webサイトからデータを取得するために使用
using DataFrames                # 取得したCSVを加工用にDataFrameとして扱うために使用
using Plots                     # グラフ描画用
using Dates                     # 日付データ処理用
using TimeSeries                # 時系列計算ライブラリ
using TimeSeriesResampler       # 時系列集計ライブラリ

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
# グラフの見た目を映える作業は面倒なのでパス
plot(p0, p1, p2 , label = "")

# That's all folks.
#=
using MarketData: AAPL		# サンプルデータ
using Dates						# 日付データ処理用
using TimeSeriesResampler	# 時系列計算用ライブラリ
#using Statistics					# 統計処理用ライブラリ
using Plots						# グラフ表示用
ta = AAPL						# サンプルデータを読み込む

 # 1週毎のデータを集計する。対象となるカラムは :Volumeとなる
tsum  = sum(resample(ta, Dates.Month(1)))
plot(tsum)

using MarketData    # : AAPL
#using DataFrames
using TimeSeries    # 時間経過計算用
using TimeSeriesResampler   # 時間経過計算用

ta = MarketData.AAPL

#tadf = DataFrame(ta)    # Convert to DataFrame from TimeSeries
                        # TimeArray(df,timestamp = :timestamp)
#println(ta)

#tsum = sum(resample(ta[:Volume], Dates.Month(6)))
#tsum = sum(resample(ta[:Open], Dates.Month(6)))
tsum = sum(resample(ta, Month(1)))
#tsum = sum(resample(ta,Dates.Week(2)))

plot(tsum)


::Day
::Week
::Month

tsum = mean(resample(ta[:AdjVolume,:Volume] , Week(1)))

using Statistics
tsum = std(resample(ta[:AdjVolume,:Volume] , Week(1)))

=#
