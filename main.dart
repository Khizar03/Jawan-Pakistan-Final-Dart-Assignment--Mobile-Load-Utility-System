import 'dart:io';

enum Goal { weightLoss, maintenance, muscleGain }

class User {
  final String username;
  final String password; 
  int age;
  double heightCm; 
  double weightKg;
  Goal goal;
  double dailyCalorieLimit;

  User({
    required this.username,
    required this.password,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.dailyCalorieLimit,
  }) {
    _validate();
  }

  void _validate() {
    if (username.trim().isEmpty) throw Exception("Username cannot be empty.");
    if (password.length < 4) {
      throw Exception("Password must be at least 4 characters.");
    }
    if (age < 10 || age > 100) {
      throw Exception("Age must be between 10 and 100.");
    }
    if (heightCm < 100 || heightCm > 230) {
      throw Exception("Height must be between 100 and 230 cm.");
    }
    if (weightKg < 30 || weightKg > 300) {
      throw Exception("Weight must be between 30 and 300 kg.");
    }
    if (dailyCalorieLimit < 800 || dailyCalorieLimit > 6000) {
      throw Exception("Daily calorie limit must be between 800 and 6000 kcal.");
    }
  }

  double get bmi {
    final hM = heightCm / 100.0;
    return weightKg / (hM * hM);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return "Underweight";
    if (b < 25) return "Normal";
    if (b < 30) return "Overweight";
    return "Obese";
  }

  @override
  String toString() {
    return "User: $username | Age: $age | H: ${heightCm.toStringAsFixed(1)} cm | "
        "W: ${weightKg.toStringAsFixed(1)} kg | Goal: ${goal.name} | "
        "Daily Limit: ${dailyCalorieLimit.toStringAsFixed(0)} kcal | "
        "BMI: ${bmi.toStringAsFixed(1)} (${bmiCategory})";
  }
}

class WorkoutEntry {
  final DateTime date;
  final String name;
  final double caloriesBurned;

  WorkoutEntry({
    required this.date,
    required this.name,
    required this.caloriesBurned,
  }) {
    if (name.trim().isEmpty) throw Exception("Workout name cannot be empty.");
    if (caloriesBurned <= 0) {
      throw Exception("Calories burned must be greater than 0.");
    }
    if (caloriesBurned > 3000) {
      throw Exception("Calories burned seems unrealistically high.");
    }
  }

  @override
  String toString() =>
      "[${date.toLocal()}] Workout: $name | Burned: ${caloriesBurned.toStringAsFixed(0)} kcal";
}

class FoodEntry {
  final DateTime date;
  final String item;
  final double calories;

  FoodEntry({required this.date, required this.item, required this.calories}) {
    if (item.trim().isEmpty) throw Exception("Food item cannot be empty.");
    if (calories <= 0) throw Exception("Calories must be greater than 0.");
    if (calories > 3000) {
      throw Exception("Single item calories seems unrealistically high.");
    }
  }

  @override
  String toString() =>
      "[${date.toLocal()}] Food: $item | ${calories.toStringAsFixed(0)} kcal";
}

class DayLog {
  final DateTime date; 
  final List<FoodEntry> foods = [];
  final List<WorkoutEntry> workouts = [];

  DayLog(this.date);

  double get totalFood => foods.fold(0.0, (sum, e) => sum + e.calories);

  double get totalBurned =>
      workouts.fold(0.0, (sum, e) => sum + e.caloriesBurned);

  double netCalories(double dailyLimit) {
    return totalFood - totalBurned;
  }

  String get dateKey => _dateKey(date);

  static String _dateKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}

class FitnessApp {
  final Map<String, User> _users = {};
  User? _current;

  final Map<String, Map<String, DayLog>> _logs = {};

 
  final Map<String, List<String>> _savedMeals = {}; 
  final Map<String, List<String>> _savedWorkouts =
      {}; 

  void run() {
    while (true) {
      if (_current == null) {
        _authMenu();
      } else {
        _mainMenu();
      }
    }
  }


