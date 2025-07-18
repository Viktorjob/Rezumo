import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rezumo/download_files/pdf_conversion_bloc.dart';
import 'package:rezumo/download_files/pdf_converter_service.dart';

import 'package:rezumo/menu_bar/menu_bar.dart';
import 'download_files/bloc/file_picker_bloc.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  debugPrint = (String? message, {int? wrapWidth}) {
    if (message?.contains('Adreno') == false &&
        message?.contains('Gralloc') == false) {
      debugPrintSynchronously(message, wrapWidth: wrapWidth);
    }
  };

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FilePickerBloc()),
        BlocProvider(create: (_) => PdfConversionBloc(
          PdfConverterService(apiKey: 'LKHfjqi7eZw9cFUTsRzqYp7ytxPTjKM7'),
        )),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PDF Picker Demo',
        home: BottomNavigationBarExample(),
      ),
    );
  }
}
