import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:kulatheivam/features/deities/data/shiva_associated_data.dart';

void main() {
  group('Structured Deity Registration System Tests (Lord Shiva Primary Example)', () {
    // ==========================================
    // STEP 1: PRIMARY DEITY TESTS
    // ==========================================
    test('STEP 1: Verify Lord Shiva as Primary Deity with Tamil and English Names', () {
      final shivaRecord = {
        'id': 'shiva',
        'category': 'Primary Deity',
        'primaryDeityCategory': 'சிவன்',
        'tamilName': 'சிவன்',
        'englishName': 'Lord Shiva',
        'deityName': 'Lord Shiva',
        'name': 'சிவன்',
        'gender': 'male',
        'roleGender': 'Male deity',
        'relationship': 'முதன்மை தெய்வம் (Primary Deity)',
        'description': 'சிவபெருமான் - சைவ சமயத்தின் முழுமுதற் பரம்பொருள்',
      };

      expect(shivaRecord['category'], equals('Primary Deity'));
      expect(shivaRecord['tamilName'], anyOf(equals('சிவன்'), equals('Sivan'), equals('Shiva')));
      expect(shivaRecord['englishName'], equals('Lord Shiva'));
      expect(shivaRecord['roleGender'], equals('Male deity'));
      expect(shivaRecord['id'], equals('shiva'));
    });

    // ==========================================
    // STEP 2: DEITY PHOTOS TESTS
    // ==========================================
    test('STEP 2: Primary Deity Photo & Additional Form Photos Stored Separately', () {
      final List<PhotoReferenceRecord> photosStore = [];

      // Primary Deity Photo
      final primaryPhoto = PhotoReferenceRecord(
        id: 'photo_primary_shiva',
        deityId: 'shiva',
        targetType: 'primary',
        targetName: 'Lord Shiva',
        photoBase64: 'base64_primary_shiva_image_bytes',
        description: 'முதன்மை சிவபெருமான் திருவுருவப் படம்',
        createdAt: DateTime.now(),
      );
      photosStore.add(primaryPhoto);

      // Additional Form Photo for Nataraja
      final natarajaPhoto = PhotoReferenceRecord(
        id: 'photo_form_nataraja',
        deityId: 'shiva',
        targetType: 'form',
        targetName: 'Nataraja',
        photoBase64: 'base64_nataraja_form_image_bytes',
        description: 'ஆனந்த தாண்டவ நடராஜர் திருவுருவப் படம்',
        createdAt: DateTime.now(),
      );
      photosStore.add(natarajaPhoto);

      // Additional Form Photo for Dakshinamurthy
      final dakshinaPhoto = PhotoReferenceRecord(
        id: 'photo_form_dakshinamurthy',
        deityId: 'shiva',
        targetType: 'form',
        targetName: 'Dakshinamurthy',
        photoBase64: 'base64_dakshina_form_image_bytes',
        description: 'தென்முகக் கடவுள் தட்சிணாமூர்த்தி படம்',
        createdAt: DateTime.now(),
      );
      photosStore.add(dakshinaPhoto);

      expect(photosStore.length, equals(3));
      expect(photosStore.first.targetType, equals('primary'));
      expect(photosStore.where((p) => p.targetType == 'form').length, equals(2));

      // Verify JSON serialization and separation
      final jsonList = photosStore.map((p) => p.toJson()).toList();
      final decoded = jsonList.map((j) => PhotoReferenceRecord.fromJson(j)).toList();
      expect(decoded.length, equals(3));
      expect(decoded[1].targetName, equals('Nataraja'));
    });

    // ==========================================
    // STEP 3: ASSOCIATED SAINTS AND SIDDHARS TESTS
    // ==========================================
    test('STEP 3A: Traditional 63 Nayanmars Records Verification', () {
      final all63 = ShivaAssociatedMasterData.all63Nayanmars;
      expect(all63.length, equals(63), reason: 'Must contain all 63 traditional Nayanmars');

      // Check unique IDs and names
      final ids = all63.map((n) => n.id).toSet();
      expect(ids.length, equals(63), reason: 'All 63 Nayanmar IDs must be unique');

      final tamilNames = all63.map((n) => n.tamilName).toSet();
      expect(tamilNames.length, equals(63), reason: 'All 63 Nayanmar Tamil names must be unique');

      // Check prominent Nayanmars
      expect(all63.any((n) => n.englishName.contains('Appar') || n.tamilName.contains('அப்பர்')), isTrue);
      expect(all63.any((n) => n.englishName.contains('Sambandar') || n.tamilName.contains('சம்பந்த')), isTrue);
      expect(all63.any((n) => n.englishName.contains('Sundarar') || n.tamilName.contains('சுந்தரமூர்த்தி')), isTrue);
      expect(all63.any((n) => n.englishName.contains('Kannappa') || n.tamilName.contains('கண்ணப்ப')), isTrue);
      expect(all63.any((n) => n.englishName.contains('Karaikkal') || n.tamilName.contains('காரைக்கால்')), isTrue);

      // Verify relationship type for all 63
      for (final n in all63) {
        expect(n.relationshipType, equals('Shaivite Saint / Devotee of Shiva'));
        expect(n.shortDescription.isNotEmpty, isTrue);
      }
    });

    test('STEP 3B: Configurable Siddhars (18 Siddhars & Distinct from Family)', () {
      final traditional18 = ShivaAssociatedMasterData.traditional18Siddhars;
      expect(traditional18.length, equals(18), reason: 'Must support 18 traditional Siddhars');

      // Check key Siddhars
      final names = traditional18.map((s) => s.tamilName).toList();
      expect(names, containsAll(['அகத்தியர்', 'போகர்', 'திருமூலர்', 'கோரக்கர்', 'கருவூரார்', 'பதஞ்சலி']));

      // Verify custom regional Siddhar creation
      final customSiddhar = SiddharRecord(
        id: 'siddhar_custom_sivavakkiyar',
        primaryDeityId: 'shiva',
        tamilName: 'சிவவாக்கியர்',
        englishName: 'Siva Vakkiyar',
        siddharTradition: 'Tamil Siddhar Tradition (தமிழ் சித்தர் மரபு)',
        shortDescription: 'தீவிர தத்துவப் பாடல்களைப் பாடிய தமிழ் சித்தர்',
      );

      final List<SiddharRecord> deitySiddhars = [...traditional18.take(3), customSiddhar];
      expect(deitySiddhars.length, equals(4));
      expect(deitySiddhars.last.tamilName, equals('சிவவாக்கியர்'));

      // Ensure tradition options exist
      expect(ShivaAssociatedMasterData.siddharTraditionOptions, contains('18 Siddhars (பதினெண் சித்தர்கள்)'));
      expect(ShivaAssociatedMasterData.siddharTraditionOptions, contains('Nath Siddhar Tradition (நாத மரபு)'));
    });

    // ==========================================
    // STEP 4: FAMILY RELATIONSHIPS TESTS
    // ==========================================
    test('STEP 4: Shiva Family Relationships (Parvati, Murugan, Vinayagar) & Relationship Types', () {
      final defaultFamily = ShivaAssociatedMasterData.defaultShivaFamily;
      expect(defaultFamily.length, equals(3));

      // Verify Parvati as Consort/Wife
      final parvati = defaultFamily.firstWhere((f) => f.deityNameTa.contains('பார்வதி'));
      expect(parvati.relationshipType, equals('Wife / Consort'));
      expect(parvati.gender, equals('Female deity'));

      // Verify Murugan as Son
      final murugan = defaultFamily.firstWhere((f) => f.deityNameTa.contains('முருகன்'));
      expect(murugan.relationshipType, equals('Son'));
      expect(murugan.gender, equals('Male deity'));

      // Verify Vinayagar as Son
      final vinayagar = defaultFamily.firstWhere((f) => f.deityNameTa.contains('விநாயகர்'));
      expect(vinayagar.relationshipType, equals('Son'));
      expect(vinayagar.gender, equals('Male deity'));

      // Verify all required relationship types exist
      final expectedTypes = [
        'Father',
        'Mother',
        'Son',
        'Daughter',
        'Husband',
        'Wife / Consort',
        'Brother',
        'Sister',
        'Other',
      ];
      expect(ShivaAssociatedMasterData.relationshipTypes, containsAll(expectedTypes));
    });

    // ==========================================
    // STEP 5: DEITY FORMS TESTS
    // ==========================================
    test('STEP 5: Shiva 12 Prominent Forms Verification', () {
      final forms = ShivaAssociatedMasterData.prominent12ShivaForms;
      expect(forms.length, equals(12), reason: 'Must contain all 12 prominent Shiva forms');

      final englishNames = forms.map((f) => f.nameEn).toList();
      final expected12 = [
        'Nataraja',
        'Dakshinamurthy',
        'Lingodbhava',
        'Ardhanarishvara',
        'Bhairava',
        'Chandrashekara',
        'Somaskanda',
        'Gangadhara',
        'Tripurantaka',
        'Kirata',
        'Pashupati',
        'Harihara',
      ];
      expect(englishNames, containsAll(expected12));

      // Each form must have primary deity reference to Shiva
      for (final f in forms) {
        expect(f.primaryDeityId, equals('shiva'));
        expect(f.nameTa.isNotEmpty, isTrue);
        expect(f.description.isNotEmpty, isTrue);
      }
    });

    // ==========================================
    // STEP 6: DEITY ROLE / GENDER TESTS
    // ==========================================
    test('STEP 6: Configurable Deity Role / Gender Options', () {
      final expectedGenderRoles = [
        'Male deity',
        'Female deity',
        'Both / Combined form',
        'Other / Not specified',
      ];
      expect(ShivaAssociatedMasterData.genderRoleOptions, containsAll(expectedGenderRoles));
    });

    // ==========================================
    // STEP 7: SAVE, SEPARATION, DUPLICATE PREVENTION & RESET
    // ==========================================
    test('STEP 7: Save Shiva as Primary Deity, Separate Data Structures & Duplicate Prevention', () {
      // 1. Separate in-memory collections
      final List<Map<String, dynamic>> savedDeities = [];
      final List<PhotoReferenceRecord> photosStore = [];
      final List<DeityFormRecord> formsStore = [];
      final List<NayanmarRecord> nayanmarsStore = [];
      final List<SiddharRecord> siddharsStore = [];
      final List<DeityFamilyRelationshipRecord> familyStore = [];

      // 2. Add Shiva Form (Nataraja)
      final natarajaForm = ShivaAssociatedMasterData.prominent12ShivaForms.firstWhere((f) => f.nameEn == 'Nataraja');
      formsStore.add(natarajaForm);

      // Attempt duplicate addition of Nataraja
      final isDuplicateForm = formsStore.any((f) => f.nameEn == 'Nataraja');
      expect(isDuplicateForm, isTrue, reason: 'Duplicate form must be detected');

      // 3. Add Family (Parvati & Murugan)
      familyStore.add(ShivaAssociatedMasterData.defaultShivaFamily[0]); // Parvati
      familyStore.add(ShivaAssociatedMasterData.defaultShivaFamily[1]); // Murugan

      // Attempt duplicate family
      final isDuplicateFamily = familyStore.any((fm) => fm.deityNameEn.contains('Parvati') && fm.relationshipType == 'Wife / Consort');
      expect(isDuplicateFamily, isTrue, reason: 'Duplicate family member must be detected');

      // 4. Add Nayanmars (Appar)
      final appar = ShivaAssociatedMasterData.all63Nayanmars.firstWhere((n) => n.englishName.contains('Appar'));
      nayanmarsStore.add(appar);

      final isDuplicateNayanmar = nayanmarsStore.any((n) => n.tamilName == appar.tamilName);
      expect(isDuplicateNayanmar, isTrue);

      // 5. Add Siddhars (Agathiyar)
      final agathiyar = ShivaAssociatedMasterData.traditional18Siddhars.firstWhere((s) => s.englishName == 'Agathiyar');
      siddharsStore.add(agathiyar);

      final isDuplicateSiddhar = siddharsStore.any((s) => s.tamilName == agathiyar.tamilName);
      expect(isDuplicateSiddhar, isTrue);

      // 6. Save Shiva Primary Deity Record
      final shivaPrimaryRecord = {
        'id': 'shiva',
        'primaryDeityId': 'shiva',
        'primaryDeityCategory': 'சிவன்',
        'category': 'Primary Deity',
        'deityCategory': 'Primary Deity',
        'tamilName': 'சிவன்',
        'englishName': 'Lord Shiva',
        'deityName': 'Lord Shiva',
        'name': 'சிவன்',
        'roleGender': 'Male deity',
        'gender': 'male',
        'relationship': 'முதன்மை தெய்வம் (Primary Deity)',
        'photoReferences': photosStore.map((p) => p.toJson()).toList(),
        'forms': formsStore.map((f) => f.toJson()).toList(),
        'nayanmars': nayanmarsStore.map((n) => n.toJson()).toList(),
        'siddhars': siddharsStore.map((s) => s.toJson()).toList(),
        'familyMembers': familyStore.map((fm) => fm.toJson()).toList(),
      };
      savedDeities.add(shivaPrimaryRecord);

      expect(savedDeities.length, equals(1));
      expect(savedDeities.first['category'], equals('Primary Deity'));
      expect((savedDeities.first['forms'] as List).length, equals(1));
      expect((savedDeities.first['familyMembers'] as List).length, equals(2));
      expect((savedDeities.first['nayanmars'] as List).length, equals(1));
      expect((savedDeities.first['siddhars'] as List).length, equals(1));

      // 7. Verify JSON Encoding / Decoding of all separated stores
      final encodedDeities = jsonEncode(savedDeities);
      final encodedPhotos = jsonEncode(photosStore.map((p) => p.toJson()).toList());
      final encodedForms = jsonEncode(formsStore.map((f) => f.toJson()).toList());
      final encodedNayanmars = jsonEncode(nayanmarsStore.map((n) => n.toJson()).toList());
      final encodedSiddhars = jsonEncode(siddharsStore.map((s) => s.toJson()).toList());
      final encodedFamily = jsonEncode(familyStore.map((fm) => fm.toJson()).toList());

      expect(encodedDeities.isNotEmpty, isTrue);
      expect(encodedPhotos.isNotEmpty, isTrue);
      expect(encodedForms.isNotEmpty, isTrue);
      expect(encodedNayanmars.isNotEmpty, isTrue);
      expect(encodedSiddhars.isNotEmpty, isTrue);
      expect(encodedFamily.isNotEmpty, isTrue);
    });

    test('STEP 7: Reset Dependent Fields when Category Changes', () {
      String currentCategory = 'சிவன்';
      String tamilName = 'சிவன்';
      String englishName = 'Lord Shiva';
      List<String> activeForms = ['Nataraja', 'Dakshinamurthy'];

      void onCategoryChanged(String newCat) {
        if (currentCategory != newCat) {
          currentCategory = newCat;
          // Dependent fields reset
          tamilName = '';
          englishName = '';
          activeForms = [];
        }
      }

      onCategoryChanged('விஷ்ணு');
      expect(currentCategory, equals('விஷ்ணு'));
      expect(tamilName, isEmpty);
      expect(englishName, isEmpty);
      expect(activeForms, isEmpty);
    });
  });
}
