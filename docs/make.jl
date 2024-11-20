using Documenter
using Vampires

makedocs(
    modules = [Vampires],
    sitename = "Vampires.jl",
    checkdocs = :exports,
    format = Documenter.HTML(;
    # Use clean URLs, unless built as a "local" build
    prettyurls=get(ENV, "CI", nothing) == "true",
    edit_link="master",
    size_threshold=nothing,  # do not fail build if large HTML outputs
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "man/install.md",
            "man/cli_interface.md",
            "man/examples.md",
            "man/library.md"
        ],
        "Tutorials" => [
            "tutorials/silicon.md"
        ],
    ]
)