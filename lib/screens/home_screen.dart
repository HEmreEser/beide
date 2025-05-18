import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/animated_apple_button.dart';
import 'dart:ui';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// Provider für die Suchfilter
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final availabilityFilterProvider = StateProvider<bool?>((ref) => null);

// Gefilterter Equipment Provider
final _equipmentProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  final equipment = await ApiService.getEquipment();
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(categoryFilterProvider);
  final availabilityFilter = ref.watch(availabilityFilterProvider);

  return equipment.where((eq) {
    if (searchQuery.isNotEmpty &&
        !eq['name'].toString().toLowerCase().contains(searchQuery) &&
        !eq['description'].toString().toLowerCase().contains(searchQuery)) {
      return false;
    }
    if (categoryFilter != null && eq['category'] != categoryFilter) {
      return false;
    }
    if (availabilityFilter != null && eq['available'] != availabilityFilter) {
      return false;
    }
    return true;
  }).toList();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final equipmentAsync = ref.watch(_equipmentProvider);
    final isAdmin = auth.email?.endsWith('@admin.hm.edu') ?? false;

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
          "HM Sportsgear",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.pushNamed(context, '/admin/equipment'),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(_equipmentProvider),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: const Color(0xFF2C2C2E),
                      title: Text('Profil: ${auth.email}'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.list),
                            label: const Text('Meine Ausleihen'),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/myloans');
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.logout),
                            label: const Text('Abmelden'),
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.purple.shade900],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: kToolbarHeight + 20),
            // Suchleiste
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged:
                    (value) =>
                        ref.read(searchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Suche nach Equipment...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            // Verfügbarkeits-Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Verfügbar'),
                    selected: ref.watch(availabilityFilterProvider) == true,
                    onSelected: (selected) {
                      ref.read(availabilityFilterProvider.notifier).state =
                          selected ? true : null;
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Verliehen'),
                    selected: ref.watch(availabilityFilterProvider) == false,
                    onSelected: (selected) {
                      ref.read(availabilityFilterProvider.notifier).state =
                          selected ? false : null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Kategorie-Filter
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children:
                    [
                          'Freizeitsport',
                          'Fortbewegungsmittel',
                          'Kleidung',
                          'Training',
                        ]
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected:
                                  ref.watch(categoryFilterProvider) == category,
                              onSelected: (selected) {
                                ref
                                    .read(categoryFilterProvider.notifier)
                                    .state = selected ? category : null;
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            // Equipment Liste
            Expanded(
              child: equipmentAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:
                    (e, _) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text("Fehler beim Laden: $e"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ref.refresh(_equipmentProvider),
                            child: const Text("Erneut versuchen"),
                          ),
                        ],
                      ),
                    ),
                data:
                    (equipments) => ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: equipments.length,
                      itemBuilder: (context, index) {
                        final eq = equipments[index];
                        return Hero(
                          tag: 'equipment-${eq['id']}',
                          child: Card(
                            elevation: 8,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2C2C2E,
                                    ).withOpacity(0.9),
                                  ),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              eq['available'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                          child: Icon(
                                            Icons.sports,
                                            color: Colors.white,
                                          ),
                                        ),
                                        title: Text(
                                          eq['name'] ?? '',
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
                                              eq['description'] ?? '',
                                              style: TextStyle(
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Chip(
                                                  label: Text(
                                                    eq['category'] ?? 'Keine',
                                                  ),
                                                  backgroundColor: Colors.blue
                                                      .withOpacity(0.2),
                                                ),
                                                const SizedBox(width: 8),
                                                if (eq['rating'] != null)
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color: Colors.amber,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        '${eq['rating']}',
                                                        style: const TextStyle(
                                                          color: Colors.amber,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing:
                                            eq['available'] == true
                                                ? AnimatedAppleButton(
                                                  label: "Leihen",
                                                  loading: false,
                                                  onTap: () async {
                                                    final today =
                                                        DateTime.now();
                                                    final in7Days = today.add(
                                                      const Duration(days: 7),
                                                    );
                                                    final res =
                                                        await ApiService.createRental(
                                                          eq['id'],
                                                          today
                                                              .toIso8601String()
                                                              .substring(0, 10),
                                                          in7Days
                                                              .toIso8601String()
                                                              .substring(0, 10),
                                                        );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            "Ausleihe beantragt: ${res['equipmentName'] ?? eq['name']}",
                                                          ),
                                                        ),
                                                      );
                                                      ref.refresh(
                                                        _equipmentProvider,
                                                      );
                                                    }
                                                  },
                                                )
                                                : Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Verliehen",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                      ),
                                      // Bewertungen
                                      if (eq['reviews']?.isNotEmpty == true)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Bewertungen',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ...List.generate(
                                                (eq['reviews'] as List).length >
                                                        2
                                                    ? 2
                                                    : (eq['reviews'] as List)
                                                        .length,
                                                (index) {
                                                  final review =
                                                      eq['reviews'][index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          bottom: 8,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        RatingBar.builder(
                                                          initialRating:
                                                              review['rating']
                                                                  ?.toDouble() ??
                                                              0,
                                                          minRating: 1,
                                                          direction:
                                                              Axis.horizontal,
                                                          allowHalfRating: true,
                                                          itemCount: 5,
                                                          itemSize: 16,
                                                          ignoreGestures: true,
                                                          itemBuilder:
                                                              (
                                                                context,
                                                                _,
                                                              ) => const Icon(
                                                                Icons.star,
                                                                color:
                                                                    Colors
                                                                        .amber,
                                                              ),
                                                          onRatingUpdate:
                                                              (_) {},
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            review['comment'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors
                                                                      .grey[300],
                                                              fontSize: 12,
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              if ((eq['reviews'] as List)
                                                      .length >
                                                  2)
                                                TextButton(
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF2C2C2E,
                                                          ),
                                                      isScrollControlled: true,
                                                      builder:
                                                          (
                                                            context,
                                                          ) => DraggableScrollableSheet(
                                                            initialChildSize:
                                                                0.9,
                                                            minChildSize: 0.5,
                                                            maxChildSize: 0.9,
                                                            builder:
                                                                (
                                                                  _,
                                                                  scrollController,
                                                                ) => Column(
                                                                  children: [
                                                                    AppBar(
                                                                      title: Text(
                                                                        'Bewertungen: ${eq['name']}',
                                                                      ),
                                                                      automaticallyImplyLeading:
                                                                          false,
                                                                      actions: [
                                                                        IconButton(
                                                                          icon: const Icon(
                                                                            Icons.close,
                                                                          ),
                                                                          onPressed:
                                                                              () => Navigator.pop(
                                                                                context,
                                                                              ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Expanded(
                                                                      child: ListView.builder(
                                                                        controller:
                                                                            scrollController,
                                                                        padding:
                                                                            const EdgeInsets.all(
                                                                              16,
                                                                            ),
                                                                        itemCount:
                                                                            (eq['reviews']
                                                                                    as List)
                                                                                .length,
                                                                        itemBuilder: (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          final review =
                                                                              eq['reviews'][index];
                                                                          return Card(
                                                                            margin: const EdgeInsets.only(
                                                                              bottom:
                                                                                  8,
                                                                            ),
                                                                            child: ListTile(
                                                                              title: Row(
                                                                                children: [
                                                                                  RatingBar.builder(
                                                                                    initialRating:
                                                                                        review['rating']?.toDouble() ??
                                                                                        0,
                                                                                    minRating:
                                                                                        1,
                                                                                    direction:
                                                                                        Axis.horizontal,
                                                                                    allowHalfRating:
                                                                                        true,
                                                                                    itemCount:
                                                                                        5,
                                                                                    itemSize:
                                                                                        20,
                                                                                    ignoreGestures:
                                                                                        true,
                                                                                    itemBuilder:
                                                                                        (
                                                                                          context,
                                                                                          _,
                                                                                        ) => const Icon(
                                                                                          Icons.star,
                                                                                          color:
                                                                                              Colors.amber,
                                                                                        ),
                                                                                    onRatingUpdate:
                                                                                        (
                                                                                          _,
                                                                                        ) {},
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    width:
                                                                                        8,
                                                                                  ),
                                                                                  Text(
                                                                                    review['userName'] ??
                                                                                        'Anonym',
                                                                                    style: const TextStyle(
                                                                                      fontSize:
                                                                                          14,
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              subtitle: Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                  top:
                                                                                      8,
                                                                                ),
                                                                                child: Text(
                                                                                  review['comment'] ??
                                                                                      '',
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                          ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Alle Bewertungen anzeigen',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      // Bewertung hinzufügen Button
                                      if (eq['canReview'] == true)
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Colors.grey.withOpacity(
                                                  0.2,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            icon: const Icon(Icons.rate_review),
                                            label: const Text(
                                              'Bewertung hinzufügen',
                                            ),
                                            onPressed: () {
                                              double rating = 0;
                                              final commentController =
                                                  TextEditingController();
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      backgroundColor:
                                                          const Color(
                                                            0xFF2C2C2E,
                                                          ),
                                                      title: const Text(
                                                        'Bewertung abgeben',
                                                      ),
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          RatingBar.builder(
                                                            initialRating: 0,
                                                            minRating: 1,
                                                            direction:
                                                                Axis.horizontal,
                                                            allowHalfRating:
                                                                true,
                                                            itemCount: 5,
                                                            itemBuilder:
                                                                (
                                                                  context,
                                                                  _,
                                                                ) => const Icon(
                                                                  Icons.star,
                                                                  color:
                                                                      Colors
                                                                          .amber,
                                                                ),
                                                            onRatingUpdate:
                                                                (value) =>
                                                                    rating =
                                                                        value,
                                                          ),
                                                          const SizedBox(
                                                            height: 16,
                                                          ),
                                                          TextField(
                                                            controller:
                                                                commentController,
                                                            decoration: const InputDecoration(
                                                              hintText:
                                                                  'Dein Kommentar',
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                            maxLines: 3,
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: const Text(
                                                            'Abbrechen',
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            if (rating == 0) {
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                    'Bitte eine Bewertung abgeben',
                                                                  ),
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            try {
                                                              await ApiService.createReview(
                                                                equipmentId:
                                                                    eq['id'],
                                                                rating:
                                                                    rating
                                                                        .round(),
                                                                comment:
                                                                    commentController
                                                                        .text,
                                                              );
                                                              if (context
                                                                  .mounted) {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                ref.refresh(
                                                                  _equipmentProvider,
                                                                );
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Bewertung wurde hinzugefügt',
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .green,
                                                                  ),
                                                                );
                                                              }
                                                            } catch (e) {
                                                              if (context
                                                                  .mounted) {
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Fehler: $e',
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: const Text(
                                                            'Bewertung absenden',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                    ],
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/myloans'),
        child: const Icon(Icons.list),
      ),
    );
  }
}
