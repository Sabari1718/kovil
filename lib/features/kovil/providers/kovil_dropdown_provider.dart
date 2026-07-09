import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/kovil_api_repository.dart';
import '../data/kovil_dropdown_models.dart';

final kovilApiRepositoryProvider = Provider<KovilApiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return KovilApiRepository(apiClient);
});

final sectorsProvider = FutureProvider<List<SectorModel>>((ref) async {
  final repository = ref.watch(kovilApiRepositoryProvider);
  return repository.getSectors();
});

final subSectorsProvider = FutureProvider<List<SubSectorModel>>((ref) async {
  final repository = ref.watch(kovilApiRepositoryProvider);
  return repository.getSubSectors();
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final repository = ref.watch(kovilApiRepositoryProvider);
  return repository.getCategories();
});
