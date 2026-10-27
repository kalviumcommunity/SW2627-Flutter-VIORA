import 'package:flutter/foundation.dart';
import '../models/beauty_quiz_model.dart';
import 'api_client.dart';

/// Service coordinating Beauty Quiz questions, submission, and personalized recommendations
class QuizService {
  static final QuizService _instance = QuizService._internal();
  factory QuizService() => _instance;
  QuizService._internal();

  final ApiClient _apiClient = ApiClient();
  QuizResultModel? _latestResult;

  QuizResultModel? get latestResult => _latestResult;

  /// Default Standardized Quiz Questions Schema (Matches Group 52.png & Backend)
  static List<QuizQuestion> get defaultQuestions => defaultQuizQuestions;

  static const List<QuizQuestion> defaultQuizQuestions = [
    QuizQuestion(
      id: 'hairType',
      stepNumber: 1,
      category: 'Hair Texture',
      title: 'What is your hair texture & type?',
      subtitle: 'Helps us tailor styling techniques and product weight.',
      isMultiSelect: false,
      required: true,
      options: [
        QuizOption(
          id: 'Straight',
          title: 'Straight',
          description: 'Fine to medium density with sleek, reflective finish',
          icon: 'straight',
        ),
        QuizOption(
          id: '2B Wavy',
          title: '2B Wavy',
          description: 'Defined S-waves with natural body and loose movement',
          icon: 'wavy',
        ),
        QuizOption(
          id: 'Curly',
          title: 'Curly',
          description: 'Bouncy spirals and loops that crave weightless hydration',
          icon: 'curly',
        ),
        QuizOption(
          id: 'Coily',
          title: 'Coily / Textured',
          description: 'Delicate tight coils requiring nourishing moisture locks',
          icon: 'coily',
        ),
      ],
    ),
    QuizQuestion(
      id: 'hairConcerns',
      stepNumber: 2,
      category: 'Hair Profile',
      title: 'What is your primary hair concern?',
      subtitle: 'Select one or more concerns for personalized treatment.',
      isMultiSelect: true,
      required: true,
      options: [
        QuizOption(
          id: 'Frizz Control',
          title: 'Frizz Control',
          description: 'Smoothing and hydration locks',
          icon: 'frizz',
        ),
        QuizOption(
          id: 'Volume & Lift',
          title: 'Volume & Lift',
          description: 'Adding body to flat layers',
          icon: 'volume',
        ),
        QuizOption(
          id: 'Color Maintenance',
          title: 'Color Maintenance',
          description: 'Preventing fade & brassy tones',
          icon: 'color',
        ),
        QuizOption(
          id: 'Damage Repair',
          title: 'Damage Repair',
          description: 'Treating heat and chemical wear',
          icon: 'damage',
        ),
        QuizOption(
          id: 'Scalp Health',
          title: 'Scalp Health',
          description: 'Deep cleansing and exfoliation',
          icon: 'scalp',
        ),
      ],
    ),
    QuizQuestion(
      id: 'skinType',
      stepNumber: 3,
      category: 'Skin Profile',
      title: 'How would you describe your skin profile?',
      subtitle: 'Enables tailored facials and biocompatible formulations.',
      isMultiSelect: false,
      required: true,
      options: [
        QuizOption(
          id: 'Combination',
          title: 'Combination',
          description: 'Oily T-zone with normal to dry cheeks',
          icon: 'combination',
        ),
        QuizOption(
          id: 'Dry & Dehydrated',
          title: 'Dry & Dehydrated',
          description: 'Tightness, dullness, or compromised moisture barrier',
          icon: 'dry',
        ),
        QuizOption(
          id: 'Balanced / Normal',
          title: 'Balanced / Normal',
          description: 'Even texture with calm, comfortable barrier',
          icon: 'normal',
        ),
        QuizOption(
          id: 'Sensitive / Reactive',
          title: 'Sensitive / Reactive',
          description: 'Easily irritated, prone to redness or reactivity',
          icon: 'sensitive',
        ),
        QuizOption(
          id: 'Oily / Congested',
          title: 'Oily / Congested',
          description: 'Persistent shine and prone to clogged pores',
          icon: 'oily',
        ),
      ],
    ),
    QuizQuestion(
      id: 'goals',
      stepNumber: 4,
      category: 'Beauty Goals',
      title: 'What are your main beauty & treatment goals?',
      subtitle: 'Your immediate priorities for in-salon and at-home rituals.',
      isMultiSelect: true,
      required: true,
      options: [
        QuizOption(
          id: 'Deep Hydration',
          title: 'Deep Hydration',
          description: 'Restoring long-lasting moisture, bounce, and suppleness',
          icon: 'hydration',
        ),
        QuizOption(
          id: 'Radiant Glow',
          title: 'Radiant Glow',
          description: 'Luminous complexion and polished, light-reflective shine',
          icon: 'glow',
        ),
        QuizOption(
          id: 'Bond Fortification',
          title: 'Bond Fortification',
          description: 'Strengthening cuticles, bond repair, and thermal defense',
          icon: 'fortify',
        ),
        QuizOption(
          id: 'Precision Style & Definition',
          title: 'Precision Style & Definition',
          description: 'Customized contour cuts, layer bounce, and sharp finish',
          icon: 'style',
        ),
      ],
    ),
    QuizQuestion(
      id: 'sensitivities',
      stepNumber: 5,
      category: 'Care Preferences',
      title: 'Do you have any ingredient or service preferences?',
      subtitle: 'We filter all recommended products and formulas accordingly.',
      isMultiSelect: true,
      required: false,
      options: [
        QuizOption(
          id: 'Sulfate & Paraben Free',
          title: 'Sulfate & Paraben Free',
          description: 'Gentle, clean salon formulations without harsh surfactants',
          icon: 'sulfate_free',
        ),
        QuizOption(
          id: 'Fragrance Sensitive',
          title: 'Fragrance Sensitive',
          description: 'Hypoallergenic, fragrance-neutral formulations',
          icon: 'fragrance_free',
        ),
        QuizOption(
          id: 'Vegan & Cruelty-Free',
          title: 'Vegan & Cruelty-Free',
          description: '100% plant-derived ethically certified care',
          icon: 'vegan',
        ),
        QuizOption(
          id: 'Ammonia / Bleach Sensitive',
          title: 'Ammonia / Bleach Sensitive',
          description: 'Zero-ammonia toning and gentle lift pigments',
          icon: 'ammonia_free',
        ),
        QuizOption(
          id: 'No Sensitivities',
          title: 'No Sensitivities',
          description: 'Open to all professional salon treatment lines',
          icon: 'all_clear',
        ),
      ],
    ),
  ];

