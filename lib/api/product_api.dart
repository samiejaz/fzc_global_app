import 'dart:convert';
import 'package:fzc_global_app/models/product_model.dart';
import 'package:fzc_global_app/utils/constants.dart';
import 'package:http/http.dart' as http;

Future<List<ProductModel>> getProducts(
    {String? barcode = "",
    String? customerId = "",
    String? supplierId = "",
    String? itemCode = ""}) async {
  try {
    String queryParams = "";

    if (barcode != "" && barcode != null) {
      queryParams += "&Barcode=${barcode.trim()}";
    }
    if (customerId != "" && customerId != null) {
      queryParams += "&CustomerID=${customerId.trim()}";
    }
    if (supplierId != "" && supplierId != null) {
      queryParams += "&SupplierID=${supplierId.trim()}";
    }
    if (itemCode != "" && itemCode != null) {
      queryParams += "&ItemCode=${itemCode.trim()}";
    }

    final response = await http.post(
        Uri.parse(
            '${APIConstants.baseUrl}/BarcodeAllotment/GetAllProducts${queryParams.replaceFirst("&", "?")}'),
        headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception(jsonResponse['error']);
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Failed to load products: $e');
  }
}

class APIResponse {
  final String error;
  final bool success;

  APIResponse({required this.error, required this.success});
}

Future<APIResponse> addProduct(ProductModel product, String barCode,
    int updatedQuantity, String from) async {
  String apiUrl = '${APIConstants.baseUrl}/BarcodeAllotment/AddBoxAllotment';

  Map<String, dynamic> jsonData =
      product.toJson(barCode.trim(), updatedQuantity, from);

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(jsonData),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      APIResponse apiResponse = APIResponse(
          error: responseBody['error'], success: responseBody['success']);
      return apiResponse;
    } else {
      throw Exception("Something went wrong...");
    }
  } catch (e) {
    throw Exception("Something went wrong...$e");
  }
}
