"""
    _get_key(method, key; iserror=false)

Generates a dynamic `Symbol` based on the provided method name and key. This function is used to create field names for output named tuples in a structured and flexible way.

# Arguments
- `method`: A `String` or `Symbol` representing the operation or method name (e.g., `"mean"`, `"sum"`).
- `key`: A `String` or `Symbol` representing an identifier or key to append to the `method`.
- `iserror::Bool` (optional): A keyword argument that, when set to `true`, appends the suffix `"_error"` to the generated symbol. Defaults to `false`.

# Returns
- A `Symbol` combining the method and key, with an optional `"_error"` suffix if `iserror` is `true`.
"""
_get_key(method, key; iserror=false) = Symbol("$method"*"_$key" * ifelse(iserror, "_error", ""))

"""
    calculate(::Type{Val{operation}}, key, x, [::Type{Val{:broadcasted}}])

A collection of methods to perform various calculations (`mean`, `diff`, `sum`, `maxdiff`, `last`, `maximum`, `minimum`) on input data `x`, returning results as a named tuple. These calculations can be done either directly on the input array or in a "broadcasted" mode where computations are applied over the last dimension of `x`.

# Arguments
- `operation::Type{Val{operation}}`: A `Val` type indicating the operation to perform. Supported operations are:
    - `:mean`: Compute the mean and standard deviation of `x`.
    - `:diff`: Compute the differences along the last dimension.
    - `:sum`: Compute the sum of all elements.
    - `:maxdiff`: Compute the maximum of the differences along the last dimension.
    - `:last`: Extract the last element.
    - `:maximum`: Compute the maximum value.
    - `:minimum`: Compute the minimum value.
- `key`: A key or identifier used to generate field names for the resulting named tuple. Passed to `_get_key`.
- `x`: The input array on which the operation is performed.
- `broadcasted::Type{Val{:broadcasted}}` (optional): If provided, indicates that the operation should be applied in a broadcasted fashion, typically across the last dimension of `x`.

# Returns
- A named tuple containing results of the specified operation. The field names are generated using `_get_key`.

# Details
- For each operation, when the `:broadcasted` mode is used, the computation is applied across slices of `x` along the penultimate dimension, with results aggregated into arrays.
- The `_get_key` function determines the field names for the output tuple based on the operation and the provided key.
"""
calculate(::Type{Val{:mean}}, key, x, broadcasted) = NamedTuple(zip([_get_key("mean", key), _get_key("mean", key, iserror=true)], [mean(x), std(x)]))
function calculate(::Type{Val{:mean}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("mean", key), _get_key("mean", key, iserror=true)]
    dims = Tuple(1:ndims(x)-1)
    vals = [dropdims(mean(x, dims=dims), dims=dims), dropdims(std(x, dims=dims), dims=dims)]
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:diff}}, key, x, broadcasted)
    ks = [_get_key("diff", key)]
    vals = [diff(x, dims=ndims(x))]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:diff}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("diff", key)]
    vals = [diff(x, dims=ndims(x)-1)]
    vals = cat([diff(selectdim(x, ndims(x), i), dims=ndims(x)-1) for i in axes(x, ndims(x))]..., dims=ndims(x))
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:sum}}, key, x, broadcasted)
    ks = [_get_key("sum", key)]
    vals = [sum(x)]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:sum}}, key, x, ::Type{Val{:broadcasted}})
    dims = Tuple(1:ndims(x)-1)
    ks = [_get_key("sum", key)]
    vals = [dropdims(sum(x, dims=dims), dims=dims)]
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:maxdiff}}, key, x, broadcasted)
    ks = [_get_key("maxdiff", key)]
    vals = [maximum(diff(x, dims=ndims(x)))]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:maxdiff}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("maxdiff", key)]
    vals = [maximum(diff(x, dims=ndims(x)-1))]
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:last}}, key, x, broadcasted)
    ks = [_get_key("last", key)]
    vals = [x[end]]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:last}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("last", key)]
    vals = [[selectdim(x, ndims(x), i)[end] for i in axes(x, ndims(x))]]
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:maximum}}, key, x, broadcasted)
    ks = [_get_key("maximum", key)]
    vals = [maximum(x)]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:maximum}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("maximum", key)]
    vals = [[maximum(selectdim(x, ndims(x), i)) for i in axes(x, ndims(x))]]
    return NamedTuple(zip(ks, vals))
end

function calculate(::Type{Val{:minimum}}, key, x, broadcasted)
    ks = [_get_key("minimum", key)]
    vals = [minimum(x)]
    return NamedTuple(zip(ks, vals))
end
function calculate(::Type{Val{:minimum}}, key, x, ::Type{Val{:broadcasted}})
    ks = [_get_key("minimum", key)]
    vals = [[minimum(selectdim(x, ndims(x), i)) for i in axes(x, ndims(x))]]
    return NamedTuple(zip(ks, vals))
end