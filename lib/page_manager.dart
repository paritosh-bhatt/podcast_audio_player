import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PageManager {
  PageManager() {
    _init();
  }
  //
  final currentSongTitleNotifier = ValueNotifier<String>('For Those Seeking Guidance – Part 8');
  // final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  // final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  late AudioPlayer _audioPlayer;
  //
  void _init() async {
    _audioPlayer = AudioPlayer();
    _setInitialPlaylist();
    _listenForChangesInPlayerState();
    _listenForChangesInPlayerPosition();
    _listenForChangesInBufferedPosition();
    _listenForChangesInTotalDuration();
  }

  void _setInitialPlaylist() async {
    // const url = 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
    const url = 'http://qalaminstitute.org/podcast/audio/ftsg/ftsg_8.mp3';
    await _audioPlayer.setUrl(url);
  }

  void _listenForChangesInPlayerState() {
    _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }

  void _listenForChangesInPlayerPosition() {
    _audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInBufferedPosition() {
    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenForChangesInTotalDuration() {
    _audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void play() {
    _audioPlayer.play();
  }

  void pause() {
    _audioPlayer.pause();
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  void ChangeSongTo(String Url, String title, bool isOffline) async {
    isOffline ? await _audioPlayer.setFilePath(Url) : await _audioPlayer.setUrl(Url);
    currentSongTitleNotifier.value = title;
    play();
  }

  void dispose() {
    _audioPlayer.dispose();
  }

  void onRewindSongButtonPressed() {
    //TO DO
  }
  void onForwardSongButtonPressed() {
    //TO DO
  }
}

class ProgressNotifier extends ValueNotifier<ProgressBarState> {
  ProgressNotifier() : super(_initialValue);
  static const _initialValue = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
}

class ProgressBarState {
  const ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

class PlayButtonNotifier extends ValueNotifier<ButtonState> {
  PlayButtonNotifier() : super(_initialValue);
  static const _initialValue = ButtonState.paused;
}

enum ButtonState { paused, playing, loading }
