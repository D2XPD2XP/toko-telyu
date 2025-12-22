import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toko_telyu/models/delivery_area.dart';
import 'package:toko_telyu/services/delivery_area_services.dart';

import 'mock_delivery_area_repository.dart';

void main() {
  late MockDeliveryAreaRepository mockRepository;
  late MockUuid mockUuid;
  late DeliveryAreaService service;

  setUpAll(() {
    registerFallbackValue(
      DeliveryArea('dummy-id', 'dummy-name', 0),
    );
  });

  setUp(() {
    mockRepository = MockDeliveryAreaRepository();
    mockUuid = MockUuid();

    service = DeliveryAreaService(
      repository: mockRepository,
      uuid: mockUuid,
    );
  });

  group('createArea', () {
    test('harus generate UUID dan simpan ke repository', () async {
      when(() => mockUuid.v4()).thenReturn('uuid-123');
      when(() => mockRepository.addDeliveryArea(any()))
          .thenAnswer((_) async {});

      await service.createArea('Jakarta', 5000);

      verify(() => mockUuid.v4()).called(1);
      verify(() => mockRepository.addDeliveryArea(
            any(
              that: isA<DeliveryArea>()
                  .having((a) => a.getAreaId(), 'areaId', 'uuid-123')
                  .having((a) => a.getAreaname(), 'areaName', 'Jakarta')
                  .having((a) => a.getDeliveryfee(), 'fee', 5000),
            ),
          )).called(1);
    });
  });

  group('fetchAllAreas', () {
    test('harus return list dari repository', () async {
      final areas = [
        DeliveryArea('1', 'Bandung', 4000),
        DeliveryArea('2', 'Surabaya', 6000),
      ];

      when(() => mockRepository.getAllAreas())
          .thenAnswer((_) async => areas);

      final result = await service.fetchAllAreas();

      expect(result, areas);
      verify(() => mockRepository.getAllAreas()).called(1);
    });
  });

  group('fetchArea', () {
    test('harus return satu area', () async {
      final area = DeliveryArea('1', 'Bali', 7000);

      when(() => mockRepository.getAreaById('1'))
          .thenAnswer((_) async => area);

      final result = await service.fetchArea('1');

      expect(result, area);
    });
  });

  group('updateArea', () {
    test('harus update area ke repository', () async {
      when(() => mockRepository.updateDeliveryArea(any()))
          .thenAnswer((_) async {});

      await service.updateArea('1', 'Yogyakarta', 4500);

      verify(() => mockRepository.updateDeliveryArea(
            any(
              that: isA<DeliveryArea>()
                  .having((a) => a.getAreaId(), 'areaId', '1')
                  .having((a) => a.getAreaname(), 'areaName', 'Yogyakarta')
                  .having((a) => a.getDeliveryfee(), 'fee', 4500),
            ),
          )).called(1);
    });
  });

  group('deleteArea', () {
    test('harus delete area berdasarkan id', () async {
      when(() => mockRepository.deleteDeliveryArea('1'))
          .thenAnswer((_) async {});

      await service.deleteArea('1');

      verify(() => mockRepository.deleteDeliveryArea('1')).called(1);
    });
  });
}

