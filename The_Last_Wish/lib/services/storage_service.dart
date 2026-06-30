import 'package:camera/camera.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  static final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dkrpmlv03',
    'flutter_upload',
    cache: false,
  );

  static Future<String> uploadVideo(XFile file) async {
    try {
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Video,
        ),
      );

      print("Video Uploaded Successfully");
      print(response.secureUrl);

      return response.secureUrl;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      rethrow;
    }
  }
}
