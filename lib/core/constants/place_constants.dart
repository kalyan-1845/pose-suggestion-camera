import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Defines place/scene types for pose suggestion filtering
class PlaceScene {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final LinearGradient gradient;

  const PlaceScene({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.gradient,
  });
}

class PlaceConstants {
  PlaceConstants._();

  static const List<PlaceScene> places = [
    PlaceScene(
      id: 'any',
      name: 'All Poses',
      icon: Icons.auto_awesome,
      description: 'Show all available poses',
      gradient: AppColors.primaryGradient,
    ),
    PlaceScene(
      id: 'beach',
      name: 'Beach',
      icon: Icons.beach_access,
      description: 'Sandy shores & ocean vibes',
      gradient: LinearGradient(
        colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
      ),
    ),
    PlaceScene(
      id: 'park',
      name: 'Park / Garden',
      icon: Icons.park,
      description: 'Green spaces & nature',
      gradient: LinearGradient(
        colors: [Color(0xFF56AB2F), Color(0xFFA8E063)],
      ),
    ),
    PlaceScene(
      id: 'urban',
      name: 'Urban / Street',
      icon: Icons.location_city,
      description: 'City walls & architecture',
      gradient: LinearGradient(
        colors: [Color(0xFF636FA4), Color(0xFFE8CBC0)],
      ),
    ),
    PlaceScene(
      id: 'indoor',
      name: 'Indoor / Home',
      icon: Icons.home,
      description: 'Living room & studio',
      gradient: LinearGradient(
        colors: [Color(0xFFDA4453), Color(0xFF89216B)],
      ),
    ),
    PlaceScene(
      id: 'cafe',
      name: 'Café',
      icon: Icons.coffee,
      description: 'Cozy seated settings',
      gradient: LinearGradient(
        colors: [Color(0xFFB24592), Color(0xFFF15F79)],
      ),
    ),
    PlaceScene(
      id: 'mountain',
      name: 'Mountain / Nature',
      icon: Icons.terrain,
      description: 'Scenic landscapes & trails',
      gradient: LinearGradient(
        colors: [Color(0xFF134E5E), Color(0xFF71B280)],
      ),
    ),
    PlaceScene(
      id: 'sunset',
      name: 'Sunset / Golden Hour',
      icon: Icons.wb_twilight,
      description: 'Backlit & silhouette shots',
      gradient: LinearGradient(
        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
      ),
    ),
    PlaceScene(
      id: 'event',
      name: 'Event / Wedding',
      icon: Icons.celebration,
      description: 'Formal celebrations',
      gradient: LinearGradient(
        colors: [Color(0xFFBE93C5), Color(0xFF7BC6CC)],
      ),
    ),
    PlaceScene(
      id: 'steps',
      name: 'Steps / Stairs',
      icon: Icons.stairs,
      description: 'Multi-level compositions',
      gradient: LinearGradient(
        colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      ),
    ),
  ];

  /// Get a PlaceScene by ID
  static PlaceScene getById(String id) {
    return places.firstWhere(
      (p) => p.id == id,
      orElse: () => places.first,
    );
  }
}
