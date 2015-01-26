#include "cli.h"

static char *app_bundle_id = NULL;
static char *expected_udid = NULL;

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);

  NSString *bundle_id = [NSString stringWithUTF8String:app_bundle_id];

  // uninstall package from device
  ASSERT_OR_EXIT(!AMDeviceSecureUninstallApplication(0, device, (__bridge CFStringRef) bundle_id,
                 0, NULL, 0), "!AMDeviceSecureUninstallApplication\n");

  printf("OK\n");
  device_unregister(0);
}

int uninstall_app(int argc, char *argv[])
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

  if (argc != 1)
  {
    return invalid_usage(argc, argv);
  }

  app_bundle_id = argv[0];

  device_delayed_unregister_status = 1;
  device_register(on_device_connected, timeout);
  return 1;
}
