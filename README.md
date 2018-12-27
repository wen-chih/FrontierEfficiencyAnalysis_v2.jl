# FrontierEfficiencyAnalysis_v2.jl
#### Copyright © 2018 by Wen-Chih Chen.  Released under the MIT License.

FrontierEfficiencyAnalysis_v2.jl is a package for Frontier Efficiency Analysis (aka Data Envelopment Analysis, DEA) computation. It is embedded in the [Julia](https://julialang.org/) programming language, and is an extension to the [JuMP](https://github.com/JuliaOpt/JuMP.jl) modeling language. It is particularly designed to enhance large-scale DEA computation and to solve DEA problems by size-limited solvers.

**Disclaimer** : FrontierEfficiencyAnalysis_v2 is *not* developed or maintained by the JuMP developers.


## Installation
In Julia, call `Pkg.clone("git://github.com/wen-chih/FrontierEfficiencyAnalysis_v2.jl")` to install FrontierEfficiencyAnalysis_v2.


## Usage
DEA is a linear program (LP)-based method used to determine a firm’s relative efficiency. Users can use JuMP to model and solve the DEA problems (special LP problems). Rather than solve the LPs by calling `JuMP.solve()`, FrontierEfficiencyAnalysis_v2.jl can solve the large-scale problems more efficiently and/or by a solver with size limitation (e.g. 300 variables).


Please refer to [Quick Start Guide of JuMP](https://jump.readthedocs.io/en/latest/quickstart.html) for modeling details. What needed is to call our FrontierEfficiencyAnalysis_v2.jl function:

	solveDEA(model)

instead of calling

	JuMP.solve(model)


## Example


```julia
# full size example
# there are 6 cases
# please write the data output (e.g. to csv) by yourself
using JuMP
using Gurobi
using FrontierEfficiencyAnalysis_v2

include("solveDEA.jl")
include("variable.jl")

# CRS input-oriented
function case1(data)
    # make up the data set
    X = data[:,1:6] # 6
    Z = data[:,7:10] # 4
    Y = data[:,11:15] # 5
    scale = size(data)[1]
    xNo = size(X)[2]
    zNo = size(Z)[2]
    yNo = size(Y)[2]

    for k = 1:scale
        model = Model(solver = GurobiSolver(OutputFlag=0)) # Gurobi is used as the LP solver here. Users can choose their favorite solver.

        @solveDEA_varibleInit(model)
        @solveDEA_varible(model, Lambda[1:25000] >= 0, "nc") # non-critical group 1
        @solveDEA_varible(model, Gamma[1:25000] >= 0, "nc") # non-critical group 2
        @solveDEA_varible(model, middle[1:4] >= 0, "c") # critial
        @solveDEA_varible(model, Theta >= 0, "c") # critial

        @objective(model, Min, Theta)

        @constraint(model, inputConA[i=1:xNo], sum{Lambda[r]*X[r,i], r = 1:scale} <= Theta*X[k,i])
        @constraint(model, outputConA[j=1:zNo], sum{Lambda[r]*Z[r,j], r = 1:scale} >= middle[j])
        @constraint(model, inputConB[i=1:zNo], sum{Gamma[r]*Z[r,i], r = 1:scale} <= middle[i])
        @constraint(model, outputConB[j=1:yNo], sum{Gamma[r]*Y[r,j], r = 1:scale} >= Y[k,j])

        #solve(model)
        solveDEA(model)

        #println("lambdas: $(getvalue(Lambda)))")

        # retrieve results
        println("Objective value: ", getobjectivevalue(model))
    end
end


println("begins")
data = readcsv("example.csv")
case1(data)

println("done!")

```

<br>

## Parameters

>
**incrementSize** : the incremental size to expand the sample ( default value: 100 ).

	solveDEA(model, incrementSize = 200) # set the incremental size to 200

>
**tol** : the solution tolerance for solving DEA problem (default value: 1e-6). It also resets the dual feasibility tolerance in the solver to the given value.
<br>

	solveDEA(model, tol = 10^-4) # set the solution tolerance to 1e-4

>
**lpUB** : the size limit of the LP, i.e. the limitation of number of variables in the LP (default value: Inf).
<br>

	solveDEA(model, lpUB = 300) # set the LP size limitation to 300 variables

>
**extremeValueSetFlag** : to enable (=1) or disable (=0) performing initial sampling by selecing extreme value in each input/output dimension (default value: 0).
<br>


	solveDEA(model, extremeValueSetFlag = 1) # enable




## Citation
If you find FrontierEfficiencyAnalysis_v2 useful in your work, we kindly request that you cite the following papers

	@article{ChenLai2017,
	author = {Wen-Chih Chen and Sheng-Yung Lai},
	title = {Determining radial efficiency with a large data set by solving small-size linear programs},
	journal = {Annals of Operations Research},
	volume = {250},
	number = {1},
	pages = {147-166},
	year = {2017},
	doi = {10.1007/s10479-015-1968-4},
	}
and

	@misc{chen2017b,
	Author = {Wen-Chih Chen and Yueh-Shan Chung},
	Title = {A generalized non-radial efficiency measure and its application in DEA computation},
	Year = {2017},
	Eprint = {http://dx.doi.org/10.2139/ssrn.2496847},
	}

## Acknowledgements
FrontierEfficiencyAnalysis_v2 has been developed under the financial support of the Ministry of Science and Technology, Taiwan (Grant No. 104-2410-H-009-026-MY2). The contributors include Yueh-Shan Chung and Hao-Yun Chen.