  /// Fetch Quiz Questions from Backend API with local fallback
  Future<List<QuizQuestion>> getQuestions() async {
    try {
      final res = await _apiClient.get('/customers/quiz/questions', includeAuth: false);
      if (res is Map<String, dynamic> && res['success'] == true && res['data'] is List) {
        final rawList = res['data'] as List<dynamic>;
        final questions = rawList
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
        if (questions.isNotEmpty) {
          debugPrint('✅ [QuizService] Loaded ${questions.length} questions from backend');
          return questions;
        }
      }
    } on ApiException catch (e) {
      debugPrint('ℹ️ [QuizService] Questions endpoint notice (${e.statusCode}): ${e.message}');
    } catch (e) {
      debugPrint('ℹ️ [QuizService] Questions endpoint fallback: $e');
    }
    return defaultQuizQuestions;
  }

  /// Submit Quiz Answers to Backend API with deterministic fallback matching Group 53.png
  Future<QuizResultModel> submitQuiz(QuizAnswers answers) async {
    try {
      final res = await _apiClient.post(
        '/customers/quiz',
        body: answers.toJson(),
      );

      if (res is Map<String, dynamic> && res['success'] == true && res['data'] != null) {
        final result = QuizResultModel.fromJson(res['data'] as Map<String, dynamic>);
        _latestResult = result;
        debugPrint('✅ [QuizService] Quiz submitted to backend: ${result.profileArchetype}');
        return result;
      }
    } on ApiException catch (e) {
      debugPrint('ℹ️ [QuizService] Backend submission returned (${e.statusCode}): ${e.message}');
    } catch (e) {
      debugPrint('ℹ️ [QuizService] Backend submission fallback: $e');
    }

    // Deterministic fallback matching Group 53.png
    final fallbackResult = _generateFallbackResult(answers);
    _latestResult = fallbackResult;
    return fallbackResult;
  }

