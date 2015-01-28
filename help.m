#include "cli.h"

int help(int argc, char *argv[])
{
  printf("mobiledevice help\n");
  printf("  Display this help screen\n");
  printf("\n");

  printf("mobiledevice version [options]\n");
  printf("  Display program version.\n");
  printf("  Options:\n");
  printf("    -r: Include revision identifier\n");
  printf("\n");

  printf("mobiledevice list_devices [options]\n");
  printf("  Display UDID of each connected devices.\n");
  printf("  Options:\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("    -n <count> : Limit the number of devices to be printed\n");
  printf("\n");

  printf("mobiledevice list_device_props [options]\n");
  printf("  List all property names of device.\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice get_device_prop [options] <prop_name>\n");
  printf("  Display value of device property with given name.\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice list_apps [options]\n");
  printf("  Lists all apps installed on device\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice list_app_props [options] <bundle_id>\n");
  printf("  List all property names of app with given bundle id.\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
  printf("\n");

  printf("mobiledevice get_app_prop [options] <bundle_id> <prop_name>\n");
  printf("  Display value of app property with given name.\n");
  printf("  Options:\n");
  printf("    -u <udid> : Filter by device UDID (default: first detected device)\n");
  printf("    -t <timeout>: Timeout (in ms) to wait for devices (default: %lld)\n", DEVICE_DEFAULT_TIMEOUT);
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
