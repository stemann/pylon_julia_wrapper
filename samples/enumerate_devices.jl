include(joinpath("..", "src", "PylonWrapper.jl"))

PylonWrapper.pylon_initialize()

transport_layer_factory = PylonWrapper.get_transport_layer_factory_instance()

try
    device_infos = PylonWrapper.enumerate_devices(transport_layer_factory)
    println("Found $(length(device_infos)) device(s)")
    for device_info in device_infos
        vendor_name = PylonWrapper.get_vendor_name(device_info)
        model_name = PylonWrapper.get_model_name(device_info)
        serial_number = PylonWrapper.get_serial_number(device_info)
        println("$(vendor_name) $(model_name) $(serial_number)")
        device = PylonWrapper.create_device(transport_layer_factory, device_info)
        camera = PylonWrapper.InstantCamera(device)
    end
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
