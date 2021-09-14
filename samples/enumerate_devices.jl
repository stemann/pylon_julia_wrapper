using PylonWrapper

PylonWrapper.pylon_initialize()

try
    device_infos = PylonWrapper.enumerate_devices()
    println("Found $(length(device_infos)) device(s)")
    for device_info in device_infos
        vendor_name = PylonWrapper.get_vendor_name(device_info)
        model_name = PylonWrapper.get_model_name(device_info)
        serial_number = PylonWrapper.get_serial_number(device_info)
        println("$(vendor_name) $(model_name) $(serial_number)")
        camera = PylonWrapper.InstantCamera(device_info)
    end
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
