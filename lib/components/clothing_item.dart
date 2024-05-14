import 'package:flutter/material.dart';

enum ClothingType { top, bottom, outerwear, accessories, footwear }

class ClothingItem extends StatelessWidget {
  final ClothingType type;
  final String name;
  final String msg;
  final String imageUrl;

  const ClothingItem({
    Key? key,
    required this.type,
    required this.name,
    required this.msg,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Image.asset(imageUrl),
        ),
        const SizedBox(
          height: 8.0,
        ),
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// import 'package:flutter/material.dart';
//
// enum ClothingType { top, bottom, outerwear, accessories, footwear }
//
// class ClothingItem extends StatelessWidget {
//   final ClothingType type;
//   final String name;
//
//   const ClothingItem({Key? key, required this.type, required this.name})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       title: Text(name),
//       leading: Icon(getIcon(type)),
//     );
//   }
//
//   IconData getIcon(ClothingType type) {
//     switch (type) {
//       case ClothingType.top:
//         return Icons.tshirt;
//       case ClothingType.bottom:
//         return Icons.pants;
//       case ClothingType.outerwear:
//         return Icons.jacket;
//       case ClothingType.accessories:
//         return Icons.accessibility;
//       case ClothingType.footwear:
//         return Icons.shoe;
//       default:
//         return Icons.error;
//     }
//   }
// }