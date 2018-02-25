import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:wallet_concept/transaction.dart';

class OPClient {
  static final String apiKey = "YOUR_API_KEY";
  static final String token = "fdb6c7c24bbc3a2c4144c1848825ab7d3a4ccb43";

  static final String OPBaseUrl = "sandbox.apis.op-palvelut.fi";

  static final OPClient _opClient = new OPClient._internal();
  static final httpClient = new HttpClient();

  factory OPClient() {
    return _opClient;
  }

  OPClient._internal();

  Future<dynamic> getBalance(String accountId) async {
    var uri = new Uri.https(OPBaseUrl, "/v1/accounts/$accountId");
    return await httpClient.getUrl(uri).then((HttpClientRequest request) {
      HttpClientRequest requestWithHeaders = _addHeaders(request);
      return requestWithHeaders.close();
    }).then((HttpClientResponse response) {
      return response.transform(UTF8.decoder).join();
    }).then((String responseBody) {
      List data = JSON.decode(responseBody);
      return data[0]['balance'];
    });
  }

  Future<List<Transaction>> getTransactions(String accountId) async {
    var uri = new Uri.https(OPBaseUrl, "/v1/accounts/$accountId/transactions");
    return await httpClient.getUrl(uri).then((HttpClientRequest request) {
      HttpClientRequest requestWithHeaders = _addHeaders(request);
      return requestWithHeaders.close();
    }).then((HttpClientResponse response) {
      return response.transform(UTF8.decoder).join();
    }).then((String responseBody) {
      print(responseBody);
      List data = JSON.decode(responseBody);
      var formatter = new DateFormat('dd.MM.yyyy');
      List<Transaction> transactions = data.map((transactionJson) {
        return new Transaction(
            transactionJson["reference"], transactionJson["amount"].toDouble(),
            formatter.format(DateTime.parse(transactionJson["bookingDate"])),
            transactionJson["purpose"]);
      }).toList();
      return transactions;
    });
  }

  HttpClientRequest _addHeaders(HttpClientRequest request) {
    request.headers
      ..add("Content-Type", "application/json")
      ..add("x-api-key", apiKey)
      ..add("x-authorization", token)
      ..add("x-request-id", "111")..add("x-session-id", "234");
    return request;
  }
}