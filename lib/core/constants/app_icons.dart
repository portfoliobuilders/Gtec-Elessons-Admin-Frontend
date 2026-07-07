import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The web design uses hand-drawn stroke SVGs (feather-style).
/// Every path below is copied verbatim from the design's inline SVG markup
/// so icons render pixel-identical to the source.
class AppIcons {
  AppIcons._();

  static const String dashboard =
      '<rect x="3" y="3" width="8" height="8" rx="1.6"/><rect x="13" y="3" width="8" height="5" rx="1.6"/><rect x="13" y="11" width="8" height="10" rx="1.6"/><rect x="3" y="14" width="8" height="7" rx="1.6"/>';
  static const String curriculum =
      '<path d="M4 5a2 2 0 0 1 2-2h10l4 4v12a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2z"/><path d="M8 8h6M8 12h8M8 16h5"/>';
  static const String pricing =
      '<path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>';
  static const String assessments =
      '<path d="M9 11l3 3 8-8"/><path d="M20 12v6a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h9"/>';
  static const String students =
      '<circle cx="9" cy="8" r="3.5"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/><path d="M16 4a3.5 3.5 0 0 1 0 7M21 20c0-2.4-1.4-4.5-3.5-5.5"/>';
  static const String userGroup =
      '<circle cx="9" cy="8" r="3.5"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/>';
  static const String user =
      '<circle cx="9" cy="8" r="3.5"/><path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6"/><path d="M16 4a3.5 3.5 0 0 1 0 7"/>';
  static const String bell =
      '<path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/>';
  static const String bellPlain =
      '<path d="M18 8a6 6 0 1 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/>';
  static const String search =
      '<circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/>';
  static const String plus = '<path d="M12 5v14M5 12h14"/>';
  static const String chevronRight = '<path d="M9 6l6 6-6 6"/>';
  static const String chevronDown = '<path d="M6 9l6 6 6-6"/>';
  static const String chevronUp = '<path d="M18 15l-6-6-6 6"/>';
  static const String chevronLeft = '<path d="M15 18l-6-6 6-6"/>';
  static const String edit =
      '<path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/>';
  static const String trash =
      '<path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6"/>';
  static const String clock =
      '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2.5 2.5M9 2h6"/>';
  static const String calendar =
      '<rect x="3" y="5" width="18" height="16" rx="2.4"/><path d="M3 10h18M8 3v4M16 3v4"/>';
  static const String send =
      '<path d="M22 2L11 13"/><path d="M22 2l-7 20-4-9-9-4z"/>';
  static const String upload =
      '<path d="M12 16V4M7 9l5-5 5 5"/><path d="M5 20h14"/>';
  static const String download =
      '<path d="M12 3v12M7 11l5 5 5-5"/><path d="M5 21h14"/>';
  static const String file = '<path d="M6 3h9l5 5v13H6z"/>';
  static const String fileCorner =
      '<path d="M6 3h9l5 5v13H6z"/><path d="M14 3v6h6"/>';
  static const String check = '<path d="M5 12l5 5 9-11"/>';
  static const String info =
      '<circle cx="12" cy="12" r="9"/><path d="M12 8v4M12 16h.01"/>';
  static const String shieldCheck =
      '<path d="M12 3l8 4v5c0 5-3.5 8-8 9-4.5-1-8-4-8-9V7z"/><path d="M9 12l2 2 4-4"/>';
  static const String dragDots =
      '<circle cx="9" cy="6" r="1"/><circle cx="9" cy="12" r="1"/><circle cx="9" cy="18" r="1"/><circle cx="15" cy="6" r="1"/><circle cx="15" cy="12" r="1"/><circle cx="15" cy="18" r="1"/>';
  static const String trendingUp =
      '<path d="M23 6l-9.5 9.5-5-5L1 18"/><path d="M17 6h6v6"/>';
  static const String trendingDown =
      '<path d="M23 18l-9.5-9.5-5 5L1 6"/><path d="M17 18h6v-6"/>';
  static const String message =
      '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>';
  static const String book =
      '<path d="M5 5a2 2 0 0 1 2-2h12v18H7a2 2 0 0 1-2-2z"/><path d="M9 3v18"/>';
  static const String phone =
      '<rect x="5" y="2.5" width="14" height="19" rx="2.5"/>';
  static const String play = '<path d="M8 5v14l11-7z"/>';
}

/// Renders one of the stroke icons above with the exact stroke weight
/// used in the design (default 1.8, buttons use 2.2, checks use 2.4/2.6).
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.paths, {
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.8,
    this.filled = false,
  });

  final String paths;
  final double size;
  final Color color;
  final double strokeWidth;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final String svg = filled
        ? '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" '
            'fill="#000" stroke="none">$paths</svg>'
        : '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" '
            'fill="none" stroke="#000" stroke-width="$strokeWidth" '
            'stroke-linecap="round" stroke-linejoin="round">$paths</svg>';
    return SvgPicture.string(
      svg,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
