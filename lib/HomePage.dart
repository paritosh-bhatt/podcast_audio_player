import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pod_player/page_manager.dart';
import 'package:pod_player/song_model.dart';
import 'package:pod_player/utility.dart';

late final PageManager _pageManager;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //
  List<SongModel> _URLs = [
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/ftsg/ftsg_8.mp3", title: "For Those Seeking Guidance – Part 8"),
    SongModel(URL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", title: "testing"),
    // SongModel(URL: "https://ibb.co/qyr1TVp", title: "image Testing"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/ftsg/ftsg_7.mp3", title: "For Those Seeking Guidance – Part 7"),
    SongModel(
        URL: "http://qalaminstitute.org/podcast/audio/heartwork_purification/heartwork_purification_4.mp3",
        title: "Heartwork – Purification of the Heart – Part 4 – Lying"),
    SongModel(
        URL: "http://qalaminstitute.org/podcast/audio/heartwork_purification/heartwork_purification_3.mp3",
        title: "Heartwork – Purification of the Heart – Part 3 – Backbiting"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/ftsg/ftsg_6.mp3", title: "For Those Seeking Guidance – Part 6"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/future_of_qalam.mp3", title: "The Future of Qalam – Urgent Message"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/ftsg/ftsg_2.mp3", title: "For Those Seeking Guidance – Part 2"),
    SongModel(
        URL: "http://qalaminstitute.org/podcast/audio/heartwork_taha/heartwork_taha_16.mp3",
        title: "Heartwork – Surah Taha – Part 16 – Final"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/sotq/sotq_28.mp3", title: "Stories of the Quran: Surah Kawthar"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/sotq/sotq_27.mp3", title: "Stories of the Quran: Dawah in Prison"),
    SongModel(URL: "http://qalaminstitute.org/podcast/audio/Picture_vs_pixel.mp3", title: "Picture vs Pixel"),
  ];
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isConnectedToNetwork = true;
  String? directory;
  List<FileSystemEntity> _songs = [];
  //
  @override
  void initState() {
    super.initState();
    _pageManager = PageManager();
    _listofFiles();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    // Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
    //   _listofFiles();
    //   setState(() {
    //     print("connection change");
    //     isConnectedToNetwork = true;
    //     if (result == ConnectivityResult.none) {
    //       isConnectedToNetwork = false;
    //     }
    //   });
    // });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
      return;
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _listofFiles();
    setState(() {
      print("connection change");
      if (result == ConnectivityResult.none) {
        Utility.showToast("You are Offline");
        isConnectedToNetwork = false;
      } else {
        Utility.showToast("Internet Connected");
        isConnectedToNetwork = true;
      }
    });
  }

  void _listofFiles() async {
    Directory? dir = await getExternalStorageDirectory();
    String mp3Path = dir.toString();
    print("mp3Path: ${mp3Path}");
    List<FileSystemEntity> _files;
    _songs = [];
    _files = dir!.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      if (path.endsWith('.mp3')) _songs.add(entity);
    }
    setState(() {});
    print(_songs);
    print(_songs.length);
  }

  //
  @override
  Widget build(BuildContext context) {
    //
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    //
    return Scaffold(
      appBar: AppBar(
        title: Text("Qalam Podcast"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                Utility.showToast("downloading canceled");
                FlutterDownloader.cancelAll();
              },
              icon: Icon(Icons.cancel))
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: isConnectedToNetwork
                  ? ListView.builder(
                      padding: EdgeInsets.only(bottom: 40),
                      itemCount: _URLs.length,
                      itemBuilder: (ctx, idx) {
                        return ListWidget(_URLs[idx].URL, _URLs[idx].title, false);
                      })
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 40),
                      itemCount: _songs.length,
                      itemBuilder: (ctx, idx) {
                        return ListWidget(_songs[idx].path, _songs[idx].path, true);
                      })),
          // return ListWidget("file[idx].absolute.toString()", _songs[idx].path, true);
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)]),
            child: Column(
              children: [
                CurrentSongTitle(),
                SizedBox(height: 8),
                ValueListenableBuilder<ProgressBarState>(
                  valueListenable: _pageManager.progressNotifier,
                  builder: (_, value, __) {
                    return ProgressBar(
                      progress: value.current,
                      buffered: value.buffered,
                      total: value.total,
                      onSeek: _pageManager.seek,
                    );
                  },
                ),
                Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RewindSongButton(),
                      ValueListenableBuilder<ButtonState>(
                        valueListenable: _pageManager.playButtonNotifier,
                        builder: (_, value, __) {
                          switch (value) {
                            case ButtonState.loading:
                              return Container(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              );
                            case ButtonState.paused:
                              return CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.2),
                                radius: 28,
                                child: IconButton(
                                  icon: Icon(Icons.play_arrow, color: primaryColor),
                                  onPressed: _pageManager.play,
                                ),
                              );
                            case ButtonState.playing:
                              return CircleAvatar(
                                backgroundColor: primaryColor.withOpacity(0.2),
                                radius: 28,
                                child: IconButton(
                                  icon: Icon(Icons.pause, color: primaryColor),
                                  onPressed: _pageManager.pause,
                                ),
                              );
                          }
                        },
                      ),
                      ForwardSongButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //
  @override
  void dispose() {
    _pageManager.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }
}

