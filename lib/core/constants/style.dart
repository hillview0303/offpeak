import 'package:flutter/material.dart';
import 'color.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String pretendard = 'Pretendard';
  static const String nanumNeo = 'NanumNeo';

  // 폰트사이즈
  static const double fontSizeXS = 10.0;
  static const double fontSizeSM = 12.0;
  static const double fontSizeMD = 14.0;
  static const double fontSizeLG = 16.0;
  static const double fontSizeXL = 18.0;
  static const double fontSizeXXL = 20.0;
  static const double fontSizeTitle = 24.0;
  static const double fontSizeHeading = 28.0;

  // 굵기
  static const FontWeight thin = FontWeight.w100;
  static const FontWeight extraLight = FontWeight.w200;
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;

  static const TextStyle h1 = TextStyle(
    fontSize: fontSizeHeading,
    fontWeight: bold,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: semiBold,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontSizeXXL,
    fontWeight: semiBold,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text Styles (Pretendard 사용 - 본문용)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textSecondary,
    height: 1.4,
  );

 // 버튼용
  static const TextStyle buttonLarge = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.white,
    letterSpacing: 0.2,
  );

  // Label & Caption Styles (Pretendard 사용)
  static const TextStyle label = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: semiBold,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textSecondary,
  );

  static const TextStyle overline = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  // Special Text Styles
  static const TextStyle link = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.primary,
    decoration: TextDecoration.underline,
  );

  static const TextStyle error = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.error,
  );

  static const TextStyle success = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.success,
  );

  static const TextStyle warning = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.warning,
  );

  static const TextStyle hint = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textHint,
  );

  // 강조
  static const TextStyle appBarTitle = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  // 탭
  static const TextStyle tabActive = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );

  static const TextStyle tabInactive = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: regular,
    fontFamily: nanumNeo,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  // 인풋필드
  static const TextStyle inputText = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: regular,
    fontFamily: pretendard,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputLabel = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: medium,
    fontFamily: pretendard,
    color: AppColors.textSecondary,
  );

  // 숫자
  static const TextStyle numberLarge = TextStyle(
    fontSize: fontSizeTitle,
    fontWeight: bold,
    fontFamily: nanumNeo,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberMedium = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: semiBold,
    fontFamily: nanumNeo,
    color: AppColors.textPrimary,
  );

  static const TextStyle numberSmall = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: medium,
    fontFamily: nanumNeo,
    color: AppColors.textPrimary,
  );
}
