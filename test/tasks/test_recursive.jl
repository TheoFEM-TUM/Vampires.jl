@testset "readfolders sorting" begin
    mktempdir() do tmp
        # Create dummy folders
        foldernames = ["config_2", "config_1", "config_10", "alpha", "zeta"]
        for name in foldernames
            mkdir(joinpath(tmp, name))
        end

        sorted_folders = Vampires.readfolders(tmp)

        @test sorted_folders == ["alpha", "config_1", "config_2", "config_10", "zeta"]
    end

    mktempdir() do tmp
        # Folders with no trailing numbers
        foldernames = ["gamma", "beta", "alpha"]
        for name in foldernames
            mkdir(joinpath(tmp, name))
        end

        sorted_folders = Vampires.readfolders(tmp)

        @test sorted_folders == sort(foldernames)
    end

    mktempdir() do tmp
        # Mixed: some without numbers, some with
        foldernames = ["run_5", "run_2", "A", "run_12", "X"]
        for name in foldernames
            mkdir(joinpath(tmp, name))
        end

        sorted_folders = Vampires.readfolders(tmp)

        @test sorted_folders == ["A", "X", "run_2", "run_5", "run_12"]
    end
end