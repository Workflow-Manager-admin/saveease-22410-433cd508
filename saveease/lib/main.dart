import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const SaveEaseApp());
}

// Theme and color constants
const kPrimaryColor = Color(0xFF2E7D32);
const kSecondaryColor = Color(0xFFF9A825);
const kAccentColor = Color(0xFF00B8D4);

final saveEaseTheme = ThemeData(
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: kSecondaryColor,
    background: Colors.white,
    primaryContainer: kPrimaryColor.withOpacity(0.05),
    secondaryContainer: kSecondaryColor.withOpacity(0.08),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.black,
  ),
  useMaterial3: true,
  fontFamily: 'Roboto',
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(kPrimaryColor),
      foregroundColor: MaterialStatePropertyAll(Colors.white),
      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      )),
      textStyle:
          MaterialStatePropertyAll(TextStyle(fontWeight: FontWeight.bold)),
      padding:
          MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 18, horizontal: 12)),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 14),
    labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor),
  ),
);

// ---------------- SaveEaseApp (Main Container) ------------------
class SaveEaseApp extends StatefulWidget {
  const SaveEaseApp({Key? key}) : super(key: key);

  @override
  State<SaveEaseApp> createState() => _SaveEaseAppState();
}

class _SaveEaseAppState extends State<SaveEaseApp> {
  Locale _locale = const Locale('en');
  bool _isRtl = false;

  void _changeLocale(Locale locale, {bool isRtl = false}) {
    setState(() {
      _locale = locale;
      _isRtl = isRtl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveEase',
      theme: saveEaseTheme,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('es'), // Spanish
        Locale('ar'), // Arabic (RTL)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Apply RTL if needed
        return Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        );
      },
      home: OnboardingScreen(
        onLocaleChange: _changeLocale,
      ),
    );
  }
}

// ---------------- UI ROUTES -----------------

enum SaveEaseTab { home, goals, withdraw, settings }

