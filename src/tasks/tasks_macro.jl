"""
list of available tasks
"""


"""
    @run_task(task, subtask, args...)
    @run_task_recursive(task, subtask, args...)

This macro provides a convenient way to call any `run_task` (or `run_task_recursive`) method without having to explicitly convert `task` and `subtask` into Val-types.
Args can either be a dictionary or a set of `key = value` pairs.

# Arguments
- `task::Symbol`: The task name (e.g., incar).
- `subtask::Symbol`: The subtask name (e.g., `set`).
- `args`: A set of key-value pairs passed as arguments (e.g., `key1 = value1`) or a dictionary.

# Returns
- A quoted expression that, when evaluated, will call the `run_task` function with the `task`, `subtask`, and arguments packaged into a dictionary.

# Example
```julia
# Example 1: Call the `incar set` task with arguments
@run_task incar set par = ENCUT val = 250

# Example 2: Call the `kpoints make` task with a dictionary that contains arguments
args = get_default_args()
@run_task kpoints make args

# Example 3: Call the `runscript make` recursively.
@run_task_recursive runscript make
```
"""
macro run_task(task, subtask, args...)
    args_dict = _get_args_dict_from_third_arg(args...)
    return _get_run_task_quote(:normal, task, subtask, args_dict)
end

macro run_task_recursive(task, subtask, args...)
    args_dict = _get_args_dict_from_third_arg(args...)
    return _get_run_task_quote(:recursive, task, subtask, args_dict)
end

"""
    get_run_task_quote(r_flag, task, subtask, args_dict)

Generates a quoted expression for either `run_task` or `run_task_recursive` based on the provided flag `r_flag`.

This function takes in a flag `r_flag`, along with the task, subtask, and a dictionary of arguments (`args_dict`). Depending on whether the flag is `:normal` or `:recursive`, it generates the corresponding quoted expression to call either `run_task` or `run_task_recursive`. The task and subtask are dynamically converted to symbols and wrapped in `Val{Symbol()}`, while `args_dict` is passed as-is.

# Arguments
- `r_flag::Symbol`: A flag that determines whether to call `run_task` or `run_task_recursive`. It must be either `:normal` or `:recursive`.
- `task::Any`: The task name (typically a symbol or string), which will be converted to a `Val{Symbol()}`.
- `subtask::Any`: The subtask name (typically a symbol or string), which will be converted to a `Val{Symbol()}`.
- `args_dict`: A dictionary of arguments to be passed to the task or recursive task. The dictionary is passed as-is.

# Returns
- A quoted expression that, when evaluated, will call either `run_task` or `run_task_recursive` with the task, subtask, and arguments wrapped in `Val{Symbol()}`.
"""
function _get_run_task_quote(r_flag, task, subtask, args_dict)
    task_type = Val{task}
    subtask_type = Val{subtask}
    if r_flag == :normal
        return quote
            run_task($task_type, $subtask_type, $(esc(args_dict)))
        end
    elseif r_flag == :recursive
        return quote
            run_task_recursive($task_type, $subtask_type, $(esc(args_dict)))
        end
    end
end

"""
    get_args_dict_from_third_arg(third_arg...)

Converts the third argument, `third_arg`, into a dictionary of key-value pairs, where the keys and values are extracted from the arguments within `third_arg`.
If third argument is a symbol, the symbol itself is returned.

For example, if `third_arg` contains expressions like `:key1 = "value1"`, `:key2 => "value2"`, the function will return a dictionary like:
Dict("key1" => "value1", "key2" => "value2")
"""
function _get_args_dict_from_third_arg(third_arg...)
    args_dict = get_default_args()
    for expression in third_arg
        key, value = expression.args
        args_dict[string(key)] = string(strip(string(value), ['(', ')']))
    end
    return args_dict
end
_get_args_dict_from_third_arg(third_arg::Symbol) = third_arg