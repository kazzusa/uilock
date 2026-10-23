import 'package:flutter/material.dart';

/// Screen 2 of 2 in productivity mode: the text-only app menu.
/// Apps are grouped by first letter, with a search field at the bottom
/// and a column of dots on the right showing the current letter.
class ProductivityMenuScreen extends StatefulWidget {
  const ProductivityMenuScreen({super.key});

  @override
  State<ProductivityMenuScreen> createState() => _ProductivityMenuScreenState();
}

/// One letter section: the letter, its apps, and where it starts in the list.
class _Group {
  final String letter;
  final List<String> apps;
  final double offset;

  const _Group(this.letter, this.apps, this.offset);
}

class _ProductivityMenuScreenState extends State<ProductivityMenuScreen> {
  // Fixed heights let us calculate where each letter starts in the list,
  // which is how the dots know which letter is on screen.
  static const _headerHeight = 80.0;
  static const _itemHeight = 28.0;

  // FAKE DATA for now. A later stage replaces this with the real
  // installed apps of the phone.
  static const _allApps = [
    'Telegram',
    'Todoist',
    'UILock',
    'WhatsApp',
    'ZArchiver',
    'Calculator',
    'Camera',
    'Chrome',
    'Clock',
    'Gmail',
    'Maps',
    'Photos',
    'Spotify',
  ];

  final _scrollController = ScrollController();
  List<_Group> _groups = [];
  int _activeGroup = 0;

  @override
  void initState() {
    super.initState();
    _groups = _buildGroups('');
    _scrollController.addListener(_updateActiveGroup);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Filters the apps by [query], sorts them A-Z, and groups them by letter.
  /// Returns the group letter for an app name: A-Z, or '#' for everything else
  /// (numbers, symbols, emoji, accented or non-Latin letters).
  String _letterOf(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final first = String.fromCharCode(trimmed.runes.first).toUpperCase();
    return RegExp(r'^[A-Z]$').hasMatch(first) ? first : '#';
  }

  /// Filters the apps by [query], sorts them A-Z, and groups them by letter.
  List<_Group> _buildGroups(String query) {
    final q = query.trim().toLowerCase();
    final apps = _allApps.where((a) => a.toLowerCase().contains(q)).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    final byLetter = <String, List<String>>{};
    for (final app in apps) {
      byLetter.putIfAbsent(_letterOf(app), () => []).add(app);
    }

    // Letters A-Z in order, then '#' at the end.
    final letters = byLetter.keys.toList()
      ..sort((a, b) {
        if (a == '#') return 1;
        if (b == '#') return -1;
        return a.compareTo(b);
      });

    final groups = <_Group>[];
    var offset = 0.0;
    for (final letter in letters) {
      final list = byLetter[letter]!;
      groups.add(_Group(letter, list, offset));
      offset += _headerHeight + list.length * _itemHeight;
    }
    return groups;
  }

  /// Runs while the list scrolls. Finds which letter is at the top.
  void _updateActiveGroup() {
    if (_groups.isEmpty || !_scrollController.hasClients) return;

    final position = _scrollController.position;
    var index = 0;
    for (var i = 0; i < _groups.length; i++) {
      if (_groups[i].offset <= position.pixels + 1) index = i;
    }

    // At the very bottom, the last letter may never reach the top,
    // so it is selected by hand.
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent - 1) {
      index = _groups.length - 1;
    }

    if (index != _activeGroup) setState(() => _activeGroup = index);
  }

  void _onSearch(String query) {
    setState(() {
      _groups = _buildGroups(query);
      _activeGroup = 0;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _openApp(String app) {
    if (app == 'UILock') {
      // Close the Menu and Home screens and return to the main UILock screen.
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }
    // TODO: open the other apps (a later stage).
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161616),
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                // The alphabetical list
                ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 24, right: 40),
                  children: [
                    for (final group in _groups) ...[
                      SizedBox(
                        height: _headerHeight,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              group.letter,
                              style: const TextStyle(
                                color: Color(0xFF5A5A5A),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (final app in group.apps)
                        SizedBox(
                          height: _itemHeight,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _openApp(app),
                              child: Text(
                                app,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ],
                ),

                // The dots on the right edge
                Positioned(
                  right: 12,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _IndexDots(
                      count: _groups.length,
                      active: _activeGroup,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search field
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: TextField(
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                  filled: true,
                  fillColor: const Color(0xFF404040),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A vertical column of dots, one per letter. The current letter is bigger
/// and white.
class _IndexDots extends StatelessWidget {
  final int count;
  final int active;

  const _IndexDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(vertical: 4),
          width: isActive ? 7 : 3,
          height: isActive ? 7 : 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : const Color(0xFF6A6A6A),
          ),
        );
      }),
    );
  }
}
