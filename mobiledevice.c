#include "mobiledevice.h"
#include <string.h>

enum MobileDeviceCommandType
{
  GetUDID,
  InstallApp,
  UninstallApp,
  ListInstalledApps 
};

struct 
{
  struct am_device_notification *notification;
  enum MobileDeviceCommandType type;
  const char *app_path;
  const char *bundle_id;
} command;

#define ASSERT_OR_EXIT(_cnd_, ...)       \
  do                                     \
  {                                      \
    if (!(_cnd_))                        \
    {                                    \
      fprintf(stderr, __VA_ARGS__);      \
      unregister_device_notification(1); \
    }                                    \
  } while (0)

void unregister_device_notification(int status)
{
  AMDeviceNotificationUnsubscribe(command.notification);
  exit(status);
}

void connect_to_device(struct am_device *device)
{
  AMDeviceConnect(device);
  ASSERT_OR_EXIT(AMDeviceIsPaired(device), "!AMDeviceIsPaired\n");
  ASSERT_OR_EXIT(!AMDeviceValidatePairing(device), "!AMDeviceValidatePairing\n");
  ASSERT_OR_EXIT(!AMDeviceStartSession(device), "!AMDeviceStartSession\n");
}

CFURLRef get_absolute_file_url(const char *file_path)
{
  CFStringRef path = CFStringCreateWithCString(NULL, file_path, kCFStringEncodingUTF8);
  CFURLRef relative_url = CFURLCreateWithFileSystemPath(NULL, path, kCFURLPOSIXPathStyle, false);
  CFURLRef url = CFURLCopyAbsoluteURL(relative_url);

  CFRelease(path);
  CFRelease(relative_url);
  return url;
}

CFStringRef get_bundle_id(const char *app_path)
{
  CFURLRef app_url = get_absolute_file_url(app_path);
  if (app_url == NULL)
  {
    return NULL;
  }

  CFURLRef url = CFURLCreateCopyAppendingPathComponent(NULL, app_url,
                                                       CFSTR("Info.plist"), false);
  CFRelease(app_url);
  if (url == NULL)
  {
    return NULL;
  }

  CFReadStreamRef stream = CFReadStreamCreateWithFile(NULL, url);
  CFRelease(url);
  if (stream == NULL)
  {
    return NULL;
  }

  CFPropertyListRef plist = NULL;
  if (CFReadStreamOpen(stream) == TRUE)
  {
    plist = CFPropertyListCreateWithStream(NULL, stream, 0, 
                                           kCFPropertyListImmutable, NULL, NULL);
  }
  CFReadStreamClose(stream);
  CFRelease(stream);

  if (plist == NULL)
  {
    return NULL;
  }

  const void *value = CFDictionaryGetValue(plist, CFSTR("CFBundleIdentifier"));
  CFStringRef bundle_id = NULL;
  if (value != NULL)
  {
    bundle_id = CFRetain(value);
  }
  CFRelease(plist);
  return bundle_id;
}

void get_udid(struct am_device *device)
{
  CFStringEncoding encoding = CFStringGetSystemEncoding();
  const char *udid = CFStringGetCStringPtr(AMDeviceCopyDeviceIdentifier(device), encoding);

  // print UDID to stdout
  printf("%s\n", udid);
  unregister_device_notification(0);
}

void install_app(struct am_device *device)
{
  connect_to_device(device);

  CFURLRef local_app_url = get_absolute_file_url(command.app_path);
  CFStringRef keys[] = { CFSTR("PackageType") }, values[] = { CFSTR("Developer") };
  CFDictionaryRef options = CFDictionaryCreate(NULL, (const void **)&keys, (const void **)&values, 1,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);

  // copy .app to device
  ASSERT_OR_EXIT(!AMDeviceSecureTransferPath(0, device, local_app_url, options,
                 NULL, 0), "!AMDeviceSecureTransferPath\n");

  // install package on device
  ASSERT_OR_EXIT(!AMDeviceSecureInstallApplication(0, device, local_app_url,
                 options, NULL, 0), "!AMDeviceSecureInstallApplication\n");

  CFRelease(options);
  CFRelease(local_app_url);

  printf("OK\n");
  unregister_device_notification(0);
}

void uninstall_app(struct am_device *device)
{
  connect_to_device(device);

  CFStringRef bundle_id = CFStringCreateWithCString(NULL, command.bundle_id, kCFStringEncodingUTF8);

  // install package on device
  ASSERT_OR_EXIT(!AMDeviceSecureUninstallApplication(0, device, bundle_id,
                 0, NULL, 0), "!AMDeviceSecureUninstallApplication\n");

  CFRelease(bundle_id);

  printf("OK\n");
  unregister_device_notification(0);
}

static void print_bundle_id_and_path(const void *key, const void *value, void *context)
{
  if ((key == NULL) || (value == NULL))
  {
    return;
  }

  printf("%s\n", CFStringGetCStringPtr(key, kCFStringEncodingMacRoman));
}

void list_installed_apps(struct am_device *device)
{
  connect_to_device(device);

  CFDictionaryRef apps;
  ASSERT_OR_EXIT(!AMDeviceLookupApplications(device, 0, &apps),
                 "!AMDeviceLookupApplications\n");

  CFDictionaryApplyFunction(apps, print_bundle_id_and_path, NULL);
  CFRelease(apps);

  unregister_device_notification(0);
}

void on_device_connected(struct am_device *device)
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
}

void on_device_notification(struct am_device_notification_callback_info *info, int cookie)
{
  switch (info->msg)
  {
    case ADNCI_MSG_CONNECTED:
      on_device_connected(info->dev);
      break;

    default:
      break;
  }  
}	 

void register_device_notification()
{
  AMDeviceNotificationSubscribe(&on_device_notification, 0, 0, 0, &command.notification);
  CFRunLoopRun();
}

void print_syntax()
{
  printf("Usage: mobiledevice <command>\n\n");
  printf("<Commands>\n");
  printf("  get_udid                    : Display UDID of connected device\n");
  printf("  get_bundle_id <path_to_app> : Display bundle identifier of app (.app folder)\n");
  printf("  install_app <path_to_app>   : Install app (.app folder) to device\n");
  printf("  uninstall <bundle_id>       : Uninstall app by bundle id\n");
  printf("  list_installed_apps         : Lists all installed apps on device\n");
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
  else if ((argc == 3) && (strcmp(argv[1], "get_bundle_id") == 0))
  {
    CFStringRef bundle_id = get_bundle_id(argv[2]);
    if (bundle_id == NULL)
    {
      exit(1);
    }
    printf("%s\n", CFStringGetCStringPtr(bundle_id, kCFStringEncodingMacRoman));
    CFRelease(bundle_id);
    exit(0);
  }
  else if ((argc == 3) && (strcmp(argv[1], "install_app") == 0))
  {
    command.type = InstallApp;
    command.app_path = argv[2];
  }
  else if ((argc == 3) && (strcmp(argv[1], "uninstall_app") == 0))
  {
    command.type = UninstallApp;
    command.bundle_id = argv[2];
  }
  else if (strcmp(argv[1], "list_installed_apps") == 0)
  {
    command.type = ListInstalledApps;
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
