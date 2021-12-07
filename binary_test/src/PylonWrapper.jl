module PylonWrapper
    import Base: getindex, iterate, IteratorSize, length

    using CxxWrap
    using pylon_julia_wrapper_jll

    @wrapmodule(pylon_julia_wrapper_jll.pylon_julia_wrapper, :define_pylon_wrapper)

    function __init__()
        @initcxx
    end

    InstantCamera(device_info::DeviceInfo) = InstantCamera(device_info, Cleanup_Delete)

    create_instant_camera_from_first_device() = create_instant_camera_from_first_device(DeviceInfo())

    create_instant_camera_from_first_device(device_info::DeviceInfo) = create_instant_camera_from_first_device(device_info, Cleanup_Delete)

    attach(camera::InstantCamera, device_info::DeviceInfo) = attach(camera, device_info, Cleanup_Delete)

    retrieve_result(camera::InstantCamera, timeoutMs::UInt32) = retrieve_result(camera, timeoutMs, TimeoutHandling_ThrowException)

    iterate(list::DeviceInfoList) = length(list) > 0 ? (list[1], 2) : nothing
    iterate(list::DeviceInfoList, i) = i <= length(list) ? (list[i], i+1) : nothing
    IteratorSize(list::DeviceInfoList) = length(list)
end
