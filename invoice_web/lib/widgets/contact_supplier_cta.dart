import 'dart:ui';
import 'package:flutter/material.dart';

class ContactSupplierCTA extends StatelessWidget {
  final double potentialSavings;

  const ContactSupplierCTA({
    super.key,
    required this.potentialSavings,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background gradient
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400,
                    Colors.purple.shade400,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            
            // Blurred effect
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            
            // Content
            Container(
              height: 200,
              padding: const EdgeInsets.all(32),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.phone_in_talk,
                      size: 40,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Text content
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready to Save ${potentialSavings.toStringAsFixed(0)} AED?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contact our verified suppliers for better prices',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.95),
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // CTA Button
                  ElevatedButton.icon(
                    onPressed: () {
                      _showContactDialog(context);
                    },
                    icon: const Icon(Icons.arrow_forward, size: 24),
                    label: const Text(
                      'Get Cheaper Prices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 20,
                      ),
                      elevation: 8,
                      shadowColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Animated pulse effect (optional)
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade300,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Limited Offer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 12),
            const Text('Contact Supplier'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Save up to ${potentialSavings.toStringAsFixed(0)} AED on your purchases!',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Our verified suppliers can offer you:'),
            const SizedBox(height: 8),
            _buildBenefit('✓ Better prices (3-9% savings)'),
            _buildBenefit('✓ Quality products'),
            _buildBenefit('✓ Fast delivery'),
            _buildBenefit('✓ Bulk discounts'),
            const SizedBox(height: 16),
            const Text(
              'Contact: suppliers@company.com',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement contact action
              Navigator.pop(context);
            },
            icon: const Icon(Icons.email),
            label: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

