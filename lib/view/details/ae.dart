// @override
// Widget build(BuildContext context) {
//   return LayoutBuilder(builder: (context, constraints) {
//     TextEditingController _controller = TextEditingController();
//
//     return BlocProvider(
//       create: (context) => HomeCubit()
//         ..getnotification(id: widget.roomId, password: widget.passwordRoom)
//         ..getroomuser(id: widget.roomId)
//         ..getuserExp(id: apiid)
//         ..usersfollowingroom(id: widget.roomId),
//       child: BlocConsumer<HomeCubit, HomeStates>(listener: (context, state) {
//        // ... (Your existing listener logic here)
//       }, builder: (context, state) {
//         return Stack( // Use a Stack for Dialog Overlay
//           children: [
//             // Your Existing UI:
//             ConditionalBuilder(
//               condition: HomeCubit.get(context).roomUserModel != null &&
//                   HomeCubit.get(context).getUserExpModel != null,
//               builder: (context) {
//                 // ... (Your existing 'getdata' based UI)
//               },
//               fallback: (context) {
//                 // ... (Your existing fallback UI)
//               },
//             ),
//
//
//           ],
//         );
//       }),
//     );
//   });
// }
