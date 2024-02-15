/// Brief documentation for MyRoomsItem widget.
///
/// This widget displays information and navigation for a room item in a list.
/// It shows the room name, description, tags, and user count.
/// Tapping on it navigates to the room details screen.

/*
The MyRoomsItem widget is a StatelessWidget that displays information and navigation for a room item in a list. It shows the room name, description, tags, and user count. Tapping on it navigates to the room details screen.
The widget takes the following parameters:

roomId: The ID of the room.
roomOwnerId: The ID of the room owner.
roomName: The name of the room.
roomDesc: The description of the room.

The widget first creates a Directionality widget to set the text direction to RTL (right-to-left). This is because the app is being localized for Arabic, which is a right-to-left language.
Next, the widget creates a GestureDetector widget to handle taps on the room item. When the user taps on the room item, the widget calls the Get.to() function to navigate to the DetailsScreen. The DetailsScreen is a StatefulWidget that displays the details of the room.
The widget then creates a Container widget to hold the room item's content. The Container widget has a BoxDecoration widget to set the room item's border, color, and shadow. The Container widget also has a Row widget to hold the room item's image, name, and description.
The Row widget has two children: an Image widget and a Column widget. The Image widget displays the room item's image. The Column widget holds the room item's name and description.
The Column widget has three children: a Row widget, a Text widget, and a Row widget. The Row widget displays the room item's tags. The Text widget displays the room item's description. The Row widget displays the room item's user count.
Finally, the widget returns the Container widget.

*/



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/utils/constants.dart';
import 'package:project/utils/images.dart';
import 'package:project/view/details/details_screen.dart';
import 'package:project/view/details/roomDetailsScreen.dart';

class MyRoomsItem extends StatelessWidget {
  const MyRoomsItem(
      {Key key, this.roomId, this.roomOwnerId, this.roomName, this.roomDesc})
      : super(key: key);
  final String roomId;
  final String roomOwnerId;
  final String roomName;
  final String roomDesc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () => Get.to(
            DetailsScreen(
              roomId: roomId,
              roomName: roomName,
              roomDesc: roomDesc,
              // roomOwnerId: roomOwnerId,
            ),
            duration: Duration(milliseconds: 1000),
            transition: Transition.leftToRightWithFade),
        child: Container(
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.0)),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 2.0),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(8.0)),
                    child: Image.asset(
                      kRoomImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                // _sizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _sizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.flag),
                          _sizedBox(width: 4.0),
                          Expanded(
                              child: Text(
                            roomName,
                            maxLines: 1,
                            style: theme.textTheme.bodyText1
                                .copyWith(color: Colors.black, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          )),
                        ]),
                        _sizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.queue_music,
                              size: 20,
                            ),
                            _sizedBox(width: 6.0),
                            Container(
                              // height: 30,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                "موسيقى",
                                style: theme.textTheme.bodyText2
                                    .copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                        _sizedBox(height: 8),
                        Text(
                          roomDesc,
                          maxLines: 1,
                          style: theme.textTheme.bodyText2.copyWith(
                              color: Colors.grey.shade600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                        // _sizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.queue_music,
                          size: 20,
                        ),
                        Icon(
                          Icons.perm_identity_sharp,
                          size: 20,
                        ),
                        Text(
                          "1177",
                          maxLines: 1,
                          style: theme.textTheme.bodyText2.copyWith(
                              color: Colors.grey.shade600, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                    // _sizedBox(height: 8),
                    // Row(
                    //   children: [
                    //     Icon(Icons.queue_music),
                    //     Icon(Icons.perm_identity_sharp),
                    //   ],
                    // ),
                  ],
                ),
                _sizedBox(width: 10),
              ],
            )),
      ),
    );
  }

  Widget _sizedBox({double width, double height}) {
    return SizedBox(
      width: width,
      height: height,
    );
  }
}
