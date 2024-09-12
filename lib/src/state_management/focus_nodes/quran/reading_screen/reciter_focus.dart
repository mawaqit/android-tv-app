import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReciterFocusState {
  final FocusNode reciterFocusNode;
  final List<FocusNode> reciteTypeFocusNodeList;
  final FocusNode floatingActionButtonFocusNode;
  final FocusScopeNode reciterFocusScopeNode;
  final FocusScopeNode globalScreenFocusNode;
  final FocusScopeNode reciterTypeFocusScopeNode;
  ReciterFocusState({
    required this.reciterFocusNode,
    required this.reciteTypeFocusNodeList,
    required this.floatingActionButtonFocusNode,
    required this.reciterFocusScopeNode,
    required this.globalScreenFocusNode,
    required this.reciterTypeFocusScopeNode,
  });

  ReciterFocusState copyWith({
    FocusNode? reciterFocusNode,
    List<FocusNode>? reciteTypeFocusNodeList,
    FocusNode? floatingActionButtonFocusNode,
    FocusScopeNode? reciterFocusScopeNode,
    FocusScopeNode? globalScreenFocusNode,
    FocusScopeNode? reciterTypeFocusScopeNode,
  }) {
    return ReciterFocusState(
      reciterFocusNode: reciterFocusNode ?? this.reciterFocusNode,
      reciteTypeFocusNodeList: reciteTypeFocusNodeList ?? this.reciteTypeFocusNodeList,
      floatingActionButtonFocusNode: floatingActionButtonFocusNode ?? this.floatingActionButtonFocusNode,
      reciterFocusScopeNode: reciterFocusScopeNode ?? this.reciterFocusScopeNode,
      globalScreenFocusNode: globalScreenFocusNode ?? this.globalScreenFocusNode,
      reciterTypeFocusScopeNode: reciterTypeFocusScopeNode ?? this.reciterTypeFocusScopeNode,
    );
  }
}

class ReciterFocusNotifier extends AutoDisposeNotifier<ReciterFocusState> {
  @override
  ReciterFocusState build() {
    return ReciterFocusState(
      reciterFocusNode: FocusNode(debugLabel: 'reciter'),
      reciteTypeFocusNodeList: [],
      floatingActionButtonFocusNode: FocusNode(debugLabel: 'floating_action_focus'),
      reciterFocusScopeNode: FocusScopeNode(debugLabel: 'reciter_list_focus_scope'),
      globalScreenFocusNode: FocusScopeNode(debugLabel: 'global_screen_focus_scope'),
      reciterTypeFocusScopeNode: FocusScopeNode(debugLabel: 'reciter_type_focus_scope'),
    );
  }



  void dispose() {
    state.reciterFocusNode.dispose();
    state.floatingActionButtonFocusNode.dispose();
    state.reciterFocusScopeNode.dispose();
    state.globalScreenFocusNode.dispose();
    state.reciterTypeFocusScopeNode.dispose();
    for(FocusNode focusNode in state.reciteTypeFocusNodeList) {
      focusNode.dispose();
    }
  }

  void addReciteTypeFocusNode(FocusNode focusNode) {
    state.reciteTypeFocusNodeList.add(focusNode);
  }

  void requestFocus(FocusNode focusNode) {
    focusNode.requestFocus();
  }

  void unFocusAll() {
    state.reciterFocusNode.unfocus();
    state.floatingActionButtonFocusNode.unfocus();
    state.reciterFocusScopeNode.unfocus();
    for(FocusNode focusNode in state.reciteTypeFocusNodeList) {
      focusNode.unfocus();
    }
  }

  void unFocus(FocusNode focusNode) {
    focusNode.unfocus();
  }
}

final reciterFocusProvider = AutoDisposeNotifierProvider<ReciterFocusNotifier, ReciterFocusState>(
  ReciterFocusNotifier.new,
);
