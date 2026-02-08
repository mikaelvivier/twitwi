import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../services_firebase/service_firestore.dart';

class CreatePostDialog extends StatefulWidget {
  const CreatePostDialog({super.key});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _textController = TextEditingController();
  final ServiceFirestore _firestoreService = ServiceFirestore();
  bool _isPosting = false;
  Uint8List? _imageBytes;
  String? _imageName;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _compressImage(Uint8List imageBytes) async {
    try {
      // Décoder l'image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Redimensionner si trop grande (max 1200px de largeur)
      if (image.width > 1200) {
        image = img.copyResize(image, width: 1200);
      }

      // Compresser en JPEG avec qualité 85
      final compressed = img.encodeJpg(image, quality: 85);
      
      // Afficher la réduction de taille
      final originalSize = imageBytes.length / 1024 / 1024;
      final compressedSize = compressed.length / 1024 / 1024;
      print('Image originale: ${originalSize.toStringAsFixed(2)} MB');
      print('Image compressée: ${compressedSize.toStringAsFixed(2)} MB');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      print('Erreur de compression: $e');
      return imageBytes;
    }
  }

  Future<void> _pickImage() async {
    try {
      setState(() {
        _uploadStatus = 'Sélection de l\'image...';
      });

      final pickedImage = await ImagePickerWeb.getImageAsBytes();
      if (pickedImage != null) {
        setState(() {
          _uploadStatus = 'Compression de l\'image...';
        });

        // Compresser l'image
        final compressed = await _compressImage(pickedImage);
        
        setState(() {
          _imageBytes = compressed ?? pickedImage;
          _imageName = 'post_${DateTime.now().millisecondsSinceEpoch}.jpg';
          _uploadStatus = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection : $e')),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null || _imageName == null) return null;

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return null;

      setState(() {
        _uploadStatus = 'Upload en cours...';
        _uploadProgress = 0.0;
      });

      final ref = FirebaseStorage.instance
          .ref()
          .child('posts')
          .child(userId)
          .child(_imageName!);

      final uploadTask = ref.putData(_imageBytes!);
      
      // Écouter la progression
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
            _uploadStatus = 'Upload: ${(_uploadProgress * 100).toStringAsFixed(0)}%';
          });
        }
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      setState(() {
        _uploadStatus = '';
        _uploadProgress = 0.0;
      });
      
      return url;
    } catch (e) {
      if (mounted) {
        setState(() {
          _uploadStatus = '';
          _uploadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'upload : $e')),
        );
      }
      return null;
    }
  }

  Future<void> _publishPost() async {
    if (_textController.text.trim().isEmpty && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez du texte ou une image')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        String? imageUrl;
        if (_imageBytes != null) {
          imageUrl = await _uploadImage();
        }

        await _firestoreService.addPost(
          memberId: userId,
          text: _textController.text.trim(),
          image: imageUrl ?? '',
        );

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post publié avec succès !')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Text(
                  'Créer un post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isPosting ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Quoi de neuf ?',
                border: OutlineInputBorder(),
              ),
              enabled: !_isPosting,
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 16),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: _isPosting
                          ? null
                          : () {
                              setState(() {
                                _imageBytes = null;
                                _imageName = null;
                              });
                            },
                    ),
                  ),
                ],
              ),
            ],
            if (_uploadStatus.isNotEmpty) ...[
              const SizedBox(height: 12),
              Column(
                children: [
                  if (_uploadProgress > 0) ...[
                    LinearProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    _uploadStatus,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Ajouter une image'),
                  onPressed: _isPosting ? null : _pickImage,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _isPosting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isPosting ? null : _publishPost,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Publier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
