export mutualinfo, Kraskov1, Kraskov2

abstract type MutualInformationEstimator <: EntropyEstimator end

"""
## Mutual information

Mutual information ``I`` between (potentially collections of) variables ``X`` and ``Y`` 
is defined as 

```math
I(X; Y) = \\sum_{y \\in Y} \\sum_{x \\in X} p(x, y) \\log \\left( \\dfrac{p(x, y)}{p(x)p(y)} \\right)
```

Here, we rewrite this expression as the sum of the marginal entropies, and extend the 
definition of ``I`` to use generalized Rényi entropies

```math
I^{\\alpha}(X; Y) = H^{\\alpha}(X) + H^{\\alpha}(Y) - H^{\\alpha}(X, Y),
```

where ``H^{\\alpha}(\\cdot)`` is the generalized Renyi entropy of order ``\\alpha``.

## General interface

    mutualinfo(x, y, est; base = 2, α = 1)

Estimate mutual information between `x` and `y`, ``I^{\\alpha}(x; y)``, using the provided 
entropy/probability estimator `est` and Rényi entropy of order `α` (defaults to `α = 1`, 
which is the Shannon entropy), with logarithms to the given `base`.

Both `x` and `y` can be vectors or (potentially multivariate) [`Dataset`](@ref)s.

## Binning based

    mutualinfo(x, y, est::VisitationFrequency{RectangularBinning}; base = 2, α = 1)

Estimate ``I^{\\alpha}(x; y)`` using a visitation frequency estimator. 

See also [`VisitationFrequency`](@ref), [`RectangularBinning`](@ref).

## Kernel density based 

    mutualinfo(x, y, est::NaiveKernel{Union{DirectDistance, TreeDistance}}; base = 2, α = 1)

Estimate ``I^{\\alpha}(x; y)`` using a naive kernel density estimator. 

It is possible to use both direct evaluation of distances, and a tree-based approach. 
Which approach is faster depends on the application. 

See also [`NaiveKernel`](@ref), [`DirectDistance`](@ref), [`TreeDistance`](@ref).

## Nearest neighbor based

    mutualinfo(x, y, est::KozachenkoLeonenko; base = 2)
    mutualinfo(x, y, est::Kraskov; base = 2)
    mutualinfo(x, y, est::Kraskov1; base = 2)
    mutualinfo(x, y, est::Kraskov2; base = 2)

Estimate ``I^{1}(x; y)`` using a nearest neighbor based estimator. Choose between naive 
estimation using the [`KozachenkoLeonenko`](@ref) or [`Kraskov`](@ref) entropy estimators, 
or the improved [`Kraskov1`](@ref) and [`Kraskov2`](@ref) dedicated ``I`` estimators. The 
latter estimators reduce bias compared to the naive estimators.

*Note: only Shannon entropy is possible to use for nearest neighbor estimators, so the 
keyword `α` cannot be provided; it is hardcoded as `α = 1`*. 

See also [`KozachenkoLeonenko`](@ref), [`Kraskov`](@ref), [`Kraskov1`](@ref), 
[`Kraskov2`](@ref).
"""
function mutualinfo end 

mutualinfo(x::Vector_or_Dataset, y::Vector_or_Dataset) = 
    error("Estimator missing. Please provide a valid estimator as the third argument.")

function mutualinfo(x::Vector_or_Dataset, y::Vector_or_Dataset, est; base = 2, α = 1)
    X = genentropy(Dataset(x), est; base = base, α = α)
    Y = genentropy(Dataset(y), est; base = base, α = α)
    XY = genentropy(Dataset(x, y), est; base = base, α = α)
    MI = X + Y - XY 
end 

include("nearestneighbor.jl")