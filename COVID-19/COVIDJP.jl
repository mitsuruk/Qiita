using HTTP, CSV, DataFrames, Plots, Dates

mutable struct structTargetData
    targetURL::String
    Label::String
    fillcolor::Symbol   # :green :orange :black :purple :red :yellow :brown :white
end

arrayTargetDataFrame = [ # from https://www.mhlw.go.jp/stf/covid-19/open-data.html
    structTargetData("https://www.mhlw.go.jp/content/cases_total.csv"           ,"Cases"        ,:blue),
    structTargetData("https://www.mhlw.go.jp/content/pcr_positive_daily.csv"    ,"Positive"     ,:red),
    structTargetData("https://www.mhlw.go.jp/content/death_total.csv"           ,"Death total"  ,:yellow)   ]

function ReadCSV(url::String)
    df = CSV.File(HTTP.request("GET",url).body; dateformat="yyyy/mm/dd") |> DataFrame
    colnames = names(df); colnames[1] = "DATE"; rename!(df, colnames) # Change the name of the first column.
    return df
end

dfs = []
for s in arrayTargetDataFrame
    push!(dfs,ReadCSV(s.targetURL))
end

ps = plot(formatter =:plain,legend = :topleft,title = "Information on COVID-19 in Japan "*string(last(dfs[1]).:DATE))
for i = 1:length(arrayTargetDataFrame)
    plot!(ps, dfs[i][!, 1],dfs[i][!, 2],fillrange = 0, fillalpha = 0.4, color = :black, fillcolor = arrayTargetDataFrame[i].fillcolor, label = arrayTargetDataFrame[i].Label)
end

savefig("Covid-19"*string(last(dfs[1]).:DATE)*"-plot.png")
plot(ps)
