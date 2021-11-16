#include <thread>
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/functions.hpp"
#include "uv.h"

#include <pylon/PylonIncludes.h>

namespace pylon_julia_wrapper
{
  using namespace Pylon;

  void grab_result_waiter(CInstantCamera& camera, unsigned int timeout,
    uv_async_t* result_ready_handle,
    WaitObjectEx& terminate_waiter_event,
    WaitObjectEx& initiate_wait_event)
  {
    auto result_ready_event = camera.GetGrabResultWaitObject();

    WaitObjects control_events;
    control_events.Add(terminate_waiter_event);
    control_events.Add(initiate_wait_event);

    WaitObjects result_events;
    result_events.Add(terminate_waiter_event);
    result_events.Add(result_ready_event);

    unsigned int event_index;

    while (true)
    {
      if (!control_events.WaitForAny(INFINITE, &event_index))
      {
        std::cout << "pylon_wrapper: Timeout while waiting for termination or initiation" << std::endl;
        break;
      }

      if (event_index == 0) // terminate_waiter_event
        break;

      // initiate_wait_event
      if (!result_events.WaitForAny(timeout, &event_index))
      {
        std::cout << "pylon_wrapper: Timeout while waiting for grab result" << std::endl;
        continue;
      }

      if (event_index == 0) // terminate_waiter_event
        break;

      // result_ready_event
      uv_async_send(result_ready_handle);
    }
  }
}

