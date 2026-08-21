/// BMI-category-driven recommendation engine.
///
/// Single source of truth for turning a BMI category into general,
/// informational nutrition guidance, a suggested meal structure, and
/// workout recommendations. These are intentionally general suggestions,
/// NOT personalized medical prescriptions — the system does not make
/// medical claims (see Project Scope / Delimitation in the project paper).
library;

/// A single food-guidance card entry (e.g. "Prioritize", "Limit").
class NutritionGuidance {
  final String title;
  final String detail;
  final List<String> examples;

  const NutritionGuidance({
    required this.title,
    required this.detail,
    required this.examples,
  });
}

class MealSuggestion {
  final String mealName; // Breakfast / Lunch / Dinner / Snack
  final String suggestion;
  final String description;

  const MealSuggestion({
    required this.mealName,
    required this.suggestion,
    required this.description,
  });
}

class WorkoutSuggestion {
  final String type;
  final String duration;
  final String intensity;
  final String description;

  const WorkoutSuggestion({
    required this.type,
    required this.duration,
    required this.intensity,
    required this.description,
  });
}

class RecommendationEngine {
  RecommendationEngine._();

  static const String medicalDisclaimer =
      'These are general, informational suggestions based on your BMI '
      'category — not a medical prescription or clinical diagnosis. '
      'Consult a healthcare professional for personalized advice.';

  /// General nutrition guidance for a BMI category.
  static List<NutritionGuidance> nutritionFor(String category) {
    switch (category) {
      case 'Underweight':
        return const [
          NutritionGuidance(
            title: 'Prioritize',
            detail:
                'Energy- and nutrient-dense foods to support healthy weight gain.',
            examples: ['Whole milk & dairy', 'Nuts & nut butters', 'Whole grains', 'Lean meat, eggs, fish'],
          ),
          NutritionGuidance(
            title: 'Eat more often',
            detail: 'Frequent, smaller meals are easier to keep up with than three large ones.',
            examples: ['5–6 meals/snacks a day', 'Add healthy snacks between meals'],
          ),
          NutritionGuidance(
            title: 'Limit',
            detail: 'Low-nutrient foods that fill you up without providing enough energy or nutrients.',
            examples: ['Excess black coffee/tea before meals', 'Very low-calorie diet foods'],
          ),
          NutritionGuidance(
            title: 'Healthy habits',
            detail: 'Stay hydrated and pair meals with light activity to support appetite.',
            examples: ['6–8 glasses of water daily', 'Light activity to stimulate appetite'],
          ),
        ];
      case 'Overweight':
        return const [
          NutritionGuidance(
            title: 'Prioritize',
            detail: 'High-fiber, high-protein foods that help you feel full for longer.',
            examples: ['Vegetables & fruits', 'Lean protein (chicken, fish, tofu)', 'Whole grains'],
          ),
          NutritionGuidance(
            title: 'Portion control',
            detail: 'Moderate portions and regular meal timing help manage overall intake.',
            examples: ['3 balanced meals a day', 'Use smaller plates/bowls'],
          ),
          NutritionGuidance(
            title: 'Limit',
            detail: 'Foods high in added sugar, refined carbs, and fried oil.',
            examples: ['Sugary drinks & desserts', 'Fried & fast food', 'White rice/bread in excess'],
          ),
          NutritionGuidance(
            title: 'Healthy habits',
            detail: 'Drink water instead of sugary drinks, and avoid eating late at night.',
            examples: ['8+ glasses of water daily', 'Avoid heavy meals close to bedtime'],
          ),
        ];
      case 'Obese':
        return const [
          NutritionGuidance(
            title: 'Prioritize',
            detail: 'Whole, minimally processed foods with plenty of vegetables and lean protein.',
            examples: ['Non-starchy vegetables', 'Lean protein', 'Legumes & beans', 'Whole fruit'],
          ),
          NutritionGuidance(
            title: 'Portion control',
            detail: 'Structured, controlled portions with consistent meal timing.',
            examples: ['3 meals + 1 light snack', 'Fill half the plate with vegetables'],
          ),
          NutritionGuidance(
            title: 'Limit',
            detail: 'Calorie-dense, low-nutrient foods and sugary beverages.',
            examples: ['Sugary drinks & sweets', 'Fried & fast food', 'Processed/packaged snacks'],
          ),
          NutritionGuidance(
            title: 'Healthy habits',
            detail: 'Stay well hydrated and consider professional guidance for a sustainable plan.',
            examples: ['8+ glasses of water daily', 'Consult a dietitian for a tailored plan'],
          ),
        ];
      case 'Normal':
      default:
        return const [
          NutritionGuidance(
            title: 'Prioritize',
            detail: 'A balanced mix of food groups to maintain your current healthy status.',
            examples: ['Vegetables & fruits', 'Whole grains', 'Lean protein', 'Healthy fats'],
          ),
          NutritionGuidance(
            title: 'Maintain balance',
            detail: 'Consistent, balanced meals help you stay in your current healthy range.',
            examples: ['3 balanced meals a day', 'Moderate healthy snacks'],
          ),
          NutritionGuidance(
            title: 'Limit',
            detail: 'Occasional treats are fine — keep highly processed food occasional, not routine.',
            examples: ['Sugary drinks', 'Highly processed snacks'],
          ),
          NutritionGuidance(
            title: 'Healthy habits',
            detail: 'Keep up regular hydration and consistent meal timing.',
            examples: ['6–8 glasses of water daily', 'Regular meal schedule'],
          ),
        ];
    }
  }

