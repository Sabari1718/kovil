import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size to make it responsive (side-by-side for wide screens, stacked for mobile)
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      // Background matching the image (deep blue/purple gradient)
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1B4B), // Deep Indigo
              Color(0xFF312E81), // Indigo
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Container(
                width: isDesktop ? 900 : 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                // Use Row for desktop, Column for mobile
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 5, child: _buildLeftPanel()),
                          Expanded(flex: 6, child: _buildRightPanel()),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildLeftPanel(isMobile: true),
                          _buildRightPanel(isMobile: true),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2A6B), // Deep purple card color
        borderRadius: isMobile
            ? const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.temple_hindu,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'கோவில் நிர்வாகம்',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'TEMPLE ADMINISTRATION SYSTEM',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'தெய்வீக பணிகளை திறமையாக நிர்வகிக்கும் தவிர்க்க முடியாத ஆன்மீக நிர்வாக தளம்',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Seamlessly manage rituals, festivals, and devotee records in one sacred space.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoPill(Icons.spa, 'பூஜைகள்', 'Rituals'),
          const SizedBox(height: 12),
          _buildInfoPill(Icons.event, 'நிகழ்வுகள்', 'Events'),
          const SizedBox(height: 12),
          _buildInfoPill(Icons.people, 'பக்தர்கள்', 'Devotees'),
        ],
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String titleTamil, String titleEnglish) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleTamil,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  titleEnglish,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20.0 : 40.0,
        vertical: isMobile ? 24.0 : 40.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Colors.indigo,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'உள்நுழைக',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to your admin account',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 32),
          const Text(
            'மின்னஞ்சல் முகவரி (Email)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'admin@example.com',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'கடவுச்சொல் (Password)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: '********',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: !_obscurePassword,
                  onChanged: (value) {
                    setState(() {
                      _obscurePassword = !(value ?? false);
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  activeColor: Colors.indigo,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'கடவுச்சொல் காட்டு (Show Password)',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: ref.watch(authNotifierProvider).isLoading
                ? null
                : () async {
                    var email = _emailController.text.trim();
                    final password = _passwordController.text;

                    // Fix common mobile keyboard typos like @gamil.com
                    if (email.toLowerCase().endsWith('@gamil.com')) {
                      email = email.replaceAll(RegExp(r'@gamil\.com$', caseSensitive: false), '@gmail.com');
                      _emailController.text = email;
                    } else if (email.toLowerCase().endsWith('@gmial.com')) {
                      email = email.replaceAll(RegExp(r'@gmial\.com$', caseSensitive: false), '@gmail.com');
                      _emailController.text = email;
                    }

                    ScaffoldMessenger.of(context).clearSnackBars();

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Please enter both email and password.',
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                      return;
                    }

                    final success = await ref
                        .read(authNotifierProvider.notifier)
                        .login(email, password);

                    if (!mounted) return;

                    if (success) {
                      // Instantly dismiss any pending or active snackbars before navigating!
                      ScaffoldMessenger.of(context).clearSnackBars();

                      final authState = ref.read(authNotifierProvider);
                      final userName =
                          authState.response?.user?.name ?? 'Admin';
                      final userEmail =
                          authState.response?.user?.email ?? email;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(
                            userName: userName,
                            userEmail: userEmail,
                          ),
                        ),
                      );
                    } else {
                      final error = ref.read(authNotifierProvider).error;
                      final isNewUser = error != null && error.contains('பதிவு');
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Login Failed'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: const EdgeInsets.all(16),
                          duration: const Duration(seconds: 3),
                          action: isNewUser
                              ? SnackBarAction(
                                  label: 'பதிவு செய்க',
                                  textColor: Colors.yellowAccent,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    _showRegisterDialog(context);
                                  },
                                )
                              : null,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF524EE1), // Purple button color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (ref.watch(authNotifierProvider).isLoading)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(Icons.login, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    ref.watch(authNotifierProvider).isLoading
                        ? 'உள்நுழைகிறது (Logging in...)'
                        : 'உள்நுழைக (Login to Dashboard)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'புதிய பயனரா? ',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  _showRegisterDialog(context);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'பதிவு செய்க (Register Here)',
                    style: TextStyle(
                      color: Color(0xFF524EE1),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 12, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Secured Admin Access • கோவில் நிர்வாக அமைப்பு',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController(text: _emailController.text);
    final passwordCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF524EE1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_add, color: Color(0xFF524EE1)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'புதிய கணக்கு பதிவு\n(New User Register)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('முழு பெயர் (Full Name)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'எ.கா: சபாரீஸ்வரன்',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('மின்னஞ்சல் (Email)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'user@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('கடவுச்சொல் (Password)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    hintText: '********',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('ரத்து (Cancel)'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF524EE1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final email = emailCtrl.text.trim();
                final pass = passwordCtrl.text;

                if (name.isEmpty || email.isEmpty || pass.isEmpty) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('அனைத்து விவரங்களையும் நிரப்பவும் (Please fill all fields)'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                  return;
                }

                final success = await ref
                    .read(authNotifierProvider.notifier)
                    .register(name, email, pass);

                if (!context.mounted) return;

                if (success) {
                  Navigator.pop(dialogCtx);
                  setState(() {
                    _emailController.text = email;
                    _passwordController.text = pass;
                  });
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'பதிவு வெற்றிகரமாக முடிந்தது! இப்போது உள்நுழையலாம். (Registration successful! You can login now)',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  final error = ref.read(authNotifierProvider).error;
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Registration failed'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              },
              child: const Text('பதிவு செய் (Register)'),
            ),
          ],
        ),
      ),
    );
  }
}
