#include <thread>
#include "jlcxx/jlcxx.hpp"
#include "jlcxx/functions.hpp"

#include <pylon/PylonIncludes.h>

namespace pylon_julia_wrapper
{
  using namespace Pylon;

  void grab_result_waiter(CInstantCamera& camera, unsigned int timeout, int(*notify_async_cond)(void*), void* result_ready_cond)
  {
    auto grabResultReady = camera.GetGrabResultWaitObject();
    while (camera.IsGrabbing())
    {
      try
      {
        auto res = grabResultReady.Wait(timeout);
        notify_async_cond(result_ready_cond);
      }
      catch (const GenericException & e)
      {
        std::cout << "pylon_wrapper: Timeout while waiting for grab result: " << e.GetDescription() << std::endl;
      }
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
  module.method("get_pylon_version_string", &GetPylonVersionString);
  module.method("pylon_initialize", &PylonInitialize);
  module.method("pylon_terminate", &PylonTerminate);

  module.add_type<CDeviceInfo>("DeviceInfo")
    .method("get_vendor_name", [](CDeviceInfo& info)
    {
      return std::string(info.GetVendorName());
    })
    .method("get_model_name", [](CDeviceInfo& info)
    {
      return std::string(info.GetModelName());
    })
    .method("get_serial_number", [](CDeviceInfo& info)
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
      return grabResult->GetErrorDescription();
    })
    .method("get_height", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetHeight();
    })
    .method("get_width", [](CGrabResultPtr grabResult)
    {
      return grabResult->GetWidth();
    })
    .method("release", [](CGrabResultPtr& grabResult)
    {
      return grabResult.Release();
    });

  module.add_type<CInstantCamera>("InstantCamera")
    .constructor(false)
    .constructor<IPylonDevice*>(false)
    .constructor<IPylonDevice*, ECleanup>(false)
    .method("attach", [](CInstantCamera& camera, IPylonDevice* device)
    {
      camera.Attach(device);
    })
    .method("attach", [](CInstantCamera& camera, IPylonDevice* device, ECleanup cleanup_procedure)
    {
      camera.Attach(device, cleanup_procedure);
    })
    .method("is_grabbing", [](CInstantCamera& camera)
    {
      return camera.IsGrabbing();
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
    .method("start_grabbing_async", [](CInstantCamera& camera, unsigned int timeout, jlcxx::SafeCFunction safe_notify_async_cond, void* result_ready_cond)
    {
      auto notify_async_cond = jlcxx::make_function_pointer<int(void*)>(safe_notify_async_cond);
      camera.StartGrabbing();
      auto waiter_thread = new std::thread(pylon_julia_wrapper::grab_result_waiter, std::ref(camera), timeout, notify_async_cond, result_ready_cond);
      return (void*)waiter_thread;
    })
    .method("start_grabbing_async", [](CInstantCamera& camera, size_t maxImages, unsigned int timeout, jlcxx::SafeCFunction safe_notify_async_cond, void* result_ready_cond)
    {
      auto notify_async_cond = jlcxx::make_function_pointer<int(void*)>(safe_notify_async_cond);
      camera.StartGrabbing(maxImages);
      auto waiter_thread = new std::thread(pylon_julia_wrapper::grab_result_waiter, std::ref(camera), timeout, notify_async_cond, result_ready_cond);
      return (void*)waiter_thread;
    })
    .method("stop_grabbing", [](CInstantCamera& camera)
    {
      camera.StopGrabbing();
    });

  module.add_type<DeviceInfoList_t>("DeviceInfoList")
    .method("getindex", [](DeviceInfoList_t& list, long i)
    {
      return list[i - 1];
    })
    .method("length", &DeviceInfoList_t::size);

  module.add_bits<ECleanup>("ECleanup");
  module.set_const("Cleanup_None", Cleanup_None);
  module.set_const("Cleanup_Delete", Cleanup_Delete);

  module.add_bits<ETimeoutHandling>("ETimeoutHandling");
  module.set_const("TimeoutHandling_Return", TimeoutHandling_Return);
  module.set_const("TimeoutHandling_ThrowException", TimeoutHandling_ThrowException);

  module.add_type<IDevice>("IDevice")
    .method("get_device_info", &IDevice::GetDeviceInfo);

  module.add_type<IPylonDevice>("IPylonDevice", jlcxx::julia_type<IDevice>());

  module.add_type<CTlFactory>("TlFactory")
    .method("get_transport_layer_factory_instance", &CTlFactory::GetInstance)
    .method("create_device", [](CTlFactory& factory, CDeviceInfo& device_info)
    {
      try
      {
        return factory.CreateDevice(device_info);
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("create_first_device", [](CTlFactory& factory) -> IPylonDevice*
    {
      try
      {
        return factory.CreateFirstDevice();
      }
      catch (const GenericException & e)
      {
        throw std::runtime_error(e.GetDescription());
      }
    })
    .method("enumerate_devices", [](CTlFactory& factory)
    {
      DeviceInfoList_t device_list;
      factory.EnumerateDevices(device_list);
      return device_list;
    });
}

namespace jlcxx
{
  using namespace Pylon;

  // Needed for shared pointer downcasting
  template<> struct SuperType<IPylonDevice> { typedef IDevice type; };

  template<> struct IsBits<ECleanup> : std::true_type {};
  template<> struct IsBits<ETimeoutHandling> : std::true_type {};
}