class ListWidget extends StatefulWidget {
  final String URL;
  final String title;
  final bool isOffline;
  ListWidget(this.URL, this.title, this.isOffline, {Key? key}) : super(key: key);

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  //
  bool? downloading;
  int progress = 0;
  ReceivePort _port = ReceivePort();
  //

  @override
  void initState() {
    super.initState();
    downloading = false;
    _bindBackgroundIsolate();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];

      setState(() {
        // if (id == _downloadTaskId) {
        setState(() {
          this.progress = progress;
        });

        if (status == DownloadTaskStatus.complete) {
          Utility.showToast("downloading Finished!");
          setState(() {
            downloading = false;
          });
        }
        // }
      });
    });
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
    print("sta: ${status}");
    // print("prog: ${progress}");
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  String getFileNameFromPath(String path) {
    return path.split("files/").last;
  }

  //
  @override
  Widget build(BuildContext context) {
    print("offline check: ${widget.isOffline}");
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          onTap: () {
            print("URL check: ${widget.URL}");
            widget.isOffline
                ? _pageManager.ChangeSongTo(widget.URL, getFileNameFromPath(widget.URL), widget.isOffline)
                : _pageManager.ChangeSongTo(widget.URL, widget.title, widget.isOffline);
          },
          title: Text(widget.isOffline ? getFileNameFromPath(widget.title) : widget.title),
          trailing: widget.isOffline
              ? SizedBox()
              : IconButton(
                  icon: Icon(Icons.file_download, color: Colors.blue),
                  onPressed: () {
                    downloadFile(widget.URL, widget.title);
                  },
                ),
        ),
      ),
    );
  }

  Future downloadFile(String Url, String title) async {
    setState(() {
      downloading = true;
    });

    Directory? dir = await getExternalStorageDirectory();
    print("File saved at: ${dir!.path}");
    if (await _listofFiles(title)) {
      Utility.showToast("File already exists");
    } else {
      Utility.showToast("downloading started!");
      final taskId = await FlutterDownloader.enqueue(
        url: Url,
        fileName: title + ".${Url.split(".").last}",
        savedDir: dir.path,
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );
      FlutterDownloader.registerCallback(downloadCallback);
      print("taskId: ${taskId}");
      print("check: ${taskId}");
    }
  }

  Future<bool> _listofFiles(String title) async {
    Directory? dir = await getExternalStorageDirectory();
    String mp3Path = dir.toString();
    print("mp3Path: ${mp3Path}");
    List<FileSystemEntity> _files;
    _files = dir!.listSync(recursive: true, followLinks: false);
    for (FileSystemEntity entity in _files) {
      String path = entity.path;
      print("path: ${path}");
      print("path.contains(title) ${path.contains(title)}");
      if (path.contains(title)) return true;
      // if (path.endsWith('.mp3')) _songs.add(entity);
    }
    return false;
  }

  //
  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }
}

//////////

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Text(title, style: TextStyle(fontSize: 16));
      },
    );
  }
}

class ForwardSongButton extends StatelessWidget {
  const ForwardSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: Icon(Icons.fast_forward),
          onPressed: (isLast) ? null : _pageManager.onForwardSongButtonPressed,
        );
      },
    );
  }
}

class RewindSongButton extends StatelessWidget {
  const RewindSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: Icon(Icons.fast_rewind),
          onPressed: (isFirst) ? null : _pageManager.onRewindSongButtonPressed,
        );
      },
    );
  }
}
