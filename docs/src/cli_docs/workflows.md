# Workflows

## Convergence testing
```@docs
run_task(::Type{Val{:convergence}}, ::Type{Val{:make}}, ::Any)
```

## MD sampling
```@docs
run_task(::Type{Val{:supercell}}, ::Type{Val{:sample}}, ::Any)
```

## SCF/NSCF workflows
```@docs
run_task(::Type{Val{:nscf}}, ::Type{Val{:make}}, ::Any)
```