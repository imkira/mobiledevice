extern int list_devices(int argc, char *argv[]);
extern int list_device_props(int argc, char *argv[]);
extern int get_device_prop(int argc, char *argv[]);
extern int list_apps(int argc, char *argv[]);
extern int list_app_props(int argc, char *argv[]);
extern int get_app_prop(int argc, char *argv[]);
extern int install_app(int argc, char *argv[]);
extern int uninstall_app(int argc, char *argv[]);
extern int tunnel(int argc, char *argv[]);
extern int get_bundle_id(int argc, char *argv[]);
extern int version(int argc, char *argv[]);
extern int help(int argc, char *argv[]);
extern int invalid_usage(int argc, char *argv[]);

typedef struct
{
  const char *name;
  int (*func)(int argc, char *argv[]);
} command;

extern command commands[];
extern command *get_command(const char *name);
