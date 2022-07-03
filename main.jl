function zakharov(x::Array{Int64, 1})::Float64
    d = length(x)
    sum1 = sum(x.^2)
    sum2 = sum(((1:d).*0.5).*x)

    sum1 + sum2^2 + sum2^4
end
