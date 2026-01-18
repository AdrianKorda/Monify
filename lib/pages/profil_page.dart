import 'package:flutter/material.dart';
import 'package:koltsegkoveto/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/currency/currency_service.dart';
import '../core/currency/currency.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/localization/language.dart';
import '../core/localization/language_service.dart';
import '../core/localization/app_strings.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final user = Supabase.instance.client.auth.currentUser;

  final TextEditingController fullNameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();

  File? _selectedImage;
  String? _profileImageUrl;

  late Currency _selectedCurrencyTemp;
  late AppLanguage _selectedLanguageTemp;

  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    emailCtrl.text = user?.email ?? "";
    _selectedCurrencyTemp = CurrencyService.selectedCurrency;
    _selectedLanguageTemp = LanguageService.selectedLanguage;
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _loadUserData() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('full_name, avatar_path')
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response != null) {
        String? avatarUrl;
        String? avatarPath = response['avatar_path'];

        if (avatarPath != null && avatarPath.isNotEmpty) {
          final cleanPath = avatarPath.startsWith('/') 
              ? avatarPath.substring(1) 
              : avatarPath;
          
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          avatarUrl = '${Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(cleanPath)}?t=$timestamp';
        }

        setState(() {
          fullNameCtrl.text = response['full_name'] ?? '';
          _profileImageUrl = avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      //debugPrint('❌ Hiba profil betöltéskor: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final fullName = fullNameCtrl.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.fullName} ${AppStrings.cannotBeEmpty}'),
        ),
      );
      return;
    }

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'full_name': fullName})
          .eq('user_id', currentUser.id);

      if (_selectedCurrencyTemp != CurrencyService.selectedCurrency) {
        await CurrencyService.saveCurrency(_selectedCurrencyTemp);
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.profileUpdated)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${AppStrings.error}: $e")));
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppStrings.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedImage = File(pickedFile.path);
    });

    await _uploadProfileImage();
  }

  Future<void> _uploadProfileImage() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null || _selectedImage == null) return;

    final fileExt = _selectedImage!.path.split('.').last;
    final filePath = '${currentUser.id}/avatar.$fileExt';

    try {
      if (_profileImageUrl != null) {
        await CachedNetworkImage.evictFromCache(_profileImageUrl!);
      }

      // Upload a fájlt
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(
            filePath,
            _selectedImage!,
            fileOptions: const FileOptions(upsert: true),
          );

      await Future.delayed(const Duration(milliseconds: 500));

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicUrl = '${Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(filePath)}?t=$timestamp';

      await Supabase.instance.client
          .from('profiles')
          .update({'avatar_path': filePath})
          .eq('user_id', currentUser.id);

      setState(() {
        _profileImageUrl = publicUrl;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.profileImageUpdated)));
    } catch (e) {
      //debugPrint('❌ Feltöltési hiba: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${AppStrings.errorUploading}: $e")),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', false);
    
    await Supabase.instance.client.auth.signOut();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final savedFullName = fullNameCtrl.text;

    return ValueListenableBuilder(
      valueListenable: LanguageService.notifier,
      builder: (context, _, __) {
        return GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
              fullNameCtrl.text = savedFullName;
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB69CFF),
                    Color(0xFFE8DEFF),
                    Color(0xFFF2F2F7),
                  ],
                  stops: [0.0, 0.45, 0.8],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.editProfile,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.grey[200],
                                    child: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              key: ValueKey(_profileImageUrl),
                                              imageUrl: _profileImageUrl!,
                                              fit: BoxFit.cover,
                                              width: 96,
                                              height: 96,
                                              placeholder: (context, url) => 
                                                  const CircularProgressIndicator(),
                                              errorWidget: (context, url, error) {
                                                return Icon(
                                                  Icons.person,
                                                  size: 48,
                                                  color: Colors.grey[600],
                                                );
                                              },
                                            ),
                                          )
                                        : Icon(
                                            Icons.person,
                                            size: 48,
                                            color: Colors.grey[600],
                                          ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF8E6CFF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _input(AppStrings.fullName, fullNameCtrl),
                              const SizedBox(height: 16),
                              _input(
                                AppStrings.email,
                                emailCtrl,
                                enabled: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.settings,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.currency,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Currency>(
                                    value: _selectedCurrencyTemp,
                                    isExpanded: true,
                                    icon: const Icon(Icons.arrow_drop_down),
                                    selectedItemBuilder: (context) {
                                      return Currency.values.map((currency) {
                                        return Row(
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                              ),
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                'assets/images/${currency.name.toLowerCase()}.svg',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              currency.name.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList();
                                    },
                                    items: Currency.values.map((currency) {
                                      return DropdownMenuItem(
                                        value: currency,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[100],
                                              ),
                                              padding: const EdgeInsets.all(6),
                                              child: SvgPicture.asset(
                                                'assets/images/${currency.name.toLowerCase()}.svg',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(currency.name.toUpperCase()),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _selectedCurrencyTemp = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.language,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F2F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<AppLanguage>(
                                    value: _selectedLanguageTemp,
                                    isExpanded: true,
                                    items: [
                                      DropdownMenuItem(
                                        value: AppLanguage.hu,
                                        child: Text(AppStrings.hungarian),
                                      ),
                                      DropdownMenuItem(
                                        value: AppLanguage.en,
                                        child: Text(AppStrings.english),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() {
                                        _selectedLanguageTemp = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _updateProfile();
                            await LanguageService.saveLanguage(
                              _selectedLanguageTemp,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppStrings.profileUpdated),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            AppStrings.save,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: _logout,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              AppStrings.logout,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _input(
    String label,
    TextEditingController ctrl, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}