import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:gsform/gsform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GSForm Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US'), Locale('fa', 'IR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // Customize form field appearance via inputDecorationTheme
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: false,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        // Customize form field appearance via inputDecorationTheme
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: false,
        ),
      ),
      home: MainTestPage(
        currentThemeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class MainTestPage extends StatelessWidget {
  const MainTestPage({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GSForm Example'),
          actions: [
            PopupMenuButton<ThemeMode>(
              icon: Icon(
                currentThemeMode == ThemeMode.light
                    ? Icons.light_mode
                    : currentThemeMode == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.brightness_auto,
              ),
              tooltip: 'Change theme',
              onSelected: onThemeModeChanged,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_auto),
                      const SizedBox(width: 12),
                      const Text('System'),
                      if (currentThemeMode == ThemeMode.system) ...[
                        const Spacer(),
                        Icon(Icons.check, color: theme.colorScheme.primary),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Row(
                    children: [
                      const Icon(Icons.light_mode),
                      const SizedBox(width: 12),
                      const Text('Light'),
                      if (currentThemeMode == ThemeMode.light) ...[
                        const Spacer(),
                        Icon(Icons.check, color: theme.colorScheme.primary),
                      ],
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Row(
                    children: [
                      const Icon(Icons.dark_mode),
                      const SizedBox(width: 12),
                      const Text('Dark'),
                      if (currentThemeMode == ThemeMode.dark) ...[
                        const Spacer(),
                        Icon(Icons.check, color: theme.colorScheme.primary),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'GSForm Demo',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A Material Design form library',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MultiSectionForm()),
                  );
                },
                icon: const Icon(Icons.view_list),
                label: const Text('Multi-Section Form'),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SingleSectionForm()),
                  );
                },
                icon: const Icon(Icons.article),
                label: const Text('Single-Section Form'),
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.palette,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Theming',
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Forms automatically inherit styling from ThemeData. '
                        'Use the menu above to toggle themes. '
                        'Customize via inputDecorationTheme, cardTheme, and textTheme.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleSectionForm extends StatefulWidget {
  const SingleSectionForm({super.key});

  @override
  State<SingleSectionForm> createState() => _SingleSectionFormState();
}

class _SingleSectionFormState extends State<SingleSectionForm> {
  late GSForm form;
  int selectedSpinnerId = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Section Form'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: form = GSForm.singleSection(
                  context,
                  fields: [
                    GSField.email(
                      tag: 'email',
                      title: 'Email',
                      weight: 12,
                      required: true,
                      maxLength: 100,
                      errorMessage: 'Please enter a valid email',
                      value: 'example@test.com',
                    ),
                    GSField.text(
                      tag: 'name',
                      title: 'Full Name',
                      weight: 12,
                      required: true,
                      errorMessage: 'Name is required',
                    ),
                    GSField.spinner(
                      tag: 'category',
                      required: false,
                      weight: 12,
                      title: 'Category',
                      onChange: (model) {
                        if (model != null) {
                          selectedSpinnerId = model.id;
                          setState(() {});
                        }
                      },
                      items: [
                        SpinnerDataModel(name: 'Option 1', id: 0),
                        SpinnerDataModel(name: 'Option 2', id: 1),
                        SpinnerDataModel(name: 'Option 3', id: 2),
                      ],
                    ),
                    GSField.spinner(
                      tag: 'subcategory',
                      required: false,
                      weight: 6,
                      title: 'Subcategory',
                      onChange: (model) {},
                      items: [
                        SpinnerDataModel(name: 'Sub A', id: 0, isSelected: selectedSpinnerId == 0),
                        SpinnerDataModel(name: 'Sub B', id: 1, isSelected: selectedSpinnerId == 1),
                        SpinnerDataModel(name: 'Sub C', id: 2, isSelected: selectedSpinnerId == 2),
                      ],
                    ),
                    GSField.mobile(
                      tag: 'phone',
                      title: 'Phone',
                      maxLength: 11,
                      weight: 6,
                      required: false,
                      helpMessage: 'Enter phone number',
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: _onSubmit,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Submit'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    final isValid = form.isValid();
    final data = form.onSubmit();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isValid ? 'Form Valid' : 'Form Invalid'),
        content: Text('Data: $data'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class MultiSectionForm extends StatefulWidget {
  const MultiSectionForm({super.key});

  @override
  State<MultiSectionForm> createState() => _MultiSectionFormState();
}

class _MultiSectionFormState extends State<MultiSectionForm> {
  late GSForm form;
  Uint8List? _sampleBackgroundImage;

  @override
  void initState() {
    super.initState();
    _generateSampleImage();
  }

  Future<void> _generateSampleImage() async {
    // Create a simple sample image to demonstrate scribble-on-image
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const width = 400.0;
    const height = 200.0;

    // Draw a light gray background with grid lines
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 1;
    for (double x = 0; x <= width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }
    for (double y = 0; y <= height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw "SAMPLE DOCUMENT" text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SAMPLE DOCUMENT',
        style: TextStyle(
          color: Color(0xFFBDBDBD),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((width - textPainter.width) / 2, (height - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (mounted && byteData != null) {
      setState(() {
        _sampleBackgroundImage = byteData.buffer.asUint8List();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Section Form'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                child: form = GSForm.multiSection(
                  context,
                  sections: [
                    GSSection(
                      sectionTitle: "Risk Matrix",
                      fields: [
                        GSField.matrix(
                          tag: 'risk_matrix',
                          title: 'Risk Assessment Matrix',
                          required: true,
                          errorMessage: 'Please select a risk level',
                          severityLabel: 'Severity',
                          severityDescription: 'How severely could it hurt someone or how ill could it make someone',
                          likelihoodLabel: 'Likelihood',
                          likelihoodDescription: 'How likely is it that someone could be harmed',
                          matrixCells: [
                            // 4x4 test matrix
                            // Column 1 (Minor)
                            {'xid': 1, 'yid': 1, 'xyId': 101, 'x': 'Minor', 'y': 'Rare', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '1'},
                            {'xid': 1, 'yid': 2, 'xyId': 102, 'x': 'Minor', 'y': 'Unlikely', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '2'},
                            {'xid': 1, 'yid': 3, 'xyId': 103, 'x': 'Minor', 'y': 'Possible', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '3'},
                            {'xid': 1, 'yid': 4, 'xyId': 104, 'x': 'Minor', 'y': 'Likely', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '4'},
                            // Column 2 (Moderate)
                            {'xid': 2, 'yid': 1, 'xyId': 201, 'x': 'Moderate', 'y': 'Rare', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '2'},
                            {'xid': 2, 'yid': 2, 'xyId': 202, 'x': 'Moderate', 'y': 'Unlikely', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '4'},
                            {'xid': 2, 'yid': 3, 'xyId': 203, 'x': 'Moderate', 'y': 'Possible', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '6'},
                            {'xid': 2, 'yid': 4, 'xyId': 204, 'x': 'Moderate', 'y': 'Likely', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '8'},
                            // Column 3 (Major)
                            {'xid': 3, 'yid': 1, 'xyId': 301, 'x': 'Major', 'y': 'Rare', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '3'},
                            {'xid': 3, 'yid': 2, 'xyId': 302, 'x': 'Major', 'y': 'Unlikely', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '6'},
                            {'xid': 3, 'yid': 3, 'xyId': 303, 'x': 'Major', 'y': 'Possible', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '9'},
                            {'xid': 3, 'yid': 4, 'xyId': 304, 'x': 'Major', 'y': 'Likely', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '12'},
                            // Column 4 (Catastrophic)
                            {'xid': 4, 'yid': 1, 'xyId': 401, 'x': 'Catastrophic', 'y': 'Rare', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '4'},
                            {'xid': 4, 'yid': 2, 'xyId': 402, 'x': 'Catastrophic', 'y': 'Unlikely', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '8'},
                            {'xid': 4, 'yid': 3, 'xyId': 403, 'x': 'Catastrophic', 'y': 'Possible', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '12'},
                            {'xid': 4, 'yid': 4, 'xyId': 404, 'x': 'Catastrophic', 'y': 'Likely', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '16'},
                          ],
                          onCellSelected: (xid, yid, xyId, score) {
                            debugPrint('Risk Matrix Selected: xid=$xid, yid=$yid, xyId=$xyId, score=$score');
                          },
                        ),
                      ],
                    ),
                    GSSection(
                      sectionTitle: "Wide Risk Matrix (Scrollable)",
                      fields: [
                        GSField.matrix(
                          tag: 'risk_matrix_wide',
                          title: 'Extended Risk Assessment',
                          helpMessage: 'Scroll horizontally to see all columns',
                          required: false,
                          severityLabel: 'Consequence',
                          likelihoodLabel: 'Probability',
                          matrixCells: [
                            // 6 columns x 5 rows = 30 cells
                            // Column 1 (Negligible)
                            {'xid': 1, 'yid': 1, 'xyId': 1001, 'x': 'Negligible', 'y': 'Almost Certain', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '5'},
                            {'xid': 1, 'yid': 2, 'xyId': 1002, 'x': 'Negligible', 'y': 'Likely', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '4'},
                            {'xid': 1, 'yid': 3, 'xyId': 1003, 'x': 'Negligible', 'y': 'Possible', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '3'},
                            {'xid': 1, 'yid': 4, 'xyId': 1004, 'x': 'Negligible', 'y': 'Unlikely', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '2'},
                            {'xid': 1, 'yid': 5, 'xyId': 1005, 'x': 'Negligible', 'y': 'Rare', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '1'},
                            // Column 2 (Minor)
                            {'xid': 2, 'yid': 1, 'xyId': 2001, 'x': 'Minor', 'y': 'Almost Certain', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '10'},
                            {'xid': 2, 'yid': 2, 'xyId': 2002, 'x': 'Minor', 'y': 'Likely', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '8'},
                            {'xid': 2, 'yid': 3, 'xyId': 2003, 'x': 'Minor', 'y': 'Possible', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '6'},
                            {'xid': 2, 'yid': 4, 'xyId': 2004, 'x': 'Minor', 'y': 'Unlikely', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '4'},
                            {'xid': 2, 'yid': 5, 'xyId': 2005, 'x': 'Minor', 'y': 'Rare', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '2'},
                            // Column 3 (Moderate)
                            {'xid': 3, 'yid': 1, 'xyId': 3001, 'x': 'Moderate', 'y': 'Almost Certain', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '15'},
                            {'xid': 3, 'yid': 2, 'xyId': 3002, 'x': 'Moderate', 'y': 'Likely', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '12'},
                            {'xid': 3, 'yid': 3, 'xyId': 3003, 'x': 'Moderate', 'y': 'Possible', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '9'},
                            {'xid': 3, 'yid': 4, 'xyId': 3004, 'x': 'Moderate', 'y': 'Unlikely', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '6'},
                            {'xid': 3, 'yid': 5, 'xyId': 3005, 'x': 'Moderate', 'y': 'Rare', 'xyName': 'Low', 'xyColor': '#42994b', 'xy': '3'},
                            // Column 4 (Major)
                            {'xid': 4, 'yid': 1, 'xyId': 4001, 'x': 'Major', 'y': 'Almost Certain', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '20'},
                            {'xid': 4, 'yid': 2, 'xyId': 4002, 'x': 'Major', 'y': 'Likely', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '16'},
                            {'xid': 4, 'yid': 3, 'xyId': 4003, 'x': 'Major', 'y': 'Possible', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '12'},
                            {'xid': 4, 'yid': 4, 'xyId': 4004, 'x': 'Major', 'y': 'Unlikely', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '8'},
                            {'xid': 4, 'yid': 5, 'xyId': 4005, 'x': 'Major', 'y': 'Rare', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '4'},
                            // Column 5 (Severe)
                            {'xid': 5, 'yid': 1, 'xyId': 5001, 'x': 'Severe', 'y': 'Almost Certain', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '25'},
                            {'xid': 5, 'yid': 2, 'xyId': 5002, 'x': 'Severe', 'y': 'Likely', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '20'},
                            {'xid': 5, 'yid': 3, 'xyId': 5003, 'x': 'Severe', 'y': 'Possible', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '15'},
                            {'xid': 5, 'yid': 4, 'xyId': 5004, 'x': 'Severe', 'y': 'Unlikely', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '10'},
                            {'xid': 5, 'yid': 5, 'xyId': 5005, 'x': 'Severe', 'y': 'Rare', 'xyName': 'Medium', 'xyColor': '#fff875', 'xy': '5'},
                            // Column 6 (Catastrophic)
                            {'xid': 6, 'yid': 1, 'xyId': 6001, 'x': 'Catastrophic', 'y': 'Almost Certain', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '30'},
                            {'xid': 6, 'yid': 2, 'xyId': 6002, 'x': 'Catastrophic', 'y': 'Likely', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '24'},
                            {'xid': 6, 'yid': 3, 'xyId': 6003, 'x': 'Catastrophic', 'y': 'Possible', 'xyName': 'Critical', 'xyColor': '#633636', 'xy': '18'},
                            {'xid': 6, 'yid': 4, 'xyId': 6004, 'x': 'Catastrophic', 'y': 'Unlikely', 'xyName': 'Critical', 'xyColor': '#ee3300', 'xy': '12'},
                            {'xid': 6, 'yid': 5, 'xyId': 6005, 'x': 'Catastrophic', 'y': 'Rare', 'xyName': 'High', 'xyColor': '#ff9933', 'xy': '6'},
                          ],
                          onCellSelected: (xid, yid, xyId, score) {
                            debugPrint('Wide Matrix Selected: xid=$xid, yid=$yid, xyId=$xyId, score=$score');
                          },
                        ),
                      ],
                    ),
                    GSSection(sectionTitle: "Star Rating",
                    fields: [
                      GSField.starRating(
                        tag: "rating",
                        title: "Rate this product",
                        weight: 12,
                        maximumRate: 5,
                        starSize: 32,
                        leftText: "Poor",
                        rightText: "Excellent",
                      ),
                      GSField.starRating(
                        tag: "satisfaction",
                        title: "Satisfaction (required)",
                        weight: 12,
                        maximumRate: 10,
                        starSize: 24,
                        required: true,
                        errorMessage: "Please rate your satisfaction",
                      ),
                    ]),
                    GSSection(sectionTitle: "Stepper Inputs",
                    fields: [
                      GSField.stepper(
                        tag: "percentage",
                        title: "Percentage",
                        weight: 12,
                        suffix: "%",
                        value: 50,
                        minValue: 0,
                        maxValue: 100,
                        step: 5,
                        allowDecimal: false,
                        allowNegative: false,
                      ),
                      GSField.stepper(
                        tag: "quantity",
                        title: "Quantity",
                        weight: 12,
                        value: 0,
                        minValue: 0,
                        step: 1,
                        allowDecimal: false,
                        allowNegative: false,
                      ),
                      GSField.stepper(
                        tag: "decimal",
                        title: "Decimal Value",
                        weight: 12,
                        value: 0.5,
                        step: 0.1,
                        allowDecimal: true,
                        allowNegative: true,
                      ),
                    ]),
                    GSSection(sectionTitle: "Currency Inputs",
                    fields: [
                      GSField.stepper(
                        tag: "price_usd",
                        title: "Price (USD)",
                        weight: 12,
                        prefix: "\$",
                        suffix: "USD",
                        value: 0,
                        minValue: 0,
                        step: 1,
                        allowDecimal: true,
                        allowNegative: false,
                      ),
                      GSField.stepper(
                        tag: "price_aud",
                        title: "Price (AUD)",
                        weight: 12,
                        prefix: "\$",
                        suffix: "AUD",
                        value: 100,
                        minValue: 0,
                        step: 0.5,
                        allowDecimal: true,
                        allowNegative: false,
                      ),
                    ]),
                    GSSection(sectionTitle: "Button Group",
                    fields: [
                      GSField.buttonGroup(
                        tag: "yesno",
                        title: "Yes/No Question",
                        weight: 12,
                        items: [
                          ButtonGroupItem(label: "Yes"),
                          ButtonGroupItem(label: "No"),
                          ButtonGroupItem(label: "N/A"),
                        ],
                        required: true,
                        errorMessage: "Please select an option",
                      ),
                      GSField.buttonGroup(
                        tag: "rating_buttons",
                        title: "Quick Rating",
                        weight: 12,
                        items: [
                          ButtonGroupItem(label: "Poor"),
                          ButtonGroupItem(label: "Fair"),
                          ButtonGroupItem(label: "Good"),
                          ButtonGroupItem(label: "Excellent"),
                        ],
                        allowDeselect: true,
                      ),
                    ]),
                    GSSection(sectionTitle: "Slider",
                    fields: [
                      GSField.slider(
                        tag: "volume",
                        title: "Volume",
                        weight: 12,
                        minValue: 0,
                        maxValue: 100,
                        step: 1,
                        initialValue: 50,
                        showLabels: true,
                        showValueField: true,
                        minLabel: "0%",
                        maxLabel: "100%",
                      ),
                      GSField.slider(
                        tag: "temperature",
                        title: "Temperature",
                        weight: 12,
                        minValue: 16,
                        maxValue: 30,
                        step: 0.5,
                        initialValue: 22,
                        showLabels: true,
                        showValueField: true,
                        minLabel: "Cold",
                        midLabel: "Comfortable",
                        maxLabel: "Hot",
                      ),
                    ]),
                    GSSection(sectionTitle: "Chip Select",
                    fields: [
                      GSField.chipSelect(
                        tag: "tags",
                        title: "Select Tags (Multi)",
                        weight: 12,
                        multiSelect: true,
                        wrap: true,
                        items: [
                          ChipSelectItem(label: "Flutter"),
                          ChipSelectItem(label: "Dart"),
                          ChipSelectItem(label: "Mobile"),
                          ChipSelectItem(label: "iOS"),
                          ChipSelectItem(label: "Android"),
                          ChipSelectItem(label: "Web"),
                        ],
                      ),
                      GSField.chipSelect(
                        tag: "size",
                        title: "Select Size (Single)",
                        weight: 12,
                        multiSelect: false,
                        wrap: true,
                        items: [
                          ChipSelectItem(label: "Small"),
                          ChipSelectItem(label: "Medium"),
                          ChipSelectItem(label: "Large"),
                          ChipSelectItem(label: "X-Large"),
                        ],
                      ),
                    ]),
                    GSSection(sectionTitle: "Signature",
                    fields: [
                      GSField.signature(
                        tag: "signature",
                        title: "Sign Here",
                        weight: 12,
                        height: 150,
                        showClearButton: true,
                        clearButtonText: "Clear Signature",
                        required: true,
                        errorMessage: "Signature is required",
                      ),
                      if (_sampleBackgroundImage != null)
                        GSField.signature(
                          tag: "scribble_on_image",
                          title: "Scribble on Image",
                          weight: 12,
                          height: 200,
                          showClearButton: true,
                          clearButtonText: "Clear",
                          backgroundImageBytes: _sampleBackgroundImage,
                        ),
                    ]),
                    GSSection(sectionTitle: "Number Inputs",
                    fields: [
                      GSField.number(
                        tag: "age",
                        title: "Age",
                        weight: 6,
                        required: true,
                        minValue: 0,
                        maxValue: 120,
                        allowDecimal: false,
                        allowNegative: false,
                        errorMessage: "Please enter a valid age",
                      ),
                      GSField.number(
                        tag: "temperature_reading",
                        title: "Temperature Reading",
                        weight: 6,
                        allowDecimal: true,
                        allowNegative: true,
                        minValue: -50,
                        maxValue: 50,
                      ),
                      GSField.number(
                        tag: "score",
                        title: "Score (0-100)",
                        weight: 12,
                        allowDecimal: true,
                        allowNegative: false,
                        minValue: 0,
                        maxValue: 100,
                      ),
                    ]),
                    GSSection(sectionTitle: "Date Inputs",
                    fields: [
                      GSField.time(tag: "time", title: "Select a time", weight: 12),
                      GSField.datePicker(tag: "date", calendarType: GSCalendarType.gregorian),
                      GSField.dateRangePicker(tag: "dateRange", calendarType: GSCalendarType.gregorian)
                    ]),
                    GSSection(sectionTitle: "Media Inputs",
                    fields: [
                      GSField.imagePicker(tag: "imagePicker", iconWidget: const Icon(Icons.image)),
                      GSField.multiImagePicker(tag: "multiImagePicker", iconWidget: const Icon(Icons.image)),
                      GSField.qrScanner(tag: "qrScanner")
                    ]),
                    GSSection(sectionTitle: "Checklist",
                    fields: [
                      GSField.checkList(
                          tag: 'interests',
                          title: 'Interests',
                          weight: 12,
                          searchable: false,
                          items: [
                            CheckDataModel(title: 'Technology', isSelected: true),
                            CheckDataModel(title: 'Sports', isSelected: false),
                            CheckDataModel(title: 'Music', isSelected: false),
                            CheckDataModel(title: 'Travel', isSelected: false),
                          ],
                          callBack: (data) {},
                        ),
                  ]),
                  GSSection(sectionTitle: "Radio group",
                    fields: [
                        GSField.radioGroup(
                          tag: 'gender',
                          title: 'Gender',
                          weight: 12,
                          required: false,
                          scrollDirection: Axis.vertical,
                          searchable: false,
                          items: [
                            RadioDataModel(title: 'Male', isSelected: false),
                            RadioDataModel(title: 'Female', isSelected: false),
                            RadioDataModel(title: 'Non-Binary', isSelected: false),
                            RadioDataModel(title: 'Other', isSelected: false),
                          ],
                          callBack: (data) {},
                        ),
                    ]),
                    GSSection(sectionTitle: "Spinner",
                    fields: [
                        GSField.spinner(
                          tag: 'country',
                          title: 'Country',
                          weight: 12,
                          required: false,
                          items: [
                            SpinnerDataModel(name: 'United States', id: 1),
                            SpinnerDataModel(name: 'Canada', id: 2),
                            SpinnerDataModel(name: 'United Kingdom', id: 3),
                            SpinnerDataModel(name: 'Australia', id: 4),
                          ],
                        ),
                    ]),
                    GSSection(
                      sectionTitle: 'Text inputs',
                      fields: [
                        GSField.text(
                          tag: 'firstName',
                          title: 'First Name',
                          weight: 6,
                          required: true,
                          errorMessage: 'First name is required',
                        ),
                        GSField.text(
                          tag: 'lastName',
                          title: 'Last Name',
                          weight: 6,
                          required: true,
                          errorMessage: 'Last name is required',
                        ),
                        GSField.datePicker(
                          calendarType: GSCalendarType.gregorian,
                          tag: 'birthDate',
                          title: 'Date of Birth',
                          weight: 12,
                          required: true,
                          errorMessage: 'Date of birth is required',
                        ),
                      ],
                    ),
                    GSSection(
                      sectionTitle: 'Contact Information',
                      fields: [
                        GSField.email(
                          tag: 'email',
                          title: 'Email Address',
                          weight: 12,
                          required: true,
                          errorMessage: 'Valid email is required',
                        ),
                        GSField.mobile(
                          tag: 'phone',
                          title: 'Phone Number',
                          maxLength: 15,
                          weight: 6,
                          required: false,
                        ),
                        GSField.textPlain(
                          tag: 'address',
                          title: 'Address',
                          hint: 'Enter your full address',
                          weight: 12,
                          maxLine: 3,
                          required: false,
                          prefixWidget: const Icon(Icons.location_on),
                        ),
                      ],
                    ),
                    GSSection(
                      sectionTitle: 'Rich Text',
                      fields: [
                        GSField.richText(
                          tag: 'notes',
                          title: 'Notes',
                          weight: 12,
                          hint: 'Enter formatted notes...',
                          height: 200,
                          showToolbar: true,
                        ),
                        GSField.richText(
                          tag: 'description',
                          title: 'Description (Required)',
                          weight: 12,
                          hint: 'Enter a description...',
                          height: 150,
                          required: true,
                          errorMessage: 'Description is required',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FilledButton(
              onPressed: _onSubmit,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check),
                  SizedBox(width: 8),
                  Text('Submit'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    final isValid = form.isValid();
    final data = form.onSubmit();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isValid ? 'Form Valid' : 'Form Invalid'),
        content: SingleChildScrollView(
          child: Text('Data:\n${data.entries.map((e) => '${e.key}: ${e.value}').join('\n')}'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
