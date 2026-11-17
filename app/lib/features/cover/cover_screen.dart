import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/brand.dart';
import '../../core/theme/teleios_logo.dart';

/// Portada al abrir la app: marca, nombre en griego y el lema (Mateo 5:48).
/// Siempre sobre fondo medianoche, como el logo, sin importar el tema.
class CoverScreen extends StatelessWidget {
  const CoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Brand.midnight,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [Brand.midnightHigh, Brand.midnight, Brand.midnightLowest],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    const TeleiosMark(size: 148),
                    const SizedBox(height: 28),
                    const Text(
                      'TELEIOS',
                      style: TextStyle(
                        fontFamily: Brand.fontUi,
                        fontWeight: FontWeight.w700,
                        fontSize: 38,
                        letterSpacing: 9,
                        color: Brand.cream,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const GoldText(
                      'ΤΕΛΕΙΟΣ',
                      style: TextStyle(fontFamily: Brand.fontGreek, fontSize: 20, letterSpacing: 9),
                    ),
                    const SizedBox(height: 36),
                    const _GoldRule(),
                    const SizedBox(height: 28),
                    // Cada línea del lema entera: se reduce antes que partirse.
                    for (final line in Brand.mottoGreek.split('\n'))
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: GoldText(
                          line,
                          style: const TextStyle(fontFamily: Brand.fontGreek, fontSize: 19, height: 1.6),
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      Brand.mottoSpanish,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Brand.fontScripture,
                        fontStyle: FontStyle.italic,
                        fontSize: 19,
                        height: 1.45,
                        color: Brand.cream.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      Brand.mottoReference,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: Brand.fontUi,
                        fontSize: 11,
                        letterSpacing: 2.5,
                        color: Brand.gold.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _GoldRule(),
                    const SizedBox(height: 40),
                    FilledButton(
                      key: const Key('enter-app'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Brand.gold,
                        foregroundColor: Brand.midnight,
                        minimumSize: const Size(220, 52),
                        textStyle: const TextStyle(
                          fontFamily: Brand.fontUi,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      onPressed: () => context.go(Routes.estudio),
                      child: const Text('ENTRAR'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoldRule extends StatelessWidget {
  const _GoldRule();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(width: 56, height: 1, color: Brand.gold.withValues(alpha: 0.5)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Icon(Icons.circle, size: 5, color: Brand.gold),
      ),
      Container(width: 56, height: 1, color: Brand.gold.withValues(alpha: 0.5)),
    ],
  );
}
