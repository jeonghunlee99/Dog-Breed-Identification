import 'package:flutter/material.dart';

import 'dog_information_page.dart';
import 'dogcategorywidget.dart';
import 'navigator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 4;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: AssetImage('asset/dog.gif'),
            fit: BoxFit.cover,
          ),
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  '카테고리',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/dog_image.png',
                  title: '소형 강아지',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '소형'),
                      ),
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/dog_image2.png',
                  title: '중형 강아지',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '중형'),
                      ),
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/big_dog.png',
                  title: '대형 강아지',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '대형'),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/longdog.png',
                  title: '장모종',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '장모종'),
                      ),
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/shortdog.png',
                  title: '단모종',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '단모종'),
                      ),
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/dog_rank.png',
                  title: 'IQ 순위',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: 'IQ 순위'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
