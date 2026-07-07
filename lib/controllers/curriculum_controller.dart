import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Curriculum Builder — module tree + lesson/uploader panel state.
class CurriculumController extends ChangeNotifier {
  CurriculumController();

  final List<String> breadcrumb = const ['CBSE', 'Class 10', 'Science'];

  List<ModuleModel> modules = const [
    ModuleModel(
      title: 'Module 1 · Chemical Reactions',
      subtitle: '11 lessons · published',
      isDraft: false,
      expanded: true,
      lessons: [
        LessonModel(title: 'Types of chemical reactions', duration: '12 min'),
        LessonModel(title: 'Balancing equations', duration: '9 min'),
      ],
    ),
    ModuleModel(
      title: 'Module 2 · Acids, Bases & Salts',
      subtitle: '9 lessons · published',
      isDraft: false,
    ),
    ModuleModel(
      title: 'Module 3 · Metals & Non-metals',
      subtitle: '6 lessons · draft',
      isDraft: true,
    ),
  ];

  // Lesson video panel.
  final String youtubeLink = 'youtu.be/3xR-pHSc4le';
  final String videoDuration = '11:05';
  final String uploadedPdf = 'ph-scale-notes.pdf';

  // Module settings.
  bool published = true;
  bool freePreview = false;

  void toggleModule(int index) {
    modules = [
      for (int i = 0; i < modules.length; i++)
        i == index ? modules[i].copyWith(expanded: !modules[i].expanded) : modules[i],
    ];
    notifyListeners();
  }

  void setPublished(bool value) {
    published = value;
    notifyListeners();
  }

  void setFreePreview(bool value) {
    freePreview = value;
    notifyListeners();
  }
}
