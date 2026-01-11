import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';

Future<File> generateLocalSampleWav() async {
  final sampleRate = 22050;
  final durationSec = 2;
  final numSamples = sampleRate * durationSec;
  final bytesPerSample = 2; // 16-bit
  final dataLength = numSamples * bytesPerSample;

  const headerLen = 44;
  final totalLen = headerLen + dataLength;
  final bytes = Uint8List(totalLen);
  final bd = bytes.buffer.asByteData();

  // RIFF header
  bytes.setRange(0, 4, ascii.encode('RIFF'));
  bd.setUint32(4, 36 + dataLength, Endian.little);
  bytes.setRange(8, 12, ascii.encode('WAVE'));

  // fmt chunk
  bytes.setRange(12, 16, ascii.encode('fmt '));
  bd.setUint32(16, 16, Endian.little); // Subchunk1Size
  bd.setUint16(20, 1, Endian.little); // AudioFormat PCM
  bd.setUint16(22, 1, Endian.little); // NumChannels
  bd.setUint32(24, sampleRate, Endian.little);
  bd.setUint32(28, sampleRate * bytesPerSample, Endian.little); // ByteRate
  bd.setUint16(32, bytesPerSample * 1, Endian.little); // BlockAlign
  bd.setUint16(34, 16, Endian.little); // BitsPerSample

  // data chunk header
  bytes.setRange(36, 40, ascii.encode('data'));
  bd.setUint32(40, dataLength, Endian.little);

  // PCM samples (sine wave)
  final freq = 440.0;
  final amplitude = 0.5; // relative amplitude (0.0 - 1.0)
  final maxInt16 = 32767;
  int offset = headerLen;
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final v = (amplitude * maxInt16 * sin(2 * pi * freq * t)).round();
    bd.setInt16(offset, v, Endian.little);
    offset += bytesPerSample;
  }

  final tmpDir = Directory.systemTemp;
  final file = File('${tmpDir.path}/storynest_sample_${DateTime.now().millisecondsSinceEpoch}.wav');
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
