import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widget/dog_category_widget.dart';
import '../widget/navigator.dart';
import 'information_page/dog_information_screen.dart';


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
                  imagePath: 'asset/category_image/small_dog.png',
                  title: '소형 강아지',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) =>
                        DogInformationPage(category: '소형'),
                    )
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/category_image/middle_dog.png',
                  title: '중형 강아지',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) =>
                        DogInformationPage(category: '중형'),
                    )
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/category_image/big_dog.png',
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
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/category_image/longdog.png',
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
                  imagePath: 'asset/category_image/shortdog.png',
                  title: '단모종',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DogInformationPage(category: '단모종'),
                      ),);
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/category_image/dog_rank.png',
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
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DogCategoryWidget(
                  imagePath: 'asset/origin.jpg.png',
                  title: '나라별 모음',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DogInformationPage(category: '나라별'),
                      ),
                    );
                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/wait_image.png',
                  title: '추가중 ...',
                  onTap: () {

                  },
                ),
                DogCategoryWidget(
                  imagePath: 'asset/wait_image.png',
                  title: '추가중 ...',
                  onTap: () {

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
