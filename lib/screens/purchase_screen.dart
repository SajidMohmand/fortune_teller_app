import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_option_model.dart';
import '../providers/purchase_provider.dart';
import '../widgets/processing_dialog.dart';
import '../widgets/purchase_card.dart';
import '../widgets/success_purchase_dialog.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  int? _selectedPremadeIndex;
  int? _selectedCustomIndex;

  final List<PurchaseOption> _premadeOptions = [
    PurchaseOption(
      title: "Single Question",
      price: 0.99,
      description: "Try it out",
      questionCount: 1,
      badge: null,
    ),
    PurchaseOption(
      title: "5 Questions Pack",
      price: 4.95,
      description: "Most Popular",
      questionCount: 5,
      badge: "BEST VALUE",
      savingsPercent: 20,
    ),
    PurchaseOption(
      title: "10 Questions Pack",
      price: 9.9,
      description: "Ultimate Bundle",
      questionCount: 10,
      badge: null,
      savingsPercent: 40,
    ),
  ];

  final List<PurchaseOption> _customOptions = [
    PurchaseOption(
      title: "Single Tailored Question",
      price: 1.99,
      description: "Personal insight",
      questionCount: 1,
      badge: null,
    ),
    PurchaseOption(
      title: "5 Tailored Questions",
      price: 9.9,
      description: "Deep dive",
      questionCount: 5,
      badge: "POPULAR",
      savingsPercent: 40,
    ),
    PurchaseOption(
      title: "10 Tailored Questions",
      price: 19.9,
      description: "Complete guidance",
      questionCount: 10,
      badge: "ULTIMATE",
      savingsPercent: 60,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase(BuildContext context, PurchaseOption option, bool isPremade) async {
    final purchase = ref.read(purchaseProvider);

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ProcessingDialog(),
    );

    // Simulate purchase processing
    await Future.delayed(const Duration(milliseconds: 800));

    // Close loading dialog
    if (!mounted) return;
    Navigator.of(context).pop();

    // Perform actual purchase
    if (isPremade) {
      await purchase.buyPremadePack(option.questionCount);
    } else {
      await purchase.buyCustomPack(option.questionCount);
    }


    // Show success animation
    _showSuccessAnimation(context, option);
  }

  void _showSuccessAnimation(BuildContext context, PurchaseOption option) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => SuccessPurchaseDialog(option: option),
    );

    // Close after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Upgrade Your Insights",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0C0D2C),
              Color(0xFF1A1B3A),
              Color(0xFF2A2B50),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fade.value,
                child: Transform.translate(
                  offset: Offset(0, _slide.value),
                  child: child,
                ),
              );
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.3),
                        Colors.deepPurple.withOpacity(0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "PREMIUM QUESTIONS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pre-Made Section
                _buildSectionHeader(
                  title: "Pre-Made Questions",
                  subtitle: "Instant insights from our curated collection",
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(height: 12),

                ..._premadeOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return PurchaseCard(
                    option: option,
                    isSelected: _selectedPremadeIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedPremadeIndex = index;
                        _selectedCustomIndex = null;
                      });
                    },
                    onBuy: () => _handlePurchase(context, option, true),
                    accentColor: Colors.blueAccent,
                  );
                }),

                const SizedBox(height: 32),

                // Custom Section
                _buildSectionHeader(
                  title: "Tailored Questions",
                  subtitle: "Personalized insights written just for you",
                  icon: Icons.edit_note,
                ),
                const SizedBox(height: 12),

                ..._customOptions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final option = entry.value;
                  return PurchaseCard(
                    option: option,
                    isSelected: _selectedCustomIndex == index,
                    onTap: () {
                      setState(() {
                        _selectedCustomIndex = index;
                        _selectedPremadeIndex = null;
                      });
                    },
                    onBuy: () => _handlePurchase(context, option, false),
                    accentColor: Colors.purpleAccent,
                  );
                }),

                const SizedBox(height: 32),

                // Buy Now Button
                if (_selectedPremadeIndex != null || _selectedCustomIndex != null)
                  _buildBuyNowButton(context),

                const SizedBox(height: 32),

                // Features
                _buildFeaturesSection(),

                const SizedBox(height: 16),

                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lock, color: Colors.green, size: 14),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Secure payment • 256-bit encryption",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "⏳ Replies delivered in 1-5 business days",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Questions never expire • Cancel anytime",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuyNowButton(BuildContext context) {
    final selectedOption = _selectedPremadeIndex != null
        ? _premadeOptions[_selectedPremadeIndex!]
        : _customOptions[_selectedCustomIndex!];
    final isPremade = _selectedPremadeIndex != null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purpleAccent.withOpacity(0.8),
                Colors.deepPurple.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedOption.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isPremade ? "Pre-made questions" : "Tailored questions",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${selectedOption.price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                  if (selectedOption.savingsPercent != null)
                    Text(
                      "Save ${selectedOption.savingsPercent}%",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _handlePurchase(context, selectedOption, isPremade),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 18),
              const SizedBox(width: 10),
              const Text(
                "Buy Now",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "SECURE",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✨ What you'll get:",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildFeatureChip(Icons.star, "Premium insights"),
            _buildFeatureChip(Icons.lock_clock, "Lifetime access"),
            _buildFeatureChip(Icons.devices, "Sync across devices"),
            _buildFeatureChip(Icons.support, "Priority support"),
            _buildFeatureChip(Icons.update, "Free updates"),
            _buildFeatureChip(Icons.thumb_up, "100% satisfaction"),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}