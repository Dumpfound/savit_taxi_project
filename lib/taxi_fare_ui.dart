import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaxiFareUi extends StatefulWidget {
  const TaxiFareUi({super.key});

  @override
  State<TaxiFareUi> createState() => _TaxiFareUiState();
}

class _TaxiFareUiState extends State<TaxiFareUi> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _waitingController = TextEditingController();

  double _fare = 0.0;
  String? _errorMessage;
  bool _hasCalculated = false;

  @override
  void dispose() {
    _distanceController.dispose();
    _waitingController.dispose();
    super.dispose();
  }

  /// Calculate taxi fare based on official Bangkok rates (small sedan - 35 baht first km)
  double _calculateFare(double distanceKm, double waitingMinutes) {
    if (distanceKm <= 0) return 0;

    double fare = 0;

    // First kilometer
    if (distanceKm >= 1) {
      fare += 35.0;
    } else {
      // Less than 1 km still charged as first km
      fare += 35.0;
      return fare + (waitingMinutes * 3.0);
    }

    double remaining = distanceKm - 1;

    // 1+ to 10 km : 6.50 baht/km  (up to 9 km)
    if (remaining > 0) {
      double segment = remaining > 9 ? 9 : remaining;
      fare += segment * 6.50;
      remaining -= segment;
    }

    // 10+ to 20 km : 7.00 baht/km (10 km)
    if (remaining > 0) {
      double segment = remaining > 10 ? 10 : remaining;
      fare += segment * 7.00;
      remaining -= segment;
    }

    // 20+ to 40 km : 8.00 baht/km (20 km)
    if (remaining > 0) {
      double segment = remaining > 20 ? 20 : remaining;
      fare += segment * 8.00;
      remaining -= segment;
    }

    // 40+ to 60 km : 8.50 baht/km (20 km)
    if (remaining > 0) {
      double segment = remaining > 20 ? 20 : remaining;
      fare += segment * 8.50;
      remaining -= segment;
    }

    // 60+ to 80 km : 9.00 baht/km (20 km)
    if (remaining > 0) {
      double segment = remaining > 20 ? 20 : remaining;
      fare += segment * 9.00;
      remaining -= segment;
    }

    // Over 80 km : 10.50 baht/km
    if (remaining > 0) {
      fare += remaining * 10.50;
    }

    // Waiting / traffic jam : 3.00 baht per minute
    fare += waitingMinutes * 3.0;

    return fare;
  }

  void _onCalculate() {
    final distanceText = _distanceController.text.trim();
    final waitingText = _waitingController.text.trim();

    if (distanceText.isEmpty || waitingText.isEmpty) {
      setState(() {
        _errorMessage = 'กรุณากรอกข้อมูลให้ครบถ้วน';
        _fare = 0.0;
        _hasCalculated = false;
      });
      return;
    }

    final distance = double.tryParse(distanceText);
    final waiting = double.tryParse(waitingText);

    if (distance == null || waiting == null || distance < 0 || waiting < 0) {
      setState(() {
        _errorMessage = 'กรุณากรอกตัวเลขที่ถูกต้อง';
        _fare = 0.0;
        _hasCalculated = false;
      });
      return;
    }

    final result = _calculateFare(distance, waiting);

    setState(() {
      _fare = result;
      _errorMessage = null;
      _hasCalculated = true;
    });
  }

  void _onClear() {
    setState(() {
      _distanceController.clear();
      _waitingController.clear();
      _fare = 0.0;
      _errorMessage = null;
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text(
          'Taxi Fare',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFC107),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Taxi Icon
            _buildTaxiIcon(),
            const SizedBox(height: 20),
            // Title
            const Text(
              'คำนวณค่าโดยสารแท็กซี่',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE65100),
              ),
            ),
            const SizedBox(height: 28),

            // Distance input
            _buildInputField(
              label: 'ระยะทาง (กิโลเมตร)',
              icon: Icons.straighten,
              controller: _distanceController,
              hint: 'กรุณากรอกระยะทาง',
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),

            // Waiting time input
            _buildInputField(
              label: 'เวลารถติด (นาที)',
              icon: Icons.access_time,
              controller: _waitingController,
              hint: 'กรุณากรอกเวลารถติด',
              iconColor: Colors.redAccent,
            ),
            const SizedBox(height: 28),

            // Calculate button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onCalculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black87,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'คำนวณค่าโดยสาร',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Clear button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _onClear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ยกเลิก',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFE0B2)),
              ),
              child: Column(
                children: [
                  const Text(
                    'ค่าโดยสารแท็กซี่',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fare.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE65100),
                    ),
                  ),
                  const Text(
                    'บาท',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTaxiIcon() {
    return Container(
      width: 110,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD54F),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Body
          Positioned(
            bottom: 12,
            child: Container(
              width: 85,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          // Roof + TAXI text
          Positioned(
            top: 12,
            child: Container(
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'TAXI',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
          // Windows
          Positioned(
            top: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81D4FA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 16,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF81D4FA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          // Wheels
          Positioned(
            bottom: 6,
            left: 16,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 6,
            right: 16,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    required Color iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
