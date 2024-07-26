path = string(@__DIR__)*"/"

keyword = "ENCUT"
values = ["300", "350", "400"]
convergence_create_subdirectories(keyword, values; path=path, verbose=false)

for (folder, value) in zip(keyword * "_" .* values, values)
    @test "INCAR" in readdir(path*folder) && "KPOINTS" in readdir(path*folder) && "POSCAR" in readdir(path*folder) && "POTCAR" in readdir(path*folder)
    incar_ = read_incar(path*folder*"/INCAR")
    @test get_value_for_keyword(keyword, incar_) == value
    rm(path*folder, recursive=true)
end

