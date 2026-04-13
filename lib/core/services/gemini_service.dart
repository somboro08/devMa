// lib/core/services/gemini_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class GeminiMessage {
  final String role; // 'user' or 'model'
  final String content;

  GeminiMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'parts': [
          {'text': content}
        ],
      };
}

class GeminiService {
  GeminiService._();

  static const String _systemPrompt = '''
Tu es le Mentor IA de DevMa, le club de codage et développement du campus universitaire FAST (Université de Parakou, Bénin).

Ton rôle :
- Aider les membres à apprendre à coder (Python, Dart/Flutter, JavaScript, SQL, etc.)
- Expliquer des concepts de mathématiques et d'informatique clairement
- Corriger et améliorer du code fourni par les membres
- Préparer les membres aux hackathons et challenges techniques
- Motiver et encourager les étudiants, surtout les débutants

Ton style :
- Chaleureux, pédagogue et encourageant
- Utilise des analogies locales (contexte béninois/africain) pour expliquer les concepts
- Réponds en français
- Donne toujours des exemples de code concrets
- Adapte le niveau au contexte : si l'étudiant est débutant, simplifie au maximum
- Tu peux utiliser des emojis avec modération pour rendre l'apprentissage fun

Contexte DevMa :
- Club d'étudiants en technologie à l'université FAST de Parakou
- Technologies utilisées : Python, Flutter/Dart, React, FastAPI, Supabase, Firebase
- Objectifs : participer à des hackathons, créer des projets utiles pour l'Afrique de l'Ouest

Réponds toujours en markdown pour un meilleur rendu du code.
''';

  static final List<GeminiMessage> _conversationHistory = [];

  static void clearHistory() => _conversationHistory.clear();

  static Future<String> sendMessage(String userMessage) async {
    _conversationHistory.add(
      GeminiMessage(role: 'user', content: userMessage),
    );

    final url = Uri.parse(
      '${AppConstants.geminiApiUrl}?key=${AppConstants.geminiApiKey}',
    );

    final body = {
      'system_instruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': _conversationHistory.map((m) => m.toJson()).toList(),
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
      'safetySettings': [
        {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
        {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_MEDIUM_AND_ABOVE'},
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

        _conversationHistory.add(
          GeminiMessage(role: 'model', content: text),
        );

        return text;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Gemini API error: ${error['error']['message']}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion à l\'IA : $e');
    }
  }

  static Future<String> explainConcept(String concept, String level) async {
    final prompt = '''
Explique le concept de "$concept" de manière claire pour un étudiant de niveau "$level".
Utilise une analogie simple, puis donne un exemple de code pratique.
''';
    return sendMessage(prompt);
  }

  static Future<String> reviewCode(String code, String language) async {
    final prompt = '''
Voici du code $language. Analyse-le et :
1. Identifie les erreurs s'il y en a
2. Suggère des améliorations
3. Explique pourquoi chaque correction est importante

```$language
$code
```
''';
    return sendMessage(prompt);
  }

  static Future<String> generateQuizExplanation(
    String question,
    String correctAnswer,
    String userAnswer,
  ) async {
    final prompt = '''
Un étudiant a répondu à cette question de quiz :
Question : $question
Bonne réponse : $correctAnswer
Réponse de l'étudiant : $userAnswer

Explique pourquoi la bonne réponse est "$correctAnswer" de façon pédagogique.
''';
    return sendMessage(prompt);
  }

  static Future<String> hackathonAdvice(String projectIdea) async {
    final prompt = '''
Un étudiant de DevMa veut développer ce projet pour un hackathon : "$projectIdea"

Donne-lui :
1. Les points forts de cette idée
2. Les défis techniques à anticiper
3. Une architecture technique recommandée (stack Flutter/Python/Supabase)
4. Des conseils pour impressionner le jury
5. Une estimation du temps de développement sur 24h
''';
    return sendMessage(prompt);
  }
}
