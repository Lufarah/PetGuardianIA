import 'package:flutter/material.dart';
import '../services/pet_service.dart';
import 'pet_list_screen.dart';

class AddPetScreen extends StatelessWidget {

  AddPetScreen({super.key});

  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final PetService petService = PetService();

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Agregar Mascota'),
        backgroundColor: Colors.teal,

        actions: [

          IconButton(

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetListScreen(),
                ),
              );
            },

            icon: const Icon(Icons.list),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: breedController,
              decoration: const InputDecoration(
                labelText: 'Raza',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: ageController,
              decoration: const InputDecoration(
                labelText: 'Edad',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(

              controller: weightController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: 'Peso (kg)',

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () async {

                  await petService.addPet(
                    name: nameController.text.trim(),
                    breed: breedController.text.trim(),
                    age: ageController.text.trim(),
                    weight: weightController.text.trim(),
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mascota guardada'),
                    ),
                  );

                  nameController.clear();
                  breedController.clear();
                  ageController.clear();
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),

                child: const Text(
                  'Guardar Mascota',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}