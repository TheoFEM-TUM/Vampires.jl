# Library Mode Documentation

```@autodocs
Modules = [Vampires]
Filter = x -> !(startswith(string(x), "_"))
Filter = x -> !(string(x) == "run_task")
```