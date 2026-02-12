import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_teller_app/providers/question_provider.dart';

final purchaseProvider = Provider((ref) {
  return PurchaseService(ref);
});

class PurchaseService {
  final Ref ref;
  PurchaseService(this.ref);

  Future<void> buyPremadePack(int questions) async {
    await ref
        .read(questionProvider.notifier)
        .addPremadeQuestions(questions);
  }

  Future<void> buyCustomPack(int questions) async {
    await ref
        .read(questionProvider.notifier)
        .addCustomQuestions(questions);
  }
}
