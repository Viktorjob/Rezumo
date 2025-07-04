import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/file_picker_bloc.dart';

class FilePickerScreen extends StatelessWidget {
  const FilePickerScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezumo')),
      body: Center(
        child: BlocBuilder<FilePickerBloc, FilePickerState>(
          builder: (context, state) {
            if (state is FilePickerInitial) {
              return ElevatedButton(
                onPressed: () {
                  context.read<FilePickerBloc>().add(PickFileEvent());
                },
                child: const Text('Выбрать PDF'),
              );
            } else if (state is FilePickerLoading) {
              return const CircularProgressIndicator();
            } else if (state is FilePickerLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Text('Выбран файл:\n${state.filePath}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FilePickerBloc>().add(PickFileEvent());
                    },
                    child: const Text('Выбрать другой файл'),
                  ),
                ],
              );
            } else if (state is FilePickerError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ошибка: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FilePickerBloc>().add(PickFileEvent());
                    },
                    child: const Text('Попробовать снова'),
                  ),
                ],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}

