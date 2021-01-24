import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easyping/easyping.dart';
import 'package:flutter/services.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:connectivity/connectivity.dart';


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double listFontSize = 28;
  double listIconSize = 28;
  double listSpeedSize = 18;

  double deviceHeight = 0.0;

  final Color yellow = const Color(0xFFFFC000);
  final Color background = const Color(0xFF22272B);
  final Color cardColor = Colors.white10;

  final internetSpeedTest = InternetSpeedTest();

  double lastPing = 0;
  bool pinging = false;
  String address = "google.com";
  double downloadSpeed = 0.0;
  SpeedUnit dspeed = SpeedUnit.Kbps;
  double uploadSpeed = 0.0;
  SpeedUnit uspeed = SpeedUnit.Kbps;
  double progress = 0;
  String _connectionStatus = 'Unknown';

  bool testing = false;
  bool downloadingDone = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _updateConnectionStatus(result);
    });

    initConnectivity();

    super.initState();
  }

  Future<void> initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        print(_connectionStatus);
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        print(_connectionStatus);
        break;
    }}


  pingIn() async {
    setState(() {
      pinging = true;
    });
    lastPing = await ping(address);
    setState(() {
      lastPing = lastPing;
    });
    print("Pinging !!!!!!!!!!!!!!!!!!!!!!!!!!!!"+lastPing.toString());
    setState(() {
      pinging = false;
    });
  }

  onStartTestUpload() {
      internetSpeedTest.startUploadTesting(
        onDone: (double transferRate, SpeedUnit unit) {
          setState(() {
            uploadSpeed = transferRate;
            uspeed = unit;
            progress = 0.0;
            testing = false;
          });

          print("Done uploading !!!!!!!!!!!");
        },
        onProgress: (double percent, double transferRate, SpeedUnit unit) {
          setState(() {
            uploadSpeed = transferRate;
            progress = percent;
            uspeed = unit;
            testing = true;
          });
        },
        onError: (String errorMessage, String speedTestError) {
          setState(() {
            uploadSpeed = 0.0;
            uspeed = SpeedUnit.Kbps;
            testing = false;
          });
        },
      );
    }

  onStartTest() {
    internetSpeedTest.startDownloadTesting(
      onDone: (double transferRate, SpeedUnit unit) {
        setState(() {
          downloadSpeed = transferRate;
          dspeed = unit;
          downloadingDone = true;
        });
        pingIn();
        onStartTestUpload();
        print("Done Downloading!!!!!!!!!!!");
      },
      onProgress: (double percent, double transferRate, SpeedUnit unit) {
        setState(() {
          downloadSpeed = transferRate;
          progress = percent;
          dspeed = unit;
          testing = true;
        });
      },
      onError: (String errorMessage, String speedTestError) {
        setState(() {
          downloadSpeed = 0.0;
          dspeed = SpeedUnit.Kbps;
          testing = false;
        });
      },
    );
  }



  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    print(MediaQuery.of(context).size.height);

    if(height < 750){
      listFontSize = 22;
      listSpeedSize = 16;
    }

    return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          title: Text(
            "Internet Speed Tester",
            style: TextStyle(color: yellow, fontSize: 24.0),
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          height:height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              // Meter
              Expanded(
                flex: height < 750 ? 4 : 5,
                child: Padding(
                  padding: height < 750 ?  EdgeInsets.all(5): EdgeInsets.all(20),
                  child: SfRadialGauge(
                    enableLoadingAnimation: true,
                    animationDuration: 2500,
                    key: null,
                    axes: <RadialAxis>[
                      RadialAxis(
                          labelOffset: 15,
                          axisLineStyle: AxisLineStyle(
                              thicknessUnit: GaugeSizeUnit.factor, thickness: 0.15),
                          radiusFactor: 1,
                          minimum: 0,
                          showTicks: true,
                          maximum: 50,
                          axisLabelStyle: GaugeTextStyle(fontSize: 12),
                          pointers: <GaugePointer>[
                            NeedlePointer(
                              enableAnimation: true,
                              animationDuration: 2500,
                              needleColor: yellow,
                              animationType: AnimationType.easeOutBack,
                              value: downloadingDone ? uploadSpeed : downloadSpeed,
                              lengthUnit: GaugeSizeUnit.factor,
                              needleStartWidth: 3,
                              needleEndWidth: 6,
                              needleLength: height < 700? 0.5: 0.6,
                            ),
                            RangePointer(
                              value: downloadingDone ? uploadSpeed : downloadSpeed,
                              width: 0.15,
                              sizeUnit: GaugeSizeUnit.factor,
                              color: yellow,
                              animationDuration: 2500,
                              enableAnimation: true,
                              animationType: AnimationType.easeOutBack,
                            )
                          ])
                    ],
                  ),
                ),
              ),

              // Card
              Expanded(
                flex:height < 750 ? 6 : 5,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: height < 750? Radius.circular(30.0):Radius.circular(40.0),
                          topRight: height < 750? Radius.circular(30.0):Radius.circular(40.0)),
                      color: cardColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 35.0, horizontal: 35),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        // List
                        Column(
                          children: [

                            // Ping
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.swap_vert_sharp,size: listIconSize,
                                      color: yellow,),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Ping",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: listFontSize),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      lastPing.toStringAsFixed(1),
                                      style: TextStyle(
                                          color: yellow,
                                          fontSize: listFontSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      "ms",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: listSpeedSize),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            SizedBox(height: 15,),

                            // Download
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.download_sharp,
                                      size: listIconSize,
                                      color: yellow,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Download",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: listFontSize),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      downloadSpeed.toStringAsFixed(2),
                                      style: TextStyle(
                                          color: yellow,
                                          fontSize: listFontSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      dspeed == SpeedUnit.Mbps
                                          ? "Mbps"
                                          : "Kbps",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: listSpeedSize),
                                    ),
                                  ],
                                )
                              ],
                            ),

                            SizedBox(height: 15,),

                            // Upload
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.upload_sharp,
                                      size: listIconSize,
                                      color: yellow,
                                    ),
                                    SizedBox(width: 10,),
                                    Text(
                                      "Upload",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: listFontSize),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      uploadSpeed.toStringAsFixed(2),
                                      style: TextStyle(
                                          color: yellow,
                                          fontSize:listFontSize,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      uspeed == SpeedUnit.Mbps
                                          ? "Mbps"
                                          : "Kbps",
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: listSpeedSize),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),

                        // Progress
                        Column(
                          children: [
                            Text(
                              testing
                                  ? downloadingDone
                                      ? "Testing Upload Speed"
                                      : "Testing Download Speed"
                                  : "Start Test",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.devices_sharp,
                                  size: height < 750? 40:55,
                                  color: yellow,
                                ),
                                Expanded(
                                    child: LinearPercentIndicator(
                                      lineHeight: 8.0,
                                      percent: progress / 100,
                                      progressColor: yellow,
                                      animationDuration: 1000,
                                      backgroundColor: Colors.white24,
                                    )),
                                Icon(
                                  Icons.cloud,
                                  size:height < 750? 40:55,
                                  color: yellow,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Start button
                        RaisedButton(

                          padding: height <800? EdgeInsets.symmetric(horizontal: 20.0,vertical: 8): EdgeInsets.symmetric(horizontal: 30.0,vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          onPressed:testing ? null : () {
                              setState(() {
                                downloadSpeed = 0;
                                uploadSpeed = 0;
                                lastPing = 0.0;
                                downloadingDone = false;
                              });
                              onStartTest();

                          },
                          color: yellow,
                          elevation: 12.0,
                          child: Text("START",style: TextStyle(color: background,fontSize:height <750? 22:24,),),
                        )

                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
