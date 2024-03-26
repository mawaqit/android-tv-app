import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MosqueMode {
  normal,
  announcement,
}

class DeviceState extends Equatable {
  final String language;
  final Orientation orientation;
  final String mosqueId;
  final MosqueMode mosqueMode;
  final bool termsAccepted;

  DeviceState({
    required this.language,
    required this.orientation,
    required this.mosqueId,
    required this.termsAccepted,
    required this.mosqueMode,
  });

  factory DeviceState.initial() {
    return DeviceState(
      language: 'unknown',
      mosqueMode: MosqueMode.normal,
      orientation: Orientation.portrait,
      mosqueId: '',
      termsAccepted: false,
    );
  }

  DeviceState copyWith({
    String? language,
    Orientation? orientation,
    String? mosqueId,
    bool? termsAccepted,
    MosqueMode? mosqueMode,
  }) {
    return DeviceState(
      language: language ?? this.language,
      orientation: orientation ?? this.orientation,
      mosqueId: mosqueId ?? this.mosqueId,
      mosqueMode: mosqueMode ?? this.mosqueMode,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  @override
  List<Object> get props => [language, orientation, mosqueId, termsAccepted, mosqueMode];
}
