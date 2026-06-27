import 'dart:convert';
import 'package:http/http.dart' as http;

class TelegramService {
  static const String _token = '8712674761:AAEUs0t3V5ezEvixSthsFVovHsSwLJKC3iU';
  static const String _chatId = '@uhtred_store';
  static const String _apiUrl = 'https://api.telegram.org/bot$_token/sendMessage';

  static Future<Map<String, dynamic>> sendOrderNotification(Map<String, dynamic> order) async {
    try {
      final items = jsonDecode(order['items'] ?? '[]') as List;
      final itemsHtml = items.asMap().entries.map((e) {
        final i = e.value;
        return '${e.key + 1}. ${i['productName']}\n'
            '   - الطباعة: ${i['printing']}\n'
            '   - اللون: ${i['color']}\n'
            '   - المقاس: ${i['size']}\n'
            '   - الكمية: ${i['quantity']}\n'
            '   - السعر: ${i['price']} د.ع';
      }).join('\n\n');

      final message = '''
<b>🛒 طلب جديد من Uhtred Store</b>

<b>رقم الطلب:</b> ${order['orderNumber']}
<b>الاسم:</b> ${order['name']}
<b>الهاتف:</b> ${order['phone']}
<b>العنوان:</b> ${order['address']}

<b>المنتجات:</b>
$itemsHtml

<b>الإجمالي:</b> ${order['total']} د.ع
<b>التاريخ:</b> ${order['createdAt']}
''';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': _chatId,
          'text': message,
          'parse_mode': 'HTML',
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'error': null};
      }
      final body = jsonDecode(response.body);
      return {'success': false, 'error': body['description'] ?? 'خطأ غير معروف'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
