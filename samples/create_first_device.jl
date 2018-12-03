include(joinpath("..", "src", "wrapper.jl"))

Wrapper.pylon_initialize()

transport_layer_factory = Wrapper.get_transport_layer_factory_instance()

try
    device = Wrapper.create_first_device(transport_layer_factory)
    device_info = Wrapper.get_device_info(device)
    vendor_name = Wrapper.get_vendor_name(device_info)
    model_name = Wrapper.get_model_name(device_info)
    serial_number = Wrapper.get_serial_number(device_info)
    println("$(vendor_name) $(model_name) $(serial_number)")
catch e
    println(e)
end

Wrapper.pylon_terminate(true)
