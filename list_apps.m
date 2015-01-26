#include "cli.h"

static char *expected_udid = NULL;

static void print_app(const void *key, const void *value, void *context)
{
  if ((key == NULL) || (value == NULL))
  {
    return;
  }

  NSString *bundle_id = (__bridge NSString*)key;
  printfNS(@"%@\n", bundle_id);
}

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);

  CFDictionaryRef apps;
  ASSERT_OR_EXIT(!AMDeviceLookupApplications(device, 0, &apps), "!AMDeviceLookupApplications\n");

  CFDictionaryApplyFunction(apps, print_app, NULL);
  CFRelease(apps);

  device_unregister(0);
}

int list_apps(int argc, char *argv[])
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
