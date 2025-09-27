import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/data/data_sources/shared_preferences_cache_local_data_source.dart';
import '../../domain/repositories/storage_repository.dart';
import '../data_sources/firebase_storage_remote_data_source.dart';

class FirebaseStorageRepository extends StorageRepository {
  @override
  final SharedPreferencesCacheLocalDataSource localDataSource;
  @override
  final FirebaseStorageRemoteDataSource remoteDataSource;

  const FirebaseStorageRepository({
    required this.localDataSource,
    required this.remoteDataSource,
  }) : super(
         localDataSource: localDataSource,
         remoteDataSource: remoteDataSource,
       );
}

final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

final firebaseStorageRepositoryProvider =
    Provider.autoDispose<StorageRepository>(
      (ref) => FirebaseStorageRepository(
        localDataSource: ref.read(
          sharedPreferencesCacheLocalDataSourceProvider,
        ),
        remoteDataSource: ref.read(firebaseStorageRemoteDataSourceProvider),
      ),
    );
