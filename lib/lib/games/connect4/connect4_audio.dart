import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

/// Programmatic audio effects for Connect 4.
/// All sounds are synthesised in memory — no audio asset files required.
class Connect4Audio {
  static const int _sampleRate = 22050;

  // Cached WAV bytes (generated once on first play).
  static Uint8List? _dropBytes;
  static Uint8List? _winBytes;
  static Uint8List? _drawBytes;

  static Future<void> playDrop() =>
      _play(_dropBytes ??= _buildWav(_dropSamples()));

  static Future<void> playWin() =>
      _play(_winBytes ??= _buildWav(_winSamples()));

  static Future<void> playDraw() =>
      _play(_drawBytes ??= _buildWav(_drawSamples()));

  static Future<void> _play(Uint8List bytes) async {
    try {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.release);
      await player.play(BytesSource(bytes));
    } catch (_) {
      // Audio is non-critical; silently ignore platform failures.
    }
  }

  // ── Sample generators ────────────────────────────────────────────────────

  /// Short percussive "thud" — 160 ms, 320 Hz with exponential decay.
  static List<double> _dropSamples() {
    const ms = 160;
    const n = _sampleRate * ms ~/ 1000;
    return List.generate(n, (i) {
      final t = i / _sampleRate;
      return math.exp(-t * 28) * math.sin(2 * math.pi * 320 * t) * 0.65;
    });
  }

  /// Ascending arpeggio (C4 → E4 → G4 → C5), 110 ms per note.
  static List<double> _winSamples() {
    const freqs = [261.63, 329.63, 392.0, 523.25];
    const noteMs = 110;
    const n = _sampleRate * noteMs ~/ 1000;
    final out = <double>[];
    for (final freq in freqs) {
      for (var i = 0; i < n; i++) {
        final t = i / _sampleRate;
        out.add(math.exp(-t * 9) * math.sin(2 * math.pi * freq * t) * 0.55);
      }
    }
    return out;
  }

  /// Two descending tones — gentle "no winner" signal, 160 ms each.
  static List<double> _drawSamples() {
    const freqs = [330.0, 247.0];
    const noteMs = 160;
    const n = _sampleRate * noteMs ~/ 1000;
    final out = <double>[];
    for (final freq in freqs) {
      for (var i = 0; i < n; i++) {
        final t = i / _sampleRate;
        out.add(math.exp(-t * 10) * math.sin(2 * math.pi * freq * t) * 0.5);
      }
    }
    return out;
  }

  // ── WAV builder ──────────────────────────────────────────────────────────

  static Uint8List _buildWav(List<double> samples) {
    final dataBytes = samples.length * 2; // 16-bit mono PCM
    final buf = ByteData(44 + dataBytes);
    var o = 0;

    void str(String s) {
      for (var i = 0; i < s.length; i++) {
        buf.setUint8(o++, s.codeUnitAt(i));
      }
    }

    // RIFF header
    str('RIFF');
    buf.setUint32(o, 36 + dataBytes, Endian.little);
    o += 4;
    str('WAVE');

    // fmt chunk
    str('fmt ');
    buf.setUint32(o, 16, Endian.little);
    o += 4; // chunk size
    buf.setUint16(o, 1, Endian.little);
    o += 2; // PCM format
    buf.setUint16(o, 1, Endian.little);
    o += 2; // mono
    buf.setUint32(o, _sampleRate, Endian.little);
    o += 4;
    buf.setUint32(o, _sampleRate * 2, Endian.little);
    o += 4; // byte rate
    buf.setUint16(o, 2, Endian.little);
    o += 2; // block align
    buf.setUint16(o, 16, Endian.little);
    o += 2; // bits per sample

    // data chunk
    str('data');
    buf.setUint32(o, dataBytes, Endian.little);
    o += 4;
    for (final s in samples) {
      buf.setInt16(o, (s.clamp(-1.0, 1.0) * 32767).round(), Endian.little);
      o += 2;
    }

    return buf.buffer.asUint8List();
  }
}
