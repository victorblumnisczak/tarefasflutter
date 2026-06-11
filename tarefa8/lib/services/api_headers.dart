class ApiHeaders {
  ApiHeaders._();

  static Map<String, String> json() => {'Content-Type': 'application/json'};

  static Map<String, String> auth(String token) => {
        'Authorization': 'Bearer $token',
      };

  static Map<String, String> jsonWithAuth(String token) => {
        ...json(),
        ...auth(token),
      };
}
