import 'package:flutter/material.dart';

import '../services/pet_service.dart';

class PetDetailScreen extends StatefulWidget {

  final dynamic pet;

  const PetDetailScreen({
    super.key,
    required this.pet,
  });

  @override
  State<PetDetailScreen> createState() =>
      _PetDetailScreenState();
}

class _PetDetailScreenState
    extends State<PetDetailScreen> {

  late TextEditingController nameController;
  late TextEditingController breedController;
  late TextEditingController ageController;
  late TextEditingController weightController;

  final PetService petService =
  PetService();

  @override
  void initState() {

    super.initState();

    nameController = TextEditingController(
      text: widget.pet['name'],
    );

    breedController = TextEditingController(
      text: widget.pet['breed'],
    );

    ageController = TextEditingController(
      text: widget.pet['age'],
    );

    weightController = TextEditingController(
      text: widget.pet['weight'],
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Editar Mascota'),

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

              keyboardType: TextInputType.number,

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

                  await petService.updatePet(

                    petId: widget.pet.id,

                    name:
                    nameController.text.trim(),

                    breed:
                    breedController.text.trim(),

                    age:
                    ageController.text.trim(),

                    weight:
                    weightController.text.trim(),
                  );

                  ScaffoldMessenger.of(context)
                      .showSnackBar(

                    const SnackBar(

                      content: Text(
                        'Mascota actualizada',
                      ),
                    ),
                  );

                  Navigator.pop(context);
                },

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.teal,

                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),

                child: const Text(

                  'Guardar Cambios',

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