#=
    「厚生労働省掲載　新型コロナウイルス感染症について > オープンデータ」 グラフ化プログラム
    https://www.mhlw.go.jp/stf/covid-19/open-data.html
    2020/11/22
    Julia 1.5.3 on MacBook Air 10.15.7

    Qiita投稿用にコメントを大幅に追加したバージョン
=#
using HTTP, CSV     # Webサイトからデータを取得するために使用
using DataFrames    # 取得したCSVを加工用にDataFrameとして扱うために使用
using Plots         # グラフ描画用

#=
    データ取得元に対しての情報を纏めるための struct を定義する
    最低限の目的としては、サイトを追加してラベル、色を指定可能とする
    今後機能、パラメータの追加はここに行い、参照側で機能拡張を実装する
=#
mutable struct structTargetData
    targetURL::String   # ターゲット URL
    Label::String       # 表示用ラベル
    fillcolor::Symbol   # 表示グラフの色を指定する。 :green :orange :black :purple :red :yellow :brown :white
end

#=
    ターゲットURLと関連情報を配列として定義
    今後グラフを追加する場合には、このデータを追加定義する。
    グラフは定義された順に描画される。
    一般的に大きな数値データを先に描画すると良い結果が得られると思うので、目的に応じて順番,色を決定する
=#
arrayTargetDataFrame = [
    structTargetData("https://www.mhlw.go.jp/content/cases_total.csv"           ,"Cases"        ,:blue),
    structTargetData("https://www.mhlw.go.jp/content/pcr_positive_daily.csv"    ,"Positive"     ,:red),
    structTargetData("https://www.mhlw.go.jp/content/death_total.csv"           ,"Death total"  ,:yellow)
]

#=
    渡された URLからデータを取得する
    (面倒なのでインターネット未接続などのエラートラップは行っていない)
        1.データの取得
        2.DeataFrame型に格納
        3.カラム名変更
=#
function ReadCSV(url::String)
    # CSV中の日付データをDate型で扱いたいため、dateformat="yyyy/mm/dd"を追加。
    # 得られたCSV型を pipingを使ってDetaFrame型に変換。
    df = CSV.File(HTTP.request("GET",url).body; dateformat="yyyy/mm/dd") |> DataFrame

    # 厚生労働省のデータのカラム名が "日付" だったので "DATE" に変更
    # 今回使用した開発環境はコメントも含めて全て英語で記述したい方針にした為に日本語を避けた。
    # サブ機は日本語OKなのでそちらを使えば問題ないのだが・・・
    # カラム指定には別の方法もあるが、明確にしたかったのでカラム名変更を採用（要は後で忘れないようにした)
    colnames = names(df)    # カラム名を配列で取得
    colnames[1] = "DATE"    # 厚生労働省データの先頭は "日付" なので、"DATE" に変更
    rename!(df, colnames)   # 配列を使ってカラム名変更を行う

    # 直前の rename!は df を返すので、シンタックスとしては returnは不要です。
    # 私は戻り値を明確にしたい方針なので必ず return 文を書くようにしています。
    return df
end

#=
    メインルーチン
=#

#
# データ取得と格納
#   取得したCSVから生成された DetaFrame型データを配列に追加する
#
dfs = []    # 配列追加用の Place holder
for i in arrayTargetDataFrame
    push!(dfs,ReadCSV(i.targetURL))     # 取得したCSVから生成された DetaFrame型データを配列に追加する
    # 以上の処理によりDataFrames型が格納された配列が生成される
    # dfs[1] : 感染者数のデータセット
    # dfs[2] : 治療が必要な人の数のデータセット
    # dfs[3] : 死亡者数合計のデータセット となる。
    # 順番,要素数は最初に定義した URL順と数になる。
end

#
# グラフ描画
#

# 最初にグラフ全体に影響するパラメータを定義する
# ここでは、数字表示を:plain(指数表示で無い)、データラベル表示位置を左上、タイトルを指定
#   string(last(dfs[1]).:DATE)は、取得したデータの日付データの最終ライン(最新日付)を取得してタイトルに追記した
#   この方法で十分だが、なにかモヤモヤする。将来変更する第一候補
ps = plot(
    formatter = :plain,
    legend = :topleft,
    title = "Information on COVID-19 in Japan " * string(last(dfs[1]).:DATE),
)

#
for i = 1:length(arrayTargetDataFrame)
    plot!(
        ps,
        dfs[i][!, :DATE],   # 最初が日付 カラム番号でも良い dfs[i][!, 1]
        dfs[i][!, 2],       # 表示する数値データ
        fillrange = 0,      # 色を塗る開始位置
        fillalpha = 0.4,    # 塗る色の透過度 適当に試して値を決めた。将来は URL 関連情報を一緒に纏める予定
        color = :black,     # 一応目立つように
        fillcolor = arrayTargetDataFrame[i].fillcolor,  # 指定されてた色で描画
        label = arrayTargetDataFrame[i].Label,          # ラベルを指定
    )
end

# png形式で保存
savefig("Covid-19"*string(last(dfs[1]).:DATE)*"-plot.png")
# 画面に描画
plot(ps)

# That's all folks.
