import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screen/album_page/photo_screen/photo_screen.dart';
import '../screen/health_page/health_screen.dart';
import '../screen/profile_page/profile_screen/profile.page.dart';
import '../screen/walk_page/dog_walk_screen.dart';
import '../screen/homepage.dart';

final currentIndexProvider = StateProvider<int>((ref) => 0);



class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 95,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 100),
            painter: BNBCustomPainter(),
          ),
          Center(
            heightFactor: 0.6,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.brown,
                size: 40,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  _createPageRoute(HomePage()),
                      (route) => false,
                );
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 95,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildIconWithText(
                    context, ref, 'asset/bottom_bar_image/dog_walk.png', '강아지 산책', 0, const DogWalkPage()),
                buildIconWithText(
                    context, ref, 'asset/bottom_bar_image/dog_information.png', '강아지 건강', 1, const DogHealthPage()),
                Container(width: MediaQuery.of(context).size.width * 0.20),
                buildIconWithText(
                    context, ref, 'asset/bottom_bar_image/dog_photo.png', '강아지 앨범', 2, const DogPhotoPage()),
                buildIconWithText(
                    context, ref, 'asset/bottom_bar_image/dog_profile.png', '강아지 프로필', 3, const ProfilePage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconWithText(BuildContext context, WidgetRef ref, String imagePath, String text,
      int index, Widget targetPage) {
    // StateProvider에 접근
    final currentNotifier = ref.read(currentIndexProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            currentNotifier.state = index; // 상태 변경
            Navigator.pushAndRemoveUntil(
              context,
              _createPageRoute(targetPage),
                  (route) => false,
            );
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 0.8,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: ref.watch(currentIndexProvider) == index
                ? Colors.black
                : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }


  PageRouteBuilder _createPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 20);
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: const Radius.circular(10.0), clockwise: false);

    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
