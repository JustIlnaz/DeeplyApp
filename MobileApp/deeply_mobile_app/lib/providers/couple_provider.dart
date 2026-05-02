import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_endpoints.dart';
import '../data/models/couple_model.dart';

class CoupleProvider extends ChangeNotifier {
  final _dio = DioClient.instance;
  CoupleModel? couple;
  bool isLoading = false;
  String? error;

  bool get hasCouple => couple != null;
  bool get hasPartner => couple?.user2Id != null;

  Future<void> fetchCouple() async {
    _load(true);
    try {
      final r = await _dio.get(ApiEndpoints.coupleMe);
      couple = CoupleModel.fromJson(r.data);
      error = null;
    } on DioException catch (e) {
      error = e.response?.data?['message'];
    } finally { _load(false); }
  }

  Future<bool> createCouple({String? anniversaryDate}) async {
    _load(true);
    try {
      final r = await _dio.post(ApiEndpoints.coupleCreate, data: {
        if (anniversaryDate != null) 'anniversaryDate': anniversaryDate,
      });
      couple = CoupleModel.fromJson(r.data);
      error = null;
      return true;
    } on DioException catch (e) {
      error = e.response?.data?['message'] ?? 'Ошибка создания пары';
      return false;
    } finally { _load(false); }
  }

  Future<bool> joinCouple(String inviteCode) async {
    _load(true);
    try {
      final r = await _dio.post(ApiEndpoints.coupleJoin, data: {'inviteCode': inviteCode});
      couple = CoupleModel.fromJson(r.data);
      error = null;
      return true;
    } on DioException catch (e) {
      error = e.response?.data?['message'] ?? 'Неверный код';
      return false;
    } finally { _load(false); }
  }

  void _load(bool v) { isLoading = v; notifyListeners(); }
}