  /// Retrieve latest stored quiz result for the customer
  Future<QuizResultModel?> getLatestResult() async {
    if (_latestResult != null) return _latestResult;

    try {
      final res = await _apiClient.get('/customers/quiz');
      if (res is Map<String, dynamic> && res['success'] == true && res['data'] != null) {
        _latestResult = QuizResultModel.fromJson(res['data'] as Map<String, dynamic>);
        return _latestResult;
      }
    } on ApiException catch (e) {
      debugPrint('ℹ️ [QuizService] Remote quiz result check (${e.statusCode}): ${e.message}');
    } catch (e) {
      debugPrint('ℹ️ [QuizService] Failed to load remote quiz result: $e');
    }

    return null;
  }

  /// Retake quiz and reset current result
  Future<void> retakeQuiz() async {
    _latestResult = null;
    try {
      await _apiClient.post('/customers/quiz/retake');
    } on ApiException catch (e) {
      debugPrint('ℹ️ [QuizService] Retake API notice (${e.statusCode}): ${e.message}');
    } catch (e) {
      debugPrint('ℹ️ [QuizService] Retake API notice: $e');
    }
  }

  /// Deterministic result generator corresponding exactly to answers & Group 53.png
  QuizResultModel generateFallback(QuizAnswers answers) => _generateFallbackResult(answers);

  QuizResultModel _generateFallbackResult(QuizAnswers answers) {
    final hairType = answers.hairType ?? '2B Wavy';
    final skinType = answers.skinType ?? 'Combination';
    final concerns = answers.hairConcerns.isNotEmpty ? answers.hairConcerns : ['Volume & Lift'];

    // Profile Chips matching Group 53.png
    final chips = <String>[
      'Hair: $hairType',
      'Skin: $skinType',
      ...concerns.map((c) => 'Concern: $c'),
    ];

    String archetype = 'Airy Volume & Sleek Defiance';
    String summary =
        'Tailored for $hairType textures that need customized root lift and bounce without sacrificing smooth, frizz-resistant moisture locks.';

    if (hairType == 'Curly' || hairType == 'Coily') {
      archetype = 'Hydrated Curl Architecture';
      summary =
          'Focused on weightless hydration, curl elongation, and defining spiral bounce without build-up.';
    } else if (hairType == 'Straight') {
      archetype = 'Sleek Silk & Reflective Shine';
      summary =
          'Formulated for straight cuticle alignment, thermal protection, and mirror-finish glass gloss.';
    }

    final products = <RecommendedProduct>[
      const RecommendedProduct(
        productId: 'PROD-H-01',
        name: 'Maison Revital Serum',
        category: 'Hair',
        price: 1200,
        formattedPrice: '₹1,200',
        imageUrl:
            'https://images.unsplash.com/photo-1608248597359-2ff99479b188?w=400&auto=format&fit=crop&q=80',
        matchReason:
            'Restores weightless hydration and smooths cuticle frizz without weighing down wave patterns.',
        features: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free'],
      ),
      const RecommendedProduct(
        productId: 'PROD-H-02',
        name: 'Volumizing Sea Spray',
        category: 'Hair',
        price: 950,
        formattedPrice: '₹950',
        imageUrl:
            'https://images.unsplash.com/photo-1535585209827-a15fcdbc4c2d?w=400&auto=format&fit=crop&q=80',
        matchReason:
            'Adds textured grip, instant root lift, and effortless airy bounce to layered sections.',
        features: ['Sulfate & Paraben Free', 'Vegan & Cruelty-Free'],
      ),
    ];

    final services = <RecommendedService>[
      RecommendedService(
        serviceId: 'SERV-01',
        name: 'Premium Hair Spa',
        category: 'Hair',
        duration: 60,
        price: 1500,
        formattedPrice: 'From ₹1,500',
        description:
            'Specifically curated to restore hydration and reduce frizz for your $hairType hair texture.',
        matchReason: 'High priority treatment for immediate moisture replenishment.',
      ),
      const RecommendedService(
        serviceId: 'SERV-02',
        name: 'Couture Haircut & Style',
        category: 'Hair',
        duration: 45,
        price: 1800,
        formattedPrice: 'From ₹1,800',
        description:
            'Ideal for adding customized body, layers, and bounce to flat crown sections.',
        matchReason: 'Structural cut tailored to enhance natural movement.',
      ),
    ];

    return QuizResultModel(
      profileArchetype: archetype,
      summary: summary,
      profileChips: chips,
      products: products,
      services: services,
    );
  }
}
