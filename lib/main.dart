import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

Map<String, String> flags = {
  'USD' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Flag_of_the_United_States_%281776%E2%80%931777%29.svg/250px-Flag_of_the_United_States_%281776%E2%80%931777%29.svg.png',
  'EUR' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/1200px-Flag_of_Europe.svg.png',
  'RUB' : 'https://upload.wikimedia.org/wikipedia/en/thumb/f/f3/Flag_of_Russia.svg/1200px-Flag_of_Russia.svg.png',
  'GBP' : 'https://upload.wikimedia.org/wikipedia/en/thumb/a/ae/Flag_of_the_United_Kingdom.svg/1280px-Flag_of_the_United_Kingdom.svg.png',
  'JPY' : 'https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/1200px-Flag_of_Japan.svg.png',
  'AZN' : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ2EeYEiJolZ-tmWQl4_BYZ__CqSRqk0V66VMPqbZ3zCQ&s',
  'BDT' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Flag_of_Bangladesh.svg/1200px-Flag_of_Bangladesh.svg.png',
  'BGN' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Flag_of_Bulgaria.svg/2000px-Flag_of_Bulgaria.svg.png',
  'BHD' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Flag_of_Bahrain.svg/640px-Flag_of_Bahrain.svg.png',
  'BND' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/Flag_of_Brunei.svg/800px-Flag_of_Brunei.svg.png',
  'BRL' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Flag_of_Brazil.svg/1060px-Flag_of_Brazil.svg.png',
  'BYN' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Flag_of_Belarus.svg/1200px-Flag_of_Belarus.svg.png',
  'CAD' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/Flag_of_Canada.svg/1280px-Flag_of_Canada.svg.png',
  'CHF' : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRf7tdMVTzoCIWa85h0OLfI1RjtMMmLyLTKOpwMTlNfkA&s',
  'CNY' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Flag_of_the_People%27s_Republic_of_China.svg/1024px-Flag_of_the_People%27s_Republic_of_China.svg.png',
  'CUP' : 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Flag_of_Cuba.svg/1200px-Flag_of_Cuba.svg.png',
};

class CardData {  //Json fileni ta'minlash
  final String nomi;
  final String qiymati;
  final String sana;
  final String uznomi;

  CardData({required this.nomi, required this.qiymati, required this.sana, required this.uznomi });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      nomi: json['Ccy'], // Shu qiymat Alfa3 bilan teng bo'lishi kerak!
      qiymati: json['Rate'],
      sana: json['Date'],
      uznomi: json['CcyNm_UZ'],
    );
  }
}

//String? bugungisana;

Future<List<CardData>> fetchData() async {
  final response = await http.get(Uri.parse('https://cbu.uz/uz/arkhiv-kursov-valyut/json/'));
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((item) => CardData.fromJson(item)).toList();
  } else {
    throw Exception('Json fileni yuklashda xatolik!');
  }
}


// card_view.dart

class CardView extends StatelessWidget {
  final List<CardData> data;
  const CardView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    String bugungisana = data[1].sana;
    return Scaffold(
      appBar: AppBar(title: Text('${bugungisana} dagi valyuta kursi!'),centerTitle: true,),
      body: ListView.builder(
        itemCount: data.length -59,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text('${data[index].nomi}  -  ${data[index].uznomi}'),
              subtitle: Text('${data[index].qiymati} So`m '),
            leading: Image.network( '${flags[data[index].nomi]}',width: 80, height: 120, fit: BoxFit.cover,),
            ),
          );
        },
      ),
    );
  }
}

// main.dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     // title: 'Valyuta kursi',
      home: FutureBuilder<List<CardData>>(
        future: fetchData(),
        builder: (context, snapshot) {
          CardView(data: snapshot.data!);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return CardView(data: snapshot.data!);
          }
        },
      ),
    );
  }
}