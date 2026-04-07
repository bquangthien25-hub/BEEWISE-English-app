/// Normalizes user input before hitting domain / data layers.
abstract final class InputConverter {
  static String trimLowerEmail(String raw) => raw.trim().toLowerCase();
}
