import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_theme.dart';
import 'brand.dart';

/// La marca: círculo con la Chi (Χ) dorada.
class TeleiosMark extends StatelessWidget {
  const TeleiosMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/brand/teleios-mark.svg', width: size, height: size, semanticsLabel: 'TELEIOS');
}

/// Texto con el degradado dorado del logo.
class GoldText extends StatelessWidget {
  const GoldText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: Brand.goldGradient.createShader,
    child: Text(text, style: style, textAlign: textAlign),
  );
}

/// "TELEIOS" + "ΤΕΛΕΙΟΣ", como en el logo.
class TeleiosWordmark extends StatelessWidget {
  const TeleiosWordmark({super.key, this.scale = 1});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TELEIOS',
          style: TextStyle(
            fontFamily: Brand.fontUi,
            fontWeight: FontWeight.w700,
            fontSize: 34 * scale,
            letterSpacing: 6 * scale,
            color: onSurface,
          ),
        ),
        SizedBox(height: 2 * scale),
        GoldText(
          'ΤΕΛΕΙΟΣ',
          style: TextStyle(fontFamily: Brand.fontGreek, fontSize: 14 * scale, letterSpacing: 6 * scale),
        ),
      ],
    );
  }
}

/// Logo vertical completo: marca + wordmark (+ lema opcional, Mateo 5:48).
class TeleiosLogo extends StatelessWidget {
  const TeleiosLogo({super.key, this.markSize = 120, this.showMotto = false});

  final double markSize;
  final bool showMotto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TeleiosMark(size: markSize),
        SizedBox(height: markSize * 0.22),
        TeleiosWordmark(scale: markSize / 120),
        if (showMotto) ...[
          const SizedBox(height: 28),
          GoldText(
            Brand.mottoGreek,
            textAlign: TextAlign.center,
            style: context.scripture.greek.copyWith(fontStyle: FontStyle.italic, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Text(
            Brand.mottoSpanish,
            textAlign: TextAlign.center,
            style: context.scripture.body.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              color: theme.colorScheme.primary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Brand.mottoReference,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 2.5,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
