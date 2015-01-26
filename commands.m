#include "commands.h"
#include <stdio.h>
#include <string.h>

command commands[] =
{
  {"list_devices", list_devices},
  {"describe_device", describe_device},
  {"list_apps", list_apps},
  {"describe_app", describe_app},
  {"install_app", install_app},
  {"uninstall_app", uninstall_app},
  {"tunnel", tunnel},
  {"get_bundle_id", get_bundle_id},
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
