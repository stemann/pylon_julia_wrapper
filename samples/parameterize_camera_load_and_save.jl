include(joinpath("..", "src", "wrapper.jl"))

Wrapper.pylon_initialize()

transport_layer_factory = Wrapper.get_transport_layer_factory_instance()

filename = tempname() * ".pfs"

try
    device = Wrapper.create_first_device(transport_layer_factory)
    device_info = Wrapper.get_device_info(device)
    vendor_name = Wrapper.get_vendor_name(device_info)
    model_name = Wrapper.get_model_name(device_info)
    serial_number = Wrapper.get_serial_number(device_info)
    @info "Found $(vendor_name) $(model_name) $(serial_number)"
    @info "Creating camera instance"
    camera = Wrapper.InstantCamera(device)
    @info "Opening camera"
    Wrapper.open(camera)
    @info "Getting camera node map"
    node_map = Wrapper.get_node_map(camera)
    @info "Saving node map to $filename"
    Wrapper.save(filename, node_map)
    @info "Closing camera"
    Wrapper.close(camera)

    @info "Creating camera instance"
    camera = Wrapper.InstantCamera(device)
    @info "Removing default configuration from instance"
    Wrapper.register_configuration(camera, C_NULL, Wrapper.RegistrationMode_ReplaceAll, Wrapper.Cleanup_None)
    @info "Opening camera"
    Wrapper.open(camera)
    @info "Loading node map from $filename"
    Wrapper.load(filename, node_map)
    @info "Closing camera"
    Wrapper.close(camera)
catch e
    println(e)
end

Wrapper.pylon_terminate(true)
