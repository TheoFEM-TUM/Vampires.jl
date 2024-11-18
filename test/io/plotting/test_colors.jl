@testset "Test color cycling" begin
    resetcolor()
    @test autocolor() == RGB(0.0, 0.45, 0.70)
    @test autocolor() == RGB(0.90, 0.60, 0.0)
    @test autocolor() == RGB(0.0, 0.60, 0.50)
    @test autocolor() == RGB(0.95, 0.90, 0.25)
    @test autocolor() == RGB(0.80, 0.60, 0.70)
    @test autocolor() == RGB(0.35, 0.70, 0.90)
    @test autocolor() == RGB(0.80, 0.40, 0.0)
    @test autocolor() == RGB(0.0, 0.0, 0.0)

    # Should start at blue again
    @test autocolor() == RGB(0.0, 0.45, 0.70)
    resetcolor()
    # Should still be blu
    @test autocolor() == RGB(0.0, 0.45, 0.70)
    resetcolor()
end