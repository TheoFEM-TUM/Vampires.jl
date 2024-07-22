# Unit tests
split_line = Vampires.split_line

@testset "split_line tests" begin
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
end