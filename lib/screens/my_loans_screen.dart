import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../widgets/animated_apple_button.dart';
import 'dart:ui';

final _myLoansProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  try {
    return await ApiService.getMyRentals();
  } catch (e) {
    print('Error in myLoansProvider: $e');
    rethrow;
  }
});

class MyLoansScreen extends ConsumerWidget {
  const MyLoansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(_myLoansProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: const Text(
          "Meine Ausleihen",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade900],
          ),
        ),
        child: loansAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) {
            print('Error: $e\nStackTrace: $st');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    "Fehler beim Laden: $e",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(_myLoansProvider),
                    child: const Text("Erneut versuchen"),
                  ),
                ],
              ),
            );
          },
          data:
              (loans) =>
                  loans.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.sports_kabaddi,
                              size: 100,
                              color: Colors.white54,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Du hast aktuell keine Ausleihen",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.search),
                              label: const Text("Equipment suchen"),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.only(
                          top:
                              MediaQuery.of(context).padding.top +
                              kToolbarHeight +
                              16,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        itemCount: loans.length,
                        itemBuilder: (context, index) {
                          final loan = loans[index];
                          return Hero(
                            tag: 'loan-${loan['id']}',
                            child: Card(
                              elevation: 8,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 5,
                                    sigmaY: 5,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2C2C2E,
                                      ).withOpacity(0.9),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            loan['returned'] == true
                                                ? Colors.green
                                                : Colors.orange,
                                        child: Icon(
                                          loan['returned'] == true
                                              ? Icons.check
                                              : Icons.sports_kabaddi,
                                          color: Colors.white,
                                        ),
                                      ),
                                      title: Text(
                                        loan['equipmentName'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 8),
                                          Text(
                                            "Von: ${loan['startDate']} Bis: ${loan['endDate']}",
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing:
                                          loan['returned'] == true
                                              ? const Chip(
                                                label: Text("Zurückgegeben"),
                                                backgroundColor: Colors.green,
                                              )
                                              : AnimatedAppleButton(
                                                label: "Zurückgeben",
                                                loading: false,
                                                onTap: () async {
                                                  try {
                                                    final res =
                                                        await ApiService.returnRental(
                                                          loan['id'],
                                                        );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Equipment erfolgreich zurückgegeben!",
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                      ref.refresh(
                                                        _myLoansProvider,
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Fehler: $e",
                                                          ),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                              ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
        ),
      ),
    );
  }
}
