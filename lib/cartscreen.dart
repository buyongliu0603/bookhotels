import 'dart:async';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:lin_261780/user.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({Key key, this.user}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List cartData;
  double screenHeight, screenWidth;
  bool _noCoupon = true;
  bool _storeCredit = false;
  bool _coupon = false;
  double _totalbudget = 0.0;
  Position _currentPosition;
  String curaddress;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();
  double latitude, longitude;
  String label;
  CameraPosition _userpos;
  double deliverycharge;
  double amountpayable;

  @override
  void initState() {
    super.initState();
    _getLocation();
    //_getCurrentLocation();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (cartData == null) {
      return Scaffold(
          appBar: AppBar(
            title: Text('Booking List'),
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
                  "Loading Booking Hotel List",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          )));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('Booking List'),
          ),
          body: Center(
            child: ListView.builder(
                itemCount: cartData == null ? 1 : cartData.length + 2,
                itemBuilder: (context, index) {
                  if (index == cartData.length) {
                    return Container(
                        height: screenHeight / 2.4,
                        width: screenWidth / 2.5,
                        child: InkWell(
                          onLongPress: () => {print("Delete")},
                          child: Card(
                            //color: Colors.yellow,
                            elevation: 5,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Text("Booking Option",
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                                Expanded(
                                    child: Row(
                                  children: <Widget>[
                                    Container(
                                      // color: Colors.red,
                                      width: screenWidth / 2,
                                      height: screenHeight / 3,
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: _noCoupon,
                                                onChanged: (bool value) {
                                                  _onSelfPickUp(value);
                                                },
                                              ),
                                              Text(
                                                "No Coupon",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(2, 1, 2, 1),
                                        child: SizedBox(
                                            width: 2,
                                            child: Container(
                                              height: screenWidth / 2,
                                              color: Colors.grey,
                                            ))),
                                    Expanded(
                                        child: Container(
                                      //color: Colors.blue,
                                      width: screenWidth / 2,
                                      height: screenHeight / 3,
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Checkbox(
                                                value: _coupon,
                                                onChanged: (bool value) {
                                                  _onHomeDelivery(value);
                                                },
                                              ),
                                              Text(
                                                "Coupon",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                          FlatButton(
                                            color: Color.fromRGBO(
                                                101, 255, 218, 50),
                                            onPressed: () => {_loadMapDialog()},
                                            child: Icon(
                                              MdiIcons.locationEnter,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text("Current Address:",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          Row(
                                            children: <Widget>[
                                              Text("  "),
                                              Flexible(
                                                child: Text(
                                                  curaddress ??
                                                      "Address not set",
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ))
                              ],
                            ),
                          ),
                        ));
                  }
                  if (index == cartData.length + 1) {
                    return Container(
                        height: screenHeight / 3,
                        child: Card(
                          elevation: 5,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 10,
                              ),
                              Text("Payment",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              SizedBox(height: 10),
                              Container(
                                  padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                                  //color: Colors.red,
                                  child: Table(
                                      defaultColumnWidth: FlexColumnWidth(1.0),
                                      columnWidths: {
                                        0: FlexColumnWidth(7),
                                        1: FlexColumnWidth(3),
                                      },
                                      // border: TableBorder.all(color: Colors.white),
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 20,
                                                child: Text("Total Budget ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black))),
                                          ),
                                          TableCell(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 20,
                                              child: Text(
                                                  "RM" +
                                                          _totalbudget
                                                              .toStringAsFixed(
                                                                  2) ??
                                                      "0",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 20,
                                                child: Text("Delivery Charge ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black))),
                                          ),
                                          TableCell(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 20,
                                              child: Text(
                                                  "RM" +
                                                          deliverycharge
                                                              .toStringAsFixed(
                                                                  2) ??
                                                      "0.0",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Colors.black)),
                                            ),
                                          ),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 20,
                                                child: Text(
                                                    "Store Credit RM" +
                                                        widget.user.credit,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black))),
                                          ),
                                          TableCell(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 20,
                                              child: Checkbox(
                                                value: _storeCredit,
                                                onChanged: (bool value) {
                                                  _onStoreCredit(value);
                                                },
                                              ),
                                            ),
                                          ),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                            child: Container(
                                                alignment: Alignment.centerLeft,
                                                height: 20,
                                                child: Text("Total Amount ",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white))),
                                          ),
                                          TableCell(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              height: 20,
                                              child: Text(
                                                  "RM" +
                                                          amountpayable
                                                              .toStringAsFixed(
                                                                  2) ??
                                                      "0.0",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ]),
                                      ])),
                              SizedBox(
                                height: 10,
                              ),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0)),
                                minWidth: 200,
                                height: 40,
                                child: Text('Make Payment'),
                                color: Color.fromRGBO(101, 255, 218, 50),
                                textColor: Colors.black,
                                elevation: 10,
                                onPressed: makePayment,
                              ),
                            ],
                          ),
                        ));
                  }
                  index -= 0;
                  return Card(
                      elevation: 10,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(children: <Widget>[
                            Column(
                              children: <Widget>[
                                ClipOval(
                                  child: Container(
                                      height: screenWidth / 4.8,
                                      width: screenWidth / 4.8,
                                      decoration: BoxDecoration(
                                          //shape: BoxShape.circle,
                                          //border: Border.all(color: Colors.black),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  "http://lintatt.com/bookhotels/images/${cartData[index]['id']}.jpg")))),
                                ),
                                Text(
                                  "RM " + cartData[index]['budget'],
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                                padding: EdgeInsets.fromLTRB(5, 1, 10, 1),
                                child: SizedBox(
                                    width: 2,
                                    child: Container(
                                      height: screenWidth / 3.5,
                                      color: Colors.grey,
                                    ))),
                            Container(
                                width: screenWidth / 1.45,
                                //color: Colors.blue,
                                child: Row(
                                  //crossAxisAlignment: CrossAxisAlignment.center,
                                  //mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Flexible(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            cartData[index]['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.white),
                                            maxLines: 1,
                                          ),
                                          Text(
                                            "Available " +
                                                cartData[index]['quantity'] +
                                                " unit",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            "Your Quantity " +
                                                cartData[index]['cquantity'],
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                              height: 20,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  FlatButton(
                                                    onPressed: () => {
                                                      _updateCart(index, "add")
                                                    },
                                                    child: Icon(
                                                      MdiIcons.plus,
                                                      color: Color.fromRGBO(
                                                          101, 255, 218, 50),
                                                    ),
                                                  ),
                                                  Text(
                                                    cartData[index]
                                                        ['cquantity'],
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  FlatButton(
                                                    onPressed: () => {
                                                      _updateCart(
                                                          index, "remove")
                                                    },
                                                    child: Icon(
                                                      MdiIcons.minus,
                                                      color: Color.fromRGBO(
                                                          101, 255, 218, 50),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                  "Total RM " +
                                                      cartData[index]
                                                          ['yourbudget'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black)),
                                              FlatButton(
                                                onPressed: () =>
                                                    {_deleteCart(index)},
                                                child: Icon(
                                                  MdiIcons.delete,
                                                  color: Color.fromRGBO(
                                                      101, 255, 218, 50),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                )),
                          ])));
                }),
          ));
    }
  }

  void _loadCart() {
    _totalbudget = 0;
    amountpayable = 0;
    deliverycharge = 0;
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Updating cart...");
    pr.show();
    String urlLoadJobs = "https://lintatt.com/bookhotels/php/load_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
    }).then((res) {
      print(res.body);
      pr.dismiss();
      setState(() {
        var extractdata = json.decode(res.body);
        cartData = extractdata["cart"];
        for (int i = 0; i < cartData.length; i++) {
          _totalbudget = int.parse(cartData[i]['yourbudget']) + _totalbudget;
        }

        amountpayable = _totalbudget;
        print(_totalbudget);
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    pr.dismiss();
  }

  _updateCart(int index, String op) {
    int curquantity = int.parse(cartData[index]['quantity']);
    int quantity = int.parse(cartData[index]['cquantity']);
    if (op == "add") {
      quantity++;
      if (quantity > (curquantity - 2)) {
        Toast.show("Rooms not available", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
    }
    if (op == "remove") {
      quantity--;
      if (quantity == 0) {
        _deleteCart(index);
        return;
      }
    }
    String urlLoadJobs = "https://lintatt.com/bookhotels/php/update_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
      "bhotelid": cartData[index]['id'],
      "quantity": quantity.toString()
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Book Updated", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
    });
  }

  _deleteCart(int index) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Delete booking hotel list?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post("https://lintatt.com/bookhotels/php/delete_cart.php",
                    body: {
                      "email": widget.user.email,
                      "bhotelid": cartData[index]['id'],
                    }).then((res) {
                  print(res.body);
                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("Failed", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
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
      ),
    );
  }

  void _onSelfPickUp(bool newValue) => setState(() {
        _noCoupon = newValue;
        if (_noCoupon) {
          _coupon = false;
          _updatePayment();
        } else {
          //_homeDelivery = true;
          _updatePayment();
        }
      });

  void _onStoreCredit(bool newValue) => setState(() {
        _storeCredit = newValue;
        if (_storeCredit) {
          _updatePayment();
        } else {
          _updatePayment();
        }
      });

  void _onHomeDelivery(bool newValue) {
    //_getCurrentLocation();
    _getLocation();
    setState(() {
      _coupon = newValue;
      if (_coupon) {
        _updatePayment();
        _noCoupon = false;
      } else {
        _updatePayment();
      }
    });
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Delivery Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(
                  "Select New Delivery Location",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: markers.toSet(),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {
                          _loadLoc(newLatLng, newSetState);
                        }),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Color.fromRGBO(101, 255, 218, 50),
                    textColor: Colors.black,
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 14,
      );
      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Booking Hotel Location',
          )));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );
    _newhomeLocation();
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
    //Navigator.of(context).pop(false);
    //_loadMapDialog();
  }

  void _updatePayment() {

    _totalbudget = 0.0;
    amountpayable = 0.0;
    setState(() {
      for (int i = 0; i < cartData.length; i++) {
        _totalbudget = int.parse(cartData[i]['yourbudget']) + _totalbudget;
      }
      print(_noCoupon);

      if (_coupon == true) {
        _totalbudget = _totalbudget * 0.9 ;
      } 
      if (_storeCredit) {
        amountpayable =
            deliverycharge + _totalbudget - double.parse(widget.user.credit);
      } else {
        amountpayable = deliverycharge + _totalbudget;
      }
      print(_totalbudget);
    });
  }

  void makePayment() {
    if (_noCoupon) {
      print("No Coupon");
      Toast.show("No Coupon", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_coupon) {
      print("Coupon");
      Toast.show("Coupon", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Please select booking option", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }
}
