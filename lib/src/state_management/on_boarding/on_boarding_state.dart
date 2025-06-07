import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mawaqit/src/models/mosque.dart';
import 'package:mawaqit/src/data/countries.dart';

enum MosqueMode {
  normal,
  announcement,
}

class OnboardingState extends Equatable {
  String language;
  Orientation orientation;
  String mosqueId;
  MosqueMode mosqueMode;
  bool termsAccepted;
  final bool isRootedDevice;
  final Country? selectedCountry;

  OnboardingState({
    required this.language,
    required this.orientation,
    required this.mosqueId,
    required this.termsAccepted,
    required this.mosqueMode,
    this.isRootedDevice = false,
    this.selectedCountry,
  });

  factory OnboardingState.initial() {
    return OnboardingState(
      language: 'unknown',
      mosqueMode: MosqueMode.normal,
      orientation: Orientation.portrait,
      mosqueId: '',
      termsAccepted: false,
      isRootedDevice: false,
      selectedCountry: null,
    );
  }

  OnboardingState copyWith({
    String? language,
    Orientation? orientation,
    String? mosqueId,
    bool? termsAccepted,
    MosqueMode? mosqueMode,
    bool? isRootedDevice,
    Country? selectedCountry,
  }) {
    return OnboardingState(
      language: language ?? this.language,
      orientation: orientation ?? this.orientation,
      mosqueId: mosqueId ?? this.mosqueId,
      mosqueMode: mosqueMode ?? this.mosqueMode,
      isRootedDevice: isRootedDevice ?? this.isRootedDevice,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }

  @override
  List<Object?> get props => [
        language,
        orientation,
        mosqueId,
        termsAccepted,
        mosqueMode,
        isRootedDevice,
        selectedCountry,
      ];
}
