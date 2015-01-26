#include "cli.h"

int get_bundle_id(int argc, char *argv[])
{
  if (argc != 2)
  {
    return invalid_usage(argc, argv);
  }

  NSString *path = [NSString stringWithUTF8String:argv[1]];
  path = [path stringByAppendingPathComponent:@"Info.plist"];

  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
  NSString *bundle_id = dict[@"CFBundleIdentifier"];

  if (bundle_id == nil)
  {
    return 1;
  }

  printfNS(@"%@\n", bundle_id);
  return 0;
}
