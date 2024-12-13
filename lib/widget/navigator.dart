import 'package:flutter/material.dart';
import '../screen/dog_health_screen.dart';
import '../screen/dog_photo_screen.dart';
import '../screen/dog_profile_screen.dart';
import '../screen/dog_walk_screen.dart';
import '../screen/homepage.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  CustomBottomNavBarState createState() => CustomBottomNavBarState();
}

class CustomBottomNavBarState extends State<CustomBottomNavBar> {


  @override
  Widget build(BuildContext context) {
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
                  _createPageRoute(HomePage()), (route) => false,
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
                buildIconWithText('asset/dog_walk.png', '강아지 산책', 0, const DogWalkPage()),
                buildIconWithText('asset/dog_information.png', '강아지 건강', 1, const DogHealthPage()),
                Container(width: MediaQuery.of(context).size.width * 0.20),
                buildIconWithText('asset/dog_photo.png', '강아지 앨범', 2, const DogPhotoPage()),
                buildIconWithText('asset/dog_profile2321.png', '강아지 프로필', 3, const ProfilePage()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIconWithText(String imagePath, String text, int index, Widget targetPage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            widget.onTap(index);
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
            color: widget.currentIndex == index ? Colors.black : Colors.black54,
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
