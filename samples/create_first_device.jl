using PylonWrapper

PylonWrapper.pylon_initialize()

try
    camera = PylonWrapper.create_instant_camera_from_first_device()
    device_info = PylonWrapper.get_device_info(camera)
    vendor_name = PylonWrapper.get_vendor_name(device_info)
    model_name = PylonWrapper.get_model_name(device_info)
    serial_number = PylonWrapper.get_serial_number(device_info)
    println("$(vendor_name) $(model_name) $(serial_number)")
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
