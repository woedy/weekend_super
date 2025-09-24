
import 'package:flutter/material.dart';
import 'package:weekend_chef_dispatch/constants.dart';

class ShopDialog extends StatefulWidget {
  const ShopDialog({Key? key}) : super(key: key);

  @override
  State<ShopDialog> createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 250,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0), // Border radius of 30
            color: Colors.white, // Blue color
          ),
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                      /*    Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  AllShopsScreen())); */
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  //margin: EdgeInsets.all(10),
                  height: 59,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: bookPrimary,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "Shop List",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {

    /*       Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  ShopMap()));
 */

                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  //margin: EdgeInsets.all(10),
                  height: 59,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: bookPrimary,
                      borderRadius: BorderRadius.circular(7)),
                  child: const Center(
                    child: Text(
                      "Map View",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
