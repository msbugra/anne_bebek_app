import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cultural_tradition_model.dart';
import '../../core/services/database_service.dart';

class CultureProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  CultureProvider({required DatabaseService databaseService})
    : _databaseService = databaseService;

  // State
  List<CulturalTraditionModel> _allTraditions = [];
  List<CulturalTraditionModel> _filteredTraditions = [];
  List<CulturalTraditionModel> _favoriteTraditions = [];
  Set<int> _favoriteIds = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  CulturalOrigin? _selectedOrigin;
  TraditionCategory? _selectedCategory;
  AgeRange? _selectedAgeRange;
  String _searchQuery = '';

  // Getters
  List<CulturalTraditionModel> get allTraditions => _allTraditions;
  List<CulturalTraditionModel> get filteredTraditions => _filteredTraditions;
  List<CulturalTraditionModel> get favoriteTraditions => _favoriteTraditions;
  List<CulturalTraditionModel> get turkishTraditions =>
      _allTraditions.where((t) => t.origin == CulturalOrigin.turkish).toList();
  List<CulturalTraditionModel> get worldTraditions =>
      _allTraditions.where((t) => t.origin == CulturalOrigin.world).toList();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CulturalOrigin? get selectedOrigin => _selectedOrigin;
  TraditionCategory? get selectedCategory => _selectedCategory;
  AgeRange? get selectedAgeRange => _selectedAgeRange;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _selectedOrigin != null ||
      _selectedCategory != null ||
      _selectedAgeRange != null ||
      _searchQuery.isNotEmpty;

  // İstatistikler
  int get totalTraditions => _allTraditions.length;
  int get turkishTraditionsCount => turkishTraditions.length;
  int get worldTraditionsCount => worldTraditions.length;
  int get favoritesCount => _favoriteTraditions.length;

  // Initialization
  Future<void> initialize() async {
    await _loadTraditions();
    await _loadFavorites();
    _applyFilters();
  }

  // Load traditions from database or sample data
  Future<void> _loadTraditions() async {
    try {
      setLoading(true);

      // Database'den gelenekleri yükle
      List<Map<String, dynamic>> traditionsData = await _databaseService.query(
        'cultural_traditions',
        orderBy: 'created_at DESC',
      );

      if (traditionsData.isNotEmpty) {
        _allTraditions = traditionsData
            .map((data) => CulturalTraditionModel.fromMap(data))
            .toList();
      } else {
        // Database boşsa örnek verileri yükle ve kaydet
        await _loadSampleData();
      }

      _clearError();
    } catch (e) {
      _setError('Gelenekler yüklenirken hata oluştu: $e');
      // Hata durumunda örnek verileri yükle
      _allTraditions = CulturalTraditionService.getAllTraditions();
    } finally {
      setLoading(false);
    }
  }

  // Load sample data to database
  Future<void> _loadSampleData() async {
    try {
      _allTraditions = CulturalTraditionService.getAllTraditions();

      // Database'e örnek verileri kaydet
      for (CulturalTraditionModel tradition in _allTraditions) {
        await _databaseService.insert('cultural_traditions', tradition.toMap());
      }

      debugPrint(
        'Örnek gelenekler database\'e kaydedildi: ${_allTraditions.length} adet',
      );
    } catch (e) {
      debugPrint('Örnek veriler kaydedilirken hata: $e');
    }
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? favoriteIds = prefs.getStringList('favorite_traditions');

      if (favoriteIds != null) {
        _favoriteIds = favoriteIds.map((id) => int.parse(id)).toSet();
        _updateFavoritesList();
      }
    } catch (e) {
      debugPrint('Favoriler yüklenirken hata: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> favoriteIds = _favoriteIds
          .map((id) => id.toString())
          .toList();
      await prefs.setStringList('favorite_traditions', favoriteIds);
    } catch (e) {
      debugPrint('Favoriler kaydedilirken hata: $e');
    }
  }

  // Update favorites list
  void _updateFavoritesList() {
    _favoriteTraditions = _allTraditions
        .where(
          (tradition) =>
              tradition.id != null && _favoriteIds.contains(tradition.id!),
        )
        .toList();
  }

  // Toggle favorite
  Future<void> toggleFavorite(CulturalTraditionModel tradition) async {
    if (tradition.id == null) return;

    if (_favoriteIds.contains(tradition.id!)) {
      _favoriteIds.remove(tradition.id!);
    } else {
      _favoriteIds.add(tradition.id!);
    }

    _updateFavoritesList();
    await _saveFavorites();
    notifyListeners();
  }

  // Check if tradition is favorite
  bool isFavorite(CulturalTraditionModel tradition) {
    return tradition.id != null && _favoriteIds.contains(tradition.id!);
  }

  // Search
  void searchTraditions(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Filter by origin
  void filterByOrigin(CulturalOrigin? origin) {
    _selectedOrigin = origin;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(TraditionCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Filter by age range
  void filterByAgeRange(AgeRange? ageRange) {
    _selectedAgeRange = ageRange;
    _applyFilters();
    notifyListeners();
  }

  // Filter by baby age (in days)
  void filterByBabyAge(int babyAgeInDays) {
    List<CulturalTraditionModel> ageAppropriate =
        CulturalTraditionService.getTraditionsForBabyAge(
          _allTraditions,
          babyAgeInDays,
        );
    _filteredTraditions = ageAppropriate;
    notifyListeners();
  }

  // Clear all filters
  void clearAllFilters() {
    _selectedOrigin = null;
    _selectedCategory = null;
    _selectedAgeRange = null;
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Apply current filters
  void _applyFilters() {
    List<CulturalTraditionModel> filtered = List.from(_allTraditions);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = CulturalTraditionService.searchTraditions(
        filtered,
        _searchQuery,
      );
    }

    // Origin filter
    if (_selectedOrigin != null) {
      filtered = CulturalTraditionService.getTraditionsByOrigin(
        filtered,
        _selectedOrigin!,
      );
    }

    // Category filter
    if (_selectedCategory != null) {
      filtered = CulturalTraditionService.getTraditionsByCategory(
        filtered,
        _selectedCategory!,
      );
    }

    // Age range filter
    if (_selectedAgeRange != null) {
      filtered = CulturalTraditionService.getTraditionsByAgeRange(
        filtered,
        _selectedAgeRange!,
      );
    }

    _filteredTraditions = filtered;
  }

  // Get traditions by category
  List<CulturalTraditionModel> getTraditionsByCategory(
    TraditionCategory category,
  ) {
    return CulturalTraditionService.getTraditionsByCategory(
      _allTraditions,
      category,
    );
  }

  // Get traditions by origin
  List<CulturalTraditionModel> getTraditionsByOrigin(CulturalOrigin origin) {
    return CulturalTraditionService.getTraditionsByOrigin(
      _allTraditions,
      origin,
    );
  }

  // Get tradition by id
  CulturalTraditionModel? getTraditionById(int id) {
    try {
      return _allTraditions.firstWhere((tradition) => tradition.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get related traditions (same category, different tradition)
  List<CulturalTraditionModel> getRelatedTraditions(
    CulturalTraditionModel tradition, {
    int limit = 5,
  }) {
    List<CulturalTraditionModel> related = _allTraditions
        .where((t) => t.category == tradition.category && t.id != tradition.id)
        .toList();

    if (related.length > limit) {
      related = related.take(limit).toList();
    }

    return related;
  }

  // Get random traditions
  List<CulturalTraditionModel> getRandomTraditions({int count = 5}) {
    List<CulturalTraditionModel> shuffled = List.from(_allTraditions);
    shuffled.shuffle();
    return shuffled.take(count).toList();
  }

  // Get category statistics
  Map<TraditionCategory, int> getCategoryStatistics() {
    Map<TraditionCategory, int> stats = {};

    for (TraditionCategory category in TraditionCategory.values) {
      stats[category] = _allTraditions
          .where((t) => t.category == category)
          .length;
    }

    return stats;
  }

  // Get origin statistics
  Map<CulturalOrigin, int> getOriginStatistics() {
    Map<CulturalOrigin, int> stats = {};

    for (CulturalOrigin origin in CulturalOrigin.values) {
      stats[origin] = _allTraditions.where((t) => t.origin == origin).length;
    }

    return stats;
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadTraditions();
    await _loadFavorites();
    _applyFilters();
    notifyListeners();
  }

  // Helper methods
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
