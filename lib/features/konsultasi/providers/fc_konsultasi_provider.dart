import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/fc_question_model.dart';
import '../../../core/models/diagnosis_model.dart';
import '../../../core/services/fc_service.dart';

/// Konsultasi State untuk backend-based diagnosis
class FCKonsultasiState {
  final List<FCQuestionModel> questions;
  final Map<String, String> answers;
  final int currentStep;
  final int ageInMonths;
  final String? childName;
  final String? childId;
  final DiagnosisModel? result;
  final bool isLoading;
  final String? error;

  const FCKonsultasiState({
    this.questions = const [],
    this.answers = const {},
    this.currentStep = 0,
    this.ageInMonths = 0,
    this.childName,
    this.childId,
    this.result,
    this.isLoading = false,
    this.error,
  });

  FCKonsultasiState copyWith({
    List<FCQuestionModel>? questions,
    Map<String, String>? answers,
    int? currentStep,
    int? ageInMonths,
    String? childName,
    String? childId,
    DiagnosisModel? result,
    bool? isLoading,
    String? error,
  }) {
    return FCKonsultasiState(
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      currentStep: currentStep ?? this.currentStep,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      childName: childName ?? this.childName,
      childId: childId ?? this.childId,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get answeredCount => answers.length;
  int get totalQuestions => questions.length;
  double get progress => totalQuestions > 0 ? answeredCount / totalQuestions : 0;
}

class FCKonsultasiNotifier extends StateNotifier<FCKonsultasiState> {
  final FCService _fcService;

  FCKonsultasiNotifier(this._fcService) : super(const FCKonsultasiState());

  void initializeWithChild({
    required String childId,
    required String childName,
    required int ageInMonths,
  }) {
    final questions = _fcService.getQuestionsForAge(ageInMonths);

    state = FCKonsultasiState(
      questions: questions,
      answers: {},
      currentStep: 0,
      ageInMonths: ageInMonths,
      childName: childName,
      childId: childId,
    );
  }

  void setAnswer(String key, String value) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers[key] = value;
    state = state.copyWith(answers: newAnswers);
  }

  void removeAnswer(String key) {
    final newAnswers = Map<String, String>.from(state.answers);
    newAnswers.remove(key);
    state = state.copyWith(answers: newAnswers);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  void setResult(DiagnosisModel result) {
    state = state.copyWith(result: result, isLoading: false, currentStep: 2);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(isLoading: false, error: error);
  }

  void reset() {
    state = const FCKonsultasiState();
  }

  Map<String, dynamic> getMilestoneInfo() {
    return _fcService.getMilestoneInfo(state.ageInMonths);
  }

  bool canProceedToQuestions() {
    return state.ageInMonths > 0;
  }

  bool canSubmitDiagnosis() {
    return state.answers.isNotEmpty;
  }
}

final fcServiceProvider = Provider<FCService>((ref) {
  return FCService();
});

final fcKonsultasiProvider =
    StateNotifierProvider<FCKonsultasiNotifier, FCKonsultasiState>((ref) {
  final fcService = ref.watch(fcServiceProvider);
  return FCKonsultasiNotifier(fcService);
});