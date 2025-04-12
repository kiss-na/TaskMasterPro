class Validators {
  // Private constructor to prevent instantiation
  Validators._();

  // Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }

    final phoneRegExp = RegExp(r'^\+?[0-9]{10,15}$');
    
    if (!phoneRegExp.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  // Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // URL is optional
    }

    final urlRegExp = RegExp(
      r'^(http|https)://[a-zA-Z0-9-\.]+\.[a-zA-Z]{2,}(:[0-9]+)?(/[a-zA-Z0-9\-\._,?:/\\+&%$#=~]*)?$',
    );
    
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  // Validate date format (yyyy-MM-dd)
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date is required';
    }

    final dateRegExp = RegExp(
      r'^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$',
    );
    
    if (!dateRegExp.hasMatch(value)) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
    
    return null;
  }

  // Validate time format (HH:mm)
  static String? validateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Time is required';
    }

    final timeRegExp = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    
    if (!timeRegExp.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }
    
    return null;
  }

  // Validate minimum length
  static String? validateMinLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let validateRequired handle empty values
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }
    
    return null;
  }

  // Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let validateRequired handle empty values
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'This field'} must be at most $maxLength characters';
    }
    
    return null;
  }

  // Validate numeric value
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return null; // Let validateRequired handle empty values
    }

    final numericRegExp = RegExp(r'^[0-9]+$');
    
    if (!numericRegExp.hasMatch(value)) {
      return '${fieldName ?? 'This field'} must contain only numbers';
    }
    
    return null;
  }

  // Validate hex color code
  static String? validateHexColor(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Color is optional
    }

    final hexColorRegExp = RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    
    if (!hexColorRegExp.hasMatch(value)) {
      return 'Please enter a valid hex color code (e.g., #RRGGBB)';
    }
    
    return null;
  }
}
