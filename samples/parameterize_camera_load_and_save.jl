include(joinpath("..", "src", "PylonWrapper.jl"))

PylonWrapper.pylon_initialize()

transport_layer_factory = PylonWrapper.get_transport_layer_factory_instance()

filename = tempname() * ".pfs"

try
    device = PylonWrapper.create_first_device(transport_layer_factory)
    device_info = PylonWrapper.get_device_info(device)
    vendor_name = PylonWrapper.get_vendor_name(device_info)
    model_name = PylonWrapper.get_model_name(device_info)
    serial_number = PylonWrapper.get_serial_number(device_info)
    @info "Found $(vendor_name) $(model_name) $(serial_number)"
    @info "Creating camera instance"
    camera = PylonWrapper.InstantCamera(device)
    @info "Opening camera"
    PylonWrapper.open(camera)
    @info "Getting camera node map"
    node_map = PylonWrapper.get_node_map(camera)
    @info "Saving node map to $filename"
    PylonWrapper.save_features(filename, node_map)
    @info "Closing camera"
    PylonWrapper.close(camera)

    @info "Creating camera instance"
    camera = PylonWrapper.InstantCamera(device)
    @info "Removing default configuration from instance"
    PylonWrapper.register_configuration(camera, C_NULL, PylonWrapper.RegistrationMode_ReplaceAll, PylonWrapper.Cleanup_None)
    @info "Opening camera"
    PylonWrapper.open(camera)
    @info "Loading node map from $filename"
    PylonWrapper.load_features(filename, node_map)
    @info "Closing camera"
    PylonWrapper.close(camera)
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
