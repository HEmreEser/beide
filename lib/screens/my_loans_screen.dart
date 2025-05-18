import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../widgets/animated_apple_button.dart';

final _myLoansProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  return ApiService.getMyRentals();
});

class MyLoansScreen extends ConsumerWidget {
  const MyLoansScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(_myLoansProvider);
    return Scaffold(
      appBar: AppBar(title: const Text("Meine Ausleihen")),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Fehler beim Laden: $e")),
        data:
            (loans) =>
                loans.isEmpty
                    ? const Center(
                      child: Text("Du hast aktuell keine Ausleihen."),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        final loan = loans[index];
                        return Card(
                          color: const Color(0xFF2C2C2E),
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: const Icon(
                              Icons.sports_kabaddi,
                              color: Colors.orange,
                            ),
                            title: Text(loan['equipmentName'] ?? ''),
                            subtitle: Text(
                              "Von: ${loan['startDate']} Bis: ${loan['endDate']}",
                            ),
                            trailing:
                                loan['returned'] == true
                                    ? const Text(
                                      "Zurückgegeben",
                                      style: TextStyle(color: Colors.green),
                                    )
                                    : AnimatedAppleButton(
                                      label: "Zurückgeben",
                                      loading: false,
                                      onTap: () async {
                                        final res =
                                            await ApiService.returnRental(
                                              loan['id'],
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text("$res")),
                                          );
                                          ref.refresh(_myLoansProvider);
                                        }
                                      },
                                    ),
                          ),
                        );
                      },
                    ),
      ),
    );
  }
}
