
Step-by-Step Demo of Fitness & Diet Tracker

Step 1: Launch the App
After running:
dart run bin/main.dart
You will see:
=== FITNESS & DIET TRACKER ===
1) Register
2) Login
3) Exit
Choose:
Type 1 → Register a new user.
________________________________________
Step 2: Register a User
Username: khizar
Password (min 4 chars): 1234
Age (10-100): 22
Height in cm (100-230): 170
Weight in kg (30-300): 65
Goal: 1) weightLoss  2) maintenance  3) muscleGain
Choose goal: 1
Daily calorie limit (800-6000): 2000
 Output:
Registration successful and logged in!
User: khizar | Age: 22 | H: 170.0 cm | W: 65.0 kg | Goal: weightLoss | Daily Limit: 2000 kcal | BMI: 22.5 (Normal)
________________________________________
Step 3: Main Menu
=== MAIN MENU (khizar) ===
1) View Profile
2) Update Profile / Goal / Daily Limit
3) Log Food Intake
4) Log Workout
5) Today Summary
6) View History (select date)
7) Quick Add (Saved Meals/Workouts)
8) Smart Suggestions
9) Logout
Choose:
________________________________________
Step 4: Log Food Intake
Choose 3 → Log Food:
Food item: Chicken Salad
Calories: 400
Save this meal to Quick Add? (y/n): y
 Saved meal 'Chicken Salad' to Quick Add.
 Added: [2025-08-21 15:45:30.000] Food: Chicken Salad | 400 kcal
________________________________________
Step 5: Log Workout
Choose 4 → Log Workout:
Workout name: Jogging
Calories burned: 250
Save this workout to Quick Add? (y/n): y
 Saved workout 'Jogging' to Quick Add.
 Added: [2025-08-21 15:50:10.000] Workout: Jogging | Burned: 250 kcal
________________________________________
Step 6: Today Summary
Choose 5 → Today Summary:
--- Today Summary (2025-08-21) ---
Daily Limit: 2000 kcal

Foods:
  Chicken Salad - 400 kcal

Workouts:
  Jogging - 250 kcal

Total Intake: 400 kcal
Total Burned: 250 kcal
Remaining Intake Budget: 1600 kcal
________________________________________
Step 7: Quick Add (Saved Meals / Workouts)
Choose 7 → Quick Add:
--- Quick Add ---
1) Add Saved Meal
2) Add Saved Workout
3) Manage Saved Items
Choose: 1
1) Chicken Salad
Select meal #: 1
Calories for 'Chicken Salad': 400
 Added Quick Meal: [2025-08-21 16:00:00.000] Food: Chicken Salad | 400 kcal
________________________________________
Step 8: Smart Suggestions
Choose 8 → Smart Suggestions:
--- Smart Suggestions ---
BMI: 22.5 (Normal), Goal: weightLoss
Daily Limit: 2000 kcal | Adjusted Target for Goal: 1700 kcal

Diet Plan Ideas (today):
- Balanced meal possible (~1300 kcal): lean protein + complex carbs + veggies.

Workout Suggestions:
- Mix 20 min moderate cardio + 20 min strength training.
- No workout logged today. Even a 15–20 min session can help (jump rope, walk, bodyweight squats).
________________________________________
Step 9: View History
Choose 6 → View History:
Enter date (YYYY-MM-DD), empty for today: 
--- History for 2025-08-21 ---
Foods:
  Chicken Salad - 400 kcal
  Chicken Salad - 400 kcal

Workouts:
  Jogging - 250 kcal

Total Intake: 800 kcal
Total Burned: 250 kcal
________________________________________
Step 10: Logout
Choose 9 → Logout:
Logged out.
________________________________________



Main Features
1.	User Management
o	Register with validation (username, password, age, height, weight, goal, daily limit).
o	Login system.
o	Update profile anytime.
2.	Food Logging
o	Log meals with calories.
o	Restriction → Cannot log food if it exceeds daily calorie limit.
o	Quick Add → Save favorite meals for future.
3.	Workout Logging
o	Log workouts with calories burned.
o	Quick Add → Save workouts for faster entry.
4.	Daily & History Summaries
o	View today’s summary (intake, burned, remaining calories).
o	Check history for any past date.
5.	Smart Suggestions
o	Based on BMI, daily limit, and goal (weight loss, maintenance, muscle gain).
o	Suggests diet + workouts dynamically.
o	Encourages healthy habits.
6.	Validation Everywhere
o	Age, height, weight ranges.
o	Calories not unrealistically high.
o	Empty inputs blocked.


