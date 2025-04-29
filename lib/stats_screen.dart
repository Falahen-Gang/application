import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Field Stats"),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNPKBarChart(),
            const SizedBox(height: 20),
            _buildInfectionPercentageCard(),
            const SizedBox(height: 20),
            _buildDiseaseChart(),
            const SizedBox(height: 20),
            _buildWeedAmountCard(),
            const SizedBox(height: 20),
            _buildCausesAndPrevention(),
          ],
        ),
      ),
    );
  }

  /// **1️⃣ NPK Sensor Data as Bar Chart**
  Widget _buildNPKBarChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NPK Sensor Data",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _buildBarData(0, 35, 50, Colors.blue, "N"),
                    _buildBarData(1, 18, 30, Colors.red, "P"),
                    _buildBarData(2, 25, 40, Colors.green, "K"),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          List<String> labels = [
                            "Nitrogen",
                            "Phosphorus",
                            "Potassium",
                          ];
                          return Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 14),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "🔵 Normal values: Nitrogen ≤ 50, Phosphorus ≤ 30, Potassium ≤ 40",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarData(
    int x,
    double value,
    double normalValue,
    Color color,
    String label,
  ) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: value, color: color, width: 20),
        BarChartRodData(
          toY: normalValue,
          color: Colors.grey,
          width: 20,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: normalValue,
          ),
        ),
      ],
    );
  }

  /// **2️⃣ Infection Percentage**
  Widget _buildInfectionPercentageCard() {
    double infectionRate = 65; // Example infection percentage

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Infected Area",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "📍 ${infectionRate.toStringAsFixed(1)}% of the land is infected",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: infectionRate / 100,
              color: Colors.red,
              backgroundColor: Colors.grey.shade300,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  /// **3️⃣ Diseases Pie Chart**
  Widget _buildDiseaseChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Disease Distribution",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 40,
                  title: "Fungal",
                  color: Colors.redAccent,
                  radius: 50,
                ),
                PieChartSectionData(
                  value: 30,
                  title: "Bacterial",
                  color: Colors.blueAccent,
                  radius: 50,
                ),
                PieChartSectionData(
                  value: 20,
                  title: "Viral",
                  color: Colors.green,
                  radius: 50,
                ),
                PieChartSectionData(
                  value: 10,
                  title: "Healthy",
                  color: Colors.grey,
                  radius: 50,
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ],
    );
  }

  /// **4️⃣ Weed Amount Progress Bar**
  Widget _buildWeedAmountCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Weed Distribution",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Weed Cover: 60% of the field",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: 0.6,
              color: Colors.red,
              backgroundColor: Colors.grey.shade300,
              minHeight: 10,
            ),
          ],
        ),
      ),
    );
  }

  /// **5️⃣ Causes & Prevention of Diseases**
  Widget _buildCausesAndPrevention() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Causes of Diseases & Prevention",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            Text(
              "🌱 **Fungal Diseases**",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Cause: High humidity, poor ventilation, and excessive watering.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Prevention: Improve air circulation, reduce excess moisture, and apply organic fungicides.",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 10),

            Text(
              "🦠 **Bacterial Infections**",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Cause: Contaminated soil, infected seeds, and improper watering.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Prevention: Use disease-free seeds, disinfect tools, and avoid overwatering.",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 10),

            Text(
              "🦠 **Viral Infections**",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Cause: Spread by insects (aphids, whiteflies) or contaminated tools.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Prevention: Use insect-resistant crops, control pest populations, and sanitize equipment.",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 10),

            Text(
              "🌿 **Weed Growth**",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Cause: Uncontrolled weed spreading and lack of proper maintenance.",
              style: TextStyle(fontSize: 16),
            ),
            Text(
              "Prevention: Regular weeding, using cover crops, and applying mulch.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
