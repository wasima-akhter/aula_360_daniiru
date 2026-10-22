import '../../domain/entities/legal_content.dart';

class LegalContentDto {
  final String legalContentType;
  final String content;
  final String? updatedAt;

  const LegalContentDto({
    required this.legalContentType,
    required this.content,
    this.updatedAt,
  });

  factory LegalContentDto.fromJson(Map<String, dynamic> json) {
    return LegalContentDto(
      legalContentType: json['legalContentType'] as String? ?? 'TERMS_AND_CONDITION',
      content: json['content'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'legalContentType': legalContentType,
      'content': content,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  LegalContent toEntity() {
    DateTime? parsedDate;
    if (updatedAt != null) {
      parsedDate = DateTime.tryParse(updatedAt!);
    }

    return LegalContent(
      type: LegalContentType.fromString(legalContentType),
      content: content,
      updatedAt: parsedDate,
    );
  }
}
