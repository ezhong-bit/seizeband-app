import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DurationGraph extends StatelessWidget {
  const DurationGraph({super.key});
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Seizure Duration'),
      primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Date')),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Duration (mins)'),
        minimum: 0,
        interval: 1,
        ),
      series: <CartesianSeries>[
        LineSeries<SeizureData, String>(
          dataSource: _getSeizureDurationData(),
          xValueMapper: (SeizureData data, _) => data.date,
          yValueMapper: (SeizureData data, _) => data.duration,
          name: 'Seizure Duration',
          color: Colors.deepPurpleAccent,
          markerSettings:MarkerSettings(isVisible: true),
          animationDuration: 0.0,
        ),
      ],
    );
  }

  List<SeizureData> _getSeizureDurationData() {
    return [
      SeizureData("Aug 7", 2),
      SeizureData("Aug 8", 5),
      SeizureData("Aug 9", 3),
    ];
  }
}

class SeizureData {
  final String date;
  final double duration;

  SeizureData(this.date, this.duration);
}
