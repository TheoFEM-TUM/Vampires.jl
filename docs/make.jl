using Documenter
using Vampires

makedocs(
    sitename = "Vampires.jl",
    format = Documenter.HTML(),
    modules = [Vampires],
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