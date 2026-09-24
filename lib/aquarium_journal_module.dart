import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'models/aquarium_model.dart';
import 'local_reminder_service.dart';

const _ink = Color(0xFF12181F);
const _cyan = Color(0xFF00E5FF);
const _green = Color(0xFF00E676);
const _coral = Color(0xFFFF5252);

class JournalTimelineView extends StatefulWidget {
  const JournalTimelineView({super.key});

  @override
  State<JournalTimelineView> createState() => _JournalTimelineViewState();
}

class _JournalTimelineViewState extends State<JournalTimelineView> {
  final _searchController = TextEditingController();
  JournalCategory? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AquariumProvider>();
    final query = _searchController.text.toLowerCase();
    final entries = provider.journalEntries.where((entry) {
      final matchesQuery = query.isEmpty ||
          '${entry.title} ${entry.description} ${entry.tags.join(' ')}'
              .toLowerCase()
              .contains(query);
      return matchesQuery &&
          (_category == null || entry.category == _category);
    }).toList();

    return Scaffold(
      backgroundColor: _ink,
      appBar: AppBar(
        backgroundColor: _ink,
        foregroundColor: Colors.white,
        title: const Text('Dziennik akwarysty'),
        actions: [
          IconButton(
            tooltip: 'Porównaj zdjęcia',
            onPressed: () => _openComparer(context, entries),
            icon: const Icon(Icons.compare_outlined),
          ),
          IconButton(
            tooltip: 'Kalendarz zadań',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (_) => const AquariumCalendarView()),
            ),
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: 'Dodaj wpis',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const AddJournalEntryModal(),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final content = _JournalContent(
              searchController: _searchController,
              category: _category,
              entries: entries,
              onSearch: () => setState(() {}),
              onCategory: (value) => setState(() => _category = value),
            );
            if (constraints.maxWidth < 760) return content;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 18),
                    const Expanded(child: AquariumCalendarView(compact: true)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openComparer(BuildContext context, List<JournalEntry> entries) {
    final images = entries.expand((entry) => entry.imagePaths).toList();
    if (images.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodaj co najmniej dwa zdjęcia do dziennika.')),
      );
      return;
    }
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageGrowthComparer(before: images[0], after: images[1]),
      ),
    );
  }
}

class _JournalContent extends StatelessWidget {
  const _JournalContent({
    required this.searchController,
    required this.category,
    required this.entries,
    required this.onSearch,
    required this.onCategory,
  });

  final TextEditingController searchController;
  final JournalCategory? category;
  final List<JournalEntry> entries;
  final VoidCallback onSearch;
  final ValueChanged<JournalCategory?> onCategory;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: searchController,
            onChanged: (_) => onSearch(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Szukaj wpisów, tagów i obserwacji',
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: _cyan),
              filled: true,
              fillColor: Colors.white.withAlpha(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Wszystkie'),
                  selected: category == null,
                  onSelected: (_) => onCategory(null),
                ),
                ...JournalCategory.values.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(item.label),
                      selected: category == item,
                      onSelected: (_) => onCategory(item),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (entries.isEmpty)
            const _DarkEmptyState()
          else
            ...entries.map((entry) => _TimelineEntry(entry: entry)),
        ],
      ),
    );
  }
}

