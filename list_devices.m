#include "cli.h"

static int64_t max_count = 0;
static int64_t count = 0;

static void on_device_connected(struct am_device *device)
{
  NSString *udid = device_udid(device);
  printfNS(@"%@\n", udid);

  if ((max_count > 0) && (++count >= max_count))
  {
    device_unregister(0);
  }
}

int list_devices(int argc, char *argv[])
{
  int flag;
  char *endptr;
  int64_t timeout = -1;

  while ((flag = getopt(argc, argv, "t:n:")) != -1)
  {
    switch (flag)
    {
      case 't':
        timeout = strtoll(optarg, &endptr, 10);
        break;

      case 'n':
        max_count = strtoll(optarg, &endptr, 10);
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

  device_delayed_unregister_status = 0;
  device_register(on_device_connected, timeout);
  return 1;
}
