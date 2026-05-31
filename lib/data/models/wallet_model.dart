import '../../domain/entities/currency.dart';

import '../../domain/entities/wallet_entity.dart';



class WalletModel {

  const WalletModel({

    required this.id,

    required this.name,

    required this.currencyCode,

    required this.createdAtMs,

    required this.updatedAtMs,

    this.synced = false,

    this.deleted = false,

  });



  final String id;

  final String name;

  final String currencyCode;

  final int createdAtMs;

  final int updatedAtMs;

  final bool synced;

  final bool deleted;



  Map<String, Object?> toMap() => {

        'id': id,

        'name': name,

        'currency': currencyCode,

        'created_at': createdAtMs,

        'updated_at': updatedAtMs,

        'synced': synced,

        'deleted': deleted,

      };



  static WalletModel fromMap(Map<dynamic, dynamic> map) {

    final now = DateTime.now().millisecondsSinceEpoch;

    final created = (map['created_at'] as int?) ?? now;

    return WalletModel(

      id: (map['id'] as String?) ?? '',

      name: (map['name'] as String?) ?? 'Wallet',

      currencyCode: (map['currency'] as String?) ?? 'LRD',

      createdAtMs: created,

      updatedAtMs: (map['updated_at'] as int?) ?? created,

      synced: (map['synced'] as bool?) ?? false,

      deleted: (map['deleted'] as bool?) ?? false,

    );

  }



  WalletEntity toEntity() {

    return WalletEntity(

      id: id,

      name: name,

      currency: Currency.fromCode(currencyCode),

      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),

      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),

      synced: synced,

      deleted: deleted,

    );

  }



  static WalletModel fromEntity(WalletEntity e) {

    return WalletModel(

      id: e.id,

      name: e.name,

      currencyCode: e.currency.code,

      createdAtMs: e.createdAt.millisecondsSinceEpoch,

      updatedAtMs: e.updatedAt.millisecondsSinceEpoch,

      synced: e.synced,

      deleted: e.deleted,

    );

  }



  WalletModel copyWith({

    bool? synced,

    int? updatedAtMs,

    bool? deleted,

  }) {

    return WalletModel(

      id: id,

      name: name,

      currencyCode: currencyCode,

      createdAtMs: createdAtMs,

      updatedAtMs: updatedAtMs ?? this.updatedAtMs,

      synced: synced ?? this.synced,

      deleted: deleted ?? this.deleted,

    );

  }

}

