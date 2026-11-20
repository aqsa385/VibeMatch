/// One password requirement: shown in the live checklist and used for errors.
class PasswordRule {
  const PasswordRule(this.label, this.error, this.test);

  final String label; // shown in the checklist
  final String error; // shown as the validation error
  final bool Function(String) test;
}

/// All form validators in one place. Each returns null when the value is
/// valid, or an error message to show under the field.
class Validators {
  Validators._();

  static const int minAge = 13; // change if your app needs a different limit
  static const int maxAge = 120;

  // Letters from any language, with single spaces, hyphens or apostrophes
  // between words (Aqsa, Mary-Jane, O'Neil).
  static final RegExp _nameRegex =
  RegExp(r"^\p{L}+(?:[ '\-]\p{L}+)*$", unicode: true);

  static final RegExp _emailRegex = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  static const Set<String> _commonPasswords = {
    'password',
    'password1',
    'password123',
    '12345678',
    '123456789',
    'qwerty123',
    'iloveyou',
    'admin123',
    'welcome1',
    'letmein123',
  };

  static final List<PasswordRule> passwordRules = [
    PasswordRule(
      'At least 8 characters',
      'Password must be at least 8 characters',
          (p) => p.length >= 8,
    ),
    PasswordRule(
      'An uppercase letter (A-Z)',
      'Add at least one uppercase letter',
          (p) => RegExp(r'[A-Z]').hasMatch(p),
    ),
    PasswordRule(
      'A lowercase letter (a-z)',
      'Add at least one lowercase letter',
          (p) => RegExp(r'[a-z]').hasMatch(p),
    ),
    PasswordRule(
      'A number (0-9)',
      'Add at least one number',
          (p) => RegExp(r'\d').hasMatch(p),
    ),
    PasswordRule(
      'A special character (! @ # ...)',
      'Add at least one special character',
          (p) => RegExp(r'[^A-Za-z0-9\s]').hasMatch(p),
    ),
  ];

  static String? name(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter your name';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (value.length > 50) return 'Name must be 50 characters or fewer';
    if (!_nameRegex.hasMatch(value)) {
      return "Use letters only (single spaces, - and ' are allowed)";
    }
    return null;
  }

  static String? age(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter your age';
    if (!RegExp(r'^[1-9]\d{0,2}$').hasMatch(value)) {
      return 'Enter a valid whole number';
    }
    final age = int.parse(value);
    if (age < minAge) return 'You must be at least $minAge to use VibeMatch';
    if (age > maxAge) return 'Enter a valid age';
    return null;
  }

  static String? gender(String? v) {
    if (v == null || v.isEmpty) return 'Select an option';
    return null;
  }

  static String? email(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Enter your email';
    if (value.contains(' ')) return 'Email cannot contain spaces';
    if (value.length > 254) return 'Email is too long';
    if (!value.contains('@')) return "Email must include '@'";
    if (value.split('@').length != 2) return "Email must have only one '@'";
    if (value.contains('..')) return 'Email cannot have two dots in a row';
    final local = value.split('@').first;
    if (local.isEmpty) return "Enter the part before '@'";
    if (local.length > 64 || local.startsWith('.') || local.endsWith('.')) {
      return 'Enter a valid email address';
    }
    if (!_emailRegex.hasMatch(value)) return 'Enter a valid email address';
    final tld = value.split('.').last;
    if (tld.length < 2 || !RegExp(r'^[A-Za-z]+$').hasMatch(tld)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// For creating a password (sign up).
  static String? password(String? v, {String? name, String? email}) {
    final value = v ?? '';
    if (value.isEmpty) return 'Create a password';
    if (value.length > 64) return 'Password must be 64 characters or fewer';
    if (value.contains(RegExp(r'\s'))) return 'Password cannot contain spaces';
    for (final rule in passwordRules) {
      if (!rule.test(value)) return rule.error;
    }
    final lower = value.toLowerCase();
    if (_commonPasswords.contains(lower)) {
      return 'That password is too common. Choose another';
    }
    final emailName = (email ?? '').trim().toLowerCase().split('@').first;
    if (emailName.length >= 3 && lower.contains(emailName)) {
      return 'Password cannot contain your email name';
    }
    final nameParts = (name ?? '')
        .trim()
        .toLowerCase()
        .split(' ')
        .where((part) => part.length >= 3);
    for (final part in nameParts) {
      if (lower.contains(part)) return 'Password cannot contain your name';
    }
    return null;
  }

  /// For logging in: only check that something was typed. The server decides
  /// if it is correct, and we don't reveal the password rules here.
  static String? loginPassword(String? v) {
    if (v == null || v.isEmpty) return 'Enter your password';
    return null;
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return 'Re-enter your password';
    if (v != original) return 'Passwords do not match';
    return null;
  }
}
