#include "cli.h"

int help(int argc, char *argv[])
{
  printf("mobiledevice help\n");
  printf("  Display this help screen\n");
  printf("\n");

  printf("mobiledevice list_devices [options]\n");
  printf("  Display UDID of each connected devices.\n");
  printf("  Options:\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("    -n <count> : Limit the number of devices to be printed\n");
  printf("\n");

  printf("mobiledevice describe_device [options]\n");
  printf("  Display details of device.\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("    -k <key> : Filter by key\n");
  printf("\n");

  printf("mobiledevice list_apps [options]\n");
  printf("  Lists all apps installed on device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice describe_app [options] <bundle_id>\n");
  printf("  Display details of app installed on device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("    -k <key> : Filter by key\n");
  printf("\n");

  printf("mobiledevice install_app [options] <path_to_app>\n");
  printf("  Install app (.app folder) to device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice uninstall_app [options] <bundle_id>\n");
  printf("  Uninstall app with given bundle id from device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice tunnel [options] <from_port> <to_port>\n");
  printf("  Forward TCP connections to connected device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice get_bundle_id <path_to_app>\n");
  printf("  Display bundle identifier of app (.app folder)\n");
  printf("\n");

  return 0;
}
