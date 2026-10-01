import '../../catalog/domain/models/catalog_models.dart';
import '../domain/models/profile_models.dart';

/// Mock profile store keyed by user id. Seeds each user with demo KYC data
/// (PAN + Bank approved, GST pending) until a backend exists.
class InMemoryProfileRepository {
  final Map<String, ProfileDetails> _store = {};

  static const _demoAddress = 'A-123, Sector 62, Noida, Uttar Pradesh - 201309';

  Future<ProfileDetails> fetch(AppUserProfile user) async {
    return _store.putIfAbsent(user.id, () => _seed(user));
  }

  Future<ProfileDetails> save(String userId, ProfileDetails details) async {
    _store[userId] = details;
    return details;
  }

  static ProfileDetails _seed(AppUserProfile user) {
    final uploaded = DateTime(2026, 3, 10);
    return ProfileDetails(
      personal: PersonalInfo(
        fullName: user.name,
        mobileNumber: user.phone ?? '',
        email: user.email ?? '',
        address: _demoAddress,
      ),
      pan: PanDetails(
        panNumber: 'ABCDE1234F',
        nameOnDocument: user.name,
        document: ProfileDocument(fileName: 'PAN_Card.pdf', uploadedOn: uploaded),
        status: VerificationStatus.approved,
      ),
      gst: GstDetails(
        gstNumber: '09ABCDE1234F1Z5',
        nameOnDocument: user.name,
        document: ProfileDocument(
          fileName: 'GST_Certificate.pdf',
          uploadedOn: uploaded,
        ),
        status: VerificationStatus.pending,
      ),
      bank: BankDetails(
        accountNumber: 'XXXXXXXX1234',
        ifscCode: 'HDFC0001234',
        nameOnAccount: user.name,
        document: ProfileDocument(
          fileName: 'Cancelled_Cheque.pdf',
          uploadedOn: uploaded,
        ),
        status: VerificationStatus.approved,
      ),
    );
  }
}
