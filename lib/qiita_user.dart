class QiitaUser {
  QiitaUser({
    this.description,
    this.facebookId,
    this.followeesCount,
    this.followersCount,
    this.githubLoginName,
    this.id,
    this.itemsCount,
    this.linkedinId,
    this.location,
    this.name,
    this.organization,
    this.permanentId,
    this.profileImageUrl,
    this.teamOnly,
    this.twitterScreenName,
    this.websiteUrl,
    this.imageMonthlyUploadLimit,
    this.imageMonthlyUploadRemaining,
  });

  factory QiitaUser.fromJson(Map<String, dynamic> json) {
    return QiitaUser(
      description: json['description'] as String,
      facebookId: json['facebook_id'] as String,
      followeesCount: json['followees_count'] as int,
      followersCount: json['followers_count'] as int,
      githubLoginName: json['github_login_name'] as String,
      id: json['id'] as String,
      itemsCount: json['items_count'] as int,
      linkedinId: json['linkedin_id'] as String,
      location: json['location'] as String,
      name: json['name'] as String,
      organization: json['organization'] as String,
      permanentId: json['permanent_id'] as int,
      profileImageUrl: json['profile_image_url'] as String,
      teamOnly: json['team_only'] as bool,
      twitterScreenName: json['twitter_screen_name'] as String,
      websiteUrl: json['website_url'] as String,
      imageMonthlyUploadLimit: json['image_monthly_upload_limit'] as int,
      imageMonthlyUploadRemaining:
          json['image_monthly_upload_remaining'] as int,
    );
  }

  final String description;
  final String facebookId;
  final int followeesCount;
  final int followersCount;
  final String githubLoginName;
  final String id;
  final int itemsCount;
  final String linkedinId;
  final String location;
  final String name;
  final String organization;
  final int permanentId;
  final String profileImageUrl;
  final bool teamOnly;
  final String twitterScreenName;
  final String websiteUrl;
  final int imageMonthlyUploadLimit;
  final int imageMonthlyUploadRemaining;
}
