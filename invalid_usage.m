#include "cli.h"

int invalid_usage(int argc, char *argv[])
{
  fprintf(stderr, "Invalid usage\n");
  help(argc, argv);
  return 1;
}
