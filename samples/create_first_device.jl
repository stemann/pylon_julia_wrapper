include(joinpath("..", "src", "PylonWrapper.jl"))

PylonWrapper.pylon_initialize()

transport_layer_factory = PylonWrapper.get_transport_layer_factory_instance()

try
    device = PylonWrapper.create_first_device(transport_layer_factory)
    device_info = PylonWrapper.get_device_info(device)
    vendor_name = PylonWrapper.get_vendor_name(device_info)
    model_name = PylonWrapper.get_model_name(device_info)
    serial_number = PylonWrapper.get_serial_number(device_info)
    println("$(vendor_name) $(model_name) $(serial_number)")
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
