// Placeholder question catalog — verify facts before production use.

import '../models/quiz_question.dart';

const List<QuizQuestion> quizCatalog = [
  // ── Heat ──────────────────────────────────────────────────────────
  QuizQuestion(
    id: 'heat_01',
    cube: ClimateCube.heat,
    questionText: 'What is the urban heat island effect?',
    options: [
      'Cities are cooler than their surroundings',
      'Cities are warmer than their surroundings due to concrete and asphalt',
      'Islands near the equator receive more sun',
      'Parks generate heat through photosynthesis',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'heat_02',
    cube: ClimateCube.heat,
    questionText:
        'At what time of day does Madrid typically reach its highest temperature?',
    options: [
      'Around 8:00 AM',
      'Around 12:00 noon',
      'Between 3:00 and 5:00 PM',
      'After 8:00 PM',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    id: 'heat_03',
    cube: ClimateCube.heat,
    questionText: 'Which surface absorbs and stores the most heat?',
    options: [
      'Grass lawn',
      'Light-colored stone',
      'Dark asphalt',
      'Water surface',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    id: 'heat_04',
    cube: ClimateCube.heat,
    questionText:
        'How many consecutive days above 40 °C did Madrid record in summer 2023?',
    options: [
      '2 days',
      '5 days',
      '10 days',
      '15 days',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'heat_05',
    cube: ClimateCube.heat,
    questionText:
        'Which Madrid district tends to be hottest due to high building density?',
    options: [
      'Retiro',
      'Centro',
      'Casa de Campo',
      'El Pardo',
    ],
    correctIndex: 1,
  ),

  // ── Health ────────────────────────────────────────────────────────
  QuizQuestion(
    id: 'health_01',
    cube: ClimateCube.health,
    questionText: 'What is an early sign of heat stroke?',
    options: [
      'Intense shivering',
      'Dizziness and confusion',
      'Increased appetite',
      'Lower heart rate',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'health_02',
    cube: ClimateCube.health,
    questionText: 'Which group is most vulnerable to extreme heat?',
    options: [
      'Teenagers',
      'Adults aged 20–40',
      'Elderly people and small children',
      'Professional athletes',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    id: 'health_03',
    cube: ClimateCube.health,
    questionText:
        'How much water should an adult drink daily during a Madrid heat wave?',
    options: [
      'About 0.5 liters',
      'About 1 liter',
      'At least 2–3 liters',
      'Exactly 5 liters',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    id: 'health_04',
    cube: ClimateCube.health,
    questionText:
        'What should you do first if someone shows symptoms of heat exhaustion?',
    options: [
      'Give them a hot drink',
      'Move them to a cool place and offer water',
      'Tell them to exercise to sweat it out',
      'Apply sunscreen',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'health_05',
    cube: ClimateCube.health,
    questionText: 'Why is exercising outdoors at midday dangerous during a heat wave?',
    options: [
      'UV radiation is lowest at midday',
      'The body cannot cool itself efficiently in extreme heat',
      'Wind speed is highest at noon',
      'Humidity drops to zero',
    ],
    correctIndex: 1,
  ),

  // ── Solutions ─────────────────────────────────────────────────────
  QuizQuestion(
    id: 'solutions_01',
    cube: ClimateCube.solutions,
    questionText: 'How do urban trees help reduce heat?',
    options: [
      'They reflect sunlight into space',
      'They provide shade and cool the air through evapotranspiration',
      'They absorb heat and store it underground',
      'They block wind and trap cool air',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'solutions_02',
    cube: ClimateCube.solutions,
    questionText: 'What type of building facade helps reduce indoor temperatures?',
    options: [
      'Dark glass curtain wall',
      'Uninsulated concrete',
      'Green facade with climbing plants',
      'Metal sheet cladding',
    ],
    correctIndex: 2,
  ),
  QuizQuestion(
    id: 'solutions_03',
    cube: ClimateCube.solutions,
    questionText: 'What is the purpose of public drinking fountains during heat waves?',
    options: [
      'Decorative use only',
      'Providing free hydration to prevent heat-related illness',
      'Cooling the pavement through overflow',
      'Attracting tourists to the area',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'solutions_04',
    cube: ClimateCube.solutions,
    questionText: 'Which roof type keeps buildings coolest in summer?',
    options: [
      'Black tar roof',
      'Reflective white or green roof',
      'Wooden shingle roof',
      'Uncoated metal roof',
    ],
    correctIndex: 1,
  ),
  QuizQuestion(
    id: 'solutions_05',
    cube: ClimateCube.solutions,
    questionText:
        'What is Madrid\'s "refugios climáticos" program?',
    options: [
      'A network of underground bunkers',
      'Designated cool public spaces open during heat waves',
      'A rain-harvesting initiative',
      'An air-conditioning subsidy for homes',
    ],
    correctIndex: 1,
  ),
];
