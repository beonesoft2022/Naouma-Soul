import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/shopCubit.dart';
import 'package:project/shopStates.dart';
import 'package:project/utils/constants.dart';

import 'models/myBackground_model.dart';
import 'models/shop_background_mode.dart';

class MyBackgroundScreen extends StatefulWidget {
  final String roomId;

  const MyBackgroundScreen({Key key, @required this.roomId}) : super(key: key);

  @override
  State<MyBackgroundScreen> createState() => _MyBackgroundScreenState();
}

class _MyBackgroundScreenState extends State<MyBackgroundScreen> {
  String id;
  String roomId;

  @override
  void initState() {
    super.initState();
    roomId = widget.roomId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShopCubit()..myBackgroundData(),
      child: BlocConsumer<ShopCubit, ShopIntresStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return ConditionalBuilder(
            condition: ShopCubit.get(context).myBackgroundModel != null,
            builder: (context) =>
                getIntresItem(ShopCubit.get(context).myBackgroundModel),
            fallback: (context) => Container(
              color: Colors.white,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getIntresItem(MyBackgroundModel model) => Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          actions: [],
          centerTitle: true,
          title: Text(
            "الموضوعات",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
              child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  childAspectRatio: 1 / 1.3,
                  children: List.generate(model.data.length,
                      (index) => buildGridleProduct(model.data[index])))),
        ),
      );

  Widget buildGridleProduct(MyBackgroundData model) => Column(
        children: [
          InkWell(
            child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(8.0), left: Radius.circular(8.0)),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          model.url + model.giftLink,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.fill,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 170,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [],
                              ),
                            )
                          ],
                        )
                      ],
                    ),

                    // Container(
                    //     child: Center(child: Text(model.price.toString()))),
                    InkWell(
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        color: KstorebuttonColor,
                        child: Center(
                          child: Text(
                            'تغير الى الافتراضية',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                      onTap: () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              title: Center(
                                child: const Text(
                                    'هل تريد تغير الخلفية الافتراضية الى تلك الخلفية؟'),
                              ),
                              // content: const Text('AlertDialog description'),
                              actions: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        ShopCubit.get(context)
                                            .ChangeDefaultBackground(
                                                shopid: model.id,
                                                roomid: roomId);
                                        ShopCubit.get(context)
                                            .getWalletAmount();
                                        Navigator.pop(context, 'yes');
                                      },
                                      child: const Text('نعم قم بتغير الخلفية'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'no'),
                                      child: const Text('لا'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );

                        setState(() {
                          id = model.id.toString();
                          // price = totalWalletAmount-model.price.toString();
                        });

                        //  ShopCubit.get(context).shopPurchase(id: id);
                      },
                    )
                  ],
                )),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Theme(
                      data: ThemeData(
                          dialogBackgroundColor: Colors.grey.withOpacity(0.0)),
                      child: AlertDialog(
                        content: SingleChildScrollView(
                            child: Image.network(
                          model.url + model.giftLink,
                        )),
                      ),
                    );
                  });
              setState(() {
                // id = model.id.toString();
                // print(id);
                // image = model.url;
                // pressGeoON = true;
                // CacheHelper.saveData(key: 'image', value: model.url);
              });
            },
          ),
        ],
      );
}
