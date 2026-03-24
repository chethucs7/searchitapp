import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/database_service.dart';
import '../models/record_model.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool autoFocus;
  
  const SearchScreen({
    super.key,
    this.autoFocus = false,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late DatabaseService _dbService;
  late FocusNode _focusNode;
  List<ExcelRecord> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _dbService = DatabaseService();
    _focusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
    
    // Request focus if autoFocus is enabled
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _performSearch();
  }

  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();

    if (keyword.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _dbService.searchRecords(keyword);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  String _getDisplayText(ExcelRecord record) {
    final rowData = record.rowData;

    String? candidateName;
    String? epicNumber;

    for (var key in rowData.keys) {
      if (key.toLowerCase().contains('candidate_name')) {
        candidateName = rowData[key]?.toString();
      }
      if (key.toLowerCase().contains('unnamed') && key.toLowerCase().contains('14')) {
        epicNumber = rowData[key]?.toString();
      }
    }

    if (candidateName != null && epicNumber != null) {
      return '$candidateName - $epicNumber';
    }

    final firstTwo = <String>[];
    for (var value in rowData.values) {
      if (firstTwo.length >= 2) break;
      final strValue = value?.toString().trim();
      if (strValue != null && strValue.isNotEmpty) {
        firstTwo.add(strValue);
      }
    }

    return firstTwo.join(' - ');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Section
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              child: TextField(
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, EPIC, address...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
            ),
            
            // Results Section
            Expanded(
              child: _isSearching
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Start Searching',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a keyword to find records',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade100,
              ),
              child: Icon(
                Icons.inbox_rounded,
                size: 48,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Records Found',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      itemBuilder: (context, index) {
        final record = _searchResults[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(record: record),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              title: Text(
                _getDisplayText(record),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Wrapper for auto-focused search screen
class SearchScreenWithAutoFocus extends StatelessWidget {
  const SearchScreenWithAutoFocus({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: const SearchScreen(autoFocus: true),
    );
  }
}
