import 'package:clinico/constants/app_colors.dart';
import 'package:loading_indicator/loading_indicator.dart';

LoadingIndicator loadingIndicatorWidget() {
  return const LoadingIndicator(
      indicatorType: Indicator.ballSpinFadeLoader,
      colors: [
        AppColors.secondaryColor1,
        AppColors.secondaryColor2,
        AppColors.secondaryColor3,
        AppColors.secondaryColor4
      ],
      strokeWidth: 2,
      backgroundColor: AppColors.primaryColor,
      pathBackgroundColor: AppColors.primaryColor);
}
