# Unit tests
split_line = Vampires.split_line

@testset "split_line" begin
    # Basic tests
    @test split_line("This is a test") == ["This", "is", "a", "test"]
    @test split_line("Hello World") == ["Hello", "World"]

    # Tests with multiple spaces
    @test split_line("This  is   a test") == ["This", "is", "a", "test"]
    @test split_line("  Julia   language  ") == ["Julia", "language"]

    # Edge cases
    @test split_line("") == []
    @test split_line(" ") == []
    @test split_line("   ") == []
    @test split_line("OneWord") == ["OneWord"]
    @test split_line("   OneWord   ") == ["OneWord"]

    # Tests with special characters
    @test split_line("Hello, world! How are you?") == ["Hello,", "world!", "How", "are", "you?"]
    @test split_line("Julia, Python, and C++") == ["Julia,", "Python,", "and", "C++"]

    # Test with `,`
    @test split_line("This,is,a,test", char=",") == ["This", "is", "a", "test"]
    # Test with custom delimiter with no matches
    @test split_line("No delimiters here", char=",") == ["No delimiters here"]

    # Test with custom delimiter at the start and end
    @test split_line(",Delimiters,at,start,and,end,", char=",") == ["Delimiters", "at", "start", "and", "end"]

    # Test with custom delimiter with consecutive delimiters
    @test split_line("Consecutive,,delimiters", char=",") == ["Consecutive", "delimiters"]

    # Test with mixed whitespace characters
    @test split_line("Mixed\twhitespace\ncharacters\r\n", char=r"\s") == ["Mixed", "whitespace", "characters"]

    # Test with different unicode characters as delimiters
    @test split_line("Unicode✨delimiters✨here", char="✨") == ["Unicode", "delimiters", "here"]
    @test split_line("Special*characters*in*delimiter", char="*") == ["Special", "characters", "in", "delimiter"]
    @test split_line("Escape\\nsequences\\nare\\ninteresting", char="\\n") == ["Escape", "sequences", "are", "interesting"]

    # Test with long string
    @test split_line("This is a very long string to test the splitting function with a default space delimiter") == ["This", "is", "a", "very", "long", "string", "to", "test", "the", "splitting", "function", "with", "a", "default", "space", "delimiter"]
end

@testset "concat values" begin
    # Test 1: test basic functionality with vector of matrices
    vals_1 = [rand(4, 4) for _ in 1:2]
    vals_out = Vampires._concat_values(vals_1)
    @test size(vals_out) == (4, 4, 2)
    @test vals_out[:, :, 1] == vals_1[1]
    @test vals_out[:, :, 2] == vals_1[2]

    # Test 2: test special case for Vector of floats
    vals_2 = rand(4)
    vals_out = Vampires._concat_values(vals_2)
    @test vals_out == vals_2

    # Test 3: test with strings
    @test Vampires._concat_values([["Hello", "World"], ["foo", "bar"]]) == ["Hello" "foo"; "World" "bar"]

    # Test 4: vector of strings should return itself
    Vampires._concat_values(["Hello", "World"])
end