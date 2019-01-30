using Pkg
Pkg.add("DataFrames")
Pkg.add("CSV")
Pkg.add("Plots")
Pkg.add("StatPlots")
Pkg.add("PyPlot")
Pkg.add("Plotly")

using DataFrames
using CSV
using Plots
using Plotly

data=CSV.read("/Users/miganehhadisahal/Desktop/TTw.csv"; header=true, delim=';')
print("La taille du jeu de données est :", size(data))
showall(data[1:5,:])
names(data)
Plots.histogram(data[:num],xlabel="nvr de tweet",xlims=(0,5000),color = :red,xtickfont = font(9, "Courier"),legend=nothing,ylabel="Frequency")
Plots.histogram(data[:P14_POP],xlabel="nvr de tweet",xlims=(0,5000),color = :red,xtickfont = font(9, "Courier"),legend=nothing,ylabel="Frequency")
