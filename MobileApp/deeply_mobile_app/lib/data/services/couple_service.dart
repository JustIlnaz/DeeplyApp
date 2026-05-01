import 'package:dio/dio.dart';
import '../models/couple.dart';
import '../models/dtos.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';

abstract class CoupleService {
  Future<Couple> createCouple(CreateCoupleRequest request);
  Future<Couple> getCouple();
  Future<Couple> joinCouple(JoinCoupleRequest request);
}

class CoupleServiceImpl implements CoupleService {
  final DioClient _dioClient;

  CoupleServiceImpl(this._dioClient);

  @override
  Future<Couple> createCouple(CreateCoupleRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/couples/create',
        data: request.toJson(),
      );
      return Couple.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Couple> getCouple() async {
    try {
      final response = await _dioClient.get<Map<String, dynamic>>(
        '/couples/my',
      );
      return Couple.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Couple> joinCouple(JoinCoupleRequest request) async {
    try {
      final response = await _dioClient.post<Map<String, dynamic>>(
        '/couples/join',
        data: request.toJson(),
      );
      return Couple.fromJson(response.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
