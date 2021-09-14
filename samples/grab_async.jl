using PylonWrapper

PylonWrapper.pylon_initialize()

const images_to_grab = UInt64(100)
const grab_result_wait_timeout_ms = UInt32(500)
const grab_result_retrieve_timeout_ms = UInt32(200)

function acquire_async(camera)
    time_waited = 0.0
    time_retrieved = 0.0
    time_slept = 0.0
    terminate_waiter_event = PylonWrapper.create_wait_object_ex(false)
    initiate_wait_event = PylonWrapper.create_wait_object_ex(false)
    result_ready_cond = Base.AsyncCondition()
    grab_result_waiter = PylonWrapper.start_grab_result_waiter(camera,
        grab_result_wait_timeout_ms,
        result_ready_cond.handle,
        terminate_waiter_event,
        initiate_wait_event)
    PylonWrapper.start_grabbing(camera, images_to_grab)
    @sync begin
        @async begin
            while PylonWrapper.is_grabbing(camera)
                t1 = time_ns()
                PylonWrapper.signal(initiate_wait_event)
                wait(result_ready_cond)
                t2 = time_ns()
                time_waited += (t2 - t1) / 1e9
                t1 = time_ns()
                grabResult = PylonWrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
                t2 = time_ns()
                time_retrieved += (t2 - t1) / 1e9
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
        end
        @async begin
            sleep_delta = 0.001
            while PylonWrapper.is_grabbing(camera)
                sleep(sleep_delta)
                time_slept += sleep_delta
            end
        end
    end
    PylonWrapper.stop_grab_result_waiter(grab_result_waiter, terminate_waiter_event)
    PylonWrapper.stop_grabbing(camera)
    println("Time spent waiting (non-blocking): $(time_waited) secs, mean $(time_waited/images_to_grab)")
    println("Time spent retrieving (blocking): $(time_retrieved) secs, mean $(time_retrieved/images_to_grab)")
    println("Time usable for other tasks: $(time_slept) secs, mean $(time_slept/images_to_grab) secs")
end

try
    camera = PylonWrapper.create_instant_camera_from_first_device()
    device_info = PylonWrapper.get_device_info(camera)
    vendor_name = PylonWrapper.get_vendor_name(device_info)
    model_name = PylonWrapper.get_model_name(device_info)
    serial_number = PylonWrapper.get_serial_number(device_info)
    println("Using device: $(vendor_name) $(model_name) $(serial_number)")
    acquire_async(camera)
catch e
    println(e)
    rethrow(e)
end

PylonWrapper.pylon_terminate(true)
