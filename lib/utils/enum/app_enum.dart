enum AppLogType { error, success, warning, defaultLog }

enum AppToastType { success, error, warning, info }

enum ApiStatus { loading, error, completed, internetError, noDataFound }

enum SessionStatus { canceled, confirmed, pending }

//
enum UserRole {
  merchandiser,
  customer,
  influencer;

  bool get isMerchandiser => this == UserRole.merchandiser;
  bool get isCustomer => this == UserRole.customer;
  bool get isInfluencer => this == UserRole.influencer;
}

extension UserRoleX on UserRole {
  bool get isCustomer => this == UserRole.customer;
  bool get isMerchandiser => this == UserRole.merchandiser;
  bool get isInfluencer => this == UserRole.influencer;
}
