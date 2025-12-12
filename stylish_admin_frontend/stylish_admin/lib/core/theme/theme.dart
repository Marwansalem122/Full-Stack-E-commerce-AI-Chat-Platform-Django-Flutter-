import 'package:flutter/material.dart';

class AppTheme {
  // Primary Color Palette - Refined for fashion retail
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color primaryMedium = Color(0xFF16213E);
  static const Color primaryLight = Color(0xFF0F3460);

  // New sophistication colors
  static const Color richNavy = Color(0xFF0A1128);
  static const Color midnightBlue = Color(0xFF001F54);
  static const Color cobaltBlue = Color(0xFF034078);

  // Accent Colors - Fashion-forward palette
  static const Color accentPink = Color(0xFFFF6B6B);
  static const Color accentMauve = Color(0xFFD48EAD);
  static const Color accentIvory = Color(0xFFF9F7F7);
  static const Color accentGold = Color(0xFFDDA15E);
  static const Color accentSilver = Color(0xFFBEC5AD);
  static const Color accentEmerald = Color(0xFF2A9D8F);

  static const Color accentBlue = Color(0xFF4EA8DE);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9F1C);
  static const Color accentPurple = Color(0xFF9381FF);
  static const Color accentRed = Color(0xFFE71D36);
  static const Color accentAmber = Color(0xFFFFBF69);

  // Main theme colors
  static const Color primary = Color(0xFF0F3460);
  static const Color secondary = Color(0xFFE94560);
  static const Color background = Color(0xFF16213E);

  // Status colors - Enhanced for better readability
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF8BC34A);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFFF5722);
  static const Color info = Color(0xFF03A9F4);

  // Background Colors
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color backgroundMedium = Color(0xFF16213E);
  static const Color cardBackground = Color(
    0xFF1D2951,
  ); // Slightly lighter for better contrast

  // Text Colors - Refined for fashion readability
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(
    0xFFE0E0E0,
  ); // Lighter for better readability
  static const Color textMuted = Color(0xFFADADAD); // Softer muted color
  static const Color textTertiary =
      Colors.white70; // Increased opacity for better readability
  static const Color textAccent = Color(0xFFFFD700); // Gold for emphasis

  // Border & Divider Colors
  static Color borderColor = const Color(0xFF1C3879);
  static Color dividerColor = Colors.grey.shade700;

  // Chart Colors - Fashion-forward palette
  static Color chartBlue = Color(0xFF4EA8DE);
  static Color chartGreen = Color(0xFF2A9D8F);
  static Color chartPurple = Color(0xFF9381FF);
  static Color chartRed = Color(0xFFE71D36);
  static Color chartYellow = Color(0xFFFFBF69);
  static Color chartPink = Color(0xFFFF6B6B);

  // Status Colors
  static const Color positive = Color(0xFF4CAF50);
  static const Color negative = Color(0xFFE71D36);
  static const Color neutral = Color(0xFFBEC5AD);

  // Gradients - More elegant and fashion-forward
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE94560), Color(0xFFE71D36)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDDA15E), Color(0xFFBC6C25)],
  );

  static const LinearGradient chartBlueGradient = LinearGradient(
    colors: [Color(0xFF4EA8DE), Color(0x004EA8DE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Font Sizes - Adjusted for cleaner hierarchy
  static const double fontSizeXXSmall = 10.0;
  static const double fontSizeXSmall = 12.0;
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 22.0;
  static const double fontSizeXXLarge = 28.0;
  static const double fontSizeHuge = 36.0;

  static InputDecorationTheme textFieldDecorationTheme() {
    return InputDecorationTheme(
      // More elegant, fashion-forward styling
      fillColor: primaryLight.withAlpha((0.15 * 255).round()),
      filled: true,

      // Customize border styles
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: primaryLight.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: primaryLight.withAlpha((0.3 * 255).round()),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(
          color: accentGold.withAlpha((0.7 * 255).round()),
          width: 2,
        ),
      ),

      // Error state styling
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusMedium),
        borderSide: BorderSide(color: accentRed, width: 1),
      ),

      // Text and hint styling
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      labelStyle: bodyMedium().copyWith(color: textSecondary),
      hintStyle: bodyMedium().copyWith(color: textMuted),
      helperStyle: bodySmall().copyWith(color: textMuted),
      errorStyle: bodySmall().copyWith(color: accentRed),
    );
  }

  // Text Styles with Google Fonts
  static TextStyle headingHuge() {
    return const TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: fontSizeHuge,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headingLarge() {
    return const TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: fontSizeXXLarge,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headingMedium() {
    return const TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: fontSizeXLarge,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    );
  }

  static TextStyle subheading() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeLarge,
      fontWeight: FontWeight.w600,
      color: textPrimary,
      letterSpacing: 0.5,
    );
  }

  static TextStyle bodyLarge() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeMedium,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    );
  }

  static TextStyle bodyMedium() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeSmall,
      fontWeight: FontWeight.w400,
      color: textPrimary,
      height: 1.5,
    );
  }

  static TextStyle bodySmall() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXSmall,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    );
  }

  static TextStyle bodyXSmall() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXXSmall,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.4,
    );
  }

  static TextStyle buttonText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeSmall,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: textPrimary,
    );
  }

  static TextStyle valueText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXLarge,
      fontWeight: FontWeight.bold,
      color: textPrimary,
    );
  }

  static TextStyle labelText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXSmall,
      fontWeight: FontWeight.w600,
      color: textSecondary,
      letterSpacing: 0.5,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  static TextStyle highlightText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeMedium,
      fontWeight: FontWeight.w600,
      color: accentGold,
      letterSpacing: 0.5,
    );
  }

  // Border Radius - More refined for fashion aesthetics
  static const double borderRadiusXSmall = 4.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircular = 100.0;

  // Spacing - More options for precise layouts
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;

  // Elevation levels
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Card Styles - More elegant for fashion
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha((0.2 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration premiumCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    border: Border.all(
      color: accentGold.withAlpha((0.3 * 255).round()),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: accentGold.withAlpha((0.15 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration statsCardDecoration = BoxDecoration(
    color: primaryLight.withAlpha((0.15 * 255).round()),
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    border: Border.all(color: primaryLight.withAlpha((0.3 * 255).round())),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha((0.1 * 255).round()),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // Chip Styles - More fashion-forward
  static BoxDecoration selectedChipDecoration = BoxDecoration(
    color: accentGold.withAlpha((0.2 * 255).round()),
    borderRadius: BorderRadius.circular(borderRadiusCircular),
    border: Border.all(color: accentGold),
  );

  static BoxDecoration unselectedChipDecoration = BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(borderRadiusCircular),
    border: Border.all(color: dividerColor),
  );

  // Product card styles
  static BoxDecoration productCardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha((0.1 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Badge styles
  static BoxDecoration badgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withAlpha((0.2 * 255).round()),
      borderRadius: BorderRadius.circular(borderRadiusCircular),
      border: Border.all(color: color.withAlpha((0.5 * 255).round())),
    );
  }

  // Icon Containers
  static BoxDecoration iconContainerDecoration(Color color) {
    return BoxDecoration(
      color: color.withAlpha((0.15 * 255).round()),
      shape: BoxShape.circle,
      border: Border.all(color: color.withAlpha((0.3 * 255).round()), width: 1),
    );
  }

  // ThemeData for MaterialApp
  static ThemeData buildThemeData() {
    return ThemeData(
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: primaryLight,
      canvasColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: accentGold,
        tertiary: accentPink,
        surface: cardBackground,
        error: accentRed,
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          elevation: elevationLow,
          textStyle: buttonText(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentGold,
          side: BorderSide(color: accentGold, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: buttonText(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: buttonText(),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: bodyMedium(),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(cardBackground),
          elevation: WidgetStateProperty.all(elevationMedium),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadiusMedium),
            ),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: cardBackground,
        elevation: elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
        textStyle: bodyMedium(),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingMedium,
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingMedium(),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: primaryMedium,
          borderRadius: BorderRadius.circular(borderRadiusSmall),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: bodySmall(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primaryLight.withAlpha((0.15 * 255).round()),
        disabledColor: Colors.grey.shade800,
        selectedColor: accentGold.withAlpha((0.2 * 255).round()),
        secondarySelectedColor: accentGold.withAlpha((0.2 * 255).round()),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: bodySmall(),
        secondaryLabelStyle: bodySmall().copyWith(color: accentGold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusCircular),
          side: BorderSide(color: dividerColor),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: accentGold,
        labelColor: accentGold,
        unselectedLabelColor: textSecondary,
        labelStyle: bodyMedium().copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: bodyMedium(),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold;
          }
          return Colors.grey.shade400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold.withAlpha((0.3 * 255).round());
          }
          return Colors.grey.shade700;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXSmall),
        ),
        side: BorderSide(color: dividerColor, width: 1.5),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold;
          }
          return dividerColor;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentGold,
        linearTrackColor: dividerColor,
        circularTrackColor: dividerColor,
      ),
      fontFamily: 'Poppins',
      textTheme: TextTheme(
        displayLarge: _addNotoEmojiFallback(headingHuge()),
        displayMedium: _addNotoEmojiFallback(headingLarge()),
        displaySmall: _addNotoEmojiFallback(headingMedium()),
        headlineMedium: _addNotoEmojiFallback(subheading()),
        titleLarge: _addNotoEmojiFallback(
          bodyLarge().copyWith(fontWeight: FontWeight.w600),
        ),
        titleMedium: _addNotoEmojiFallback(
          bodyMedium().copyWith(fontWeight: FontWeight.w600),
        ),
        titleSmall: _addNotoEmojiFallback(
          bodySmall().copyWith(fontWeight: FontWeight.w600),
        ),
        bodyLarge: _addNotoEmojiFallback(bodyLarge()),
        bodyMedium: _addNotoEmojiFallback(bodyMedium()),
        bodySmall: _addNotoEmojiFallback(bodySmall()),
        labelLarge: _addNotoEmojiFallback(buttonText()),
        labelMedium: _addNotoEmojiFallback(labelText()),
        labelSmall: _addNotoEmojiFallback(bodyXSmall()),
      ),

      inputDecorationTheme: textFieldDecorationTheme(),

      // Text selection theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accentGold,
        selectionColor: accentGold.withAlpha((0.3 * 255).round()),
        selectionHandleColor: accentGold,
      ),

      // Scrollbar theme
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.all(6),
        thumbColor: WidgetStateProperty.all(
          primaryLight.withAlpha((0.5 * 255).round()),
        ),
        radius: const Radius.circular(10),
        minThumbLength: 80,
      ),

      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: accentGold,
        inactiveTrackColor: dividerColor,
        thumbColor: accentGold,
        overlayColor: accentGold.withAlpha((0.2 * 255).round()),
        valueIndicatorColor: primaryMedium,
        valueIndicatorTextStyle: bodySmall(),
      ),

      // Date picker theme
      datePickerTheme: DatePickerThemeData(
        backgroundColor: cardBackground,
        headerBackgroundColor: primaryLight,
        headerForegroundColor: textPrimary,
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold;
          }
          return Colors.transparent;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return textPrimary;
        }),
        todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
        todayForegroundColor: WidgetStateProperty.all(accentGold),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentGold;
          }
          return Colors.transparent;
        }),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryDark;
          }
          return textPrimary;
        }),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
    );
  }

  // Fashion-specific theme components
  static BoxDecoration fashionCategoryDecoration(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withAlpha((0.7 * 255).round()),
          color.withAlpha((0.3 * 255).round()),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadiusLarge),
      boxShadow: [
        BoxShadow(
          color: color.withAlpha((0.2 * 255).round()),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration productImageDecoration = BoxDecoration(
    color: backgroundMedium,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
  );
  static BoxDecoration seasonalTagDecoration(Color color) {
    return BoxDecoration(
      color: color.withAlpha((0.2 * 255).round()),
      borderRadius: BorderRadius.circular(borderRadiusXSmall),
      border: Border.all(color: color),
    );
  }

  static BoxDecoration trendingItemDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(borderRadiusLarge),
    boxShadow: [
      BoxShadow(
        color: accentGold.withAlpha((0.1 * 255).round()),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: accentGold.withAlpha((0.3 * 255).round()),
      width: 1,
    ),
  );
  static BoxDecoration discountBadgeDecoration = BoxDecoration(
    color: accentRed,
    borderRadius: BorderRadius.circular(borderRadiusCircular),
  );
  static TextStyle discountBadgeText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXXSmall,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  static TextStyle productPriceText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeMedium,
      fontWeight: FontWeight.bold,
      color: accentGold,
    );
  }

  static TextStyle productOldPriceText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXSmall,
      fontWeight: FontWeight.normal,
      color: textMuted,
      decoration: TextDecoration.lineThrough,
    );
  }

  static TextStyle categoryTitleText() {
    return const TextStyle(
      fontFamily: 'PlayfairDisplay',
      fontSize: fontSizeLarge,
      fontWeight: FontWeight.bold,
      color: textPrimary,
      letterSpacing: 0.5,
    );
  }

  static TextStyle brandNameText() {
    return const TextStyle(
      fontFamily: 'Poppins',
      fontSize: fontSizeXSmall,
      fontWeight: FontWeight.w600,
      color: textSecondary,
      letterSpacing: 1,
      textBaseline: TextBaseline.alphabetic,
    );
  }

  // Emoji fallback
  static TextStyle _addNotoEmojiFallback(TextStyle baseStyle) {
    return baseStyle.copyWith(
      fontFamilyFallback: ['NotoColorEmoji', 'NotoSans'],
    );
  }
}
