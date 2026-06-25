import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vsign_mobile_app/core/models/auth_models.dart';
import 'package:vsign_mobile_app/core/models/payment_models.dart';
import 'package:vsign_mobile_app/core/network/analytics_service.dart';
import 'package:vsign_mobile_app/core/network/api_client.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';
import 'package:vsign_mobile_app/features/auth/bloc/auth_bloc.dart';
import 'package:vsign_mobile_app/features/monetization/presentation/payment_webview_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<PaymentPlan> _plans = [];
  bool _loadingPlans = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  void _loadPlans() async {
    setState(() {
      _loadingPlans = true;
    });
    try {
      final repository = GetIt.instance<AuthRepository>();
      // Get the profile state
      final profile = await repository.getProfile();
      if (!mounted) return;
      setState(() {
        _user = profile;
      });

      // Load billing plans
      final response = await GetIt.instance<ApiClient>().dio.get('/subscription/plans');
      final List list = response.data['data'] ?? response.data ?? [];
      if (!mounted) return;
      setState(() {
        _plans = list.map((item) => PaymentPlan.fromJson(item)).toList();
        _loadingPlans = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingPlans = false;
      });
    }
  }

  void _triggerPayment(PaymentPlan plan) async {
    final client = GetIt.instance<ApiClient>();
    setState(() {
      _loadingPlans = true;
    });
    try {
      final response = await client.dio.post('/payments/orders', data: {
        'planType': plan.planType,
        'provider': 'PAYOS',
      });
      final order = PaymentOrderResponse.fromJson(response.data['data'] ?? response.data);
      
      if (mounted) {
        setState(() {
          _loadingPlans = false;
        });

        // Launch in-app WebView for PayOS checkout
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentWebViewScreen(
              checkoutUrl: order.deepLink.isNotEmpty ? order.deepLink : order.qrCodeData,
              successRedirectUrl: 'v-sign.vercel.app/payment/success', // PayOS Web Return Success url path
              title: 'Thanh toán Premium',
              onSuccess: (url) {
                // Log purchase GA4 event
                GetIt.instance<AnalyticsService>().logPurchase(plan.planType, plan.price.toDouble(), plan.currency);
                // Refresh subscription status from backend
                _loadPlans();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nâng cấp PREMIUM thành công! Cảm ơn bạn.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingPlans = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo hóa đơn nâng cấp Premium thất bại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tài khoản của tôi',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User detail section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: colorScheme.primary.withAlpha(20),
                          child: Icon(LucideIcons.user, size: 48, color: colorScheme.primary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _user!.displayName,
                          style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _user!.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: _user!.accountType == 'PREMIUM' ? Colors.amber.withAlpha(30) : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _user!.accountType == 'PREMIUM' ? Colors.amber : Colors.grey,
                            ),
                          ),
                          child: Text(
                            _user!.accountType == 'PREMIUM' ? 'TÀI KHOẢN PREMIUM' : 'TÀI KHOẢN FREE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _user!.accountType == 'PREMIUM' ? Colors.amber[800] : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Upgrade premium plans section
                  if (_user!.accountType != 'PREMIUM') ...[
                    Text(
                      'Nâng cấp lên Premium',
                      style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Mở khóa toàn bộ bài học và các tính năng luyện tập AI thông minh',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingPlans)
                      const Center(child: CircularProgressIndicator())
                    else
                      ..._plans.map((plan) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Thời hạn: ${plan.durationDays} ngày',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${plan.price} ${plan.currency}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _triggerPayment(plan),
                                  child: const Text('Mua ngay'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(LucideIcons.share2),
                          title: const Text('Chia sẻ bạn bè'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Copy link referral link
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã sao chép liên kết giới thiệu bạn bè!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(LucideIcons.logOut, color: Colors.red),
                          title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                          onTap: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                            context.go('/login');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
