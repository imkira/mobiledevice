#include "cli.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <signal.h>

#define TUNNEL_MAX_CONNS (FD_SETSIZE / 2 - 1)

#define FLPRINT(...)           \
  do                           \
  {                            \
    printf( __VA_ARGS__);      \
    fflush(stdout);            \
  } while (0)

#define TUNNEL_ASSERT_OR_EXIT(_cnd_, _t_, ...)  \
  do                                            \
  {                                             \
    if (!(_cnd_))                               \
    {                                           \
      fprintf(stderr, __VA_ARGS__);             \
      terminate_tunnel(_t_);                    \
      device_unregister(1);                     \
    }                                           \
  } while (0)

struct mobiletunnel
{
  struct am_device *device;
  uint16_t src_port;
  uint16_t dst_port;
  int sock;
  struct
  {
    int src_sock;
    int dst_sock;
  } conns[TUNNEL_MAX_CONNS];
  int conn_count;
  fd_set monitored_socks;
} *current_tunnel = NULL;

void init_tunnel(struct mobiletunnel *t)
{
  t->sock = -1;
  t->conn_count = 0;
  FD_ZERO(&t->monitored_socks);
}

int tunnel_max_socket(struct mobiletunnel *t)
{
  int i, max_sock = t->sock;

  for (i = 0; i < t->conn_count; ++i)
  {
    if (t->conns[i].src_sock > max_sock)
    {
      max_sock = t->conns[i].src_sock;
    }
    if (t->conns[i].dst_sock > max_sock)
    {
      max_sock = t->conns[i].dst_sock;
    }
  }
  return max_sock;
}

void remove_tunnel_conn(struct mobiletunnel *t, int conn)
{
  // close connection sockets
  close(t->conns[conn].src_sock);
  close(t->conns[conn].dst_sock);

  // unmonitor them
  FD_CLR(t->conns[conn].src_sock, &t->monitored_socks);
  FD_CLR(t->conns[conn].dst_sock, &t->monitored_socks);

  // remove them from the array
  if (t->conn_count > 1)
  {
    memcpy(&t->conns[conn], &t->conns[t->conn_count - 1], sizeof(t->conns[0]));
  }
  t->conn_count--;
}

void terminate_tunnel(struct mobiletunnel *t)
{
  int i = 0;

  // close all connections
  while (t->conn_count > 0)
  {
    FLPRINT("Closing connection between client and device...\n");
    remove_tunnel_conn(t, i);
  }
  // close server socket
  if (t->sock != -1)
  {
    FLPRINT("Closing tunnel...\n");
    close(t->sock);
  }
  init_tunnel(t);
}

void add_tunnel_conn(struct mobiletunnel *t, int src_sock, int dst_sock)
{
  // add connection sockets to array
  t->conns[t->conn_count].src_sock = src_sock;
  t->conns[t->conn_count].dst_sock = dst_sock;
  t->conn_count++;
  // monitor new connection sockets
  FD_SET(src_sock, &t->monitored_socks);
  FD_SET(dst_sock, &t->monitored_socks);
}

int accept_tunnel_conn(struct mobiletunnel *t)
{
  struct sockaddr_in addr;
  socklen_t addr_size = sizeof(addr);
  int src_sock = accept(t->sock, (struct sockaddr *)&addr, &addr_size);

  // could not accept client?
  if (src_sock < 0)
  {
    return 0;
  }

  FLPRINT("Got new client!\n");

  if (t->conn_count >= TUNNEL_MAX_CONNS)
  {
    fprintf(stderr, "Cannot accept client: too many connections!\n");
    // too many connections, reject this client
    close(src_sock);
    return 0;
  }

  unsigned int device_id = AMDeviceGetConnectionID(t->device);
  int dst_sock;

  // connect to device
  if (USBMuxConnectByPort(device_id, htons(t->dst_port), &dst_sock) != 0)
  {
    fprintf(stderr, "Device refused connection to port %d!\n", t->dst_port);
    // connection failed, reject this client
    close(src_sock);
    return 0;
  }

  FLPRINT("Forwarding connection to device...\n");

  // register connection between source and remove sockets
  add_tunnel_conn(t, src_sock, dst_sock);
  return 1;
}

int process_tunnel_sock(struct mobiletunnel *t, int conn, int direction)
{
  char buffer[512];
  int src_sock, dst_sock;

  if (direction == 0)
  {
    src_sock = t->conns[conn].src_sock;
    dst_sock = t->conns[conn].dst_sock;
  }
  else
  {
    src_sock = t->conns[conn].dst_sock;
    dst_sock = t->conns[conn].src_sock;
  }

  // read data from client or device
  ssize_t recv_count = recv(src_sock, buffer, sizeof(buffer), 0);

  // error reading or connection terminated?
  if (recv_count <= 0)
  {
    fprintf(stderr, "Connection terminated!\n");
    remove_tunnel_conn(t, conn);
    return 0;
  }

  // forward data to the other party
  send(dst_sock, buffer, recv_count, 0);
  return 1;
}

