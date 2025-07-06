import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rezumo/download_files/ui/check.dart';
import 'package:rezumo/menu_bar/menu_bar.dart';

import 'download_files/bloc/file_picker_bloc.dart';
import 'download_files/ui/file_picker_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FilePickerBloc(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PDF Picker Demo',
        home: BottomNavigationBarExample(),
      ),
    );
  }
}


