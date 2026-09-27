import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/aquarium_firestore_model.dart';
import '../services/firestore_service.dart';

class AquariumLivestockScreen extends StatelessWidget {
  const AquariumLivestockScreen({required this.aquarium, super.key});

  final AquariumModel aquarium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Obsada: ${aquarium.name}')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getLivestock(aquarium.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Nie udało się wczytać obsady.'));
          }
          final entries = snapshot.data ?? const <Map<String, dynamic>>[];
          if (entries.isEmpty) {
            return const Center(child: Text('To akwarium nie ma jeszcze obsady.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final addedAt = entry['addedAt'];
              final date = addedAt is Timestamp ? addedAt.toDate() : null;
              final notes = entry['notes']?.toString() ?? '';
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.pets_outlined),
                  title: Text(entry['namePl']?.toString() ?? 'Nieznany gatunek'),
                  subtitle: Text(
                    [
                      if ((entry['nameLatin']?.toString() ?? '').isNotEmpty)
                        entry['nameLatin'].toString(),
                      entry['category']?.toString() ?? '',
                      'Liczba: ${entry['count'] ?? 1}',
                      if (date != null)
                        'Dodano: ${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                      if (notes.isNotEmpty) notes,
                    ].where((line) => line.isNotEmpty).join(' · '),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
