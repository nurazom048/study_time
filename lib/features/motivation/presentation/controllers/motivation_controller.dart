import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/providers.dart';
import '../../domain/models/motivation_item.dart';

final motivationControllerProvider = Provider<MotivationItem>((ref) {
  final repo = ref.watch(motivationRepositoryProvider);
  return repo.getTodayMotivation();
});
