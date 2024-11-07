function run_task(task, ::Type{Val{:plot}}, args)
    param = args["par"]
    keys, values = run_task(task, Val{Symbol("read")}, args)
    fig = plot(title="$param plot", xlabel="k-point distance", ylabel="$param", legend=false)
    for (key, value) in zip(keys, values)
        if occursin(param, key)
            plot(value)
        end
    end
    savefig(fig, output_filename)
end