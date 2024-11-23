import 'package:flutter/material.dart';

class InquiryPage extends StatelessWidget {
  const InquiryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문의 작성'),
      ),
      body: Center(
        child: Text('문의 작성 페이지입니다.'),
      ),
    );
  }
}
