import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({super.key, required this.positifCount, required this.negatifCount});

  final int positifCount;
  final int negatifCount;

  @override
  Widget build(BuildContext context) {
    return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Color(0xffF5F5F5),
                ),
                height: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('Positif :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(positifCount.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text('Negatif :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              Text(negatifCount.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 2,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: positifCount.toDouble(),
                                color: Colors.red,
                                title: '75%',
                                radius: 60,
                              ),
                              PieChartSectionData(
                                value: negatifCount.toDouble(),
                                color: Colors.green,
                                title: '75%',
                                radius: 60,
                              ),
                            ],
                            sectionsSpace: 2,
                            centerSpaceRadius: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
  }
}