import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/racha_model.dart';
import '../services/settings_service.dart';
import '../utils/app_theme.dart';
import '../utils/category_helper.dart';
import '../utils/color_helper.dart';

class RachaCard extends StatelessWidget {
  final Racha racha;
  final VoidCallback onTap;

  const RachaCard({
    super.key,
    required this.racha,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usa um Consumer para reconstruir o card quando as configurações mudarem.
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        final isDetailedStyle = settings.cardStyle == CardStyle.detailed;
        final categoryColor = CategoryHelper.getColor(racha.category);
        final isLightTheme = Theme.of(context).brightness == Brightness.light;

        // Define as cores com base no estilo do card e no tema do app
        Color? cardBackgroundColor;
        final Color textColor;
        Gradient? cardGradient;

        if (isDetailedStyle) {
          if (isLightTheme) {
            // CORREÇÃO: Removida a linha que definia a cor de fundo como transparente.
            // Agora apenas o gradiente será responsável pelo fundo.
            cardGradient = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 1.0],
              colors: [
                AppTheme.lightDetailedCardBg1.withOpacity(0.30),
                AppTheme.lightDetailedCardBg2.withOpacity(0.80)
              ],
            );
            textColor = AppTheme.lightTextColor;
          } else {
            cardBackgroundColor = const Color(0xFF323645);
            cardGradient = null;
            textColor = Colors.white;
          }
        } else {
          cardBackgroundColor = categoryColor;
          cardGradient = null;
          textColor = isLightTheme ? const Color(0xFF303030) : const Color(0xFF222531);
        }

        // O conteúdo do card é extraído para um widget separado para evitar repetição.
        final cardContent = _buildCardContent(context, textColor);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  offset: const Offset(0, 10),
                  blurRadius: 2.93,
                  spreadRadius: 0.0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SizedBox(
                height: 140.0,
                child: isDetailedStyle
                    ? _buildDetailedView(cardBackgroundColor, categoryColor, cardContent, cardGradient)
                    : _buildColorfulView(cardBackgroundColor!, cardContent),
              ),
            ),
          ),
        );
      },
    );
  }

  // Constrói o visual do card com fundo todo colorido
  Widget _buildColorfulView(Color backgroundColor, Widget content) {
    final svgColor = CategoryHelper.getSvgColor(racha.category);
    final double svgOpacity = racha.isFinished ? 0.5 : 1.0;

    return Container(
      color: backgroundColor,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (racha.category != RachaCategory.outros)
            Positioned(
              bottom: -7,
              right: 5,
              child: Opacity(
                opacity: svgOpacity,
                child: Transform.rotate(
                  angle: -13.00 * math.pi / 180,
                  child: SvgPicture.asset(
                    CategoryHelper.getImagePath(racha.category),
                    width: 120,
                    height: 95.07,
                    colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
                  ),
                ),
              ),
            ),
          content,
        ],
      ),
    );
  }

  // Constrói o visual do card com a barra lateral colorida
  Widget _buildDetailedView(Color? backgroundColor, Color categoryColor, Widget content, Gradient? gradient) {
    final double svgOpacity = racha.isFinished ? 0.5 : 1.0;
    final bool isLightTheme = gradient != null;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Camada de fundo com a barra lateral e o conteúdo
          Row(
            children: [
              Container(
                width: 15, // Largura da barra de categoria
                color: categoryColor,
              ),
              Expanded(child: content),
            ],
          ),
          // Camada de cima: Marca d'água SVG
          if (racha.category != RachaCategory.outros)
            Positioned(
              bottom: -11,
              right: 5,
              child: Opacity(
                // Aplica 80% de opacidade, e também a opacidade de 'finalizado' se aplicável.
                opacity: svgOpacity * (isLightTheme ? 0.15 : 0.4),
                child: Transform.rotate(
                  angle: -13.00 * math.pi / 180,
                  child: SvgPicture.asset(
                    CategoryHelper.getImagePath(racha.category),
                    width: 120,
                    height: 95.07,
                    colorFilter: ColorFilter.mode(
                      isLightTheme ? AppTheme.lightTextColor : Colors.white, // Cor branca para o SVG
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget que contém o conteúdo interno do card (textos, avatares, etc.)
  Widget _buildCardContent(BuildContext context, Color textColor) {
    final double textOpacity = racha.isFinished ? 0.7 : 1.0;
    final double dateOpacity = racha.isFinished ? 0.7 : 0.8;
    final double avatarOpacity = racha.isFinished ? 0.7 : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  racha.title,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(textOpacity),
                    letterSpacing: 0.1,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'R\$ ${racha.totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: textColor.withOpacity(textOpacity),
                  letterSpacing: -0.33,
                ),
              ),
            ],
          ),
          const SizedBox(height: 1.0),
          Text(
            racha.date,
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(dateOpacity),
              letterSpacing: 0.33,
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: avatarOpacity,
            child: _buildParticipantAvatars(),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    const maxAvatars = 5;
    final itemsToShow = racha.participants.length > maxAvatars
        ? maxAvatars
        : racha.participants.length;

    if (itemsToShow == 0) {
      return const SizedBox(height: 32);
    }

    return SizedBox(
      height: 32,
      child: Stack(
        children: List.generate(
          itemsToShow,
          (index) {
            final participant = racha.participants[index];
            final name = participant.displayName;
            final photoURL = participant.photoURL;

            if (index == maxAvatars - 1 &&
                racha.participants.length > maxAvatars) {
              return Positioned(
                left: (index * 24).toDouble(),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  child: Text(
                      '+${racha.participants.length - (maxAvatars - 1)}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                ),
              );
            }

            return Positioned(
              left: (index * 24).toDouble(),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: ColorHelper.getColorForName(name),
                backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                    ? NetworkImage(photoURL)
                    : null,
                child: (photoURL == null || photoURL.isEmpty)
                    ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
