#include "cli.h"

static char *expected_udid = NULL;
static char *prop_name = NULL;

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);

  NSString *expected_prop_name = [NSString stringWithUTF8String:prop_name];
  CFStringRef key = (__bridge CFStringRef)expected_prop_name;
  id value = AMDeviceCopyValue(device, 0, key);

  if (value == nil)
  {
    device_unregister(1);
    return;
  }

  printfNS(@"%@\n", value);
  device_unregister(0);
}

int get_device_prop(int argc, char *argv[])
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

  prop_name = argv[0];

  device_delayed_unregister_status = 1;
  device_register(on_device_connected, timeout);
  return 1;
}
