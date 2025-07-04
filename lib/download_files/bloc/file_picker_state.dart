part of 'file_picker_bloc.dart';

abstract class FilePickerState {}

class FilePickerInitial extends FilePickerState {}

class FilePickerLoading extends FilePickerState {}

class FilePickerLoaded extends FilePickerState {
  final String filePath;

  FilePickerLoaded(this.filePath);
}


class FilePickerError extends FilePickerState {
  final String message;

  FilePickerError(this.message);
}
