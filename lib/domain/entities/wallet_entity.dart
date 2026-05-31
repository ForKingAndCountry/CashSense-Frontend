import 'currency.dart';



class WalletEntity {

  const WalletEntity({

    required this.id,

    required this.name,

    required this.currency,

    required this.createdAt,

    required this.updatedAt,

    this.synced = false,

    this.deleted = false,

  });



  final String id;

  final String name;

  final Currency currency;

  final DateTime createdAt;

  final DateTime updatedAt;

  final bool synced;

  final bool deleted;



  WalletEntity copyWith({

    String? id,

    String? name,

    Currency? currency,

    DateTime? createdAt,

    DateTime? updatedAt,

    bool? synced,

    bool? deleted,

  }) {

    return WalletEntity(

      id: id ?? this.id,

      name: name ?? this.name,

      currency: currency ?? this.currency,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,

      synced: synced ?? this.synced,

      deleted: deleted ?? this.deleted,

    );

  }

}

