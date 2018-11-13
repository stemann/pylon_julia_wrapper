module Wrapper
    using CxxWrap
    @wrapmodule(joinpath(@__DIR__, "..", "build", "lib", "libpylon_julia_wrapper"), :define_pylon_wrapper)
    function __init__()
        @initcxx
    end
end
