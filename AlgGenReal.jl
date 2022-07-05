function ntaker_gen(iterable, n, fillvalue=nothing)
   padded_iterable = Iterators.flatten( (iterable, Iterators.repeated(fillvalue,n-1)) )
   n_partition = Iterators.partition( padded_iterable, n )
   (x for x in n_partition if length(x) == n)
end

ntaker(args...) = collect( ntaker_gen(args...) )

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
    max_gen::Int64
    fit_function::Function
    selection_function::Function
    cross_function::Function
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
            if pos >= partial_sum
                return i
            end
        end

        pop_size
    end

    selected = [copy(spin_roullete()) for _ = 1:new_size]
    println("selected: $(selected)")

    selected
end

function crossover(father::Array{Float64, 1}, mother::Array{Float64, 1})::Array{Float64, 1}
    d = length(father)

    collect(Iterators.flatten([mother[(d ÷ 2):(d-1)], father[1:(d ÷ 2)]]))
end

function uniform_mutation(gene::Array{Float64, 1})
    pos = rand(1:length(gene))
    value = rand(-5:10) + rand()

    gene[pos] = value
end

function run_ag(ag::AG)
    println("O que eu to fazendo?")
    println(ag)

    println("Gerando população inicial de $(ag.pop_size) tamanho $(ag.gen_size)")
    interval = -5:10
    initial_pop = [convert(Array{Float64, 1}, rand(interval, ag.gen_size)) for _ = 1:ag.pop_size]
    println(initial_pop)
    gen = copy(initial_pop)

    #for _ = 1:ag.max_gen
    #    println(ag.fit_function.(gen))
    #end

    while true
        println("Geração atual: $(gen)")
        println("Fit geração atual: $(ag.fit_function.(gen))")
        parents = gen[ag.selection_function(gen, ag.fit_function, 8)]
        
        # println("pais: $(parents)")
        # println("fitness pais: $(ag.fit_function.(parents))")
        parents_pair = ntaker(parents, 2, 0)

        new_gen = []
        for i in 1:length(parents_pair)
            pair = parents_pair[i]
            # println("pair: $(pair)")

            father = pair[1]
            mother = pair[2]


            if rand() < ag.cross_prob
                println("O par $(pair) sofrerá crossover")
                println("$(father) $(mother)")
                # parents_pair[i] = ag.cross_function(pair[0], pair[1])
                son = ag.cross_function(father, mother)
                println("Filho gerado: $(son)")
                push!(new_gen, son)
            end

            push!(new_gen, father)
            push!(new_gen, mother)
        end

        println("Nova geração: $(new_gen)")
        println("Fit nova geração: $(ag.fit_function.(new_gen))")
        break
    end
end

function main()
    println("Hello, World!")

    pop_size = 32
    cross_prob = 0.2
    mut_prob = 0.1
    gen_size = 2
    max_gen = 10
    fit_function = fitness
    selection_funtion = roulette
    cross_function = crossover
    
    ag = AG(pop_size, cross_prob, mut_prob, gen_size, max_gen, fit_function, selection_funtion, cross_function)
    run_ag(ag)
end

main()
