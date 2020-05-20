import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lin_261780/user.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'profilescreen.dart';
import 'cartscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;

  const MainScreen({Key key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List hoteldata;
  int curnumber = 1;
  double screenHeight, screenWidth;
  bool _visible = false;
  String curtype = "Recent";
  String cartquantity = "0";
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    TextEditingController _prdController = new TextEditingController();

    if (hoteldata == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Hotels List'),
          ),
          body: Container(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading Hotels",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          )));
    } else {
      return Scaffold(
        drawer: mainDrawer(context),
        appBar: AppBar(
          title: Text('Hotels List'),
          actions: <Widget>[
            IconButton(
              icon: _visible
                  ? new Icon(Icons.expand_more)
                  : new Icon(Icons.expand_less),
              onPressed: () {
                setState(() {
                  if (_visible) {
                    _visible = false;
                  } else {
                    _visible = true;
                  }
                });
              },
            ),

            //
          ],
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Visibility(
                visible: _visible,
                child: Card(
                    elevation: 10,
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () => _sortItem("Recent"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.update,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Recent",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          _sortItem("Free Breakfast"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            Icons.free_breakfast,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Free Breakfast",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          _sortItem("Free Collection"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            Icons.collections,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Free Collection",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          _sortItem("Pay at Hotel"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            Icons.payment,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Pay at Hotel",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () =>
                                          _sortItem("Instant Book"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            MdiIcons.book,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Instant Book",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Column(
                                children: <Widget>[
                                  FlatButton(
                                      onPressed: () => _sortItem("Nothing"),
                                      color: Colors.green[300],
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        // Replace with a Row for horizontal icon + text
                                        children: <Widget>[
                                          Icon(
                                            Icons.event_busy,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Nothing",
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ))),
              ),
              Visibility(
                  visible: _visible,
                  child: Card(
                    elevation: 5,
                    child: Container(
                      height: screenHeight / 12,
                      margin: EdgeInsets.fromLTRB(20, 2, 20, 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Flexible(
                              child: Container(
                            height: 30,
                            child: TextField(
                                autofocus: false,
                                controller: _prdController,
                                decoration: InputDecoration(
                                    icon: Icon(Icons.search),
                                    border: OutlineInputBorder())),
                          )),
                          Flexible(
                              child: MaterialButton(
                                  color: Colors.green[300],
                                  onPressed: () =>
                                      {_sortItembyName(_prdController.text)},
                                  elevation: 5,
                                  child: Text(
                                    "Search Hotels",
                                    style: TextStyle(color: Colors.white),
                                  )))
                        ],
                      ),
                    ),
                  )),
              Text(curtype,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Flexible(
                  child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (screenWidth / screenHeight) / 1,
                      children: List.generate(hoteldata.length, (index) {
                        return Card(
                            elevation: 10,
                            child: Padding(
                              padding: EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => _onImageDisplay(index),
                                    child: Container(
                                        height: screenWidth / 4,
                                        width: screenWidth / 4,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.black),
                                            image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                    "http://lintatt.com/bookhotels/images/${hoteldata[index]['id']}.jpg")))),
                                  ),
                                  Text(hoteldata[index]['name'],
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    hoteldata[index]['location'],
                                  ),
                                  Text("Description: " +
                                      hoteldata[index]['description']),
                                  Text("RM " + hoteldata[index]['budget']),
                                  Text("Total Rooms: " +
                                      hoteldata[index]['quantity']),
                                  MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    minWidth: 100,
                                    height: 40,
                                    child: Text('Book Now'),
                                    color: Colors.green[300],
                                    textColor: Colors.white,
                                    elevation: 10,
                                    onPressed: () => _addtocartdialog(index),
                                  ),
                                ],
                              ),
                            ));
                      })))
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => CartScreen(
                          user: widget.user,
                        )));
          },
          icon: Icon(Icons.add_shopping_cart),
          label: Text(cartquantity),
          backgroundColor: Colors.green[300],
        ),
      );
    }
  }

  _onImageDisplay(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            content: new Container(
          height: screenHeight / 2.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  height: screenWidth / 2,
                  width: screenWidth / 2,
                  decoration: BoxDecoration(
                      //border: Border.all(color: Colors.black),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              "http://lintatt.com/bookhotels/images/${hoteldata[index]['id']}.jpg")))),
            ],
          ),
        ));
      },
    );
  }

  void _loadData() {
    String urlLoadJobs = "https://lintatt.com/bookhotels/php/load_hotels.php";
    http.post(urlLoadJobs, body: {}).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        hoteldata = extractdata["hotels"];
        cartquantity = widget.user.quantity;
      });
    }).catchError((err) {
      print(err);
    });
  }

  Widget mainDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(widget.user.name),
            accountEmail: Text(widget.user.email),
            otherAccountsPictures: <Widget>[
              Text("RM " + widget.user.credit,
                  style: TextStyle(fontSize: 16.0, color: Colors.white)),
            ],
            currentAccountPicture: CircleAvatar(
              backgroundColor:
                  Theme.of(context).platform == TargetPlatform.android
                      ? Colors.white
                      : Colors.white,
              child: Text(
                widget.user.name.toString().substring(0, 1).toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
              backgroundImage: NetworkImage(
                  "http://lintatt.com/bookhotels/profileimages/${widget.user.email}.jpg?"),
            ),
            onDetailsPressed: () => {
              Navigator.pop(context),
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => ProfileScreen(
                            user: widget.user,
                          )))
            },
          ),
          ListTile(
              title: Text(
                "Booking Hotel List",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => {
                    Navigator.pop(context),
                    gotoCart(),
                  }),
          ListTile(
            title: Text(
              "Purchased History",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            trailing: Icon(Icons.arrow_forward),
          ),
          ListTile(
              title: Text(
                "User Profile",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              trailing: Icon(Icons.arrow_forward),
              onTap: () => {
                    Navigator.pop(context),
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => ProfileScreen(
                                  user: widget.user,
                                )))
                  }),
        ],
      ),
    );
  }

  _addtocartdialog(int index) {
     if (widget.user.email == "unregistered") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    quantity = 1;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, newSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              title: new Text(
                "Add " + hoteldata[index]['name'] + " to Booking list?",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Select number of room of hotel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          FlatButton(
                            onPressed: () => {
                              newSetState(() {
                                if (quantity > 1) {
                                  quantity--;
                                }
                              })
                            },
                            child: Icon(
                              MdiIcons.minus,
                              color: Color.fromRGBO(101, 255, 218, 50),
                            ),
                          ),
                          Text(
                            quantity.toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          FlatButton(
                            onPressed: () => {
                              newSetState(() {
                                if (quantity <
                                    (int.parse(hoteldata[index]['quantity']) -
                                        10)) {
                                  quantity++;
                                } else {
                                  Toast.show("Room not available", context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                              })
                            },
                            child: Icon(
                              MdiIcons.plus,
                              color: Color.fromRGBO(101, 255, 218, 50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
              actions: <Widget>[
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      _addtoCart(index);
                    },
                    child: Text(
                      "Yes",
                      style: TextStyle(
                        color: Color.fromRGBO(101, 255, 218, 50),
                      ),
                    )),
                MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color.fromRGBO(101, 255, 218, 50),
                      ),
                    )),
              ],
            );
          });
        });
  }

  void _addtoCart(int index) {
    try {
      int cquantity = int.parse(hoteldata[index]["quantity"]);
      print(cquantity);
      print(hoteldata[index]["id"]);
      print(widget.user.email);
      if (cquantity > 0) {
        ProgressDialog pr = new ProgressDialog(context,
            type: ProgressDialogType.Normal, isDismissible: true);
        pr.style(message: "Booking Now...");
        pr.show();
        String urlLoadJobs =
            "https://lintatt.com/bookhotels/php/insert_cart.php";
        http.post(urlLoadJobs, body: {
          "email": widget.user.email,
          "bhotelid": hoteldata[index]["id"],
          "quantity": quantity.toString(),
        }).then((res) {
          print(res.body);
          if (res.body == "failed") {
            Toast.show("Failed to booking hotel", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            pr.dismiss();
            return;
          } else {
            List respond = res.body.split(",");
            setState(() {
              cartquantity = respond[1];
            });
            Toast.show("Success booking hotels", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
          pr.dismiss();
        }).catchError((err) {
          print(err);
          pr.dismiss();
        });
        pr.dismiss();
      } else {
        Toast.show("No rooms", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    } catch (e) {
      Toast.show("Failed to booking hotels", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _sortItem(String type) {
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Searching...");
    pr.show();
    String urlLoadJobs = "https://lintatt.com/bookhotels/php/load_hotels.php";
    http.post(urlLoadJobs, body: {
      "description": type,
    }).then((res) {
      setState(() {
        curtype = type;
        var extractdata = json.decode(res.body);
        hoteldata = extractdata["hotels"];
        FocusScope.of(context).requestFocus(new FocusNode());
        pr.dismiss();
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    pr.dismiss();
  }

  void _sortItembyName(String prname) {
    print(prname);
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Searching...");
    pr.show();
    String urlLoadJobs = "https://lintatt.com/bookhotels/php/load_hotels.php";
    http.post(urlLoadJobs, body: {
      "name": prname.toString(),
    }).then((res) {
      if (res.body == "nodata") {
        Toast.show("Hotel not found", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.dismiss();
        FocusScope.of(context).requestFocus(new FocusNode());
        return;
      }
      setState(() {
        var extractdata = json.decode(res.body);
        hoteldata = extractdata["hotels"];
        FocusScope.of(context).requestFocus(new FocusNode());
        curtype = prname;
        pr.dismiss();
      });
    }).catchError((err) {
      pr.dismiss();
    });
    pr.dismiss();
  }

  gotoCart() {
    if (widget.user.email == "unregistered") {
      Toast.show("Please register to use this function", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => CartScreen(
                    user: widget.user,
                  )));
    }
  }
}
