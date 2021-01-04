#=
    単回帰分析　Simple regression analysis
=#
using Statistics    # LinRegの中で使用する統計関数の使用宣言

# 単回帰分析
function LinReg(x, y)
    #=
        linear regression
        2つの配列を受取り、単回帰分析を行う
        x,yの配列の大きさは同じである事が前提。
        配列の大きさが異なる場合にはエラーで落ちる
        面倒なので、チェックをしていない

        もっと早い手法もあるが、可読性重視とした
    =#
        b = Statistics.cov(x,y) / Statistics.std(x)^2
        a = Statistics.mean(y) - b * Statistics.mean(x)
        return b, a
end

using Plots     # 散布図と直線を描く為に使用
using Printf    # @sprintfを氏要すために使用
using Random    # サンプルデータにノイズを加えるために使用

#アニメーションのインスタンス生成
anim = Animation()

# デモデータの作成
n = 500                   # デモデータの個数
dx = randn(n)             # 乱数を指定個数発生
dy = randn(n) / 2 .+ dx   # 良い塩梅に見栄え良くノイズを加える


# 散布図と直線を描画したグラフをｎ枚作成しながら、
# アニメーション用のフレームに追加していく
for dn = 2:n # 2から始めないと直線が書けないので
    # 散布図を作成
    ps = plot(
        dx[1:dn],
        dy[1:dn],
        seriestype = :scatter,
        title  = "Linear regression Demonstration",
        lab    = "Data $(dn) / $(n) ",
        xlabel = "xlabel",
        ylabel = "ylabel",
        legend = :topleft,
        c = :green,
        xlims  = (-3, 3),
        ylims  = (-3, 3)   # お好みでグラフを表示する範囲を指定しておく
    )

    # Y = aX + b の a,bを求める
    a, b = LinReg(dx[1:dn], dy[1:dn])

    # 直線描画
    plot!(
        ps, # 分散図に追加描画　（省略可能)
        x -> a * x + b,
        findmin(dx)[1],
        findmax(dx)[1],    # 横軸の最小値、最大値を求め、その間を描画する
        lab = @sprintf(    # 見栄えの為
            "y = %s * x + %s",
            string(round(b, digits = 4)),　# 小数点４桁だけ表示
            string(round(a, digits = 4))
        ),
        lw = 3,
        c = :red,
    )
    frame(anim, ps) # フレームとして追加する
end

# フレームが出来たので出力する
popdisplay()        # Plotsを使うときには記述した方がベター
gif(anim, "test.gif", fps = 30) # 30フレーム/Secでgiｆを出力
