#include <stdio.h>
#include <Foundation/Foundation.h>
#include "mobiledevice.h"

enum MobileDeviceCommandType
{
  GetUDID,
  InstallApp,
  UninstallApp,
  ListInstalledApps,
  Tunnel
};

struct
{
  struct am_device_notification *notification;
  enum MobileDeviceCommandType type;
  const char *app_path;
  const char *bundle_id;
  bool print_paths;
  uint16_t src_port;
  uint16_t dst_port;
} command;

void create_tunnel(struct am_device *device, uint16_t src_port, uint16_t dst_port);

#define ASSERT_OR_EXIT(_cnd_, ...)       \
  do                                     \
  {                                      \
    if (!(_cnd_))                        \
    {                                    \
      fprintf(stderr, __VA_ARGS__);      \
      unregister_device_notification(1); \
    }                                    \
  } while (0)

//works like NSLog without log header
static void printfNS(NSString *format, ...) 
{
  va_list args;
  va_start(args, format);
  NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  fprintf(stdout, "%s", [str UTF8String]);
}

void unregister_device_notification(int status)
{
  AMDeviceNotificationUnsubscribe(command.notification);
  exit(status);
}

static void connect_to_device(struct am_device *device)
{
  AMDeviceConnect(device);
  ASSERT_OR_EXIT(AMDeviceIsPaired(device), "!AMDeviceIsPaired\n");
  ASSERT_OR_EXIT(!AMDeviceValidatePairing(device), "!AMDeviceValidatePairing\n");
  ASSERT_OR_EXIT(!AMDeviceStartSession(device), "!AMDeviceStartSession\n");
}

static NSString* get_bundle_id(const char *app_path)
{
  NSString* path=[NSString stringWithUTF8String:app_path];
  path=[path stringByAppendingPathComponent:@"Info.plist"];
  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
  return dict[@"CFBundleIdentifier"];
}

static void get_udid(struct am_device *device)
{
  NSString* udid = (__bridge NSString*) AMDeviceCopyDeviceIdentifier(device);
  // print UDID to stdout
  printfNS(@"%@\n", udid==nil ? @"(nil)" : udid);
  unregister_device_notification(udid==nil? 1: 0);
}

static void install_app(struct am_device *device)
{
  connect_to_device(device);
  NSString* path=[NSString stringWithUTF8String:command.app_path];
  NSURL* local_app_url=[NSURL fileURLWithPath:path isDirectory:TRUE];
  NSDictionary *options = @{ @"PackageType" : @"Developer" };
  // copy .app to device
  ASSERT_OR_EXIT(!AMDeviceSecureTransferPath(0, device, (__bridge CFURLRef) local_app_url, (__bridge CFDictionaryRef) options,
                 NULL, 0), "!AMDeviceSecureTransferPath\n");

  // install package on device
  ASSERT_OR_EXIT(!AMDeviceSecureInstallApplication(0, device, (__bridge CFURLRef) local_app_url,
                 (__bridge CFDictionaryRef)options, NULL, 0), "!AMDeviceSecureInstallApplication\n");

  printf("OK\n");
  unregister_device_notification(0);
}

static void uninstall_app(struct am_device *device)
{
  connect_to_device(device);

  NSString* bundle_id = [NSString stringWithUTF8String:command.bundle_id];
  // install package on device
  ASSERT_OR_EXIT(!AMDeviceSecureUninstallApplication(0, device, (__bridge CFStringRef) bundle_id,
                 0, NULL, 0), "!AMDeviceSecureUninstallApplication\n");

  printf("OK\n");
  unregister_device_notification(0);
}

static void print_installed_app(const void *key, const void *value, void *context)
{
  if ((key == NULL) || (value == NULL))
  {
    return;
  }

  NSString* bundle_id = (__bridge NSString*)key;

  if (command.print_paths)
  {
    printfNS(@"%@\t%@\n", bundle_id, ((__bridge NSDictionary*)value)[@"Path"]);
  }
  else
  {
    printfNS(@"%@\n", bundle_id);
  }
}

static void list_installed_apps(struct am_device *device)
{
  connect_to_device(device);

  CFDictionaryRef apps;
  ASSERT_OR_EXIT(!AMDeviceLookupApplications(device, 0, &apps), "!AMDeviceLookupApplications\n");

  CFDictionaryApplyFunction(apps, print_installed_app, NULL);
  CFRelease(apps);

  unregister_device_notification(0);
}

static void on_device_connected(struct am_device *device)
{
  if (command.type == GetUDID)
  {
    get_udid(device);
  }
  else if (command.type == InstallApp)
  {
    install_app(device);
  }
  else if (command.type == UninstallApp)
  {
    uninstall_app(device);
  }
  else if (command.type == ListInstalledApps)
  {
    list_installed_apps(device);
  }
  else if (command.type == Tunnel)
  {
    connect_to_device(device);
    create_tunnel(device, command.src_port, command.dst_port);
  }
}

static void on_device_notification(struct am_device_notification_callback_info *info, int cookie)
{
  if (info->msg==ADNCI_MSG_CONNECTED) {
    on_device_connected(info->dev);
  }
}

static void register_device_notification()
{
  AMDeviceNotificationSubscribe(&on_device_notification, 0, 0, 0, &command.notification);
  CFRunLoopRun();
}

static void print_syntax()
{
  printf("Usage: mobiledevice <command> [<options>]\n\n");
  printf("<Commands>\n");
  printf("  get_udid                     : Display UDID of connected device\n");
  printf("  get_bundle_id <path_to_app>  : Display bundle identifier of app (.app folder)\n");
  printf("  install_app <path_to_app>    : Install app (.app folder) to device\n");
  printf("  uninstall_app <bundle_id>        : Uninstall app by bundle id\n");
  printf("  list_installed_apps [-p]     : Lists all installed apps on device\n");
  printf("\n");
  printf("<Options>\n");
  printf("  -p : Include installation paths (use with list_installed_apps)\n");
}

int main(int argc, char *argv[])
{
  if (argc < 2)
  {
    print_syntax();
    exit(2);
  }

  // get_udid
  if ((argc == 2) && (strcmp(argv[1], "get_udid") == 0))
  {
    command.type = GetUDID;
  }
  // get_bundle_id
  else if ((argc == 3) && (strcmp(argv[1], "get_bundle_id") == 0))
  {
    NSString*  bundle_id = get_bundle_id(argv[2]);
    printfNS(@"%@\n", bundle_id==nil ? @"(nil)": bundle_id);
    exit(bundle_id==nil?1:0);
  }
  // install_app
  else if ((argc == 3) && (strcmp(argv[1], "install_app") == 0))
  {
    command.type = InstallApp;
    command.app_path = argv[2];
  }
  // uninstall_app
  else if ((argc == 3) && (strcmp(argv[1], "uninstall_app") == 0))
  {
    command.type = UninstallApp;
    command.bundle_id = argv[2];
  }
  // list_installed_apps
  else if (strcmp(argv[1], "list_installed_apps") == 0)
  {
    command.type = ListInstalledApps;
    command.print_paths= ((argc == 3) && (strcmp(argv[2], "-p") == 0)) ? true : false;
  }
  // tunnel
  else if ((argc == 4) && (strcmp(argv[1], "tunnel") == 0))
  {
    command.type = Tunnel;
    command.src_port = (uint16_t)atoi(argv[2]);
    command.dst_port = (uint16_t)atoi(argv[3]);
  }
  else
  {
    fprintf(stderr, "Unknown command\n");
    print_syntax();
    exit(1);
  }

  // wait for device
  register_device_notification();
  return 1;
}
