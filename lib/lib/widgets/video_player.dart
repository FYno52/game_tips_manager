import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen(
      {super.key, required this.videoUrl, required this.title});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool _isPlaying = false;
  double _volume = 1.0;
  bool _hasError = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.initialize().then((_) {
      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: _controller.value.aspectRatio,
          autoPlay: true,
          looping: false,
          fullScreenByDefault: false,
        );
        setState(() {
          // 最初のフレームを描画するため初期化後に更新
        });
      }
    }).catchError((error) {
      setState(() {
        _hasError = true;
      });
    });

    _controller.addListener(() {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : _volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: _hasError
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Invalid URL',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_controller.value.isInitialized)
                    Flexible(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            child: Chewie(
                              controller: _chewieController!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  _ProgressText(controller: _controller),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: IconButton(
                          onPressed: () {
                            _controller.seekTo(
                              _controller.value.position -
                                  const Duration(seconds: 10),
                            );
                          },
                          icon: const Icon(Icons.replay_10),
                        ),
                      ),
                      Expanded(
                        child: IconButton(
                          onPressed: _togglePlayPause,
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.volume_down,
                          color: Colors.white,
                        ),
                        onPressed: _toggleMute,
                      ),
                      Expanded(
                        child: Slider(
                          value: _isMuted ? 0.0 : _volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            setState(() {
                              _volume = value;
                              if (!_isMuted) {
                                _controller.setVolume(_volume);
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _ProgressText extends StatefulWidget {
  final VideoPlayerController controller;

  const _ProgressText({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  __ProgressTextState createState() => __ProgressTextState();
}

class __ProgressTextState extends State<_ProgressText> {
  late VoidCallback _listener;

  __ProgressTextState() {
    _listener = () {
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_listener);
  }

  @override
  void dispose() {
    // ここでdisposeメソッドを使用します
    widget.controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String position = widget.controller.value.position.toString();
    final String duration = widget.controller.value.duration.toString();
    return Text(
      '$position / $duration',
      style: const TextStyle(color: Colors.white),
    );
  }
}
