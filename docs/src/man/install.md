# Install `Vampires.jl`
### How to install `Vampires.jl` in Julia

* First, you need to install Julia itself from the [Julia homepage](https://julialang.org/downloads/)
* Next, clone the git repository to your computer
* Then, run the install packages script form the main package folder
```bash
path=<path_to_your_bashrc> && julia vampires_install.jl --bashrc $path && source $path
```
You can then call the `Vampires` CLI interface using `vamp`.