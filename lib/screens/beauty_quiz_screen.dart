import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/beauty_quiz_model.dart';
import '../services/quiz_service.dart';
import 'beauty_quiz_result_screen.dart';

/// Beauty Quiz Screen matching Group 52.png
/// Provides step-by-step beauty diagnostic consultation with answer persistence and validation
class BeautyQuizScreen extends StatefulWidget {
  final bool reset;

  const BeautyQuizScreen({super.key, this.reset = false});

  @override
  State<BeautyQuizScreen> createState() => _BeautyQuizScreenState();
}

class _BeautyQuizScreenState extends State<BeautyQuizScreen> {
  final QuizService _quizService = QuizService();

  List<QuizQuestion> _questions = [];
  bool _isLoadingQuestions = true;
  String? _questionsError;

  int _currentStep = 0;
  final QuizAnswers _answers = QuizAnswers();
  bool _isSubmitting = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    if (widget.reset) {
      _quizService.retakeQuiz();
    }
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
      _questionsError = null;
    });

    try {
      final questions = await _quizService.getQuestions();
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoadingQuestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _questionsError = 'Unable to load quiz questions. Please check your connection.';
          _isLoadingQuestions = false;
        });
      }
    }
  }

  void _onOptionTapped(QuizQuestion question, String optionId) {
    setState(() {
      _answers.toggleOption(question, optionId);
      _validationError = null;
    });
  }

  void _onNextPressed() {
    if (_questions.isEmpty) return;

    final currentQuestion = _questions[_currentStep];
    if (currentQuestion.required && !_answers.isStepAnswered(currentQuestion)) {
      setState(() {
        _validationError = 'Please select an option to continue.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.textPrimary,
          content: Text('Please select at least one option before proceeding.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
        _validationError = null;
      });
    } else {
      _submitQuiz();
    }
  }

  void _onBackPressed() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _validationError = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submitQuiz() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _validationError = null;
    });

    try {
      final result = await _quizService.submitQuiz(_answers);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => BeautyQuizResultScreen(result: result),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _validationError = 'Submission failed: $e. Please tap submit again.';
        _isSubmitting = false;
      });
    }
  }

  IconData _getQuizIcon(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'straight':
        return Icons.straighten_outlined;
      case 'wavy':
        return Icons.waves_outlined;
      case 'curly':
        return Icons.all_inclusive_outlined;
      case 'coily':
        return Icons.blur_on_outlined;
      case 'frizz':
        return Icons.air_outlined;
      case 'volume':
        return Icons.auto_awesome_outlined;
      case 'color':
        return Icons.color_lens_outlined;
      case 'damage':
        return Icons.favorite_border;
      case 'scalp':
        return Icons.eco_outlined;
      case 'combination':
        return Icons.pie_chart_outline;
      case 'dry':
        return Icons.opacity_outlined;
      case 'normal':
        return Icons.sentiment_satisfied_outlined;
      case 'sensitive':
        return Icons.shield_outlined;
      case 'oily':
        return Icons.flare_outlined;
      case 'hydration':
        return Icons.water_drop_outlined;
      case 'glow':
        return Icons.auto_awesome;
      case 'fortify':
        return Icons.verified_outlined;
      case 'style':
        return Icons.content_cut_outlined;
      case 'sulfate_free':
        return Icons.eco;
      case 'fragrance_free':
        return Icons.air;
      case 'vegan':
        return Icons.park_outlined;
      case 'ammonia_free':
        return Icons.clean_hands_outlined;
      case 'all_clear':
        return Icons.done_all;
      default:
        return Icons.spa_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: GestureDetector(
              onTap: _onBackPressed,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Beauty Quiz',
          style: AppTextStyles.editorialTitle(fontSize: 22)
              .copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingQuestions) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Preparing your bespoke beauty consultation...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_questionsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 14),
              Text(
                'Consultation Offline',
                style: AppTextStyles.editorialTitle(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                _questionsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('RETRY'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentStep];
    final progress = (_currentStep + 1) / _questions.length;

    return Column(
      children: [
        // Step Header & Progress Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STEP ${_currentStep + 1} OF ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    question.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3.5,
                  backgroundColor: const Color(0xFFEBE5DD),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Scrollable Question & Options
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  question.title,
                  style: AppTextStyles.editorialTitle(fontSize: 26)
                      .copyWith(height: 1.25, color: AppColors.textPrimary),
                ),
                if (question.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    question.subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: question.options.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final opt = question.options[index];
                    final isSelected = _answers.isOptionSelected(question, opt.id);

                    return GestureDetector(
                      onTap: () => _onOptionTapped(question, opt.id),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFAF6F0) : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.border,
                            width: isSelected ? 1.5 : 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isSelected ? 0.04 : 0.015),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Icon container
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryLight : const Color(0xFFF3EFEA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                _getQuizIcon(opt.icon),
                                size: 19,
                                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Option Title & Description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (opt.description.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      opt.description,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Selection Checkmark
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.check,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Note at bottom of options
                const Center(
                  child: Text(
                    'Your answers combined with your service history help us personalize recommendations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        if (_validationError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: const Color(0xFFFFF0ED),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFC04B37), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _validationError!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFC04B37),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Bottom CTA Button (NEXT / SUBMIT QUIZ)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _currentStep == _questions.length - 1 ? 'SUBMIT QUIZ' : 'NEXT',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
