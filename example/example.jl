# full size example
# there are 6 cases
# please write the data output (e.g. to csv) by yourself
using JuMP
using Gurobi

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
        # crs = Model(solver = GurobiSolver(Presolve=0, OutputFlag=0))
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
data = readcsv("C:/Users/mb516/Desktop/solveDEA_local_0307/15-7-25k_01.csv")
case1(data)
# case2(data)
# case3(data)
# case4(data)
# case5(data)
# case6(data)

println("done!")
