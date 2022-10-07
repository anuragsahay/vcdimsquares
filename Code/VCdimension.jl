#=
This program computes the VC dimension of the class of shifts of squares modulo
primes p. This is done by doing depth-first search for the largest shattered
subset.
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

    # Prompt user for input data.
    println()

    println("Loop through primes in the interval [LOWER, UPPER].")
    LOWER = prompt(Int64, "-> Enter LOWER. (Must be at least 5.)", x->(x>=5))
    UPPER = prompt(Int64, "-> Enter UPPER.")

    println("For each prime q, exit the search for the largest shattered subset early after finding a shattered set of size at least floor(log2(q)) - DISCOUNT. (DISCOUNT = 0 will return the true VC dimension.)")
    DISCOUNT = prompt(Int64, "-> Enter DISCOUNT. (Must be a nonnegative integer.)", x->(x>=0))

    println("Results will be output to FILENAME.csv.")
    println("-> Enter FILENAME.")
    FILENAME = readline()

    # Initialize the data to write to file.
    qs = []
    vcdims = []

    # Loop through the primes q lying between LOWER and UPPER.
    for q in Primes.primes(LOWER, UPPER)

        print("q = ", q)

        # Record log2(q)
        logq = floor(Int64, log2(q))
        vcdim_goal = logq - DISCOUNT

        # Construct the set {-x^2 : x is in F_q}.
        nSq = CircularArray(zeros(Int64, q))
        for x in 0:(q-1)÷2
            nSq[-x^2] = 1
        end

        #=
        We iterate over subsets Y containing both 0 and 1 (WLOG). To do this, we
        do a depth-first search through the tree whose root is the set {0,1},
        and where Y is the parent of Z if Y = Z - {max(Z)}.
        =#
        Y = [0,1]
        largest_size = 2
        running = true
        while running

            n = length(Y)

            #=
            Compute "shattering index" of subset. This is the theoretical
            maximum number of elements we can add to Y and still have hope that
            it can be shattered.
            =#
            A = Array{Int64}(undef, q, n)
            for i in 1:n
                A[:,i] = nSq[Y[i]:Y[i]+q-1]
            end

            counts = CircularArray(zeros(Int64, 2^n))
            for x in A * [2^i for i in 0:n-1]
                counts[x] += 1
            end

            countmin = minimum(counts)
            shatteringindex = (countmin == 0) ? -1 : floor(Int64, log2(countmin))

            # Record new largest size if we shatter.
            largest_size = (countmin > 0 && n > largest_size) ? n : largest_size

            #=
            Determine if there is hope for some superset of Y to be a maximally
            shattered subset. Two conditions must be met:
                (1) The shattering index must be large enough to allow for the
                    possibility that a superset of Y of size largest_size + 1
                    can be shattered.
                (2) There must be a superset of Y of size largest_size + 1 along
                    the current "branch" of the search.
            If both of these conditions are met, append an element to Y. That
            is, traverse deeper into the tree. Otherwise, traverse laterally
            through the tree.
            =#
            if n + shatteringindex > largest_size && q - 1 - Y[end] + n > largest_size
                # Append an element to Y.
                push!(Y, Y[end]+1)
            else
                # Prune the most recently added elements from Y until we can
                # make a lateral move.
                j = 0
                while Y[end] == q - 1 - j
                    pop!(Y)
                    j += 1
                end

                # Move laterally.
                Y[end] += 1

                print(length(Y) == 3 ? "+" : "")
                print(length(Y) == 4 ? "-" : "")
                print(length(Y) == 5 ? "." : "")
            end

            # Terminate the process if we reach the VC dimension goal or if we
            # have iterated through the entire tree. Otherwise, keep running.
            running = largest_size < vcdim_goal && Y[2] == 1
        end

        # Record the VC dimension.
        push!(qs, q)
        push!(vcdims, largest_size)
        println()
        println("  VCdim ≧ ", largest_size)
        println("  logq = ", logq)
    end

    # Write data to file.
    writedlm(FILENAME * ".csv", zip(qs, vcdims))

    # Plot data.
    myplot = scatter(qs, vcdims, yticks = [k for k in 0:floor(Int64, log2(UPPER))], label="", xlims=(LOWER,UPPER), ylims=(0,log2(UPPER)), seriescolor="black")
    plot!(myplot, log2, label="", seriescolor="red")
    png(myplot, FILENAME)

end

main()
