import 'package:flutter/material.dart';

import '../services/payment_service.dart';

// ignore_for_file: deprecated_member_use
// ignore_for_file: library_private_types_in_public_api
class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String _selectedAmount = "500";
  bool _isCustomAmount = false;
  final TextEditingController _customAmountController = TextEditingController();
  int _currentStep = 0;
  String? _selectedPaymentMethod;

  /// payment service
  late PaymentService _paymentService;
  bool _isProcessing = false;
  String _paymentStatus = '';
  String _transactionId = '';

  /// card payment field
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final List<String> _amounts = ["100", "300", "500", "1000", "2000", "5000"];

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(onPaymentUpdate: _handlePaymentUpdate);
  }

  void _handlePaymentUpdate(String status, String message) {
    setState(() {
      _paymentStatus = message;
      _isProcessing = status == 'processing';

      if (status == 'success') {
        _currentStep = 2;

        /// Success screen
      } else if (status == 'error') {
        _showErrorDialog(message);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sadaqah & Donation"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => setState(() => _currentStep = 0),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/islamic_pattern.png'),
                repeat: ImageRepeat.repeat,
                opacity: 0.05,
              ),
            ),
          ),

          // Main content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  SizedBox(height: 20),
                  _buildStepIndicator(),
                  SizedBox(height: 20),

                  _currentStep == 0
                      ? _buildAmountStep()
                      : _currentStep == 1
                      ? _buildPaymentStep()
                      : _buildSuccessStep(),
                ],
              ),
            ),
          ),

          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text(_paymentStatus),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.volunteer_activism, color: Colors.white, size: 50),
            Text(
              "Give Sadaqah",
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            Text(
              "Your donation is a blessing",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(1, "Amount", _currentStep >= 0),
        Expanded(
          child: Divider(color: _currentStep >= 1 ? Colors.green : Colors.grey),
        ),
        _buildStep(2, "Payment", _currentStep >= 1),
        Expanded(
          child: Divider(color: _currentStep >= 2 ? Colors.green : Colors.grey),
        ),
        _buildStep(3, "Success", _currentStep >= 2),
      ],
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.green : Colors.grey.shade300,
          ),
          child: Center(
            child: Text(step.toString(), style: TextStyle(color: Colors.white)),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountStep() {
    return Column(
      children: [
        Text(
          "Select Amount",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
          ),
          itemCount: _amounts.length,
          itemBuilder: (context, index) {
            final amount = _amounts[index];
            return InkWell(
              onTap: () => setState(() {
                _selectedAmount = amount;
                _isCustomAmount = false;
              }),
              child: Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedAmount == amount && !_isCustomAmount
                      ? Colors.green
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text("৳$amount")),
              ),
            );
          },
        ),
        SizedBox(height: 20),
        _buildCustomAmountField(),
        SizedBox(height: 25),
        Text(
          "Payment Method",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 15),
        _buildPaymentMethodCard(
          icon: Icons.account_balance,
          title: "Payoneer",
          color: Colors.blue,
          method: 'payoneer',
        ),
        _buildPaymentMethodCard(
          icon: Icons.credit_card,
          title: "Visa/Mastercard",
          color: Colors.purple,
          method: 'card',
        ),
        SizedBox(height: 30),
        _buildContinueButton(),
      ],
    );
  }

  Widget _buildCustomAmountField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _isCustomAmount ? Colors.green : Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            color: _isCustomAmount ? Colors.green : Colors.grey.shade300,
            child: IconButton(
              icon: Icon(
                Icons.edit,
                color: _isCustomAmount ? Colors.white : Colors.black,
              ),
              onPressed: () => setState(() {
                _isCustomAmount = true;
                _selectedAmount = '';
              }),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _customAmountController,
              enabled: _isCustomAmount,
              decoration: InputDecoration(
                hintText: "Other amount",
                prefixText: "৳ ",
                border: InputBorder.none,
              ),
              onChanged: (value) => _selectedAmount = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required Color color,
    required String method,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Radio<String>(
          value: method,
          groupValue: _selectedPaymentMethod,
          onChanged: (value) => setState(() => _selectedPaymentMethod = value),
        ),
        onTap: () => setState(() => _selectedPaymentMethod = method),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedAmount.isNotEmpty && _selectedPaymentMethod != null
            ? () => setState(() => _currentStep = 1)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text("Continue to Payment"),
      ),
    );
  }

  Widget _buildPaymentStep() {
    if (_selectedPaymentMethod == 'payoneer') {
      return _buildPayoneerForm();
    } else {
      return _buildCardForm();
    }
  }

  Widget _buildPayoneerForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.account_balance, size: 60, color: Colors.blue),
            Text(
              "Payoneer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Amount: ৳$_selectedAmount", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            _buildPaymentActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCardForm() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.credit_card, size: 60, color: Colors.purple),
            Text(
              "Card Payment",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: "Card Number",
                hintText: "1234 5678 9012 3456",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cardHolderController,
              decoration: InputDecoration(
                labelText: "Card Holder Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    decoration: InputDecoration(
                      labelText: "Expiry (MM/YY)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: "CVV",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Amount: ৳$_selectedAmount", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            _buildPaymentActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: Text("Back"),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _processRealPayment,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text("Pay ৳$_selectedAmount"),
          ),
        ),
      ],
    );
  }

  Future<void> _processRealPayment() async {
    setState(() => _isProcessing = true);

    try {
      final orderId = 'DON-${DateTime.now().millisecondsSinceEpoch}';

      if (_selectedPaymentMethod == 'payoneer') {
        // Payoneer payment
        final result = await _paymentService.processPayoneerPayment(
          amount: double.parse(_selectedAmount),
          currency: 'BDT',
          orderId: orderId,
          customerEmail: 'donor@example.com',
          customerName: 'Donor',
        );

        if (result['success'] && result['paymentUrl'] != null) {
          // Payoneer payment page open
          // WebView or  browser open
        }
      } else {
        /// Card payment
        final expiry = _expiryController.text.split('/');
        final result = await _paymentService.processCardPayment(
          amount: double.parse(_selectedAmount),
          currency: 'BDT',
          cardNumber: _cardNumberController.text.replaceAll(' ', ''),
          cardHolder: _cardHolderController.text,
          expiryMonth: expiry[0],
          expiryYear: '20${expiry[1]}',
          cvv: _cvvController.text,
          orderId: orderId,
          customerEmail: 'donor@example.com',
        );

        if (result['success']) {
          _transactionId = result['transactionId'];
          setState(() => _currentStep = 2);
        }
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildSuccessStep() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            Text("Jazakallah Khairan!", style: TextStyle(fontSize: 24)),
            Text("Your donation has been received"),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(15),
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  Text("Amount: ৳$_selectedAmount"),
                  Text("Transaction: $_transactionId"),
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
