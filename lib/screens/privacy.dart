import 'package:flutter/material.dart';

class MePolicy extends StatefulWidget {
  const MePolicy({Key? key}) : super(key: key);

  @override
  _MePolicyState createState() => _MePolicyState();
}

class _MePolicyState extends State<MePolicy> {
  String selectedContent = 'Terms and Conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        leading: IconButton(
          style: const ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.black)),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
        ),
        centerTitle: true,
        title: const Text(
          'Privacy and Policy',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 8),
                itemCount: 2,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedContent = index == 0
                            ? 'Terms and Conditions'
                            : 'Cancellation and Refund';
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: selectedContent ==
                                (index == 0
                                    ? 'Terms and Conditions'
                                    : 'Cancellation and Refund')
                            ? Colors.black
                            : Colors.black87,
                      ),
                      child: ListTile(
                        title: Text(
                          index == 0
                              ? 'Terms and Conditions'
                              : 'Cancellation and Refund',
                          style: TextStyle(
                            color: selectedContent ==
                                    (index == 0
                                        ? 'Terms and Conditions'
                                        : 'Cancellation and Refund')
                                ? Colors.white
                                : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  child: selectedContent == 'Terms and Conditions'
                      ? PrivacyContent()
                      : PolicyContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10), color: Colors.black),
      child: const SingleChildScrollView(
        child: Text(
          'Last updated on Feb 29 2024\n'
          'For the purpose of these Terms and Conditions, "we", "us", "our" refer to MESME ONLINE PRIVATE LIMITED, located at 1,120 Tavarekere Hobli Kethohalli/Chunchanakuppe Post Bengaluru KARNATAKA 562130. "You", "your", "user", and "visitor" refer to any natural or legal person visiting our website and/or agreeing to purchase from us.\n'
          'Your use of the website and/or purchase from us is governed by the following Terms and Conditions:\n'
          'The content of the pages of this website is subject to change without notice.\n'
          'We do not provide any warranty or guarantee as to the accuracy, timeliness, performance, completeness, or suitability of the information and materials found or offered on this website.\n'
          'Your use of any information or materials on our website and/or product pages is entirely at your own risk.\n'
          'Our website contains material owned by or licensed to us, and reproduction is prohibited without our prior consent.\n'
          'All trademarks not owned by us are acknowledged on the website.\n'
          'Unauthorized use of information provided by us may result in a claim for damages or be a criminal offense.\n'
          'Links to other websites may be provided for your convenience, but we do not endorse those websites.\n'
          'You may not create a link to our website without our prior written consent.\n'
          'Any dispute arising from the use of our website, purchase, or engagement with us is subject to Indian laws.\n'
          'We are not liable for any loss or damage arising directly or indirectly from the decline of authorization for any transaction.\n',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class PolicyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black,
      ),
      child: const SingleChildScrollView(
        child: Text(
          'Last updated on Feb 29 2024\n'
          'MESME ONLINE PRIVATE LIMITED believes in helping its customers as far as possible and has therefore a liberal cancellation policy. Under this policy:\n'
          'Cancellations will be considered only if the request is made within the same day of placing the order. However, the cancellation request may not be entertained if the orders have been communicated to the vendors/merchants and they have initiated the process of shipping them.\n'
          'MESME ONLINE PRIVATE LIMITED does not accept cancellation requests for perishable items like flowers, eatables etc. However, refund/replacement can be made if the customer establishes that the quality of product delivered is not good.\n'
          'In case of receipt of damaged or defective items please report the same to our Customer Service team. The request will, however, be entertained once the merchant has checked and determined the same at his own end. This should be reported within the same day of receipt of the products.\n'
          'If you feel that the product received is not as shown on the site or as per your expectations, you must bring it to the notice of our customer service within the same day of receiving the product. The Customer Service Team after looking into your complaint will take an appropriate decision.\n'
          'For complaints regarding products that come with a warranty from manufacturers, please refer the issue to them.\n'
          'In case of any refunds approved by MESME ONLINE PRIVATE LIMITED, it will take 1-2 days for the refund to be processed to the end customer.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
