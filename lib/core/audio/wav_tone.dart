import 'dart:math' as math;
import 'dart:typed_data';

/// Tạo file WAV PCM 16-bit mono (không cần asset — tương thích mọi nền tảng).
Uint8List buildToneWav(
  double frequencyHz,
  double durationSec, {
  double volume = 0.22,
  int sampleRate = 44100,
}) {
  final n = math.max(1, (durationSec * sampleRate).floor());
  final dataSize = n * 2;
  final total = 44 + dataSize;
  final u = Uint8List(total);
  final bd = ByteData.sublistView(u);

  u.setRange(0, 4, const [0x52, 0x49, 0x46, 0x46]); // RIFF
  bd.setUint32(4, 36 + dataSize, Endian.little);
  u.setRange(8, 12, const [0x57, 0x41, 0x56, 0x45]); // WAVE
  u.setRange(12, 16, const [0x66, 0x6D, 0x74, 0x20]); // fmt
  bd.setUint32(16, 16, Endian.little);
  bd.setUint16(20, 1, Endian.little); // PCM
  bd.setUint16(22, 1, Endian.little); // mono
  bd.setUint32(24, sampleRate, Endian.little);
  bd.setUint32(28, sampleRate * 2, Endian.little);
  bd.setUint16(32, 2, Endian.little);
  bd.setUint16(34, 16, Endian.little);
  u.setRange(36, 40, const [0x64, 0x61, 0x74, 0x61]); // data
  bd.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < n; i++) {
    final t = i / sampleRate;
    final sample =
        (32767 * volume * math.sin(2 * math.pi * frequencyHz * t)).round().clamp(-32767, 32767);
    bd.setInt16(44 + i * 2, sample, Endian.little);
  }
  return u;
}

/// Hai tần số ngắn — nghe khác âm đơn (gợi fail).
Uint8List buildTwoToneFailWav({
  double volume = 0.28,
  int sampleRate = 44100,
}) {
  const dur1 = 0.14;
  const dur2 = 0.16;
  const f1 = 180.0;
  const f2 = 140.0;
  final n1 = (dur1 * sampleRate).floor();
  final n2 = (dur2 * sampleRate).floor();
  final n = n1 + n2;
  final dataSize = n * 2;
  final total = 44 + dataSize;
  final u = Uint8List(total);
  final bd = ByteData.sublistView(u);

  u.setRange(0, 4, const [0x52, 0x49, 0x46, 0x46]);
  bd.setUint32(4, 36 + dataSize, Endian.little);
  u.setRange(8, 12, const [0x57, 0x41, 0x56, 0x45]);
  u.setRange(12, 16, const [0x66, 0x6D, 0x74, 0x20]);
  bd.setUint32(16, 16, Endian.little);
  bd.setUint16(20, 1, Endian.little);
  bd.setUint16(22, 1, Endian.little);
  bd.setUint32(24, sampleRate, Endian.little);
  bd.setUint32(28, sampleRate * 2, Endian.little);
  bd.setUint16(32, 2, Endian.little);
  bd.setUint16(34, 16, Endian.little);
  u.setRange(36, 40, const [0x64, 0x61, 0x74, 0x61]);
  bd.setUint32(40, dataSize, Endian.little);

  var offset = 44;
  for (var i = 0; i < n1; i++) {
    final t = i / sampleRate;
    final sample =
        (32767 * volume * math.sin(2 * math.pi * f1 * t)).round().clamp(-32767, 32767);
    bd.setInt16(offset, sample, Endian.little);
    offset += 2;
  }
  for (var i = 0; i < n2; i++) {
    final t = i / sampleRate;
    final sample =
        (32767 * volume * math.sin(2 * math.pi * f2 * t)).round().clamp(-32767, 32767);
    bd.setInt16(offset, sample, Endian.little);
    offset += 2;
  }
  return u;
}
