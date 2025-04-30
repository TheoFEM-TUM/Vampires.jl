# Job management

## Generate a Run Script

A run script represents a bash script, e.g., to run VASP in each subfolder. The command to run can be controlled with the `exe` keyword. You can add files to be removed in each subfolder using the `exclude` keyword. The `r` flag will run `exe` in each subfolder. The `npar` keyword can be used to split the workload for expensive computations (default is 1).
```bash
vamp -r runscript make --npar 2 --exe vasp_std --exclude WAVECAR,CONTCAR
```

## Generate a Job Script

Vampires can also generate SLURM job scripts for you, streamlining the submission process. To save time and reduce repetition, it's recommended to configure default settings (e.g., for modules, account name, partition, etc.) in your Vampires settings file (`vamp settings set --par <...> --val <...>`).

This way, you only need to specify what's different for each job.

To explore all available options and keyword arguments, run:

```bash
vamp job make --help
```
Note that if `exe`, e.g., a run script, exists multiple times (with numbering), a job script is created for each run script.

## Managing jobs on a cluster locally

If your cluster uses the SLURM job scheduler and SSH for remote access, Vampires allows you to submit, monitor, and cancel jobs directly from your local machine. To get started, follow these setup steps:

### Mount the cluster's storage (e.g., using sshfs).
### Setup a config file for ssh (so that ssh <hostname>) establishes a connection to the cluster. For example:
```ssh
Host your-cluster
    HostName cluster.address.com
    User your-username
    IdentityFile ~/.ssh/your-private-key
```
### Set relevant default settings for convenience (optional but recommended).
```bash
vamp settings set --par hostname --val <hostname>
vamp settings set --par account --val <account>
```
### Usage 
Once the setup is complete, you can begin using Vampires to manage your SLURM jobs directly from your local terminal — as long as you're working within the mounted cluster storage.

Submit a job (this will try to submit ALL jobs in the current folder)
```bash
vamp job submit
```
Check Job Status
```bash
vamp job status
```
Cancel a Job
```bash
vamp job cancel --N <job_id>
```
