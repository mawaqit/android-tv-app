import 'package:flutter/material.dart';
import 'package:mawaqit/src/helpers/RelativeSizes.dart';

class SurahCard extends StatelessWidget {
  final String surahName;
  final int surahNumber;
  final int? verses;
  final bool isSelected;
  final VoidCallback onTap;

  const SurahCard({
    required this.surahName,
    required this.surahNumber,
    required this.isSelected,
    required this.onTap,
    this.verses,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$surahNumber. $surahName',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 2.2.vwr,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              verses == null
                  ? Container()
                  : Text(
                      '$verses verses',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
