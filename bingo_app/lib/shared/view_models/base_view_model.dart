import 'package:flutter/material.dart';

/// A base class for all ViewModels that provides loading state management
/// and integrates with ChangeNotifier for UI updates.
class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;

  /// Whether the ViewModel is currently busy with a task.
  bool get isLoading => _isLoading;

  /// Sets the loading state and notifies listeners.
  ///
  /// [value]: The new loading state.
  /// [notify]: Whether to call notifyListeners() after setting the state.
  ///           Defaults to true. Useful to set to false if you want to
  ///           batch multiple state changes before notifying the UI.
  void setLoading(bool value, {bool notify = true}) {
    if (_isLoading != value) {
      _isLoading = value;
      if (notify) {
        notifyListeners();
      }
    }
  }
}
