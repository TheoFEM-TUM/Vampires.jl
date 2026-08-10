# Settings and command log

## Managing default settings

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

## Logging command history

For reproducibility, it may be useful to log the commands executed by Vampires. By default, command logging is disabled. To enable it, set the `log` tag to either `"local"` (commands are written to `Vampires.log` in the current working directory) or `"global"` (commands are written to `Vampires.log` in `\$HOME/.Vampires/`). It is recommended to change the default setting to enabling this feature, so that your workflows are automatically recorded via
```bash
vamp settings set --par log --val local
```
or
```bash
vamp settings set --par log --val global
```
Note that no commands that executed with the `--help` flag are logged.