import 'package:flutter/material.dart';

class ImageGalleryWidget extends StatelessWidget {
  final List<dynamic> getAllImagesHistory;
  final double screenRatio;

  ImageGalleryWidget({
    required this.getAllImagesHistory,
    required this.screenRatio,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: ListView.builder(
        itemCount: getAllImagesHistory.length,
        itemBuilder: (context, index) {
          final imageUrl = getAllImagesHistory[index]['imageUrl']!;
          return Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.01,
                vertical: screenRatio),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.14,
              height: MediaQuery.of(context).size.height * 0.4,
              child: GestureDetector(
                onTap: () => _showImageDialog(context, imageUrl),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.fitHeight,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _transformationController = TransformationController();
        final _scaleNotifier = ValueNotifier<double>(1.0);

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: screenRatio * 16,
                      ),
                      color: const Color(0xFF004283),
                    ),
                  ],
                ),
                Expanded(
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: true,
                    minScale: 0.1,
                    maxScale: 4.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.zoom_out,
                        size: screenRatio * 16,
                      ),
                      onPressed: () {
                        _scaleNotifier.value =
                            (_scaleNotifier.value / 1.1).clamp(0.1, 4.0);
                        _transformationController.value = Matrix4.identity()
                          ..scale(_scaleNotifier.value);
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.zoom_in,
                        size: screenRatio * 16,
                      ),
                      onPressed: () {
                        _scaleNotifier.value =
                            (_scaleNotifier.value * 1.1).clamp(0.1, 4.0);
                        _transformationController.value = Matrix4.identity()
                          ..scale(_scaleNotifier.value);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
