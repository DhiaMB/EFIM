// this class is responsible for managing the caching data
import 'dart:async';

class DataCache<T> {
// creating the data cache
//.broadcast() constructor allows multiple listeners to listen to the stream.
  final _streamController = StreamController<List<T>>.broadcast();
  List<T> _cachedData = [];

  Stream<List<T>> get stream => _streamController.stream;

//The cacheData method is used to update the cached data
//and notify listeners of the change.
  void cacheData(List<T> data) {
    _cachedData = data;
    _streamController.add(_cachedData);

//It's important to clean up resources when
// they're no longer needed to prevent memory leaks
    void dispose() {
      _streamController.close();
    }
  }
}
