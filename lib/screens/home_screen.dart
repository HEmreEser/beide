import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_apple_button.dart';
import 'my_loans_screen.dart';

final _equipmentProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  return ApiService.getEquipment();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final equipmentAsync = ref.watch(_equipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("HM Sportsgear"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(_equipmentProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2C2C2E)),
              child: Text(
                auth.email ?? 'Gast',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text("Meine Ausleihen"),
              onTap: () => Navigator.of(context).pushNamed('/myloans'),
            ),
          ],
        ),
      ),
      body: equipmentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Fehler beim Laden: $e")),
        data:
            (equipments) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: equipments.length,
              itemBuilder: (context, index) {
                final eq = equipments[index];
                return Card(
                  color: const Color(0xFF2C2C2E),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Icon(
                      Icons.sports,
                      color:
                          eq['available'] == true ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      eq['name'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(eq['description'] ?? ''),
                    trailing:
                        eq['available'] == true
                            ? AnimatedAppleButton(
                              label: "Leihen",
                              loading: false,
                              onTap: () async {
                                final today = DateTime.now();
                                final in7Days = today.add(
                                  const Duration(days: 7),
                                );
                                final res = await ApiService.createRental(
                                  eq['id'],
                                  today.toIso8601String().substring(0, 10),
                                  in7Days.toIso8601String().substring(0, 10),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Ausleihe beantragt: ${res['equipmentName'] ?? eq['name']}",
                                      ),
                                    ),
                                  );
                                  ref.refresh(_equipmentProvider);
                                }
                              },
                            )
                            : const Text(
                              "Verliehen",
                              style: TextStyle(color: Colors.red),
                            ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