class MainShell extends StatefulWidget {
  final int initialTab;
  final void Function(Locale, {bool isRtl}) onLocaleChange;
  const MainShell({super.key, required this.onLocaleChange, this.initialTab = 0});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget>? _tabs;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    _tabs ??= [
      HomeScreen(),
      GoalsScreen(),
      WithdrawScreen(),
      SettingsScreen(onLocaleChange: widget.onLocaleChange),
    ];
    return Scaffold(
      body: Builder(
        builder: (context) => _tabs![_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kPrimaryColor.withOpacity(0.97),
        currentIndex: _currentIndex,
        selectedItemColor: kSecondaryColor,
        unselectedItemColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Goals'),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Withdraw'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ----------------- ONBOARDING FLOW -----------------

class OnboardingScreen extends StatefulWidget {
  final void Function(Locale, {bool isRtl}) onLocaleChange;
  const OnboardingScreen({super.key, required this.onLocaleChange});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _OnboardingStep { welcome, register, kyc, pinSetup, done }

class _OnboardingScreenState extends State<OnboardingScreen> {
  _OnboardingStep _step = _OnboardingStep.welcome;
  bool _kycRequired = false;
  String _phoneOrEmail = '';
  String _pin = '';
  bool _showPin = false;
  String _kycDocument = '';

  void _completeRegistration() {
    setState(() => _step = _OnboardingStep.kyc);
  }

  void _completeKyc() {
    setState(() => _step = _OnboardingStep.pinSetup);
  }

  void _completePinSetup() {
    setState(() => _step = _OnboardingStep.done);
  }

  void _goToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => MainShell(
          initialTab: 0,
          onLocaleChange: widget.onLocaleChange,
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.savings, size: 80, color: kAccentColor),
          const SizedBox(height: 32),
          Text(
            "Welcome to SaveEase!",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Start saving, track your goals, and get rewarded for good habits.",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => setState(() => _step = _OnboardingStep.register),
            child: Text("Get Started"),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _langSelector('English', const Locale('en'), false),
              _langSelector('Español', const Locale('es'), false),
              _langSelector('العربية', const Locale('ar'), true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _langSelector(String label, Locale locale, bool isRtl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: OutlinedButton(
        onPressed: () => widget.onLocaleChange(locale, isRtl: isRtl),
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimaryColor,
          side: BorderSide(color: kPrimaryColor),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildRegister() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Register Account",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: kPrimaryColor),
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              labelText: "Phone or Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (val) => setState(() => _phoneOrEmail = val),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            activeColor: kSecondaryColor,
            title: Text(
              "Perform KYC (upload ID)",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
            ),
            value: _kycRequired,
            onChanged: (val) => setState(() => _kycRequired = val),
          ),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: _phoneOrEmail.trim().isNotEmpty
                ? _completeRegistration
                : null,
            child: Text("Continue"),
          ),
          const SizedBox(height: 30),
          _backButton(_OnboardingStep.welcome),
        ],
      ),
    );
  }

  Widget _buildKyc() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Upload KYC Document",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kPrimaryColor,
                ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Simulate a successful document upload
              setState(() => _kycDocument = "kyc_document_mock.pdf");
            },
            icon: const Icon(Icons.upload_file),
            label: Text(_kycDocument.isEmpty
                ? "Choose Document"
                : "Document Uploaded"),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
              onPressed: _kycDocument.isNotEmpty
                  ? _completeKyc
                  : null,
              child: Text("Continue")),
          const SizedBox(height: 30),
          _backButton(_OnboardingStep.register),
        ],
      ),
    );
  }

  Widget _buildPinSetup() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Set a 4-digit PIN",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kPrimaryColor,
                ),
          ),
          const SizedBox(height: 17),
          TextField(
            obscureText: !_showPin,
            keyboardType: TextInputType.number,
            maxLength: 4,
            decoration: InputDecoration(
              labelText: "PIN",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPin ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () => setState(() => _showPin = !_showPin),
              ),
            ),
            onChanged: (val) => setState(() => _pin = val),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _pin.length == 4 ? _completePinSetup : null,
            child: Text("Continue"),
          ),
          const SizedBox(height: 30),
          _backButton(_kycRequired
              ? _OnboardingStep.kyc
              : _OnboardingStep.register),
        ],
      ),
    );
  }

  Widget _buildDone() {
    return Padding(
      padding: const EdgeInsets.all(38),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, size: 68, color: kPrimaryColor),
          const SizedBox(height: 18),
          Text(
            "All Done!",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: kPrimaryColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Your SaveEase account is ready.\nSet a savings goal to get started!",
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
              onPressed: _goToMain, child: Text("Enter SaveEase")),
        ],
      ),
    );
  }

  Widget _backButton(_OnboardingStep step) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => setState(() => _step = step),
        icon: const Icon(Icons.arrow_back, size: 22),
        label: Text("Back"),
        style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (_step) {
      case _OnboardingStep.welcome:
        child = _buildWelcome();
        break;
      case _OnboardingStep.register:
        child = _buildRegister();
        break;
      case _OnboardingStep.kyc:
        if (_kycRequired) {
          child = _buildKyc();
        } else {
          // Skip KYC
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _step = _OnboardingStep.pinSetup);
          });
          child = const SizedBox.shrink();
        }
        break;
      case _OnboardingStep.pinSetup:
        child = _buildPinSetup();
        break;
      case _OnboardingStep.done:
        child = _buildDone();
        break;
    }

    return Scaffold(
      backgroundColor: kAccentColor.withOpacity(0.04),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ------------------ HOME/DASHBOARD ----------------------

class HomeScreen extends StatelessWidget {
  final _mockSavingTotal = 210.50;
  final _mockNextSavings = 7.20;
  final _mockStreak = 4;
  final _mockBadges = [
    'Streak 3 Days!', 'Saved \$100', 'First Goal Achieved'
  ];

  HomeScreen({Key? key}) : super(key: key);

  Widget _badgeWidget(String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: kAccentColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        badge,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.account_circle_rounded, color: kAccentColor, size: 32),
        ),
        title: Text('SaveEase Home', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (ctx) => [
              PopupMenuItem(value: "settings", child: Text("Settings")),
              PopupMenuItem(value: "logout", child: Text("Logout")),
            ],
            onSelected: (selected) {
              // Handle action (mock)
            },
          )
        ],
      ),
      backgroundColor: kAccentColor.withOpacity(0.03),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(
                context,
                totalSavings: _mockSavingTotal,
                nextSavings: _mockNextSavings,
                streak: _mockStreak),
            SizedBox(height: 22),
            Text("Your Badges", style: Theme.of(context).textTheme.labelLarge),
            Row(
              children: [
                for (var b in _mockBadges) _badgeWidget(b),
              ],
            ),
            SizedBox(height: 22),
            Text(
              "Active Goals",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            GoalsSummaryWidget(),
            SizedBox(height: 22),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: Colors.black),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => SaveActionSheet()),
                );
              },
              icon: Icon(Icons.add),
              label: Text("Quick Save Now!"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(BuildContext context,
      {required double totalSavings,
      required double nextSavings,
      required int streak}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Saved',
                  style: TextStyle(color: kSecondaryColor, fontSize: 14)),
              Text('\$${totalSavings.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Next Auto-Save: \$${nextSavings.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, color: kAccentColor, size: 32),
              Text('Streak: $streak',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class SaveActionSheet extends StatefulWidget {
  @override
  State<SaveActionSheet> createState() => _SaveActionSheetState();
}

class _SaveActionSheetState extends State<SaveActionSheet> {
  double _amount = 0;
  String _goal = "House Fund";
  final _goals = ["House Fund", "Medical", "Education", "Emergency"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quick Save"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _goal,
              items: _goals
                  .map((g) =>
                      DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => _goal = val!),
              decoration: InputDecoration(
                labelText: "Select Goal",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 18),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Amount (\$)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => setState(() =>
                  _amount = double.tryParse(val) ?? 0),
            ),
            SizedBox(height: 22),
            ElevatedButton.icon(
                onPressed: _amount > 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Saved \$_${_amount.toStringAsFixed(2)} to $_goal!")));
                        Navigator.pop(context);
                      }
                    : null,
                icon: Icon(Icons.check),
                label: Text("Confirm Save")),
          ],
        ),
      ),
    );
  }
}