JLCXX_MODULE define_pylon_wrapper(jlcxx::Module& module)
{
  using namespace Pylon;

  module.method("get_pylon_version", []()
  {
    unsigned int major, minor, subminor, build;
    GetPylonVersion(&major, &minor, &subminor, &build);
    return std::make_tuple(major, minor, subminor, build);
  });
  module.method("get_pylon_version_string", []()
  {
    return std::string(GetPylonVersionString());
  });
  module.method("pylon_initialize", &PylonInitialize);
  module.method("pylon_terminate", &PylonTerminate);
  module.method("samples_per_pixel", [](unsigned long pixelType)
  {
    return SamplesPerPixel((EPixelType)pixelType);
  });
  module.method("is_rgb", [](unsigned long pixelType)
  {
    return IsRGB((EPixelType)pixelType);
  });
  module.method("is_bgr", [](unsigned long pixelType)
  {
    return IsBGR((EPixelType)pixelType);
  });

  // CFeaturePersistence
  module.method("load_features", [](const char *filename, void *nodeMap)
  {
    try
    {
      CFeaturePersistence::Load(filename, (GenApi::INodeMap*)nodeMap);
    }
    catch (const GenericException & e)
    {
      throw std::runtime_error(e.GetDescription());
    }
  });
  module.method("save_features", [](const char *filename, void *nodeMap)
  {
    try
    {
      CFeaturePersistence::Save(filename, (GenApi::INodeMap*)nodeMap);
    }
    catch (const GenericException & e)
    {
      throw std::runtime_error(e.GetDescription());
    }
  });

  module.add_type<CDeviceInfo>("DeviceInfo")
    .method("get_vendor_name", [](const CDeviceInfo& info)
    {
      return std::string(info.GetVendorName());
    })
    .method("get_model_name", [](const CDeviceInfo& info)
    {
      return std::string(info.GetModelName());
    })
    .method("get_serial_number", [](const CDeviceInfo& info)
    {
      return std::string(info.GetSerialNumber());
    });

  module.add_type<CGrabResultPtr>("GrabResultPtr")
    .method("grab_succeeded", [](CGrabResultPtr grabResult)
    {
      return grabResult->GrabSucceeded();
    })
    .method("get_buffer", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetBuffer();
    })
    .method("get_error_code", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetErrorCode();
    })
    .method("get_error_description", [](CGrabResultPtr grabResult)
    {
      return std::string(grabResult->GetErrorDescription());
    })
    .method("get_height", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetHeight();
    })
    .method("get_id", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetID();
    })
    .method("get_image_number", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetImageNumber();
    })
    .method("get_image_size", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetImageSize();
    })
    .method("get_pixel_type", [](CGrabResultPtr grabResult)
    {
      return (unsigned long)grabResult->GetPixelType();
    })
    .method("get_time_stamp", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetTimeStamp();
    })
    .method("get_width", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetWidth();
    })
    .method("release", [](CGrabResultPtr& grabResult)
    {
      return grabResult.Release();
    });

  module.add_bits<ECleanup>("ECleanup", jlcxx::julia_type("CppEnum"));
  module.set_const("Cleanup_None", Cleanup_None);
  module.set_const("Cleanup_Delete", Cleanup_Delete);

  module.add_bits<EPixelType>("EPixelType", jlcxx::julia_type("CppEnum"));
  module.set_const("PixelType_Undefined", PixelType_Undefined);
  module.set_const("PixelType_Mono1packed", PixelType_Mono1packed);
  module.set_const("PixelType_Mono2packed", PixelType_Mono2packed);
  module.set_const("PixelType_Mono4packed", PixelType_Mono4packed);
  module.set_const("PixelType_Mono8", PixelType_Mono8);
  module.set_const("PixelType_Mono8signed", PixelType_Mono8signed);
  module.set_const("PixelType_Mono10", PixelType_Mono10);
  module.set_const("PixelType_Mono10packed", PixelType_Mono10packed);
  module.set_const("PixelType_Mono10p", PixelType_Mono10p);
  module.set_const("PixelType_Mono12", PixelType_Mono12);
  module.set_const("PixelType_Mono12packed", PixelType_Mono12packed);
  module.set_const("PixelType_Mono12p", PixelType_Mono12p);
  module.set_const("PixelType_Mono16", PixelType_Mono16);
  module.set_const("PixelType_BayerGR8", PixelType_BayerGR8);
  module.set_const("PixelType_BayerRG8", PixelType_BayerRG8);
  module.set_const("PixelType_BayerGB8", PixelType_BayerGB8);
  module.set_const("PixelType_BayerBG8", PixelType_BayerBG8);
  module.set_const("PixelType_BayerGR10", PixelType_BayerGR10);
  module.set_const("PixelType_BayerRG10", PixelType_BayerRG10);
  module.set_const("PixelType_BayerGB10", PixelType_BayerGB10);
  module.set_const("PixelType_BayerBG10", PixelType_BayerBG10);
  module.set_const("PixelType_BayerGR12", PixelType_BayerGR12);
  module.set_const("PixelType_BayerRG12", PixelType_BayerRG12);
  module.set_const("PixelType_BayerGB12", PixelType_BayerGB12);
  module.set_const("PixelType_BayerBG12", PixelType_BayerBG12);
  module.set_const("PixelType_RGB8packed", PixelType_RGB8packed);
  module.set_const("PixelType_BGR8packed", PixelType_BGR8packed);
  module.set_const("PixelType_RGBA8packed", PixelType_RGBA8packed);
  module.set_const("PixelType_BGRA8packed", PixelType_BGRA8packed);
  module.set_const("PixelType_RGB10packed", PixelType_RGB10packed);
  module.set_const("PixelType_BGR10packed", PixelType_BGR10packed);
  module.set_const("PixelType_RGB12packed", PixelType_RGB12packed);
  module.set_const("PixelType_BGR12packed", PixelType_BGR12packed);
  module.set_const("PixelType_RGB16packed", PixelType_RGB16packed);
  module.set_const("PixelType_BGR10V1packed", PixelType_BGR10V1packed);
  module.set_const("PixelType_BGR10V2packed", PixelType_BGR10V2packed);
  module.set_const("PixelType_YUV411packed", PixelType_YUV411packed);
  module.set_const("PixelType_YUV422packed", PixelType_YUV422packed);
  module.set_const("PixelType_YUV444packed", PixelType_YUV444packed);
  module.set_const("PixelType_RGB8planar", PixelType_RGB8planar);
  module.set_const("PixelType_RGB10planar", PixelType_RGB10planar);
  module.set_const("PixelType_RGB12planar", PixelType_RGB12planar);
  module.set_const("PixelType_RGB16planar", PixelType_RGB16planar);
  module.set_const("PixelType_YUV422_YUYV_Packed", PixelType_YUV422_YUYV_Packed);
  module.set_const("PixelType_BayerGR12Packed", PixelType_BayerGR12Packed);
  module.set_const("PixelType_BayerRG12Packed", PixelType_BayerRG12Packed);
  module.set_const("PixelType_BayerGB12Packed", PixelType_BayerGB12Packed);
  module.set_const("PixelType_BayerBG12Packed", PixelType_BayerBG12Packed);
  module.set_const("PixelType_BayerGR10p", PixelType_BayerGR10p);
  module.set_const("PixelType_BayerRG10p", PixelType_BayerRG10p);
  module.set_const("PixelType_BayerGB10p", PixelType_BayerGB10p);
  module.set_const("PixelType_BayerBG10p", PixelType_BayerBG10p);
  module.set_const("PixelType_BayerGR12p", PixelType_BayerGR12p);
  module.set_const("PixelType_BayerRG12p", PixelType_BayerRG12p);
  module.set_const("PixelType_BayerGB12p", PixelType_BayerGB12p);
  module.set_const("PixelType_BayerBG12p", PixelType_BayerBG12p);
  module.set_const("PixelType_BayerGR16", PixelType_BayerGR16);
  module.set_const("PixelType_BayerRG16", PixelType_BayerRG16);
  module.set_const("PixelType_BayerGB16", PixelType_BayerGB16);
  module.set_const("PixelType_BayerBG16", PixelType_BayerBG16);
  module.set_const("PixelType_RGB12V1packed", PixelType_RGB12V1packed);
  module.set_const("PixelType_Double", PixelType_Double);

  module.add_bits<ERegistrationMode>("ERegistrationMode", jlcxx::julia_type("CppEnum"));
  module.set_const("RegistrationMode_Append", RegistrationMode_Append);
  module.set_const("RegistrationMode_ReplaceAll", RegistrationMode_ReplaceAll);

  module.add_bits<ETimeoutHandling>("ETimeoutHandling", jlcxx::julia_type("CppEnum"));
  module.set_const("TimeoutHandling_Return", TimeoutHandling_Return);
  module.set_const("TimeoutHandling_ThrowException", TimeoutHandling_ThrowException);

  module.add_type<WaitObjectEx>("WaitObjectEx")
    .method("create_wait_object_ex", &WaitObjectEx::Create)
    .method("reset", &WaitObjectEx::Reset)
    .method("signal", &WaitObjectEx::Signal)
    .method("wait", &WaitObjectEx::Wait);

  module.add_type<std::thread>("StdThread");

  module.add_type<CInstantCamera>("InstantCamera")
    .constructor(false)
    .method("InstantCamera", [](CDeviceInfo& deviceInfo, ECleanup cleanupProcedure)
    {
      try
      {
        auto device = CTlFactory::GetInstance().CreateDevice(deviceInfo);
        return jlcxx::create<CInstantCamera, false>(device, cleanupProcedure);
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("create_instant_camera_from_first_device", [](CDeviceInfo& deviceInfo, ECleanup cleanupProcedure)
    {
      try
      {
        auto device = CTlFactory::GetInstance().CreateFirstDevice(deviceInfo);
        return jlcxx::create<CInstantCamera, false>(device, cleanupProcedure);
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("attach", [](CInstantCamera& camera, CDeviceInfo& deviceInfo, ECleanup cleanupProcedure)
    {
      try
      {
        auto device = CTlFactory::GetInstance().CreateDevice(deviceInfo);
        camera.Attach(device, cleanupProcedure);
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("close", [](CInstantCamera& camera)
    {
      camera.Close();
    })
    .method("get_device_info", &CInstantCamera::GetDeviceInfo)
    .method("get_node_map", [](CInstantCamera& camera)
    {
      try
      {
        return (void*)&(camera.GetNodeMap());
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("is_grabbing", [](CInstantCamera& camera)
    {
      return camera.IsGrabbing();
    })
    .method("is_open", [](CInstantCamera& camera)
    {
      return camera.IsOpen();
    })
    .method("max_num_buffer", [](CInstantCamera& camera)
    {
      return (unsigned int)camera.MaxNumBuffer.GetValue();
    })
    .method("max_num_buffer!", [](CInstantCamera& camera, unsigned int v)
    {
      camera.MaxNumBuffer.SetValue(v);
    })
    .method("open", [](CInstantCamera& camera)
    {
      camera.Open();
    })
    .method("register_configuration", [](CInstantCamera& camera, void *configurator, ERegistrationMode registrationMode, ECleanup cleanupProcedure)
    {
      try
      {
        camera.RegisterConfiguration((CConfigurationEventHandler*)configurator, registrationMode, cleanupProcedure);
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("retrieve_result", [](CInstantCamera& camera, unsigned int timeoutMs, ETimeoutHandling timeoutHandling)
    {
      try
      {
        CGrabResultPtr grabResultPtr;
        camera.RetrieveResult(timeoutMs, grabResultPtr, timeoutHandling);
        return grabResultPtr;
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("start_grabbing", [](CInstantCamera& camera)
    {
      camera.StartGrabbing();
    })
    .method("start_grabbing", [](CInstantCamera& camera, size_t maxImages)
    {
      camera.StartGrabbing(maxImages);
    })
    .method("start_grab_result_waiter", [](CInstantCamera& camera, unsigned int timeout,
      void* result_ready_handle,
      WaitObjectEx& terminate_waiter_event,
      WaitObjectEx& initiate_wait_event)
    {
      return jlcxx::create<std::thread>(pylon_julia_wrapper::grab_result_waiter,
        std::ref(camera), timeout,
        (uv_async_t*)result_ready_handle,
        std::ref(terminate_waiter_event),
        std::ref(initiate_wait_event));
    })
    .method("stop_grabbing", [](CInstantCamera& camera)
    {
      camera.StopGrabbing();
    });

  module.method("stop_grab_result_waiter", [](std::thread& grab_result_waiter_thread,
    WaitObjectEx& terminate_waiter_event)
  {
    terminate_waiter_event.Signal();
    grab_result_waiter_thread.join();
  });

  module.add_type<DeviceInfoList_t>("DeviceInfoList")
    .method("getindex", [](DeviceInfoList_t& list, long i)
    {
      return list[i - 1];
    })
    .method("length", &DeviceInfoList_t::size);

  module.method("enumerate_devices", []()
    {
      DeviceInfoList_t device_list;
      CTlFactory::GetInstance().EnumerateDevices(device_list);
      return device_list;
    });
}
