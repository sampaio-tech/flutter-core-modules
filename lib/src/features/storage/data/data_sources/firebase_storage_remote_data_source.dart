import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

import '../../../../core/domain/failures/storage_failure.dart';
import '../../../../core/domain/utils/either.dart';
import '../../../../core/presentation/setup/http/provider.dart';
import '../../domain/data_sources/storage_remote_data_source.dart';
import '../repositories/firebase_storage_repository.dart';

class FirebaseStorageRemoteDataSource extends StorageRemoteDataSource {
  final FirebaseStorage _firebaseStorage;
  final Client _httpClient;

  const FirebaseStorageRemoteDataSource({
    required FirebaseStorage firebaseStorage,
    required Client httpClient,
  }) : _firebaseStorage = firebaseStorage,
       _httpClient = httpClient;

  @override
  Future<Either<StorageFailure, String>> getDownloadUrl({
    required String path,
  }) async {
    try {
      final url = await _firebaseStorage.ref(path).getDownloadURL();
      return Right(url);
    } catch (err) {
      return const Left(UnidentifiedStorageFailure());
    }
  }

  @override
  Future<Either<StorageFailure, dynamic>> getJson({
    required String path,
  }) async {
    try {
      return await getDownloadUrl(
        path: path,
      ).then<Either<StorageFailure, dynamic>>(
        (failureOrSuccess) async =>
            failureOrSuccess.fold<Future<Either<StorageFailure, dynamic>>>(
              (failure) async => const Left(UnidentifiedStorageFailure()),
              (url) async {
                return _httpClient.get(Uri.parse(url)).then((response) async {
                  if (response.statusCode == 200) {
                    final body = response.body;
                    return Right(jsonDecode(body));
                  }
                  return const Left(UnidentifiedStorageFailure());
                });
              },
            ),
      );
    } catch (err) {
      return const Left(UnidentifiedStorageFailure());
    }
  }
}

final firebaseStorageRemoteDataSourceProvider =
    Provider.autoDispose<FirebaseStorageRemoteDataSource>(
      (ref) => FirebaseStorageRemoteDataSource(
        httpClient: ref.read(defaultHttpClientProvider),
        firebaseStorage: ref.read(firebaseStorageProvider),
      ),
    );
