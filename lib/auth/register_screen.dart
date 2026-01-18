import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:koltsegkoveto/core/localization/app_strings.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../pages/login.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nevController = TextEditingController();
  final _emailController = TextEditingController();
  final _jelszoController = TextEditingController();
  final _jelszoUjraController = TextEditingController();

  String _hibaUzenet = '';
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final supabaseService = SupabaseService();
  final supabase = Supabase.instance.client;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourEmail;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.enterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.enterYourPassword;
    }
    if (value.length < 8) {
      return AppStrings.minimumCharacters;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.confirmPassword;
    }
    if (value != _jelszoController.text) {
      return AppStrings.passwordsDontMatch;
    }
    return null;
  }

  Future<void> _regisztral() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _hibaUzenet = '';
    });

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _jelszoController.text.trim(),
        data: {'full_name': _nevController.text.trim()},
      );

      final user = response.user;

      if (user != null) {
        await supabase.from('profiles').insert({
          'user_id': user.id,
          'full_name': _nevController.text.trim(),
          'created_at': DateTime.now().toIso8601String(),
        });

        await supabase.auth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.registrationSucces),
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _hibaUzenet = e.message;
      });
    } catch (e) {
      setState(() {
        _hibaUzenet = '${AppStrings.errorOccurred}: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  SvgPicture.asset(
                    'assets/illustrations/register.svg',
                    height: 180,
                  ),

                  const SizedBox(height: 40),

                 Text(
                    AppStrings.registration,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),

                  const SizedBox(height: 8),

                 Text(
                    AppStrings.pleaseRegister,
                    style: TextStyle(fontSize: 14, color: Color(0xFF8F92A1)),
                  ),

                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nevController,
                    decoration: InputDecoration(
                      labelText: AppStrings.fullName,
                      labelStyle: const TextStyle(
                        color: Color(0xFF8F92A1),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF8F92A1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C5CE7),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? AppStrings.enterYourName : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(
                        color: Color(0xFF8F92A1),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Color(0xFF8F92A1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C5CE7),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                    ),
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _jelszoController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      labelStyle: const TextStyle(
                        color: Color(0xFF8F92A1),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF8F92A1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF8F92A1),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C5CE7),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                    ),
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _jelszoUjraController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.confirmPassword2,
                      labelStyle: const TextStyle(
                        color: Color(0xFF8F92A1),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Color(0xFF8F92A1),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF8F92A1),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF6C5CE7),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F7F9),
                    ),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 24),

                  if (_hibaUzenet.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _hibaUzenet,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _regisztral,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppStrings.signUp2,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppStrings.haveAcc} ',
                        style: TextStyle(
                          color: Color(0xFF8F92A1),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          AppStrings.signIn,
                          style: TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
