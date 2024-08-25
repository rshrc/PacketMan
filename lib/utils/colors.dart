// Flutter imports:
import 'package:flutter/material.dart';

String statusMessageColor(int statusCode) {
  switch (statusCode) {
    case 200:
      return 'Success';
    case 201:
      return 'Created';
    case 204:
      return 'No Content';
    case 400:
      return 'Bad Request';
    case 401:
      return 'Unauthorized';
    case 403:
      return 'Forbidden';
    case 404:
      return 'Not Found';
    case 405:
      return 'Method Not Allowed';
    case 500:
      return 'Internal Server Error';
    default:
      return 'Unknown';
  }
}

Color getColorForRequestType(String requestType) {
  switch (requestType) {
    case 'GET':
      return Colors.orange;
    case 'POST':
      return Colors.green;
    case 'PUT':
      return Colors.blue;
    case 'DELETE':
      return Colors.red;
    case 'PATCH':
      return Colors.purple;
    default:
      return Colors.black;
  }
}
