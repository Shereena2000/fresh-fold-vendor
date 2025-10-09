import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Settings/utils/p_colors.dart';
import '../../auth/view_model.dart/auth_view_model.dart';
import '../model/promo_model.dart';
import '../view_model/promo_view_model.dart';

class PromoManagementScreen extends StatefulWidget {
  const PromoManagementScreen({super.key});

  @override
  State<PromoManagementScreen> createState() => _PromoManagementScreenState();
}

class _PromoManagementScreenState extends State<PromoManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PromoViewModel>().loadPromos();
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Upload Promo Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: PColors.primaryColor,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.photo_library, color: PColors.primaryColor),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(fromCamera: false);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: PColors.primaryColor),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadImage(fromCamera: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage({required bool fromCamera}) async {
    final promoViewModel = context.read<PromoViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    
    final vendorUid = authViewModel.getCurrentUser()?.uid;
    if (vendorUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please login first'),
          backgroundColor: PColors.errorRed,
        ),
      );
      return;
    }

    // Pick image
    File? imageFile;
    if (fromCamera) {
      imageFile = await promoViewModel.pickImageFromCamera();
    } else {
      imageFile = await promoViewModel.pickImageFromGallery();
    }

    if (imageFile == null) return;

    // Show preview and confirm
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upload Promo?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                imageFile!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'This image will be uploaded to Cloudinary and visible to all customers.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
            ),
            child: Text('Upload'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Upload
    final success = await promoViewModel.uploadPromo(imageFile, vendorUid);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo uploaded successfully!'),
          backgroundColor: PColors.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(promoViewModel.errorMessage ?? 'Upload failed'),
          backgroundColor: PColors.errorRed,
        ),
      );
    }
  }

  void _showDeleteDialog(PromoModel promo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Promo'),
        content: Text('Are you sure you want to delete this promo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<PromoViewModel>().deletePromo(promo);
              
              if (!mounted) return;
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Promo deleted'),
                    backgroundColor: PColors.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.errorRed,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      appBar: AppBar(
        title: Text(
          'Manage Promos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: PColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<PromoViewModel>(
        builder: (context, promoViewModel, child) {
          if (promoViewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: PColors.primaryColor),
            );
          }

          return Column(
            children: [
              // Upload Button
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: ElevatedButton.icon(
                  onPressed: promoViewModel.isUploading
                      ? null
                      : _showImageSourceDialog,
                  icon: promoViewModel.isUploading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.add_photo_alternate),
                  label: Text(
                    promoViewModel.isUploading ? 'Uploading...' : 'Upload Promo Image',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Promos Grid
              Expanded(
                child: promoViewModel.promos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: PColors.lightGray,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No promos yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: PColors.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload promo images for customers',
                              style: TextStyle(
                                fontSize: 14,
                                color: PColors.darkGray.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : StreamBuilder<List<PromoModel>>(
                        stream: promoViewModel.streamPromos(),
                        builder: (context, snapshot) {
                          final promos = snapshot.data ?? promoViewModel.promos;

                          return GridView.builder(
                            padding: EdgeInsets.all(16),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: promos.length,
                            itemBuilder: (context, index) {
                              return _buildPromoCard(promos[index]);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromoCard(PromoModel promo) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Promo Image
            Image.network(
              promo.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: PColors.lightGray,
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: PColors.darkGray,
                  ),
                );
              },
            ),

            // Delete Button Overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: () => _showDeleteDialog(promo),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
              ),
            ),

            // Date Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  'Uploaded ${_formatDate(promo.createdAt)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}


