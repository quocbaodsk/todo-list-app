import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../../widgets/edit_task_sheet.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TaskProvider>().loadTasks();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    await context.read<TaskProvider>().loadTasks();
  }

  void _loadMore() {
    if (!context.read<TaskProvider>().isLoading) {
      context.read<TaskProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.tasks.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!provider.isLoading && provider.tasks.isEmpty) {
          return const EmptyTaskView();
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: provider.hasMore
                      ? provider.tasks.length + 1
                      : provider.tasks.length,
                  itemBuilder: (context, index) {
                    if (index >= provider.tasks.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: _loadMore,
                            icon: const Icon(Icons.refresh_outlined),
                            label: const Text('Load more'),
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TaskCard(task: provider.tasks[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _dismissProgress = 0.0;

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: EditTaskSheet(task: widget.task),
      ),
    );
  }

  Future<void> _toggleTaskStatus() async {
    await context.read<TaskProvider>().toggleTaskStatus(widget.task);
  }

  Future<void> _toggleFavorite() async {
    await context.read<TaskProvider>().toggleFavorite(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('task-${widget.task.id}'),
      direction: DismissDirection.endToStart,
      onUpdate: (DismissUpdateDetails details) {
        setState(() {
          _dismissProgress = details.progress;
        });
      },
      background: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        child: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: colorScheme.error,
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<TaskProvider>().deleteTask(widget.task.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
          borderRadius: _dismissProgress == 0
              ? BorderRadius.circular(12)
              : const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          border: Border.all(
            color: _dismissProgress != 0
                ? Colors.red
                : (widget.task.favorite
                ? Colors.orange[600]!
                : (widget.task.status == 'completed'
                ? colorScheme.primary
                : widget.task.isOverdue == true
                ? Colors.red
                : Colors.transparent)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onLongPress: () {
              Navigator.pushReplacementNamed(context, '/task-detail/${widget.task.id}');
            },
            onTap: () => _showEditDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleTaskStatus,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.task.status == 'completed'
                            ? colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: widget.task.status == 'completed'
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: 2,
                        ),
                      ),
                      child: widget.task.status == 'completed'
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: widget.task.status == 'completed'
                                ? TextDecoration.lineThrough
                                : null,
                            color: widget.task.status == 'completed'
                                ? colorScheme.outline
                                : null,
                          ),
                        ),
                        if (widget.task.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.task.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 12,
                              color: widget.task.isToday == true
                                  ? Colors.deepOrange
                                  : (widget.task.isOverdue == true
                                  ? Colors.red
                                  : colorScheme.primary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.task.isToday == true
                                  ? 'Hôm nay'
                                  : (widget.task.dateString ??
                                  _formatDate(widget.task.executionDate)),
                              style: TextStyle(
                                fontSize: 12,
                                color: widget.task.isToday == true
                                    ? Colors.deepOrange
                                    : (widget.task.isOverdue == true
                                    ? Colors.red
                                    : colorScheme.primary),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.task.repeat) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.repeat_rounded,
                                size: 14,
                                color: colorScheme.secondary,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      widget.task.favorite
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 22,
                      color: widget.task.favorite
                          ? Colors.orange[600]
                          : colorScheme.outline,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class EmptyTaskView extends StatelessWidget {
  const EmptyTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/empty.json',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 16),
          const Text(
            'No tasks yet',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first task by tapping the + button',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
