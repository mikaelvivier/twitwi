import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../modeles/post.dart';
import '../modeles/membre.dart';
import '../modeles/app_theme.dart';
import '../services_firebase/service_firestore.dart';
import 'package:intl/intl.dart';
import 'comments_sheet.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final ServiceFirestore _firestoreService = ServiceFirestore();
  Membre? _author;
  bool _isLoading = true;
  int _commentsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
    _loadCommentsCount();
  }

  Future<void> _loadAuthor() async {
    try {
      final authorDoc = await _firestoreService.getMember(widget.post.memberId);
      if (authorDoc.exists) {
        setState(() {
          _author = Membre.fromSnapshot(authorDoc);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCommentsCount() async {
    try {
      final count = await _firestoreService.getCommentsCount(widget.post.id);
      if (mounted) {
        setState(() {
          _commentsCount = count;
        });
      }
    } catch (e) {
      // Ignorer l'erreur
    }
  }

  void _toggleLike() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _firestoreService.toggleLike(postId: widget.post.id, userId: userId);
    }
  }

  void _showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsSheet(postId: widget.post.id),
    ).then((_) {
      // Recharger le compteur après fermeture
      _loadCommentsCount();
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(date);
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = userId != null && widget.post.isLikedBy(userId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec auteur et date
            Row(
              children: [
                // Avatar avec gradient border
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppTheme.primaryStart.withOpacity(0.2),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _author?.surname.isNotEmpty == true
                                  ? _author!.surname[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: AppTheme.primaryStart,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _author?.fullName ?? 'Chargement...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(widget.post.date.toDate()),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Contenu du post
            Text(
              widget.post.text,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (widget.post.image.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[200]!,
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Statistiques (likes et commentaires)
            if (widget.post.likesCount > 0 || _commentsCount > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (widget.post.likesCount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.accentGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.post.likesCount}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (_commentsCount > 0)
                      Text(
                        '$_commentsCount commentaire${_commentsCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            Divider(color: Colors.grey[300]),
            // Barre d'actions (likes et commentaires)
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? AppTheme.accentStart : Colors.grey[700],
                      size: 22,
                    ),
                    label: Text(
                      'J\'aime',
                      style: TextStyle(
                        color: isLiked ? AppTheme.accentStart : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: _toggleLike,
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    icon: Icon(
                      Icons.comment_outlined,
                      color: Colors.grey[700],
                      size: 22,
                    ),
                    label: Text(
                      'Commenter',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: _showComments,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
