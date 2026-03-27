import '../models/guest_pass.dart';

class GuestPassService {
  static final List<GuestPass> _passes = [];

  static void addPass(GuestPass pass) {
    _passes.add(pass);
  }

  static GuestPass? findById(String id) {
    try {
      return _passes.firstWhere((pass) => pass.id == id);
    } catch (_) {
      return null;
    }
  }

  static GuestPassValidationResult validatePass(String id) {
    final pass = findById(id);
    if (pass == null) {
      return GuestPassValidationResult(
        isValid: false,
        message: 'Пропуск не найден',
      );
    }

    final now = DateTime.now();

    if (pass.isUsed) {
      return GuestPassValidationResult(
        isValid: false,
        message: 'Пропуск уже использован',
        pass: pass,
      );
    }

    if (now.isBefore(pass.validFrom)) {
      return GuestPassValidationResult(
        isValid: false,
        message: 'Пропуск еще не активен',
        pass: pass,
      );
    }

    if (now.isAfter(pass.validTo)) {
      return GuestPassValidationResult(
        isValid: false,
        message: 'Срок пропуска истек',
        pass: pass,
      );
    }

    return GuestPassValidationResult(
      isValid: true,
      message: 'Доступ разрешен',
      pass: pass,
    );
  }

  static void markUsed(String id) {
    final pass = findById(id);
    if (pass != null) {
      pass.isUsed = true;
    }
  }

  static List<GuestPass> getAllPasses() {
    return List.unmodifiable(_passes.reversed);
  }
}

class GuestPassValidationResult {
  final bool isValid;
  final String message;
  final GuestPass? pass;

  GuestPassValidationResult({
    required this.isValid,
    required this.message,
    this.pass,
  });
}