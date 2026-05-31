import '../../domain/entities/buffer_entity.dart';

abstract class BuffersRepository {
  Future<List<BufferEntity>> getAll();
  Future<void> upsert(BufferEntity buffer);
  Future<void> delete(String id);
  Future<void> fund(String id, double amount);
  Future<void> clear();
}
