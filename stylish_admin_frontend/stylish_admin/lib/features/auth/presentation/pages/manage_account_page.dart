import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:stylish_admin/core/theme/theme.dart';
import 'package:stylish_admin/features/auth/domain/entities/user_entity.dart';
import 'package:stylish_admin/features/auth/domain/usecase/update_profile_usecase.dart';
import 'package:stylish_admin/features/auth/presentation/bloc/auth_bloc.dart';

class ManageAccountPage extends StatefulWidget {
  final UserEntity user;
  const ManageAccountPage({super.key, required this.user});

  @override
  State<ManageAccountPage> createState() => _ManageAccountPageState();
}

class _ManageAccountPageState extends State<ManageAccountPage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _imageChanged = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
  }

  @override
  void didUpdateWidget(covariant ManageAccountPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user != widget.user) {
      _initControllers();
    }
  }

  bool _validateForm() {
    if (_formKey.currentState?.validate() ?? false) {
      return true;
    }
    return false;
  }

  void _updateAccount() {
    if (!_validateForm()) return;
    final updateParams = UpdateProfileParams(
      _firstNameController.text,
      _lastNameController.text,
      _phoneController.text,
      _imageChanged ? _webImageBytes : null,
    );
    context.read<AuthBloc>().add(UpdateProfileEvent(updateParams));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Account')),
      // backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingLarge),
              child: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is ProfileUpdateSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Account updated successfully',
                          style: AppTheme.bodyMedium(),
                        ),
                        backgroundColor: AppTheme.positive,
                      ),
                    );
                    setState(() {
                      _imageChanged = false;
                    });
                  } else if (state is ProfileUpdateError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to update account',
                          style: AppTheme.bodyMedium(),
                        ),
                        backgroundColor: AppTheme.negative,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final currentUser = state is Authenticated
                      ? state.user
                      : widget.user;
                  return Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Manage Account', style: AppTheme.headingMedium()),
                        SizedBox(height: AppTheme.spacingLarge),
                        // Profile picture section
                        Center(
                          child: Column(
                            children: [
                              _buildProfilePicture(currentUser),
                              SizedBox(height: AppTheme.spacingMedium),
                              TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.photo_library),
                                label: Text('Change profile Picture'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.accentBlue,
                                ),
                              ),
                              SizedBox(height: AppTheme.spacingLarge),
                              _buildTextField(
                                controller: _usernameController,
                                labelText: 'Username',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Username cannot be empty';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: AppTheme.spacingMedium),
                              _buildTextField(
                                controller: _emailController,
                                labelText: "Email",
                                readOnly: true,
                              ),
                              SizedBox(height: AppTheme.spacingMedium),
                              _buildTextField(
                                controller: _firstNameController,
                                labelText: "First Name",
                              ),
                              SizedBox(height: AppTheme.spacingMedium),
                              _buildTextField(
                                controller: _lastNameController,
                                labelText: "Last Name",
                              ),
                              SizedBox(height: AppTheme.spacingMedium),
                              _buildTextField(
                                controller: _phoneController,
                                labelText: 'Phone Number',
                                keyboardType: TextInputType.phone,
                              ),
                              SizedBox(height: AppTheme.spacingLarge),
                              _buildUpdateButton(state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(AuthState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is! ProfileUpdating ? _updateAccount : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryLight,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingLarge,
            vertical: AppTheme.spacingMedium,
          ),
        ),
        child: state is ProfileUpdating
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                'Update Account',
                style: AppTheme.bodyMedium().copyWith(color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: AppTheme.bodyMedium(),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.borderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.negative),
        ),
      ),
      style: AppTheme.bodyMedium(),
    );
  }

  Widget _buildProfilePicture(UserEntity user) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.accentBlue.withAlpha((0.2 * 255).round()),
            border: Border.all(color: AppTheme.borderColor, width: 2),
          ),
          child: ClipOval(child: _buildProfileImageContent(user)),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: GestureDetector(
              onTap: _pickImage,
              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageChanged = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: AppTheme.bodyMedium(),
            ),
            backgroundColor: AppTheme.negative,
          ),
        );
      }
    }
  }

  Widget _buildProfileImageContent(UserEntity user) {
    if (_imageChanged && _webImageBytes != null) {
      return Image.memory(
        _webImageBytes!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(user);
        },
      );
    }
    if (user.profilePictureUrl != null && user.profilePictureUrl!.isNotEmpty) {
      return Image.network(
        user.profilePictureUrl!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackAvatar(user);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: AppTheme.accentBlue,
            ),
          );
        },
      );
    }
    return _buildFallbackAvatar(user);
  }

  Widget _buildFallbackAvatar(UserEntity user) {
    return Center(
      child: Text(
        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
        style: AppTheme.headingLarge().copyWith(color: AppTheme.accentBlue),
      ),
    );
  }
}
