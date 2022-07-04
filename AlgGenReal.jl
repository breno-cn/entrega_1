function zakharov(x::Array{Float64, 1})::Float64
    d = length(x)
    sum1 = sum(x.^2)
    sum2 = sum(((1:d).*0.5).*x)

    sum1 + sum2^2 + sum2^4
end

struct AG
    pop_size::Int64
    cross_prob::Float64
    mut_prob::Float64
    gen_size::Int64
    fit_function::Function
    selection_function::Function
end

function fitness(gene::Array{Float64, 1})::Float64
    # Como o mínimo global é 0, apenas o resultado
    # da função já serve
    zakharov(gene)
end

function roulette(pop::Array{Array{Float64, 1}}, fit_function::Function, new_size::Int64)::Array{Int64, 1}
    total_fit = sum(fit_function.(pop))
    pop_size = length(pop)
    println("fitness total = $(total_fit)")
    
    function spin_roullete()
        pos = rand() * total_fit
        partial_sum = 0

        for i = 1:pop_size
            partial_sum += fit_function(pop[i])
            if pos <= partial_sum
                return i
            end
        end
    end

    selected = [copy(spin_roullete()) for _ = 1:new_size]
    println(selected)

    selected
end

function run_ag(ag::AG)
    println("O que eu to fazendo?")
    println(ag)

    println("Gerando população inicial de $(ag.pop_size) tamanho $(ag.gen_size)")
    interval = -5:10
    initial_pop = [convert(Array{Float64, 1}, rand(interval, ag.gen_size)) for _ = 1:ag.pop_size]
    println(initial_pop)

    # teste fitness
    fit_test = [ag.fit_function(x) for x = initial_pop]
    println(fit_test)

    # teste seleção
    selected_pos = ag.selection_function(initial_pop, ag.fit_function, 2)
    selected = initial_pop[selected_pos]
    println(selected)
    println(ag.fit_function.(selected))
end

function main()
    println("Hello, World!")

    pop_size = 10
    cross_prob = 0.2
    mut_prob = 0.1
    gen_size = 2
    fit_function = fitness
    selection_funtion = roulette
    
    ag = AG(pop_size, cross_prob, mut_prob, gen_size, fit_function, selection_funtion)
    run_ag(ag)
end

main()
