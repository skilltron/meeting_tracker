import 'package:flutter/material.dart';

class TrackingButton {
  final String id;
  final String name;
  final String? icon; // Icon name or emoji
  final Color? color;
  final int order;
  
  TrackingButton({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.order = 0,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': color?.value,
      'order': order,
    };
  }
  
  factory TrackingButton.fromJson(Map<String, dynamic> json) {
    return TrackingButton(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      color: json['colorValue'] != null 
          ? Color(json['colorValue'])
          : null,
      order: json['order'] ?? 0,
    );
  }
  
  TrackingButton copyWith({
    String? id,
    String? name,
    String? icon,
    Color? color,
    int? order,
  }) {
    return TrackingButton(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
    );
  }
}
