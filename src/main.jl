import Pkg
Pkg.activate(".")
include("models/model1.jl")
include("models/model2.jl")
using .Model1
using .Model2

# dados da instância completo com 40 jobs
p = [41, 18, 66, 42, 100, 71, 89, 19, 92, 3, 75, 57, 46, 2, 53, 57, 17, 9, 30, 25, 90, 19, 93, 69, 76, 79, 5, 100, 16, 89, 7, 32, 78, 4, 21, 85, 60, 29, 43, 77]
w = [9, 10, 5, 5, 3, 1, 5, 9, 1, 8, 1, 10, 5, 8, 9, 1, 9, 4, 6, 3, 2, 5, 4, 1, 5, 6, 7, 7, 5, 7, 3, 6, 8, 6, 4, 6, 9, 4, 6, 2]
d = [928, 623, 690, 630, 796, 811, 728, 670, 618, 788, 609, 629, 984, 841, 918, 809, 613, 644, 724, 764, 667, 713, 797, 663, 951, 920, 716, 892, 677, 774, 894, 652, 988, 696, 872, 713, 971, 719, 956, 836]


# dados da instância com 20 jobs e dj/2
p_half = p[1:20]
w_half = w[1:20]
d_half = d[1:20] ./ 2

# executa o modelo 1 e o modelo 2, cada um utilizando primeiro uma instância com 20 jobs e posteriormente com todos os 40 jobs
# primeiro cada modelo é executado por 20 minutos e posteriormente 60 minutos
# totalizam-se 8 chamadas

Model1.run_model_1(p_half, w_half, d_half;
    time_limit = 60.0 * 15,
    filename = "result-model1-15min (20 jobs).txt"
)


Model1.run_model_1(p_half, w_half, d_half;
    time_limit = 60.0 * 60,
    filename = "result-model1-60min (20 jobs).txt"
)

Model2.run_model_2(p_half, w_half, d_half;
    time_limit = 60.0 * 15,
    filename = "result-model2-15min (20 jobs).txt"
)

Model2.run_model_2(p_half, w_half, d_half;
    time_limit = 60.0 * 60,
    filename = "result-model2-60min (20 jobs).txt"
)

Model1.run_model_1(p, w, d;
    time_limit = 60.0 * 15,
    filename = "result-model1-15min (all 40 jobs).txt"
)

Model1.run_model_1(p, w, d;
    time_limit = 60.0 * 60,
    filename = "result-model1-60min (all 40 jobs).txt"
)

Model2.run_model_2(p, w, d;
    time_limit = 60.0 * 15,
    filename = "result-model2-15min (all 40 jobs).txt"
)

Model2.run_model_2(p, w, d;
    time_limit = 60.0 * 60,
    filename = "result-model2-60min (all 40 jobs).txt"
)