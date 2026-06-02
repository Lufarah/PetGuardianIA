import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PetService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addPet({
    required String name,
    required String breed,
    required String age,
    required String weight,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    await _firestore.collection('pets').add({

      'userId': user!.uid,
      'name': name,
      'breed': breed,
      'age': age,
      'weight': weight,
      'createdAt': Timestamp.now(),
    });
  }
  Future<void> deletePet(String id) async {

    await _firestore
        .collection('pets')
        .doc(id)
        .delete();
  }
  Future<void> updatePet({

    required String petId,

    required String name,

    required String breed,

    required String age,

    required String weight,

  }) async {

    await _firestore
        .collection('pets')
        .doc(petId)
        .update({

      'name': name,

      'breed': breed,

      'age': age,

      'weight': weight,
    });
  }
}