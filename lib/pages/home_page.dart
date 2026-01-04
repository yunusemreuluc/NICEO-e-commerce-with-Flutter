import 'package:flutter/material.dart';
import '../widgets/category_list.dart';
import '../widgets/discount_carousel.dart';
import '../widgets/featured_products.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [CategoryList(), DiscountCarousel(), FeaturedProducts()],
    );
  }
}
