import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/account_data.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:provider/provider.dart';

/// Full-screen login / create-account page.
/// Since the backend has no real auth, "logging in" simply sets the
/// accountLoggedOut flag to false via AccountData.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final _loginKey = GlobalKey<FormState>();
  final _registerKey = GlobalKey<FormState>();

  final _loginEmail = TextEditingController();
  final _loginPassword = TextEditingController();

  final _regFirstName = TextEditingController();
  final _regLastName = TextEditingController();
  final _regEmail = TextEditingController();
  final _regPassword = TextEditingController();
  final _regPassword2 = TextEditingController();

  bool _obscureLogin = true;
  bool _obscureReg1 = true;
  bool _obscureReg2 = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    _loginEmail.dispose();
    _loginPassword.dispose();
    _regFirstName.dispose();
    _regLastName.dispose();
    _regEmail.dispose();
    _regPassword.dispose();
    _regPassword2.dispose();
    super.dispose();
  }

  void _login() {
    if (!_loginKey.currentState!.validate()) return;
    final iMat = context.read<ImatDataHandler>();
    AccountData.setLoggedIn(iMat, true);
    Navigator.pop(context);
  }

  void _register() {
    if (!_registerKey.currentState!.validate()) return;
    final iMat = context.read<ImatDataHandler>();
    // Persist the name + email on the backend Customer
    final customer = iMat.getCustomer();
    customer.firstName = _regFirstName.text.trim();
    customer.lastName = _regLastName.text.trim();
    customer.email = _regEmail.text.trim();
    iMat.setCustomer(customer);
    AccountData.setLoggedIn(iMat, true);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.gray900),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mitt konto',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray900,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.gray200),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.paddingHuge),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.gray200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Tab bar
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: AppTheme.gray200),
                          ),
                        ),
                        child: TabBar(
                          controller: _tab,
                          indicatorColor: AppTheme.green600,
                          indicatorWeight: 2,
                          labelColor: AppTheme.green700,
                          unselectedLabelColor: AppTheme.gray500,
                          labelStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: const TextStyle(
                            fontSize: 16,
                          ),
                          tabs: const [
                            Tab(text: 'Logga in'),
                            Tab(text: 'Skapa konto'),
                          ],
                        ),
                      ),
                      // Forms
                      SizedBox(
                        height: 420,
                        child: TabBarView(
                          controller: _tab,
                          children: [
                            _LoginForm(
                              formKey: _loginKey,
                              email: _loginEmail,
                              password: _loginPassword,
                              obscurePassword: _obscureLogin,
                              onToggleObscure: () =>
                                  setState(() => _obscureLogin = !_obscureLogin),
                              onSubmit: _login,
                            ),
                            _RegisterForm(
                              formKey: _registerKey,
                              firstName: _regFirstName,
                              lastName: _regLastName,
                              email: _regEmail,
                              password: _regPassword,
                              password2: _regPassword2,
                              obscurePassword: _obscureReg1,
                              obscurePassword2: _obscureReg2,
                              onToggleObscure1: () =>
                                  setState(() => _obscureReg1 = !_obscureReg1),
                              onToggleObscure2: () =>
                                  setState(() => _obscureReg2 = !_obscureReg2),
                              onSubmit: _register,
                            ),
                          ],
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
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController email;
  final TextEditingController password;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.email,
    required this.password,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.paddingSmall),
            _Field(
              controller: email,
              label: 'E-postadress',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ange e-postadress';
                if (!v.contains('@')) return 'Ogiltig e-postadress';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _Field(
              controller: password,
              label: 'Lösenord',
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.gray400,
                ),
                onPressed: onToggleObscure,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ange lösenord';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: const Text(
                'Logga in',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController email;
  final TextEditingController password;
  final TextEditingController password2;
  final bool obscurePassword;
  final bool obscurePassword2;
  final VoidCallback onToggleObscure1;
  final VoidCallback onToggleObscure2;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.formKey,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.password2,
    required this.obscurePassword,
    required this.obscurePassword2,
    required this.onToggleObscure1,
    required this.onToggleObscure2,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.paddingSmall),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: firstName,
                    label: 'Förnamn',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Krävs' : null,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMediumSmall),
                Expanded(
                  child: _Field(
                    controller: lastName,
                    label: 'Efternamn',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Krävs' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _Field(
              controller: email,
              label: 'E-postadress',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ange e-postadress';
                if (!v.contains('@')) return 'Ogiltig e-postadress';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _Field(
              controller: password,
              label: 'Lösenord',
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.gray400,
                ),
                onPressed: onToggleObscure1,
              ),
              validator: (v) {
                if (v == null || v.length < 6) return 'Minst 6 tecken';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMediumSmall),
            _Field(
              controller: password2,
              label: 'Bekräfta lösenord',
              obscureText: obscurePassword2,
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword2 ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.gray400,
                ),
                onPressed: onToggleObscure2,
              ),
              validator: (v) {
                if (v != password.text) return 'Lösenorden matchar inte';
                return null;
              },
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
              ),
              child: const Text(
                'Skapa konto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.green500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.red500),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          borderSide: const BorderSide(color: AppTheme.red500, width: 2),
        ),
      ),
    );
  }
}
