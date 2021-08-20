using Test
using PylonWrapper

@testset "init" begin
    expected_version = ENV["PYLON_VERSION"]
    expected_version_tuple = tuple([parse(UInt, s) for s in split(expected_version, ".")]...)
    @test PylonWrapper.get_pylon_version() == expected_version_tuple
    @test PylonWrapper.get_pylon_version_string() == expected_version
    @show PylonWrapper.pylon_initialize()
    @show PylonWrapper.pylon_terminate(true)
end
