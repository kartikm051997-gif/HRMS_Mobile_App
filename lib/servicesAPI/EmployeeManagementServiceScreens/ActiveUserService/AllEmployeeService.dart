import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../../../apibaseScreen/Api_Base_Screens.dart';
import '../../../model/Employee_management/AllEmployeeListModelClass.dart';
import '../../APIHelper/ApiHelper.dart';

class AllEmployeeService {
  static const Duration _timeout = Duration(seconds: 30);

  String _cleanResponseBody(String rawBody) {
    String cleaned = rawBody.trim();
    while (cleaned.isNotEmpty &&
        !cleaned.startsWith('{') &&
        !cleaned.startsWith('[')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  Future<AllEmployeeListModelClass?> getAllEmployees({
    String? zoneId,
    String? locationsId,
    String? designationsId,
    int? page,
    int? perPage,
    String? search,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (zoneId != null && zoneId.isNotEmpty) {
        queryParams['zone_id'] = zoneId;
      }
      if (locationsId != null && locationsId.isNotEmpty) {
        queryParams['locations_id'] = locationsId;
      }
      if (designationsId != null && designationsId.isNotEmpty) {
        queryParams['designations_id'] = designationsId;
      }
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(
        ApiBase.allEmployeeList,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      if (kDebugMode) {
        print("🔄 AllEmployeeService → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);
        
        if (kDebugMode) {
          print("📦 AllEmployeeService Response type: ${jsonResponse.runtimeType}");
          print("📦 Response body (first 500 chars): ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}");
          if (jsonResponse is Map) {
            print("📦 Response keys: ${jsonResponse.keys}");
            print("📦 Response status: ${jsonResponse['status']}");
            if (jsonResponse['data'] != null) {
              print("📦 Data type: ${jsonResponse['data'].runtimeType}");
              if (jsonResponse['data'] is Map) {
                print("📦 Data keys: ${(jsonResponse['data'] as Map).keys}");
                if (jsonResponse['data']['users'] != null) {
                  print("📦 Users count: ${(jsonResponse['data']['users'] as List).length}");
                }
              } else if (jsonResponse['data'] is List) {
                print("📦 Data is List, length: ${(jsonResponse['data'] as List).length}");
              }
            } else {
              print("⚠️ Response has no 'data' field");
            }
          } else if (jsonResponse is List) {
            print("📦 List length: ${jsonResponse.length}");
          }
        }
        
        // Handle case where API returns List directly instead of Map
        if (jsonResponse is List) {
          if (kDebugMode) {
            print("⚠️ API returned List directly, wrapping in expected format");
          }
          // Wrap list in expected structure
          return AllEmployeeListModelClass.fromJson({
            'status': 'success',
            'message': 'Data retrieved successfully',
            'total': jsonResponse.length,
            'data': {
              'users': jsonResponse,
              'pagination': null,
            },
          });
        }
        
        // Handle case where data field is a List instead of Map
        if (jsonResponse is Map && jsonResponse['data'] is List) {
          if (kDebugMode) {
            print("⚠️ API returned data as List, wrapping in expected format");
            print("📦 List length: ${(jsonResponse['data'] as List).length}");
          }
          // Wrap data list in expected structure
          // Also convert status from boolean to string if needed
          final wrappedResponse = <String, dynamic>{
            'status': jsonResponse['status'] == true ? 'success' : (jsonResponse['status'] is bool ? (jsonResponse['status'] == true ? 'success' : 'failed') : jsonResponse['status']?.toString() ?? 'success'),
            'message': jsonResponse['message']?.toString() ?? 'Data retrieved successfully',
            'total': jsonResponse['total'] ?? jsonResponse['limit'] ?? (jsonResponse['data'] as List).length,
            'data': {
              'users': jsonResponse['data'],
              'pagination': null,
            },
          };
          if (kDebugMode) {
            print("📦 Wrapped response - status: ${wrappedResponse['status']}, total: ${wrappedResponse['total']}");
          }
          return AllEmployeeListModelClass.fromJson(wrappedResponse);
        }
        
        // Handle case where status is boolean instead of string (but data is already Map)
        if (jsonResponse is Map && jsonResponse['status'] is bool) {
          if (kDebugMode) {
            print("⚠️ API returned status as boolean, converting to string");
          }
          final convertedResponse = Map<String, dynamic>.from(jsonResponse);
          convertedResponse['status'] = jsonResponse['status'] == true ? 'success' : 'failed';
          // Also handle total/limit
          if (convertedResponse['total'] == null && convertedResponse['limit'] != null) {
            convertedResponse['total'] = convertedResponse['limit'];
          }
          return AllEmployeeListModelClass.fromJson(convertedResponse);
        }
        
        // Normal Map response
        return AllEmployeeListModelClass.fromJson(jsonResponse);
      }

      // Log response body for debugging errors
      if (kDebugMode) {
        print("❌ AllEmployeeService ${response.statusCode} Response: ${response.body}");
        if (response.statusCode == 404) {
          print("⚠️ 404 Error - Endpoint might not exist. Check if 'allemployee_api' is correct.");
          print("   Current endpoint: ${ApiBase.allEmployeeList}");
        }
      }
      
      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ AllEmployeeService error: $e");
      }
      rethrow;
    }
  }

  Future<AllEmployeeUser?> getEmployeeById(String empId) async {
    try {
      final Map<String, String> queryParams = {'employment_id': empId};

      final uri = Uri.parse(
        ApiBase.employeeDetailsById,
      ).replace(queryParameters: queryParams);

      if (kDebugMode) {
        print("🔄 AllEmployeeService.getEmployeeById → $uri");
      }

      final response = await ApiHelper.get(uri).timeout(_timeout);

      if (kDebugMode) {
        print("✅ Status: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        final cleaned = _cleanResponseBody(response.body);
        final jsonResponse = jsonDecode(cleaned);

        // Handle response - could be direct user object or wrapped in data
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['user'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['data']['user']);
        } else if (jsonResponse['user'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['user']);
        } else if (jsonResponse['data'] != null) {
          return AllEmployeeUser.fromJson(jsonResponse['data']);
        } else {
          return AllEmployeeUser.fromJson(jsonResponse);
        }
      }

      throw Exception("API Error ${response.statusCode}");
    } catch (e) {
      if (kDebugMode) {
        print("❌ AllEmployeeService.getEmployeeById error: $e");
      }
      rethrow;
    }
  }
}
