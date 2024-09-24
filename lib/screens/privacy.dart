import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class MePolicy extends StatelessWidget {
  @override
  // Function to launch email
  void _launchEmail(String email) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch $email';
    }
  }

  // Function to launch phone call
  void _launchPhone(String phoneNumber) async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.orange)),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to “MESME online Food and Grocery delivery”',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'These Terms and Conditions (“Terms”) govern your use of the MESME application (“App”). By accessing or using the MESME app, you agree to comply with and be bound by these terms and conditions. If you do not agree, then do not use the MESME app.',
            ),
            const SizedBox(height: 16),
            _sectionTitle('I. Account Registration:'),
            _bulletPoint(
                'You must be at least 18 years old to create an account and use the MESME app.'),
            _bulletPoint(
                'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account.'),
            const SizedBox(height: 16),
            _sectionTitle('II. Order and Delivery:'),
            _bulletPoint(
                'By placing an order through the MESME app, you agree to purchase the items selected.'),
            _bulletPoint(
                'Delivery times provided are estimates and not guaranteed, delays may occur due to traffic, weather, or other factors.'),
            _bulletPoint(
                'You are responsible for providing accurate delivery instructions and ensuring someone is available to receive the order.'),
            const SizedBox(height: 16),
            _sectionTitle('III. Pricing and Payments:'),
            _bulletPoint(
                'Prices for menu items and delivery fees are displayed in the app and are subject to change without notice.'),
            _bulletPoint(
                'Payment must be made at the time of ordering. MESME accepts various payment methods, including credit/debit cards, mobile wallets, and cash on delivery.'),
            _bulletPoint(
                'All transactions are processed securely. MESME does not store your payment information.'),
            const SizedBox(height: 16),
            _sectionTitle('IV. Cancellation and Refunds:'),
            _bulletPoint(
                'Orders can be cancelled within a specified time frame before the scheduled delivery time. Refer to our cancellation policy for more details.'),
            _bulletPoint(
                'Refunds will be issued in accordance with our refund policy. Refund amounts will be credited within 3 working days.'),
            const SizedBox(height: 16),
            _sectionTitle('V. User Responsibilities:'),
            _bulletPoint(
                'You agree not to use the MESME app for any unlawful or unauthorized purpose.'),
            _bulletPoint(
                'You are responsible for providing accurate and up-to-date information, including your contact details and delivery address.'),
            const SizedBox(height: 16),
            _sectionTitle('VI. Intellectual Property:'),
            _bulletPoint(
                'All content, logos, and graphics in the app are the property of MESME or its licensors and are protected by copyright, trademark, and other intellectual property laws.'),
            _bulletPoint(
                'You may not reproduce, distribute, or use any content from the MESME app without permission.'),
            const SizedBox(height: 16),
            _sectionTitle('VII. Limitation of Liability:'),
            _bulletPoint(
                'MESME shall not be liable for any indirect, incidental, special, or consequential damages arising out of or in connection with your use of the app or any products or services ordered through the app.'),
            _bulletPoint(
                'Our total liability for any claims arising out of or related to these terms and conditions shall not exceed the total amount paid by you for the specific orders giving rise to the claim.'),
            const SizedBox(height: 16),
            _sectionTitle('VIII. Changes to Terms:'),
            _bulletPoint(
                'MESME reserves the right to modify or update these terms at any time without prior notice. Changes will be posted in the app with a revised “Last Updated” date.'),
            _bulletPoint(
                'Your continued use of the app after the posting of revised terms and conditions constitutes your acceptance of the changes.'),
            const SizedBox(height: 16),
            _sectionTitle('IX. Termination:'),
            _bulletPoint(
                'MESME may terminate or suspend your account and access to the app without prior notice for violations of these terms and conditions or for any other reasons.'),
            _bulletPoint(
                'Upon termination, your right to use the app will cease immediately.'),
            const SizedBox(height: 16),
            _sectionTitle('X. Governing Law:'),
            _bulletPoint(
                'These terms and conditions shall be governed by and construed in accordance with the laws of (“Jurisdiction”) without regard to its conflict of law principles.'),
            const SizedBox(height: 16),
            _sectionTitle('Contact Us:'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'If you have any questions or concerns about these terms and conditions, please contact us at:\n\n'
                    'MESME ONLINE PRIVATE LIMITED\n'),
                // Other sections here...

                GestureDetector(
                  onTap: () => _launchEmail('mesmegroup@gmail.com'),
                  child: Row(
                    children: [
                      Icon(Icons.email_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'mesmegroup@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                GestureDetector(
                  onTap: () => _launchEmail('mesmeinfo@gmail.com'),
                  child: Row(
                    children: [
                      Icon(Icons.email_rounded, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'mesmeinfo@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchPhone('+918680888124'),
                  child: Row(
                    children: [
                      Icon(Icons.phone_android_rounded,
                          color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Phone: +91 8680888124',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchPhone('+918660629972'),
                  child: Row(
                    children: [
                      Icon(Icons.phone_android_rounded,
                          color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Phone: +91 8660629972',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Thank you for choosing MESME. We hope you enjoy using our Food and Grocery delivery app.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to display section titles
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.orange.shade700,
      ),
    );
  }

  // Helper function to display bullet points
  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