class _TimelineEntry extends StatelessWidget {
  const _TimelineEntry({required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: _cyan, shape: BoxShape.circle),
              ),
              Container(width: 2, height: 110, color: _cyan.withAlpha(70)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Card(
              color: Colors.white.withAlpha(15),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(entry.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        Text(_date(entry.date), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(entry.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                    if (entry.imagePaths.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 68,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: entry.imagePaths.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) => _JournalImage(source: entry.imagePaths[index]),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _DarkTag(label: entry.category.label),
                        ...entry.tags.map((tag) => _DarkTag(label: '#$tag')),
                        if (entry.attachedWaterParameters != null)
                          const _DarkTag(label: 'Pomiary wody'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AquariumCalendarView extends StatefulWidget {
  const AquariumCalendarView({super.key, this.compact = false});

  final bool compact;

  @override
  State<AquariumCalendarView> createState() => _AquariumCalendarViewState();
}

class _AquariumCalendarViewState extends State<AquariumCalendarView> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<AquariumProvider>().tasks;
    final dayTasks = tasks.where((task) => isSameDay(task.nextDueDate, _selectedDay)).toList();
    final upcoming = tasks.where((task) => !task.isCompletedToday).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));

    return Scaffold(
      backgroundColor: _ink,
      appBar: widget.compact
          ? null
          : AppBar(
              backgroundColor: _ink,
              foregroundColor: Colors.white,
              title: const Text('Kalendarz zadań'),
              actions: [
                IconButton(
                  tooltip: 'Dodaj zadanie',
                  onPressed: () => showDialog<void>(context: context, builder: (_) => const AddTaskModal()),
                  icon: const Icon(Icons.add_task),
                ),
              ],
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.compact)
              FilledButton.icon(
                onPressed: () => showDialog<void>(context: context, builder: (_) => const AddTaskModal()),
                icon: const Icon(Icons.add),
                label: const Text('Dodaj zadanie'),
              ),
            if (!widget.compact) const SizedBox(height: 12),
            Card(
              color: Colors.white.withAlpha(15),
              child: TableCalendar<AquariumTask>(
                firstDay: DateTime.utc(2020),
                lastDay: DateTime.utc(2035),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) => setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                }),
                eventLoader: (day) => tasks.where((task) => isSameDay(task.nextDueDate, day)).toList(),
                calendarStyle: const CalendarStyle(
                  defaultTextStyle: TextStyle(color: Colors.white),
                  weekendTextStyle: TextStyle(color: _cyan),
                  outsideTextStyle: TextStyle(color: Colors.white24),
                  selectedDecoration: BoxDecoration(color: _cyan, shape: BoxShape.circle),
                  todayDecoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: _green, shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  formatButtonVisible: false,
                  leftChevronIcon: Icon(Icons.chevron_left, color: _cyan),
                  rightChevronIcon: Icon(Icons.chevron_right, color: _cyan),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(isSameDay(_selectedDay, DateTime.now()) ? 'Na dziś' : 'Wybrany dzień', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (dayTasks.isEmpty)
              const Text('Brak zadań na ten dzień.', style: TextStyle(color: Colors.white54))
            else
              ...dayTasks.map((task) => _TaskTile(task: task)),
            if (upcoming.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text('Nadchodzące', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...upcoming.take(5).map((task) => _TaskTile(task: task)),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task});

  final AquariumTask task;

  @override
  Widget build(BuildContext context) {
    final overdue = task.nextDueDate.isBefore(DateTime.now()) && !task.isCompletedToday;
    return Card(
      color: Colors.white.withAlpha(15),
      child: ListTile(
        leading: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: IconButton(
            key: ValueKey(task.isCompletedToday),
            tooltip: task.isCompletedToday ? 'Odznacz jako zrobione' : 'Oznacz jako wykonane',
            icon: Icon(task.isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked, color: task.isCompletedToday ? _green : (overdue ? _coral : _cyan)),
            onPressed: () {
              final provider = context.read<AquariumProvider>();
              if (task.isCompletedToday) {
                provider.reopenTask(task.id);
              } else {
                provider.completeTask(task.id);
              }
            },
          ),
        ),
        title: Text(task.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text('${task.description}\n${_date(task.nextDueDate)}', style: TextStyle(color: overdue ? _coral : Colors.white60)),
        isThreeLine: true,
      ),
    );
  }
}

class AddTaskModal extends StatefulWidget {
  const AddTaskModal({super.key});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  TaskRecurrence _recurrence = TaskRecurrence.weekly;
  int _interval = 7;
  TimeOfDay _reminder = const TimeOfDay(hour: 9, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowe zadanie'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Tytuł')),
            TextField(controller: _description, decoration: const InputDecoration(labelText: 'Opis')),
            DropdownButtonFormField<TaskRecurrence>(
              initialValue: _recurrence,
              decoration: const InputDecoration(labelText: 'Powtarzanie'),
              items: const [
                DropdownMenuItem(value: TaskRecurrence.once, child: Text('Jednorazowe')),
                DropdownMenuItem(value: TaskRecurrence.daily, child: Text('Codziennie')),
                DropdownMenuItem(value: TaskRecurrence.everyXDays, child: Text('Co X dni')),
                DropdownMenuItem(value: TaskRecurrence.weekly, child: Text('Co tydzień')),
                DropdownMenuItem(value: TaskRecurrence.monthly, child: Text('Co miesiąc')),
              ],
              onChanged: (value) => setState(() => _recurrence = value!),
            ),
            if (_recurrence == TaskRecurrence.everyXDays)
              TextFormField(
                initialValue: '$_interval',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Liczba dni'),
                onChanged: (value) => _interval = int.tryParse(value) ?? 1,
              ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Przypomnienie'),
              subtitle: Text(_reminder.format(context)),
              trailing: const Icon(Icons.notifications_outlined),
              onTap: () async {
                final value = await showTimePicker(context: context, initialTime: _reminder);
                if (value != null) setState(() => _reminder = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        FilledButton(onPressed: _save, child: const Text('Zapisz')),
      ],
    );
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    final now = DateTime.now();
    var firstDue = DateTime(
      now.year,
      now.month,
      now.day,
      _reminder.hour,
      _reminder.minute,
    );
    if (firstDue.isBefore(now)) firstDue = firstDue.add(const Duration(days: 1));
    final task = AquariumTask(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        description: _description.text.trim(),
        recurrence: _recurrence,
        intervalDays: _recurrence == TaskRecurrence.everyXDays ? _interval : 1,
        nextDueDate: firstDue,
        reminderMinutes: _reminder.hour * 60 + _reminder.minute,
    );
    context.read<AquariumProvider>().addTask(task);
    LocalReminderService.instance.schedule(
      AquariumReminder(
        id: int.tryParse(task.id.substring(task.id.length - 8)) ?? 1,
        title: task.title,
        body: task.description,
        date: task.nextDueDate,
      ),
    );
    Navigator.pop(context);
  }
}

class AddJournalEntryModal extends StatefulWidget {
  const AddJournalEntryModal({super.key});

  @override
  State<AddJournalEntryModal> createState() => _AddJournalEntryModalState();
}

class _AddJournalEntryModalState extends State<AddJournalEntryModal> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  final _tags = TextEditingController();
  final _picker = ImagePicker();
  JournalCategory _category = JournalCategory.observation;
  bool _attachWater = false;
  final List<String> _images = [];

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _tags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nowy wpis dziennika'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Tytuł')),
            TextField(controller: _notes, maxLines: 4, decoration: const InputDecoration(labelText: 'Notatka')),
            DropdownButtonFormField<JournalCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategoria'),
              items: JournalCategory.values.map((item) => DropdownMenuItem(value: item, child: Text(item.label))).toList(),
              onChanged: (value) => setState(() => _category = value!),
            ),
            TextField(controller: _tags, decoration: const InputDecoration(labelText: 'Tagi, oddziel przecinkami')),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _attachWater,
              onChanged: (value) => setState(() => _attachWater = value ?? false),
              title: const Text('Podepnij ostatni pomiar wody'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(onPressed: () => _pickImages(ImageSource.gallery), icon: const Icon(Icons.photo_library_outlined), label: const Text('Galeria')),
                  OutlinedButton.icon(onPressed: () => _pickImages(ImageSource.camera), icon: const Icon(Icons.camera_alt_outlined), label: const Text('Aparat')),
                ],
              ),
            ),
            if (_images.isNotEmpty) Text('${_images.length} zdjęć gotowych do zapisu'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Anuluj')),
        FilledButton(onPressed: _save, child: const Text('Zapisz wpis')),
      ],
    );
  }

  Future<void> _pickImages(ImageSource source) async {
    final cameraImage = source == ImageSource.camera
      ? await _picker.pickImage(source: source, imageQuality: 82)
      : null;
    final selected = source == ImageSource.camera
      ? (cameraImage == null ? <XFile>[] : [cameraImage])
      : await _picker.pickMultiImage(imageQuality: 82);
    for (final file in selected) {
      final bytes = await file.readAsBytes();
      _images.add('data:image/${file.name.split('.').last};base64,${base64Encode(bytes)}');
    }
    if (mounted) setState(() {});
  }

  void _save() {
    if (_title.text.trim().isEmpty) return;
    final tests = context.read<AquariumProvider>().waterTests;
    final latest = tests.isEmpty ? null : tests.first;
    final attached = _attachWater && latest != null
        ? {'pH': latest.ph, 'NO3': latest.no3, 'PO4': latest.po4, 'Fe': latest.fe}
        : null;
    context.read<AquariumProvider>().addJournalEntry(
      JournalEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now(),
        title: _title.text.trim(),
        description: _notes.text.trim(),
        type: 'journal',
        imagePaths: List.unmodifiable(_images),
        category: _category,
        tags: _tags.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        attachedWaterParameters: attached,
      ),
    );
    Navigator.pop(context);
  }
}

