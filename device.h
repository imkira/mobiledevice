#include <stdio.h>
#include <Foundation/Foundation.h>
#include "mobiledevice.h"

#define DEVICE_DEFAULT_TIMEOUT 1ll

#define ASSERT_OR_EXIT(_cnd_, ...)       \
  do                                     \
  {                                      \
    if (!(_cnd_))                        \
    {                                    \
      fprintf(stderr, __VA_ARGS__);      \
      device_unregister(1);              \
    }                                    \
  } while (0)

extern int device_delayed_unregister_status;
extern bool device_delayed_unregister_aborted;
extern void device_register(void (*func)(struct am_device *), int64_t timeout);
extern void device_unregister(int status);
extern void device_connect(struct am_device *device);
extern NSString* device_udid(struct am_device *device);
extern bool device_matches(struct am_device *device, const char *udid);
