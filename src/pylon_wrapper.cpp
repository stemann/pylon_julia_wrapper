#include "jlcxx/jlcxx.hpp"

#include <pylon/PylonIncludes.h>

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

  module.add_type<DeviceInfoList_t>("DeviceInfoList")
    .method("getindex", [](DeviceInfoList_t& list, long i)
    {
      return list[i - 1];
    })
    .method("length", &DeviceInfoList_t::size);

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
}
