import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNav extends StatelessWidget {
  final int activeIndex; // 0 for Home, 1 for Scan, 2 for Attendees
  const CustomBottomNav({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 20,
      shadowColor: Colors.grey,
      height: 70.h,
      color: const Color.fromARGB(255, 255, 255, 255),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, 0, Icons.home_outlined, 'Home', '/home'),
          _buildNavItem(context, 1, Icons.qr_code_scanner, 'Scan', '/scan'),
          _buildNavItem(
              context, 2, Icons.people_outlined, 'Attendees', '/attendees'),
        ],
      ),
    );
  }

  // A helper method to keep your code DRY (Don't Repeat Yourself)
  Widget _buildNavItem(BuildContext context, int index, IconData icon,
      String label, String route) {
    bool isActive = activeIndex == index;
    Color color = isActive ? Colors.blue : Colors.grey;

    return InkWell(
      onTap: () {
        if (!isActive) Navigator.pushReplacementNamed(context, route);
      },
      child: SizedBox(
        width: 100.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 25.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
