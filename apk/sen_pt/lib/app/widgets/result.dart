import 'package:flutter/material.dart';

class ResultWidget extends StatelessWidget {
  const ResultWidget({super.key, required this.itemCount, required this.productName, required this.comments, required this.sentimen});

  final int itemCount;
  final String productName;
  final List<String> comments;
  final List<String> sentimen;

  @override
  Widget build(BuildContext context) {
    return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Color(0xffF5F5F5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hasil Analisis', style: TextStyle(fontSize: 20)),
                          Icon(Icons.article_outlined, size: 30),
                        ],
                      ),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          productName,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 400, // Fixed height for the list
                        child: ListView.builder(
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Text(
                                          comments[index],
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Text(
                                        sentimen[index] ,
                                        style: TextStyle(fontSize: 20, color: sentimen[index] == 'Positif' ? Colors.green : Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}