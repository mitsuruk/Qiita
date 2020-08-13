using Statistics


a = [ 1,2,3,4,5,6,7,8,9,11]     # 平均値と中央値をずらす為に 9,11 のように、わざと定義しています。
b = [ 2,5,2,6,7,10,12,10,14,11] # 相関係数用のデモデータ


#=
  標本標準偏差と標準偏差　Standard Deviation、Sample Standard Deviation

  std
  stdm

  標本標準偏差は、母集団から部分的に標本を抜き題したときに使う
  標準偏差は、全データに対して計算

  stdmは、内部で使用する平均値をあらかじめ指定する事が出来る。
  従って stdm(a,mean(a))とstd(a)は同値となります。
  なぜ、平均値を指定出来るかというと、巨大なデータの平均値を既に計算済みの場合に
  再度内部で計算しなくても良いというメリットが有るからです。
=#
println("標本標準偏差 ",std(a))
println("標準偏差 ",std(a,corrected=false))
println("標本標準偏差ｍ付き ",stdm(a,mean(a)))
println("標準偏差ｍ付き　",stdm(a,corrected=false,mean(a)))


#=
  標本分散と分散   sample variance, variance
  var
  varm
  corrected=falseを指定すると分散、デフォルトは標本分散
  varmは、内部で使用する平均値をあらかじめ指定する事が出来る。
  従って varm(a,mean(a))とvar(a)は同値となります。

=#
println("標本分散 ",var(a))
println("標本分散ｍ付き　",varm(a,mean(a)))

println("分散 ",var(a,corrected=false))
println("分散ｍ付き　",varm(a,mean(a),corrected=false))

println("標本標準偏差の2乗 ",std(a)^2 ,"　==  標本分散 ",var(a),"　計算誤差除く")


#cov       2つの配列の共分散を求める
println("共分散 ", cov(a, b,corrected=false))
#cor       2つの配列のピアソン相関係数 pearson correlationを求める
println("相関係数 ",cor(a, b))


#　平均値を求める
println("平均値 ",mean(a))
println("平均値 ",mean(√,a),"各値をルートしてから平均")
println("平均値 ",mean(sin,a),"各値をsin()してから平均")
# データに missingがある場合には
println("平均値 ",mean(skipmissing(a))," with skipmissing()")

# median 中央値
println("中央値 ",median(a))

#middle    指定値の平均値(x,y)  = (x + y) / 2
println("指定値の平均値 2と3 -> ",middle(2,3))

# quantile 分位数
#データの値を小さい順にソートして、指定の数で分けた云々（説明がめんどい）
# ２等分するのに、２ではなくて、1/2 , 0.5 を指定する
# n等分なら、 1/n と書くことになる。

println("1/2の時は中央値と同じ median(a) = ",median(a)," quantile(a,1/2) = ", quantile(a,1/2))


#以下は面倒なので省略
# https://docs.julialang.org/en/v1/stdlib/Statistics/#Statistics.mean! を見てください
# mean!
# median!
# quantile!
