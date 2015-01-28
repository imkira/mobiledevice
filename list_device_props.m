#include "cli.h"

static char *expected_udid = NULL;

static const char *keys[] =
{
  "ActivationPublicKey",
  "ActivationState",
  "ActivationStateAcknowledged",
  "ActivityURL",
  "BasebandBootloaderVersion",
  "BasebandSerialNumber",
  "BasebandStatus",
  "BasebandVersion",
  "BluetoothAddress",
  "BuildVersion",
  "CPUArchitecture",
  "DeviceCertificate",
  "DeviceClass",
  "DeviceColor",
  "DeviceName",
  "DevicePublicKey",
  "DieID",
  "FirmwareVersion",
  "HardwareModel",
  "HardwarePlatform",
  "HostAttached",
  "IMLockdownEverRegisteredKey",
  "IntegratedCircuitCardIdentity",
  "InternationalMobileEquipmentIdentity",
  "InternationalMobileSubscriberIdentity",
  "iTunesHasConnected",
  "MLBSerialNumber",
  "MobileSubscriberCountryCode",
  "MobileSubscriberNetworkCode",
  "ModelNumber",
  "PartitionType",
  "PasswordProtected",
  "PhoneNumber",
  "ProductionSOC",
  "ProductType",
  "ProductVersion",
  "ProtocolVersion",
  "ProximitySensorCalibration",
  "RegionInfo",
  "SBLockdownEverRegisteredKey",
  "SerialNumber",
  "SIMStatus",
  "SoftwareBehavior",
  "SoftwareBundleVersion",
  "SupportedDeviceFamilies",
  "TelephonyCapability",
  "TimeIntervalSince1970",
  "TimeZone",
  "TimeZoneOffsetFromUTC",
  "TrustedHostAttached",
  "UniqueChipID",
  "UniqueDeviceID",
  "UseActivityURL",
  "UseRaptorCerts",
  "Uses24HourClock",
  "WeDelivered",
  "WiFiAddress",
  NULL
};

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);

  for (const char **pkey = keys; *pkey != NULL; ++pkey)
  {
    CFStringRef key = (__bridge CFStringRef)[NSString stringWithUTF8String:*pkey];
    id value = AMDeviceCopyValue(device, 0, key);

    if (value != nil)
    {
      printfNS(@"%@\n", key);
    }
  }

  device_unregister(0);
}

int list_device_props(int argc, char *argv[])
{
  int flag;
  char *endptr;
  int64_t timeout = -1;

  while ((flag = getopt(argc, argv, "u:t:")) != -1)
  {
    switch (flag)
    {
      case 'u':
        expected_udid = optarg;
        break;

      case 't':
        timeout = strtoll(optarg, &endptr, 10);
        break;

      default:
        help(argc, argv);
        return 1;
    }
  }

  argc -= optind;
  argv += optind;

  if (argc != 0)
  {
    return invalid_usage(argc, argv);
  }

  device_delayed_unregister_status = 1;
  device_register(on_device_connected, timeout);
  return 1;
}
