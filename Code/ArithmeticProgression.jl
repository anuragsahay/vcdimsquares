#=
This program finds, for each prime in a given range, the largest arithmetic
sequence which is shattered by shifts of quadratic residues. Without loss of
generality, we need only consider sequences of consecutive integers.
=#

import Base
import Primes
using CircularArrays
using DelimitedFiles
using Plots

# These two functions are to help accept user input.
function prompt(T::Type, message::String)
    println(message)
    return parse(T, readline())
end

function prompt(T::Type, message::String, condition::Function)
    result = prompt(T, message)
    while !condition(result)
        result = prompt(T, message)
    end
    return result
end

function main()

    # Prompt user for input.
    println()

    println("Loop through primes in the interval [LOWER, UPPER].")
    LOWER = prompt(Int64, "-> Enter LOWER. (Must be at least 5.)", x->(x>=5))
    UPPER = prompt(Int64, "-> Enter UPPER.")

    println("Results will be output to FILENAME.csv.")
    println("-> Enter FILENAME.")
    FILENAME = readline()

    qs = []
    longests = []

    for q in Primes.primes(LOWER, UPPER)

        # Initialize negated quadratic residues
        nSq = CircularArray(zeros(q))
        for x in 0:(q-1)÷2
            nSq[-x^2] = 1
        end

        # Creates a q × n matrix with 1 in entry (i,j) if i + j is a quadratic residue.
        n = floor(Int64, log2(q))
        A = Array{Int64}(undef, q, n)
        for i in 1:n
            A[:,i] = nSq[i-1:q+i-2]
        end

        # Create a boolean vector of length 2^n to collect occurrences of restrictions.
        restrictions = CircularArray(falses(2^n))
        for x in A * [2^i for i in 0:n-1]
            restrictions[x] = true
        end

        # Determine the size of the largest shattered arithmetic progression.
        while !all(restrictions[0:2^n-1])
            restrictions[0:2^(n-1)-1] = restrictions[0:2^(n-1) - 1] .| restrictions[2^(n-1) : 2^n - 1]
            n -= 1
        end

        println("q = ", q, ",  n = ", n)
        push!(qs, q)
        push!(longests, n)
    end

    # Write data to file.
    writedlm(FILENAME * ".csv", zip(qs, longests))

    # Generate and save plot of data.
    myplot = scatter(qs, longests, label="", xlims=(LOWER,UPPER), ylims=(0,log2(UPPER)), seriescolor="black")
    plot!(myplot, log2, label="", seriescolor="red")
    png(myplot, FILENAME)

end

main()
