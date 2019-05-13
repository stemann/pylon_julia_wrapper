include(joinpath("..", "src", "wrapper.jl"))

Wrapper.pylon_initialize()

transport_layer_factory = Wrapper.get_transport_layer_factory_instance()

const images_to_grab = UInt64(100)
const grab_result_retrieve_timeout_ms = UInt32(500)

try
    device = Wrapper.create_first_device(transport_layer_factory)
    device_info = Wrapper.get_device_info(device)
    vendor_name = Wrapper.get_vendor_name(device_info)
    model_name = Wrapper.get_model_name(device_info)
    serial_number = Wrapper.get_serial_number(device_info)
    println("Using device: $(vendor_name) $(model_name) $(serial_number)")
    camera = Wrapper.InstantCamera(device)
    Wrapper.start_grabbing(camera, images_to_grab)
    while Wrapper.is_grabbing(camera)
        grabResult = Wrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
        if Wrapper.grab_succeeded(grabResult)
            id = Wrapper.get_id(grabResult)
            time_stamp = Wrapper.get_time_stamp(grabResult)
            width = Wrapper.get_width(grabResult)
            height = Wrapper.get_height(grabResult)
            print("Image $id @ $time_stamp with size: $(width) x $(height) : ")
            buffer = Wrapper.get_buffer(grabResult)
            buffer_array = unsafe_wrap(Array, Ptr{UInt8}(buffer), (width, height))
            @show buffer_array[1, 1]
        else
            println("Error: $(Wrapper.get_error_code(grabResult)) $(Wrapper.get_error_description(grabResult))")
        end
        Wrapper.release(grabResult)
    end
    Wrapper.stop_grabbing(camera)
catch e
    println(e)
end

Wrapper.pylon_terminate(true)
