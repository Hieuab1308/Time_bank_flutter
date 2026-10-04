import 'package:flutter/material.dart';

// Filter data model
class ServiceFilter {
  final String? category;
  final String? location;
  final DurationFilterOption? duration;
  final RangeValues? timeCreditsRange;

  const ServiceFilter({
    this.category,
    this.location,
    this.duration,
    this.timeCreditsRange,
  });

  ServiceFilter copyWith({
    String? category,
    String? location,
    DurationFilterOption? duration,
    RangeValues? timeCreditsRange,
  }) {
    return ServiceFilter(
      category: category ?? this.category,
      location: location ?? this.location,
      duration: duration ?? this.duration,
      timeCreditsRange: timeCreditsRange ?? this.timeCreditsRange,
    );
  }
}

enum DurationFilterOption {
  any,
  upTo30,
  between30And60,
  moreThan60,
}
