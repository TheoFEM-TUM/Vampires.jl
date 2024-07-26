using Documenter
using Vampires

makedocs(
    modules = [Vampires],
    sitename = "Vampires.jl",
    format = Documenter.HTML(;
    # Use clean URLs, unless built as a "local" build
    prettyurls=CONTINUOUS_INTEGRATION,
    canonical="https://docs.dftk.org/stable/",
    edit_link="master",
    size_threshold=nothing,  # do not fail build if large HTML outputs
    mathengine,
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "man/install.md",
            "man/cli_interface.md",
            "man/examples.md"
        ],
        "tasks.md"
    ]
)