  /// Suggested Breakfast / Lunch / Dinner meal plan for a BMI category.
  static List<MealSuggestion> mealPlanFor(String category) {
    switch (category) {
      case 'Underweight':
        return const [
          MealSuggestion(
            mealName: 'Breakfast',
            suggestion: 'Whole grain toast, peanut butter, banana & milk',
            description: 'A calorie- and protein-rich start to the day.',
          ),
          MealSuggestion(
            mealName: 'Lunch',
            suggestion: 'Rice, grilled chicken/fish, sautéed vegetables',
            description: 'Balanced, energy-dense meal with lean protein.',
          ),
          MealSuggestion(
            mealName: 'Dinner',
            suggestion: 'Pasta or rice with lean meat and vegetables',
            description: 'A satisfying dinner that supports steady weight gain.',
          ),
          MealSuggestion(
            mealName: 'Snack',
            suggestion: 'Nuts, cheese, or a fruit smoothie',
            description: 'Optional nutrient-dense snack between meals.',
          ),
        ];
      case 'Overweight':
        return const [
          MealSuggestion(
            mealName: 'Breakfast',
            suggestion: 'Oatmeal with fruit, or eggs with vegetables',
            description: 'High-fiber, protein-forward breakfast to curb mid-morning hunger.',
          ),
          MealSuggestion(
            mealName: 'Lunch',
            suggestion: 'Grilled chicken/fish, brown rice, mixed vegetables',
            description: 'Balanced plate with lean protein and fiber.',
          ),
          MealSuggestion(
            mealName: 'Dinner',
            suggestion: 'Light soup or salad with lean protein',
            description: 'A lighter evening meal, eaten earlier where possible.',
          ),
          MealSuggestion(
            mealName: 'Snack',
            suggestion: 'Fresh fruit or a handful of nuts',
            description: 'Optional light snack if needed between meals.',
          ),
        ];
      case 'Obese':
        return const [
          MealSuggestion(
            mealName: 'Breakfast',
            suggestion: 'Boiled eggs with vegetables, or plain oatmeal',
            description: 'Low-glycemic, high-protein start to keep portions controlled.',
          ),
          MealSuggestion(
            mealName: 'Lunch',
            suggestion: 'Grilled fish/chicken, steamed vegetables, small rice portion',
            description: 'Structured portions built around vegetables and lean protein.',
          ),
          MealSuggestion(
            mealName: 'Dinner',
            suggestion: 'Vegetable soup or salad with lean protein',
            description: 'A light, early dinner to support a calorie-controlled routine.',
          ),
          MealSuggestion(
            mealName: 'Snack',
            suggestion: 'Cucumber, carrot sticks, or plain yogurt',
            description: 'Optional low-calorie snack, if needed.',
          ),
        ];
      case 'Normal':
      default:
        return const [
          MealSuggestion(
            mealName: 'Breakfast',
            suggestion: 'Whole grain cereal or eggs with fruit',
            description: 'A balanced breakfast to maintain steady energy.',
          ),
          MealSuggestion(
            mealName: 'Lunch',
            suggestion: 'Rice, grilled protein, mixed vegetables',
            description: 'A well-rounded plate across all food groups.',
          ),
          MealSuggestion(
            mealName: 'Dinner',
            suggestion: 'Light rice or noodle dish with vegetables and protein',
            description: 'A moderate dinner to keep your current healthy balance.',
          ),
          MealSuggestion(
            mealName: 'Snack',
            suggestion: 'Fruit, yogurt, or a small handful of nuts',
            description: 'Optional balanced snack between meals.',
          ),
        ];
    }
  }

