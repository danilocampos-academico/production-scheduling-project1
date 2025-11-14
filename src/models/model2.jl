module Model2

using JuMP
using HiGHS
using Printf

# executa o modelo 2 (Assignment and positional date variables [F4]) para os dados fornecidos:

function run_model_2(p::Vector{<:Real}, w::Vector{<:Real}, d::Vector{<:Real};
                      time_limit::Real,
                      filename::String)

    n = length(p)
    M = sum(p)

    model = Model(HiGHS.Optimizer)
    set_optimizer_attribute(model, "time_limit", time_limit)

    # variável binária u[j,k] = 1 se job j está na posição k
    @variable(model, u[1:n, 1:n], Bin)

    # variável de tempo de conclusão por posição
    @variable(model, c[1:n] >= 0)

    # variável de tempo de conclusão por job (Cj)
    @variable(model, C[1:n] >= 0)

    # função objetivo: minimizar soma dos pesos * tempos de conclusão
    @objective(model, Min, sum(w[j] * C[j] for j in 1:n))

    # cada job deve ser atribuído exatamente a uma posição
    @constraint(model, [j in 1:n], sum(u[j,k] for k in 1:n) == 1)

    # cada posição deve conter exatamente um job
    @constraint(model, [k in 1:n], sum(u[j,k] for j in 1:n) == 1)

    # tempo de conclusão da primeira posição
    @constraint(model, c[1] >= sum(p[j] * u[j,1] for j in 1:n))

    # relação entre tempos de conclusão consecutivos
    @constraint(model, [k in 2:n],
        c[k] >= c[k-1] + sum(p[j] * u[j,k] for j in 1:n)
    )

    # definição de Cj (tempo de conclusão do job j)
    @constraint(model, [j in 1:n, k in 1:n],
        C[j] >= c[k] - M * (1 - u[j,k])
    )

    # resolve o modelo
    optimize!(model)

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

    # grava os resultados
    project_root = normpath(joinpath(@__DIR__, "..", ".."))
    results_dir = joinpath(project_root, "results")
    mkpath(results_dir)

    minutes = time_limit/60.0
    minutes_str = @sprintf("%.2f", minutes)

    open(joinpath(results_dir, filename), "w") do io
        println(io, "RESULTADOS")
        println(io, "Modelo: Assignment and Positional Date Variables [F4]")
        println(io, "Solver: HiGHS")
        println(io, "Tempo limite: $minutes_str minutos")
        println(io, "Função objetivo (min sum wj*Cj): ", obj_value)
        println(io, "Gap relativo: ", gap, "%")
        println(io, "\nTempo de conclusão de cada job (Cj):")
        for j in 1:n
            println(io, "C[$j] = ", round(value(C[j]), digits=2))
        end
        println(io, "\nTempo de conclusão de cada posição (ck):")
        for k in 1:n
            println(io, "c[$k] = ", round(value(c[k]), digits=2))
        end
    end

    println("Resultados salvos em: ", joinpath(results_dir, filename))
end

end
