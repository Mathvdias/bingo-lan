import 'package:flutter/material.dart';
import 'package:bingo_app/shared/di/service_locator.dart';
import 'package:bingo_app/shared/view_models/base_view_model.dart';

/// A provider widget that handles the lifecycle of a ViewModel.
///
/// It retrieves a ViewModel instance from the [serviceLocator], provides it
/// to its builder, and automatically disposes of the ViewModel when the
/// widget is removed from the widget tree.
class ViewModelProvider<T extends BaseViewModel> extends StatefulWidget {
  final Widget Function(BuildContext context, T viewModel, Widget? child) builder;
  final Widget? child;
  final Function(T viewModel)? onReady;
  final Object? param1;
  final Object? param2;

  const ViewModelProvider({
    super.key,
    required this.builder,
    this.child,
    this.onReady,
    this.param1,
    this.param2,
  });

  @override
  State<ViewModelProvider<T>> createState() => _ViewModelProviderState<T>();
}

class _ViewModelProviderState<T extends BaseViewModel> extends State<ViewModelProvider<T>> {
  late T _viewModel;

  @override
  void initState() {
    super.initState();
    // Retrieve the ViewModel from the service locator, passing parameters if provided.
    _viewModel = serviceLocator<T>(param1: widget.param1, param2: widget.param2);
    // Optionally call the onReady callback.
    widget.onReady?.call(_viewModel);
  }

  @override
  void dispose() {
    // Dispose the ViewModel when the widget is disposed.
    // get_it can also handle this if the disposal logic is registered.
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use ListenableBuilder to automatically rebuild the UI
    // when the ViewModel calls notifyListeners().
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (BuildContext context, Widget? child) {
        return widget.builder(context, _viewModel, child);
      },
      child: widget.child,
    );
  }
}
