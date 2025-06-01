import 'package:mobile/models/campaign.dart'; // Assuming CampaignStatus and CampaignPost are here

enum RequestType {
  goalAdjustment("Goal Adjustment"),
  postUpdate("Post Update"),
  endDateExtension("End Date Extension"),
  statusChange("Status Change");

  final String value;
  const RequestType(this.value);
}

enum ResolutionType {
  accepted,
  rejected;

  static ResolutionType? fromString(String? value) {
    if (value == null) return null;
    try {
      return ResolutionType.values.byName(value);
    } catch (e) {
      // Handle cases where the string might be lowercase or different casing
      for (var entry in ResolutionType.values) {
        if (entry.name.toLowerCase() == value.toLowerCase()) {
          return entry;
        }
      }
      return null; // Or throw an error if strict matching is required
    }
  }
}

abstract class CampaignRequest {
  String? id;
  String campaignId;
  String ownerRecipientId; // Kept as per existing model structure
  String title;
  String justification;
  DateTime? requestDate;
  DateTime? resolutionDate;
  ResolutionType? resolutionType;
  String get type; // Abstract getter for the type discriminator

  CampaignRequest({
    this.id,
    required this.campaignId,
    required this.ownerRecipientId,
    required this.title,
    required this.justification,
    this.requestDate,
    this.resolutionDate,
    this.resolutionType,
  });

  // Factory method for deserialization
  factory CampaignRequest.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'GOAL_ADJUSTMENT_REQUEST':
        return GoalAdjustmentRequest.fromJson(json);
      case 'STATUS_CHANGE_REQUEST':
        return StatusChangeRequest.fromJson(json);
      case 'POST_UPDATE_REQUEST':
        return PostUpdateRequest.fromJson(json);
      case 'END_EXTENSION_REQUEST':
        return EndDateExtensionRequest.fromJson(json);
      default:
        // Fallback or error if type is unknown or missing
        // For robustness, you might want to check if other fields can identify the type
        // or throw a more specific error.
        // This example assumes 'type' is always present for valid requests.
        if (json.containsKey('newGoal')) {
          return GoalAdjustmentRequest.fromJson(json..putIfAbsent('type', () => 'GOAL_ADJUSTMENT_REQUEST'));
        }
        if (json.containsKey('newStatus')) {
          return StatusChangeRequest.fromJson(json..putIfAbsent('type', () => 'STATUS_CHANGE_REQUEST'));
        }
        if (json.containsKey('newPostId')) {
          return PostUpdateRequest.fromJson(json..putIfAbsent('type', () => 'POST_UPDATE_REQUEST'));
        }
        if (json.containsKey('newEndDate')) {
          return EndDateExtensionRequest.fromJson(json..putIfAbsent('type', () => 'END_EXTENSION_REQUEST'));
        }
        throw Exception('Unknown or missing request type in JSON: $type');
    }
  }

  Map<String, dynamic> toJson();
}

class GoalAdjustmentRequest extends CampaignRequest {
  BigInt newGoal;

  @override
  String get type => 'GOAL_ADJUSTMENT_REQUEST';

  GoalAdjustmentRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newGoal,
  });

  factory GoalAdjustmentRequest.fromJson(Map<String, dynamic> json) {
    return GoalAdjustmentRequest(
      id: json['id'],
      campaignId: json['campaignId'],
      ownerRecipientId: json['ownerRecipientId'],
      title: json['title'],
      justification: json['justification'],
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : null,
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.parse(json['resolutionDate'])
          : null,
      resolutionType: ResolutionType.fromString(json['resolutionType']),
      newGoal: BigInt.parse(json['newGoal'].toString()),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'ownerRecipientId': ownerRecipientId,
        'title': title,
        'justification': justification,
        'requestDate': requestDate?.toIso8601String(),
        'resolutionDate': resolutionDate?.toIso8601String(),
        'resolutionType': resolutionType?.name,
        'newGoal': newGoal.toString(),
        'type': type,
      };
}

class StatusChangeRequest extends CampaignRequest {
  CampaignStatus newStatus;

  @override
  String get type => 'STATUS_CHANGE_REQUEST';

  StatusChangeRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newStatus,
  });

  factory StatusChangeRequest.fromJson(Map<String, dynamic> json) {
    // 1. Parse all the shared CampaignRequest fields as before:
    final id = json['id'] as String?;
    final campaignId = json['campaignId'] as String;
    final ownerRecipientId = json['ownerRecipientId'] as String;
    final title = json['title'] as String;
    final justification = json['justification'] as String;
    final requestDate = json['requestDate'] != null
        ? DateTime.parse(json['requestDate'] as String)
        : null;
    final resolutionDate = json['resolutionDate'] != null
        ? DateTime.parse(json['resolutionDate'] as String)
        : null;
    final resolutionType =
        ResolutionType.fromString(json['resolutionType'] as String?);

    // 2. Now, do a case‐insensitive lookup for the "newStatus" string:
    final rawStatus = json['newStatus'] as String?;
    if (rawStatus == null) {
      throw Exception("StatusChangeRequest JSON missing 'newStatus': $json");
    }

    // Attempt to find a matching CampaignStatus by comparing .name.toLowerCase()
    final lowerIncoming = rawStatus.toLowerCase();
    final matchingStatus = CampaignStatus.values.firstWhere(
      (enumVal) => enumVal.name.toLowerCase() == lowerIncoming,
      orElse: () {
        // If nothing matches, throw a more descriptive exception:
        throw Exception("Invalid CampaignStatus: '$rawStatus'");
      },
    );

    return StatusChangeRequest(
      id: id,
      campaignId: campaignId,
      ownerRecipientId: ownerRecipientId,
      title: title,
      justification: justification,
      requestDate: requestDate,
      resolutionDate: resolutionDate,
      resolutionType: resolutionType,
      newStatus: matchingStatus,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'ownerRecipientId': ownerRecipientId,
        'title': title,
        'justification': justification,
        'requestDate': requestDate?.toIso8601String(),
        'resolutionDate': resolutionDate?.toIso8601String(),
        'resolutionType': resolutionType?.name,
        'newStatus': newStatus.name,
        'type': type,
      };
}
class PostUpdateRequest extends CampaignRequest {
  String newPostId; // Changed from CampaignPost to String

  @override
  String get type => 'POST_UPDATE_REQUEST';

  PostUpdateRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newPostId,
  });

  factory PostUpdateRequest.fromJson(Map<String, dynamic> json) {
    return PostUpdateRequest(
      id: json['id'],
      campaignId: json['campaignId'],
      ownerRecipientId: json['ownerRecipientId'],
      title: json['title'],
      justification: json['justification'],
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : null,
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.parse(json['resolutionDate'])
          : null,
      resolutionType: ResolutionType.fromString(json['resolutionType']),
      newPostId: json['newPostId'], // Changed to parse newPostId
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'ownerRecipientId': ownerRecipientId,
        'title': title,
        'justification': justification,
        'requestDate': requestDate?.toIso8601String(),
        'resolutionDate': resolutionDate?.toIso8601String(),
        'resolutionType': resolutionType?.name,
        'newPostId': newPostId,
        'type': type,
      };
}

class EndDateExtensionRequest extends CampaignRequest {
  DateTime newEndDate;

  @override
  String get type => 'END_EXTENSION_REQUEST';

  EndDateExtensionRequest({
    super.id,
    required super.campaignId,
    required super.ownerRecipientId,
    required super.title,
    required super.justification,
    super.requestDate,
    super.resolutionDate,
    super.resolutionType,
    required this.newEndDate,
  });

  factory EndDateExtensionRequest.fromJson(Map<String, dynamic> json) {
    return EndDateExtensionRequest(
      id: json['id'],
      campaignId: json['campaignId'],
      ownerRecipientId: json['ownerRecipientId'],
      title: json['title'],
      justification: json['justification'],
      requestDate: json['requestDate'] != null
          ? DateTime.parse(json['requestDate'])
          : null,
      resolutionDate: json['resolutionDate'] != null
          ? DateTime.parse(json['resolutionDate'])
          : null,
      resolutionType: ResolutionType.fromString(json['resolutionType']),
      newEndDate: DateTime.parse(json['newEndDate']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'campaignId': campaignId,
        'ownerRecipientId': ownerRecipientId,
        'title': title,
        'justification': justification,
        'requestDate': requestDate?.toIso8601String(),
        'resolutionDate': resolutionDate?.toIso8601String(),
        'resolutionType': resolutionType?.name,
        'newEndDate': newEndDate.toIso8601String(),
        'type': type,
      };
}