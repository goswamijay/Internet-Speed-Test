import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  bool _isServerSelectionInProgress = false;

  String? _ip;
  String? _asn;
  String? _isp;

  String _unitText = 'Mbps';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme).copyWith(
          bodyMedium: GoogleFonts.poppins(textStyle: textTheme.labelLarge),
        ),
      ),
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(25, 26, 46, 255),
        appBar: AppBar(
          backgroundColor: Colors.teal.shade900,
          centerTitle: true,
          title: const Text(
            'Speed Test',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: SfRadialGauge(axes: <RadialAxis>[
                        RadialAxis(
                            minimum: 0,
                            maximum: 150,
                            showFirstLabel: false,
                            canRotateLabels: true,
                            axisLabelStyle: GaugeTextStyle(
                                color: Colors.white.withOpacity(0.95)),
                            majorTickStyle: MajorTickStyle(
                                color: Colors.white.withOpacity(0.95)),
                            minorTickStyle: MinorTickStyle(
                                color: Colors.white.withOpacity(0.95)),
                            ranges: <GaugeRange>[
                              GaugeRange(
                                startValue: 0,
                                endValue: 20,
                                color: Colors.red,
                                labelStyle: GaugeTextStyle(
                                    color: Colors.white.withOpacity(0.95)),
                              ),
                              GaugeRange(
                                startValue: 20,
                                endValue: 60,
                                color: Colors.orange,
                                labelStyle:
                                    const GaugeTextStyle(color: Colors.white),
                              ),
                              GaugeRange(
                                startValue: 60,
                                endValue: 150,
                                color: Colors.green,
                                labelStyle: GaugeTextStyle(
                                    color: Colors.white.withOpacity(0.95)),
                              ),
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: _downloadRate,
                                needleColor: Colors.white.withOpacity(0.95),
                                knobStyle: const KnobStyle(color: Colors.white),
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Text(_downloadRate.toString(),
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  angle: 90,
                                  positionFactor: 0.5)
                            ])
                      ]),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: SfRadialGauge(axes: <RadialAxis>[
                        RadialAxis(
                            minimum: 0,
                            maximum: 150,
                            showFirstLabel: false,
                            canRotateLabels: true,
                            axisLabelStyle: GaugeTextStyle(
                                color: Colors.white.withOpacity(0.95)),
                            majorTickStyle: MajorTickStyle(
                                color: Colors.white.withOpacity(0.95)),
                            minorTickStyle: MinorTickStyle(
                                color: Colors.white.withOpacity(0.95)),
                            ranges: <GaugeRange>[
                              GaugeRange(
                                startValue: 0,
                                endValue: 20,
                                color: Colors.red,
                                labelStyle: GaugeTextStyle(
                                    color: Colors.white.withOpacity(0.95)),
                              ),
                              GaugeRange(
                                startValue: 20,
                                endValue: 60,
                                color: Colors.orange,
                                labelStyle:
                                    const GaugeTextStyle(color: Colors.white),
                              ),
                              GaugeRange(
                                startValue: 60,
                                endValue: 150,
                                color: Colors.green,
                                labelStyle: GaugeTextStyle(
                                    color: Colors.white.withOpacity(0.95)),
                              ),
                            ],
                            pointers: <GaugePointer>[
                              NeedlePointer(
                                value: _uploadRate,
                                needleColor: Colors.white.withOpacity(0.95),
                                knobStyle: const KnobStyle(color: Colors.white),
                              )
                            ],
                            annotations: <GaugeAnnotation>[
                              GaugeAnnotation(
                                  widget: Text(_uploadRate.toString(),
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  angle: 90,
                                  positionFactor: 0.5)
                            ])
                      ]),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Download Speed',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900),
                          ),
                          const Divider(),
                          Text(
                            'Progress: $_downloadProgress%',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.95)),
                          ),
                          Text(
                            'Download Rate:\n$_downloadRate $_unitText',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.95)),
                            textAlign: TextAlign.center,
                          ),
                          if (_downloadCompletionTime > 0)
                            Text(
                              'Time taken: ${(_downloadCompletionTime / 1000).toStringAsFixed(2)} sec(s)',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.95)),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Upload Speed',
                            style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900),
                          ),
                          const Divider(),
                          Text(
                            'Progress: $_uploadProgress%',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.95)),
                          ),
                          Text(
                            'Upload Rate:\n$_uploadRate $_unitText',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.95)),
                            textAlign: TextAlign.center,
                          ),
                          if (_uploadCompletionTime > 0)
                            Text(
                              'Time taken: ${(_uploadCompletionTime / 1000).toStringAsFixed(2)} sec(s)',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.95)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(
                  height: 16.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _isServerSelectionInProgress
                        ? 'Selecting Server...'
                        : 'IP: ${_ip ?? '--'} | ASP: ${_asn ?? '--'} | ISP: ${_isp ?? '--'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (!_testInProgress) ...{
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.teal.shade900)),
                    child: const Text(
                      'Start Testing',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      reset();
                      await internetSpeedTest.startTesting(onStarted: () {
                        setState(() => _testInProgress = true);
                      }, onCompleted: (TestResult download, TestResult upload) {
                        if (kDebugMode) {
                          print(
                              'the transfer rate ${download.transferRate}, ${upload.transferRate}');
                        }
                        setState(() {
                          _downloadRate = download.transferRate;
                          _unitText =
                              download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _downloadProgress = '100';
                          _downloadCompletionTime = download.durationInMillis;
                        });
                        setState(() {
                          _uploadRate = upload.transferRate;
                          _unitText =
                              upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _uploadProgress = '100';
                          _uploadCompletionTime = upload.durationInMillis;
                          _testInProgress = false;
                        });
                      }, onProgress: (double percent, TestResult data) {
                        if (kDebugMode) {
                          print(
                              'the transfer rate $data.transferRate, the percent $percent');
                        }
                        setState(() {
                          _unitText =
                              data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          if (data.type == TestType.download) {
                            _downloadRate = data.transferRate;
                            _downloadProgress = percent.toStringAsFixed(2);
                          } else {
                            _uploadRate = data.transferRate;
                            _uploadProgress = percent.toStringAsFixed(2);
                          }
                        });
                      }, onError: (String errorMessage, String speedTestError) {
                        if (kDebugMode) {
                          print(
                              'the errorMessage $errorMessage, the speedTestError $speedTestError');
                        }
                        reset();
                      }, onDefaultServerSelectionInProgress: () {
                        setState(() {
                          _isServerSelectionInProgress = true;
                        });
                      }, onDefaultServerSelectionDone: (Client? client) {
                        setState(() {
                          _isServerSelectionInProgress = false;
                          _ip = client?.ip;
                          _asn = client?.asn;
                          _isp = client?.isp;
                        });
                      }, onDownloadComplete: (TestResult data) {
                        setState(() {
                          _downloadRate = data.transferRate;
                          _unitText =
                              data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _downloadCompletionTime = data.durationInMillis;
                        });
                      }, onUploadComplete: (TestResult data) {
                        setState(() {
                          _uploadRate = data.transferRate;
                          _unitText =
                              data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                          _uploadCompletionTime = data.durationInMillis;
                        });
                      }, onCancel: () {
                        reset();
                      });
                    },
                  )
                } else ...{
                  CircularProgressIndicator(
                    color: Colors.white.withOpacity(0.95),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton.icon(
                      onPressed: () => internetSpeedTest.cancelTest(),
                      icon: Icon(
                        Icons.cancel_rounded,
                        color: Colors.white.withOpacity(0.95),
                      ),
                      label: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ),
                  )
                },
              ],
            ),
          ),
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      {
        _testInProgress = false;
        _downloadRate = 0;
        _uploadRate = 0;
        _downloadProgress = '0';
        _uploadProgress = '0';
        _unitText = 'Mbps';
        _downloadCompletionTime = 0;
        _uploadCompletionTime = 0;

        _ip = null;
        _asn = null;
        _isp = null;
      }
    });
  }
}
