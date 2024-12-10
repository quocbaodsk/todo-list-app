import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/theme_provider.dart';
import 'notification_screen.dart';
import 'task_screen.dart';
import 'weather_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TaskScreen(),
    WeatherScreen(),
    NotificationScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'Tasks',
    'Weather',
    'Notifications',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 0) ...[
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                _showSortBottomSheet(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                _showFilterBottomSheet(context);
              },
            ),
          ],
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddTaskSheet(context);
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Weather',
          ),
          NavigationDestination(
            icon: Icon(Icons.notification_important_outlined),
            selectedIcon: Icon(Icons.notification_important),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: const Text('Title'),
                onTap: () {
                  context.read<TaskProvider>().setSortBy('title', true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: const Text('Favorite'),
                onTap: () {
                  context.read<TaskProvider>().setSortBy('favorite', true);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Created Date'),
                onTap: () {
                  context
                      .read<TaskProvider>()
                      .setSortBy('execution_date', true);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.all_inclusive),
                title: const Text('All'),
                onTap: () {
                  taskProvider.setFilter(status: 'all');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending),
                title: const Text('Pending'),
                onTap: () {
                  taskProvider.setFilter(status: 'pending');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Completed'),
                onTap: () {
                  taskProvider.setFilter(status: 'completed');
                  Navigator.pop(context);
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.calendar_today),
              //   title: const Text('By Date'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     _selectFilterDate(context, taskProvider);
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  // Future<void> _selectFilterDate(BuildContext context, TaskProvider taskProvider) async {
  //   final date = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2025),
  //   );
  //   if (date != null && context.mounted) {
  //     taskProvider.setFilter(date: date);
  //   }
  // }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const AddTaskSheet(),
      ),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isFavorite = false;
  bool _isRepeat = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final task = Task(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        executionDate: _selectedDate,
        favorite: _isFavorite,
        repeat: _isRepeat,
      );

      await context.read<TaskProvider>().createTask(task);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Task',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Date Picker
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Due Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onPressed: _selectDate,
            ),
            const SizedBox(height: 16),

            // Toggles Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Favorite Toggle
                Row(
                  children: [
                    Switch(
                      value: _isFavorite,
                      onChanged: (value) {
                        setState(() => _isFavorite = value);
                      },
                    ),
                    const Text('Favorite'),
                  ],
                ),
                // Repeat Toggle
                Row(
                  children: [
                    Switch(
                      value: _isRepeat,
                      onChanged: (value) {
                        setState(() => _isRepeat = value);
                      },
                    ),
                    const Text('Repeat'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            FilledButton(
              onPressed: _isLoading ? null : _submitForm,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
