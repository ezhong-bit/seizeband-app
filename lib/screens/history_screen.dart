import 'package:flutter/material.dart';
// import 'package:seize_appios/widgets/simple_button.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:seize_appios/widgets/duration_graph.dart';
import 'package:shared_preferences/shared_preferences.dart';
// add http for flask/render server
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
    late TooltipBehavior _tooltipBehavior;
    String? username;
    int timeToMinutes(String timeStr) {
    final parts = timeStr.split(":");
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final usernameFromPrefs = prefs.getString('user_name');
    setState(() {
      username = usernameFromPrefs;
    });
    if (username != null) {
      _loadSeizureData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No username found in preferences.';
      });
    }
  }


    List<SeizureTimeData> seizureData = [];
      
      bool _isLoading = true;
      String? _errorMessage;

    @override
    void initState() {
      super.initState();
      _tooltipBehavior = TooltipBehavior(enable: true);
      _loadUsername();
    }

  Future<void> _loadSeizureData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _fetchSeizureData();
      print("Fetched seizure data: $data");  // debug log
      setState(() {
        seizureData = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading seizure data: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _clearSeizureData() async {
  final url = Uri.parse('https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/api/seizure-events/$username');
  final response = await http.delete(url);
  if (response.statusCode == 200) {
    setState(() {
      seizureData.clear();
    });
  } else {
    throw Exception("Failed to clear seizure data");
  }
}



    Future<List<SeizureTimeData>> _fetchSeizureData() async {
    if (username == null) throw Exception('Username is null');

    final url = Uri.parse(
        'https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/api/seizure-events/$username');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      Map<String, int> countPerDay = {};

      return data.map((event) {
        final timestamp = DateTime.parse(event['timestamp']);
        final dayKey = DateFormat('MMM d').format(timestamp);

        countPerDay[dayKey] = (countPerDay[dayKey] ?? 0) + 1;

        // Create a unique label per seizure on that day:
        final label = '$dayKey-${countPerDay[dayKey]}';

        return SeizureTimeData(timestamp, label);
      }).toList();
    } else {
      throw Exception("Failed to load seizure data");
    }
  }

/*
  List<SeizureTimeData> _getSeizureData(){
    return [
      SeizureTimeData("Aug 7", timeToMinutes("12:00"), timeToMinutes("12:05")),
      SeizureTimeData("Aug 8", timeToMinutes("10:15"), timeToMinutes("10:30")),
      SeizureTimeData("Aug 9", timeToMinutes("15:00"), timeToMinutes("15:15")),
    ];
  }
 */

  String _formatTimeLabel(num value) {
    int minutes = value.toInt();
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    String suffix = hours >= 12 ? 'PM' : 'AM';
    int hour12 = hours % 12 == 0 ? 12 : hours % 12;
    return '$hour12:${mins.toString().padLeft(2, '0')} $suffix';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
            children: [
            Container(
              width: double.infinity,
              height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
              alignment: Alignment.center,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text('Error: $_errorMessage'))
                    : seizureData.isEmpty
                ? const Center(child: Text('No seizure events found.'))
                : SfCartesianChart(
                    title: ChartTitle(text: 'Seizure Time of Day'),
                    primaryXAxis: CategoryAxis(
                      title: AxisTitle(text: 'Date'),
                      labelRotation: 0, // Optional: rotate labels if overlapping
                    ),
                primaryYAxis: NumericAxis(
                  title: AxisTitle(text: 'Time of Day'),
                  minimum: 0,
                  maximum: 1440,
                  interval: 120,
                  isInversed: true,
                  axisLabelFormatter: (args) {
                    return ChartAxisLabel(
                        _formatTimeLabel(args.value), null);
                  },
                ),
                tooltipBehavior: _tooltipBehavior,
                series: <CartesianSeries<SeizureTimeData, String>>[
                  ScatterSeries<SeizureTimeData, String>(
                    dataSource: seizureData,
                    xValueMapper: (data, _) => data.label,
                    yValueMapper: (data, _) =>
                        data.timestamp.hour * 60 + data.timestamp.minute,
                    markerSettings: MarkerSettings(
                        height: 10,
                        width: 10,
                        shape: DataMarkerType.circle),
                    name: 'Seizure Time',
                    color: Colors.deepPurpleAccent,
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      builder: (dynamic data, dynamic point,
                          dynamic series, int pointIndex,
                          int seriesIndex) {
                        return Text(_formatTimeLabel(
                            data.timeOfDayMinutes));
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                _loadSeizureData();
              },
              icon: Icon(Icons.refresh),
              label: Text('Load Time of Day Data'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height:20),

            Container(
              width: double.infinity,
              height:400,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow:[
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(2,2),
                  )
                ]
              ),
              child: DurationGraph(),
            ),

            const SizedBox(height: 16),

/*            SimpleRoundedButton(
              height:80,
              width: double.infinity,
              icon: Icons.access_time_rounded,
              iconSize:40,
              fontSize:18,
              label: '  Average Seizure Length',
              onTap: () {}
                ),
*/             ],
            ),
          )
        ),
      ),
    );
  }
}

class SeizureTimeData {
  final DateTime timestamp;
  final String label;  // unique label for x-axis

  SeizureTimeData(this.timestamp, this.label);

  int get timeOfDayMinutes => timestamp.hour * 60 + timestamp.minute;
}
