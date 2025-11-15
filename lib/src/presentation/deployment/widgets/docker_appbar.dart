// import 'package:auto_deployment/src/presentation/deployment/widgets/status_indicator.dart';
// import 'package:flutter/material.dart';
//
// import '../../../domain/enums/deployment_status.dart';
// import '../../../utils/status_colors.dart';
//
// class DockerAppBar extends StatelessWidget {
//   const DockerAppBar({
//     super.key,
//     required ValueNotifier<DeploymentStatus> status,
//   }) : _status = status;
//
//   final ValueNotifier<DeploymentStatus> _status;
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//         valueListenable: _status,
//         builder: (context, value, child) {
//           return SliverAppBar(
//             title: Text(
//               'Sistema de Auto-Deployment',
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w800,
//                 color: Colors.white,
//               ),
//               overflow: TextOverflow.clip,
//               maxLines: 1,
//             ),
//             backgroundColor: getStatusColor(value),
//             clipBehavior: Clip.hardEdge,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             actionsPadding: const EdgeInsetsDirectional.only(end: 10),
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.only(right: 5),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     StatusIndicator(
//                       color: Colors.white,
//                       fontSize: 20,
//                       status: _status,
//                     ),
//                     RepaintBoundary(
//                       child: Text(
//                         'Estado actual del sistema',
//                         style: TextStyle(
//                           fontSize: 11.5,
//                           fontWeight: FontWeight.w300,
//                           color: Color(0xBBFFFFFF),
//                         ),
//                         overflow: TextOverflow.clip,
//                         maxLines: 1,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         });
//   }
// }
