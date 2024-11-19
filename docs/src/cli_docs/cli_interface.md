# Task overview

Each command begins with the main executable (`vamp` by default), followed by two positional arguments: `task` and `subtask` (the latter is sometimes optional). The `task` typically represents a category or file type (e.g., `incar`, `outcar`), while the `subtask` is an action verb (e.g., `make`, `read`, `plot`) describing the operation to be performed. After these positional arguments, various keyword arguments can be added to specify the exact operation the user wants to perform.

## Input files

```@docs
run_task(::Type{Val{:incar}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:kpoints}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:supercell}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:convergence}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:nscf}}, ::Type{Val{:none}}, ::Any)
```

## Output files

```@docs
run_task(::Type{Val{:outcar}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:eigenval}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:doscar}}, ::Type{Val{:none}}, ::Any)
```

```@docs
run_task(::Type{Val{:xdatcar}}, ::Type{Val{:none}}, ::Any)
```

## Bash/Slurm scripts

```@docs
run_task(::Type{Val{:job}}, ::Type{Val{:none}}, ::Any)
```

## Wannier90

```@docs
run_task(::Type{Val{:w90}}, ::Type{Val{:none}}, ::Any)
```