// ---------- GOALS -----------

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<_Goal> _goals = [
    _Goal(
        name: "Buy a Bicycle",
        target: 150,
        saved: 90,
        deadline: "2024-07-20"),
    _Goal(
        name: "School Fees",
        target: 600,
        saved: 265,
        deadline: "2024-10-01"),
    _Goal(
        name: "Medical Emergency",
        target: 200,
        saved: 50,
        deadline: ""),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Savings Goals"),
        backgroundColor: kPrimaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newGoal = await Navigator.of(context).push<_Goal>(
            MaterialPageRoute(builder: (c) => GoalCreateScreen()),
          );
          if (newGoal != null) {
            setState(() {
              _goals.add(newGoal);
            });
          }
        },
        backgroundColor: kAccentColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _goals.length,
        itemBuilder: (c, i) {
          final g = _goals[i];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            tileColor: Colors.white,
            leading: CircleAvatar(
              backgroundColor: kAccentColor,
              child: Icon(Icons.emoji_events, color: Colors.white),
            ),
            title: Text(
              g.name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: (g.saved / g.target).clamp(0.02, 0.99),
                  minHeight: 8,
                  color: kPrimaryColor,
                  backgroundColor: kSecondaryColor.withOpacity(0.3),
                ),
                SizedBox(height: 6),
                Text("Saved: \$${g.saved} / \$${g.target}"),
                if (g.deadline.isNotEmpty)
                  Text("Deadline: ${g.deadline}",
                      style: TextStyle(
                          color: kSecondaryColor,
                          fontWeight: FontWeight.bold)),
              ],
            ),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (c) => GoalDetailScreen(goal: g)));
            },
          );
        },
      ),
    );
  }
}

class _Goal {
  final String name;
  final double target;
  final double saved;
  final String deadline;
  _Goal({
    required this.name,
    required this.target,
    required this.saved,
    required this.deadline,
  });
}

class GoalsSummaryWidget extends StatelessWidget {
  final List<_Goal> goals = [
    _Goal(
        name: "Buy a Bicycle",
        target: 150,
        saved: 90,
        deadline: "2024-07-20"),
    _Goal(
        name: "School Fees",
        target: 600,
        saved: 265,
        deadline: "2024-10-01"),
  ];

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return Text("No goals set yet!");
    }
    return Column(
      children: [
        for (var g in goals)
          ListTile(
            tileColor: kSecondaryColor.withOpacity(0.08),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            title: Text(g.name),
            subtitle: LinearProgressIndicator(
              value: (g.saved / g.target).clamp(0, 1),
              minHeight: 5,
              color: kAccentColor,
              backgroundColor: kPrimaryColor.withOpacity(0.11),
            ),
            trailing: Text(
                "\$${g.saved.toStringAsFixed(0)}/\$\{g.target.toStringAsFixed(0)}"),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (c) => GoalDetailScreen(goal: g)));
            },
          ),
      ],
    );
  }
}

class GoalDetailScreen extends StatelessWidget {
  final _Goal goal;
  const GoalDetailScreen({super.key, required this.goal});
  @override
  Widget build(BuildContext context) {
    final ratio = (goal.saved / goal.target).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text("Goal Detail"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold, color: kPrimaryColor)),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: ratio,
              color: kAccentColor,
              backgroundColor: kSecondaryColor.withOpacity(0.25),
              minHeight: 18,
            ),
            SizedBox(height: 12),
            Text("Saved: \$${goal.saved} / \$${goal.target}",
                style: Theme.of(context).textTheme.bodyLarge),
            if (goal.deadline.isNotEmpty)
              Text("Deadline: ${goal.deadline}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: kSecondaryColor)),
            SizedBox(height: 22),
            ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text("Add to Goal"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Simulate add to goal
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Amount added to '${goal.name}'")));
                }),
            SizedBox(height: 18),
            Text('Reminders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Row(
              children: [
                Icon(Icons.alarm, color: kPrimaryColor),
                SizedBox(width: 8),
                Text("Every Sunday, 8am"),
              ],
            ),
            SizedBox(height: 16),
            Text('Goal History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ListTile(
              leading: Icon(Icons.monetization_on, color: kSecondaryColor),
              title: Text("Added \$10 - 2024-06-05"),
            ),
            ListTile(
              leading: Icon(Icons.monetization_on, color: kSecondaryColor),
              title: Text("Added \$15 - 2024-06-02"),
            ),
          ],
        ),
      ),
    );
  }
}

