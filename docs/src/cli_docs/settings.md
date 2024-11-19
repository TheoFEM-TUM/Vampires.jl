# Default settings

In certain scenarios, users may wish to modify the default settings for specific parameters to better suit their needs. This can be achieved using the `settings` tasks, which save updated default values in a configuration file located at \$HOME/.Vampires. This feature is especially helpful for job-related parameters, which typically remain consistent across multiple runs. By setting these defaults, users can avoid repeatedly specifying them, streamlining their workflow. However, with great power comes great responsibility. Changing certain default values can potentially disrupt expected behavior or lead to unintended consequences.

```@docs
run_task(::Type{Val{:settings}}, ::Type{Val{:read}}, ::Any)
```

```@docs
run_task(::Type{Val{:settings}}, ::Type{Val{:set}}, ::Any)
```

```@docs
run_task(::Type{Val{:settings}}, ::Type{Val{:rm}}, ::Any)
```