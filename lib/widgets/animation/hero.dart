import 'package:flutter/material.dart';

class CustomHeroController extends HeroController {
  CustomHeroController() : super(createRectTween: (begin, end) {
    return MaterialRectCenterArcTween(begin: begin, end: end);
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 1500); // Tốc độ chậm hơn
}
