import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/providers.dart';
import '../../../../domain/entities/buffer_entity.dart';
import '../../../../domain/entities/currency.dart';
import '../../../../domain/repositories/buffers_repository.dart';
import '../../../../data/repositories/buffers_repository_impl.dart';

final buffersRepositoryProvider = Provider<BuffersRepository>((ref) {
  return BuffersRepositoryImpl(ref.read(buffersLocalProvider), ref.read(syncQueueProvider));
});

final buffersProvider = AsyncNotifierProvider<BuffersNotifier, List<BufferEntity>>(BuffersNotifier.new);

class BuffersNotifier extends AsyncNotifier<List<BufferEntity>> {
  @override
  Future<List<BufferEntity>> build() async {
    return ref.read(buffersRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await ref.read(buffersRepositoryProvider).getAll());
  }

  Future<void> addBuffer({
    required String name,
    required double annualEstimate,
    required Currency currency,
    String? purpose,
  }) async {
    final now = DateTime.now();
    await ref.read(buffersRepositoryProvider).upsert(
          BufferEntity(
            id: const Uuid().v4(),
            name: name.trim().isEmpty ? 'Buffer' : name.trim(),
            purpose: purpose?.trim().isEmpty ?? true ? null : purpose?.trim(),
            annualEstimate: annualEstimate,
            currentBalance: 0,
            currency: currency,
            synced: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await refresh();
  }

  Future<void> fundBuffer(String id, double amount) async {
    await ref.read(buffersRepositoryProvider).fund(id, amount);
    await refresh();
  }

  Future<void> deleteBuffer(String id) async {
    await ref.read(buffersRepositoryProvider).delete(id);
    await refresh();
  }
}
