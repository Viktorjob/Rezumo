import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rezumo/download_files/pdf_converter_service.dart';


abstract class PdfConversionEvent {}

class ConvertPdf extends PdfConversionEvent {
  final String filePath;
  ConvertPdf(this.filePath);
}

abstract class PdfConversionState {}

class PdfConversionInitial extends PdfConversionState {}

class PdfConversionLoading extends PdfConversionState {}

class PdfConversionSuccess extends PdfConversionState {
  final String html;
  PdfConversionSuccess(this.html);
}

class PdfConversionFailure extends PdfConversionState {
  final String message;
  PdfConversionFailure(this.message);
}

class PdfConversionBloc extends Bloc<PdfConversionEvent, PdfConversionState> {
  final PdfConverterService _service;

  PdfConversionBloc(this._service) : super(PdfConversionInitial()) {
    on<ConvertPdf>(_onConvert);
  }

  Future<void> _onConvert(ConvertPdf event, Emitter<PdfConversionState> emit) async {
    emit(PdfConversionLoading());
    try {
      final result = await _service.convertPdfToHtml(event.filePath);
      emit(PdfConversionSuccess(result));
    } catch (e) {
      emit(PdfConversionFailure(e.toString()));
    }
  }
}
