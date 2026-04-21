import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/pose_template.dart';

/// Instagram-style horizontal slider for selecting pose templates
class PoseEffectsSlider extends StatelessWidget {
  final List<PoseTemplate> templates;
  final PoseTemplate? selectedTemplate;
  final Function(PoseTemplate) onTemplateSelected;

  const PoseEffectsSlider({
    super.key,
    required this.templates,
    required this.selectedTemplate,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: templates.length,
        itemBuilder: (context, index) {
          final template = templates[index];
          final isSelected = template.id == selectedTemplate?.id;

          return GestureDetector(
            onTap: () => onTemplateSelected(template),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Effect Circle
                  Container(
                    width: isSelected ? 64 : 54,
                    height: isSelected ? 64 : 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.accentCyan : Colors.white24,
                        width: isSelected ? 3.0 : 2.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.accentCyan.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          color: Colors.black.withOpacity(isSelected ? 0.6 : 0.3),
                          child: Center(
                            child: template.emoji.isEmpty 
                              ? Text(
                                  (templates.indexOf(template) + 1).toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.accentCyan,
                                    fontSize: isSelected ? 22 : 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  template.emoji,
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 24,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Name label
                  Text(
                    template.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
