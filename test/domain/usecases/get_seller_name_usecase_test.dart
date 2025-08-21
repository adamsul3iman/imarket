// test/domain/usecases/get_seller_name_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imarket/core/error/failures.dart';
import 'package:imarket/domain/repositories/ad_repository.dart';
import 'package:imarket/domain/usecases/get_seller_name_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAdRepository extends Mock implements AdRepository {}

void main() {
  late GetSellerNameUseCase usecase;
  late MockAdRepository mockAdRepository;

  setUp(() {
    mockAdRepository = MockAdRepository();
    usecase = GetSellerNameUseCase(mockAdRepository);
  });

  const testUserId = 'user123';
  const testSellerName = 'John Doe';

  test(
    'should get seller name from the repository',
    () async {
      // Arrange: Wrap the successful string value in a Right()
      when(() => mockAdRepository.getSellerName(any()))
          .thenAnswer((_) async => const Right(testSellerName)); // FIX: Wrap in Right()

      // Act
      final result = await usecase.call(testUserId);

      // Assert
      expect(result, const Right(testSellerName)); // FIX: Expect a Right() value
      verify(() => mockAdRepository.getSellerName(testUserId));
      verifyNoMoreInteractions(mockAdRepository);
    },
  );
}