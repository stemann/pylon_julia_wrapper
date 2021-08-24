using Test
using PylonWrapper

@testset "Grabbing" begin
    ENV["PYLON_CAMEMU"] = 1

    PylonWrapper.pylon_initialize()

    function create_camera()
        transport_layer_factory = PylonWrapper.get_transport_layer_factory_instance()

        device = PylonWrapper.create_first_device(transport_layer_factory)
        camera = PylonWrapper.InstantCamera(device)
        return camera
    end

    grab_result_retrieve_timeout_ms = UInt32(500)

    @testset "Grab synchronously" begin
        images_to_grab = UInt64(1)
        camera = create_camera()

        @test !PylonWrapper.is_grabbing(camera)
        PylonWrapper.start_grabbing(camera, images_to_grab)
        @test PylonWrapper.is_grabbing(camera)
        PylonWrapper.stop_grabbing(camera)
        @test !PylonWrapper.is_grabbing(camera)

        @testset "Re-start grabbing" begin
            PylonWrapper.start_grabbing(camera, images_to_grab)
            @test PylonWrapper.is_grabbing(camera)
            PylonWrapper.stop_grabbing(camera)
        end
    end

    @testset "Grab synchronously" begin
        images_to_grab = UInt64(1)
        expected_image_id = 1
        expected_image_width = UInt(1024)
        expected_image_height = UInt(1040)
        camera = create_camera()

        @test !PylonWrapper.is_grabbing(camera)
        PylonWrapper.start_grabbing(camera, images_to_grab)
        @test PylonWrapper.is_grabbing(camera)

        grabResult = PylonWrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
        @test PylonWrapper.grab_succeeded(grabResult)
        @test PylonWrapper.get_id(grabResult) == expected_image_id
        @test PylonWrapper.get_width(grabResult) == expected_image_width
        @test PylonWrapper.get_height(grabResult) == expected_image_height
        PylonWrapper.release(grabResult)

        PylonWrapper.stop_grabbing(camera)
        @test !PylonWrapper.is_grabbing(camera)
    end

    @testset "Grab N images synchronously" begin
        grabbed_images = 0
        images_to_grab = UInt64(3)
        camera = create_camera()

        PylonWrapper.start_grabbing(camera, images_to_grab)
        while PylonWrapper.is_grabbing(camera)
            grabResult = PylonWrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
            if PylonWrapper.grab_succeeded(grabResult)
                grabbed_images += 1
                @test PylonWrapper.get_id(grabResult) == grabbed_images
            else
                @error "$(PylonWrapper.get_error_code(grabResult)) $(PylonWrapper.get_error_description(grabResult))"
            end
            PylonWrapper.release(grabResult)
        end
        PylonWrapper.stop_grabbing(camera)
        @test grabbed_images == images_to_grab
    end

    @testset "Grab N images asynchronously" begin
        grabbed_images = 0
        images_to_grab = UInt64(3)
        camera = create_camera()

        grab_result_wait_timeout_ms = UInt32(500)
        grab_result_retrieve_timeout_ms = UInt32(1)

        function grab_asynchronously()
            grabbing_done = Condition()

            terminate_waiter_event = PylonWrapper.create_wait_object_ex(false)
            initiate_wait_event = PylonWrapper.create_wait_object_ex(false)
            result_ready_cond = Base.AsyncCondition()

            grab_result_waiter = PylonWrapper.start_grab_result_waiter(camera,
                grab_result_wait_timeout_ms,
                result_ready_cond.handle,
                terminate_waiter_event,
                initiate_wait_event)
            PylonWrapper.start_grabbing(camera, images_to_grab)

            grab_task = @async begin
                yield()
                while PylonWrapper.is_grabbing(camera)
                    PylonWrapper.signal(initiate_wait_event)
                    wait(result_ready_cond)
                    grabResult = PylonWrapper.retrieve_result(camera, grab_result_retrieve_timeout_ms)
                    if PylonWrapper.grab_succeeded(grabResult)
                        grabbed_images += 1
                        @test PylonWrapper.get_id(grabResult) == grabbed_images
                    else
                        @error "$(PylonWrapper.get_error_code(grabResult)) $(PylonWrapper.get_error_description(grabResult))"
                    end
                    PylonWrapper.release(grabResult)
                    yield()
                end
                notify(grabbing_done)
            end
            yield()
            @test istaskstarted(grab_task)
            @test !istaskdone(grab_task)
            wait(grabbing_done)
            @test istaskdone(grab_task)
    
            PylonWrapper.stop_grab_result_waiter(grab_result_waiter, terminate_waiter_event)
            PylonWrapper.stop_grabbing(camera)
        end

        grab_asynchronously()

        @test grabbed_images == images_to_grab

        @testset "Re-start grabbing" begin
            grab_asynchronously()

            @test grabbed_images == 2*images_to_grab
        end
    end

    PylonWrapper.pylon_terminate(true)
end
