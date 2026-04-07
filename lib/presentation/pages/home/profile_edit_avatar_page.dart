import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/colors.dart';
import '../../../core/dependency_injection/injection_container.dart';
import '../../../core/error/failure.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/gamification_repository.dart';
import '../../bloc/auth_bloc.dart';

/// Chọn ảnh PNG/JPG và cập nhật ảnh đại diện (Firebase Storage + Firestore).
class ProfileEditAvatarPage extends StatefulWidget {
  const ProfileEditAvatarPage({super.key});

  @override
  State<ProfileEditAvatarPage> createState() => _ProfileEditAvatarPageState();
}

class _ProfileEditAvatarPageState extends State<ProfileEditAvatarPage> {
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  bool _isAllowedImage(XFile file) {
    final n = file.name.toLowerCase();
    final p = file.path.toLowerCase();
    return n.endsWith('.png') ||
        n.endsWith('.jpg') ||
        n.endsWith('.jpeg') ||
        p.endsWith('.png') ||
        p.endsWith('.jpg') ||
        p.endsWith('.jpeg');
  }

  String _extensionFor(XFile file) {
    final n = file.name.toLowerCase();
    if (n.endsWith('.png')) return 'png';
    return 'jpg';
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 1200,
    );
    if (xfile == null) return;

    if (!_isAllowedImage(xfile)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chỉ chấp nhận ảnh định dạng PNG hoặc JPG')),
        );
      }
      return;
    }

    setState(() => _uploading = true);
    try {
      final bytes = await xfile.readAsBytes();
      final ext = _extensionFor(xfile);
      final repo = sl<AuthRepository>();
      final gam = sl<GamificationRepository>();
      final updated = await repo.updateProfilePhoto(authState.user, bytes, ext);
      await gam.initializeSession(updated);
      if (!mounted) return;
      context.read<AuthBloc>().add(UserProfileRefreshed(updated));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện')),
      );
      Navigator.of(context).pop();
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ảnh đại diện'),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Chọn ảnh PNG hoặc JPG từ thư viện hoặc chụp mới. Dung lượng tối đa 5 MB.',
              style: tt.bodyMedium?.copyWith(color: context.beeMuted),
            ),
            const SizedBox(height: 24),
            if (_uploading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else ...[
              FilledButton.icon(
                onPressed: () => _pickAndUpload(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Chọn từ thư viện'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimaryStrong,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => _pickAndUpload(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Chụp ảnh'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
