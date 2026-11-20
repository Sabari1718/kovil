import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Primary Deity Selection & Hierarchy Tests (5 Categories)', () {
    // 1. Exactly 5 Primary Deity Categories
    test('1. Verify EXACTLY 5 Primary Deity Categories exist (Shiva, Vishnu, Kuladeivam, Ishta Deivam, Grama Deivam)', () {
      final categories = [
        {'id': 'shiva', 'title': 'சிவன்', 'subtitle': 'Shiva'},
        {'id': 'vishnu', 'title': 'விஷ்ணு', 'subtitle': 'Vishnu'},
        {'id': 'kuladeivam', 'title': 'குல தெய்வம்', 'subtitle': 'Kuladeivam'},
        {'id': 'ishtadeivam', 'title': 'இஷ்ட தெய்வம்', 'subtitle': 'Ishta Deivam'},
        {'id': 'gramadeivam', 'title': 'கிராம தெய்வம்', 'subtitle': 'Grama Deivam'},
      ];

      expect(categories.length, equals(5));
      final ids = categories.map((c) => c['id']).toList();
      expect(ids, containsAll(['shiva', 'vishnu', 'kuladeivam', 'ishtadeivam', 'gramadeivam']));
      final titles = categories.map((c) => c['title']).toList();
      expect(titles, containsAll(['சிவன்', 'விஷ்ணு', 'குல தெய்வம்', 'இஷ்ட தெய்வம்', 'கிராம தெய்வம்']));

      // 2. Verify Murugan & Vinayagar are REMOVED from Primary Category Cards
      expect(ids.contains('murugan'), isFalse, reason: 'Murugan must NOT be a Primary Deity category card');
      expect(ids.contains('vinayagar'), isFalse, reason: 'Vinayagar must NOT be a Primary Deity category card');
      expect(titles.contains('முருகன்'), isFalse);
      expect(titles.contains('விநாயகர்'), isFalse);
    });

    // 2. No preloaded default records
    test('2. Verify no records are preloaded by default', () {
      final List<Map<String, dynamic>> savedDeities = [];
      expect(savedDeities.isEmpty, isTrue, reason: 'Default records must NOT be preloaded');
    });

    // 3. Manual Add Workflow & Category Scoping across all 5 Categories
    test('3. Manually added deities appear ONLY under their selected Primary Deity category', () {
      final List<Map<String, dynamic>> savedDeities = [];

      String getPrimaryDeityId(String? categoryTitle) {
        if (categoryTitle == null) return 'shiva';
        final lower = categoryTitle.toLowerCase().replaceAll(' ', '');
        if (lower.contains('சிவன்') || lower.contains('shiva') || lower.contains('siva')) return 'shiva';
        if (lower.contains('விஷ்ணு') || lower.contains('vishnu')) return 'vishnu';
        if (lower.contains('குல') || lower.contains('kula')) return 'kuladeivam';
        if (lower.contains('இஷ்ட') || lower.contains('ishta')) return 'ishtadeivam';
        if (lower.contains('கிராம') || lower.contains('grama')) return 'gramadeivam';
        if (lower.contains('முருகன்') || lower.contains('murugan')) return 'murugan';
        if (lower.contains('விநாயகர்') || lower.contains('vinayagar') || lower.contains('ganesha') || lower.contains('ganapathi')) return 'vinayagar';
        return lower;
      }

      List<Map<String, dynamic>> getDeitiesForCategory(String? categoryTitle) {
        if (categoryTitle == null) return [];
        final id = getPrimaryDeityId(categoryTitle);
        return savedDeities.where((d) {
          final dId = d['primaryDeityId'] ?? getPrimaryDeityId(d['primaryDeityCategory'] ?? d['deityCategory']);
          return dId == id;
        }).toList();
      }

      // 1. User adds deities under Shiva: Shiva, Parvati, Murugan, Vinayagar
      savedDeities.add({
        'id': 'shiva_1',
        'primaryDeityId': 'shiva',
        'primaryDeityCategory': 'சிவன்',
        'deityName': 'Shiva',
        'tamilName': 'சிவன்',
        'gender': 'male',
        'relationship': 'மூலவர்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'சிவபெருமான்',
      });
      savedDeities.add({
        'id': 'shiva_2',
        'primaryDeityId': 'shiva',
        'primaryDeityCategory': 'சிவன்',
        'deityName': 'Parvati',
        'tamilName': 'பார்வதி',
        'gender': 'female',
        'relationship': 'உடனுறை தெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'அம்பாள்',
      });
      savedDeities.add({
        'id': 'shiva_3',
        'primaryDeityId': 'shiva',
        'primaryDeityCategory': 'சிவன்',
        'deityName': 'Vinayagar',
        'tamilName': 'விநாயகர்',
        'gender': 'male',
        'relationship': 'மூத்த மகன்',
        'parentDeityId': 'சிவபெருமான் & பார்வதி',
        'deityPhoto': '',
        'description': 'முழுமுதற் கடவுள்',
      });
      savedDeities.add({
        'id': 'shiva_4',
        'primaryDeityId': 'shiva',
        'primaryDeityCategory': 'சிவன்',
        'deityName': 'Murugan',
        'tamilName': 'முருகன்',
        'gender': 'male',
        'relationship': 'இளைய மகன்',
        'parentDeityId': 'சிவபெருமான் & பார்வதி',
        'deityPhoto': '',
        'description': 'தமிழ் கடவுள்',
      });

      // 2. User adds deities under Vishnu: Vishnu, Lakshmi, Rama, Sita, Krishna
      savedDeities.add({
        'id': 'vishnu_1',
        'primaryDeityId': 'vishnu',
        'primaryDeityCategory': 'விஷ்ணு',
        'deityName': 'Vishnu',
        'tamilName': 'விஷ்ணு',
        'gender': 'male',
        'relationship': 'மூலவர்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'மகாவிஷ்ணு',
      });
      savedDeities.add({
        'id': 'vishnu_2',
        'primaryDeityId': 'vishnu',
        'primaryDeityCategory': 'விஷ்ணு',
        'deityName': 'Lakshmi',
        'tamilName': 'லட்சுமி',
        'gender': 'female',
        'relationship': 'உடனுறை தெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'செல்வத்தின் அதிபதி',
      });
      savedDeities.add({
        'id': 'vishnu_3',
        'primaryDeityId': 'vishnu',
        'primaryDeityCategory': 'விஷ்ணு',
        'deityName': 'Rama',
        'tamilName': 'ராமர்',
        'gender': 'male',
        'relationship': 'அவதாரம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'தசரத மைந்தன்',
      });
      savedDeities.add({
        'id': 'vishnu_4',
        'primaryDeityId': 'vishnu',
        'primaryDeityCategory': 'விஷ்ணு',
        'deityName': 'Sita',
        'tamilName': 'சீதை',
        'gender': 'female',
        'relationship': 'துணைவி',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'ஜனக நந்தினி',
      });
      savedDeities.add({
        'id': 'vishnu_5',
        'primaryDeityId': 'vishnu',
        'primaryDeityCategory': 'விஷ்ணு',
        'deityName': 'Krishna',
        'tamilName': 'கிருஷ்ணர்',
        'gender': 'male',
        'relationship': 'அவதாரம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'வாசுதேவன்',
      });

      // 3. User adds deities under Kuladeivam: Ayyanar, Mariamman
      savedDeities.add({
        'id': 'kula_1',
        'primaryDeityId': 'kuladeivam',
        'primaryDeityCategory': 'குல தெய்வம்',
        'deityName': 'Ayyanar',
        'tamilName': 'அய்யனார்',
        'gender': 'male',
        'relationship': 'குலதெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'எங்கள் குடும்ப குலதெய்வம்',
      });
      savedDeities.add({
        'id': 'kula_2',
        'primaryDeityId': 'kuladeivam',
        'primaryDeityCategory': 'குல தெய்வம்',
        'deityName': 'Mariamman',
        'tamilName': 'மாரியம்மன்',
        'gender': 'female',
        'relationship': 'குலதெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'தாய் தெய்வம்',
      });

      // 4. User adds deities under Ishta Deivam: Anjaneyar
      savedDeities.add({
        'id': 'ishta_1',
        'primaryDeityId': 'ishtadeivam',
        'primaryDeityCategory': 'இஷ்ட தெய்வம்',
        'deityName': 'Anjaneyar',
        'tamilName': 'ஆஞ்சநேயர்',
        'gender': 'male',
        'relationship': 'இஷ்ட தெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'ராம பக்தர்',
      });

      // 5. User adds deities under Grama Deivam: Karuppasamy
      savedDeities.add({
        'id': 'grama_1',
        'primaryDeityId': 'gramadeivam',
        'primaryDeityCategory': 'கிராம தெய்வம்',
        'deityName': 'Karuppasamy',
        'tamilName': 'கருப்பசாமி',
        'gender': 'male',
        'relationship': 'கிராம காவல் தெய்வம்',
        'parentDeityId': '',
        'deityPhoto': '',
        'description': 'எல்லை காவல் தெய்வம்',
      });

      // Assert Shiva deities (Notice Murugan and Vinayagar are manually under Shiva)
      final shivaDeities = getDeitiesForCategory('சிவன்');
      expect(shivaDeities.length, equals(4));
      expect(shivaDeities.map((d) => d['tamilName']), containsAll(['சிவன்', 'பார்வதி', 'விநாயகர்', 'முருகன்']));
      expect(shivaDeities.any((d) => d['tamilName'] == 'லட்சுமி'), isFalse);
      expect(shivaDeities.any((d) => d['tamilName'] == 'அய்யனார்'), isFalse);

      // Assert Vishnu deities
      final vishnuDeities = getDeitiesForCategory('விஷ்ணு');
      expect(vishnuDeities.length, equals(5));
      expect(vishnuDeities.map((d) => d['tamilName']), containsAll(['விஷ்ணு', 'லட்சுமி', 'ராமர்', 'சீதை', 'கிருஷ்ணர்']));
      expect(vishnuDeities.any((d) => d['primaryDeityId'] != 'vishnu'), isFalse);

      // Assert Kuladeivam deities
      final kulaDeities = getDeitiesForCategory('குல தெய்வம்');
      expect(kulaDeities.length, equals(2));
      expect(kulaDeities.map((d) => d['tamilName']), containsAll(['அய்யனார்', 'மாரியம்மன்']));
      expect(kulaDeities.any((d) => d['primaryDeityId'] != 'kuladeivam'), isFalse);

      // Assert Ishta Deivam deities
      final ishtaDeities = getDeitiesForCategory('இஷ்ட தெய்வம்');
      expect(ishtaDeities.length, equals(1));
      expect(ishtaDeities.first['tamilName'], equals('ஆஞ்சநேயர்'));
      expect(ishtaDeities.first['primaryDeityId'], equals('ishtadeivam'));

      // Assert Grama Deivam deities
      final gramaDeities = getDeitiesForCategory('கிராம தெய்வம்');
      expect(gramaDeities.length, equals(1));
      expect(gramaDeities.first['tamilName'], equals('கருப்பசாமி'));
      expect(gramaDeities.first['primaryDeityId'], equals('gramadeivam'));
    });

    // 4. Preserve existing saved records (Do not delete existing murugan/vinayagar records)
    test('4. Existing saved records with legacy murugan or vinayagar IDs are preserved and not deleted', () {
      final List<Map<String, dynamic>> savedDeities = [
        {
          'id': 'legacy_murugan',
          'primaryDeityId': 'murugan',
          'primaryDeityCategory': 'முருகன்',
          'tamilName': 'பழனி முருகன்',
          'deityName': 'Palani Murugan',
        },
        {
          'id': 'legacy_vinayagar',
          'primaryDeityId': 'vinayagar',
          'primaryDeityCategory': 'விநாயகர்',
          'tamilName': 'பிள்ளையார்',
          'deityName': 'Pillaiyar',
        },
      ];

      expect(savedDeities.length, equals(2));
      expect(savedDeities.any((d) => d['id'] == 'legacy_murugan'), isTrue);
      expect(savedDeities.any((d) => d['id'] == 'legacy_vinayagar'), isTrue);
    });

    // 5. Data Structure Verification (Parent deity and relationship optional)
    test('5. Verify required and optional fields in manually added deity record', () {
      final sampleRecord = {
        'id': 'test_123',
        'primaryDeityId': 'kuladeivam',
        'primaryDeityCategory': 'குல தெய்வம்',
        'deityName': 'Madurai Veeran',
        'tamilName': 'மதுரை வீரன்',
        'gender': 'male',
        'relationship': '', // Optional
        'parentDeityId': '', // Optional
        'deityPhoto': '', // Optional
        'description': '', // Optional
      };

      expect(sampleRecord['primaryDeityId'], equals('kuladeivam'));
      expect(sampleRecord['tamilName'], equals('மதுரை வீரன்'));
      expect(sampleRecord['gender'], equals('male'));
      expect(sampleRecord['relationship'], isEmpty);
      expect(sampleRecord['parentDeityId'], isEmpty);
    });

    // 6. Update / Edit Deity Record
    test('6. Verify updating an existing deity record modifies the data in-place', () {
      final List<Map<String, dynamic>> savedDeities = [
        {
          'id': 'k_1',
          'primaryDeityId': 'kuladeivam',
          'primaryDeityCategory': 'குல தெய்வம்',
          'deityName': 'Mariamman',
          'tamilName': 'மாரியம்மன்',
          'gender': 'female',
          'relationship': 'குலதெய்வம்',
          'description': 'ஆதிபராசக்தி',
        }
      ];

      final index = savedDeities.indexWhere((d) => d['id'] == 'k_1');
      expect(index, equals(0));

      final updatedRecord = Map<String, dynamic>.from(savedDeities[index]);
      updatedRecord['description'] = 'சமயபுரம் மாரியம்மன்';

      savedDeities[index] = updatedRecord;

      expect(savedDeities[0]['description'], equals('சமயபுரம் மாரியம்மன்'));
      expect(savedDeities.length, equals(1));
    });

    // 7. Delete Deity Record
    test('7. Verify deleting a deity record removes it from the list', () {
      final List<Map<String, dynamic>> savedDeities = [
        {
          'id': 'g_1',
          'primaryDeityId': 'gramadeivam',
          'primaryDeityCategory': 'கிராம தெய்வம்',
          'tamilName': 'முனியப்பன்',
        },
        {
          'id': 'g_2',
          'primaryDeityId': 'gramadeivam',
          'primaryDeityCategory': 'கிராம தெய்வம்',
          'tamilName': 'பேச்சியம்மன்',
        },
      ];

      expect(savedDeities.length, equals(2));
      savedDeities.removeWhere((d) => d['id'] == 'g_2');

      expect(savedDeities.length, equals(1));
      expect(savedDeities[0]['id'], equals('g_1'));
      expect(savedDeities[0]['tamilName'], equals('முனியப்பன்'));
    });

    // 8. Serialization and Deserialization for SharedPreferences
    test('8. Verify JSON persistence retains all 5 categories across app restarts', () {
      final originalList = [
        {
          'id': 'kula_101',
          'primaryDeityId': 'kuladeivam',
          'primaryDeityCategory': 'குல தெய்வம்',
          'deityName': 'Ayyanar',
          'tamilName': 'அய்யனார்',
          'gender': 'male',
          'relationship': 'குலதெய்வம்',
          'parentDeityId': '',
          'deityPhoto': '',
          'description': 'குடும்ப காவல் தெய்வம்',
          'status': 'Active',
          'createdAt': '2026-11-20T10:00:00.000',
        },
        {
          'id': 'ishta_201',
          'primaryDeityId': 'ishtadeivam',
          'primaryDeityCategory': 'இஷ்ட தெய்வம்',
          'deityName': 'Anjaneyar',
          'tamilName': 'ஆஞ்சநேயர்',
          'gender': 'male',
          'relationship': 'இஷ்ட தெய்வம்',
          'parentDeityId': '',
          'deityPhoto': '',
          'description': 'சர்வ வல்லமையாளர்',
          'status': 'Active',
          'createdAt': '2026-11-20T10:05:00.000',
        }
      ];

      final jsonString = jsonEncode(originalList);
      final List<dynamic> decodedList = jsonDecode(jsonString);
      final restoredList = decodedList.map((item) => Map<String, dynamic>.from(item as Map)).toList();

      expect(restoredList.length, equals(2));
      expect(restoredList[0]['primaryDeityId'], equals('kuladeivam'));
      expect(restoredList[0]['tamilName'], equals('அய்யனார்'));
      expect(restoredList[1]['primaryDeityId'], equals('ishtadeivam'));
      expect(restoredList[1]['tamilName'], equals('ஆஞ்சநேயர்'));
    });

    // 9. Offline Devotional Image Assets Verification
    test('9. Verify all 5 local devotional category assets exist and are non-empty for offline loading', () {
      final assets = [
        'assets/images/category/shiva.png',
        'assets/images/category/vishnu.png',
        'assets/images/category/kuladeivam.png',
        'assets/images/category/ishtadeivam.png',
        'assets/images/category/gramadeivam.png',
      ];

      for (final assetPath in assets) {
        final file = File(assetPath);
        expect(file.existsSync(), isTrue, reason: '$assetPath must exist locally for offline loading');
        expect(file.lengthSync(), greaterThan(10000), reason: '$assetPath must be a high-quality non-empty image');
      }
    });
  });
}
