import Base
import Primes
using Plots
using CircularArrays
using DelimitedFiles
using LinearAlgebra

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

    println("Generate one plot for each integer in the range [NLOWER, NUPPER].")
    NLOWER = prompt(Int64, "-> Enter NLOWER. (Must be a positive integer.)", x->x>0)
    NUPPER = prompt(Int64, "-> Enter NUPPER. (Must be an integer >= NLOWER.)", x->x>=NLOWER)

    println("Subsets sampled will have sizes between A*log2(q) and B*log2(q).")
    lowerlimit = prompt(Float64, "-> Enter A. (Must be in the interval [0,1].)", x->(0<=x && x<=1))
    upperlimit = prompt(Float64, "-> Enter B. (Must be in the interval (A,1].)", x->(lowerlimit<x && x<=1))

    println("Primes will be randomly skipped such that about PRIMES_PER_BATCH are considered.")
    primes_per_batch = prompt(Float64, "-> Enter PRIMES_PER_BATCH. (If a negative number is entered, every prime will be considered.)")

    println("For each size of subset, we will test a number of randomly selected samples equal to SAMPLES.")
    samples = prompt(Int64, "-> Enter SAMPLES. (Must be a positive integer. 1000 recommended.)", x->(x>0))

    println("Raw data will be output to FILENAME.csv. The plot of the data will be output to FILENAME.png.")
    println("-> Enter FILENAME.")
    FILENAME = readline()

    println()
    println("Starting...")

    xs = []
    ys = []
    for n in NLOWER:NUPPER
        push!(xs, [])
        push!(ys, [])
    end

    for q in Primes.primes(ceil(Int64,2^(NLOWER/upperlimit)), floor(Int64,2^(NUPPER/lowerlimit)))

        #=
        Skip prime q with probability such that the expected number of
        primes considered per batch is roughly primes_per_batch. This is
        done via the prime number theorem. If primes_per_batch is non-
        positive, then consider every prime.
        =#
        prob = primes_per_batch > 0 ? primes_per_batch / (q * log(upperlimit/lowerlimit)) : 1
        if rand() > prob
            continue
        end

        # Initialize set of negated squares.
        nSq = CircularArray(0::Int64, q)
        for x in 0:(q-1)÷2
            nSq[-x^2] = 1
        end

        # Iterate over subset sizes n from lowerlimit*log2(q) to upperlimit*log2(q).
        for n in max(ceil(Int64, lowerlimit*log2(q)), NLOWER) : min(floor(Int64, upperlimit*log2(q)), NUPPER)

            number_shattered = 0 # Counts the number of shattered subsets.

            # For vectorized operations.
            A = Matrix{Int64}(undef, q, n)
            powers2 = [2^k::Int64 for k in 0:n-1]
            addresses = Vector{Int64}(undef, q)
            restrictions = falses(2^n)

            for _ in 1:samples
                # 1. Generate a random subset of size n.
                subset = Set{Int64}()
                while length(subset) < n
                    push!(subset, rand(0:q-1))
                end

                # 2. Determine if subset shatters.
                fill!(restrictions, false)

                # 2. a. Construct shifts.
                j = 1
                for y in subset
                    A[:,j] = nSq[y : y + q - 1]
                    j += 1
                end

                # 2. b. Find the addresses using matrix multiplication
                mul!(addresses, A, powers2)

                # 2. c. Find the realized restrictions.
                for a in addresses
                    restrictions[a+1] = true
                end

                # 3. Increment count if shattered.
                number_shattered += all(restrictions) ? 1 : 0
            end

            # Record data.
            push!(xs[n - NLOWER + 1], n/log2(q))
            push!(ys[n - NLOWER + 1], number_shattered/samples)
        end

        println(q, " done.")
    end

    # Create plots and write data.
    for n in NLOWER:NUPPER
        # Write data to file.
        writedlm(FILENAME * string(n) * ".csv", zip(xs[n - NLOWER + 1], ys[n - NLOWER + 1]))

        # Generate and save plot.
        plot = scatter(xs[n - NLOWER + 1], ys[n - NLOWER + 1], label="", xlims=(lowerlimit-0.01,upperlimit+0.01), ylims=(-0.02,1.02), seriescolor="black")
        png(plot, FILENAME * string(n))
    end
end

main()
