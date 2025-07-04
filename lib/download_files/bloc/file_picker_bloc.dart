import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';

part 'file_picker_event.dart';
part 'file_picker_state.dart';

class FilePickerBloc extends Bloc<FilePickerEvent, FilePickerState> {
  FilePickerBloc() : super(FilePickerInitial()) {
    on<PickFileEvent>(_onPickFile);
  }

  Future<void> _onPickFile(PickFileEvent event, Emitter<FilePickerState> emit) async {
    emit(FilePickerLoading());
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        emit(FilePickerLoaded(result.files.single.path!));
      } else {
        emit(FilePickerError('File not selected'));
      }
    } catch (e) {
      emit(FilePickerError('Error while selecting file: $e'));
    }
  }
}
