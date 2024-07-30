function run_task(::Type{Val{:nscf}}, ::Type{Val{:make}}, args)
    nscf_create_subdirectories(args["p"], args["kpoints"])
    filename = "run_nscf.sh"
    write_run_script(args["vasp_exe"], args["p"], cb="ln scf/CHGCAR nscf/CHGCAR", out=filename)
    add_path_to_folders.(filename, ["scf", "nscf"])
end