using Test
using PylonWrapper

@testset "Device handling" begin
    expected_camera_count = 3
    ENV["PYLON_CAMEMU"] = expected_camera_count

    expected_vendor_name = "Basler"
    expected_model_name = "Emulation"
    expected_serial_number(n::Int) = "0815-$(lpad(string(n), 4, '0'))"

    PylonWrapper.pylon_initialize()

    transport_layer_factory = PylonWrapper.get_transport_layer_factory_instance()

    @testset "Device info" begin
        device = PylonWrapper.create_first_device(transport_layer_factory)
        device_info = PylonWrapper.get_device_info(device)
        @test PylonWrapper.get_vendor_name(device_info) == expected_vendor_name
        @test PylonWrapper.get_model_name(device_info) == expected_model_name
        @test PylonWrapper.get_serial_number(device_info) == expected_serial_number(0)
    end

    @testset "Enumerating" begin
        device_infos = PylonWrapper.enumerate_devices(transport_layer_factory)
        @test length(device_infos) == expected_camera_count
        for (i, device_info) in enumerate(device_infos)
            @test PylonWrapper.get_vendor_name(device_info) == expected_vendor_name
            @test PylonWrapper.get_model_name(device_info) == expected_model_name
            @test PylonWrapper.get_serial_number(device_info) == expected_serial_number(i-1)
        end
    end

    @testset "InstantCamera construction and attaching" begin
        device_infos = PylonWrapper.enumerate_devices(transport_layer_factory)
        device_info = first(device_infos)
        device = PylonWrapper.create_device(transport_layer_factory, device_info)
        camera = PylonWrapper.InstantCamera(device)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)

        camera = PylonWrapper.InstantCamera()
        PylonWrapper.attach(camera, device)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)

        camera = PylonWrapper.InstantCamera()
        PylonWrapper.attach(camera, device, PylonWrapper.Cleanup_None)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)

        camera = PylonWrapper.InstantCamera()
        PylonWrapper.attach(camera, device, PylonWrapper.Cleanup_Delete)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)
    end

    @testset "Opening/Closing" begin
        device = PylonWrapper.create_first_device(transport_layer_factory)
        camera = PylonWrapper.InstantCamera(device)

        @test !PylonWrapper.is_open(camera)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)
        @test !PylonWrapper.is_open(camera)

        @testset "Re-opening a camera" begin
            PylonWrapper.open(camera)
            @test PylonWrapper.is_open(camera)
            PylonWrapper.close(camera)
        end
    end

    PylonWrapper.pylon_terminate(true)
end
