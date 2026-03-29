import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skillconnect/presentation/blocs/auth_bloc.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

/// Registration screen for new users.
///
/// Supports two account types toggled by a segmented control:
/// - **Client**: only requires name, email, and password.
/// - **Provider**: additionally requires business name, service category,
///   base rate, and a short bio. The extra fields animate in when the
///   Provider tab is selected.
///
/// All validation runs in [_onSignUpPressed] before dispatching
/// [SignUpRequested] to [AuthBloc].
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _baseRateController = TextEditingController();
  final _bioController = TextEditingController();

  String _userType = 'client';
  String _selectedCategory = 'Tailoring';
  final List<String> _categories = ['Tailoring', 'Baking', 'Hair', 'Other'];

  /// Controls whether the password field displays plain text.
  bool _obscurePassword = true;

  /// Controls whether the confirm-password field displays plain text.
  bool _obscureConfirmPassword = true;

  File? _profileImage;
  String? _profileImageBase64;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      final bytes = await _profileImage!.readAsBytes();
      _profileImageBase64 = base64Encode(bytes);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _baseRateController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join SkillConnect and start sharing skills',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // Role toggle: Client or Provider
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _userType = 'client'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _userType == 'client'
                                ? const Color(0xFFE67E22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Client',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _userType == 'client'
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _userType = 'provider'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _userType == 'provider'
                                ? const Color(0xFFE67E22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Provider',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _userType == 'provider'
                                  ? Colors.white
                                  : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_nameController, 'Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'Email',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              // Password field with visibility toggle
              _buildTextField(
                _passwordController,
                'Password',
                Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 16),
              // Confirm password field with its own visibility toggle
              _buildTextField(
                _confirmPasswordController,
                'Confirm Password',
                Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),

              if (_userType == 'provider') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                const Text(
                  'Business Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Upload Profile Image (Optional)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                _buildTextField(_businessNameController, 'Business Name', Icons.business_outlined),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _baseRateController,
                  'Base Rate (UGX)',
                  Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _bioController,
                  'Short Bio',
                  Icons.description_outlined,
                  maxLines: 3,
                ),
              ],

              const SizedBox(height: 32),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  } else if (state is Authenticated) {
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) {
                  if (state is AuthLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _onSignUpPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE67E22),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable helper that builds a consistently styled [TextField].
  ///
  /// [suffixIcon] is optional and used for password visibility toggles.
  /// All fields share the same 12 dp rounded border and prefix icon.
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Validates all required fields and dispatches [SignUpRequested] to [AuthBloc].
  ///
  /// Validation order:
  /// 1. Required fields (name, email, password) must not be empty.
  /// 2. Password and confirm-password must match.
  /// 3. For provider accounts, business name and base rate are also required.
  void _onSignUpPressed() {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (_userType == 'provider' &&
        (_businessNameController.text.isEmpty ||
            _baseRateController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider details are required')),
      );
      return;
    }


    context.read<AuthBloc>().add(
      SignUpRequested(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        userType: _userType,
        businessName:
            _userType == 'provider' ? _businessNameController.text : null,
        category: _userType == 'provider' ? _selectedCategory : null,
        baseRate: _userType == 'provider'
            ? double.tryParse(_baseRateController.text)
            : null,
        bio: _userType == 'provider' ? _bioController.text : null,
        profileImageBase64: _userType == 'provider' ? _profileImageBase64 : null,
      ),
    );
  }
}