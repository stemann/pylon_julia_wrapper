using Test
using PylonWrapper

@testset "Device handling" begin
    expected_camera_count = 3
    ENV["PYLON_CAMEMU"] = expected_camera_count

    expected_vendor_name = "Basler"
    expected_model_name = "Emulation"
    expected_serial_number(n::Int) = "0815-$(lpad(string(n), 4, '0'))"

    PylonWrapper.pylon_initialize()

    @testset "Device info" begin
        camera = PylonWrapper.create_instant_camera_from_first_device()
        device_info = PylonWrapper.get_device_info(camera)
        @test PylonWrapper.get_vendor_name(device_info) == expected_vendor_name
        @test PylonWrapper.get_model_name(device_info) == expected_model_name
        @test PylonWrapper.get_serial_number(device_info) == expected_serial_number(0)
    end

    @testset "Enumerating" begin
        device_infos = PylonWrapper.enumerate_devices()
        @test length(device_infos) == expected_camera_count
        for (i, device_info) in enumerate(device_infos)
            @test PylonWrapper.get_vendor_name(device_info) == expected_vendor_name
            @test PylonWrapper.get_model_name(device_info) == expected_model_name
            @test PylonWrapper.get_serial_number(device_info) == expected_serial_number(i-1)
        end
    end

    @testset "InstantCamera construction and attaching" begin
        device_infos = PylonWrapper.enumerate_devices()
        device_info = first(device_infos)
        camera = PylonWrapper.InstantCamera(device_info)
        PylonWrapper.open(camera)
        @test PylonWrapper.is_open(camera)
        PylonWrapper.close(camera)
    end

    @testset "Opening/Closing" begin
        camera = PylonWrapper.create_instant_camera_from_first_device()

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
