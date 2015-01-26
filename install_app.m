#include "cli.h"

static char *app_path = NULL;
static char *expected_udid = NULL;

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);

  NSString *path = [NSString stringWithUTF8String:app_path];
  NSURL *local_app_url = [NSURL fileURLWithPath:path isDirectory:TRUE];
  NSDictionary *options = @{@"PackageType" : @"Developer"};

  // copy .app to device
  ASSERT_OR_EXIT(!AMDeviceSecureTransferPath(0, device, (__bridge CFURLRef) local_app_url, (__bridge CFDictionaryRef) options,
                 NULL, 0), "!AMDeviceSecureTransferPath\n");

  // install package on device
  ASSERT_OR_EXIT(!AMDeviceSecureInstallApplication(0, device, (__bridge CFURLRef) local_app_url,
                 (__bridge CFDictionaryRef)options, NULL, 0), "!AMDeviceSecureInstallApplication\n");

  printf("OK\n");
  device_unregister(0);
}

int install_app(int argc, char *argv[])
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

  app_path = argv[0];

  device_delayed_unregister_status = 1;
  device_register(on_device_connected, timeout);
  return 1;
}
