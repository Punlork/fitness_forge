import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {
  final String assetName;
  final double size;
  final Color? color;

  const AppSvgIcon({
    required this.assetName,
    this.size = 24,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ??
        IconTheme.of(context).color ??
        Theme.of(context).iconTheme.color;
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: resolvedColor == null
          ? null
          : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
    );
  }
}
