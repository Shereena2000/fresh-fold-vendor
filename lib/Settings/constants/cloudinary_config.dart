import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudinary Configuration
/// 
/// For mobile: Credentials are stored in .env file for security
/// For web: Hardcoded values (upload preset must be unsigned)
/// Make sure to add your CLOUDINARY_CLOUD_NAME in .env file for mobile

class CloudinaryConfig {
  // Web configuration (hardcoded for web platform)
  static const String _webCloudName = 'dvcodgbkd'; // Your Cloudinary cloud name
  static const String _webUploadPreset = 'fresh-fold';
  
  // Load from environment variables for mobile, or use web values for web
  static String get cloudName {
    if (kIsWeb) {
      return _webCloudName;
    }
    return dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'YOUR_CLOUD_NAME';
  }
  
  static String get apiKey {
    if (kIsWeb) {
      return ''; // Not needed for unsigned upload preset
    }
    return dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  }
  
  static String get apiSecret {
    if (kIsWeb) {
      return ''; // Not needed for unsigned upload preset
    }
    return dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  }
  
  static String get uploadPreset {
    if (kIsWeb) {
      return _webUploadPreset;
    }
    return dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'fresh-fold';
  }
  
  // Upload URL
  static String get uploadUrl => 
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Folder structure
  static const String promoFolder = 'fresh_fold/promos';
  
  // Check if configuration is valid
  static bool get isConfigured => 
      cloudName != 'YOUR_CLOUD_NAME' && cloudName.isNotEmpty;
}

