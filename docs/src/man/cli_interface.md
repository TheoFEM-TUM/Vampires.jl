# CLI interface

Each command begins with the main executable (`vamp` by default), followed by two positional arguments: `task` and `subtask` (the latter is sometimes optional). The `task` typically represents a category or file type (e.g., `incar`, `outcar`), while the `subtask` is an action verb (e.g., `make`, `read`, `plot`) describing the operation to be performed. After these positional arguments, various keyword arguments can be added to specify the exact operation the user wants to perform.

```@docs
run_task
```
