import 'package:flutter/material.dart';

import '../config.dart';

/// Builds a full URL for an image stored in the backend `/uploads` folder.
/// Returns null when the provided [path] is empty.
String? backendImageUrl(String? path) {
  final trimmed = path?.trim() ?? '';
  if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
  if (trimmed.startsWith('http')) return trimmed;
  return '${AppConfig.baseUrl}/uploads/$trimmed';
}

/// Convenience widget to render backend images with sensible fallbacks.
Widget backendImageWidget(
  String? path, {
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
  Widget? error,
}) {
  final resolved = backendImageUrl(path);
  final placeholderWidget =
      placeholder ??
      const Icon(Icons.image_outlined, color: Colors.white30, size: 32);
  final errorWidget =
      error ?? const Icon(Icons.broken_image, color: Colors.white30, size: 32);
  if (resolved == null) return placeholderWidget;

  return Image.network(
    resolved,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget,
  );
}
