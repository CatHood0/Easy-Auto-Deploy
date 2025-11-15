abstract class RequiredServices<T, B> {
  const RequiredServices();
  String get serviceKey;
  String get serviceName => '';

  /// Returns a boolean that tell us if exist or not
  /// and the string as the key of the solution
  Future<B> check(
    T d, {
    void Function(String)? log,
    void Function()? onFail,
    void Function()? onEnd,
  });
}
