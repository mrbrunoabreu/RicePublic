import 'package:equatable/equatable.dart';
import '../base_bloc.dart';

abstract class CreatePersonalListState extends Equatable with LoaderController {
  /// notify change state without deep clone state
  final int version;

  final List? propss;
  CreatePersonalListState(this.version, [this.propss]);

  /// Copy object for use in action
  /// if need use deep clone
  CreatePersonalListState getStateCopy();

  CreatePersonalListState getNewVersion();

  @override
  List<Object> get props => propss as List<Object>;
}

class InCreatePersonalListState extends CreatePersonalListState {
  InCreatePersonalListState(int version) : super(version);

  @override
  String toString() => 'InCreatePersonalListState';

  @override
  InCreatePersonalListState getStateCopy() {
    return InCreatePersonalListState(0);
  }

  @override
  InCreatePersonalListState getNewVersion() {
    return InCreatePersonalListState(version + 1);
  }
}

class SavingPersonalListState extends CreatePersonalListState {
  SavingPersonalListState(int version) : super(version);

  @override
  String toString() => 'SavingPersonalListState';

  @override
  SavingPersonalListState getStateCopy() {
    return SavingPersonalListState(0);
  }

  @override
  SavingPersonalListState getNewVersion() {
    return SavingPersonalListState(version + 1);
  }
}

class SavedPersonalListState extends CreatePersonalListState {
  SavedPersonalListState(int version) : super(version);

  @override
  String toString() => 'SavedPersonalListState';

  @override
  SavedPersonalListState getStateCopy() {
    return SavedPersonalListState(0);
  }

  @override
  SavedPersonalListState getNewVersion() {
    return SavedPersonalListState(version + 1);
  }
}