  void _authMenu() {
    print("\n=== FITNESS & DIET TRACKER ===");
    print("1) Register");
    print("2) Login");
    print("3) Exit");
    stdout.write("Choose: ");
    final choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        _registerFlow();
        break;
      case '2':
        _loginFlow();
        break;
      case '3':
        print("Goodbye!");
        exit(0);
      default:
        print("Invalid choice.");
    }
  }

  void _registerFlow() {
    try {
      stdout.write("Username: ");
      final u = _readNonEmpty();
      if (_users.containsKey(u)) {
        print("Username already exists.");
        return;
      }
      stdout.write("Password (min 4 chars): ");
      final p = _readNonEmpty();
      final age = _readInt("Age (10-100): ");
      final height = _readDouble("Height in cm (100-230): ");
      final weight = _readDouble("Weight in kg (30-300): ");
      print("Goal: 1) weightLoss  2) maintenance  3) muscleGain");
      final gChoice = _readInt("Choose goal: ");
      final goal = switch (gChoice) {
        1 => Goal.weightLoss,
        2 => Goal.maintenance,
        3 => Goal.muscleGain,
        _ => Goal.maintenance,
      };
      final limit = _readDouble("Daily calorie limit (800-6000): ");

      final user = User(
        username: u,
        password: p,
        age: age,
        heightCm: height,
        weightKg: weight,
        goal: goal,
        dailyCalorieLimit: limit,
      );

      _users[u] = user;
      _logs[u] = {};
      _savedMeals[u] = [];
      _savedWorkouts[u] = [];
      _current = user;

      print("\nRegistration successful and logged in!");
      print(user);
    } catch (e) {
      print("❌ $e");
    }
  }

  void _loginFlow() {
    stdout.write("Username: ");
    final u = _readNonEmpty();
    stdout.write("Password: ");
    final p = _readNonEmpty();

    final user = _users[u];
    if (user == null || user.password != p) {
      print("Invalid username or password.");
      return;
    }
    _current = user;
    print("\nLogged in as ${user.username}.");
    print(user);
  }


  void _mainMenu() {
    print("\n=== MAIN MENU (${_current!.username}) ===");
    print("1) View Profile");
    print("2) Update Profile / Goal / Daily Limit");
    print("3) Log Food Intake");
    print("4) Log Workout");
    print("5) Today Summary");
    print("6) View History (select date)");
    print("7) Quick Add (Saved Meals/Workouts)");
    print("8) Smart Suggestions");
    print("9) Logout");
    stdout.write("Choose: ");
    final ch = stdin.readLineSync();

    switch (ch) {
      case '1':
        print(_current);
        break;
      case '2':
        _updateProfile();
        break;
      case '3':
        _logFood();
        break;
      case '4':
        _logWorkout();
        break;
      case '5':
        _todaySummary();
        break;
      case '6':
        _viewHistory();
        break;
      case '7':
        _quickAddMenu();
        break;
      case '8':
        _suggestions();
        break;
      case '9':
        _current = null;
        print("Logged out.");
        break;
      default:
        print("Invalid choice.");
    }
  }

  void _updateProfile() {
    final u = _current!;
    print("\n--- Update Profile ---");
    print("Leave blank to keep current value.");

    stdout.write("Age (${u.age}): ");
    final ageStr = stdin.readLineSync();
    if ((ageStr ?? "").trim().isNotEmpty) {
      final a = int.tryParse(ageStr!.trim());
      if (a == null || a < 10 || a > 100) {
        print("Invalid age. Skipped.");
      } else {
        u.age = a;
      }
    }

    stdout.write("Height cm (${u.heightCm}): ");
    final hStr = stdin.readLineSync();
    if ((hStr ?? "").trim().isNotEmpty) {
      final h = double.tryParse(hStr!.trim());
      if (h == null || h < 100 || h > 230) {
        print("Invalid height. Skipped.");
      } else {
        u.heightCm = h;
      }
    }

    stdout.write("Weight kg (${u.weightKg}): ");
    final wStr = stdin.readLineSync();
    if ((wStr ?? "").trim().isNotEmpty) {
      final w = double.tryParse(wStr!.trim());
      if (w == null || w < 30 || w > 300) {
        print("Invalid weight. Skipped.");
      } else {
        u.weightKg = w;
      }
    }

    print(
      "Goal (${u.goal.name}): 1) weightLoss  2) maintenance  3) muscleGain",
    );
    final gStr = stdin.readLineSync();
    if ((gStr ?? "").trim().isNotEmpty) {
      switch (gStr!.trim()) {
        case '1':
          u.goal = Goal.weightLoss;
          break;
        case '2':
          u.goal = Goal.maintenance;
          break;
        case '3':
          u.goal = Goal.muscleGain;
          break;
        default:
          print("Invalid goal. Skipped.");
      }
    }

    stdout.write("Daily calorie limit (${u.dailyCalorieLimit}): ");
    final dStr = stdin.readLineSync();
    if ((dStr ?? "").trim().isNotEmpty) {
      final d = double.tryParse(dStr!.trim());
      if (d == null || d < 800 || d > 6000) {
        print("Invalid daily limit. Skipped.");
      } else {
        u.dailyCalorieLimit = d;
      }
    }

    print("\nUpdated Profile:");
    print(u);
  }


  void _logFood() {
    final user = _current!;
    final today = DateTime.now();
    final log = _getOrCreateDayLog(user.username, today);

    stdout.write("Food item: ");
    final item = _readNonEmpty();
    final cals = _readDouble("Calories: ");

    final projected = log.totalFood + cals;
    if (projected > user.dailyCalorieLimit) {
      final remain = (user.dailyCalorieLimit - log.totalFood).clamp(0, 1e9);
      print(
        "❌ Cannot add. Daily limit ${user.dailyCalorieLimit.toStringAsFixed(0)} kcal exceeded.\n"
        "Remaining for today: ${remain.toStringAsFixed(0)} kcal.",
      );
      return;
    }

    try {
      final entry = FoodEntry(date: today, item: item, calories: cals);
      log.foods.add(entry);
      print("✅ Added: $entry");

      stdout.write("Save this meal to Quick Add? (y/n): ");
      final ans = stdin.readLineSync();
      if (ans != null && ans.toLowerCase().startsWith('y')) {
        final list = _savedMeals[user.username]!;
        if (!list.contains(item)) {
          list.add(item);
          print("💾 Saved meal '$item' to Quick Add.");
        } else {
          print("ℹ️ Meal already in Quick Add.");
        }
      }
    } catch (e) {
      print("❌ $e");
    }
  }

  void _logWorkout() {
    final user = _current!;
    final today = DateTime.now();
    final log = _getOrCreateDayLog(user.username, today);

    stdout.write("Workout name: ");
    final name = _readNonEmpty();
    final cals = _readDouble("Calories burned: ");

    try {
      final entry = WorkoutEntry(date: today, name: name, caloriesBurned: cals);
      log.workouts.add(entry);
      print("✅ Added: $entry");

      stdout.write("Save this workout to Quick Add? (y/n): ");
      final ans = stdin.readLineSync();
      if (ans != null && ans.toLowerCase().startsWith('y')) {
        final list = _savedWorkouts[user.username]!;
        if (!list.contains(name)) {
          list.add(name);
          print("💾 Saved workout '$name' to Quick Add.");
        } else {
          print("ℹ️ Workout already in Quick Add.");
        }
      }
    } catch (e) {
      print("❌ $e");
    }
  }


  void _todaySummary() {
    final user = _current!;
    final today = DateTime.now();
    final log = _getOrCreateDayLog(user.username, today);

    print("\n--- Today Summary (${log.dateKey}) ---");
    print("Daily Limit: ${user.dailyCalorieLimit.toStringAsFixed(0)} kcal");
    print("\nFoods:");
    if (log.foods.isEmpty) {
      print("  (none)");
    } else {
      for (final f in log.foods) {
        print("  ${f.item} - ${f.calories.toStringAsFixed(0)} kcal");
      }
    }
    print("\nWorkouts:");
    if (log.workouts.isEmpty) {
      print("  (none)");
    } else {
      for (final w in log.workouts) {
        print("  ${w.name} - ${w.caloriesBurned.toStringAsFixed(0)} kcal");
      }
    }
    final totalFood = log.totalFood;
    final totalBurn = log.totalBurned;
    final remaining = (user.dailyCalorieLimit - totalFood).clamp(0, 1e9);
    print("\nTotal Intake: ${totalFood.toStringAsFixed(0)} kcal");
    print("Total Burned: ${totalBurn.toStringAsFixed(0)} kcal");
    print("Remaining Intake Budget: ${remaining.toStringAsFixed(0)} kcal");
  }

  void _viewHistory() {
    final user = _current!;
    stdout.write("Enter date (YYYY-MM-DD), empty for today: ");
    final s = stdin.readLineSync()?.trim() ?? "";
    DateTime date;
    if (s.isEmpty) {
      date = DateTime.now();
    } else {
      final parts = s.split("-");
      if (parts.length != 3) {
        print("Invalid format.");
        return;
      }
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      final d = int.tryParse(parts[2]);
      if (y == null || m == null || d == null) {
        print("Invalid date.");
        return;
      }
      date = DateTime(y, m, d);
    }

    final map = _logs[user.username]!;
    final key = DayLog._dateKey(date);
    final log = map[key];
    if (log == null) {
      print("No entries for $key.");
      return;
    }

    print("\n--- History for $key ---");
    print("Foods:");
    if (log.foods.isEmpty) {
      print("  (none)");
    } else {
      for (final f in log.foods) {
        print("  ${f.item} - ${f.calories.toStringAsFixed(0)} kcal");
      }
    }
    print("\nWorkouts:");
    if (log.workouts.isEmpty) {
      print("  (none)");
    } else {
      for (final w in log.workouts) {
        print("  ${w.name} - ${w.caloriesBurned.toStringAsFixed(0)} kcal");
      }
    }
    final totalFood = log.totalFood;
    final totalBurn = log.totalBurned;
    print("\nTotal Intake: ${totalFood.toStringAsFixed(0)} kcal");
    print("Total Burned: ${totalBurn.toStringAsFixed(0)} kcal");
  }


  void _quickAddMenu() {
    final user = _current!;
    print("\n--- Quick Add ---");
    print("1) Add Saved Meal");
    print("2) Add Saved Workout");
    print("3) Manage Saved Items");
    stdout.write("Choose: ");
    final c = stdin.readLineSync();

    switch (c) {
      case '1':
        final meals = _savedMeals[user.username]!;
        if (meals.isEmpty) {
          print("No saved meals.");
          return;
        }
        for (int i = 0; i < meals.length; i++) {
          print("${i + 1}) ${meals[i]}");
        }
        final idx = _readInt("Select meal #: ") - 1;
        if (idx < 0 || idx >= meals.length) {
          print("Invalid.");
          return;
        }
        final name = meals[idx];
        final cals = _readDouble("Calories for '$name': ");
        final today = DateTime.now();
        final log = _getOrCreateDayLog(user.username, today);
        final projected = log.totalFood + cals;
        if (projected > user.dailyCalorieLimit) {
          final remain = (user.dailyCalorieLimit - log.totalFood).clamp(0, 1e9);
          print(
            "❌ Cannot add. Daily limit exceeded. Remaining: ${remain.toStringAsFixed(0)} kcal.",
          );
          return;
        }
        final entry = FoodEntry(date: today, item: name, calories: cals);
        log.foods.add(entry);
        print("✅ Added Quick Meal: $entry");
        break;

      case '2':
        final wouts = _savedWorkouts[user.username]!;
        if (wouts.isEmpty) {
          print("No saved workouts.");
          return;
        }
        for (int i = 0; i < wouts.length; i++) {
          print("${i + 1}) ${wouts[i]}");
        }
        final idx2 = _readInt("Select workout #: ") - 1;
        if (idx2 < 0 || idx2 >= wouts.length) {
          print("Invalid.");
          return;
        }
        final name2 = wouts[idx2];
        final cals2 = _readDouble("Calories burned for '$name2': ");
        final entry2 = WorkoutEntry(
          date: DateTime.now(),
          name: name2,
          caloriesBurned: cals2,
        );
        final log2 = _getOrCreateDayLog(user.username, DateTime.now());
        log2.workouts.add(entry2);
        print("✅ Added Quick Workout: $entry2");
        break;

      case '3':
        _manageSavedItems();
        break;

      default:
        print("Invalid choice.");
    }
  }

  void _manageSavedItems() {
    final u = _current!;
    print(
      "\nSaved Meals: ${_savedMeals[u.username]}\nSaved Workouts: ${_savedWorkouts[u.username]}",
    );
    print("1) Add Meal Name");
    print("2) Remove Meal Name");
    print("3) Add Workout Name");
    print("4) Remove Workout Name");
    stdout.write("Choose: ");
    final c = stdin.readLineSync();

    switch (c) {
      case '1':
        stdout.write("Meal name: ");
        final n = _readNonEmpty();
        final list = _savedMeals[u.username]!;
        if (!list.contains(n)) {
          list.add(n);
          print("Saved meal.");
        } else {
          print("Already exists.");
        }
        break;
      case '2':
        stdout.write("Meal name to remove: ");
        final r = _readNonEmpty();
        _savedMeals[u.username]!.remove(r);
        print("Removed if existed.");
        break;
      case '3':
        stdout.write("Workout name: ");
        final wn = _readNonEmpty();
        final wl = _savedWorkouts[u.username]!;
        if (!wl.contains(wn)) {
          wl.add(wn);
          print("Saved workout.");
        } else {
          print("Already exists.");
        }
        break;
      case '4':
        stdout.write("Workout name to remove: ");
        final wr = _readNonEmpty();
        _savedWorkouts[u.username]!.remove(wr);
        print("Removed if existed.");
        break;
      default:
        print("Invalid choice.");
    }
  }

  void _suggestions() {
    final u = _current!;
    final today = DateTime.now();
    final log = _getOrCreateDayLog(u.username, today);


    double target = u.dailyCalorieLimit;
    if (u.goal == Goal.weightLoss) target = (target * 0.85).roundToDouble();
    if (u.goal == Goal.muscleGain) target = (target * 1.10).roundToDouble();

    
    final remaining = (u.dailyCalorieLimit - log.totalFood).clamp(0, 1e9);
    final bmi = u.bmi;
    final cat = u.bmiCategory;

    print("\n--- Smart Suggestions ---");
    print("BMI: ${bmi.toStringAsFixed(1)} ($cat), Goal: ${u.goal.name}");
    print(
      "Daily Limit: ${u.dailyCalorieLimit.toStringAsFixed(0)} kcal | "
      "Adjusted Target for Goal: ${target.toStringAsFixed(0)} kcal",
    );

  
    print("\nDiet Plan Ideas (today):");
    if (remaining <= 200) {
      print(
        "- You are close to the daily limit. Prefer zero/low-cal snacks: cucumber, soup, tea without sugar.",
      );
    } else if (remaining <= 600) {
      print(
        "- Suggest a light meal (~${remaining.toStringAsFixed(0)} kcal): grilled chicken + salad / daal + roti / egg white omelet.",
      );
    } else {
      print(
        "- Balanced meal possible (~500–700 kcal): lean protein + complex carbs + veggies.",
      );
    }

    if (u.goal == Goal.weightLoss) {
      print("- Keep sugary drinks and fried foods minimal today.");
    } else if (u.goal == Goal.muscleGain) {
      print(
        "- Ensure protein in every meal; add dairy/eggs/legumes; consider a bedtime snack.",
      );
    }


    print("\nWorkout Suggestions:");
    if (cat == "Overweight" || cat == "Obese") {
      print("- Start with brisk walk 30–45 min or cycling 20–30 min.");
    } else if (cat == "Underweight") {
      print(
        "- Light full-body strength training 20–30 min; avoid excessive cardio.",
      );
    } else {
      print("- Mix 20 min moderate cardio + 20 min strength training.");
    }

    
    if (log.workouts.isEmpty) {
      print(
        "- No workout logged today. Even a 15–20 min session can help (jump rope, walk, bodyweight squats).",
      );
    } else {
      print(
        "- Great job training today! Consider mobility/stretching for recovery.",
      );
    }
  }


  DayLog _getOrCreateDayLog(String username, DateTime date) {
    final map = _logs[username]!;
    final key = DayLog._dateKey(date);
    return map.putIfAbsent(key, () => DayLog(date));
  }

  String _readNonEmpty() {
    final s = stdin.readLineSync();
    if (s == null || s.trim().isEmpty) {
      throw Exception("Input cannot be empty.");
    }
    return s.trim();
  }

  int _readInt(String prompt) {
    while (true) {
      stdout.write(prompt);
      final s = stdin.readLineSync();
      final v = int.tryParse((s ?? "").trim());
      if (v != null) return v;
      print("Please enter a valid integer.");
    }
  }

  double _readDouble(String prompt) {
    while (true) {
      stdout.write(prompt);
      final s = stdin.readLineSync();
      final v = double.tryParse((s ?? "").trim());
      if (v != null) return v;
      print("Please enter a valid number.");
    }
  }
}

void main() {
  final app = FitnessApp();
  app.run();
}
