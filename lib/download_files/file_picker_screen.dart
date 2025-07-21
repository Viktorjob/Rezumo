import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:rezumo/analysis_and_recommendation/check.dart';
import 'package:rezumo/download_files/bloc/file_picker_bloc.dart';
import 'package:rezumo/download_files/bloc/pdf_conversion_bloc.dart';
import 'package:rezumo/download_files/conversion_status_indicator.dart';
import 'package:rezumo/download_files/level_selector.dart';

import 'package:rezumo/download_files/pdf_preview_card.dart';

class FilePickerScreen extends StatefulWidget {
  const FilePickerScreen({Key? key}) : super(key: key);

  @override
  State<FilePickerScreen> createState() => _FilePickerScreenState();
}

class _FilePickerScreenState extends State<FilePickerScreen> {
  String? _selectedLevel;

  void _onAnalyzePressed(String filePath) {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a level')),
      );
      return;
    }

    context.read<PdfConversionBloc>().add(ConvertPdf(filePath));
  }

  void _onLevelSelected(String level) {
    setState(() {
      _selectedLevel = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezumo')),
      body: Center(
        child: BlocBuilder<FilePickerBloc, FilePickerState>(
          builder: (context, state) {
            if (state is FilePickerInitial) {
              return ElevatedButton(
                onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
                child: const Text('Select PDF'),
              );
            }

            if (state is FilePickerLoading) {
              return const CircularProgressIndicator();
            }

            if (state is FilePickerLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PdfPreviewCard(filePath: state.filePath),
                  const SizedBox(height: 20),
                  BlocConsumer<PdfConversionBloc, PdfConversionState>(
                    listener: (context, convState) {
                      if (convState is PdfConversionSuccess) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Check(
                              cvText: convState.html,
                              level: _selectedLevel!,
                            ),
                          ),
                        );
                      }
                    },
                    builder: (context, convState) {
                      return Column(
                        children: [
                          ConversionStatusIndicator(
                            isLoading: convState is PdfConversionLoading,
                            error: convState is PdfConversionFailure ? convState.message : null,
                          ),
                          const SizedBox(height: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
                                child: const Text('Select another file'),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: convState is PdfConversionLoading
                                    ? null
                                    : () => _onAnalyzePressed(state.filePath),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('Analyze PDF'),
                                    const SizedBox(width: 12),
                                    LevelSelector(
                                      selected: _selectedLevel,
                                      onSelected: _onLevelSelected,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              );
            }

            if (state is FilePickerError) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.read<FilePickerBloc>().add(PickFileEvent()),
                    child: const Text('Try again'),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
