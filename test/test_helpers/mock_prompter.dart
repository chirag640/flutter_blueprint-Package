import 'package:flutter_blueprint/src/prompts/interactive_prompter.dart';

/// Mock implementation of InteractivePrompter for testing
class MockInteractivePrompter extends InteractivePrompter {
  bool isInteractiveValue = false;
  String mockPromptResponse = 'mock_response';
  String mockChooseResponse = 'mock_choice';
  bool mockConfirmResponse = true;
  List<String> mockMultiSelectResponse = [];

  int promptCallCount = 0;
  int chooseCallCount = 0;
  int confirmCallCount = 0;
  int multiSelectCallCount = 0;

  @override
  bool get isInteractive => isInteractiveValue;

  @override
  Future<String> prompt(String question, {String? defaultValue}) async {
    promptCallCount++;
    return mockPromptResponse;
  }

  @override
  Future<String> choose(
    String question,
    List<String> options, {
    String? defaultValue,
  }) async {
    chooseCallCount++;
    return mockChooseResponse;
  }

  @override
  Future<bool> confirm(String question, {bool defaultValue = true}) async {
    confirmCallCount++;
    return mockConfirmResponse;
  }

  @override
  Future<List<String>> multiSelect(
    String question,
    List<String> options, {
    List<String>? defaultValues,
  }) async {
    multiSelectCallCount++;
    return mockMultiSelectResponse;
  }

  void reset() {
    promptCallCount = 0;
    chooseCallCount = 0;
    confirmCallCount = 0;
    multiSelectCallCount = 0;
    isInteractiveValue = false;
    mockPromptResponse = 'mock_response';
    mockChooseResponse = 'mock_choice';
    mockConfirmResponse = true;
    mockMultiSelectResponse = [];
  }
}
