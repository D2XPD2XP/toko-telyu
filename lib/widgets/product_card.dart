import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:toko_telyu/models/Product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 2,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image(
                  image: AssetImage('assets/seragam_merah_telkom.png'),
                  width: 200,
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(Symbols.heart_plus, color: Colors.grey[900]),
                ),
              ],
            ),
            Text('Ini Kategori',),
            Text('Ini Nama Prduk'),
            Text('Ini Harga'),
          ],
        ),
      ),
    );
  }
}
