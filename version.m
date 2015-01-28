#include "cli.h"

int version(int argc, char *argv[])
{
  int flag;
  bool include_revision = false;

  while ((flag = getopt(argc, argv, "r")) != -1)
  {
    switch (flag)
    {
      case 'r':
        include_revision = true;
        break;

      default:
        help(argc, argv);
        return 1;
    }
  }

  argc -= optind;
  argv += optind;

  if (argc != 0)
  {
    return invalid_usage(argc, argv);
  }

  if (include_revision == true)
  {
    printf("%s.%s\n", MOBILEDEVICE_CLI_VERSION, MOBILEDEVICE_CLI_REVISION);
  }
  else
  {
    printf("%s\n", MOBILEDEVICE_CLI_VERSION);
  }
  return 0;
}
