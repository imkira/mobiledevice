/* ----------------------------------------------------------------------------
 *   MobileDevice.h - interface to MobileDevice.framework 
 *
 * Adapted from http://theiphonewiki.com/wiki/index.php?title=MobileDevice_Library
 * ------------------------------------------------------------------------- */
#ifndef MOBILEDEVICE_H
#define MOBILEDEVICE_H

#ifdef __cplusplus
extern "C" {
#endif
	
#ifndef __GNUC__
#pragma pack
#define __PACK
#else
#define __PACK __attribute__((__packed__))
#endif

#if defined(WIN32)
#define __DLLIMPORT [DllImport("iTunesMobileDevice.dll")]
	using namespace System::Runtime::InteropServices;
#include <CoreFoundation.h>
	typedef unsigned int mach_error_t;
#elif defined(__APPLE__)
#define __DLLIMPORT
#include <CoreFoundation/CoreFoundation.h>
#include <mach/error.h>
#endif	
	
	/* Error codes */
#define MDERR_APPLE_MOBILE  (err_system(0x3a))
#define MDERR_IPHONE        (err_sub(0))
	
	/* Apple Mobile (AM*) errors */
#define MDERR_OK                ERR_SUCCESS
#define MDERR_SYSCALL           (ERR_MOBILE_DEVICE | 0x01)
#define MDERR_OUT_OF_MEMORY     (ERR_MOBILE_DEVICE | 0x03)
#define MDERR_QUERY_FAILED      (ERR_MOBILE_DEVICE | 0x04) 
#define MDERR_INVALID_ARGUMENT  (ERR_MOBILE_DEVICE | 0x0b)
#define MDERR_DICT_NOT_LOADED   (ERR_MOBILE_DEVICE | 0x25)
	
	/* Apple File Connection (AFC*) errors */
#define MDERR_AFC_OUT_OF_MEMORY 0x03
	
	/* USBMux errors */
#define MDERR_USBMUX_ARG_NULL   0x16
#define MDERR_USBMUX_FAILED     0xffffffff
	
	/* Messages passed to device notification callbacks: passed as part of
	 * am_device_notification_callback_info. */
#define ADNCI_MSG_CONNECTED     1
#define ADNCI_MSG_DISCONNECTED  2
#define ADNCI_MSG_UNSUBSCRIBED  3
	
#define AMD_IPHONE_PRODUCT_ID   0x1290
	//#define AMD_IPHONE_SERIAL       ""
	
	/* Services, found in /System/Library/Lockdown/Services.plist */
#define AMSVC_AFC                   CFSTR("com.apple.afc")
#define AMSVC_BACKUP                CFSTR("com.apple.mobilebackup")
#define AMSVC_CRASH_REPORT_COPY     CFSTR("com.apple.crashreportcopy")
#define AMSVC_DEBUG_IMAGE_MOUNT     CFSTR("com.apple.mobile.debug_image_mount")
#define AMSVC_NOTIFICATION_PROXY    CFSTR("com.apple.mobile.notification_proxy")
#define AMSVC_PURPLE_TEST           CFSTR("com.apple.purpletestr")
#define AMSVC_SOFTWARE_UPDATE       CFSTR("com.apple.mobile.software_update")
#define AMSVC_SYNC                  CFSTR("com.apple.mobilesync")
#define AMSVC_SCREENSHOT            CFSTR("com.apple.screenshotr")
#define AMSVC_SYSLOG_RELAY          CFSTR("com.apple.syslog_relay")
#define AMSVC_SYSTEM_PROFILER       CFSTR("com.apple.mobile.system_profiler")

  typedef unsigned int service_conn_t;
	
	typedef unsigned int afc_error_t;
	typedef unsigned int usbmux_error_t;
	
	struct am_recovery_device;
	
	struct am_device_notification_callback_info {
		struct am_device *dev;  /* 0    device */ 
		unsigned int msg;       /* 4    one of ADNCI_MSG_* */
               struct am_device_notification* subscription; 
	} __PACK;
	
	/* The type of the device restore notification callback functions.
	 * TODO: change to correct type. */
	typedef void (*am_restore_device_notification_callback)(struct am_recovery_device *);
	
	/* This is a CoreFoundation object of class AMRecoveryModeDevice. */
	struct am_recovery_device {
		unsigned char unknown0[8];                          /* 0 */
		am_restore_device_notification_callback callback;   /* 8 */
		void *user_info;                                    /* 12 */
		unsigned char unknown1[12];                         /* 16 */
		unsigned int readwrite_pipe;                        /* 28 */
		unsigned char read_pipe;                            /* 32 */
		unsigned char write_ctrl_pipe;                      /* 33 */
		unsigned char read_unknown_pipe;                    /* 34 */
		unsigned char write_file_pipe;                      /* 35 */
		unsigned char write_input_pipe;                     /* 36 */
	} __PACK;
	
	/* A CoreFoundation object of class AMRestoreModeDevice. */
	struct am_restore_device {
		unsigned char unknown[32];
		int port;
	} __PACK;
	
	/* The type of the device notification callback function. */
	typedef void(*am_device_notification_callback)(struct am_device_notification_callback_info *, int cookie);
	
	/* The type of the _AMDDeviceAttached function.
	 * TODO: change to correct type. */
	typedef void *amd_device_attached_callback;
	
	/* Structure that contains internal data used by AMDevice... functions. Never try 
        * to access its members directly! Use AMDeviceCopyDeviceIdentifier, 
        * AMDeviceGetConnectionID, AMDeviceRetain, AMDeviceRelease instead. */
	struct am_device {
		unsigned char unknown0[16]; /* 0 - zero */
		unsigned int device_id;     /* 16 */
		unsigned int product_id;    /* 20 - set to AMD_IPHONE_PRODUCT_ID */
		char *serial;               /* 24 - set to UDID, Unique Device Identifier */
		unsigned int unknown1;      /* 28 */
		unsigned int unknown2;      /* 32 - reference counter, increased by AMDeviceRetain, decreased by AMDeviceRelease*/
		unsigned int lockdown_conn; /* 36 */
		unsigned char unknown3[8];  /* 40 */
#if (__ITUNES_VER > 740)
		unsigned int unknown4;      /* 48 - used to store CriticalSection Handle*/
#endif
#if (__ITUNES_VER >= 800)
		unsigned char unknown5[24];  /* 52 */
#endif
	} __PACK;
	
	struct am_device_notification {
		unsigned int unknown0;                      /* 0 */
		unsigned int unknown1;                      /* 4 */
		unsigned int unknown2;                      /* 8 */
		am_device_notification_callback callback;   /* 12 */ 
		unsigned int cookie;                      /* 16 */
	} __PACK;
	
	struct afc_connection {
		unsigned int handle;            /* 0 */
		unsigned int unknown0;          /* 4 */
		unsigned char unknown1;         /* 8 */
		unsigned char padding[3];       /* 9 */
		unsigned int unknown2;          /* 12 */
		unsigned int unknown3;          /* 16 */
		unsigned int unknown4;          /* 20 */
		unsigned int fs_block_size;     /* 24 */
		unsigned int sock_block_size;   /* 28: always 0x3c */
		unsigned int io_timeout;        /* 32: from AFCConnectionOpen, usu. 0 */
		void *afc_lock;                 /* 36 */
		unsigned int context;           /* 40 */
	} __PACK;
	
	

	struct afc_device_info {
		unsigned char unknown[12];  /* 0 */
	} __PACK;

	struct afc_directory {
		unsigned char unknown[0];   /* size unknown */
	} __PACK;

	struct afc_dictionary {
		unsigned char unknown[0];   /* size unknown */
	} __PACK;
	
	typedef unsigned long long afc_file_ref;
	
	struct usbmux_listener_1 {                  /* offset   value in iTunes */
		unsigned int unknown0;                  /* 0        1 */
		unsigned char *unknown1;                /* 4        ptr, maybe device? */
		amd_device_attached_callback callback;  /* 8        _AMDDeviceAttached */
		unsigned int unknown3;                  /* 12 */
		unsigned int unknown4;                  /* 16 */
		unsigned int unknown5;                  /* 20 */
	} __PACK;
	
	struct usbmux_listener_2 {
		unsigned char unknown0[4144];
	} __PACK;
	
	struct am_bootloader_control_packet {
		unsigned char opcode;       /* 0 */
		unsigned char length;       /* 1 */
		unsigned char magic[2];     /* 2: 0x34, 0x12 */
		unsigned char payload[0];   /* 4 */
	} __PACK;
	
	/* ----------------------------------------------------------------------------
	 *   Public routines
	 * ------------------------------------------------------------------------- */
	
	/*  Registers a notification with the current run loop. The callback gets
	 *  copied into the notification struct, as well as being registered with the
	 *  current run loop. Cookie gets copied into cookie in the same.
	 *  (Cookie is a user info parameter that gets passed as an arg to
	 *  the callback) unused0 and unused1 are both 0 when iTunes calls this.
	 *
	 *  Never try to acces directly or copy contents of dev and subscription fields 
	 *  in am_device_notification_callback_info. Treat them as abstract handles. 
	 *  When done with connection use AMDeviceRelease to free resources allocated for am_device.
	 *  
	 *  Returns:
	 *      MDERR_OK            if successful
	 *      MDERR_SYSCALL       if CFRunLoopAddSource() failed
	 *      MDERR_OUT_OF_MEMORY if we ran out of memory
	 */
	__DLLIMPORT mach_error_t AMDeviceNotificationSubscribe(am_device_notification_callback callback, 
								unsigned int unused0, unsigned int unused1, 
								unsigned int cookie, 
								struct am_device_notification **subscription);
	

       /* Unregisters notifications. Buggy (iTunes 8.2): if you subscribe, unsubscribe and subscribe again, arriving 
          notifications will contain cookie and subscription from 1st call to subscribe, not the 2nd one. iTunes 
          calls this function only once on exit.
       */
	__DLLIMPORT mach_error_t AMDeviceNotificationUnsubscribe(struct am_device_notification* subscription);

	/*  Returns device_id field of am_device structure
	 */
	__DLLIMPORT unsigned int AMDeviceGetConnectionID(struct am_device *device);

	/*  Returns serial field of am_device structure
	 */
	__DLLIMPORT CFStringRef AMDeviceCopyDeviceIdentifier(struct am_device *device);

	/*  Connects to the iPhone. Pass in the am_device structure that the
	 *  notification callback will give to you.
	 *
	 *  Returns:
	 *      MDERR_OK                if successfully connected
	 *      MDERR_SYSCALL           if setsockopt() failed
	 *      MDERR_QUERY_FAILED      if the daemon query failed
	 *      MDERR_INVALID_ARGUMENT  if USBMuxConnectByPort returned 0xffffffff
	 */
	__DLLIMPORT mach_error_t AMDeviceConnect(struct am_device *device);
	
	/*  Calls PairingRecordPath() on the given device, than tests whether the path
	 *  which that function returns exists. During the initial connect, the path
	 *  returned by that function is '/', and so this returns 1.
	 *
	 *  Returns:
	 *      0   if the path did not exist
	 *      1   if it did
	 */
	__DLLIMPORT mach_error_t AMDeviceIsPaired(struct am_device *device);
	__DLLIMPORT mach_error_t AMDevicePair(struct am_device *device);
	
	/*  iTunes calls this function immediately after testing whether the device is
	 *  paired. It creates a pairing file and establishes a Lockdown connection.
	 *
	 *  Returns:
	 *      MDERR_OK                if successful
	 *      MDERR_INVALID_ARGUMENT  if the supplied device is null
	 *      MDERR_DICT_NOT_LOADED   if the load_dict() call failed
	 */
	__DLLIMPORT mach_error_t AMDeviceValidatePairing(struct am_device *device);
	
	/*  Creates a Lockdown session and adjusts the device structure appropriately
	 *  to indicate that the session has been started. iTunes calls this function
	 *  after validating pairing.
	 *
	 *  Returns:
	 *      MDERR_OK                if successful
	 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
	 *      MDERR_DICT_NOT_LOADED   if the load_dict() call failed
	 */
	__DLLIMPORT mach_error_t AMDeviceStartSession(struct am_device *device);


	/* Reads various device settings. One of domain or cfstring arguments should be NULL.
        *
        * ActivationPublicKey 
        * ActivationState 
        * ActivationStateAcknowledged 
        * ActivityURL 
        * BasebandBootloaderVersion 
        * BasebandSerialNumber 
        * BasebandStatus 
        * BasebandVersion 
        * BluetoothAddress 
        * BuildVersion 
        * CPUArchitecture 
        * DeviceCertificate 
        * DeviceClass 
        * DeviceColor 
        * DeviceName 
        * DevicePublicKey 
        * DieID 
        * FirmwareVersion 
        * HardwareModel 
        * HardwarePlatform 
        * HostAttached 
        * IMLockdownEverRegisteredKey 
        * IntegratedCircuitCardIdentity 
        * InternationalMobileEquipmentIdentity 
        * InternationalMobileSubscriberIdentity 
        * iTunesHasConnected 
        * MLBSerialNumber 
        * MobileSubscriberCountryCode 
        * MobileSubscriberNetworkCode 
        * ModelNumber 
        * PartitionType 
        * PasswordProtected 
        * PhoneNumber 
        * ProductionSOC 
        * ProductType 
        * ProductVersion 
        * ProtocolVersion 
        * ProximitySensorCalibration 
        * RegionInfo 
        * SBLockdownEverRegisteredKey 
        * SerialNumber 
        * SIMStatus 
        * SoftwareBehavior 
        * SoftwareBundleVersion 
        * SupportedDeviceFamilies 
        * TelephonyCapability 
        * TimeIntervalSince1970 
        * TimeZone 
        * TimeZoneOffsetFromUTC 
        * TrustedHostAttached 
        * UniqueChipID 
        * UniqueDeviceID 
        * UseActivityURL 
        * UseRaptorCerts 
        * Uses24HourClock 
        * WeDelivered 
        * WiFiAddress 
        * // Updated by DiAifU 14.10.2010 for iOS5 and iTunes 5.0
        *
        * Possible values for domain:
        * com.apple.mobile.battery
	 */
	__DLLIMPORT id AMDeviceCopyValue(struct am_device *device, CFStringRef domain, CFStringRef cfstring);
	
	/* Starts a service and returns a socket file descriptor that can be used in order to further
	 * access the service. You should stop the session and disconnect before using
	 * the service. iTunes calls this function after starting a session. It starts 
	 * the service and the SSL connection. service_name should be one of the AMSVC_*
	 * constants.
	 *
	 * Returns:
	 *      MDERR_OK                if successful
	 *      MDERR_SYSCALL           if the setsockopt() call failed
	 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
	 */
	__DLLIMPORT mach_error_t AMDeviceStartService(struct am_device *device, CFStringRef 
									  service_name, int *socket_fd);
	
	/* Stops a session. You should do this before accessing services.
	 *
	 * Returns:
	 *      MDERR_OK                if successful
	 *      MDERR_INVALID_ARGUMENT  if the Lockdown conn has not been established
	 */
	__DLLIMPORT mach_error_t AMDeviceStopSession(struct am_device *device);
	
	/* Decrements reference counter and, if nothing left, releases resources hold 
	 * by connection, invalidates  pointer to device
	 */
	__DLLIMPORT void AMDeviceRelease(struct am_device *device);

	/* Increments reference counter
	 */
	__DLLIMPORT void AMDeviceRetain(struct am_device *device);

	/* Opens an Apple File Connection. You must start the appropriate service
	 * first with AMDeviceStartService(). In iTunes, io_timeout is 0.
	 *
	 * Returns:
	 *      MDERR_OK                if successful
	 *      MDERR_AFC_OUT_OF_MEMORY if malloc() failed
	 */
	__DLLIMPORT afc_error_t AFCConnectionOpen(int socket_fd, unsigned int io_timeout,
								  struct afc_connection **conn);


       /* Copy an enviromental variable value from iBoot
       */
       __DLLIMPORT CFStringRef AMRecoveryModeCopyEnvironmentVariable(struct am_recovery_device *rdev, CFStringRef var);
	
	/* Pass in a pointer to an afc_dictionary structure. It will be filled. You can
	 * iterate it using AFCKeyValueRead. When done use AFCKeyValueClose. Possible keys:
	 * FSFreeBytes - free bytes on system device for afc2, user device for afc
	 * FSBlockSize - filesystem block size
	 * FSTotalBytes - size of device
	 * Model - iPhone1,1 etc.

	 */
	__DLLIMPORT afc_error_t AFCDeviceInfoOpen(struct afc_connection *conn, struct
								  afc_dictionary **info);
	
	/* Turns debug mode on if the environment variable AFCDEBUG is set to a numeric
	 * value, or if the file '/AFCDEBUG' is present and contains a value. */
#if defined(__APPLE__)
	void AFCPlatformInitialize();
#endif
	
	/* Opens a directory on the iPhone. Pass in a pointer in dir to be filled in.
	 * Note that this normally only accesses the iTunes sandbox/partition as the
	 * root, which is /var/root/Media. Pathnames are specified with '/' delimiters
	 * as in Unix style. Use UTF-8 to specify non-ASCII symbols in path.
	 *
	 * Returns:
	 *      MDERR_OK                if successful
	 */
	__DLLIMPORT afc_error_t AFCDirectoryOpen(struct afc_connection *conn, char *path, struct
								 afc_directory **dir);
	
	/* Acquires the next entry in a directory previously opened with
	 * AFCDirectoryOpen(). When dirent is filled with a NULL value, then the end
	 * of the directory has been reached. '.' and '..' will be returned as the
	 * first two entries in each directory except the root; you may want to skip
	 * over them.
	 *
	 * Returns:
	 *      MDERR_OK                if successful, even if no entries remain
	 */
	__DLLIMPORT afc_error_t AFCDirectoryRead(struct afc_connection *conn, struct afc_directory *dir,
								 char **dirent);
	__DLLIMPORT afc_error_t AFCDirectoryClose(struct afc_connection *conn, struct afc_directory *dir);
	__DLLIMPORT afc_error_t AFCDirectoryCreate(struct afc_connection *conn, char *dirname);
	__DLLIMPORT afc_error_t AFCRemovePath(struct afc_connection *conn, char *dirname);
	__DLLIMPORT afc_error_t AFCRenamePath(struct afc_connection *conn, char *oldpath, char *newpath);

#if (__ITUNES_VER >= 800)
	/* Creates symbolic or hard link
        * linktype - int64: 1 means hard link, 2 - soft (symbolic) link
        * target - absolute or relative path to link target
        * linkname - absolute path where to create new link
	 */
	__DLLIMPORT afc_error_t AFCLinkPath(struct afc_connection *conn, long long int linktype, const char *target, 
								                              const char *linkname);

#endif
	/* Opens file for reading or writing without locking it in any way. afc_file_ref should not be shared between threads - 
         * opening file in one thread and closing it in another will lead to possible crash.
	 * path - UTF-8 encoded absolute path to file
	 * mode 2 = read, mode 3 = write; unknown = 0 
	 * ref - receives file handle
	 */
	__DLLIMPORT afc_error_t AFCFileRefOpen(struct afc_connection *conn, char *path, unsigned
							   long long int mode, afc_file_ref *ref);
	/* Reads specified amount (len) of bytes from file into buf. Puts actual count of read bytes into len on return
	 */
	__DLLIMPORT afc_error_t AFCFileRefRead(struct afc_connection *conn, afc_file_ref ref,
							   void *buf, unsigned int *len);
	/* Writes specified amount (len) of bytes from buf into file.
	 */
	__DLLIMPORT afc_error_t AFCFileRefWrite(struct afc_connection *conn, afc_file_ref ref,
								void *buf, unsigned int len);
	/* Moves the file pointer to a specified location.
	 * offset - Number of bytes from origin (int64)
	 * origin - 0 = from beginning, 1 = from current position, 2 = from end
	 */
	__DLLIMPORT afc_error_t AFCFileRefSeek(struct afc_connection *conn, afc_file_ref ref,
							   unsigned long long offset, int origin, int unused);

	/* Gets the current position of a file pointer into offset argument.
	 */
	__DLLIMPORT afc_error_t AFCFileRefTell(struct afc_connection *conn, afc_file_ref ref,
							   unsigned long long* offset);

	/*  Truncates a file at the specified offset.
	 */
	__DLLIMPORT afc_error_t AFCFileRefSetFileSize(struct afc_connection *conn, afc_file_ref ref,
							   unsigned long long offset);


	__DLLIMPORT afc_error_t AFCFileRefLock(struct afc_connection *conn, afc_file_ref ref);
	__DLLIMPORT afc_error_t AFCFileRefUnlock(struct afc_connection *conn, afc_file_ref ref);
	__DLLIMPORT afc_error_t AFCFileRefClose(struct afc_connection *conn, afc_file_ref ref);

	/* Opens dictionary describing specified file or directory (iTunes below 8.2 allowed using AFCGetFileInfo
	   to get the same information)
	*/
	__DLLIMPORT afc_error_t AFCFileInfoOpen(struct afc_connection *conn, char *path, struct
								afc_dictionary **info);

	/* Reads next entry from dictionary. When last entry is read, function returns NULL in key argument
	   Possible keys:
	     "st_size":     val - size in bytes
	     "st_blocks":   val - size in blocks
	     "st_nlink":    val - number of hardlinks
	     "st_ifmt":     val - "S_IFDIR" for folders
	                        "S_IFLNK" for symlinks
	     "LinkTarget":  val - path to symlink target
	*/
	__DLLIMPORT afc_error_t AFCKeyValueRead(struct afc_dictionary *dict, char **key, char **
								val);
	/* Closes dictionary
	*/
	__DLLIMPORT afc_error_t AFCKeyValueClose(struct afc_dictionary *dict);

	
	/* Returns the context field of the given AFC connection. */
	__DLLIMPORT unsigned int AFCConnectionGetContext(struct afc_connection *conn);
	
	/* Returns the fs_block_size field of the given AFC connection. */
	__DLLIMPORT unsigned int AFCConnectionGetFSBlockSize(struct afc_connection *conn);
	
	/* Returns the io_timeout field of the given AFC connection. In iTunes this is
	 * 0. */
	__DLLIMPORT unsigned int AFCConnectionGetIOTimeout(struct afc_connection *conn);
	
	/* Returns the sock_block_size field of the given AFC connection. */
	__DLLIMPORT unsigned int AFCConnectionGetSocketBlockSize(struct afc_connection *conn);
	
	/* Closes the given AFC connection. */
	__DLLIMPORT afc_error_t AFCConnectionClose(struct afc_connection *conn);
	
	/* Registers for device notifications related to the restore process. unknown0
	 * is zero when iTunes calls this. In iTunes,
	 * the callbacks are located at:
	 *      1: $3ac68e-$3ac6b1, calls $3ac542(unknown1, arg, 0)
	 *      2: $3ac66a-$3ac68d, calls $3ac542(unknown1, 0, arg)
	 *      3: $3ac762-$3ac785, calls $3ac6b2(unknown1, arg, 0)
	 *      4: $3ac73e-$3ac761, calls $3ac6b2(unknown1, 0, arg)
	 */
	__DLLIMPORT unsigned int AMRestoreRegisterForDeviceNotifications(
				am_restore_device_notification_callback dfu_connect_callback,
				am_restore_device_notification_callback recovery_connect_callback,
				am_restore_device_notification_callback dfu_disconnect_callback,
				am_restore_device_notification_callback recovery_disconnect_callback,
				unsigned int unknown0,
				void *user_info);
	
	/* Causes the restore functions to spit out (unhelpful) progress messages to
	 * the file specified by the given path. iTunes always calls this right before
	 * restoring with a path of
	 * "$HOME/Library/Logs/iPhone Updater Logs/iPhoneUpdater X.log", where X is an
	 * unused number.
	 */
	__DLLIMPORT unsigned int AMRestoreEnableFileLogging(char *path);
	
	/* Initializes a new option dictionary to default values. Pass the constant
	 * kCFAllocatorDefault as the allocator. The option dictionary looks as
	 * follows:
	 * {
	 *      NORImageType => 'production',
	 *      AutoBootDelay => 0,
	 *      KernelCacheType => 'Release',
	 *      UpdateBaseband => true,
	 *      DFUFileType => 'RELEASE',
	 *      SystemImageType => 'User',
	 *      CreateFilesystemPartitions => true,
	 *      FlashNOR => true,
	 *      RestoreBootArgs => 'rd=md0 nand-enable-reformat=1 -progress'
	 *      BootImageType => 'User'
	 *  }
	 *
	 * Returns:
	 *      the option dictionary   if successful
	 *      NULL                    if out of memory
	 */ 
	__DLLIMPORT CFMutableDictionaryRef AMRestoreCreateDefaultOptions(CFAllocatorRef allocator);
	
	/* ----------------------------------------------------------------------------
	 *   Less-documented public routines
	 * ------------------------------------------------------------------------- */
	
	__DLLIMPORT unsigned int AMRestorePerformRecoveryModeRestore(struct am_recovery_device *
				rdev, CFDictionaryRef opts, void *callback, void *user_info);
	__DLLIMPORT unsigned int AMRestorePerformRestoreModeRestore(struct am_restore_device *
				rdev, CFDictionaryRef opts, void *callback, void *user_info);
	__DLLIMPORT struct am_restore_device *AMRestoreModeDeviceCreate(unsigned int unknown0,
				unsigned int connection_id, unsigned int unknown1);
	__DLLIMPORT unsigned int AMRestoreCreatePathsForBundle(CFStringRef restore_bundle_path,
				CFStringRef kernel_cache_type, CFStringRef boot_image_type, unsigned int
				unknown0, CFStringRef *firmware_dir_path, CFStringRef *
				kernelcache_restore_path, unsigned int unknown1, CFStringRef *
				ramdisk_path);
	__DLLIMPORT unsigned int AMRestoreModeDeviceReboot(struct am_restore_device *rdev);	// Added by JB 30.07.2008
	__DLLIMPORT mach_error_t AMDeviceEnterRecovery(struct am_device *device);
	__DLLIMPORT mach_error_t AMDeviceDisconnect(struct am_device *device);


	/* to use this, start the service "com.apple.mobile.notification_proxy", handle will be the socket to use */
	typedef void (*notify_callback)(CFStringRef notification, void* data);
	__DLLIMPORT mach_error_t AMDPostNotification(service_conn_t socket, CFStringRef  notification, CFStringRef userinfo);
	__DLLIMPORT mach_error_t AMDObserveNotification(service_conn_t socket, CFStringRef notification);
	__DLLIMPORT mach_error_t AMDListenForNotifications(service_conn_t socket, notify_callback cb, void* data);
	__DLLIMPORT mach_error_t AMDShutdownNotificationProxy(service_conn_t socket);
	
	/*edits by geohot*/
	__DLLIMPORT mach_error_t AMDeviceDeactivate(struct am_device *device);
	__DLLIMPORT mach_error_t AMDeviceActivate(struct am_device *device, CFDictionaryRef dict);
	__DLLIMPORT mach_error_t AMDeviceRemoveValue(struct am_device *device, unsigned int, CFStringRef cfstring);

  /* additional functions by imkira
   * it looks like unknown0 is actually a AMServiceConnection, but it can be NULL */
  int AMDeviceSecureTransferPath(int unknown0, struct am_device *device, CFURLRef url,
                                 CFDictionaryRef options, void *callback, int callback_arg);
  int AMDeviceSecureInstallApplication(int unknown0, struct am_device *device, CFURLRef url,
                                       CFDictionaryRef options, void *callback, int callback_arg);
  int AMDeviceSecureUninstallApplication(int unknown0, struct am_device *device, CFStringRef bundle_id,
                                         int unknown1, void *callback, int callback_arg);
  int AMDeviceLookupApplications(struct am_device *device, int unknown0, CFDictionaryRef* apps);

  /* obtained from http://theiphonewiki.com/wiki/index.php?title=USBMuxConnectByPort */
  int USBMuxConnectByPort(int connectionID, int iPhone_port_network_byte_order, int* outHandle);
	
	/* ----------------------------------------------------------------------------
	 *   Semi-private routines
	 * ------------------------------------------------------------------------- */
	
	/*  Pass in a usbmux_listener_1 structure and a usbmux_listener_2 structure
	 *  pointer, which will be filled with the resulting usbmux_listener_2.
	 *
	 *  Returns:
	 *      MDERR_OK                if completed successfully
	 *      MDERR_USBMUX_ARG_NULL   if one of the arguments was NULL
	 *      MDERR_USBMUX_FAILED     if the listener was not created successfully
	 */
	__DLLIMPORT usbmux_error_t USBMuxListenerCreate(struct usbmux_listener_1 *esi_fp8, struct
										usbmux_listener_2 **eax_fp12);
	
	/* ----------------------------------------------------------------------------
	 *   Less-documented semi-private routines
	 * ------------------------------------------------------------------------- */
	__DLLIMPORT usbmux_error_t USBMuxListenerHandleData(void *);
	
	/* ----------------------------------------------------------------------------
	 *   Private routines - here be dragons
	 * ------------------------------------------------------------------------- */
	
	/* AMRestorePerformRestoreModeRestore() calls this function with a dictionary
	 * in order to perform certain special restore operations
	 * (RESTORED_OPERATION_*). It is thought that this function might enable
	 * significant access to the phone. */
	
	/*
	 typedef unsigned int (*t_performOperation)(struct am_restore_device *rdev,
	 CFDictionaryRef op) __attribute__ ((regparm(2)));
	 t_performOperation _performOperation = (t_performOperation)0x3c39fa4b;
	 */ 
	
	/* ----------------------------------------------------------------------------
	 *   Less-documented private routines
	 * ------------------------------------------------------------------------- */
	
	
	/*
	 typedef int (*t_socketForPort)(struct am_restore_device *rdev, unsigned int port)
	 __attribute__ ((regparm(2)));
	 t_socketForPort _socketForPort = (t_socketForPort)(void *)0x3c39f36c;
	 
	 typedef void (*t_restored_send_message)(int port, CFDictionaryRef msg);
	 t_restored_send_message _restored_send_message = (t_restored_send_message)0x3c3a4e40;
	 
	 typedef CFDictionaryRef (*t_restored_receive_message)(int port);
	 t_restored_receive_message _restored_receive_message = (t_restored_receive_message)0x3c3a4d40;
	 
	 typedef unsigned int (*t_sendControlPacket)(struct am_recovery_device *rdev, unsigned
	 int msg1, unsigned int msg2, unsigned int unknown0, unsigned int *unknown1,
	 unsigned char *unknown2) __attribute__ ((regparm(3)));
	 t_sendControlPacket _sendControlPacket = (t_sendControlPacket)0x3c3a3da3;;
	 
	 typedef unsigned int (*t_sendCommandToDevice)(struct am_recovery_device *rdev,
	 CFStringRef cmd) __attribute__ ((regparm(2)));
	 t_sendCommandToDevice _sendCommandToDevice = (t_sendCommandToDevice)0x3c3a3e3b;
	 
	 typedef unsigned int (*t_AMRUSBInterfaceReadPipe)(unsigned int readwrite_pipe, unsigned
	 int read_pipe, unsigned char *data, unsigned int *len);
	 t_AMRUSBInterfaceReadPipe _AMRUSBInterfaceReadPipe = (t_AMRUSBInterfaceReadPipe)0x3c3a27e8;
	 
	 typedef unsigned int (*t_AMRUSBInterfaceWritePipe)(unsigned int readwrite_pipe, unsigned
	 int write_pipe, void *data, unsigned int len);
	 t_AMRUSBInterfaceWritePipe _AMRUSBInterfaceWritePipe = (t_AMRUSBInterfaceWritePipe)0x3c3a27cb;
	 */
	
	int performOperation(struct am_restore_device *rdev, CFMutableDictionaryRef message);
	int socketForPort(struct am_restore_device *rdev, unsigned int portnum);
	int sendCommandToDevice(struct am_recovery_device *rdev, CFStringRef cfs, int block);
	int sendFileToDevice(struct am_recovery_device *rdev, CFStringRef filename); 
	

#ifdef __cplusplus
}
#endif

#endif

/* -*- mode:c; indent-tabs-mode:nil; c-basic-offset:2; tab-width:2; */
