import 'package:tcp_socket_connection/tcp_socket_connection.dart';

TcpSocketConnection createConnection(String url, int port) {
  TcpSocketConnection socket = TcpSocketConnection(
    url,
    port,
  );
  return socket;
}
