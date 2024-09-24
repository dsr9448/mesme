import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mesme/screens/message.dart';

import 'package:url_launcher/url_launcher.dart';

class MeCustomer extends StatelessWidget {
  const MeCustomer({Key? key, this.food}) : super(key: key);
  final food;
  Future<void> _callNumber(BuildContext context, String number) async {
    final Uri phoneUri = Uri.parse('tel:$number');
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch ${phoneUri.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
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
          'Customer Support',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MeMessage()),
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Icon(
                Icons.message_rounded,
                color: Colors.orange.shade700,
              ),
              title: const Text(
                'Chat Support',
                style: TextStyle(color: Colors.black),
              ),
              titleAlignment: ListTileTitleAlignment.center,
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange.shade700,
              ),
            ),
            ListTile(
              onTap: () {
                showModalBottomSheet(
                  backgroundColor: Colors.orange.shade700,
                  context: context,
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.phone,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await _callNumber(context, '+918680888124');
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          title: const Text(
                            '+918680888124',
                            style: TextStyle(color: Colors.white),
                          ),
                          titleAlignment: ListTileTitleAlignment.center,
                        ),
                        ListTile(
                          leading: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.phone,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await _callNumber(context, '+918660629972');
                            Navigator.pop(context);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          title: const Text(
                            '+918660629972',
                            style: TextStyle(color: Colors.white),
                          ),
                          titleAlignment: ListTileTitleAlignment.center,
                        ),
                      ],
                    );
                  },
                );
              },
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              leading: Icon(
                Icons.call,
                color: Colors.orange.shade700,
              ),
              title: const Text(
                'Call Support',
                style: TextStyle(color: Colors.black),
              ),
              titleAlignment: ListTileTitleAlignment.center,
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
