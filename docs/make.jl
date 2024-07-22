using Documenter
using Vampires

makedocs(
    sitename = "Vampires Documentation",
    format = Documenter.HTML(),
    modules = [Vampires],
    pages = [
        "Welcome" => "index.md"
    ]
)
#TODO

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#