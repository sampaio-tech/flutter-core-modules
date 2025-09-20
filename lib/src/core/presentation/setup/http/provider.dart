import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

final httpClientProvider = Provider<Client>(
  (ref) {
    final httpClient = Client();
    ref.onDispose(
      httpClient.close,
    );
    return HttpClient(
      httpClient: httpClient,
    );
  },
);

class HttpClient extends BaseClient {
  final Client httpClient;

  HttpClient({
    required this.httpClient,
  });

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers.addAll(
      {
        'Content-Type': 'application/json',
        'Connection': 'close',
      },
    );
    return httpClient.send(request);
  }
}
