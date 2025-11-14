module Model1

using JuMP
using HiGHS
using Printf

# executa o modelo 1 (Completion time variables) para os dados fornecidos:
function run_model_1(p::Vector{<:Real}, w::Vector{<:Real}, d::Vector{<:Real};
                      time_limit::Real,
                      filename::String)

    n = length(p)
    M = sum(p)

    model = Model(HiGHS.Optimizer)
    set_optimizer_attribute(model, "time_limit", time_limit)

    @variable(model, C[1:n] >= 0)

    @variable(model, y[1:n, 1:n], Bin)

    @objective(model, Min, sum(w[j] * C[j] for j in 1:n))

    @constraint(model, [j in 1:n], C[j] >= p[j])

    @constraint(model, [j in 1:n, k in 1:n; j < k], C[j] + p[k] <= C[k] + M * (1 - y[j, k]))

    @constraint(model, [j in 1:n, k in 1:n; j < k], C[k] + p[j] <= C[j] + M * y[j, k])

    # resolve o modelo
    optimize!(model)

    # coleta os resultados
    status = termination_status(model)
    obj_value = if status in (MOI.OPTIMAL, MOI.TIME_LIMIT, MOI.INTERRUPTED)
        round(objective_value(model), digits=2)
    else
        NaN
    end

    gap = try
        round(100 * MOI.get(model, MOI.RelativeGap()), digits=2)
    catch
        NaN
    end

    # grava arquivo de saída
    project_root = normpath(joinpath(@__DIR__, "..", ".."))
    results_dir = joinpath(project_root, "results")
    mkpath(results_dir)

    minutes = time_limit/60.0
    minutes_str = @sprintf("%.2f", minutes)


    open(joinpath(results_dir, filename), "w") do io
        println(io, "RESULTADOS")
        println(io, "Modelo: Completion time variables [F1]")
        println(io, "Solver: HiGHS")
        println(io, "Tempo limite: $minutes_str minutos")
        println(io, "Função objetivo (min sum wj*Cj): ", obj_value)
        println(io, "Gap relativo: ", gap, "%")
        println(io, "\nTempo de conclusão de cada job (Cj):")

        for j in 1:n
            println(io, "C[$j] = ", round(value(C[j]), digits=2))
        end
    end

    println("Resultados salvos em: ", joinpath(results_dir, filename))

end

end
