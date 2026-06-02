import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/pet_service.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  final QueryDocumentSnapshot<Map<String, dynamic>> pet;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  late final TextEditingController nameController;
  late final TextEditingController breedController;
  late final TextEditingController ageController;
  late final TextEditingController weightController;

  final PetService petService = PetService();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.pet.data();
    nameController = TextEditingController(text: data['name'] as String? ?? '');
    breedController = TextEditingController(text: data['breed'] as String? ?? '');
    ageController = TextEditingController(text: data['age'] as String? ?? '');
    weightController = TextEditingController(text: data['weight'] as String? ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    ageController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final name = nameController.text.trim();
    final breed = breedController.text.trim();
    final age = ageController.text.trim();
    final weight = weightController.text.trim();

    if (name.isEmpty || breed.isEmpty || age.isEmpty || weight.isEmpty) {
      _showMessage('Completa todos los campos.');
      return;
    }

    setState(() => isSaving = true);

    try {
      await petService.updatePet(
        petId: widget.pet.id,
        name: name,
        breed: breed,
        age: age,
        weight: weight,
      );

      if (!mounted) return;
      _showMessage('Mascota actualizada');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo actualizar la mascota: $e');
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar mascota'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.pets,
              size: 100,
              color: Colors.teal,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: breedController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Raza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Edad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  isSaving ? 'Guardando...' : 'Guardar cambios',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
