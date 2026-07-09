class SectorModel {
  final int id;
  final String sectorName;
  final int? sectorTitleId;
  final String? sectorTitleName;
  final String? imageUrl;

  SectorModel({
    required this.id,
    required this.sectorName,
    this.sectorTitleId,
    this.sectorTitleName,
    this.imageUrl,
  });

  factory SectorModel.fromJson(Map<String, dynamic> json) {
    return SectorModel(
      id: json['id'] ?? 0,
      sectorName: json['sector_name'] ?? json['name'] ?? '',
      sectorTitleId: json['sector_title_id'],
      sectorTitleName: json['sector_title_name'],
      imageUrl: json['image_url'] ?? json['image'] ?? json['image_path'],
    );
  }
}

class SubSectorModel {
  final int id;
  final String subSectorName;
  final int? sectorId;
  final String? sectorName;
  final String? sectorTitleName;

  SubSectorModel({
    required this.id,
    required this.subSectorName,
    this.sectorId,
    this.sectorName,
    this.sectorTitleName,
  });

  factory SubSectorModel.fromJson(Map<String, dynamic> json) {
    return SubSectorModel(
      id: json['id'] ?? 0,
      subSectorName: json['sub_sector_name'] ?? json['name'] ?? '',
      sectorId: json['sector_id'],
      sectorName: json['sector_name'],
      sectorTitleName: json['sector_title_name'],
    );
  }
}

class CategoryModel {
  final int id;
  final String categoryName;
  final int? subSectorId;
  final String? categoryType;
  final int? parentCategoryId;

  CategoryModel({
    required this.id,
    required this.categoryName,
    this.subSectorId,
    this.categoryType,
    this.parentCategoryId,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      categoryName: json['category_name'] ?? json['name'] ?? '',
      subSectorId: json['sub_sector_id'],
      categoryType: json['category_type'],
      parentCategoryId: json['parent_category_id'],
    );
  }
}

class SubCategoryModel {
  final int id;
  final String subCategoryName;
  final int? categoryId;

  SubCategoryModel({
    required this.id,
    required this.subCategoryName,
    this.categoryId,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] ?? 0,
      subCategoryName: json['sub_category_name'] ?? json['name'] ?? '',
      categoryId: json['category_id'],
    );
  }
}

class CommunityModel {
  final int id;
  final String nameTamil;
  final String nameEnglish;

  CommunityModel({
    required this.id,
    required this.nameTamil,
    required this.nameEnglish,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] ?? 0,
      nameTamil: json['community_name_tamil'] ?? '',
      nameEnglish: json['community_name_english'] ?? '',
    );
  }
}

class SubCommunityModel {
  final int id;
  final int? communityId;
  final String nameTamil;
  final String nameEnglish;

  SubCommunityModel({
    required this.id,
    this.communityId,
    required this.nameTamil,
    required this.nameEnglish,
  });

  factory SubCommunityModel.fromJson(Map<String, dynamic> json) {
    return SubCommunityModel(
      id: json['id'] ?? 0,
      communityId: json['community_id'],
      nameTamil: json['sub_community_name_tamil'] ?? '',
      nameEnglish: json['sub_community_name_english'] ?? '',
    );
  }
}

class KulamModel {
  final int id;
  final int? communityId;
  final int? subCommunityId;
  final String nameTamil;
  final String nameEnglish;

  KulamModel({
    required this.id,
    this.communityId,
    this.subCommunityId,
    required this.nameTamil,
    required this.nameEnglish,
  });

  factory KulamModel.fromJson(Map<String, dynamic> json) {
    return KulamModel(
      id: json['id'] ?? 0,
      communityId: json['community_id'],
      subCommunityId: json['sub_community_id'],
      nameTamil: json['kula_name_tamil'] ?? '',
      nameEnglish: json['kula_name_english'] ?? '',
    );
  }
}

class KulaDeivamModel {
  final int id;
  final int? communityId;
  final int? subCommunityId;
  final int? kulaId;
  final String deityNameTamil;
  final String deityNameEnglish;
  final String? title;
  final String? imagePath;

  KulaDeivamModel({
    required this.id,
    this.communityId,
    this.subCommunityId,
    this.kulaId,
    required this.deityNameTamil,
    required this.deityNameEnglish,
    this.title,
    this.imagePath,
  });

  factory KulaDeivamModel.fromJson(Map<String, dynamic> json) {
    return KulaDeivamModel(
      id: json['id'] ?? 0,
      communityId: json['community_id'],
      subCommunityId: json['sub_community_id'],
      kulaId: json['kula_id'],
      deityNameTamil: json['deity_name_tamil'] ?? '',
      deityNameEnglish: json['deity_name_english'] ?? '',
      title: json['title'],
      imagePath: json['image_path'],
    );
  }
}

class VagaiyaraModel {
  final int id;
  final int? communityId;
  final int? subCommunityId;
  final int? kulaId;
  final int? kulaDeivamId;
  final String vagaiyaraNameTamil;
  final String vagaiyaraNameEnglish;

  VagaiyaraModel({
    required this.id,
    this.communityId,
    this.subCommunityId,
    this.kulaId,
    this.kulaDeivamId,
    required this.vagaiyaraNameTamil,
    required this.vagaiyaraNameEnglish,
  });

  factory VagaiyaraModel.fromJson(Map<String, dynamic> json) {
    return VagaiyaraModel(
      id: json['id'] ?? 0,
      communityId: json['community_id'],
      subCommunityId: json['sub_community_id'],
      kulaId: json['kula_id'],
      kulaDeivamId: json['kula_deivam_id'],
      vagaiyaraNameTamil: json['vagaiyara_name_tamil'] ?? '',
      vagaiyaraNameEnglish: json['vagaiyara_name_english'] ?? '',
    );
  }
}
