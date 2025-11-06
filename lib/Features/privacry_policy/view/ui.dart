import 'package:flutter/material.dart';

import '../../../Settings/common/widgets/custom_app_bar.dart';
import '../../../Settings/utils/p_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 900;
    final isTablet = screenWidth > 600 && screenWidth <= 900;
    final horizontalPadding = isWeb ? 48.0 : (isTablet ? 32.0 : 16.0);
    
    return Scaffold(
      backgroundColor: PColors.scaffoldColor,
      appBar: CustomAppBar(title: 'Privacy Policy'),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 900 : double.infinity,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: isWeb ? 32.0 : 16.0,
            ),
            child: Container(
              padding: EdgeInsets.all(isWeb ? 40 : (isTablet ? 24 : 16)),
              decoration: isWeb || isTablet
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(isWeb),
                  SizedBox(height: isWeb ? 32 : 20),
                  _buildPrivacyPolicyContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isWeb) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIVACY POLICY FOR FRESH FOLD VENDOR',
            style: TextStyle(
              fontSize: isWeb ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: PColors.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last Updated: October 2025',
            style: TextStyle(
              fontSize: isWeb ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: PColors.secondoryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fresh Fold Vendor ("we," "our," or "us") is committed to protecting the privacy of our service providers (vendors). This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our vendor mobile application for laundry service management.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 1
        SectionTitle(title: '1. INFORMATION WE COLLECT'),
        SubSectionTitle(title: '1.1 Vendor Account Information'),
        Text(
          '• Full name (collected during signup)\n'
          '• Email address\n'
          '• Account credentials (email and password)\n',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 16),
        SubSectionTitle(title: '1.2 Service Management Information'),
        Text(
          '• Assigned laundry orders and client details\n'
          '• Order processing status and updates\n'
          '• Service completion records\n'
          '• Payment amounts set for services\n'
          '• Cash on Delivery (COD) confirmation records\n'
          '• Order cancellation records\n'
          '• Service scheduling information',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 16),
        SubSectionTitle(title: '1.3 Promotional Content'),
        Text(
          '• Images uploaded for promotional purposes\n'
          '• Promo creation dates and status\n'
          'Note: Promo images are stored securely on Cloudinary servers',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        
    
        SizedBox(height: 16),
        SubSectionTitle(title: '1.5 Firebase Services Data'),
        Text(
          'We use Firebase services which may collect:\n'
          '• Authentication data and session tokens\n'
          '• Cloud Firestore database information\n'
          '• App performance and crash analytics\n'
          '• User preferences and settings',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 2
        SectionTitle(title: '2. HOW WE USE YOUR INFORMATION'),
        Text(
          'We use collected information to:\n'
          '• Create and manage your vendor account\n'
          '• Authenticate login using email and password\n'
          '• Assign and manage laundry orders\n'
          '• Process order status updates\n'
          '• Set and record payment amounts for services\n'
          '• Confirm Cash on Delivery (COD) payments\n'
          '• Manage promotional content and images\n'
          '• Provide order history and performance analytics\n'
          '• Send order notifications and updates\n'
          '• Improve app functionality and user experience\n'
          '• Ensure app security and prevent unauthorized access\n'
          '• Provide customer support to vendors',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 3
        SectionTitle(title: '3. IMAGE UPLOAD AND STORAGE'),
        SubSectionTitle(title: '3.1 Image Picker Usage'),
        Text(
          '• The app uses image_picker to select promo images from your device\n'
          '• You can choose images from gallery or camera\n'
          '• We require camera and storage permissions for this functionality\n'
          '• Images are compressed before upload to optimize performance',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 16),
        SubSectionTitle(title: '3.2 Cloudinary Storage'),
        Text(
          '• All promotional images are stored on Cloudinary servers\n'
          '• Images are transmitted securely via HTTPS\n'
          '• Cloudinary provides secure cloud-based image management\n'
          '• We do not store promo images on our own servers\n'
          '• Image URLs are stored in our database for app display',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 16),
        SubSectionTitle(title: '3.3 Image Usage'),
        Text(
          'Uploaded promo images are used to:\n'
          '• Display promotions in the client app\n'
          '• Market your laundry services\n'
          '• Attract new customers\n'
          '• Showcase special offers and discounts',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 4
        SectionTitle(title: '4. ORDER MANAGEMENT DATA'),
        SubSectionTitle(title: '4.1 Client Information Access'),
        Text(
          'As a vendor, you have access to:\n'
          '• Client names and contact information for assigned orders\n'
          '• Pickup and delivery addresses\n'
          '• Service preferences and special instructions\n'
          '• Order scheduling information\n'
          '• Client order history relevant to your services',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 16),
        SubSectionTitle(title: '4.2 Payment Processing'),
        Text(
          '• You set payment amounts based on services rendered\n'
          '• All payments are Cash on Delivery (COD)\n'
          '• You record payment confirmation in the app\n'
          '• We maintain records of payment amounts and status\n'
          '• No financial or banking information is stored',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 5
        SectionTitle(title: '5. DATA SHARING AND DISCLOSURE'),
        SubSectionTitle(title: '5.1 We DO NOT sell your personal information.'),
        SizedBox(height: 8),
        SubSectionTitle(title: '5.2 We share information with:'),
        Text(
          '• Clients: Your name and contact information for order coordination\n'
          '• Technology Providers: Firebase for authentication, Cloudinary for image storage\n'
          '• Legal Authorities: When required by law or to protect rights and safety\n\n'
          'Client data is shared only to the extent necessary for service fulfillment',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 6
        SectionTitle(title: '6. THIRD-PARTY SERVICES'),
        Text(
          'Our app uses the following third-party services:\n\n'
          'Firebase (Google)\n'
          '• Authentication and user management\n'
          '• Cloud Firestore for data storage\n'
          '• Subject to Firebase Privacy Policy\n\n'
          'Cloudinary\n'
          '• Image storage and management\n'
          'Image Picker\n'
          '• Device image selection functionality\n'
          '• Camera and gallery access\n\n'
          'We recommend reviewing the privacy policies of these third-party services.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 7
        SectionTitle(title: '7. DATA SECURITY'),
        Text(
          'We implement industry-standard security measures:\n'
          '• Encrypted data transmission (HTTPS/TLS)\n'
          '• Secure Firebase authentication\n'
          '• Protected cloud storage via Cloud Firestore\n'
          '• Secure image storage on Cloudinary\n'
          '• Regular security updates and monitoring\n'
          '• Access controls and authentication requirements\n'
          '• Secure API key management\n\n'
          'Vendor accounts are protected with email-based authentication.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 8
        SectionTitle(title: '8. DATA RETENTION'),
        Text(
          '• Active vendor accounts: Retained while account is active\n'
          '• Order records: Maintained for business operations and analytics\n'
          '• Promotional images: Stored until deleted by vendor or account closure\n'
          '• Payment records: Retained for accounting and business purposes\n'
          '• Business records may be retained longer as required by applicable laws',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 9
        SectionTitle(title: '9. VENDOR RIGHTS AND CONTROLS'),
        Text(
          'You have the right to:\n'
          '• Access your personal data stored in our system\n'
          '• Correct inaccurate profile information\n'
          '• Delete your vendor account and associated data\n'
          '• View your complete order history and performance data\n'
          '• Upload, edit, and remove promotional images\n'
          '• Manage notification preferences\n'
          '• Request information about data sharing practices\n\n'
          'To exercise these rights, contact us at freshfold.growblic@gmail.com',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 10
        SectionTitle(title: '10. ANDROID PERMISSIONS REQUIRED'),
        Text(
          'The vendor app requires the following Android permissions:\n\n'
          '• INTERNET: For app functionality and cloud services\n'
          '• CAMERA: To capture images for promotional content\n'
          '• READ_EXTERNAL_STORAGE: To select images from device gallery\n'
          '• WRITE_EXTERNAL_STORAGE: To save images (limited to SDK 29 and below)\n\n'
          'You can manage these permissions in your device settings. Camera and storage permissions are only used for promotional image uploads.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 11
        SectionTitle(title: '11. AUTHENTICATION AND ACCOUNT SECURITY'),
        Text(
          '• Login requires valid email and password authentication\n'
          '• Account creation requires your full name for identification\n'
          '• You are responsible for maintaining account confidentiality\n'
          '• Notify us immediately of any unauthorized account access\n'
          '• We implement session management and secure authentication flows',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 12
        SectionTitle(title: '12. CHANGES TO THIS POLICY'),
        Text(
          'We may update this Privacy Policy to reflect changes in our practices. Significant changes will be communicated through:\n'
          '• In-app notifications\n'
          '• Email notifications to registered vendors\n'
          '• Updated "Last Updated" date\n\n'
          'Continued use of the app after changes constitutes acceptance of the updated policy.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 13
        SectionTitle(title: '13. VENDOR RESPONSIBILITIES'),
        Text(
          'As a vendor, you agree to:\n'
          '• Protect client information accessed through the app\n'
          '• Use client data only for order fulfillment purposes\n'
          '• Maintain confidentiality of order details\n'
          '• Securely handle cash payments and records\n'
          '• Upload only appropriate promotional content\n'
          '• Report any data security concerns immediately',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 14
        SectionTitle(title: '14. CONTACT US'),
        Text(
          'For privacy concerns, questions, or to exercise your rights:\n\n'
          'Fresh Fold Vendor Support\n'
          'Email: freshfold.growblic@gmail.com\n\n'
          'We will respond to vendor inquiries within a reasonable timeframe.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 24),

        // Section 15
        SectionTitle(title: '15. YOUR CONSENT'),
        Text(
          'By creating a vendor account and using Fresh Fold Vendor app, you acknowledge that you have read and understood this Privacy Policy and agree to its terms. If you do not agree with this policy, please do not use our app.\n\n'
          'For any questions or concerns:\n'
          'Email: freshfold.growblic@gmail.com',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        SizedBox(height: 40),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: PColors.primaryColor,
        ),
      ),
    );
    
  }
}

class SubSectionTitle extends StatelessWidget {
  final String title;

  const SubSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: PColors.black,
        ),
      ),
    );
  }
}