  /// Suggested workout type / duration / intensity for a BMI category.
  static List<WorkoutSuggestion> workoutsFor(String category) {
    switch (category) {
      case 'Underweight':
        return const [
          WorkoutSuggestion(
            type: 'Strength Training',
            duration: '30 minutes',
            intensity: 'Moderate',
            description: 'Light resistance training to build muscle mass alongside weight gain.',
          ),
          WorkoutSuggestion(
            type: 'Walking',
            duration: '20 minutes',
            intensity: 'Light',
            description: 'Gentle cardio to support overall fitness without excess calorie burn.',
          ),
          WorkoutSuggestion(
            type: 'Stretching / Yoga',
            duration: '15 minutes',
            intensity: 'Light',
            description: 'Improves flexibility and recovery between strength sessions.',
          ),
        ];
      case 'Overweight':
        return const [
          WorkoutSuggestion(
            type: 'Walking / Brisk Walking',
            duration: '30 minutes',
            intensity: 'Moderate',
            description: 'Accessible cardio that can be done most days of the week.',
          ),
          WorkoutSuggestion(
            type: 'Cycling',
            duration: '30 minutes',
            intensity: 'Moderate',
            description: 'Low-impact cardio that builds endurance.',
          ),
          WorkoutSuggestion(
            type: 'Bodyweight Strength Training',
            duration: '20 minutes',
            intensity: 'Moderate',
            description: 'Builds lean muscle to support a healthy metabolism.',
          ),
        ];
      case 'Obese':
        return const [
          WorkoutSuggestion(
            type: 'Walking',
            duration: '20–30 minutes',
            intensity: 'Light to Moderate',
            description: 'A low-impact starting point that is easy on the joints.',
          ),
          WorkoutSuggestion(
            type: 'Swimming / Water Aerobics',
            duration: '20 minutes',
            intensity: 'Light',
            description: 'Low-impact, full-body activity that is gentle on joints.',
          ),
          WorkoutSuggestion(
            type: 'Seated / Chair Exercises',
            duration: '15 minutes',
            intensity: 'Light',
            description: 'A gentle option to build activity tolerance before progressing further.',
          ),
        ];
      case 'Normal':
      default:
        return const [
          WorkoutSuggestion(
            type: 'Brisk Walking / Jogging',
            duration: '30 minutes',
            intensity: 'Moderate',
            description: 'Maintains cardiovascular fitness and current healthy status.',
          ),
          WorkoutSuggestion(
            type: 'Strength Training',
            duration: '30 minutes',
            intensity: 'Moderate',
            description: 'Builds and preserves lean muscle mass.',
          ),
          WorkoutSuggestion(
            type: 'Recreational Sport / Cycling',
            duration: '30–45 minutes',
            intensity: 'Moderate',
            description: 'An enjoyable way to stay active and maintain your balance.',
          ),
        ];
    }
  }
}
