include(joinpath("..", "src", "wrapper.jl"))

@show Wrapper.get_pylon_version()
@show Wrapper.get_pylon_version_string()
@show Wrapper.pylon_initialize()
@show Wrapper.pylon_terminate(true)
