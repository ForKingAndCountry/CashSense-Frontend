import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  await Hive.openBox<Map>(AppBoxes.transactions);
  await Hive.openBox<Map>(AppBoxes.debts);
  await Hive.openBox<Map>(AppBoxes.settings);
  await Hive.openBox<Map>(AppBoxes.subscription);
  await Hive.openBox<Map>(AppBoxes.syncQueue);
  await Hive.openBox<Map>(AppBoxes.wallets);
  await Hive.openBox<Map>(AppBoxes.buffers);
  await Hive.openBox<Map>(AppBoxes.allocationPlans);
  await Hive.openBox<Map>(AppBoxes.reports);

  _migrateCategories();

  runApp(const ProviderScope(child: App()));
}

void _migrateCategories() {
  final box = Hive.box<Map>(AppBoxes.transactions);
  for (final key in box.keys) {
    final dynamic entry = box.get(key);
    if (entry is Map) {
      final String? category = entry['category'] as String?;
      final String? type = entry['type'] as String?;
      if (category != null) {
        String newCategory = category;
        if (category == 'Rent') {
          newCategory = 'Essential Fixed';
        } else if (category == 'Food' || category == 'Transport' || category == 'Data') {
          newCategory = 'Essential Variable';
        } else if (category == 'Business') {
          newCategory = type == 'income' ? 'Systemic Income' : 'Essential Variable';
        } else if (category == 'Gift' || category == 'Other') {
          newCategory = type == 'income' ? 'Labor Income' : 'Non-essential Variable';
        }

        if (newCategory != category) {
          final updated = Map<dynamic, dynamic>.of(entry);
          updated['category'] = newCategory;
          box.put(key, updated);
        }
      }
    }
  }
}
