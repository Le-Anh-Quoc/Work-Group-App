String? validateEmail(String? value) {
  if (value == null || value.isEmpty || !value.contains('@')) {
    return 'Please enter a valid email';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Password must be at least 6 characters long';
  }
  return null;
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your full name';
  }
  return null;
}