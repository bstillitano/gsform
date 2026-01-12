import 'package:flutter/material.dart';
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
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
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
          seedColor: Colors.blue,
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
                    GSSection(sectionTitle: "Date Inputs",
                    fields: [
                      GSField.time(tag: "time", title: "Select a time", weight: 12),
                      GSField.datePicker(tag: "date", calendarType: GSCalendarType.gregorian),
                      GSField.dateRangePicker(tag: "dateRange", calendarType: GSCalendarType.gregorian)
                    ]),
                    GSSection(
                      sectionTitle: 'Personal Information',
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
                        GSField.radioGroup(
                          tag: 'gender',
                          title: 'Gender',
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
                        GSField.spinner(
                          tag: 'country',
                          title: 'Country',
                          weight: 6,
                          required: false,
                          items: [
                            SpinnerDataModel(name: 'United States', id: 1),
                            SpinnerDataModel(name: 'Canada', id: 2),
                            SpinnerDataModel(name: 'United Kingdom', id: 3),
                            SpinnerDataModel(name: 'Australia', id: 4),
                          ],
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
                      sectionTitle: 'Preferences',
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