class GoalCreateScreen extends StatefulWidget {
  @override
  State<GoalCreateScreen> createState() => _GoalCreateScreenState();
}

class _GoalCreateScreenState extends State<GoalCreateScreen> {
  final nameController = TextEditingController();
  final targetController = TextEditingController();
  final deadlineController = TextEditingController();
  bool showDeadline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Goal"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Goal Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: "Target Amount (\$)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text("Set a deadline/reminder?"),
              activeColor: kSecondaryColor,
              value: showDeadline,
              onChanged: (b) => setState(() => showDeadline = b),
            ),
            if (showDeadline)
              TextFormField(
                controller: deadlineController,
                decoration: InputDecoration(
                  labelText: "Deadline (YYYY-MM-DD)",
                  border: OutlineInputBorder(),
                ),
              ),
            SizedBox(height: 21),
            ElevatedButton.icon(
                onPressed: nameController.text.trim().isEmpty ||
                        targetController.text.trim().isEmpty
                    ? null
                    : () {
                        final goal = _Goal(
                          name: nameController.text.trim(),
                          target: double.tryParse(targetController.text) ?? 0,
                          saved: 0,
                          deadline: showDeadline
                              ? deadlineController.text.trim()
                              : "",
                        );
                        Navigator.of(context).pop(goal);
                      },
                icon: Icon(Icons.check),
                label: Text("Create Goal")),
          ],
        ),
      ),
    );
  }
}

// ----------------- WITHDRAWAL -------------------

class WithdrawScreen extends StatefulWidget {
  const WithdrawScreen({super.key});
  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  double _amount = 0.0;
  String _reason = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Withdraw Funds"),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Withdrawal Form",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (val) =>
                      setState(() => _amount = double.tryParse(val) ?? 0),
                ),
                SizedBox(height: 13),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Emergency Reason (optional)",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => setState(() => _reason = val),
                ),
                SizedBox(height: 22),
                ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text("Request Withdrawal"),
                  onPressed: _amount > 0
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  "Withdrawal of \$${_amount.toStringAsFixed(2)} requested.")));
                          setState(() {
                            _amount = 0;
                            _reason = '';
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- SETTINGS -----------------------

class SettingsScreen extends StatefulWidget {
  final void Function(Locale, {bool isRtl}) onLocaleChange;
  const SettingsScreen({super.key, required this.onLocaleChange});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool pinEnabled = true;
  bool biometricEnabled = false;
  String _language = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: kPrimaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text("Security",
              style: Theme.of(context).textTheme.labelLarge),
          SwitchListTile(
              title: Text("PIN Login"),
              activeColor: kPrimaryColor,
              value: pinEnabled,
              onChanged: (v) => setState(() => pinEnabled = v)),
          SwitchListTile(
              title: Text("Enable Biometric (mocked)"),
              activeColor: kAccentColor,
              value: biometricEnabled,
              onChanged: (v) =>
                  setState(() => biometricEnabled = v)),
          Divider(),
          Text("Language",
              style: Theme.of(context).textTheme.labelLarge),
          ListTile(
            title: Text("English"),
            leading: Radio<String>(
                value: 'en',
                groupValue: _language,
                onChanged: (v) {
                  setState(() => _language = v!);
                  widget.onLocaleChange(Locale('en'), isRtl: false);
                }),
          ),
          ListTile(
            title: Text("Español"),
            leading: Radio<String>(
                value: 'es',
                groupValue: _language,
                onChanged: (v) {
                  setState(() => _language = v!);
                  widget.onLocaleChange(Locale('es'), isRtl: false);
                }),
          ),
          ListTile(
            title: Text("العربية (Arabic)"),
            leading: Radio<String>(
                value: 'ar',
                groupValue: _language,
                onChanged: (v) {
                  setState(() => _language = v!);
                  widget.onLocaleChange(Locale('ar'), isRtl: true);
                }),
          ),
          Divider(),
          Text("Account",
              style: Theme.of(context).textTheme.labelLarge),
          ListTile(
            leading: Icon(Icons.logout, color: kPrimaryColor),
            title: Text("Logout"),
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (c) => OnboardingScreen(
                        onLocaleChange: widget.onLocaleChange)),
                (route) => false),
          ),
        ],
      ),
    );
  }
}
