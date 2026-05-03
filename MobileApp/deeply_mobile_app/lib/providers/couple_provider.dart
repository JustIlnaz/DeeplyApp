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
  String? partnerName;
  int? partnerId;
  int? myUserId;

  bool get hasCouple => couple != null;
  bool get hasPartner => couple?.user2Id != null;

  Future<void> fetchCouple() async {
    _load(true);
    try {
      final r = await _dio.get(ApiEndpoints.coupleMe);
      couple = CoupleModel.fromJson(r.data);
      _derivePartnerId();
      error = null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('[CoupleProvider] No couple found (404) - user needs to create or join');
        couple = null;
        error = null;
      } else {
        debugPrint('[CoupleProvider] Error fetching couple: ${e.response?.data}');
        error = e.response?.data?['message'];
      }
    } finally { _load(false); }
  }

  void setMyUserId(int id) {
    myUserId = id;
    _derivePartnerId();
    notifyListeners();
  }

  void _derivePartnerId() {
    if (couple == null || myUserId == null) return;
    final c = couple!;
    if (c.user1Id == myUserId) {
      partnerId = c.user2Id;
    } else if (c.user2Id == myUserId) {
      partnerId = c.user1Id;
    }
  }

  Future<void> fetchPartnerInfo(int partnerUserId) async {
    partnerId = partnerUserId;
    try {
      final r = await _dio.get(ApiEndpoints.userById(partnerUserId));
      partnerName = r.data['name'] as String?;
    } catch (_) {}
    notifyListeners();
  }

  /// Convenience: derives partner ID from the couple model and fetches their name.
  Future<void> fetchPartnerProfile(int myUserId) async {
    setMyUserId(myUserId);
    final pId = partnerId;
    if (pId == null) return;
    await fetchPartnerInfo(pId);
  }

  Future<bool> createCouple({String? anniversaryDate}) async {
    _load(true);
    try {
      debugPrint('[CoupleProvider] createCouple called, anniversaryDate=$anniversaryDate');
      debugPrint('[CoupleProvider] POST ${ApiEndpoints.coupleCreate}');
      final r = await _dio.post(ApiEndpoints.coupleCreate, data: {
        if (anniversaryDate != null) 'anniversaryDate': anniversaryDate,
      });
      debugPrint('[CoupleProvider] response status=${r.statusCode} data=${r.data}');
      couple = CoupleModel.fromJson(r.data);
      _derivePartnerId();
      error = null;
      return true;
    } on DioException catch (e) {
      debugPrint('[CoupleProvider] DioException type=${e.type} status=${e.response?.statusCode} data=${e.response?.data} message=${e.message}');
      error = e.response?.data?['message'] ?? 'Ошибка создания пары';
      return false;
    } catch (e) {
      debugPrint('[CoupleProvider] unexpected error: $e');
      error = e.toString();
      return false;
    } finally { _load(false); }
  }

  Future<bool> joinCouple(String inviteCode) async {
    _load(true);
    try {
      await _dio.post(ApiEndpoints.coupleJoin, data: {'inviteCode': inviteCode});
      // join returns { message, coupleId } — fetch full couple model afterwards
      final r = await _dio.get(ApiEndpoints.coupleMe);
      couple = CoupleModel.fromJson(r.data);
      _derivePartnerId();
      error = null;
      return true;
    } on DioException catch (e) {
      error = e.response?.data?['message'] ?? 'Неверный код';
      return false;
    } finally { _load(false); }
  }

  void _load(bool v) { isLoading = v; notifyListeners(); }
}
