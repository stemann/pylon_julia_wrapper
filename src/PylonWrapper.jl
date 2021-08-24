module PylonWrapper
    import Base: iterate, IteratorSize, length

    using CxxWrap
    @wrapmodule(joinpath(@__DIR__, "..", "build", "lib", "libpylon_julia_wrapper"), :define_pylon_wrapper)

    function __init__()
        @initcxx
    end

    retrieve_result(camera::InstantCamera, timeoutMs::UInt32) = retrieve_result(camera, timeoutMs, TimeoutHandling_ThrowException)

    iterate(list::DeviceInfoList) = length(list) > 0 ? (list[1], 2) : nothing
    iterate(list::DeviceInfoList, i) = i <= length(list) ? (list[i], i+1) : nothing
    IteratorSize(list::DeviceInfoList) = length(list)
end
