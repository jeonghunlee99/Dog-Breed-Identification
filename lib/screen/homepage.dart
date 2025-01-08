import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/dog_category_widget.dart';
import '../widget/navigator.dart';


class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // initState에서 currentIndexProvider를 4로 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentIndexProvider.notifier).state = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: 800,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
          image: const DecorationImage(
            image: AssetImage('asset/dog.gif'),
            fit: BoxFit.cover,
          ),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
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
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/dog_image.png',
                  title: '소형 강아지',
                  onTap: () {
                    Navigator.pushNamed(context, '/smallDogs');
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/dog_image2.png',
                  title: '중형 강아지',
                  onTap: () {
                    Navigator.pushNamed(context, '/mediumDogs');
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/big_dog.png',
                  title: '대형 강아지',
                  onTap: () {
                    Navigator.pushNamed(context, '/largeDogs');
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/longdog.png',
                  title: '장모종',
                  onTap: () {
                    Navigator.pushNamed(context, '/longHairDogs');
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/shortdog.png',
                  title: '단모종',
                  onTap: () {
                    Navigator.pushNamed(context, '/shortHairDogs');
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/dog_rank.png',
                  title: 'IQ 순위',
                  onTap: () {
                    Navigator.pushNamed(context, '/iqRanking');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
