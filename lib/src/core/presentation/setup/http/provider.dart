import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

final defaultHttpClientProvider = Provider<Client>((ref) {
  final httpClient = Client();
  ref.onDispose(httpClient.close);
  return DefaultClient(httpClient: httpClient, ref: ref);
});

final httpClientProvider = Provider<Client>((ref) {
  final httpClient = Client();
  ref.onDispose(httpClient.close);
  return HttpClient(httpClient: httpClient);
});

class HttpClient extends BaseClient {
  final Client httpClient;

  HttpClient({required this.httpClient});

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers.addAll({
      'Content-Type': 'application/json',
      'Connection': 'close',
    });
    return httpClient.send(request);
  }
}

class DefaultClient extends BaseClient {
  final Ref ref;
  final Client httpClient;

  DefaultClient({required this.ref, required this.httpClient});

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers.addAll({'Content-Type': 'application/json'});
    return httpClient.send(request);
  }
}
