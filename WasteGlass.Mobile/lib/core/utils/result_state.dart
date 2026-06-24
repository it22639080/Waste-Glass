class ResultState<T> {
  const ResultState._({
    this.data,
    this.message,
    this.isLoading = false,
    this.isSuccess = false,
  });

  final T? data;
  final String? message;
  final bool isLoading;
  final bool isSuccess;

  factory ResultState.idle() => const ResultState._();
  factory ResultState.loading() => const ResultState._(isLoading: true);
  factory ResultState.success(T data) =>
      ResultState._(data: data, isSuccess: true);
  factory ResultState.failure(String message) =>
      ResultState._(message: message);
}
