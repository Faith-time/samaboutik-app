import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/vente.dart';

/// Courbe douce des ventes (utilisée dans la carte bleue et dans « Mes ventes »).
class CourbeVentes extends StatelessWidget {
  final List<PointSerie> points;
  final Color couleur;
  final double hauteur;
  final bool afficherPoints;

  const CourbeVentes({
    super.key,
    required this.points,
    this.couleur = Colors.white,
    this.hauteur = 70,
    this.afficherPoints = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return SizedBox(height: hauteur);
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i++)
        FlSpot(i.toDouble(), points[i].totalFcfa.toDouble()),
    ];
    final maxY = spots.map((s) => s.y).reduce(math.max);

    return SizedBox(
      height: hauteur,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: couleur,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: afficherPoints),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    couleur.withValues(alpha: 0.25),
                    couleur.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
