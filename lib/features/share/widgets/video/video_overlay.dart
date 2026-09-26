import 'package:aula360/features/share/export/screen_export.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../core/helper/text_utils/string_extension.dart';
import '../../../../utils/api_urls/api_urls.dart';

class AppVideoOverlay {
  static void show(
    BuildContext context, {
    required String videoUrl,
    String? title,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Video",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) {
        return Center(
          child: AppVideoPlayer(
            url: getVideoUrl(
              //     "https://nc5cnwcx-8000.inc1.devtunnels.ms/uploads/draftVideo/1785900922470-534162-21.mp4" ??
              videoUrl,
              ApiUrls.base, // your actual base url
            ),
            title: title,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          ),
        );
      },
    );
  }

  static String getVideoUrl(String? videoUrl, String baseUrl) {
    if (videoUrl == null || videoUrl.trim().isEmpty) {
      return '';
    }

    var url = videoUrl.trim();

    url = url.replaceAll("\\", "/");

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    return '${baseUrl.replaceAll(RegExp(r'/$'), '')}/${url.replaceFirst(RegExp(r'^/'), '')}';
  }
}

class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late final Player player;
  late final VideoController videoController;
  String? videoError;

  @override
  void initState() {
    super.initState();

    player = Player();
    videoController = VideoController(
      player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: false,
      ),
    );

    print("🎬 VIDEO URL: ${widget.url}");

    player.stream.playing.listen((playing) {
      print("▶️ Playing: $playing");
    });

    player.stream.position.listen((position) {
      print("⏱ Position: $position");
    });

    player.stream.duration.listen((duration) {
      print("⌛ Duration: $duration");
    });

    player.stream.buffer.listen((buffer) {
      print("📦 Buffer: $buffer");
    });

    player.stream.width.listen((width) {
      print("📐 Video Width: $width");
    });

    player.stream.height.listen((height) {
      print("📏 Video Height: $height");
    });

    player.stream.completed.listen((value) {
      print("COMPLETED: $value");
    });
    videoController.player.stream.videoParams.listen((params) {
      print("VIDEO PARAMS: $params");
    });

    player.stream.error.listen((error) {
      print("""
  ❌ MEDIA KIT ERROR

  URL:
  ${widget.url}

  Error:
  $error

  State:
  ${player.state}
  """);
      if (!mounted) return;

      setState(() {
        videoError = error.toString();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openVideo();
    });
  }

  Future<void> _openVideo() async {
    try {
      print("🚀 Opening video...");

      await player.open(Media(widget.url), play: true);

      print("✅ Video opened");

      print("""
      PLAYER STATE:
      Playing: ${player.state.playing}
      Position: ${player.state.position}
      Duration: ${player.state.duration}
      Volume: ${player.state.volume}
      """);
    } catch (e, stack) {
      print("🔥 OPEN VIDEO ERROR: $e");
      print(stack.toString());

      if (!mounted) return;

      setState(() {
        videoError = AppStrings.unableToPlayVideo;
      });
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * .92,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * .7,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black87,
                ),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (widget.title ?? "").capitalizeWords(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Gap(30),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: Colors.black,
                      child: videoError != null
                          ? _VideoErrorView(
                              onRetry: () {
                                setState(() {
                                  videoError = null;
                                });

                                _openVideo();
                              },
                            )
                          : Video(
                              controller: videoController,
                              fit: BoxFit.contain,

                              fill: Colors.black,
                              controls: MaterialVideoControls,
                              wakelock: true,
                              pauseUponEnteringBackgroundMode: true,
                              resumeUponEnteringForegroundMode: true,
                            ),
                    ),
                  ),
                ),
              ),

              /*
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  margin: EdgeInsets.all(12),
                  color: Colors.white,
                  child: videoError != null
                      ? _VideoErrorView(
                          onRetry: () {
                            setState(() {
                              videoError = null;
                            });

                            _openVideo();
                          },
                        )
                      :
                        // Video(
                        //     controller: videoController,
                        //     fit: BoxFit.contain,
                        //     fill: Colors.black,
                        //     controls: AdaptiveVideoControls,
                        //     filterQuality: FilterQuality.high,
                        //     wakelock: true,
                        //     pauseUponEnteringBackgroundMode: true,
                        //     resumeUponEnteringForegroundMode: true,
                        //     onEnterFullscreen: () async {
                        //       await defaultEnterNativeFullscreen();
                        //     },
                        //     onExitFullscreen: () async {
                        //       await defaultExitNativeFullscreen();
                        //     },
                        //   ),
                        Video(
                          controller: videoController,
                          fit: BoxFit.contain,
                          fill: Colors.black,
                          controls: MaterialVideoControls,
                          wakelock: true,
                          pauseUponEnteringBackgroundMode: true,
                          resumeUponEnteringForegroundMode: true,
                        ),
                ),
              ),
*/
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const _VideoErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 42),

            const SizedBox(height: 12),

            Text(
              AppStrings.unableToPlayVideo,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              AppStrings.videoUnavailableOrConnectionFailed,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}
