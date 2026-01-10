/// Defines the contract for an audio driver, used for the Megafone feature.
abstract class IAudioDriver {
  /// Requests microphone permission from the user.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission();

  /// Starts the loopback functionality, piping audio from the microphone to the speaker.
  Future<void> startLoopback();

  /// Stops the loopback functionality.
  Future<void> stopLoopback();

  /// An optional stream of the microphone's input volume.
  /// This can be used to create a sound wave animation in the UI.
  Stream<double> get volumeStream;
}
