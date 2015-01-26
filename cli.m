#include "cli.h"

int main(int argc, char *argv[])
{
  if (argc < 2)
  {
    help(argc, argv);
    return 2;
  }

  const char *name = argv[1];
  command *cmd = get_command(name);

  --argc;
  ++argv;

  if (cmd == NULL)
  {
    return invalid_usage(argc, argv);
  }

  return cmd->func(argc, argv);
}

void printfNS(NSString *format, ...)
{
  va_list args;
  va_start(args, format);
  NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  fprintf(stdout, "%s", [str UTF8String]);
}
