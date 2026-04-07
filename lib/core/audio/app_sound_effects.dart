import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

import 'wav_tone.dart';

/// Hiệu ứng âm thanh ngắn (đăng nhập, trắc nghiệm). Dùng WAV tạo tại runtime — không cần file trong assets.
abstract final class AppSoundEffects {
  static final AudioPlayer _player = AudioPlayer();

  static Uint8List? _loginOk;
  static Uint8List? _loginFail;
  static Uint8List? _quizOk;
  static Uint8List? _quizBad;

  static void _ensureCached() {
    _loginOk ??= buildToneWav(880, 0.14, volume: 0.22);
    _loginFail ??= buildTwoToneFailWav(volume: 0.32);
    _quizOk ??= buildToneWav(660, 0.11, volume: 0.24);
    _quizBad ??= buildToneWav(130, 0.22, volume: 0.3);
  }

  /// Data URI — hoạt động trên Android & iOS (BytesSource WAV thường không hỗ trợ iOS).
  static Source _sourceFromWav(Uint8List bytes) {
    final uri = Uri.dataFromBytes(bytes, mimeType: 'audio/wav');
    return UrlSource(uri.toString());
  }

  static Future<void> playLoginSuccess() async {
    _ensureCached();
    await _player.stop();
    await _player.play(_sourceFromWav(_loginOk!));
  }

  static Future<void> playLoginFailure() async {
    _ensureCached();
    await _player.stop();
    await _player.play(_sourceFromWav(_loginFail!));
  }

  static Future<void> playQuizCorrect() async {
    _ensureCached();
    await _player.stop();
    await _player.play(_sourceFromWav(_quizOk!));
  }

  static Future<void> playQuizIncorrect() async {
    _ensureCached();
    await _player.stop();
    await _player.play(_sourceFromWav(_quizBad!));
  }
}