class ImageGrowthComparer extends StatefulWidget {
  const ImageGrowthComparer({required this.before, required this.after, super.key});

  final String before;
  final String after;

  @override
  State<ImageGrowthComparer> createState() => _ImageGrowthComparerState();
}

class _ImageGrowthComparerState extends State<ImageGrowthComparer> {
  double _split = .5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ink,
      appBar: AppBar(backgroundColor: _ink, foregroundColor: Colors.white, title: const Text('Porównywarka Przed / Po')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Stack(
                    fit: StackFit.expand,
                    children: [
                      _ImageSource(source: widget.after),
                      ClipRect(
                        clipper: _RightClipper(_split),
                        child: _ImageSource(source: widget.before),
                      ),
                      Align(alignment: Alignment(_split * 2 - 1, 0), child: Container(width: 3, color: _cyan)),
                    ],
                  ),
                ),
              ),
              Slider(value: _split, onChanged: (value) => setState(() => _split = value), activeColor: _cyan),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('PRZED', style: TextStyle(color: Colors.white70)), Text('PO', style: TextStyle(color: Colors.white70))]),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightClipper extends CustomClipper<Rect> {
  const _RightClipper(this.split);
  final double split;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * split, size.height);

  @override
  bool shouldReclip(_RightClipper oldClipper) => oldClipper.split != split;
}

class _ImageSource extends StatelessWidget {
  const _ImageSource({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('data:')) {
      return Image.memory(base64Decode(source.split(',').last), fit: BoxFit.contain);
    }
    return Image.network(source, fit: BoxFit.contain, errorBuilder: (_, _, _) => const Icon(Icons.image_not_supported, color: Colors.white54, size: 48));
  }
}

class _JournalImage extends StatelessWidget {
  const _JournalImage({required this.source});
  final String source;

  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 68, child: _ImageSource(source: source)));
}

class _DarkTag extends StatelessWidget {
  const _DarkTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Chip(label: Text(label, style: const TextStyle(fontSize: 11)), backgroundColor: _cyan.withAlpha(30), side: BorderSide.none, visualDensity: VisualDensity.compact);
}

class _DarkEmptyState extends StatelessWidget {
  const _DarkEmptyState();

  @override
  Widget build(BuildContext context) => const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Brak wpisów. Dodaj pierwszą obserwację.', style: TextStyle(color: Colors.white54))));
}

String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';