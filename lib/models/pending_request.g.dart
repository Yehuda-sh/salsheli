// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingRequest _$PendingRequestFromJson(Map<String, dynamic> json) =>
    PendingRequest(
      id: json['id'] as String? ?? '',
      listId: json['list_id'] as String? ?? '',
      requesterId: json['requester_id'] as String? ?? '',
      type: $enumDecode(_$RequestTypeEnumMap, json['type'],
          unknownValue: RequestType.unknown),
      status: $enumDecode(_$RequestStatusEnumMap, json['status'],
          unknownValue: RequestStatus.unknown),
      createdAt: const FlexibleDateTimeConverter().fromJson(json['created_at']),
      requestData: const _RequestDataConverter().fromJson(json['request_data']),
      reviewerId: json['reviewer_id'] as String?,
      reviewedAt: const NullableFlexibleDateTimeConverter()
          .fromJson(json['reviewed_at']),
      rejectionReason: json['rejection_reason'] as String?,
      requesterName: json['requester_name'] as String?,
      reviewerName: json['reviewer_name'] as String?,
      listName: json['list_name'] as String?,
    );

Map<String, dynamic> _$PendingRequestToJson(PendingRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'list_id': instance.listId,
      'requester_id': instance.requesterId,
      'type': _$RequestTypeEnumMap[instance.type]!,
      'status': _$RequestStatusEnumMap[instance.status]!,
      'created_at':
          const FlexibleDateTimeConverter().toJson(instance.createdAt),
      'request_data':
          const _RequestDataConverter().toJson(instance.requestData),
      'reviewer_id': instance.reviewerId,
      'reviewed_at':
          const NullableFlexibleDateTimeConverter().toJson(instance.reviewedAt),
      'rejection_reason': instance.rejectionReason,
      'requester_name': instance.requesterName,
      'reviewer_name': instance.reviewerName,
      'list_name': instance.listName,
    };

const _$RequestTypeEnumMap = {
  RequestType.addItem: 'addItem',
  RequestType.editItem: 'editItem',
  RequestType.deleteItem: 'deleteItem',
  RequestType.inviteToList: 'inviteToList',
  RequestType.inviteToHousehold: 'inviteToHousehold',
  RequestType.unknown: 'unknown',
};

const _$RequestStatusEnumMap = {
  RequestStatus.pending: 'pending',
  RequestStatus.approved: 'approved',
  RequestStatus.rejected: 'rejected',
  RequestStatus.unknown: 'unknown',
};
