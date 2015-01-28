#include "commands.h"
#include <stdio.h>
#include <string.h>

command commands[] =
{
  {"list_devices", list_devices},
  {"list_device_props", list_device_props},
  {"get_device_prop", get_device_prop},
  {"list_apps", list_apps},
  {"list_app_props", list_app_props},
  {"get_app_prop", get_app_prop},
  {"install_app", install_app},
  {"uninstall_app", uninstall_app},
  {"tunnel", tunnel},
  {"get_bundle_id", get_bundle_id},
  {"version", version},
  {"help", help},
  {NULL, NULL}
};

command *get_command(const char *name)
{
  for (command *cmd = commands; cmd->name != NULL; cmd++)
  {
    if (strcmp(cmd->name, name) == 0)
    {
      return cmd;
    }
  }
  return NULL;
}