void tunnel_loop(struct mobiletunnel *t)
{
  fd_set signaled_socks;
  int ready_count, processed_count, i;

  FD_SET(t->sock, &t->monitored_socks);

  while (1)
  {
    signaled_socks = t->monitored_socks;
    processed_count = 0;

    // wait for a new connection or new data on sockets to be tunnelled
    ready_count = select(tunnel_max_socket(t) + 1, &signaled_socks,
                         NULL, NULL, NULL);


    TUNNEL_ASSERT_OR_EXIT(ready_count > 0, t, "!select\n");

    // new connection to tunnel server?
    if (FD_ISSET(t->sock, &signaled_socks))
    {
      accept_tunnel_conn(t);
      ++processed_count;
    }

    // process sockets (in reverse order because they can be removed)
    for (i = t->conn_count - 1; (processed_count < ready_count) && (i >= 0); --i)
    {
      // client wants to write data to device?
      if (FD_ISSET(t->conns[i].src_sock, &signaled_socks))
      {
        ++processed_count;
        if (!process_tunnel_sock(t, i, 0))
        {
          // don't care about processed_count possibly becoming out of sync
          continue;
        }
      }
      // device wants to write data to client?
      if (FD_ISSET(t->conns[i].dst_sock, &signaled_socks))
      {
        ++processed_count;
        process_tunnel_sock(t, i, 1);
      }
    }
  }
}

void terminate_tunnel_at_exit(int sig)
{
  if (current_tunnel != NULL)
  {
    FLPRINT("Terminating...\n");
    terminate_tunnel(current_tunnel);
    current_tunnel = NULL;
    device_unregister(0);
  }
  exit(0);
}

void create_tunnel(struct am_device *device, uint16_t src_port, uint16_t dst_port)
{
  struct mobiletunnel t;
  int reuse = 1;
  struct sockaddr_in addr;
  socklen_t addr_size;

  // initialize tunnel server socket
  init_tunnel(&t);
  t.device = device;
  t.src_port = src_port;
  t.dst_port = dst_port;

  t.sock = socket(AF_INET, SOCK_STREAM, 0);
  TUNNEL_ASSERT_OR_EXIT(t.sock != -1, &t, "!socket\n");

  setsockopt(t.sock, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse, sizeof(reuse));

  // specify tunnel server address (localhost) and port
  addr_size = sizeof(addr);
  memset(&addr, 0, addr_size);
  addr.sin_family = AF_INET;
  addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  addr.sin_port = htons(src_port);

  // bind server socket to the address we specified
  if ((bind(t.sock, (struct sockaddr *)&addr, addr_size) != 0) ||
      (listen(t.sock, 10) != 0))
  {
    TUNNEL_ASSERT_OR_EXIT(0, &t, "Failed to bind to port %d!\n", src_port);
  }

  // if user passes port 0 as local port, we want to print out the real port.
  if ((src_port == 0) &&
      (getsockname(t.sock, (struct sockaddr *)&addr, &addr_size) == 0))
  {
    src_port = ntohs(addr.sin_port);
  }

  FLPRINT("Tunneling from local port %u to device port %u...\n", src_port, dst_port);

  // register termination function
  current_tunnel = &t;
  signal(SIGHUP, terminate_tunnel_at_exit);
  signal(SIGINT, terminate_tunnel_at_exit);
  signal(SIGQUIT, terminate_tunnel_at_exit);
  signal(SIGTERM, terminate_tunnel_at_exit);

  // accept connections and tunnel them
  tunnel_loop(&t);
}

static char *expected_udid = NULL;
static uint16_t tunnel_src_port = 0;
static uint16_t tunnel_dst_port = 0;

static void on_device_connected(struct am_device *device)
{
  if (!device_matches(device, expected_udid))
  {
    return;
  }

  device_delayed_unregister_aborted = true;
  device_connect(device);
  create_tunnel(device, tunnel_src_port, tunnel_dst_port);
}

int tunnel(int argc, char *argv[])
{
  int flag;
  char *endptr;
  int64_t timeout = -1;

  while ((flag = getopt(argc, argv, "u:t:")) != -1)
  {
    switch (flag)
    {
      case 'u':
        expected_udid = optarg;
        break;

      case 't':
        timeout = strtoll(optarg, &endptr, 10);
        break;

      default:
        help(argc, argv);
        return 1;
    }
  }

  argc -= optind;
  argv += optind;

  if (argc != 2)
  {
    return invalid_usage(argc, argv);
  }

  tunnel_src_port = (uint16_t)atoi(argv[0]);
  tunnel_dst_port = (uint16_t)atoi(argv[1]);

  device_delayed_unregister_status = 1;
  device_register(on_device_connected, timeout);
  return 1;
}
