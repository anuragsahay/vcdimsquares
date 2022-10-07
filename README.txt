###########################################################
# The VC-Dimension of Quadratic Residues in Finite Fields #
###########################################################

Brian McDonald
bmcdon11@ur.rochester.edu

Anurag Sahay
anuragsahay@rochester.edu

Emmett L. Wyman
emmett.wyman@rochester.edu

This directory contains the Julia code for the numerical experiments in [REFERENCE PAPER HERE], along with the raw data and graphics featured in the paper. In the "Code" folder, there are three Julia files, one for each experiment in the paper:

(1) VCdimension.jl
(2) ArithmeticProgression.jl
(3) RandomSubsets.jl

In the "Data" folder, there are three similarly titled subfolders containing the outputs of these experiments. All plots in the paper are contained in this directory along with the raw data they were generated from. We explain the outputs below.

In folder "VCdimension":

vcdim.csv
This file contains the raw output data of the code VCdimension.jl. The data is arranged in two columns. The first column consists of the prime numbers in the interval [5,300] in ascending order. The second column is the size of the largest shattered subset of F_q found by the code.

vcdim.png
This file is a plot of the data in the first two columns of vcdim.csv (the black scatter plot), along with the graph of log2(q) (the red curve).

lazyvcdim.csv
This file is in the same as vcdim.csv but for two differences: (1) The first column consists of primes ranging over [5, 500] in ascending order, and (2) the corresponding value in the second column is the largest shattered subset of F_q found by the program, except the program returns early once it has found a shattered subset of size one less than the theoretical maximum.

lazyvcdim.png
This is a plot of the data in lazyvcdim.csv in the same format as vcdim.png.

In folder "ArithmeticProgression":

arithmetic.csv
This is the output of "ArithmeticProgression.jl". The data is arranged in two columns. The first is the set of primes q in the interval [5, 200000] in ascending order. The corresponding value in the second column is the largest n for which the set {0,1,...,n-1} in F_q is shattered.

arithmetic.png
This is a scatter plot of the data in arithmetic.csv in the same format as vcdim.png and lazyvcdim.png.

logscalearithmetic.png
This is a scatter plot of the data in arithmetic.csv in the same format as arithmetic.png, except that the horizontal axis is on a logarithmic scale, and the graphs of both log2(q) and 0.5*log2(q) are plotted in red.

In folder "RandomSubsets":

For each n = 5, 6, ..., 12, there are files titled samplesn.csv and samplesn.png. Both are explained below.

samplesn.csv
This is the output data of RandomSubsets.jl. The data is arranged in two columns. The first column contains the values n/log2(q) where q ranges over a random selection of the primes for which n/log2(q) stays within the interval [0.7, 0.85]. The corresponding value in the second column is the proportion of the 1000 randomly selected subsets of size n in F_q which are shattered. For the sake of time, not all primes q are considered. In fact, primes are randomly selected in such a way so that there are about 100 data points maximum for each file.

samplesn.png
This is a straightforward plot of the series in samplesn.csv, where the first and second column are the horizontal and vertical coordinates, respectively.

