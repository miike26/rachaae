import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui'; // Importado para usar o ImageFilter
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

        // Busca a cor do ícone usando o helper
        final iconColor = CategoryHelper.getIconColor(
          category: racha.category,
          style: settings.cardStyle,
          isLightTheme: isLightTheme,
          useColoredIcons: settings.useColoredIcons,
        );

        if (isDetailedStyle) {
          if (isLightTheme) {
            cardGradient = LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: const [0.0, 1.0],
              colors: [
                AppTheme.lightDetailedCardBg1.withOpacity(0.70),
                AppTheme.lightDetailedCardBg2.withOpacity(0.90)
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
        // Passamos a cor do ícone para ele.
        final cardContent = _buildCardContent(context, textColor, iconColor);

        return GestureDetector(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.translate(
                offset: const Offset(0, -3), // Move o card para cima
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.40),
                        offset: const Offset(0, 0.5),
                        blurRadius: 6.5,
                        spreadRadius: -0.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Constrói o visual do card com fundo todo colorido
  Widget _buildColorfulView(Color backgroundColor, Widget content) {
    return Container(
      color: backgroundColor,
      child: content, // O conteúdo agora inclui o ícone, não precisa mais do Stack aqui
    );
  }

  // Constrói o visual do card com a barra lateral colorida
  Widget _buildDetailedView(Color? backgroundColor, Color categoryColor, Widget content, Gradient? gradient) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
      ),
      child: Row(
        children: [
          Container(
            width: 10, // Largura da barra de categoria
            color: categoryColor,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  // Widget que contém o conteúdo interno do card (textos, avatares, etc.)
  Widget _buildCardContent(BuildContext context, Color textColor, Color iconColor) {
    final double textOpacity = racha.isFinished ? 0.7 : 1.0;
    final double dateOpacity = racha.isFinished ? 0.7 : 0.8;
    final double avatarOpacity = racha.isFinished ? 0.7 : 1.0;

    // Busca o tamanho do ícone usando o helper
    final iconSize = CategoryHelper.getIconSize(racha.category);

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
                    fontSize: 22,
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
                  fontSize: 22,
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
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(dateOpacity),
              letterSpacing: 0.33,
            ),
          ),
          const Spacer(),
          // Row para alinhar avatares e o novo ícone
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Opacity(
                opacity: avatarOpacity,
                child: _buildParticipantAvatars(),
              ),
              // Ícone da categoria com tamanho dinâmico
              SvgPicture.asset(
                CategoryHelper.getImagePath(racha.category),
                width: iconSize.width,  // Usa a largura do helper
                height: iconSize.height, // Usa a altura do helper
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    const maxAvatars = 6;
    final itemsToShow = racha.participants.length > maxAvatars
        ? maxAvatars
        : racha.participants.length;

    if (itemsToShow == 0) {
      return const SizedBox(height: 32);
    }

    // --- CORREÇÃO DO ERRO ---
    // O erro de layout ('size.isFinite') ocorria porque o Stack não tinha
    // uma largura definida, já que todos os seus filhos eram `Positioned`.
    // A solução é calcular a largura exata que o Stack precisa e aplicá-la
    // ao SizedBox que o envolve.
    //
    // O cálculo é: a largura do primeiro avatar (30px) mais o deslocamento
    // dos avatares restantes (23px cada).
    final double containerWidth = itemsToShow > 0 ? 30.0 + (23.0 * (itemsToShow - 1)) : 0.0;

    return SizedBox(
      height: 32,
      width: containerWidth, // Aplicando a largura calculada
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
                left: (index * 23).toDouble(),
                child: CircleAvatar(
                  radius: 15,
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
              left: (index * 23).toDouble(),
              child: CircleAvatar(
                radius: 15,
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
        ).reversed.toList(),
      ),
    );
  }
}
