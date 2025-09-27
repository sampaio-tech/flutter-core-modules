sealed class StorageFailure {
  const StorageFailure();
}

class UnidentifiedStorageFailure extends StorageFailure {
  const UnidentifiedStorageFailure();
}

class EmptyCacheStorageFailure extends StorageFailure {
  const EmptyCacheStorageFailure();
}
