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
            "man/examples.md",
        ],
        "CLI Interface" => [
            "cli_docs/cli_interface.md",
            "cli_docs/settings.md",
            "cli_docs/input.md",
            "cli_docs/output.md",
            "cli_docs/structure.md",          
            "cli_docs/workflows.md",
            "cli_docs/job.md",
        ],
        "Tutorials" => [
            "tutorials/silicon.md",
            "tutorials/supercell.md",
            "tutorials/wannier90.md"
        ],
        "Library Mode" => [
            "man/library.md"
        ]
    ]
)