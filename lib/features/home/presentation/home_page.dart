import 'package:flutter/material.dart';
import '../../../core/constants/color.dart';
import '../../../core/constants/size.dart';
import '../../../core/constants/style.dart';
import 'widgets/home_header.dart';
import 'widgets/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더 섹션
            const HomeHeader(),

            // 컨텐츠 섹션
            const Expanded(
              child: HomeContent(),
            ),
          ],
        ),
      ),
    );
  }
}
