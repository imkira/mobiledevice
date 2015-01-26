#include "device.h"

int device_delayed_unregister_status = 1;
bool device_delayed_unregister_aborted = false;
static struct am_device_notification *device_notification = NULL;
static void (*device_on_connected)(struct am_device *) = NULL;

static void device_on_device(struct am_device_notification_callback_info *info, int cookie)
{
  if (info->msg == ADNCI_MSG_CONNECTED)
  {
    if (device_on_connected != NULL)
    {
      device_on_connected(info->dev);
    }
  }
}

static void device_delayed_unregister(int64_t timeout)
{
  int64_t delay = timeout * 1000000ull;
  dispatch_after(dispatch_time((0ull), delay), dispatch_get_main_queue(),
    ^{
       if (device_delayed_unregister_aborted == false)
       {
         device_unregister(device_delayed_unregister_status);
       }
     });
}

void device_register(void (*func)(struct am_device *), int64_t timeout)
{
  device_on_connected = func;
  AMDeviceNotificationSubscribe(&device_on_device, 0, 0, 0, &device_notification);
  if (timeout <= 0)
  {
    timeout = DEVICE_DEFAULT_TIMEOUT;
  }

  device_delayed_unregister(timeout);
  CFRunLoopRun();
}

void device_unregister(int status)
{
  AMDeviceNotificationUnsubscribe(device_notification);
  exit(status);
}

void device_connect(struct am_device *device)
{
  AMDeviceConnect(device);
  ASSERT_OR_EXIT(AMDeviceIsPaired(device), "!AMDeviceIsPaired\n");
  ASSERT_OR_EXIT(!AMDeviceValidatePairing(device), "!AMDeviceValidatePairing\n");
  ASSERT_OR_EXIT(!AMDeviceStartSession(device), "!AMDeviceStartSession\n");
}

NSString* device_udid(struct am_device *device)
{
  return (__bridge NSString*) AMDeviceCopyDeviceIdentifier(device);
}

bool device_matches(struct am_device *device, const char *udid)
{
  if (udid == NULL)
  {
    return true;
  }

  NSString *expected_udid = [NSString stringWithUTF8String:udid];
  NSString *got_udid = device_udid(device);
  return ([got_udid caseInsensitiveCompare:expected_udid] == NSOrderedSame);
}
