using PylonWrapper

PylonWrapper.pylon_initialize()

const images_to_grab = UInt64(100)
const grab_result_retrieve_timeout_ms = UInt32(500)

try
    camera = PylonWrapper.create_instant_camera_from_first_device()
    device_info = PylonWrapper.get_device_info(camera)
    vendor_name = PylonWrapper.get_vendor_name(device_info)
    model_name = PylonWrapper.get_model_name(device_info)
    serial_number = PylonWrapper.get_serial_number(device_info)
    println("Using device: $(vendor_name) $(model_name) $(serial_number)")
    PylonWrapper.start_grabbing(camera, images_to_grab)
    while PylonWrapper.is_grabbing(camera)
        grabResult = PylonWrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
        if PylonWrapper.grab_succeeded(grabResult)
            id = PylonWrapper.get_id(grabResult)
            time_stamp = PylonWrapper.get_time_stamp(grabResult)
            width = PylonWrapper.get_width(grabResult)
            height = PylonWrapper.get_height(grabResult)
            print("Image $id @ $time_stamp with size: $(width) x $(height) : ")
            buffer = PylonWrapper.get_buffer(grabResult)
            buffer_array = unsafe_wrap(Array, Ptr{UInt8}(buffer), (width, height))
            @show buffer_array[1, 1]
        else
            println("Error: $(PylonWrapper.get_error_code(grabResult)) $(PylonWrapper.get_error_description(grabResult))")
        end
        PylonWrapper.release(grabResult)
    end
    PylonWrapper.stop_grabbing(camera)
catch e
    println(e)
end

PylonWrapper.pylon_terminate(true)
