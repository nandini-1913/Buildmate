import '../domain/models/reward_models.dart';
import 'reward_repository.dart';

/// In-memory ledger for the demo. Ledger is the source of truth.
class InMemoryRewardRepository implements RewardRepository {
  InMemoryRewardRepository();

  /// Seeded with display-only mock history for the demo user, used only by
  /// the real app shell — kept out of the default constructor so tests that
  /// exercise the ledger from a clean slate aren't affected.
  InMemoryRewardRepository.withDemoSeed() {
    _entries.addAll(_mockSeedEntries);
  }

  static final List<RewardLedgerEntry> _mockSeedEntries = [
    RewardLedgerEntry(
      id: 'seed-ledger-3',
      requesterId: 'user-demo-1',
      quotationId: 'seed-qt-1042',
      quotationDisplayId: 'QT-1042',
      quotationGrandTotal: 36000,
      points: 300,
      type: RewardLedgerType.earned,
      createdAt: DateTime(2026, 9, 10),
      description: 'Sale confirmed',
    ),
    RewardLedgerEntry(
      id: 'seed-ledger-2',
      requesterId: 'user-demo-1',
      quotationId: 'seed-perk-free-delivery',
      quotationDisplayId: 'RWD-2208',
      points: 230,
      type: RewardLedgerType.redeemed,
      createdAt: DateTime(2026, 8, 22),
      description: 'Redeemed: Free delivery',
    ),
    RewardLedgerEntry(
      id: 'seed-ledger-1',
      requesterId: 'user-demo-1',
      quotationId: 'seed-qt-1035',
      quotationDisplayId: 'QT-1035',
      quotationGrandTotal: 27500,
      points: 250,
      type: RewardLedgerType.earned,
      createdAt: DateTime(2026, 8, 20),
      description: 'Sale confirmed',
    ),
  ];

  final List<RewardLedgerEntry> _entries = [];

  List<RewardLedgerEntry> get allEntries => List.unmodifiable(_entries);

  @override
  Future<void> addLedgerEntry(RewardLedgerEntry entry) async {
    // Hard guard: never allow a second earned entry for the same quotation.
    if (await hasEntryForQuotation(entry.quotationId)) {
      throw RewardException(
        'This quotation has already been marked as sold.',
      );
    }
    _entries.insert(0, entry);
  }

  @override
  Future<List<RewardLedgerEntry>> getLedgerEntriesForUser(
    String requesterId,
  ) async {
    final list =
        _entries.where((e) => e.requesterId == requesterId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<int> getBalanceForUser(String requesterId) async {
    var earned = 0;
    var redeemed = 0;
    for (final e in _entries) {
      if (e.requesterId != requesterId) continue;
      if (e.type == RewardLedgerType.earned) {
        earned += e.points;
      } else if (e.type == RewardLedgerType.redeemed) {
        redeemed += e.points;
      }
    }
    return earned - redeemed;
  }

  @override
  Future<bool> hasEntryForQuotation(String quotationId) async {
    return _entries.any((e) => e.quotationId == quotationId);
  }

  @override
  Future<RewardLedgerEntry?> entryForQuotation(String quotationId) async {
    for (final e in _entries) {
      if (e.quotationId == quotationId) return e;
    }
    return null;
  }

  void clear() => _entries.clear();
}
