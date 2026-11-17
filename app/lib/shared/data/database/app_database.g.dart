// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DimensionsTable extends Dimensions
    with TableInfo<$DimensionsTable, DimensionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DimensionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    colorHex,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dimensions';
  @override
  VerificationContext validateIntegrity(
    Insertable<DimensionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorHexMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DimensionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DimensionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DimensionsTable createAlias(String alias) {
    return $DimensionsTable(attachedDatabase, alias);
  }
}

class DimensionRow extends DataClass implements Insertable<DimensionRow> {
  final String id;
  final String name;
  final String description;
  final String colorHex;
  final int sortOrder;
  const DimensionRow({
    required this.id,
    required this.name,
    required this.description,
    required this.colorHex,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['color_hex'] = Variable<String>(colorHex);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DimensionsCompanion toCompanion(bool nullToAbsent) {
    return DimensionsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      colorHex: Value(colorHex),
      sortOrder: Value(sortOrder),
    );
  }

  factory DimensionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DimensionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'colorHex': serializer.toJson<String>(colorHex),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DimensionRow copyWith({
    String? id,
    String? name,
    String? description,
    String? colorHex,
    int? sortOrder,
  }) => DimensionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    colorHex: colorHex ?? this.colorHex,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DimensionRow copyWithCompanion(DimensionsCompanion data) {
    return DimensionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DimensionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, colorHex, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DimensionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.colorHex == this.colorHex &&
          other.sortOrder == this.sortOrder);
}

class DimensionsCompanion extends UpdateCompanion<DimensionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String> colorHex;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const DimensionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DimensionsCompanion.insert({
    required String id,
    required String name,
    required String description,
    required String colorHex,
    required int sortOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       colorHex = Value(colorHex),
       sortOrder = Value(sortOrder);
  static Insertable<DimensionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? colorHex,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (colorHex != null) 'color_hex': colorHex,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DimensionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String>? colorHex,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return DimensionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DimensionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('colorHex: $colorHex, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmotionsTable extends Emotions
    with TableInfo<$EmotionsTable, EmotionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmotionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emotions (id)',
    ),
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, parentId, isSystem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'emotions';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmotionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmotionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmotionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $EmotionsTable createAlias(String alias) {
    return $EmotionsTable(attachedDatabase, alias);
  }
}

class EmotionRow extends DataClass implements Insertable<EmotionRow> {
  final String id;
  final String name;
  final String? parentId;
  final bool isSystem;
  const EmotionRow({
    required this.id,
    required this.name,
    this.parentId,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  EmotionsCompanion toCompanion(bool nullToAbsent) {
    return EmotionsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isSystem: Value(isSystem),
    );
  }

  factory EmotionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmotionRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  EmotionRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    bool? isSystem,
  }) => EmotionRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    isSystem: isSystem ?? this.isSystem,
  );
  EmotionRow copyWithCompanion(EmotionsCompanion data) {
    return EmotionRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmotionRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, parentId, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmotionRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.isSystem == this.isSystem);
}

class EmotionsCompanion extends UpdateCompanion<EmotionRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<bool> isSystem;
  final Value<int> rowid;
  const EmotionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmotionsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<EmotionRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<bool>? isSystem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (isSystem != null) 'is_system': isSystem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmotionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<bool>? isSystem,
    Value<int>? rowid,
  }) {
    return EmotionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      isSystem: isSystem ?? this.isSystem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmotionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('isSystem: $isSystem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TriggersTable extends Triggers
    with TableInfo<$TriggersTable, TriggerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriggersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, isSystem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'triggers';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriggerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriggerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriggerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
    );
  }

  @override
  $TriggersTable createAlias(String alias) {
    return $TriggersTable(attachedDatabase, alias);
  }
}

class TriggerRow extends DataClass implements Insertable<TriggerRow> {
  final String id;
  final String name;
  final bool isSystem;
  const TriggerRow({
    required this.id,
    required this.name,
    required this.isSystem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_system'] = Variable<bool>(isSystem);
    return map;
  }

  TriggersCompanion toCompanion(bool nullToAbsent) {
    return TriggersCompanion(
      id: Value(id),
      name: Value(name),
      isSystem: Value(isSystem),
    );
  }

  factory TriggerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriggerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isSystem': serializer.toJson<bool>(isSystem),
    };
  }

  TriggerRow copyWith({String? id, String? name, bool? isSystem}) => TriggerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isSystem: isSystem ?? this.isSystem,
  );
  TriggerRow copyWithCompanion(TriggersCompanion data) {
    return TriggerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriggerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isSystem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriggerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isSystem == this.isSystem);
}

class TriggersCompanion extends UpdateCompanion<TriggerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isSystem;
  final Value<int> rowid;
  const TriggersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TriggersCompanion.insert({
    required String id,
    required String name,
    this.isSystem = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<TriggerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isSystem,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isSystem != null) 'is_system': isSystem,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TriggersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isSystem,
    Value<int>? rowid,
  }) {
    return TriggersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriggersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicsTable extends Topics with TableInfo<$TopicsTable, TopicRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionIdMeta = const VerificationMeta(
    'dimensionId',
  );
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
    'dimension_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dimensions (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TopicStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TopicStatus>($TopicsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<TopicOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TopicOrigin>($TopicsTable.$converterorigin);
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _validationPassageMeta = const VerificationMeta(
    'validationPassage',
  );
  @override
  late final GeneratedColumn<String> validationPassage =
      GeneratedColumn<String>(
        'validation_passage',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameKey,
    dimensionId,
    status,
    origin,
    confidence,
    note,
    validationPassage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
        _dimensionIdMeta,
        dimensionId.isAcceptableOrUnknown(
          data['dimension_id']!,
          _dimensionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dimensionIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('validation_passage')) {
      context.handle(
        _validationPassageMeta,
        validationPassage.isAcceptableOrUnknown(
          data['validation_passage']!,
          _validationPassageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nameKey, dimensionId},
  ];
  @override
  TopicRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      dimensionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_id'],
      )!,
      status: $TopicsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      origin: $TopicsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      validationPassage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}validation_passage'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TopicsTable createAlias(String alias) {
    return $TopicsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TopicStatus, String, String> $converterstatus =
      const EnumNameConverter<TopicStatus>(TopicStatus.values);
  static JsonTypeConverter2<TopicOrigin, String, String> $converterorigin =
      const EnumNameConverter<TopicOrigin>(TopicOrigin.values);
}

class TopicRow extends DataClass implements Insertable<TopicRow> {
  final String id;
  final String name;

  /// Nombre normalizado (minúsculas, sin tildes) para unicidad por dimensión.
  final String nameKey;
  final String dimensionId;
  final TopicStatus status;
  final TopicOrigin origin;
  final double? confidence;
  final String? note;
  final String? validationPassage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TopicRow({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.dimensionId,
    required this.status,
    required this.origin,
    this.confidence,
    this.note,
    this.validationPassage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_key'] = Variable<String>(nameKey);
    map['dimension_id'] = Variable<String>(dimensionId);
    {
      map['status'] = Variable<String>(
        $TopicsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['origin'] = Variable<String>(
        $TopicsTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || validationPassage != null) {
      map['validation_passage'] = Variable<String>(validationPassage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      dimensionId: Value(dimensionId),
      status: Value(status),
      origin: Value(origin),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      validationPassage: validationPassage == null && nullToAbsent
          ? const Value.absent()
          : Value(validationPassage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TopicRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      dimensionId: serializer.fromJson<String>(json['dimensionId']),
      status: $TopicsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      origin: $TopicsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      confidence: serializer.fromJson<double?>(json['confidence']),
      note: serializer.fromJson<String?>(json['note']),
      validationPassage: serializer.fromJson<String?>(
        json['validationPassage'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'dimensionId': serializer.toJson<String>(dimensionId),
      'status': serializer.toJson<String>(
        $TopicsTable.$converterstatus.toJson(status),
      ),
      'origin': serializer.toJson<String>(
        $TopicsTable.$converterorigin.toJson(origin),
      ),
      'confidence': serializer.toJson<double?>(confidence),
      'note': serializer.toJson<String?>(note),
      'validationPassage': serializer.toJson<String?>(validationPassage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TopicRow copyWith({
    String? id,
    String? name,
    String? nameKey,
    String? dimensionId,
    TopicStatus? status,
    TopicOrigin? origin,
    Value<double?> confidence = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> validationPassage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TopicRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    dimensionId: dimensionId ?? this.dimensionId,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    confidence: confidence.present ? confidence.value : this.confidence,
    note: note.present ? note.value : this.note,
    validationPassage: validationPassage.present
        ? validationPassage.value
        : this.validationPassage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TopicRow copyWithCompanion(TopicsCompanion data) {
    return TopicRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      dimensionId: data.dimensionId.present
          ? data.dimensionId.value
          : this.dimensionId,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      note: data.note.present ? data.note.value : this.note,
      validationPassage: data.validationPassage.present
          ? data.validationPassage.value
          : this.validationPassage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('note: $note, ')
          ..write('validationPassage: $validationPassage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameKey,
    dimensionId,
    status,
    origin,
    confidence,
    note,
    validationPassage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.dimensionId == this.dimensionId &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.confidence == this.confidence &&
          other.note == this.note &&
          other.validationPassage == this.validationPassage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TopicsCompanion extends UpdateCompanion<TopicRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String> dimensionId;
  final Value<TopicStatus> status;
  final Value<TopicOrigin> origin;
  final Value<double?> confidence;
  final Value<String?> note;
  final Value<String?> validationPassage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TopicsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.confidence = const Value.absent(),
    this.note = const Value.absent(),
    this.validationPassage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicsCompanion.insert({
    required String id,
    required String name,
    required String nameKey,
    required String dimensionId,
    required TopicStatus status,
    required TopicOrigin origin,
    this.confidence = const Value.absent(),
    this.note = const Value.absent(),
    this.validationPassage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nameKey = Value(nameKey),
       dimensionId = Value(dimensionId),
       status = Value(status),
       origin = Value(origin),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TopicRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? dimensionId,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<double>? confidence,
    Expression<String>? note,
    Expression<String>? validationPassage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'name_key': nameKey,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (confidence != null) 'confidence': confidence,
      if (note != null) 'note': note,
      if (validationPassage != null) 'validation_passage': validationPassage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String>? dimensionId,
    Value<TopicStatus>? status,
    Value<TopicOrigin>? origin,
    Value<double?>? confidence,
    Value<String?>? note,
    Value<String?>? validationPassage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TopicsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      dimensionId: dimensionId ?? this.dimensionId,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      confidence: confidence ?? this.confidence,
      note: note ?? this.note,
      validationPassage: validationPassage ?? this.validationPassage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TopicsTable.$converterstatus.toSql(status.value),
      );
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $TopicsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (validationPassage.present) {
      map['validation_passage'] = Variable<String>(validationPassage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('note: $note, ')
          ..write('validationPassage: $validationPassage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevotionalsTable extends Devotionals
    with TableInfo<$DevotionalsTable, DevotionalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevotionalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookCodeMeta = const VerificationMeta(
    'bookCode',
  );
  @override
  late final GeneratedColumn<String> bookCode = GeneratedColumn<String>(
    'book_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseStartMeta = const VerificationMeta(
    'verseStart',
  );
  @override
  late final GeneratedColumn<int> verseStart = GeneratedColumn<int>(
    'verse_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verseEndMeta = const VerificationMeta(
    'verseEnd',
  );
  @override
  late final GeneratedColumn<int> verseEnd = GeneratedColumn<int>(
    'verse_end',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _keyVerseMeta = const VerificationMeta(
    'keyVerse',
  );
  @override
  late final GeneratedColumn<String> keyVerse = GeneratedColumn<String>(
    'key_verse',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _periodIdMeta = const VerificationMeta(
    'periodId',
  );
  @override
  late final GeneratedColumn<String> periodId = GeneratedColumn<String>(
    'period_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _empireIdMeta = const VerificationMeta(
    'empireId',
  );
  @override
  late final GeneratedColumn<String> empireId = GeneratedColumn<String>(
    'empire_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
    'region_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _approxYearMeta = const VerificationMeta(
    'approxYear',
  );
  @override
  late final GeneratedColumn<int> approxYear = GeneratedColumn<int>(
    'approx_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    bookCode,
    chapter,
    verseStart,
    verseEnd,
    content,
    title,
    keyVerse,
    periodId,
    empireId,
    regionId,
    author,
    approxYear,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devotionals';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevotionalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('book_code')) {
      context.handle(
        _bookCodeMeta,
        bookCode.isAcceptableOrUnknown(data['book_code']!, _bookCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_bookCodeMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse_start')) {
      context.handle(
        _verseStartMeta,
        verseStart.isAcceptableOrUnknown(data['verse_start']!, _verseStartMeta),
      );
    }
    if (data.containsKey('verse_end')) {
      context.handle(
        _verseEndMeta,
        verseEnd.isAcceptableOrUnknown(data['verse_end']!, _verseEndMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('key_verse')) {
      context.handle(
        _keyVerseMeta,
        keyVerse.isAcceptableOrUnknown(data['key_verse']!, _keyVerseMeta),
      );
    }
    if (data.containsKey('period_id')) {
      context.handle(
        _periodIdMeta,
        periodId.isAcceptableOrUnknown(data['period_id']!, _periodIdMeta),
      );
    }
    if (data.containsKey('empire_id')) {
      context.handle(
        _empireIdMeta,
        empireId.isAcceptableOrUnknown(data['empire_id']!, _empireIdMeta),
      );
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('approx_year')) {
      context.handle(
        _approxYearMeta,
        approxYear.isAcceptableOrUnknown(data['approx_year']!, _approxYearMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevotionalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevotionalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      bookCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_code'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verseStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_start'],
      ),
      verseEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_end'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      keyVerse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_verse'],
      ),
      periodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_id'],
      ),
      empireId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}empire_id'],
      ),
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_id'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      approxYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}approx_year'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DevotionalsTable createAlias(String alias) {
    return $DevotionalsTable(attachedDatabase, alias);
  }
}

class DevotionalRow extends DataClass implements Insertable<DevotionalRow> {
  final String id;
  final DateTime date;
  final String bookCode;
  final int chapter;
  final int? verseStart;
  final int? verseEnd;
  final String content;
  final String? title;

  /// Versículo lema (`PassageRef.encode`).
  final String? keyVerse;
  final String? periodId;
  final String? empireId;
  final String? regionId;
  final String? author;
  final int? approxYear;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DevotionalRow({
    required this.id,
    required this.date,
    required this.bookCode,
    required this.chapter,
    this.verseStart,
    this.verseEnd,
    required this.content,
    this.title,
    this.keyVerse,
    this.periodId,
    this.empireId,
    this.regionId,
    this.author,
    this.approxYear,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['book_code'] = Variable<String>(bookCode);
    map['chapter'] = Variable<int>(chapter);
    if (!nullToAbsent || verseStart != null) {
      map['verse_start'] = Variable<int>(verseStart);
    }
    if (!nullToAbsent || verseEnd != null) {
      map['verse_end'] = Variable<int>(verseEnd);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || keyVerse != null) {
      map['key_verse'] = Variable<String>(keyVerse);
    }
    if (!nullToAbsent || periodId != null) {
      map['period_id'] = Variable<String>(periodId);
    }
    if (!nullToAbsent || empireId != null) {
      map['empire_id'] = Variable<String>(empireId);
    }
    if (!nullToAbsent || regionId != null) {
      map['region_id'] = Variable<String>(regionId);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || approxYear != null) {
      map['approx_year'] = Variable<int>(approxYear);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DevotionalsCompanion toCompanion(bool nullToAbsent) {
    return DevotionalsCompanion(
      id: Value(id),
      date: Value(date),
      bookCode: Value(bookCode),
      chapter: Value(chapter),
      verseStart: verseStart == null && nullToAbsent
          ? const Value.absent()
          : Value(verseStart),
      verseEnd: verseEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(verseEnd),
      content: Value(content),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      keyVerse: keyVerse == null && nullToAbsent
          ? const Value.absent()
          : Value(keyVerse),
      periodId: periodId == null && nullToAbsent
          ? const Value.absent()
          : Value(periodId),
      empireId: empireId == null && nullToAbsent
          ? const Value.absent()
          : Value(empireId),
      regionId: regionId == null && nullToAbsent
          ? const Value.absent()
          : Value(regionId),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      approxYear: approxYear == null && nullToAbsent
          ? const Value.absent()
          : Value(approxYear),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DevotionalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevotionalRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      bookCode: serializer.fromJson<String>(json['bookCode']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verseStart: serializer.fromJson<int?>(json['verseStart']),
      verseEnd: serializer.fromJson<int?>(json['verseEnd']),
      content: serializer.fromJson<String>(json['content']),
      title: serializer.fromJson<String?>(json['title']),
      keyVerse: serializer.fromJson<String?>(json['keyVerse']),
      periodId: serializer.fromJson<String?>(json['periodId']),
      empireId: serializer.fromJson<String?>(json['empireId']),
      regionId: serializer.fromJson<String?>(json['regionId']),
      author: serializer.fromJson<String?>(json['author']),
      approxYear: serializer.fromJson<int?>(json['approxYear']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'bookCode': serializer.toJson<String>(bookCode),
      'chapter': serializer.toJson<int>(chapter),
      'verseStart': serializer.toJson<int?>(verseStart),
      'verseEnd': serializer.toJson<int?>(verseEnd),
      'content': serializer.toJson<String>(content),
      'title': serializer.toJson<String?>(title),
      'keyVerse': serializer.toJson<String?>(keyVerse),
      'periodId': serializer.toJson<String?>(periodId),
      'empireId': serializer.toJson<String?>(empireId),
      'regionId': serializer.toJson<String?>(regionId),
      'author': serializer.toJson<String?>(author),
      'approxYear': serializer.toJson<int?>(approxYear),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DevotionalRow copyWith({
    String? id,
    DateTime? date,
    String? bookCode,
    int? chapter,
    Value<int?> verseStart = const Value.absent(),
    Value<int?> verseEnd = const Value.absent(),
    String? content,
    Value<String?> title = const Value.absent(),
    Value<String?> keyVerse = const Value.absent(),
    Value<String?> periodId = const Value.absent(),
    Value<String?> empireId = const Value.absent(),
    Value<String?> regionId = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<int?> approxYear = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DevotionalRow(
    id: id ?? this.id,
    date: date ?? this.date,
    bookCode: bookCode ?? this.bookCode,
    chapter: chapter ?? this.chapter,
    verseStart: verseStart.present ? verseStart.value : this.verseStart,
    verseEnd: verseEnd.present ? verseEnd.value : this.verseEnd,
    content: content ?? this.content,
    title: title.present ? title.value : this.title,
    keyVerse: keyVerse.present ? keyVerse.value : this.keyVerse,
    periodId: periodId.present ? periodId.value : this.periodId,
    empireId: empireId.present ? empireId.value : this.empireId,
    regionId: regionId.present ? regionId.value : this.regionId,
    author: author.present ? author.value : this.author,
    approxYear: approxYear.present ? approxYear.value : this.approxYear,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DevotionalRow copyWithCompanion(DevotionalsCompanion data) {
    return DevotionalRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      bookCode: data.bookCode.present ? data.bookCode.value : this.bookCode,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verseStart: data.verseStart.present
          ? data.verseStart.value
          : this.verseStart,
      verseEnd: data.verseEnd.present ? data.verseEnd.value : this.verseEnd,
      content: data.content.present ? data.content.value : this.content,
      title: data.title.present ? data.title.value : this.title,
      keyVerse: data.keyVerse.present ? data.keyVerse.value : this.keyVerse,
      periodId: data.periodId.present ? data.periodId.value : this.periodId,
      empireId: data.empireId.present ? data.empireId.value : this.empireId,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      author: data.author.present ? data.author.value : this.author,
      approxYear: data.approxYear.present
          ? data.approxYear.value
          : this.approxYear,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevotionalRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verseStart: $verseStart, ')
          ..write('verseEnd: $verseEnd, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('keyVerse: $keyVerse, ')
          ..write('periodId: $periodId, ')
          ..write('empireId: $empireId, ')
          ..write('regionId: $regionId, ')
          ..write('author: $author, ')
          ..write('approxYear: $approxYear, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    bookCode,
    chapter,
    verseStart,
    verseEnd,
    content,
    title,
    keyVerse,
    periodId,
    empireId,
    regionId,
    author,
    approxYear,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevotionalRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.bookCode == this.bookCode &&
          other.chapter == this.chapter &&
          other.verseStart == this.verseStart &&
          other.verseEnd == this.verseEnd &&
          other.content == this.content &&
          other.title == this.title &&
          other.keyVerse == this.keyVerse &&
          other.periodId == this.periodId &&
          other.empireId == this.empireId &&
          other.regionId == this.regionId &&
          other.author == this.author &&
          other.approxYear == this.approxYear &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DevotionalsCompanion extends UpdateCompanion<DevotionalRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> bookCode;
  final Value<int> chapter;
  final Value<int?> verseStart;
  final Value<int?> verseEnd;
  final Value<String> content;
  final Value<String?> title;
  final Value<String?> keyVerse;
  final Value<String?> periodId;
  final Value<String?> empireId;
  final Value<String?> regionId;
  final Value<String?> author;
  final Value<int?> approxYear;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DevotionalsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.bookCode = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verseStart = const Value.absent(),
    this.verseEnd = const Value.absent(),
    this.content = const Value.absent(),
    this.title = const Value.absent(),
    this.keyVerse = const Value.absent(),
    this.periodId = const Value.absent(),
    this.empireId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.author = const Value.absent(),
    this.approxYear = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevotionalsCompanion.insert({
    required String id,
    required DateTime date,
    required String bookCode,
    required int chapter,
    this.verseStart = const Value.absent(),
    this.verseEnd = const Value.absent(),
    required String content,
    this.title = const Value.absent(),
    this.keyVerse = const Value.absent(),
    this.periodId = const Value.absent(),
    this.empireId = const Value.absent(),
    this.regionId = const Value.absent(),
    this.author = const Value.absent(),
    this.approxYear = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       bookCode = Value(bookCode),
       chapter = Value(chapter),
       content = Value(content),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DevotionalRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? bookCode,
    Expression<int>? chapter,
    Expression<int>? verseStart,
    Expression<int>? verseEnd,
    Expression<String>? content,
    Expression<String>? title,
    Expression<String>? keyVerse,
    Expression<String>? periodId,
    Expression<String>? empireId,
    Expression<String>? regionId,
    Expression<String>? author,
    Expression<int>? approxYear,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (bookCode != null) 'book_code': bookCode,
      if (chapter != null) 'chapter': chapter,
      if (verseStart != null) 'verse_start': verseStart,
      if (verseEnd != null) 'verse_end': verseEnd,
      if (content != null) 'content': content,
      if (title != null) 'title': title,
      if (keyVerse != null) 'key_verse': keyVerse,
      if (periodId != null) 'period_id': periodId,
      if (empireId != null) 'empire_id': empireId,
      if (regionId != null) 'region_id': regionId,
      if (author != null) 'author': author,
      if (approxYear != null) 'approx_year': approxYear,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevotionalsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? bookCode,
    Value<int>? chapter,
    Value<int?>? verseStart,
    Value<int?>? verseEnd,
    Value<String>? content,
    Value<String?>? title,
    Value<String?>? keyVerse,
    Value<String?>? periodId,
    Value<String?>? empireId,
    Value<String?>? regionId,
    Value<String?>? author,
    Value<int?>? approxYear,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DevotionalsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      bookCode: bookCode ?? this.bookCode,
      chapter: chapter ?? this.chapter,
      verseStart: verseStart ?? this.verseStart,
      verseEnd: verseEnd ?? this.verseEnd,
      content: content ?? this.content,
      title: title ?? this.title,
      keyVerse: keyVerse ?? this.keyVerse,
      periodId: periodId ?? this.periodId,
      empireId: empireId ?? this.empireId,
      regionId: regionId ?? this.regionId,
      author: author ?? this.author,
      approxYear: approxYear ?? this.approxYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (bookCode.present) {
      map['book_code'] = Variable<String>(bookCode.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verseStart.present) {
      map['verse_start'] = Variable<int>(verseStart.value);
    }
    if (verseEnd.present) {
      map['verse_end'] = Variable<int>(verseEnd.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (keyVerse.present) {
      map['key_verse'] = Variable<String>(keyVerse.value);
    }
    if (periodId.present) {
      map['period_id'] = Variable<String>(periodId.value);
    }
    if (empireId.present) {
      map['empire_id'] = Variable<String>(empireId.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (approxYear.present) {
      map['approx_year'] = Variable<int>(approxYear.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevotionalsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('bookCode: $bookCode, ')
          ..write('chapter: $chapter, ')
          ..write('verseStart: $verseStart, ')
          ..write('verseEnd: $verseEnd, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('keyVerse: $keyVerse, ')
          ..write('periodId: $periodId, ')
          ..write('empireId: $empireId, ')
          ..write('regionId: $regionId, ')
          ..write('author: $author, ')
          ..write('approxYear: $approxYear, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DevotionalTopicsTable extends DevotionalTopics
    with TableInfo<$DevotionalTopicsTable, DevotionalTopicRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevotionalTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _devotionalIdMeta = const VerificationMeta(
    'devotionalId',
  );
  @override
  late final GeneratedColumn<String> devotionalId = GeneratedColumn<String>(
    'devotional_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devotionals (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topics (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TopicOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TopicOrigin>($DevotionalTopicsTable.$converterorigin);
  @override
  List<GeneratedColumn> get $columns => [devotionalId, topicId, origin];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devotional_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevotionalTopicRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('devotional_id')) {
      context.handle(
        _devotionalIdMeta,
        devotionalId.isAcceptableOrUnknown(
          data['devotional_id']!,
          _devotionalIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_devotionalIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {devotionalId, topicId};
  @override
  DevotionalTopicRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevotionalTopicRow(
      devotionalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devotional_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      origin: $DevotionalTopicsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
    );
  }

  @override
  $DevotionalTopicsTable createAlias(String alias) {
    return $DevotionalTopicsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TopicOrigin, String, String> $converterorigin =
      const EnumNameConverter<TopicOrigin>(TopicOrigin.values);
}

class DevotionalTopicRow extends DataClass
    implements Insertable<DevotionalTopicRow> {
  final String devotionalId;
  final String topicId;
  final TopicOrigin origin;
  const DevotionalTopicRow({
    required this.devotionalId,
    required this.topicId,
    required this.origin,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['devotional_id'] = Variable<String>(devotionalId);
    map['topic_id'] = Variable<String>(topicId);
    {
      map['origin'] = Variable<String>(
        $DevotionalTopicsTable.$converterorigin.toSql(origin),
      );
    }
    return map;
  }

  DevotionalTopicsCompanion toCompanion(bool nullToAbsent) {
    return DevotionalTopicsCompanion(
      devotionalId: Value(devotionalId),
      topicId: Value(topicId),
      origin: Value(origin),
    );
  }

  factory DevotionalTopicRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevotionalTopicRow(
      devotionalId: serializer.fromJson<String>(json['devotionalId']),
      topicId: serializer.fromJson<String>(json['topicId']),
      origin: $DevotionalTopicsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'devotionalId': serializer.toJson<String>(devotionalId),
      'topicId': serializer.toJson<String>(topicId),
      'origin': serializer.toJson<String>(
        $DevotionalTopicsTable.$converterorigin.toJson(origin),
      ),
    };
  }

  DevotionalTopicRow copyWith({
    String? devotionalId,
    String? topicId,
    TopicOrigin? origin,
  }) => DevotionalTopicRow(
    devotionalId: devotionalId ?? this.devotionalId,
    topicId: topicId ?? this.topicId,
    origin: origin ?? this.origin,
  );
  DevotionalTopicRow copyWithCompanion(DevotionalTopicsCompanion data) {
    return DevotionalTopicRow(
      devotionalId: data.devotionalId.present
          ? data.devotionalId.value
          : this.devotionalId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      origin: data.origin.present ? data.origin.value : this.origin,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevotionalTopicRow(')
          ..write('devotionalId: $devotionalId, ')
          ..write('topicId: $topicId, ')
          ..write('origin: $origin')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(devotionalId, topicId, origin);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevotionalTopicRow &&
          other.devotionalId == this.devotionalId &&
          other.topicId == this.topicId &&
          other.origin == this.origin);
}

class DevotionalTopicsCompanion extends UpdateCompanion<DevotionalTopicRow> {
  final Value<String> devotionalId;
  final Value<String> topicId;
  final Value<TopicOrigin> origin;
  final Value<int> rowid;
  const DevotionalTopicsCompanion({
    this.devotionalId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.origin = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevotionalTopicsCompanion.insert({
    required String devotionalId,
    required String topicId,
    required TopicOrigin origin,
    this.rowid = const Value.absent(),
  }) : devotionalId = Value(devotionalId),
       topicId = Value(topicId),
       origin = Value(origin);
  static Insertable<DevotionalTopicRow> custom({
    Expression<String>? devotionalId,
    Expression<String>? topicId,
    Expression<String>? origin,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (devotionalId != null) 'devotional_id': devotionalId,
      if (topicId != null) 'topic_id': topicId,
      if (origin != null) 'origin': origin,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevotionalTopicsCompanion copyWith({
    Value<String>? devotionalId,
    Value<String>? topicId,
    Value<TopicOrigin>? origin,
    Value<int>? rowid,
  }) {
    return DevotionalTopicsCompanion(
      devotionalId: devotionalId ?? this.devotionalId,
      topicId: topicId ?? this.topicId,
      origin: origin ?? this.origin,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (devotionalId.present) {
      map['devotional_id'] = Variable<String>(devotionalId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $DevotionalTopicsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevotionalTopicsCompanion(')
          ..write('devotionalId: $devotionalId, ')
          ..write('topicId: $topicId, ')
          ..write('origin: $origin, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PraxisEntriesTable extends PraxisEntries
    with TableInfo<$PraxisEntriesTable, PraxisRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraxisEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _circumstanceMeta = const VerificationMeta(
    'circumstance',
  );
  @override
  late final GeneratedColumn<String> circumstance = GeneratedColumn<String>(
    'circumstance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    false,
    check: () => ComparableExpr(intensity).isBetweenValues(1, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FilterType, String> filter =
      GeneratedColumn<String>(
        'filter',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FilterType>($PraxisEntriesTable.$converterfilter);
  static const VerificationMeta _foundationDetailMeta = const VerificationMeta(
    'foundationDetail',
  );
  @override
  late final GeneratedColumn<String> foundationDetail = GeneratedColumn<String>(
    'foundation_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _passageMeta = const VerificationMeta(
    'passage',
  );
  @override
  late final GeneratedColumn<String> passage = GeneratedColumn<String>(
    'passage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peaceMeta = const VerificationMeta('peace');
  @override
  late final GeneratedColumn<int> peace = GeneratedColumn<int>(
    'peace',
    aliasedName,
    false,
    check: () => ComparableExpr(peace).isBetweenValues(1, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coherenceMeta = const VerificationMeta(
    'coherence',
  );
  @override
  late final GeneratedColumn<int> coherence = GeneratedColumn<int>(
    'coherence',
    aliasedName,
    true,
    check: () => ComparableExpr(coherence).isBetweenValues(1, 10),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    circumstance,
    intensity,
    filter,
    foundationDetail,
    passage,
    action,
    peace,
    coherence,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praxis_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<PraxisRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('circumstance')) {
      context.handle(
        _circumstanceMeta,
        circumstance.isAcceptableOrUnknown(
          data['circumstance']!,
          _circumstanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_circumstanceMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
    }
    if (data.containsKey('foundation_detail')) {
      context.handle(
        _foundationDetailMeta,
        foundationDetail.isAcceptableOrUnknown(
          data['foundation_detail']!,
          _foundationDetailMeta,
        ),
      );
    }
    if (data.containsKey('passage')) {
      context.handle(
        _passageMeta,
        passage.isAcceptableOrUnknown(data['passage']!, _passageMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('peace')) {
      context.handle(
        _peaceMeta,
        peace.isAcceptableOrUnknown(data['peace']!, _peaceMeta),
      );
    } else if (isInserting) {
      context.missing(_peaceMeta);
    }
    if (data.containsKey('coherence')) {
      context.handle(
        _coherenceMeta,
        coherence.isAcceptableOrUnknown(data['coherence']!, _coherenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PraxisRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraxisRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      circumstance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circumstance'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
      )!,
      filter: $PraxisEntriesTable.$converterfilter.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}filter'],
        )!,
      ),
      foundationDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foundation_detail'],
      ),
      passage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passage'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      peace: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}peace'],
      )!,
      coherence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coherence'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PraxisEntriesTable createAlias(String alias) {
    return $PraxisEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FilterType, String, String> $converterfilter =
      const EnumNameConverter<FilterType>(FilterType.values);
}

class PraxisRow extends DataClass implements Insertable<PraxisRow> {
  final String id;
  final DateTime date;
  final String circumstance;
  final int intensity;
  final FilterType filter;
  final String? foundationDetail;
  final String? passage;
  final String action;
  final int peace;

  /// Opcional: el registro rápido no la pide (v2). Nunca se inventa un valor por defecto.
  final int? coherence;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PraxisRow({
    required this.id,
    required this.date,
    required this.circumstance,
    required this.intensity,
    required this.filter,
    this.foundationDetail,
    this.passage,
    required this.action,
    required this.peace,
    this.coherence,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['circumstance'] = Variable<String>(circumstance);
    map['intensity'] = Variable<int>(intensity);
    {
      map['filter'] = Variable<String>(
        $PraxisEntriesTable.$converterfilter.toSql(filter),
      );
    }
    if (!nullToAbsent || foundationDetail != null) {
      map['foundation_detail'] = Variable<String>(foundationDetail);
    }
    if (!nullToAbsent || passage != null) {
      map['passage'] = Variable<String>(passage);
    }
    map['action'] = Variable<String>(action);
    map['peace'] = Variable<int>(peace);
    if (!nullToAbsent || coherence != null) {
      map['coherence'] = Variable<int>(coherence);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PraxisEntriesCompanion toCompanion(bool nullToAbsent) {
    return PraxisEntriesCompanion(
      id: Value(id),
      date: Value(date),
      circumstance: Value(circumstance),
      intensity: Value(intensity),
      filter: Value(filter),
      foundationDetail: foundationDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(foundationDetail),
      passage: passage == null && nullToAbsent
          ? const Value.absent()
          : Value(passage),
      action: Value(action),
      peace: Value(peace),
      coherence: coherence == null && nullToAbsent
          ? const Value.absent()
          : Value(coherence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PraxisRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraxisRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      circumstance: serializer.fromJson<String>(json['circumstance']),
      intensity: serializer.fromJson<int>(json['intensity']),
      filter: $PraxisEntriesTable.$converterfilter.fromJson(
        serializer.fromJson<String>(json['filter']),
      ),
      foundationDetail: serializer.fromJson<String?>(json['foundationDetail']),
      passage: serializer.fromJson<String?>(json['passage']),
      action: serializer.fromJson<String>(json['action']),
      peace: serializer.fromJson<int>(json['peace']),
      coherence: serializer.fromJson<int?>(json['coherence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'circumstance': serializer.toJson<String>(circumstance),
      'intensity': serializer.toJson<int>(intensity),
      'filter': serializer.toJson<String>(
        $PraxisEntriesTable.$converterfilter.toJson(filter),
      ),
      'foundationDetail': serializer.toJson<String?>(foundationDetail),
      'passage': serializer.toJson<String?>(passage),
      'action': serializer.toJson<String>(action),
      'peace': serializer.toJson<int>(peace),
      'coherence': serializer.toJson<int?>(coherence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PraxisRow copyWith({
    String? id,
    DateTime? date,
    String? circumstance,
    int? intensity,
    FilterType? filter,
    Value<String?> foundationDetail = const Value.absent(),
    Value<String?> passage = const Value.absent(),
    String? action,
    int? peace,
    Value<int?> coherence = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PraxisRow(
    id: id ?? this.id,
    date: date ?? this.date,
    circumstance: circumstance ?? this.circumstance,
    intensity: intensity ?? this.intensity,
    filter: filter ?? this.filter,
    foundationDetail: foundationDetail.present
        ? foundationDetail.value
        : this.foundationDetail,
    passage: passage.present ? passage.value : this.passage,
    action: action ?? this.action,
    peace: peace ?? this.peace,
    coherence: coherence.present ? coherence.value : this.coherence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PraxisRow copyWithCompanion(PraxisEntriesCompanion data) {
    return PraxisRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      circumstance: data.circumstance.present
          ? data.circumstance.value
          : this.circumstance,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      filter: data.filter.present ? data.filter.value : this.filter,
      foundationDetail: data.foundationDetail.present
          ? data.foundationDetail.value
          : this.foundationDetail,
      passage: data.passage.present ? data.passage.value : this.passage,
      action: data.action.present ? data.action.value : this.action,
      peace: data.peace.present ? data.peace.value : this.peace,
      coherence: data.coherence.present ? data.coherence.value : this.coherence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraxisRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('circumstance: $circumstance, ')
          ..write('intensity: $intensity, ')
          ..write('filter: $filter, ')
          ..write('foundationDetail: $foundationDetail, ')
          ..write('passage: $passage, ')
          ..write('action: $action, ')
          ..write('peace: $peace, ')
          ..write('coherence: $coherence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    circumstance,
    intensity,
    filter,
    foundationDetail,
    passage,
    action,
    peace,
    coherence,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraxisRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.circumstance == this.circumstance &&
          other.intensity == this.intensity &&
          other.filter == this.filter &&
          other.foundationDetail == this.foundationDetail &&
          other.passage == this.passage &&
          other.action == this.action &&
          other.peace == this.peace &&
          other.coherence == this.coherence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PraxisEntriesCompanion extends UpdateCompanion<PraxisRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> circumstance;
  final Value<int> intensity;
  final Value<FilterType> filter;
  final Value<String?> foundationDetail;
  final Value<String?> passage;
  final Value<String> action;
  final Value<int> peace;
  final Value<int?> coherence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PraxisEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.circumstance = const Value.absent(),
    this.intensity = const Value.absent(),
    this.filter = const Value.absent(),
    this.foundationDetail = const Value.absent(),
    this.passage = const Value.absent(),
    this.action = const Value.absent(),
    this.peace = const Value.absent(),
    this.coherence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PraxisEntriesCompanion.insert({
    required String id,
    required DateTime date,
    required String circumstance,
    required int intensity,
    required FilterType filter,
    this.foundationDetail = const Value.absent(),
    this.passage = const Value.absent(),
    required String action,
    required int peace,
    this.coherence = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       circumstance = Value(circumstance),
       intensity = Value(intensity),
       filter = Value(filter),
       action = Value(action),
       peace = Value(peace),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<PraxisRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? circumstance,
    Expression<int>? intensity,
    Expression<String>? filter,
    Expression<String>? foundationDetail,
    Expression<String>? passage,
    Expression<String>? action,
    Expression<int>? peace,
    Expression<int>? coherence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (circumstance != null) 'circumstance': circumstance,
      if (intensity != null) 'intensity': intensity,
      if (filter != null) 'filter': filter,
      if (foundationDetail != null) 'foundation_detail': foundationDetail,
      if (passage != null) 'passage': passage,
      if (action != null) 'action': action,
      if (peace != null) 'peace': peace,
      if (coherence != null) 'coherence': coherence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PraxisEntriesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? circumstance,
    Value<int>? intensity,
    Value<FilterType>? filter,
    Value<String?>? foundationDetail,
    Value<String?>? passage,
    Value<String>? action,
    Value<int>? peace,
    Value<int?>? coherence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PraxisEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      circumstance: circumstance ?? this.circumstance,
      intensity: intensity ?? this.intensity,
      filter: filter ?? this.filter,
      foundationDetail: foundationDetail ?? this.foundationDetail,
      passage: passage ?? this.passage,
      action: action ?? this.action,
      peace: peace ?? this.peace,
      coherence: coherence ?? this.coherence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (circumstance.present) {
      map['circumstance'] = Variable<String>(circumstance.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (filter.present) {
      map['filter'] = Variable<String>(
        $PraxisEntriesTable.$converterfilter.toSql(filter.value),
      );
    }
    if (foundationDetail.present) {
      map['foundation_detail'] = Variable<String>(foundationDetail.value);
    }
    if (passage.present) {
      map['passage'] = Variable<String>(passage.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (peace.present) {
      map['peace'] = Variable<int>(peace.value);
    }
    if (coherence.present) {
      map['coherence'] = Variable<int>(coherence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraxisEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('circumstance: $circumstance, ')
          ..write('intensity: $intensity, ')
          ..write('filter: $filter, ')
          ..write('foundationDetail: $foundationDetail, ')
          ..write('passage: $passage, ')
          ..write('action: $action, ')
          ..write('peace: $peace, ')
          ..write('coherence: $coherence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PraxisEmotionsTable extends PraxisEmotions
    with TableInfo<$PraxisEmotionsTable, PraxisEmotion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraxisEmotionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _praxisIdMeta = const VerificationMeta(
    'praxisId',
  );
  @override
  late final GeneratedColumn<String> praxisId = GeneratedColumn<String>(
    'praxis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES praxis_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _emotionIdMeta = const VerificationMeta(
    'emotionId',
  );
  @override
  late final GeneratedColumn<String> emotionId = GeneratedColumn<String>(
    'emotion_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES emotions (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [praxisId, emotionId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praxis_emotions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PraxisEmotion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('praxis_id')) {
      context.handle(
        _praxisIdMeta,
        praxisId.isAcceptableOrUnknown(data['praxis_id']!, _praxisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_praxisIdMeta);
    }
    if (data.containsKey('emotion_id')) {
      context.handle(
        _emotionIdMeta,
        emotionId.isAcceptableOrUnknown(data['emotion_id']!, _emotionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_emotionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {praxisId, emotionId};
  @override
  PraxisEmotion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraxisEmotion(
      praxisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}praxis_id'],
      )!,
      emotionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion_id'],
      )!,
    );
  }

  @override
  $PraxisEmotionsTable createAlias(String alias) {
    return $PraxisEmotionsTable(attachedDatabase, alias);
  }
}

class PraxisEmotion extends DataClass implements Insertable<PraxisEmotion> {
  final String praxisId;
  final String emotionId;
  const PraxisEmotion({required this.praxisId, required this.emotionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['praxis_id'] = Variable<String>(praxisId);
    map['emotion_id'] = Variable<String>(emotionId);
    return map;
  }

  PraxisEmotionsCompanion toCompanion(bool nullToAbsent) {
    return PraxisEmotionsCompanion(
      praxisId: Value(praxisId),
      emotionId: Value(emotionId),
    );
  }

  factory PraxisEmotion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraxisEmotion(
      praxisId: serializer.fromJson<String>(json['praxisId']),
      emotionId: serializer.fromJson<String>(json['emotionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'praxisId': serializer.toJson<String>(praxisId),
      'emotionId': serializer.toJson<String>(emotionId),
    };
  }

  PraxisEmotion copyWith({String? praxisId, String? emotionId}) =>
      PraxisEmotion(
        praxisId: praxisId ?? this.praxisId,
        emotionId: emotionId ?? this.emotionId,
      );
  PraxisEmotion copyWithCompanion(PraxisEmotionsCompanion data) {
    return PraxisEmotion(
      praxisId: data.praxisId.present ? data.praxisId.value : this.praxisId,
      emotionId: data.emotionId.present ? data.emotionId.value : this.emotionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraxisEmotion(')
          ..write('praxisId: $praxisId, ')
          ..write('emotionId: $emotionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(praxisId, emotionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraxisEmotion &&
          other.praxisId == this.praxisId &&
          other.emotionId == this.emotionId);
}

class PraxisEmotionsCompanion extends UpdateCompanion<PraxisEmotion> {
  final Value<String> praxisId;
  final Value<String> emotionId;
  final Value<int> rowid;
  const PraxisEmotionsCompanion({
    this.praxisId = const Value.absent(),
    this.emotionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PraxisEmotionsCompanion.insert({
    required String praxisId,
    required String emotionId,
    this.rowid = const Value.absent(),
  }) : praxisId = Value(praxisId),
       emotionId = Value(emotionId);
  static Insertable<PraxisEmotion> custom({
    Expression<String>? praxisId,
    Expression<String>? emotionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (praxisId != null) 'praxis_id': praxisId,
      if (emotionId != null) 'emotion_id': emotionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PraxisEmotionsCompanion copyWith({
    Value<String>? praxisId,
    Value<String>? emotionId,
    Value<int>? rowid,
  }) {
    return PraxisEmotionsCompanion(
      praxisId: praxisId ?? this.praxisId,
      emotionId: emotionId ?? this.emotionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (praxisId.present) {
      map['praxis_id'] = Variable<String>(praxisId.value);
    }
    if (emotionId.present) {
      map['emotion_id'] = Variable<String>(emotionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraxisEmotionsCompanion(')
          ..write('praxisId: $praxisId, ')
          ..write('emotionId: $emotionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PraxisTriggersTable extends PraxisTriggers
    with TableInfo<$PraxisTriggersTable, PraxisTrigger> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraxisTriggersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _praxisIdMeta = const VerificationMeta(
    'praxisId',
  );
  @override
  late final GeneratedColumn<String> praxisId = GeneratedColumn<String>(
    'praxis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES praxis_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerIdMeta = const VerificationMeta(
    'triggerId',
  );
  @override
  late final GeneratedColumn<String> triggerId = GeneratedColumn<String>(
    'trigger_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES triggers (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [praxisId, triggerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praxis_triggers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PraxisTrigger> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('praxis_id')) {
      context.handle(
        _praxisIdMeta,
        praxisId.isAcceptableOrUnknown(data['praxis_id']!, _praxisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_praxisIdMeta);
    }
    if (data.containsKey('trigger_id')) {
      context.handle(
        _triggerIdMeta,
        triggerId.isAcceptableOrUnknown(data['trigger_id']!, _triggerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {praxisId, triggerId};
  @override
  PraxisTrigger map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraxisTrigger(
      praxisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}praxis_id'],
      )!,
      triggerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_id'],
      )!,
    );
  }

  @override
  $PraxisTriggersTable createAlias(String alias) {
    return $PraxisTriggersTable(attachedDatabase, alias);
  }
}

class PraxisTrigger extends DataClass implements Insertable<PraxisTrigger> {
  final String praxisId;
  final String triggerId;
  const PraxisTrigger({required this.praxisId, required this.triggerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['praxis_id'] = Variable<String>(praxisId);
    map['trigger_id'] = Variable<String>(triggerId);
    return map;
  }

  PraxisTriggersCompanion toCompanion(bool nullToAbsent) {
    return PraxisTriggersCompanion(
      praxisId: Value(praxisId),
      triggerId: Value(triggerId),
    );
  }

  factory PraxisTrigger.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraxisTrigger(
      praxisId: serializer.fromJson<String>(json['praxisId']),
      triggerId: serializer.fromJson<String>(json['triggerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'praxisId': serializer.toJson<String>(praxisId),
      'triggerId': serializer.toJson<String>(triggerId),
    };
  }

  PraxisTrigger copyWith({String? praxisId, String? triggerId}) =>
      PraxisTrigger(
        praxisId: praxisId ?? this.praxisId,
        triggerId: triggerId ?? this.triggerId,
      );
  PraxisTrigger copyWithCompanion(PraxisTriggersCompanion data) {
    return PraxisTrigger(
      praxisId: data.praxisId.present ? data.praxisId.value : this.praxisId,
      triggerId: data.triggerId.present ? data.triggerId.value : this.triggerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraxisTrigger(')
          ..write('praxisId: $praxisId, ')
          ..write('triggerId: $triggerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(praxisId, triggerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraxisTrigger &&
          other.praxisId == this.praxisId &&
          other.triggerId == this.triggerId);
}

class PraxisTriggersCompanion extends UpdateCompanion<PraxisTrigger> {
  final Value<String> praxisId;
  final Value<String> triggerId;
  final Value<int> rowid;
  const PraxisTriggersCompanion({
    this.praxisId = const Value.absent(),
    this.triggerId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PraxisTriggersCompanion.insert({
    required String praxisId,
    required String triggerId,
    this.rowid = const Value.absent(),
  }) : praxisId = Value(praxisId),
       triggerId = Value(triggerId);
  static Insertable<PraxisTrigger> custom({
    Expression<String>? praxisId,
    Expression<String>? triggerId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (praxisId != null) 'praxis_id': praxisId,
      if (triggerId != null) 'trigger_id': triggerId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PraxisTriggersCompanion copyWith({
    Value<String>? praxisId,
    Value<String>? triggerId,
    Value<int>? rowid,
  }) {
    return PraxisTriggersCompanion(
      praxisId: praxisId ?? this.praxisId,
      triggerId: triggerId ?? this.triggerId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (praxisId.present) {
      map['praxis_id'] = Variable<String>(praxisId.value);
    }
    if (triggerId.present) {
      map['trigger_id'] = Variable<String>(triggerId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraxisTriggersCompanion(')
          ..write('praxisId: $praxisId, ')
          ..write('triggerId: $triggerId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PraxisTopicsTable extends PraxisTopics
    with TableInfo<$PraxisTopicsTable, PraxisTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PraxisTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _praxisIdMeta = const VerificationMeta(
    'praxisId',
  );
  @override
  late final GeneratedColumn<String> praxisId = GeneratedColumn<String>(
    'praxis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES praxis_entries (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topics (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [praxisId, topicId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'praxis_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<PraxisTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('praxis_id')) {
      context.handle(
        _praxisIdMeta,
        praxisId.isAcceptableOrUnknown(data['praxis_id']!, _praxisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_praxisIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {praxisId, topicId};
  @override
  PraxisTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PraxisTopic(
      praxisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}praxis_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
    );
  }

  @override
  $PraxisTopicsTable createAlias(String alias) {
    return $PraxisTopicsTable(attachedDatabase, alias);
  }
}

class PraxisTopic extends DataClass implements Insertable<PraxisTopic> {
  final String praxisId;
  final String topicId;
  const PraxisTopic({required this.praxisId, required this.topicId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['praxis_id'] = Variable<String>(praxisId);
    map['topic_id'] = Variable<String>(topicId);
    return map;
  }

  PraxisTopicsCompanion toCompanion(bool nullToAbsent) {
    return PraxisTopicsCompanion(
      praxisId: Value(praxisId),
      topicId: Value(topicId),
    );
  }

  factory PraxisTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PraxisTopic(
      praxisId: serializer.fromJson<String>(json['praxisId']),
      topicId: serializer.fromJson<String>(json['topicId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'praxisId': serializer.toJson<String>(praxisId),
      'topicId': serializer.toJson<String>(topicId),
    };
  }

  PraxisTopic copyWith({String? praxisId, String? topicId}) => PraxisTopic(
    praxisId: praxisId ?? this.praxisId,
    topicId: topicId ?? this.topicId,
  );
  PraxisTopic copyWithCompanion(PraxisTopicsCompanion data) {
    return PraxisTopic(
      praxisId: data.praxisId.present ? data.praxisId.value : this.praxisId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PraxisTopic(')
          ..write('praxisId: $praxisId, ')
          ..write('topicId: $topicId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(praxisId, topicId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PraxisTopic &&
          other.praxisId == this.praxisId &&
          other.topicId == this.topicId);
}

class PraxisTopicsCompanion extends UpdateCompanion<PraxisTopic> {
  final Value<String> praxisId;
  final Value<String> topicId;
  final Value<int> rowid;
  const PraxisTopicsCompanion({
    this.praxisId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PraxisTopicsCompanion.insert({
    required String praxisId,
    required String topicId,
    this.rowid = const Value.absent(),
  }) : praxisId = Value(praxisId),
       topicId = Value(topicId);
  static Insertable<PraxisTopic> custom({
    Expression<String>? praxisId,
    Expression<String>? topicId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (praxisId != null) 'praxis_id': praxisId,
      if (topicId != null) 'topic_id': topicId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PraxisTopicsCompanion copyWith({
    Value<String>? praxisId,
    Value<String>? topicId,
    Value<int>? rowid,
  }) {
    return PraxisTopicsCompanion(
      praxisId: praxisId ?? this.praxisId,
      topicId: topicId ?? this.topicId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (praxisId.present) {
      map['praxis_id'] = Variable<String>(praxisId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PraxisTopicsCompanion(')
          ..write('praxisId: $praxisId, ')
          ..write('topicId: $topicId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayersTable extends Prayers with TableInfo<$PrayersTable, PrayerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrayerIntent, String> intent =
      GeneratedColumn<String>(
        'intent',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrayerIntent>($PrayersTable.$converterintent);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    transcript,
    intent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayers';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    } else if (isInserting) {
      context.missing(_transcriptMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PrayerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      )!,
      intent: $PrayersTable.$converterintent.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}intent'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PrayersTable createAlias(String alias) {
    return $PrayersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrayerIntent, String, String> $converterintent =
      const EnumNameConverter<PrayerIntent>(PrayerIntent.values);
}

class PrayerRow extends DataClass implements Insertable<PrayerRow> {
  final String id;
  final DateTime date;
  final String transcript;
  final PrayerIntent intent;
  final DateTime createdAt;
  const PrayerRow({
    required this.id,
    required this.date,
    required this.transcript,
    required this.intent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['transcript'] = Variable<String>(transcript);
    {
      map['intent'] = Variable<String>(
        $PrayersTable.$converterintent.toSql(intent),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PrayersCompanion toCompanion(bool nullToAbsent) {
    return PrayersCompanion(
      id: Value(id),
      date: Value(date),
      transcript: Value(transcript),
      intent: Value(intent),
      createdAt: Value(createdAt),
    );
  }

  factory PrayerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerRow(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      transcript: serializer.fromJson<String>(json['transcript']),
      intent: $PrayersTable.$converterintent.fromJson(
        serializer.fromJson<String>(json['intent']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'transcript': serializer.toJson<String>(transcript),
      'intent': serializer.toJson<String>(
        $PrayersTable.$converterintent.toJson(intent),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PrayerRow copyWith({
    String? id,
    DateTime? date,
    String? transcript,
    PrayerIntent? intent,
    DateTime? createdAt,
  }) => PrayerRow(
    id: id ?? this.id,
    date: date ?? this.date,
    transcript: transcript ?? this.transcript,
    intent: intent ?? this.intent,
    createdAt: createdAt ?? this.createdAt,
  );
  PrayerRow copyWithCompanion(PrayersCompanion data) {
    return PrayerRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      intent: data.intent.present ? data.intent.value : this.intent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('transcript: $transcript, ')
          ..write('intent: $intent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, transcript, intent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.transcript == this.transcript &&
          other.intent == this.intent &&
          other.createdAt == this.createdAt);
}

class PrayersCompanion extends UpdateCompanion<PrayerRow> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String> transcript;
  final Value<PrayerIntent> intent;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PrayersCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.transcript = const Value.absent(),
    this.intent = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayersCompanion.insert({
    required String id,
    required DateTime date,
    required String transcript,
    required PrayerIntent intent,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       transcript = Value(transcript),
       intent = Value(intent),
       createdAt = Value(createdAt);
  static Insertable<PrayerRow> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? transcript,
    Expression<String>? intent,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (transcript != null) 'transcript': transcript,
      if (intent != null) 'intent': intent,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String>? transcript,
    Value<PrayerIntent>? intent,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PrayersCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      transcript: transcript ?? this.transcript,
      intent: intent ?? this.intent,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(
        $PrayersTable.$converterintent.toSql(intent.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayersCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('transcript: $transcript, ')
          ..write('intent: $intent, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerTopicsTable extends PrayerTopics
    with TableInfo<$PrayerTopicsTable, PrayerTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerIdMeta = const VerificationMeta(
    'prayerId',
  );
  @override
  late final GeneratedColumn<String> prayerId = GeneratedColumn<String>(
    'prayer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prayers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topics (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [prayerId, topicId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer_id')) {
      context.handle(
        _prayerIdMeta,
        prayerId.isAcceptableOrUnknown(data['prayer_id']!, _prayerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayerId, topicId};
  @override
  PrayerTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerTopic(
      prayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
    );
  }

  @override
  $PrayerTopicsTable createAlias(String alias) {
    return $PrayerTopicsTable(attachedDatabase, alias);
  }
}

class PrayerTopic extends DataClass implements Insertable<PrayerTopic> {
  final String prayerId;
  final String topicId;
  const PrayerTopic({required this.prayerId, required this.topicId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prayer_id'] = Variable<String>(prayerId);
    map['topic_id'] = Variable<String>(topicId);
    return map;
  }

  PrayerTopicsCompanion toCompanion(bool nullToAbsent) {
    return PrayerTopicsCompanion(
      prayerId: Value(prayerId),
      topicId: Value(topicId),
    );
  }

  factory PrayerTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerTopic(
      prayerId: serializer.fromJson<String>(json['prayerId']),
      topicId: serializer.fromJson<String>(json['topicId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayerId': serializer.toJson<String>(prayerId),
      'topicId': serializer.toJson<String>(topicId),
    };
  }

  PrayerTopic copyWith({String? prayerId, String? topicId}) => PrayerTopic(
    prayerId: prayerId ?? this.prayerId,
    topicId: topicId ?? this.topicId,
  );
  PrayerTopic copyWithCompanion(PrayerTopicsCompanion data) {
    return PrayerTopic(
      prayerId: data.prayerId.present ? data.prayerId.value : this.prayerId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTopic(')
          ..write('prayerId: $prayerId, ')
          ..write('topicId: $topicId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayerId, topicId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerTopic &&
          other.prayerId == this.prayerId &&
          other.topicId == this.topicId);
}

class PrayerTopicsCompanion extends UpdateCompanion<PrayerTopic> {
  final Value<String> prayerId;
  final Value<String> topicId;
  final Value<int> rowid;
  const PrayerTopicsCompanion({
    this.prayerId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerTopicsCompanion.insert({
    required String prayerId,
    required String topicId,
    this.rowid = const Value.absent(),
  }) : prayerId = Value(prayerId),
       topicId = Value(topicId);
  static Insertable<PrayerTopic> custom({
    Expression<String>? prayerId,
    Expression<String>? topicId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayerId != null) 'prayer_id': prayerId,
      if (topicId != null) 'topic_id': topicId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerTopicsCompanion copyWith({
    Value<String>? prayerId,
    Value<String>? topicId,
    Value<int>? rowid,
  }) {
    return PrayerTopicsCompanion(
      prayerId: prayerId ?? this.prayerId,
      topicId: topicId ?? this.topicId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayerId.present) {
      map['prayer_id'] = Variable<String>(prayerId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerTopicsCompanion(')
          ..write('prayerId: $prayerId, ')
          ..write('topicId: $topicId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PrayerPraxisLinksTable extends PrayerPraxisLinks
    with TableInfo<$PrayerPraxisLinksTable, PrayerPraxisLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerPraxisLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _prayerIdMeta = const VerificationMeta(
    'prayerId',
  );
  @override
  late final GeneratedColumn<String> prayerId = GeneratedColumn<String>(
    'prayer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES prayers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _praxisIdMeta = const VerificationMeta(
    'praxisId',
  );
  @override
  late final GeneratedColumn<String> praxisId = GeneratedColumn<String>(
    'praxis_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES praxis_entries (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [prayerId, praxisId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_praxis_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<PrayerPraxisLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('prayer_id')) {
      context.handle(
        _prayerIdMeta,
        prayerId.isAcceptableOrUnknown(data['prayer_id']!, _prayerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_prayerIdMeta);
    }
    if (data.containsKey('praxis_id')) {
      context.handle(
        _praxisIdMeta,
        praxisId.isAcceptableOrUnknown(data['praxis_id']!, _praxisIdMeta),
      );
    } else if (isInserting) {
      context.missing(_praxisIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {prayerId, praxisId};
  @override
  PrayerPraxisLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerPraxisLink(
      prayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prayer_id'],
      )!,
      praxisId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}praxis_id'],
      )!,
    );
  }

  @override
  $PrayerPraxisLinksTable createAlias(String alias) {
    return $PrayerPraxisLinksTable(attachedDatabase, alias);
  }
}

class PrayerPraxisLink extends DataClass
    implements Insertable<PrayerPraxisLink> {
  final String prayerId;
  final String praxisId;
  const PrayerPraxisLink({required this.prayerId, required this.praxisId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['prayer_id'] = Variable<String>(prayerId);
    map['praxis_id'] = Variable<String>(praxisId);
    return map;
  }

  PrayerPraxisLinksCompanion toCompanion(bool nullToAbsent) {
    return PrayerPraxisLinksCompanion(
      prayerId: Value(prayerId),
      praxisId: Value(praxisId),
    );
  }

  factory PrayerPraxisLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerPraxisLink(
      prayerId: serializer.fromJson<String>(json['prayerId']),
      praxisId: serializer.fromJson<String>(json['praxisId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'prayerId': serializer.toJson<String>(prayerId),
      'praxisId': serializer.toJson<String>(praxisId),
    };
  }

  PrayerPraxisLink copyWith({String? prayerId, String? praxisId}) =>
      PrayerPraxisLink(
        prayerId: prayerId ?? this.prayerId,
        praxisId: praxisId ?? this.praxisId,
      );
  PrayerPraxisLink copyWithCompanion(PrayerPraxisLinksCompanion data) {
    return PrayerPraxisLink(
      prayerId: data.prayerId.present ? data.prayerId.value : this.prayerId,
      praxisId: data.praxisId.present ? data.praxisId.value : this.praxisId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerPraxisLink(')
          ..write('prayerId: $prayerId, ')
          ..write('praxisId: $praxisId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(prayerId, praxisId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerPraxisLink &&
          other.prayerId == this.prayerId &&
          other.praxisId == this.praxisId);
}

class PrayerPraxisLinksCompanion extends UpdateCompanion<PrayerPraxisLink> {
  final Value<String> prayerId;
  final Value<String> praxisId;
  final Value<int> rowid;
  const PrayerPraxisLinksCompanion({
    this.prayerId = const Value.absent(),
    this.praxisId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PrayerPraxisLinksCompanion.insert({
    required String prayerId,
    required String praxisId,
    this.rowid = const Value.absent(),
  }) : prayerId = Value(prayerId),
       praxisId = Value(praxisId);
  static Insertable<PrayerPraxisLink> custom({
    Expression<String>? prayerId,
    Expression<String>? praxisId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (prayerId != null) 'prayer_id': prayerId,
      if (praxisId != null) 'praxis_id': praxisId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PrayerPraxisLinksCompanion copyWith({
    Value<String>? prayerId,
    Value<String>? praxisId,
    Value<int>? rowid,
  }) {
    return PrayerPraxisLinksCompanion(
      prayerId: prayerId ?? this.prayerId,
      praxisId: praxisId ?? this.praxisId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (prayerId.present) {
      map['prayer_id'] = Variable<String>(prayerId.value);
    }
    if (praxisId.present) {
      map['praxis_id'] = Variable<String>(praxisId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerPraxisLinksCompanion(')
          ..write('prayerId: $prayerId, ')
          ..write('praxisId: $praxisId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentsTable extends Attachments
    with TableInfo<$AttachmentsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerType,
    ownerId,
    fileName,
    mimeType,
    width,
    height,
    sizeBytes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentsTable createAlias(String alias) {
    return $AttachmentsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;

  /// Tipo de registro dueño: 'praxis' por ahora.
  final String ownerType;
  final String ownerId;

  /// Nombre del archivo dentro de la carpeta de adjuntos (no ruta absoluta: cambia entre dispositivos).
  final String fileName;
  final String mimeType;
  final int? width;
  final int? height;
  final int sizeBytes;
  final DateTime createdAt;
  const AttachmentRow({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    required this.fileName,
    required this.mimeType,
    this.width,
    this.height,
    required this.sizeBytes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['file_name'] = Variable<String>(fileName);
    map['mime_type'] = Variable<String>(mimeType);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentsCompanion(
      id: Value(id),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      fileName: Value(fileName),
      mimeType: Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      fileName: serializer.fromJson<String>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'fileName': serializer.toJson<String>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? ownerType,
    String? ownerId,
    String? fileName,
    String? mimeType,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    int? sizeBytes,
    DateTime? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId ?? this.ownerId,
    fileName: fileName ?? this.fileName,
    mimeType: mimeType ?? this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerType,
    ownerId,
    fileName,
    mimeType,
    width,
    height,
    sizeBytes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt);
}

class AttachmentsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String> fileName;
  final Value<String> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentsCompanion({
    this.id = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentsCompanion.insert({
    required String id,
    required String ownerType,
    required String ownerId,
    required String fileName,
    required String mimeType,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    required int sizeBytes,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerType = Value(ownerType),
       ownerId = Value(ownerId),
       fileName = Value(fileName),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerType,
    Value<String>? ownerId,
    Value<String>? fileName,
    Value<String>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<int>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentsCompanion(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentsCompanion(')
          ..write('id: $id, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BeliefsTable extends Beliefs with TableInfo<$BeliefsTable, BeliefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeliefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _propositionMeta = const VerificationMeta(
    'proposition',
  );
  @override
  late final GeneratedColumn<String> proposition = GeneratedColumn<String>(
    'proposition',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 280,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BeliefStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BeliefStatus>($BeliefsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<BeliefOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<BeliefOrigin>($BeliefsTable.$converterorigin);
  static const VerificationMeta _dimensionIdMeta = const VerificationMeta(
    'dimensionId',
  );
  @override
  late final GeneratedColumn<String> dimensionId = GeneratedColumn<String>(
    'dimension_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dimensions (id)',
    ),
  );
  static const VerificationMeta _devotionalIdMeta = const VerificationMeta(
    'devotionalId',
  );
  @override
  late final GeneratedColumn<String> devotionalId = GeneratedColumn<String>(
    'devotional_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devotionals (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _basePassageMeta = const VerificationMeta(
    'basePassage',
  );
  @override
  late final GeneratedColumn<String> basePassage = GeneratedColumn<String>(
    'base_passage',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    proposition,
    status,
    origin,
    dimensionId,
    devotionalId,
    basePassage,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'beliefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<BeliefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('proposition')) {
      context.handle(
        _propositionMeta,
        proposition.isAcceptableOrUnknown(
          data['proposition']!,
          _propositionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_propositionMeta);
    }
    if (data.containsKey('dimension_id')) {
      context.handle(
        _dimensionIdMeta,
        dimensionId.isAcceptableOrUnknown(
          data['dimension_id']!,
          _dimensionIdMeta,
        ),
      );
    }
    if (data.containsKey('devotional_id')) {
      context.handle(
        _devotionalIdMeta,
        devotionalId.isAcceptableOrUnknown(
          data['devotional_id']!,
          _devotionalIdMeta,
        ),
      );
    }
    if (data.containsKey('base_passage')) {
      context.handle(
        _basePassageMeta,
        basePassage.isAcceptableOrUnknown(
          data['base_passage']!,
          _basePassageMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BeliefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BeliefRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      proposition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposition'],
      )!,
      status: $BeliefsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      origin: $BeliefsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      dimensionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dimension_id'],
      ),
      devotionalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}devotional_id'],
      ),
      basePassage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_passage'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BeliefsTable createAlias(String alias) {
    return $BeliefsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BeliefStatus, String, String> $converterstatus =
      const EnumNameConverter<BeliefStatus>(BeliefStatus.values);
  static JsonTypeConverter2<BeliefOrigin, String, String> $converterorigin =
      const EnumNameConverter<BeliefOrigin>(BeliefOrigin.values);
}

class BeliefRow extends DataClass implements Insertable<BeliefRow> {
  final String id;
  final String proposition;
  final BeliefStatus status;
  final BeliefOrigin origin;
  final String? dimensionId;
  final String? devotionalId;

  /// Pasaje base (`PassageRef.encode`): ancla de la huella canónica.
  final String? basePassage;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BeliefRow({
    required this.id,
    required this.proposition,
    required this.status,
    required this.origin,
    this.dimensionId,
    this.devotionalId,
    this.basePassage,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['proposition'] = Variable<String>(proposition);
    {
      map['status'] = Variable<String>(
        $BeliefsTable.$converterstatus.toSql(status),
      );
    }
    {
      map['origin'] = Variable<String>(
        $BeliefsTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || dimensionId != null) {
      map['dimension_id'] = Variable<String>(dimensionId);
    }
    if (!nullToAbsent || devotionalId != null) {
      map['devotional_id'] = Variable<String>(devotionalId);
    }
    if (!nullToAbsent || basePassage != null) {
      map['base_passage'] = Variable<String>(basePassage);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BeliefsCompanion toCompanion(bool nullToAbsent) {
    return BeliefsCompanion(
      id: Value(id),
      proposition: Value(proposition),
      status: Value(status),
      origin: Value(origin),
      dimensionId: dimensionId == null && nullToAbsent
          ? const Value.absent()
          : Value(dimensionId),
      devotionalId: devotionalId == null && nullToAbsent
          ? const Value.absent()
          : Value(devotionalId),
      basePassage: basePassage == null && nullToAbsent
          ? const Value.absent()
          : Value(basePassage),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BeliefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BeliefRow(
      id: serializer.fromJson<String>(json['id']),
      proposition: serializer.fromJson<String>(json['proposition']),
      status: $BeliefsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      origin: $BeliefsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      dimensionId: serializer.fromJson<String?>(json['dimensionId']),
      devotionalId: serializer.fromJson<String?>(json['devotionalId']),
      basePassage: serializer.fromJson<String?>(json['basePassage']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'proposition': serializer.toJson<String>(proposition),
      'status': serializer.toJson<String>(
        $BeliefsTable.$converterstatus.toJson(status),
      ),
      'origin': serializer.toJson<String>(
        $BeliefsTable.$converterorigin.toJson(origin),
      ),
      'dimensionId': serializer.toJson<String?>(dimensionId),
      'devotionalId': serializer.toJson<String?>(devotionalId),
      'basePassage': serializer.toJson<String?>(basePassage),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BeliefRow copyWith({
    String? id,
    String? proposition,
    BeliefStatus? status,
    BeliefOrigin? origin,
    Value<String?> dimensionId = const Value.absent(),
    Value<String?> devotionalId = const Value.absent(),
    Value<String?> basePassage = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BeliefRow(
    id: id ?? this.id,
    proposition: proposition ?? this.proposition,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    dimensionId: dimensionId.present ? dimensionId.value : this.dimensionId,
    devotionalId: devotionalId.present ? devotionalId.value : this.devotionalId,
    basePassage: basePassage.present ? basePassage.value : this.basePassage,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BeliefRow copyWithCompanion(BeliefsCompanion data) {
    return BeliefRow(
      id: data.id.present ? data.id.value : this.id,
      proposition: data.proposition.present
          ? data.proposition.value
          : this.proposition,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      dimensionId: data.dimensionId.present
          ? data.dimensionId.value
          : this.dimensionId,
      devotionalId: data.devotionalId.present
          ? data.devotionalId.value
          : this.devotionalId,
      basePassage: data.basePassage.present
          ? data.basePassage.value
          : this.basePassage,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BeliefRow(')
          ..write('id: $id, ')
          ..write('proposition: $proposition, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('devotionalId: $devotionalId, ')
          ..write('basePassage: $basePassage, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    proposition,
    status,
    origin,
    dimensionId,
    devotionalId,
    basePassage,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BeliefRow &&
          other.id == this.id &&
          other.proposition == this.proposition &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.dimensionId == this.dimensionId &&
          other.devotionalId == this.devotionalId &&
          other.basePassage == this.basePassage &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BeliefsCompanion extends UpdateCompanion<BeliefRow> {
  final Value<String> id;
  final Value<String> proposition;
  final Value<BeliefStatus> status;
  final Value<BeliefOrigin> origin;
  final Value<String?> dimensionId;
  final Value<String?> devotionalId;
  final Value<String?> basePassage;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BeliefsCompanion({
    this.id = const Value.absent(),
    this.proposition = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.dimensionId = const Value.absent(),
    this.devotionalId = const Value.absent(),
    this.basePassage = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeliefsCompanion.insert({
    required String id,
    required String proposition,
    required BeliefStatus status,
    required BeliefOrigin origin,
    this.dimensionId = const Value.absent(),
    this.devotionalId = const Value.absent(),
    this.basePassage = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       proposition = Value(proposition),
       status = Value(status),
       origin = Value(origin),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BeliefRow> custom({
    Expression<String>? id,
    Expression<String>? proposition,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<String>? dimensionId,
    Expression<String>? devotionalId,
    Expression<String>? basePassage,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (proposition != null) 'proposition': proposition,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (dimensionId != null) 'dimension_id': dimensionId,
      if (devotionalId != null) 'devotional_id': devotionalId,
      if (basePassage != null) 'base_passage': basePassage,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeliefsCompanion copyWith({
    Value<String>? id,
    Value<String>? proposition,
    Value<BeliefStatus>? status,
    Value<BeliefOrigin>? origin,
    Value<String?>? dimensionId,
    Value<String?>? devotionalId,
    Value<String?>? basePassage,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BeliefsCompanion(
      id: id ?? this.id,
      proposition: proposition ?? this.proposition,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      dimensionId: dimensionId ?? this.dimensionId,
      devotionalId: devotionalId ?? this.devotionalId,
      basePassage: basePassage ?? this.basePassage,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (proposition.present) {
      map['proposition'] = Variable<String>(proposition.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $BeliefsTable.$converterstatus.toSql(status.value),
      );
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $BeliefsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (dimensionId.present) {
      map['dimension_id'] = Variable<String>(dimensionId.value);
    }
    if (devotionalId.present) {
      map['devotional_id'] = Variable<String>(devotionalId.value);
    }
    if (basePassage.present) {
      map['base_passage'] = Variable<String>(basePassage.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeliefsCompanion(')
          ..write('id: $id, ')
          ..write('proposition: $proposition, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('dimensionId: $dimensionId, ')
          ..write('devotionalId: $devotionalId, ')
          ..write('basePassage: $basePassage, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BeliefTopicsTable extends BeliefTopics
    with TableInfo<$BeliefTopicsTable, BeliefTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeliefTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _beliefIdMeta = const VerificationMeta(
    'beliefId',
  );
  @override
  late final GeneratedColumn<String> beliefId = GeneratedColumn<String>(
    'belief_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beliefs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES topics (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [beliefId, topicId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'belief_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<BeliefTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('belief_id')) {
      context.handle(
        _beliefIdMeta,
        beliefId.isAcceptableOrUnknown(data['belief_id']!, _beliefIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beliefIdMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {beliefId, topicId};
  @override
  BeliefTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BeliefTopic(
      beliefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}belief_id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
    );
  }

  @override
  $BeliefTopicsTable createAlias(String alias) {
    return $BeliefTopicsTable(attachedDatabase, alias);
  }
}

class BeliefTopic extends DataClass implements Insertable<BeliefTopic> {
  final String beliefId;
  final String topicId;
  const BeliefTopic({required this.beliefId, required this.topicId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['belief_id'] = Variable<String>(beliefId);
    map['topic_id'] = Variable<String>(topicId);
    return map;
  }

  BeliefTopicsCompanion toCompanion(bool nullToAbsent) {
    return BeliefTopicsCompanion(
      beliefId: Value(beliefId),
      topicId: Value(topicId),
    );
  }

  factory BeliefTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BeliefTopic(
      beliefId: serializer.fromJson<String>(json['beliefId']),
      topicId: serializer.fromJson<String>(json['topicId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'beliefId': serializer.toJson<String>(beliefId),
      'topicId': serializer.toJson<String>(topicId),
    };
  }

  BeliefTopic copyWith({String? beliefId, String? topicId}) => BeliefTopic(
    beliefId: beliefId ?? this.beliefId,
    topicId: topicId ?? this.topicId,
  );
  BeliefTopic copyWithCompanion(BeliefTopicsCompanion data) {
    return BeliefTopic(
      beliefId: data.beliefId.present ? data.beliefId.value : this.beliefId,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BeliefTopic(')
          ..write('beliefId: $beliefId, ')
          ..write('topicId: $topicId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(beliefId, topicId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BeliefTopic &&
          other.beliefId == this.beliefId &&
          other.topicId == this.topicId);
}

class BeliefTopicsCompanion extends UpdateCompanion<BeliefTopic> {
  final Value<String> beliefId;
  final Value<String> topicId;
  final Value<int> rowid;
  const BeliefTopicsCompanion({
    this.beliefId = const Value.absent(),
    this.topicId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeliefTopicsCompanion.insert({
    required String beliefId,
    required String topicId,
    this.rowid = const Value.absent(),
  }) : beliefId = Value(beliefId),
       topicId = Value(topicId);
  static Insertable<BeliefTopic> custom({
    Expression<String>? beliefId,
    Expression<String>? topicId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (beliefId != null) 'belief_id': beliefId,
      if (topicId != null) 'topic_id': topicId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeliefTopicsCompanion copyWith({
    Value<String>? beliefId,
    Value<String>? topicId,
    Value<int>? rowid,
  }) {
    return BeliefTopicsCompanion(
      beliefId: beliefId ?? this.beliefId,
      topicId: topicId ?? this.topicId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (beliefId.present) {
      map['belief_id'] = Variable<String>(beliefId.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeliefTopicsCompanion(')
          ..write('beliefId: $beliefId, ')
          ..write('topicId: $topicId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BeliefEvidenceTableTable extends BeliefEvidenceTable
    with TableInfo<$BeliefEvidenceTableTable, BeliefEvidenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BeliefEvidenceTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beliefIdMeta = const VerificationMeta(
    'beliefId',
  );
  @override
  late final GeneratedColumn<String> beliefId = GeneratedColumn<String>(
    'belief_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beliefs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _passageMeta = const VerificationMeta(
    'passage',
  );
  @override
  late final GeneratedColumn<String> passage = GeneratedColumn<String>(
    'passage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EvidenceKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EvidenceKind>($BeliefEvidenceTableTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<EvidenceSource, String> source =
      GeneratedColumn<String>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EvidenceSource>(
        $BeliefEvidenceTableTable.$convertersource,
      );
  static const VerificationMeta _votesMeta = const VerificationMeta('votes');
  @override
  late final GeneratedColumn<int> votes = GeneratedColumn<int>(
    'votes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _probEntailMeta = const VerificationMeta(
    'probEntail',
  );
  @override
  late final GeneratedColumn<double> probEntail = GeneratedColumn<double>(
    'prob_entail',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _probContraMeta = const VerificationMeta(
    'probContra',
  );
  @override
  late final GeneratedColumn<double> probContra = GeneratedColumn<double>(
    'prob_contra',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resolvedMeta = const VerificationMeta(
    'resolved',
  );
  @override
  late final GeneratedColumn<bool> resolved = GeneratedColumn<bool>(
    'resolved',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resolved" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    beliefId,
    passage,
    kind,
    source,
    votes,
    probEntail,
    probContra,
    modelVersion,
    resolved,
    confirmed,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'belief_evidence';
  @override
  VerificationContext validateIntegrity(
    Insertable<BeliefEvidenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('belief_id')) {
      context.handle(
        _beliefIdMeta,
        beliefId.isAcceptableOrUnknown(data['belief_id']!, _beliefIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beliefIdMeta);
    }
    if (data.containsKey('passage')) {
      context.handle(
        _passageMeta,
        passage.isAcceptableOrUnknown(data['passage']!, _passageMeta),
      );
    } else if (isInserting) {
      context.missing(_passageMeta);
    }
    if (data.containsKey('votes')) {
      context.handle(
        _votesMeta,
        votes.isAcceptableOrUnknown(data['votes']!, _votesMeta),
      );
    }
    if (data.containsKey('prob_entail')) {
      context.handle(
        _probEntailMeta,
        probEntail.isAcceptableOrUnknown(data['prob_entail']!, _probEntailMeta),
      );
    }
    if (data.containsKey('prob_contra')) {
      context.handle(
        _probContraMeta,
        probContra.isAcceptableOrUnknown(data['prob_contra']!, _probContraMeta),
      );
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    }
    if (data.containsKey('resolved')) {
      context.handle(
        _resolvedMeta,
        resolved.isAcceptableOrUnknown(data['resolved']!, _resolvedMeta),
      );
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {beliefId, passage},
  ];
  @override
  BeliefEvidenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BeliefEvidenceRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      beliefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}belief_id'],
      )!,
      passage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}passage'],
      )!,
      kind: $BeliefEvidenceTableTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      source: $BeliefEvidenceTableTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      votes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}votes'],
      ),
      probEntail: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prob_entail'],
      ),
      probContra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prob_contra'],
      ),
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      ),
      resolved: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resolved'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BeliefEvidenceTableTable createAlias(String alias) {
    return $BeliefEvidenceTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EvidenceKind, String, String> $converterkind =
      const EnumNameConverter<EvidenceKind>(EvidenceKind.values);
  static JsonTypeConverter2<EvidenceSource, String, String> $convertersource =
      const EnumNameConverter<EvidenceSource>(EvidenceSource.values);
}

class BeliefEvidenceRow extends DataClass
    implements Insertable<BeliefEvidenceRow> {
  final String id;
  final String beliefId;
  final String passage;
  final EvidenceKind kind;
  final EvidenceSource source;
  final int? votes;
  final double? probEntail;
  final double? probContra;
  final String? modelVersion;
  final bool resolved;
  final bool confirmed;
  final String? note;
  final DateTime createdAt;
  const BeliefEvidenceRow({
    required this.id,
    required this.beliefId,
    required this.passage,
    required this.kind,
    required this.source,
    this.votes,
    this.probEntail,
    this.probContra,
    this.modelVersion,
    required this.resolved,
    required this.confirmed,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['belief_id'] = Variable<String>(beliefId);
    map['passage'] = Variable<String>(passage);
    {
      map['kind'] = Variable<String>(
        $BeliefEvidenceTableTable.$converterkind.toSql(kind),
      );
    }
    {
      map['source'] = Variable<String>(
        $BeliefEvidenceTableTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || votes != null) {
      map['votes'] = Variable<int>(votes);
    }
    if (!nullToAbsent || probEntail != null) {
      map['prob_entail'] = Variable<double>(probEntail);
    }
    if (!nullToAbsent || probContra != null) {
      map['prob_contra'] = Variable<double>(probContra);
    }
    if (!nullToAbsent || modelVersion != null) {
      map['model_version'] = Variable<String>(modelVersion);
    }
    map['resolved'] = Variable<bool>(resolved);
    map['confirmed'] = Variable<bool>(confirmed);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BeliefEvidenceTableCompanion toCompanion(bool nullToAbsent) {
    return BeliefEvidenceTableCompanion(
      id: Value(id),
      beliefId: Value(beliefId),
      passage: Value(passage),
      kind: Value(kind),
      source: Value(source),
      votes: votes == null && nullToAbsent
          ? const Value.absent()
          : Value(votes),
      probEntail: probEntail == null && nullToAbsent
          ? const Value.absent()
          : Value(probEntail),
      probContra: probContra == null && nullToAbsent
          ? const Value.absent()
          : Value(probContra),
      modelVersion: modelVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(modelVersion),
      resolved: Value(resolved),
      confirmed: Value(confirmed),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory BeliefEvidenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BeliefEvidenceRow(
      id: serializer.fromJson<String>(json['id']),
      beliefId: serializer.fromJson<String>(json['beliefId']),
      passage: serializer.fromJson<String>(json['passage']),
      kind: $BeliefEvidenceTableTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      source: $BeliefEvidenceTableTable.$convertersource.fromJson(
        serializer.fromJson<String>(json['source']),
      ),
      votes: serializer.fromJson<int?>(json['votes']),
      probEntail: serializer.fromJson<double?>(json['probEntail']),
      probContra: serializer.fromJson<double?>(json['probContra']),
      modelVersion: serializer.fromJson<String?>(json['modelVersion']),
      resolved: serializer.fromJson<bool>(json['resolved']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'beliefId': serializer.toJson<String>(beliefId),
      'passage': serializer.toJson<String>(passage),
      'kind': serializer.toJson<String>(
        $BeliefEvidenceTableTable.$converterkind.toJson(kind),
      ),
      'source': serializer.toJson<String>(
        $BeliefEvidenceTableTable.$convertersource.toJson(source),
      ),
      'votes': serializer.toJson<int?>(votes),
      'probEntail': serializer.toJson<double?>(probEntail),
      'probContra': serializer.toJson<double?>(probContra),
      'modelVersion': serializer.toJson<String?>(modelVersion),
      'resolved': serializer.toJson<bool>(resolved),
      'confirmed': serializer.toJson<bool>(confirmed),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BeliefEvidenceRow copyWith({
    String? id,
    String? beliefId,
    String? passage,
    EvidenceKind? kind,
    EvidenceSource? source,
    Value<int?> votes = const Value.absent(),
    Value<double?> probEntail = const Value.absent(),
    Value<double?> probContra = const Value.absent(),
    Value<String?> modelVersion = const Value.absent(),
    bool? resolved,
    bool? confirmed,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => BeliefEvidenceRow(
    id: id ?? this.id,
    beliefId: beliefId ?? this.beliefId,
    passage: passage ?? this.passage,
    kind: kind ?? this.kind,
    source: source ?? this.source,
    votes: votes.present ? votes.value : this.votes,
    probEntail: probEntail.present ? probEntail.value : this.probEntail,
    probContra: probContra.present ? probContra.value : this.probContra,
    modelVersion: modelVersion.present ? modelVersion.value : this.modelVersion,
    resolved: resolved ?? this.resolved,
    confirmed: confirmed ?? this.confirmed,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  BeliefEvidenceRow copyWithCompanion(BeliefEvidenceTableCompanion data) {
    return BeliefEvidenceRow(
      id: data.id.present ? data.id.value : this.id,
      beliefId: data.beliefId.present ? data.beliefId.value : this.beliefId,
      passage: data.passage.present ? data.passage.value : this.passage,
      kind: data.kind.present ? data.kind.value : this.kind,
      source: data.source.present ? data.source.value : this.source,
      votes: data.votes.present ? data.votes.value : this.votes,
      probEntail: data.probEntail.present
          ? data.probEntail.value
          : this.probEntail,
      probContra: data.probContra.present
          ? data.probContra.value
          : this.probContra,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      resolved: data.resolved.present ? data.resolved.value : this.resolved,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BeliefEvidenceRow(')
          ..write('id: $id, ')
          ..write('beliefId: $beliefId, ')
          ..write('passage: $passage, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('votes: $votes, ')
          ..write('probEntail: $probEntail, ')
          ..write('probContra: $probContra, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('resolved: $resolved, ')
          ..write('confirmed: $confirmed, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    beliefId,
    passage,
    kind,
    source,
    votes,
    probEntail,
    probContra,
    modelVersion,
    resolved,
    confirmed,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BeliefEvidenceRow &&
          other.id == this.id &&
          other.beliefId == this.beliefId &&
          other.passage == this.passage &&
          other.kind == this.kind &&
          other.source == this.source &&
          other.votes == this.votes &&
          other.probEntail == this.probEntail &&
          other.probContra == this.probContra &&
          other.modelVersion == this.modelVersion &&
          other.resolved == this.resolved &&
          other.confirmed == this.confirmed &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class BeliefEvidenceTableCompanion extends UpdateCompanion<BeliefEvidenceRow> {
  final Value<String> id;
  final Value<String> beliefId;
  final Value<String> passage;
  final Value<EvidenceKind> kind;
  final Value<EvidenceSource> source;
  final Value<int?> votes;
  final Value<double?> probEntail;
  final Value<double?> probContra;
  final Value<String?> modelVersion;
  final Value<bool> resolved;
  final Value<bool> confirmed;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BeliefEvidenceTableCompanion({
    this.id = const Value.absent(),
    this.beliefId = const Value.absent(),
    this.passage = const Value.absent(),
    this.kind = const Value.absent(),
    this.source = const Value.absent(),
    this.votes = const Value.absent(),
    this.probEntail = const Value.absent(),
    this.probContra = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.resolved = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BeliefEvidenceTableCompanion.insert({
    required String id,
    required String beliefId,
    required String passage,
    required EvidenceKind kind,
    required EvidenceSource source,
    this.votes = const Value.absent(),
    this.probEntail = const Value.absent(),
    this.probContra = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.resolved = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       beliefId = Value(beliefId),
       passage = Value(passage),
       kind = Value(kind),
       source = Value(source),
       createdAt = Value(createdAt);
  static Insertable<BeliefEvidenceRow> custom({
    Expression<String>? id,
    Expression<String>? beliefId,
    Expression<String>? passage,
    Expression<String>? kind,
    Expression<String>? source,
    Expression<int>? votes,
    Expression<double>? probEntail,
    Expression<double>? probContra,
    Expression<String>? modelVersion,
    Expression<bool>? resolved,
    Expression<bool>? confirmed,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (beliefId != null) 'belief_id': beliefId,
      if (passage != null) 'passage': passage,
      if (kind != null) 'kind': kind,
      if (source != null) 'source': source,
      if (votes != null) 'votes': votes,
      if (probEntail != null) 'prob_entail': probEntail,
      if (probContra != null) 'prob_contra': probContra,
      if (modelVersion != null) 'model_version': modelVersion,
      if (resolved != null) 'resolved': resolved,
      if (confirmed != null) 'confirmed': confirmed,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BeliefEvidenceTableCompanion copyWith({
    Value<String>? id,
    Value<String>? beliefId,
    Value<String>? passage,
    Value<EvidenceKind>? kind,
    Value<EvidenceSource>? source,
    Value<int?>? votes,
    Value<double?>? probEntail,
    Value<double?>? probContra,
    Value<String?>? modelVersion,
    Value<bool>? resolved,
    Value<bool>? confirmed,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BeliefEvidenceTableCompanion(
      id: id ?? this.id,
      beliefId: beliefId ?? this.beliefId,
      passage: passage ?? this.passage,
      kind: kind ?? this.kind,
      source: source ?? this.source,
      votes: votes ?? this.votes,
      probEntail: probEntail ?? this.probEntail,
      probContra: probContra ?? this.probContra,
      modelVersion: modelVersion ?? this.modelVersion,
      resolved: resolved ?? this.resolved,
      confirmed: confirmed ?? this.confirmed,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (beliefId.present) {
      map['belief_id'] = Variable<String>(beliefId.value);
    }
    if (passage.present) {
      map['passage'] = Variable<String>(passage.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $BeliefEvidenceTableTable.$converterkind.toSql(kind.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $BeliefEvidenceTableTable.$convertersource.toSql(source.value),
      );
    }
    if (votes.present) {
      map['votes'] = Variable<int>(votes.value);
    }
    if (probEntail.present) {
      map['prob_entail'] = Variable<double>(probEntail.value);
    }
    if (probContra.present) {
      map['prob_contra'] = Variable<double>(probContra.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (resolved.present) {
      map['resolved'] = Variable<bool>(resolved.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BeliefEvidenceTableCompanion(')
          ..write('id: $id, ')
          ..write('beliefId: $beliefId, ')
          ..write('passage: $passage, ')
          ..write('kind: $kind, ')
          ..write('source: $source, ')
          ..write('votes: $votes, ')
          ..write('probEntail: $probEntail, ')
          ..write('probContra: $probContra, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('resolved: $resolved, ')
          ..write('confirmed: $confirmed, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActionBeliefsTable extends ActionBeliefs
    with TableInfo<$ActionBeliefsTable, ActionBeliefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActionBeliefsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<ActionKind, String> actionKind =
      GeneratedColumn<String>(
        'action_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionKind>($ActionBeliefsTable.$converteractionKind);
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beliefIdMeta = const VerificationMeta(
    'beliefId',
  );
  @override
  late final GeneratedColumn<String> beliefId = GeneratedColumn<String>(
    'belief_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES beliefs (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ActionAlignment, String>
  alignment = GeneratedColumn<String>(
    'alignment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ActionAlignment>($ActionBeliefsTable.$converteralignment);
  @override
  late final GeneratedColumnWithTypeConverter<LinkOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LinkOrigin>($ActionBeliefsTable.$converterorigin);
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    actionKind,
    actionId,
    beliefId,
    alignment,
    origin,
    confidence,
    source,
    confirmed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'action_beliefs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActionBeliefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('belief_id')) {
      context.handle(
        _beliefIdMeta,
        beliefId.isAcceptableOrUnknown(data['belief_id']!, _beliefIdMeta),
      );
    } else if (isInserting) {
      context.missing(_beliefIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {actionKind, actionId, beliefId};
  @override
  ActionBeliefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActionBeliefRow(
      actionKind: $ActionBeliefsTable.$converteractionKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action_kind'],
        )!,
      ),
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      beliefId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}belief_id'],
      )!,
      alignment: $ActionBeliefsTable.$converteralignment.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}alignment'],
        )!,
      ),
      origin: $ActionBeliefsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ActionBeliefsTable createAlias(String alias) {
    return $ActionBeliefsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionKind, String, String> $converteractionKind =
      const EnumNameConverter<ActionKind>(ActionKind.values);
  static JsonTypeConverter2<ActionAlignment, String, String>
  $converteralignment = const EnumNameConverter<ActionAlignment>(
    ActionAlignment.values,
  );
  static JsonTypeConverter2<LinkOrigin, String, String> $converterorigin =
      const EnumNameConverter<LinkOrigin>(LinkOrigin.values);
}

class ActionBeliefRow extends DataClass implements Insertable<ActionBeliefRow> {
  final ActionKind actionKind;
  final String actionId;
  final String beliefId;
  final ActionAlignment alignment;
  final LinkOrigin origin;
  final double? confidence;
  final String? source;
  final bool confirmed;
  final DateTime createdAt;
  const ActionBeliefRow({
    required this.actionKind,
    required this.actionId,
    required this.beliefId,
    required this.alignment,
    required this.origin,
    this.confidence,
    this.source,
    required this.confirmed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['action_kind'] = Variable<String>(
        $ActionBeliefsTable.$converteractionKind.toSql(actionKind),
      );
    }
    map['action_id'] = Variable<String>(actionId);
    map['belief_id'] = Variable<String>(beliefId);
    {
      map['alignment'] = Variable<String>(
        $ActionBeliefsTable.$converteralignment.toSql(alignment),
      );
    }
    {
      map['origin'] = Variable<String>(
        $ActionBeliefsTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    map['confirmed'] = Variable<bool>(confirmed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ActionBeliefsCompanion toCompanion(bool nullToAbsent) {
    return ActionBeliefsCompanion(
      actionKind: Value(actionKind),
      actionId: Value(actionId),
      beliefId: Value(beliefId),
      alignment: Value(alignment),
      origin: Value(origin),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      confirmed: Value(confirmed),
      createdAt: Value(createdAt),
    );
  }

  factory ActionBeliefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActionBeliefRow(
      actionKind: $ActionBeliefsTable.$converteractionKind.fromJson(
        serializer.fromJson<String>(json['actionKind']),
      ),
      actionId: serializer.fromJson<String>(json['actionId']),
      beliefId: serializer.fromJson<String>(json['beliefId']),
      alignment: $ActionBeliefsTable.$converteralignment.fromJson(
        serializer.fromJson<String>(json['alignment']),
      ),
      origin: $ActionBeliefsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      confidence: serializer.fromJson<double?>(json['confidence']),
      source: serializer.fromJson<String?>(json['source']),
      confirmed: serializer.fromJson<bool>(json['confirmed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'actionKind': serializer.toJson<String>(
        $ActionBeliefsTable.$converteractionKind.toJson(actionKind),
      ),
      'actionId': serializer.toJson<String>(actionId),
      'beliefId': serializer.toJson<String>(beliefId),
      'alignment': serializer.toJson<String>(
        $ActionBeliefsTable.$converteralignment.toJson(alignment),
      ),
      'origin': serializer.toJson<String>(
        $ActionBeliefsTable.$converterorigin.toJson(origin),
      ),
      'confidence': serializer.toJson<double?>(confidence),
      'source': serializer.toJson<String?>(source),
      'confirmed': serializer.toJson<bool>(confirmed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ActionBeliefRow copyWith({
    ActionKind? actionKind,
    String? actionId,
    String? beliefId,
    ActionAlignment? alignment,
    LinkOrigin? origin,
    Value<double?> confidence = const Value.absent(),
    Value<String?> source = const Value.absent(),
    bool? confirmed,
    DateTime? createdAt,
  }) => ActionBeliefRow(
    actionKind: actionKind ?? this.actionKind,
    actionId: actionId ?? this.actionId,
    beliefId: beliefId ?? this.beliefId,
    alignment: alignment ?? this.alignment,
    origin: origin ?? this.origin,
    confidence: confidence.present ? confidence.value : this.confidence,
    source: source.present ? source.value : this.source,
    confirmed: confirmed ?? this.confirmed,
    createdAt: createdAt ?? this.createdAt,
  );
  ActionBeliefRow copyWithCompanion(ActionBeliefsCompanion data) {
    return ActionBeliefRow(
      actionKind: data.actionKind.present
          ? data.actionKind.value
          : this.actionKind,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      beliefId: data.beliefId.present ? data.beliefId.value : this.beliefId,
      alignment: data.alignment.present ? data.alignment.value : this.alignment,
      origin: data.origin.present ? data.origin.value : this.origin,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      source: data.source.present ? data.source.value : this.source,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActionBeliefRow(')
          ..write('actionKind: $actionKind, ')
          ..write('actionId: $actionId, ')
          ..write('beliefId: $beliefId, ')
          ..write('alignment: $alignment, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    actionKind,
    actionId,
    beliefId,
    alignment,
    origin,
    confidence,
    source,
    confirmed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActionBeliefRow &&
          other.actionKind == this.actionKind &&
          other.actionId == this.actionId &&
          other.beliefId == this.beliefId &&
          other.alignment == this.alignment &&
          other.origin == this.origin &&
          other.confidence == this.confidence &&
          other.source == this.source &&
          other.confirmed == this.confirmed &&
          other.createdAt == this.createdAt);
}

class ActionBeliefsCompanion extends UpdateCompanion<ActionBeliefRow> {
  final Value<ActionKind> actionKind;
  final Value<String> actionId;
  final Value<String> beliefId;
  final Value<ActionAlignment> alignment;
  final Value<LinkOrigin> origin;
  final Value<double?> confidence;
  final Value<String?> source;
  final Value<bool> confirmed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ActionBeliefsCompanion({
    this.actionKind = const Value.absent(),
    this.actionId = const Value.absent(),
    this.beliefId = const Value.absent(),
    this.alignment = const Value.absent(),
    this.origin = const Value.absent(),
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActionBeliefsCompanion.insert({
    required ActionKind actionKind,
    required String actionId,
    required String beliefId,
    required ActionAlignment alignment,
    required LinkOrigin origin,
    this.confidence = const Value.absent(),
    this.source = const Value.absent(),
    this.confirmed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : actionKind = Value(actionKind),
       actionId = Value(actionId),
       beliefId = Value(beliefId),
       alignment = Value(alignment),
       origin = Value(origin),
       createdAt = Value(createdAt);
  static Insertable<ActionBeliefRow> custom({
    Expression<String>? actionKind,
    Expression<String>? actionId,
    Expression<String>? beliefId,
    Expression<String>? alignment,
    Expression<String>? origin,
    Expression<double>? confidence,
    Expression<String>? source,
    Expression<bool>? confirmed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (actionKind != null) 'action_kind': actionKind,
      if (actionId != null) 'action_id': actionId,
      if (beliefId != null) 'belief_id': beliefId,
      if (alignment != null) 'alignment': alignment,
      if (origin != null) 'origin': origin,
      if (confidence != null) 'confidence': confidence,
      if (source != null) 'source': source,
      if (confirmed != null) 'confirmed': confirmed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActionBeliefsCompanion copyWith({
    Value<ActionKind>? actionKind,
    Value<String>? actionId,
    Value<String>? beliefId,
    Value<ActionAlignment>? alignment,
    Value<LinkOrigin>? origin,
    Value<double?>? confidence,
    Value<String?>? source,
    Value<bool>? confirmed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ActionBeliefsCompanion(
      actionKind: actionKind ?? this.actionKind,
      actionId: actionId ?? this.actionId,
      beliefId: beliefId ?? this.beliefId,
      alignment: alignment ?? this.alignment,
      origin: origin ?? this.origin,
      confidence: confidence ?? this.confidence,
      source: source ?? this.source,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (actionKind.present) {
      map['action_kind'] = Variable<String>(
        $ActionBeliefsTable.$converteractionKind.toSql(actionKind.value),
      );
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (beliefId.present) {
      map['belief_id'] = Variable<String>(beliefId.value);
    }
    if (alignment.present) {
      map['alignment'] = Variable<String>(
        $ActionBeliefsTable.$converteralignment.toSql(alignment.value),
      );
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $ActionBeliefsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActionBeliefsCompanion(')
          ..write('actionKind: $actionKind, ')
          ..write('actionId: $actionId, ')
          ..write('beliefId: $beliefId, ')
          ..write('alignment: $alignment, ')
          ..write('origin: $origin, ')
          ..write('confidence: $confidence, ')
          ..write('source: $source, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SharedLabelsTable extends SharedLabels
    with TableInfo<$SharedLabelsTable, SharedLabelRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SharedLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isGoldMeta = const VerificationMeta('isGold');
  @override
  late final GeneratedColumn<bool> isGold = GeneratedColumn<bool>(
    'is_gold',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_gold" IN (0, 1))',
    ),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  @override
  late final GeneratedColumn<DateTime> answeredAt = GeneratedColumn<DateTime>(
    'answered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    label,
    isGold,
    correct,
    durationMs,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shared_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<SharedLabelRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('is_gold')) {
      context.handle(
        _isGoldMeta,
        isGold.isAcceptableOrUnknown(data['is_gold']!, _isGoldMeta),
      );
    } else if (isInserting) {
      context.missing(_isGoldMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_answeredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  SharedLabelRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SharedLabelRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      isGold: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_gold'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}answered_at'],
      )!,
    );
  }

  @override
  $SharedLabelsTable createAlias(String alias) {
    return $SharedLabelsTable(attachedDatabase, alias);
  }
}

class SharedLabelRow extends DataClass implements Insertable<SharedLabelRow> {
  final String itemId;
  final String label;
  final bool isGold;

  /// Solo ítems de oro: si coincidió con la respuesta conocida.
  final bool? correct;
  final int durationMs;
  final DateTime answeredAt;
  const SharedLabelRow({
    required this.itemId,
    required this.label,
    required this.isGold,
    this.correct,
    required this.durationMs,
    required this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['label'] = Variable<String>(label);
    map['is_gold'] = Variable<bool>(isGold);
    if (!nullToAbsent || correct != null) {
      map['correct'] = Variable<bool>(correct);
    }
    map['duration_ms'] = Variable<int>(durationMs);
    map['answered_at'] = Variable<DateTime>(answeredAt);
    return map;
  }

  SharedLabelsCompanion toCompanion(bool nullToAbsent) {
    return SharedLabelsCompanion(
      itemId: Value(itemId),
      label: Value(label),
      isGold: Value(isGold),
      correct: correct == null && nullToAbsent
          ? const Value.absent()
          : Value(correct),
      durationMs: Value(durationMs),
      answeredAt: Value(answeredAt),
    );
  }

  factory SharedLabelRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SharedLabelRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      label: serializer.fromJson<String>(json['label']),
      isGold: serializer.fromJson<bool>(json['isGold']),
      correct: serializer.fromJson<bool?>(json['correct']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      answeredAt: serializer.fromJson<DateTime>(json['answeredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'label': serializer.toJson<String>(label),
      'isGold': serializer.toJson<bool>(isGold),
      'correct': serializer.toJson<bool?>(correct),
      'durationMs': serializer.toJson<int>(durationMs),
      'answeredAt': serializer.toJson<DateTime>(answeredAt),
    };
  }

  SharedLabelRow copyWith({
    String? itemId,
    String? label,
    bool? isGold,
    Value<bool?> correct = const Value.absent(),
    int? durationMs,
    DateTime? answeredAt,
  }) => SharedLabelRow(
    itemId: itemId ?? this.itemId,
    label: label ?? this.label,
    isGold: isGold ?? this.isGold,
    correct: correct.present ? correct.value : this.correct,
    durationMs: durationMs ?? this.durationMs,
    answeredAt: answeredAt ?? this.answeredAt,
  );
  SharedLabelRow copyWithCompanion(SharedLabelsCompanion data) {
    return SharedLabelRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      label: data.label.present ? data.label.value : this.label,
      isGold: data.isGold.present ? data.isGold.value : this.isGold,
      correct: data.correct.present ? data.correct.value : this.correct,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SharedLabelRow(')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('isGold: $isGold, ')
          ..write('correct: $correct, ')
          ..write('durationMs: $durationMs, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(itemId, label, isGold, correct, durationMs, answeredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SharedLabelRow &&
          other.itemId == this.itemId &&
          other.label == this.label &&
          other.isGold == this.isGold &&
          other.correct == this.correct &&
          other.durationMs == this.durationMs &&
          other.answeredAt == this.answeredAt);
}

class SharedLabelsCompanion extends UpdateCompanion<SharedLabelRow> {
  final Value<String> itemId;
  final Value<String> label;
  final Value<bool> isGold;
  final Value<bool?> correct;
  final Value<int> durationMs;
  final Value<DateTime> answeredAt;
  final Value<int> rowid;
  const SharedLabelsCompanion({
    this.itemId = const Value.absent(),
    this.label = const Value.absent(),
    this.isGold = const Value.absent(),
    this.correct = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SharedLabelsCompanion.insert({
    required String itemId,
    required String label,
    required bool isGold,
    this.correct = const Value.absent(),
    required int durationMs,
    required DateTime answeredAt,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       label = Value(label),
       isGold = Value(isGold),
       durationMs = Value(durationMs),
       answeredAt = Value(answeredAt);
  static Insertable<SharedLabelRow> custom({
    Expression<String>? itemId,
    Expression<String>? label,
    Expression<bool>? isGold,
    Expression<bool>? correct,
    Expression<int>? durationMs,
    Expression<DateTime>? answeredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (label != null) 'label': label,
      if (isGold != null) 'is_gold': isGold,
      if (correct != null) 'correct': correct,
      if (durationMs != null) 'duration_ms': durationMs,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SharedLabelsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? label,
    Value<bool>? isGold,
    Value<bool?>? correct,
    Value<int>? durationMs,
    Value<DateTime>? answeredAt,
    Value<int>? rowid,
  }) {
    return SharedLabelsCompanion(
      itemId: itemId ?? this.itemId,
      label: label ?? this.label,
      isGold: isGold ?? this.isGold,
      correct: correct ?? this.correct,
      durationMs: durationMs ?? this.durationMs,
      answeredAt: answeredAt ?? this.answeredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (isGold.present) {
      map['is_gold'] = Variable<bool>(isGold.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<DateTime>(answeredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SharedLabelsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('label: $label, ')
          ..write('isGold: $isGold, ')
          ..write('correct: $correct, ')
          ..write('durationMs: $durationMs, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThoughtPatternsTable extends ThoughtPatterns
    with TableInfo<$ThoughtPatternsTable, ThoughtPatternRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThoughtPatternsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<ActionKind, String> actionKind =
      GeneratedColumn<String>(
        'action_kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ActionKind>($ThoughtPatternsTable.$converteractionKind);
  static const VerificationMeta _actionIdMeta = const VerificationMeta(
    'actionId',
  );
  @override
  late final GeneratedColumn<String> actionId = GeneratedColumn<String>(
    'action_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prototypeIdMeta = const VerificationMeta(
    'prototypeId',
  );
  @override
  late final GeneratedColumn<String> prototypeId = GeneratedColumn<String>(
    'prototype_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _similarityMeta = const VerificationMeta(
    'similarity',
  );
  @override
  late final GeneratedColumn<double> similarity = GeneratedColumn<double>(
    'similarity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confirmedMeta = const VerificationMeta(
    'confirmed',
  );
  @override
  late final GeneratedColumn<bool> confirmed = GeneratedColumn<bool>(
    'confirmed',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    actionKind,
    actionId,
    prototypeId,
    similarity,
    modelVersion,
    confirmed,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'thought_patterns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThoughtPatternRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('action_id')) {
      context.handle(
        _actionIdMeta,
        actionId.isAcceptableOrUnknown(data['action_id']!, _actionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actionIdMeta);
    }
    if (data.containsKey('prototype_id')) {
      context.handle(
        _prototypeIdMeta,
        prototypeId.isAcceptableOrUnknown(
          data['prototype_id']!,
          _prototypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_prototypeIdMeta);
    }
    if (data.containsKey('similarity')) {
      context.handle(
        _similarityMeta,
        similarity.isAcceptableOrUnknown(data['similarity']!, _similarityMeta),
      );
    } else if (isInserting) {
      context.missing(_similarityMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('confirmed')) {
      context.handle(
        _confirmedMeta,
        confirmed.isAcceptableOrUnknown(data['confirmed']!, _confirmedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {actionKind, actionId};
  @override
  ThoughtPatternRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThoughtPatternRow(
      actionKind: $ThoughtPatternsTable.$converteractionKind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action_kind'],
        )!,
      ),
      actionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_id'],
      )!,
      prototypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prototype_id'],
      )!,
      similarity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}similarity'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      confirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ThoughtPatternsTable createAlias(String alias) {
    return $ThoughtPatternsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ActionKind, String, String> $converteractionKind =
      const EnumNameConverter<ActionKind>(ActionKind.values);
}

class ThoughtPatternRow extends DataClass
    implements Insertable<ThoughtPatternRow> {
  final ActionKind actionKind;
  final String actionId;
  final String prototypeId;
  final double similarity;
  final String modelVersion;

  /// null: pendiente; true/false: el usuario confirmó o rechazó.
  final bool? confirmed;
  final DateTime createdAt;
  const ThoughtPatternRow({
    required this.actionKind,
    required this.actionId,
    required this.prototypeId,
    required this.similarity,
    required this.modelVersion,
    this.confirmed,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['action_kind'] = Variable<String>(
        $ThoughtPatternsTable.$converteractionKind.toSql(actionKind),
      );
    }
    map['action_id'] = Variable<String>(actionId);
    map['prototype_id'] = Variable<String>(prototypeId);
    map['similarity'] = Variable<double>(similarity);
    map['model_version'] = Variable<String>(modelVersion);
    if (!nullToAbsent || confirmed != null) {
      map['confirmed'] = Variable<bool>(confirmed);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ThoughtPatternsCompanion toCompanion(bool nullToAbsent) {
    return ThoughtPatternsCompanion(
      actionKind: Value(actionKind),
      actionId: Value(actionId),
      prototypeId: Value(prototypeId),
      similarity: Value(similarity),
      modelVersion: Value(modelVersion),
      confirmed: confirmed == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmed),
      createdAt: Value(createdAt),
    );
  }

  factory ThoughtPatternRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThoughtPatternRow(
      actionKind: $ThoughtPatternsTable.$converteractionKind.fromJson(
        serializer.fromJson<String>(json['actionKind']),
      ),
      actionId: serializer.fromJson<String>(json['actionId']),
      prototypeId: serializer.fromJson<String>(json['prototypeId']),
      similarity: serializer.fromJson<double>(json['similarity']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      confirmed: serializer.fromJson<bool?>(json['confirmed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'actionKind': serializer.toJson<String>(
        $ThoughtPatternsTable.$converteractionKind.toJson(actionKind),
      ),
      'actionId': serializer.toJson<String>(actionId),
      'prototypeId': serializer.toJson<String>(prototypeId),
      'similarity': serializer.toJson<double>(similarity),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'confirmed': serializer.toJson<bool?>(confirmed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ThoughtPatternRow copyWith({
    ActionKind? actionKind,
    String? actionId,
    String? prototypeId,
    double? similarity,
    String? modelVersion,
    Value<bool?> confirmed = const Value.absent(),
    DateTime? createdAt,
  }) => ThoughtPatternRow(
    actionKind: actionKind ?? this.actionKind,
    actionId: actionId ?? this.actionId,
    prototypeId: prototypeId ?? this.prototypeId,
    similarity: similarity ?? this.similarity,
    modelVersion: modelVersion ?? this.modelVersion,
    confirmed: confirmed.present ? confirmed.value : this.confirmed,
    createdAt: createdAt ?? this.createdAt,
  );
  ThoughtPatternRow copyWithCompanion(ThoughtPatternsCompanion data) {
    return ThoughtPatternRow(
      actionKind: data.actionKind.present
          ? data.actionKind.value
          : this.actionKind,
      actionId: data.actionId.present ? data.actionId.value : this.actionId,
      prototypeId: data.prototypeId.present
          ? data.prototypeId.value
          : this.prototypeId,
      similarity: data.similarity.present
          ? data.similarity.value
          : this.similarity,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      confirmed: data.confirmed.present ? data.confirmed.value : this.confirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThoughtPatternRow(')
          ..write('actionKind: $actionKind, ')
          ..write('actionId: $actionId, ')
          ..write('prototypeId: $prototypeId, ')
          ..write('similarity: $similarity, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    actionKind,
    actionId,
    prototypeId,
    similarity,
    modelVersion,
    confirmed,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThoughtPatternRow &&
          other.actionKind == this.actionKind &&
          other.actionId == this.actionId &&
          other.prototypeId == this.prototypeId &&
          other.similarity == this.similarity &&
          other.modelVersion == this.modelVersion &&
          other.confirmed == this.confirmed &&
          other.createdAt == this.createdAt);
}

class ThoughtPatternsCompanion extends UpdateCompanion<ThoughtPatternRow> {
  final Value<ActionKind> actionKind;
  final Value<String> actionId;
  final Value<String> prototypeId;
  final Value<double> similarity;
  final Value<String> modelVersion;
  final Value<bool?> confirmed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ThoughtPatternsCompanion({
    this.actionKind = const Value.absent(),
    this.actionId = const Value.absent(),
    this.prototypeId = const Value.absent(),
    this.similarity = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.confirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThoughtPatternsCompanion.insert({
    required ActionKind actionKind,
    required String actionId,
    required String prototypeId,
    required double similarity,
    required String modelVersion,
    this.confirmed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : actionKind = Value(actionKind),
       actionId = Value(actionId),
       prototypeId = Value(prototypeId),
       similarity = Value(similarity),
       modelVersion = Value(modelVersion),
       createdAt = Value(createdAt);
  static Insertable<ThoughtPatternRow> custom({
    Expression<String>? actionKind,
    Expression<String>? actionId,
    Expression<String>? prototypeId,
    Expression<double>? similarity,
    Expression<String>? modelVersion,
    Expression<bool>? confirmed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (actionKind != null) 'action_kind': actionKind,
      if (actionId != null) 'action_id': actionId,
      if (prototypeId != null) 'prototype_id': prototypeId,
      if (similarity != null) 'similarity': similarity,
      if (modelVersion != null) 'model_version': modelVersion,
      if (confirmed != null) 'confirmed': confirmed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThoughtPatternsCompanion copyWith({
    Value<ActionKind>? actionKind,
    Value<String>? actionId,
    Value<String>? prototypeId,
    Value<double>? similarity,
    Value<String>? modelVersion,
    Value<bool?>? confirmed,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ThoughtPatternsCompanion(
      actionKind: actionKind ?? this.actionKind,
      actionId: actionId ?? this.actionId,
      prototypeId: prototypeId ?? this.prototypeId,
      similarity: similarity ?? this.similarity,
      modelVersion: modelVersion ?? this.modelVersion,
      confirmed: confirmed ?? this.confirmed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (actionKind.present) {
      map['action_kind'] = Variable<String>(
        $ThoughtPatternsTable.$converteractionKind.toSql(actionKind.value),
      );
    }
    if (actionId.present) {
      map['action_id'] = Variable<String>(actionId.value);
    }
    if (prototypeId.present) {
      map['prototype_id'] = Variable<String>(prototypeId.value);
    }
    if (similarity.present) {
      map['similarity'] = Variable<double>(similarity.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (confirmed.present) {
      map['confirmed'] = Variable<bool>(confirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThoughtPatternsCompanion(')
          ..write('actionKind: $actionKind, ')
          ..write('actionId: $actionId, ')
          ..write('prototypeId: $prototypeId, ')
          ..write('similarity: $similarity, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('confirmed: $confirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JudgeFeedbackTable extends JudgeFeedback
    with TableInfo<$JudgeFeedbackTable, JudgeFeedbackRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JudgeFeedbackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _judgeVersionMeta = const VerificationMeta(
    'judgeVersion',
  );
  @override
  late final GeneratedColumn<String> judgeVersion = GeneratedColumn<String>(
    'judge_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskMeta = const VerificationMeta('task');
  @override
  late final GeneratedColumn<String> task = GeneratedColumn<String>(
    'task',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _predictedMeta = const VerificationMeta(
    'predicted',
  );
  @override
  late final GeneratedColumn<String> predicted = GeneratedColumn<String>(
    'predicted',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _probabilityMeta = const VerificationMeta(
    'probability',
  );
  @override
  late final GeneratedColumn<double> probability = GeneratedColumn<double>(
    'probability',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userLabelMeta = const VerificationMeta(
    'userLabel',
  );
  @override
  late final GeneratedColumn<String> userLabel = GeneratedColumn<String>(
    'user_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    judgeVersion,
    task,
    predicted,
    probability,
    userLabel,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'judge_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<JudgeFeedbackRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('judge_version')) {
      context.handle(
        _judgeVersionMeta,
        judgeVersion.isAcceptableOrUnknown(
          data['judge_version']!,
          _judgeVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_judgeVersionMeta);
    }
    if (data.containsKey('task')) {
      context.handle(
        _taskMeta,
        task.isAcceptableOrUnknown(data['task']!, _taskMeta),
      );
    } else if (isInserting) {
      context.missing(_taskMeta);
    }
    if (data.containsKey('predicted')) {
      context.handle(
        _predictedMeta,
        predicted.isAcceptableOrUnknown(data['predicted']!, _predictedMeta),
      );
    } else if (isInserting) {
      context.missing(_predictedMeta);
    }
    if (data.containsKey('probability')) {
      context.handle(
        _probabilityMeta,
        probability.isAcceptableOrUnknown(
          data['probability']!,
          _probabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_probabilityMeta);
    }
    if (data.containsKey('user_label')) {
      context.handle(
        _userLabelMeta,
        userLabel.isAcceptableOrUnknown(data['user_label']!, _userLabelMeta),
      );
    } else if (isInserting) {
      context.missing(_userLabelMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JudgeFeedbackRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JudgeFeedbackRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      judgeVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}judge_version'],
      )!,
      task: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task'],
      )!,
      predicted: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}predicted'],
      )!,
      probability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}probability'],
      )!,
      userLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_label'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $JudgeFeedbackTable createAlias(String alias) {
    return $JudgeFeedbackTable(attachedDatabase, alias);
  }
}

class JudgeFeedbackRow extends DataClass
    implements Insertable<JudgeFeedbackRow> {
  final String id;
  final String judgeVersion;

  /// 'nli' | 'alineacion' | 'patron'.
  final String task;
  final String predicted;
  final double probability;
  final String userLabel;
  final DateTime createdAt;
  const JudgeFeedbackRow({
    required this.id,
    required this.judgeVersion,
    required this.task,
    required this.predicted,
    required this.probability,
    required this.userLabel,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['judge_version'] = Variable<String>(judgeVersion);
    map['task'] = Variable<String>(task);
    map['predicted'] = Variable<String>(predicted);
    map['probability'] = Variable<double>(probability);
    map['user_label'] = Variable<String>(userLabel);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  JudgeFeedbackCompanion toCompanion(bool nullToAbsent) {
    return JudgeFeedbackCompanion(
      id: Value(id),
      judgeVersion: Value(judgeVersion),
      task: Value(task),
      predicted: Value(predicted),
      probability: Value(probability),
      userLabel: Value(userLabel),
      createdAt: Value(createdAt),
    );
  }

  factory JudgeFeedbackRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JudgeFeedbackRow(
      id: serializer.fromJson<String>(json['id']),
      judgeVersion: serializer.fromJson<String>(json['judgeVersion']),
      task: serializer.fromJson<String>(json['task']),
      predicted: serializer.fromJson<String>(json['predicted']),
      probability: serializer.fromJson<double>(json['probability']),
      userLabel: serializer.fromJson<String>(json['userLabel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'judgeVersion': serializer.toJson<String>(judgeVersion),
      'task': serializer.toJson<String>(task),
      'predicted': serializer.toJson<String>(predicted),
      'probability': serializer.toJson<double>(probability),
      'userLabel': serializer.toJson<String>(userLabel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  JudgeFeedbackRow copyWith({
    String? id,
    String? judgeVersion,
    String? task,
    String? predicted,
    double? probability,
    String? userLabel,
    DateTime? createdAt,
  }) => JudgeFeedbackRow(
    id: id ?? this.id,
    judgeVersion: judgeVersion ?? this.judgeVersion,
    task: task ?? this.task,
    predicted: predicted ?? this.predicted,
    probability: probability ?? this.probability,
    userLabel: userLabel ?? this.userLabel,
    createdAt: createdAt ?? this.createdAt,
  );
  JudgeFeedbackRow copyWithCompanion(JudgeFeedbackCompanion data) {
    return JudgeFeedbackRow(
      id: data.id.present ? data.id.value : this.id,
      judgeVersion: data.judgeVersion.present
          ? data.judgeVersion.value
          : this.judgeVersion,
      task: data.task.present ? data.task.value : this.task,
      predicted: data.predicted.present ? data.predicted.value : this.predicted,
      probability: data.probability.present
          ? data.probability.value
          : this.probability,
      userLabel: data.userLabel.present ? data.userLabel.value : this.userLabel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JudgeFeedbackRow(')
          ..write('id: $id, ')
          ..write('judgeVersion: $judgeVersion, ')
          ..write('task: $task, ')
          ..write('predicted: $predicted, ')
          ..write('probability: $probability, ')
          ..write('userLabel: $userLabel, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    judgeVersion,
    task,
    predicted,
    probability,
    userLabel,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JudgeFeedbackRow &&
          other.id == this.id &&
          other.judgeVersion == this.judgeVersion &&
          other.task == this.task &&
          other.predicted == this.predicted &&
          other.probability == this.probability &&
          other.userLabel == this.userLabel &&
          other.createdAt == this.createdAt);
}

class JudgeFeedbackCompanion extends UpdateCompanion<JudgeFeedbackRow> {
  final Value<String> id;
  final Value<String> judgeVersion;
  final Value<String> task;
  final Value<String> predicted;
  final Value<double> probability;
  final Value<String> userLabel;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const JudgeFeedbackCompanion({
    this.id = const Value.absent(),
    this.judgeVersion = const Value.absent(),
    this.task = const Value.absent(),
    this.predicted = const Value.absent(),
    this.probability = const Value.absent(),
    this.userLabel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JudgeFeedbackCompanion.insert({
    required String id,
    required String judgeVersion,
    required String task,
    required String predicted,
    required double probability,
    required String userLabel,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       judgeVersion = Value(judgeVersion),
       task = Value(task),
       predicted = Value(predicted),
       probability = Value(probability),
       userLabel = Value(userLabel),
       createdAt = Value(createdAt);
  static Insertable<JudgeFeedbackRow> custom({
    Expression<String>? id,
    Expression<String>? judgeVersion,
    Expression<String>? task,
    Expression<String>? predicted,
    Expression<double>? probability,
    Expression<String>? userLabel,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (judgeVersion != null) 'judge_version': judgeVersion,
      if (task != null) 'task': task,
      if (predicted != null) 'predicted': predicted,
      if (probability != null) 'probability': probability,
      if (userLabel != null) 'user_label': userLabel,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JudgeFeedbackCompanion copyWith({
    Value<String>? id,
    Value<String>? judgeVersion,
    Value<String>? task,
    Value<String>? predicted,
    Value<double>? probability,
    Value<String>? userLabel,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return JudgeFeedbackCompanion(
      id: id ?? this.id,
      judgeVersion: judgeVersion ?? this.judgeVersion,
      task: task ?? this.task,
      predicted: predicted ?? this.predicted,
      probability: probability ?? this.probability,
      userLabel: userLabel ?? this.userLabel,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (judgeVersion.present) {
      map['judge_version'] = Variable<String>(judgeVersion.value);
    }
    if (task.present) {
      map['task'] = Variable<String>(task.value);
    }
    if (predicted.present) {
      map['predicted'] = Variable<String>(predicted.value);
    }
    if (probability.present) {
      map['probability'] = Variable<double>(probability.value);
    }
    if (userLabel.present) {
      map['user_label'] = Variable<String>(userLabel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JudgeFeedbackCompanion(')
          ..write('id: $id, ')
          ..write('judgeVersion: $judgeVersion, ')
          ..write('task: $task, ')
          ..write('predicted: $predicted, ')
          ..write('probability: $probability, ')
          ..write('userLabel: $userLabel, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DimensionsTable dimensions = $DimensionsTable(this);
  late final $EmotionsTable emotions = $EmotionsTable(this);
  late final $TriggersTable triggers = $TriggersTable(this);
  late final $TopicsTable topics = $TopicsTable(this);
  late final $DevotionalsTable devotionals = $DevotionalsTable(this);
  late final $DevotionalTopicsTable devotionalTopics = $DevotionalTopicsTable(
    this,
  );
  late final $PraxisEntriesTable praxisEntries = $PraxisEntriesTable(this);
  late final $PraxisEmotionsTable praxisEmotions = $PraxisEmotionsTable(this);
  late final $PraxisTriggersTable praxisTriggers = $PraxisTriggersTable(this);
  late final $PraxisTopicsTable praxisTopics = $PraxisTopicsTable(this);
  late final $PrayersTable prayers = $PrayersTable(this);
  late final $PrayerTopicsTable prayerTopics = $PrayerTopicsTable(this);
  late final $PrayerPraxisLinksTable prayerPraxisLinks =
      $PrayerPraxisLinksTable(this);
  late final $AttachmentsTable attachments = $AttachmentsTable(this);
  late final $BeliefsTable beliefs = $BeliefsTable(this);
  late final $BeliefTopicsTable beliefTopics = $BeliefTopicsTable(this);
  late final $BeliefEvidenceTableTable beliefEvidenceTable =
      $BeliefEvidenceTableTable(this);
  late final $ActionBeliefsTable actionBeliefs = $ActionBeliefsTable(this);
  late final $SharedLabelsTable sharedLabels = $SharedLabelsTable(this);
  late final $ThoughtPatternsTable thoughtPatterns = $ThoughtPatternsTable(
    this,
  );
  late final $JudgeFeedbackTable judgeFeedback = $JudgeFeedbackTable(this);
  late final Index devotionalsDate = Index(
    'devotionals_date',
    'CREATE INDEX devotionals_date ON devotionals (date)',
  );
  late final Index devotionalsBook = Index(
    'devotionals_book',
    'CREATE INDEX devotionals_book ON devotionals (book_code)',
  );
  late final Index praxisDate = Index(
    'praxis_date',
    'CREATE INDEX praxis_date ON praxis_entries (date)',
  );
  late final Index attachmentsOwner = Index(
    'attachments_owner',
    'CREATE INDEX attachments_owner ON attachments (owner_type, owner_id)',
  );
  late final Index beliefEvidenceBelief = Index(
    'belief_evidence_belief',
    'CREATE INDEX belief_evidence_belief ON belief_evidence (belief_id)',
  );
  late final Index actionBeliefsBelief = Index(
    'action_beliefs_belief',
    'CREATE INDEX action_beliefs_belief ON action_beliefs (belief_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dimensions,
    emotions,
    triggers,
    topics,
    devotionals,
    devotionalTopics,
    praxisEntries,
    praxisEmotions,
    praxisTriggers,
    praxisTopics,
    prayers,
    prayerTopics,
    prayerPraxisLinks,
    attachments,
    beliefs,
    beliefTopics,
    beliefEvidenceTable,
    actionBeliefs,
    sharedLabels,
    thoughtPatterns,
    judgeFeedback,
    devotionalsDate,
    devotionalsBook,
    praxisDate,
    attachmentsOwner,
    beliefEvidenceBelief,
    actionBeliefsBelief,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devotionals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('devotional_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('devotional_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'praxis_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('praxis_emotions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'praxis_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('praxis_triggers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'praxis_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('praxis_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('praxis_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'prayers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'prayers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_praxis_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'praxis_entries',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('prayer_praxis_links', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'devotionals',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('beliefs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'beliefs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('belief_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('belief_topics', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'beliefs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('belief_evidence', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'beliefs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('action_beliefs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DimensionsTableCreateCompanionBuilder =
    DimensionsCompanion Function({
      required String id,
      required String name,
      required String description,
      required String colorHex,
      required int sortOrder,
      Value<int> rowid,
    });
typedef $$DimensionsTableUpdateCompanionBuilder =
    DimensionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String> colorHex,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$DimensionsTableReferences
    extends BaseReferences<_$AppDatabase, $DimensionsTable, DimensionRow> {
  $$DimensionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TopicsTable, List<TopicRow>> _topicsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.topics,
    aliasName: 'dimensions__id__topics__dimension_id',
  );

  $$TopicsTableProcessedTableManager get topicsRefs {
    final manager = $$TopicsTableTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.dimensionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_topicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BeliefsTable, List<BeliefRow>> _beliefsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.beliefs,
    aliasName: 'dimensions__id__beliefs__dimension_id',
  );

  $$BeliefsTableProcessedTableManager get beliefsRefs {
    final manager = $$BeliefsTableTableManager(
      $_db,
      $_db.beliefs,
    ).filter((f) => f.dimensionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_beliefsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DimensionsTableFilterComposer
    extends Composer<_$AppDatabase, $DimensionsTable> {
  $$DimensionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> topicsRefs(
    Expression<bool> Function($$TopicsTableFilterComposer f) f,
  ) {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.dimensionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> beliefsRefs(
    Expression<bool> Function($$BeliefsTableFilterComposer f) f,
  ) {
    final $$BeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.dimensionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableFilterComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DimensionsTableOrderingComposer
    extends Composer<_$AppDatabase, $DimensionsTable> {
  $$DimensionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DimensionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DimensionsTable> {
  $$DimensionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> topicsRefs<T extends Object>(
    Expression<T> Function($$TopicsTableAnnotationComposer a) f,
  ) {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.dimensionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> beliefsRefs<T extends Object>(
    Expression<T> Function($$BeliefsTableAnnotationComposer a) f,
  ) {
    final $$BeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.dimensionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DimensionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DimensionsTable,
          DimensionRow,
          $$DimensionsTableFilterComposer,
          $$DimensionsTableOrderingComposer,
          $$DimensionsTableAnnotationComposer,
          $$DimensionsTableCreateCompanionBuilder,
          $$DimensionsTableUpdateCompanionBuilder,
          (DimensionRow, $$DimensionsTableReferences),
          DimensionRow,
          PrefetchHooks Function({bool topicsRefs, bool beliefsRefs})
        > {
  $$DimensionsTableTableManager(_$AppDatabase db, $DimensionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DimensionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DimensionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DimensionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DimensionsCompanion(
                id: id,
                name: name,
                description: description,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                required String colorHex,
                required int sortOrder,
                Value<int> rowid = const Value.absent(),
              }) => DimensionsCompanion.insert(
                id: id,
                name: name,
                description: description,
                colorHex: colorHex,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DimensionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicsRefs = false, beliefsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (topicsRefs) db.topics,
                if (beliefsRefs) db.beliefs,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (topicsRefs)
                    await $_getPrefetchedData<
                      DimensionRow,
                      $DimensionsTable,
                      TopicRow
                    >(
                      currentTable: table,
                      referencedTable: $$DimensionsTableReferences
                          ._topicsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DimensionsTableReferences(db, table, p0).topicsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.dimensionId == item.id,
                          ),
                      typedResults: items,
                    ),
                  if (beliefsRefs)
                    await $_getPrefetchedData<
                      DimensionRow,
                      $DimensionsTable,
                      BeliefRow
                    >(
                      currentTable: table,
                      referencedTable: $$DimensionsTableReferences
                          ._beliefsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DimensionsTableReferences(
                            db,
                            table,
                            p0,
                          ).beliefsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.dimensionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DimensionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DimensionsTable,
      DimensionRow,
      $$DimensionsTableFilterComposer,
      $$DimensionsTableOrderingComposer,
      $$DimensionsTableAnnotationComposer,
      $$DimensionsTableCreateCompanionBuilder,
      $$DimensionsTableUpdateCompanionBuilder,
      (DimensionRow, $$DimensionsTableReferences),
      DimensionRow,
      PrefetchHooks Function({bool topicsRefs, bool beliefsRefs})
    >;
typedef $$EmotionsTableCreateCompanionBuilder =
    EmotionsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<bool> isSystem,
      Value<int> rowid,
    });
typedef $$EmotionsTableUpdateCompanionBuilder =
    EmotionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<bool> isSystem,
      Value<int> rowid,
    });

final class $$EmotionsTableReferences
    extends BaseReferences<_$AppDatabase, $EmotionsTable, EmotionRow> {
  $$EmotionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EmotionsTable _parentIdTable(_$AppDatabase db) =>
      db.emotions.createAlias('emotions__parent_id__emotions__id');

  $$EmotionsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$EmotionsTableTableManager(
      $_db,
      $_db.emotions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PraxisEmotionsTable, List<PraxisEmotion>>
  _praxisEmotionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisEmotions,
    aliasName: 'emotions__id__praxis_emotions__emotion_id',
  );

  $$PraxisEmotionsTableProcessedTableManager get praxisEmotionsRefs {
    final manager = $$PraxisEmotionsTableTableManager(
      $_db,
      $_db.praxisEmotions,
    ).filter((f) => f.emotionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisEmotionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmotionsTableFilterComposer
    extends Composer<_$AppDatabase, $EmotionsTable> {
  $$EmotionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  $$EmotionsTableFilterComposer get parentId {
    final $$EmotionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableFilterComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> praxisEmotionsRefs(
    Expression<bool> Function($$PraxisEmotionsTableFilterComposer f) f,
  ) {
    final $$PraxisEmotionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisEmotions,
      getReferencedColumn: (t) => t.emotionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEmotionsTableFilterComposer(
            $db: $db,
            $table: $db.praxisEmotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmotionsTableOrderingComposer
    extends Composer<_$AppDatabase, $EmotionsTable> {
  $$EmotionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmotionsTableOrderingComposer get parentId {
    final $$EmotionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableOrderingComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EmotionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmotionsTable> {
  $$EmotionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  $$EmotionsTableAnnotationComposer get parentId {
    final $$EmotionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableAnnotationComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> praxisEmotionsRefs<T extends Object>(
    Expression<T> Function($$PraxisEmotionsTableAnnotationComposer a) f,
  ) {
    final $$PraxisEmotionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisEmotions,
      getReferencedColumn: (t) => t.emotionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEmotionsTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEmotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmotionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmotionsTable,
          EmotionRow,
          $$EmotionsTableFilterComposer,
          $$EmotionsTableOrderingComposer,
          $$EmotionsTableAnnotationComposer,
          $$EmotionsTableCreateCompanionBuilder,
          $$EmotionsTableUpdateCompanionBuilder,
          (EmotionRow, $$EmotionsTableReferences),
          EmotionRow,
          PrefetchHooks Function({bool parentId, bool praxisEmotionsRefs})
        > {
  $$EmotionsTableTableManager(_$AppDatabase db, $EmotionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmotionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmotionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmotionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmotionsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                isSystem: isSystem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmotionsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                isSystem: isSystem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EmotionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentId = false, praxisEmotionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (praxisEmotionsRefs) db.praxisEmotions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.parentId,
                                    referencedTable: $$EmotionsTableReferences
                                        ._parentIdTable(db),
                                    referencedColumn: $$EmotionsTableReferences
                                        ._parentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (praxisEmotionsRefs)
                        await $_getPrefetchedData<
                          EmotionRow,
                          $EmotionsTable,
                          PraxisEmotion
                        >(
                          currentTable: table,
                          referencedTable: $$EmotionsTableReferences
                              ._praxisEmotionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EmotionsTableReferences(
                                db,
                                table,
                                p0,
                              ).praxisEmotionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.emotionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EmotionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmotionsTable,
      EmotionRow,
      $$EmotionsTableFilterComposer,
      $$EmotionsTableOrderingComposer,
      $$EmotionsTableAnnotationComposer,
      $$EmotionsTableCreateCompanionBuilder,
      $$EmotionsTableUpdateCompanionBuilder,
      (EmotionRow, $$EmotionsTableReferences),
      EmotionRow,
      PrefetchHooks Function({bool parentId, bool praxisEmotionsRefs})
    >;
typedef $$TriggersTableCreateCompanionBuilder =
    TriggersCompanion Function({
      required String id,
      required String name,
      Value<bool> isSystem,
      Value<int> rowid,
    });
typedef $$TriggersTableUpdateCompanionBuilder =
    TriggersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isSystem,
      Value<int> rowid,
    });

final class $$TriggersTableReferences
    extends BaseReferences<_$AppDatabase, $TriggersTable, TriggerRow> {
  $$TriggersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PraxisTriggersTable, List<PraxisTrigger>>
  _praxisTriggersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisTriggers,
    aliasName: 'triggers__id__praxis_triggers__trigger_id',
  );

  $$PraxisTriggersTableProcessedTableManager get praxisTriggersRefs {
    final manager = $$PraxisTriggersTableTableManager(
      $_db,
      $_db.praxisTriggers,
    ).filter((f) => f.triggerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisTriggersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TriggersTableFilterComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> praxisTriggersRefs(
    Expression<bool> Function($$PraxisTriggersTableFilterComposer f) f,
  ) {
    final $$PraxisTriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTriggers,
      getReferencedColumn: (t) => t.triggerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTriggersTableFilterComposer(
            $db: $db,
            $table: $db.praxisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TriggersTableOrderingComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TriggersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TriggersTable> {
  $$TriggersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  Expression<T> praxisTriggersRefs<T extends Object>(
    Expression<T> Function($$PraxisTriggersTableAnnotationComposer a) f,
  ) {
    final $$PraxisTriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTriggers,
      getReferencedColumn: (t) => t.triggerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TriggersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TriggersTable,
          TriggerRow,
          $$TriggersTableFilterComposer,
          $$TriggersTableOrderingComposer,
          $$TriggersTableAnnotationComposer,
          $$TriggersTableCreateCompanionBuilder,
          $$TriggersTableUpdateCompanionBuilder,
          (TriggerRow, $$TriggersTableReferences),
          TriggerRow,
          PrefetchHooks Function({bool praxisTriggersRefs})
        > {
  $$TriggersTableTableManager(_$AppDatabase db, $TriggersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TriggersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TriggersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TriggersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriggersCompanion(
                id: id,
                name: name,
                isSystem: isSystem,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isSystem = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TriggersCompanion.insert(
                id: id,
                name: name,
                isSystem: isSystem,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TriggersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({praxisTriggersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (praxisTriggersRefs) db.praxisTriggers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (praxisTriggersRefs)
                    await $_getPrefetchedData<
                      TriggerRow,
                      $TriggersTable,
                      PraxisTrigger
                    >(
                      currentTable: table,
                      referencedTable: $$TriggersTableReferences
                          ._praxisTriggersRefsTable(db),
                      managerFromTypedResult: (p0) => $$TriggersTableReferences(
                        db,
                        table,
                        p0,
                      ).praxisTriggersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.triggerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TriggersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TriggersTable,
      TriggerRow,
      $$TriggersTableFilterComposer,
      $$TriggersTableOrderingComposer,
      $$TriggersTableAnnotationComposer,
      $$TriggersTableCreateCompanionBuilder,
      $$TriggersTableUpdateCompanionBuilder,
      (TriggerRow, $$TriggersTableReferences),
      TriggerRow,
      PrefetchHooks Function({bool praxisTriggersRefs})
    >;
typedef $$TopicsTableCreateCompanionBuilder =
    TopicsCompanion Function({
      required String id,
      required String name,
      required String nameKey,
      required String dimensionId,
      required TopicStatus status,
      required TopicOrigin origin,
      Value<double?> confidence,
      Value<String?> note,
      Value<String?> validationPassage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TopicsTableUpdateCompanionBuilder =
    TopicsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> nameKey,
      Value<String> dimensionId,
      Value<TopicStatus> status,
      Value<TopicOrigin> origin,
      Value<double?> confidence,
      Value<String?> note,
      Value<String?> validationPassage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TopicsTableReferences
    extends BaseReferences<_$AppDatabase, $TopicsTable, TopicRow> {
  $$TopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DimensionsTable _dimensionIdTable(_$AppDatabase db) =>
      db.dimensions.createAlias('topics__dimension_id__dimensions__id');

  $$DimensionsTableProcessedTableManager get dimensionId {
    final $_column = $_itemColumn<String>('dimension_id')!;

    final manager = $$DimensionsTableTableManager(
      $_db,
      $_db.dimensions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dimensionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DevotionalTopicsTable, List<DevotionalTopicRow>>
  _devotionalTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.devotionalTopics,
    aliasName: 'topics__id__devotional_topics__topic_id',
  );

  $$DevotionalTopicsTableProcessedTableManager get devotionalTopicsRefs {
    final manager = $$DevotionalTopicsTableTableManager(
      $_db,
      $_db.devotionalTopics,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _devotionalTopicsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PraxisTopicsTable, List<PraxisTopic>>
  _praxisTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisTopics,
    aliasName: 'topics__id__praxis_topics__topic_id',
  );

  $$PraxisTopicsTableProcessedTableManager get praxisTopicsRefs {
    final manager = $$PraxisTopicsTableTableManager(
      $_db,
      $_db.praxisTopics,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrayerTopicsTable, List<PrayerTopic>>
  _prayerTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prayerTopics,
    aliasName: 'topics__id__prayer_topics__topic_id',
  );

  $$PrayerTopicsTableProcessedTableManager get prayerTopicsRefs {
    final manager = $$PrayerTopicsTableTableManager(
      $_db,
      $_db.prayerTopics,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prayerTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BeliefTopicsTable, List<BeliefTopic>>
  _beliefTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.beliefTopics,
    aliasName: 'topics__id__belief_topics__topic_id',
  );

  $$BeliefTopicsTableProcessedTableManager get beliefTopicsRefs {
    final manager = $$BeliefTopicsTableTableManager(
      $_db,
      $_db.beliefTopics,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_beliefTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TopicsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TopicStatus, TopicStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<TopicOrigin, TopicOrigin, String> get origin =>
      $composableBuilder(
        column: $table.origin,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get validationPassage => $composableBuilder(
    column: $table.validationPassage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DimensionsTableFilterComposer get dimensionId {
    final $$DimensionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableFilterComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> devotionalTopicsRefs(
    Expression<bool> Function($$DevotionalTopicsTableFilterComposer f) f,
  ) {
    final $$DevotionalTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devotionalTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalTopicsTableFilterComposer(
            $db: $db,
            $table: $db.devotionalTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> praxisTopicsRefs(
    Expression<bool> Function($$PraxisTopicsTableFilterComposer f) f,
  ) {
    final $$PraxisTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTopicsTableFilterComposer(
            $db: $db,
            $table: $db.praxisTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prayerTopicsRefs(
    Expression<bool> Function($$PrayerTopicsTableFilterComposer f) f,
  ) {
    final $$PrayerTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTopicsTableFilterComposer(
            $db: $db,
            $table: $db.prayerTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> beliefTopicsRefs(
    Expression<bool> Function($$BeliefTopicsTableFilterComposer f) f,
  ) {
    final $$BeliefTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefTopicsTableFilterComposer(
            $db: $db,
            $table: $db.beliefTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get validationPassage => $composableBuilder(
    column: $table.validationPassage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DimensionsTableOrderingComposer get dimensionId {
    final $$DimensionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableOrderingComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TopicStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TopicOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get validationPassage => $composableBuilder(
    column: $table.validationPassage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DimensionsTableAnnotationComposer get dimensionId {
    final $$DimensionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> devotionalTopicsRefs<T extends Object>(
    Expression<T> Function($$DevotionalTopicsTableAnnotationComposer a) f,
  ) {
    final $$DevotionalTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devotionalTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.devotionalTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> praxisTopicsRefs<T extends Object>(
    Expression<T> Function($$PraxisTopicsTableAnnotationComposer a) f,
  ) {
    final $$PraxisTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prayerTopicsRefs<T extends Object>(
    Expression<T> Function($$PrayerTopicsTableAnnotationComposer a) f,
  ) {
    final $$PrayerTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> beliefTopicsRefs<T extends Object>(
    Expression<T> Function($$BeliefTopicsTableAnnotationComposer a) f,
  ) {
    final $$BeliefTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefTopics,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TopicsTable,
          TopicRow,
          $$TopicsTableFilterComposer,
          $$TopicsTableOrderingComposer,
          $$TopicsTableAnnotationComposer,
          $$TopicsTableCreateCompanionBuilder,
          $$TopicsTableUpdateCompanionBuilder,
          (TopicRow, $$TopicsTableReferences),
          TopicRow,
          PrefetchHooks Function({
            bool dimensionId,
            bool devotionalTopicsRefs,
            bool praxisTopicsRefs,
            bool prayerTopicsRefs,
            bool beliefTopicsRefs,
          })
        > {
  $$TopicsTableTableManager(_$AppDatabase db, $TopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> dimensionId = const Value.absent(),
                Value<TopicStatus> status = const Value.absent(),
                Value<TopicOrigin> origin = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> validationPassage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                dimensionId: dimensionId,
                status: status,
                origin: origin,
                confidence: confidence,
                note: note,
                validationPassage: validationPassage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String nameKey,
                required String dimensionId,
                required TopicStatus status,
                required TopicOrigin origin,
                Value<double?> confidence = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> validationPassage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                dimensionId: dimensionId,
                status: status,
                origin: origin,
                confidence: confidence,
                note: note,
                validationPassage: validationPassage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TopicsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dimensionId = false,
                devotionalTopicsRefs = false,
                praxisTopicsRefs = false,
                prayerTopicsRefs = false,
                beliefTopicsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (devotionalTopicsRefs) db.devotionalTopics,
                    if (praxisTopicsRefs) db.praxisTopics,
                    if (prayerTopicsRefs) db.prayerTopics,
                    if (beliefTopicsRefs) db.beliefTopics,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (dimensionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dimensionId,
                                    referencedTable: $$TopicsTableReferences
                                        ._dimensionIdTable(db),
                                    referencedColumn: $$TopicsTableReferences
                                        ._dimensionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (devotionalTopicsRefs)
                        await $_getPrefetchedData<
                          TopicRow,
                          $TopicsTable,
                          DevotionalTopicRow
                        >(
                          currentTable: table,
                          referencedTable: $$TopicsTableReferences
                              ._devotionalTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicsTableReferences(
                                db,
                                table,
                                p0,
                              ).devotionalTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (praxisTopicsRefs)
                        await $_getPrefetchedData<
                          TopicRow,
                          $TopicsTable,
                          PraxisTopic
                        >(
                          currentTable: table,
                          referencedTable: $$TopicsTableReferences
                              ._praxisTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicsTableReferences(
                                db,
                                table,
                                p0,
                              ).praxisTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prayerTopicsRefs)
                        await $_getPrefetchedData<
                          TopicRow,
                          $TopicsTable,
                          PrayerTopic
                        >(
                          currentTable: table,
                          referencedTable: $$TopicsTableReferences
                              ._prayerTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicsTableReferences(
                                db,
                                table,
                                p0,
                              ).prayerTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (beliefTopicsRefs)
                        await $_getPrefetchedData<
                          TopicRow,
                          $TopicsTable,
                          BeliefTopic
                        >(
                          currentTable: table,
                          referencedTable: $$TopicsTableReferences
                              ._beliefTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TopicsTableReferences(
                                db,
                                table,
                                p0,
                              ).beliefTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TopicsTable,
      TopicRow,
      $$TopicsTableFilterComposer,
      $$TopicsTableOrderingComposer,
      $$TopicsTableAnnotationComposer,
      $$TopicsTableCreateCompanionBuilder,
      $$TopicsTableUpdateCompanionBuilder,
      (TopicRow, $$TopicsTableReferences),
      TopicRow,
      PrefetchHooks Function({
        bool dimensionId,
        bool devotionalTopicsRefs,
        bool praxisTopicsRefs,
        bool prayerTopicsRefs,
        bool beliefTopicsRefs,
      })
    >;
typedef $$DevotionalsTableCreateCompanionBuilder =
    DevotionalsCompanion Function({
      required String id,
      required DateTime date,
      required String bookCode,
      required int chapter,
      Value<int?> verseStart,
      Value<int?> verseEnd,
      required String content,
      Value<String?> title,
      Value<String?> keyVerse,
      Value<String?> periodId,
      Value<String?> empireId,
      Value<String?> regionId,
      Value<String?> author,
      Value<int?> approxYear,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DevotionalsTableUpdateCompanionBuilder =
    DevotionalsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> bookCode,
      Value<int> chapter,
      Value<int?> verseStart,
      Value<int?> verseEnd,
      Value<String> content,
      Value<String?> title,
      Value<String?> keyVerse,
      Value<String?> periodId,
      Value<String?> empireId,
      Value<String?> regionId,
      Value<String?> author,
      Value<int?> approxYear,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DevotionalsTableReferences
    extends BaseReferences<_$AppDatabase, $DevotionalsTable, DevotionalRow> {
  $$DevotionalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DevotionalTopicsTable, List<DevotionalTopicRow>>
  _devotionalTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.devotionalTopics,
    aliasName: 'devotionals__id__devotional_topics__devotional_id',
  );

  $$DevotionalTopicsTableProcessedTableManager get devotionalTopicsRefs {
    final manager = $$DevotionalTopicsTableTableManager(
      $_db,
      $_db.devotionalTopics,
    ).filter((f) => f.devotionalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _devotionalTopicsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BeliefsTable, List<BeliefRow>> _beliefsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.beliefs,
    aliasName: 'devotionals__id__beliefs__devotional_id',
  );

  $$BeliefsTableProcessedTableManager get beliefsRefs {
    final manager = $$BeliefsTableTableManager(
      $_db,
      $_db.beliefs,
    ).filter((f) => f.devotionalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_beliefsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevotionalsTableFilterComposer
    extends Composer<_$AppDatabase, $DevotionalsTable> {
  $$DevotionalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseEnd => $composableBuilder(
    column: $table.verseEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyVerse => $composableBuilder(
    column: $table.keyVerse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodId => $composableBuilder(
    column: $table.periodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get empireId => $composableBuilder(
    column: $table.empireId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get approxYear => $composableBuilder(
    column: $table.approxYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> devotionalTopicsRefs(
    Expression<bool> Function($$DevotionalTopicsTableFilterComposer f) f,
  ) {
    final $$DevotionalTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devotionalTopics,
      getReferencedColumn: (t) => t.devotionalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalTopicsTableFilterComposer(
            $db: $db,
            $table: $db.devotionalTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> beliefsRefs(
    Expression<bool> Function($$BeliefsTableFilterComposer f) f,
  ) {
    final $$BeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.devotionalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableFilterComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevotionalsTableOrderingComposer
    extends Composer<_$AppDatabase, $DevotionalsTable> {
  $$DevotionalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookCode => $composableBuilder(
    column: $table.bookCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseEnd => $composableBuilder(
    column: $table.verseEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyVerse => $composableBuilder(
    column: $table.keyVerse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodId => $composableBuilder(
    column: $table.periodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get empireId => $composableBuilder(
    column: $table.empireId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get approxYear => $composableBuilder(
    column: $table.approxYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevotionalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevotionalsTable> {
  $$DevotionalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get bookCode =>
      $composableBuilder(column: $table.bookCode, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verseStart => $composableBuilder(
    column: $table.verseStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get verseEnd =>
      $composableBuilder(column: $table.verseEnd, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get keyVerse =>
      $composableBuilder(column: $table.keyVerse, builder: (column) => column);

  GeneratedColumn<String> get periodId =>
      $composableBuilder(column: $table.periodId, builder: (column) => column);

  GeneratedColumn<String> get empireId =>
      $composableBuilder(column: $table.empireId, builder: (column) => column);

  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get approxYear => $composableBuilder(
    column: $table.approxYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> devotionalTopicsRefs<T extends Object>(
    Expression<T> Function($$DevotionalTopicsTableAnnotationComposer a) f,
  ) {
    final $$DevotionalTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devotionalTopics,
      getReferencedColumn: (t) => t.devotionalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.devotionalTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> beliefsRefs<T extends Object>(
    Expression<T> Function($$BeliefsTableAnnotationComposer a) f,
  ) {
    final $$BeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.devotionalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevotionalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevotionalsTable,
          DevotionalRow,
          $$DevotionalsTableFilterComposer,
          $$DevotionalsTableOrderingComposer,
          $$DevotionalsTableAnnotationComposer,
          $$DevotionalsTableCreateCompanionBuilder,
          $$DevotionalsTableUpdateCompanionBuilder,
          (DevotionalRow, $$DevotionalsTableReferences),
          DevotionalRow,
          PrefetchHooks Function({bool devotionalTopicsRefs, bool beliefsRefs})
        > {
  $$DevotionalsTableTableManager(_$AppDatabase db, $DevotionalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevotionalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevotionalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevotionalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> bookCode = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int?> verseStart = const Value.absent(),
                Value<int?> verseEnd = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> keyVerse = const Value.absent(),
                Value<String?> periodId = const Value.absent(),
                Value<String?> empireId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> approxYear = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevotionalsCompanion(
                id: id,
                date: date,
                bookCode: bookCode,
                chapter: chapter,
                verseStart: verseStart,
                verseEnd: verseEnd,
                content: content,
                title: title,
                keyVerse: keyVerse,
                periodId: periodId,
                empireId: empireId,
                regionId: regionId,
                author: author,
                approxYear: approxYear,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String bookCode,
                required int chapter,
                Value<int?> verseStart = const Value.absent(),
                Value<int?> verseEnd = const Value.absent(),
                required String content,
                Value<String?> title = const Value.absent(),
                Value<String?> keyVerse = const Value.absent(),
                Value<String?> periodId = const Value.absent(),
                Value<String?> empireId = const Value.absent(),
                Value<String?> regionId = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> approxYear = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DevotionalsCompanion.insert(
                id: id,
                date: date,
                bookCode: bookCode,
                chapter: chapter,
                verseStart: verseStart,
                verseEnd: verseEnd,
                content: content,
                title: title,
                keyVerse: keyVerse,
                periodId: periodId,
                empireId: empireId,
                regionId: regionId,
                author: author,
                approxYear: approxYear,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevotionalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({devotionalTopicsRefs = false, beliefsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (devotionalTopicsRefs) db.devotionalTopics,
                    if (beliefsRefs) db.beliefs,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (devotionalTopicsRefs)
                        await $_getPrefetchedData<
                          DevotionalRow,
                          $DevotionalsTable,
                          DevotionalTopicRow
                        >(
                          currentTable: table,
                          referencedTable: $$DevotionalsTableReferences
                              ._devotionalTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevotionalsTableReferences(
                                db,
                                table,
                                p0,
                              ).devotionalTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.devotionalId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (beliefsRefs)
                        await $_getPrefetchedData<
                          DevotionalRow,
                          $DevotionalsTable,
                          BeliefRow
                        >(
                          currentTable: table,
                          referencedTable: $$DevotionalsTableReferences
                              ._beliefsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DevotionalsTableReferences(
                                db,
                                table,
                                p0,
                              ).beliefsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.devotionalId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DevotionalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevotionalsTable,
      DevotionalRow,
      $$DevotionalsTableFilterComposer,
      $$DevotionalsTableOrderingComposer,
      $$DevotionalsTableAnnotationComposer,
      $$DevotionalsTableCreateCompanionBuilder,
      $$DevotionalsTableUpdateCompanionBuilder,
      (DevotionalRow, $$DevotionalsTableReferences),
      DevotionalRow,
      PrefetchHooks Function({bool devotionalTopicsRefs, bool beliefsRefs})
    >;
typedef $$DevotionalTopicsTableCreateCompanionBuilder =
    DevotionalTopicsCompanion Function({
      required String devotionalId,
      required String topicId,
      required TopicOrigin origin,
      Value<int> rowid,
    });
typedef $$DevotionalTopicsTableUpdateCompanionBuilder =
    DevotionalTopicsCompanion Function({
      Value<String> devotionalId,
      Value<String> topicId,
      Value<TopicOrigin> origin,
      Value<int> rowid,
    });

final class $$DevotionalTopicsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DevotionalTopicsTable,
          DevotionalTopicRow
        > {
  $$DevotionalTopicsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevotionalsTable _devotionalIdTable(_$AppDatabase db) => db
      .devotionals
      .createAlias('devotional_topics__devotional_id__devotionals__id');

  $$DevotionalsTableProcessedTableManager get devotionalId {
    final $_column = $_itemColumn<String>('devotional_id')!;

    final manager = $$DevotionalsTableTableManager(
      $_db,
      $_db.devotionals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_devotionalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicsTable _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('devotional_topics__topic_id__topics__id');

  $$TopicsTableProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $$TopicsTableTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DevotionalTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $DevotionalTopicsTable> {
  $$DevotionalTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<TopicOrigin, TopicOrigin, String> get origin =>
      $composableBuilder(
        column: $table.origin,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$DevotionalsTableFilterComposer get devotionalId {
    final $$DevotionalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableFilterComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevotionalTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $DevotionalTopicsTable> {
  $$DevotionalTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevotionalsTableOrderingComposer get devotionalId {
    final $$DevotionalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableOrderingComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevotionalTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevotionalTopicsTable> {
  $$DevotionalTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<TopicOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  $$DevotionalsTableAnnotationComposer get devotionalId {
    final $$DevotionalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableAnnotationComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevotionalTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevotionalTopicsTable,
          DevotionalTopicRow,
          $$DevotionalTopicsTableFilterComposer,
          $$DevotionalTopicsTableOrderingComposer,
          $$DevotionalTopicsTableAnnotationComposer,
          $$DevotionalTopicsTableCreateCompanionBuilder,
          $$DevotionalTopicsTableUpdateCompanionBuilder,
          (DevotionalTopicRow, $$DevotionalTopicsTableReferences),
          DevotionalTopicRow,
          PrefetchHooks Function({bool devotionalId, bool topicId})
        > {
  $$DevotionalTopicsTableTableManager(
    _$AppDatabase db,
    $DevotionalTopicsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevotionalTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevotionalTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevotionalTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> devotionalId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<TopicOrigin> origin = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevotionalTopicsCompanion(
                devotionalId: devotionalId,
                topicId: topicId,
                origin: origin,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String devotionalId,
                required String topicId,
                required TopicOrigin origin,
                Value<int> rowid = const Value.absent(),
              }) => DevotionalTopicsCompanion.insert(
                devotionalId: devotionalId,
                topicId: topicId,
                origin: origin,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevotionalTopicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({devotionalId = false, topicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (devotionalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.devotionalId,
                                referencedTable:
                                    $$DevotionalTopicsTableReferences
                                        ._devotionalIdTable(db),
                                referencedColumn:
                                    $$DevotionalTopicsTableReferences
                                        ._devotionalIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (topicId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.topicId,
                                referencedTable:
                                    $$DevotionalTopicsTableReferences
                                        ._topicIdTable(db),
                                referencedColumn:
                                    $$DevotionalTopicsTableReferences
                                        ._topicIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DevotionalTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevotionalTopicsTable,
      DevotionalTopicRow,
      $$DevotionalTopicsTableFilterComposer,
      $$DevotionalTopicsTableOrderingComposer,
      $$DevotionalTopicsTableAnnotationComposer,
      $$DevotionalTopicsTableCreateCompanionBuilder,
      $$DevotionalTopicsTableUpdateCompanionBuilder,
      (DevotionalTopicRow, $$DevotionalTopicsTableReferences),
      DevotionalTopicRow,
      PrefetchHooks Function({bool devotionalId, bool topicId})
    >;
typedef $$PraxisEntriesTableCreateCompanionBuilder =
    PraxisEntriesCompanion Function({
      required String id,
      required DateTime date,
      required String circumstance,
      required int intensity,
      required FilterType filter,
      Value<String?> foundationDetail,
      Value<String?> passage,
      required String action,
      required int peace,
      Value<int?> coherence,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PraxisEntriesTableUpdateCompanionBuilder =
    PraxisEntriesCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> circumstance,
      Value<int> intensity,
      Value<FilterType> filter,
      Value<String?> foundationDetail,
      Value<String?> passage,
      Value<String> action,
      Value<int> peace,
      Value<int?> coherence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PraxisEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $PraxisEntriesTable, PraxisRow> {
  $$PraxisEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PraxisEmotionsTable, List<PraxisEmotion>>
  _praxisEmotionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisEmotions,
    aliasName: 'praxis_entries__id__praxis_emotions__praxis_id',
  );

  $$PraxisEmotionsTableProcessedTableManager get praxisEmotionsRefs {
    final manager = $$PraxisEmotionsTableTableManager(
      $_db,
      $_db.praxisEmotions,
    ).filter((f) => f.praxisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisEmotionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PraxisTriggersTable, List<PraxisTrigger>>
  _praxisTriggersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisTriggers,
    aliasName: 'praxis_entries__id__praxis_triggers__praxis_id',
  );

  $$PraxisTriggersTableProcessedTableManager get praxisTriggersRefs {
    final manager = $$PraxisTriggersTableTableManager(
      $_db,
      $_db.praxisTriggers,
    ).filter((f) => f.praxisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisTriggersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PraxisTopicsTable, List<PraxisTopic>>
  _praxisTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.praxisTopics,
    aliasName: 'praxis_entries__id__praxis_topics__praxis_id',
  );

  $$PraxisTopicsTableProcessedTableManager get praxisTopicsRefs {
    final manager = $$PraxisTopicsTableTableManager(
      $_db,
      $_db.praxisTopics,
    ).filter((f) => f.praxisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_praxisTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrayerPraxisLinksTable, List<PrayerPraxisLink>>
  _prayerPraxisLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.prayerPraxisLinks,
        aliasName: 'praxis_entries__id__prayer_praxis_links__praxis_id',
      );

  $$PrayerPraxisLinksTableProcessedTableManager get prayerPraxisLinksRefs {
    final manager = $$PrayerPraxisLinksTableTableManager(
      $_db,
      $_db.prayerPraxisLinks,
    ).filter((f) => f.praxisId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _prayerPraxisLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PraxisEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $PraxisEntriesTable> {
  $$PraxisEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circumstance => $composableBuilder(
    column: $table.circumstance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FilterType, FilterType, String> get filter =>
      $composableBuilder(
        column: $table.filter,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get foundationDetail => $composableBuilder(
    column: $table.foundationDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get peace => $composableBuilder(
    column: $table.peace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coherence => $composableBuilder(
    column: $table.coherence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> praxisEmotionsRefs(
    Expression<bool> Function($$PraxisEmotionsTableFilterComposer f) f,
  ) {
    final $$PraxisEmotionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisEmotions,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEmotionsTableFilterComposer(
            $db: $db,
            $table: $db.praxisEmotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> praxisTriggersRefs(
    Expression<bool> Function($$PraxisTriggersTableFilterComposer f) f,
  ) {
    final $$PraxisTriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTriggers,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTriggersTableFilterComposer(
            $db: $db,
            $table: $db.praxisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> praxisTopicsRefs(
    Expression<bool> Function($$PraxisTopicsTableFilterComposer f) f,
  ) {
    final $$PraxisTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTopics,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTopicsTableFilterComposer(
            $db: $db,
            $table: $db.praxisTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prayerPraxisLinksRefs(
    Expression<bool> Function($$PrayerPraxisLinksTableFilterComposer f) f,
  ) {
    final $$PrayerPraxisLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerPraxisLinks,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerPraxisLinksTableFilterComposer(
            $db: $db,
            $table: $db.prayerPraxisLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PraxisEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PraxisEntriesTable> {
  $$PraxisEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circumstance => $composableBuilder(
    column: $table.circumstance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filter => $composableBuilder(
    column: $table.filter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foundationDetail => $composableBuilder(
    column: $table.foundationDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get peace => $composableBuilder(
    column: $table.peace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coherence => $composableBuilder(
    column: $table.coherence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PraxisEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PraxisEntriesTable> {
  $$PraxisEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get circumstance => $composableBuilder(
    column: $table.circumstance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FilterType, String> get filter =>
      $composableBuilder(column: $table.filter, builder: (column) => column);

  GeneratedColumn<String> get foundationDetail => $composableBuilder(
    column: $table.foundationDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passage =>
      $composableBuilder(column: $table.passage, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<int> get peace =>
      $composableBuilder(column: $table.peace, builder: (column) => column);

  GeneratedColumn<int> get coherence =>
      $composableBuilder(column: $table.coherence, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> praxisEmotionsRefs<T extends Object>(
    Expression<T> Function($$PraxisEmotionsTableAnnotationComposer a) f,
  ) {
    final $$PraxisEmotionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisEmotions,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEmotionsTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEmotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> praxisTriggersRefs<T extends Object>(
    Expression<T> Function($$PraxisTriggersTableAnnotationComposer a) f,
  ) {
    final $$PraxisTriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTriggers,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisTriggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> praxisTopicsRefs<T extends Object>(
    Expression<T> Function($$PraxisTopicsTableAnnotationComposer a) f,
  ) {
    final $$PraxisTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.praxisTopics,
      getReferencedColumn: (t) => t.praxisId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prayerPraxisLinksRefs<T extends Object>(
    Expression<T> Function($$PrayerPraxisLinksTableAnnotationComposer a) f,
  ) {
    final $$PrayerPraxisLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.prayerPraxisLinks,
          getReferencedColumn: (t) => t.praxisId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PrayerPraxisLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.prayerPraxisLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PraxisEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PraxisEntriesTable,
          PraxisRow,
          $$PraxisEntriesTableFilterComposer,
          $$PraxisEntriesTableOrderingComposer,
          $$PraxisEntriesTableAnnotationComposer,
          $$PraxisEntriesTableCreateCompanionBuilder,
          $$PraxisEntriesTableUpdateCompanionBuilder,
          (PraxisRow, $$PraxisEntriesTableReferences),
          PraxisRow,
          PrefetchHooks Function({
            bool praxisEmotionsRefs,
            bool praxisTriggersRefs,
            bool praxisTopicsRefs,
            bool prayerPraxisLinksRefs,
          })
        > {
  $$PraxisEntriesTableTableManager(_$AppDatabase db, $PraxisEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PraxisEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PraxisEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PraxisEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> circumstance = const Value.absent(),
                Value<int> intensity = const Value.absent(),
                Value<FilterType> filter = const Value.absent(),
                Value<String?> foundationDetail = const Value.absent(),
                Value<String?> passage = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<int> peace = const Value.absent(),
                Value<int?> coherence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PraxisEntriesCompanion(
                id: id,
                date: date,
                circumstance: circumstance,
                intensity: intensity,
                filter: filter,
                foundationDetail: foundationDetail,
                passage: passage,
                action: action,
                peace: peace,
                coherence: coherence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String circumstance,
                required int intensity,
                required FilterType filter,
                Value<String?> foundationDetail = const Value.absent(),
                Value<String?> passage = const Value.absent(),
                required String action,
                required int peace,
                Value<int?> coherence = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PraxisEntriesCompanion.insert(
                id: id,
                date: date,
                circumstance: circumstance,
                intensity: intensity,
                filter: filter,
                foundationDetail: foundationDetail,
                passage: passage,
                action: action,
                peace: peace,
                coherence: coherence,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PraxisEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                praxisEmotionsRefs = false,
                praxisTriggersRefs = false,
                praxisTopicsRefs = false,
                prayerPraxisLinksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (praxisEmotionsRefs) db.praxisEmotions,
                    if (praxisTriggersRefs) db.praxisTriggers,
                    if (praxisTopicsRefs) db.praxisTopics,
                    if (prayerPraxisLinksRefs) db.prayerPraxisLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (praxisEmotionsRefs)
                        await $_getPrefetchedData<
                          PraxisRow,
                          $PraxisEntriesTable,
                          PraxisEmotion
                        >(
                          currentTable: table,
                          referencedTable: $$PraxisEntriesTableReferences
                              ._praxisEmotionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PraxisEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).praxisEmotionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.praxisId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (praxisTriggersRefs)
                        await $_getPrefetchedData<
                          PraxisRow,
                          $PraxisEntriesTable,
                          PraxisTrigger
                        >(
                          currentTable: table,
                          referencedTable: $$PraxisEntriesTableReferences
                              ._praxisTriggersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PraxisEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).praxisTriggersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.praxisId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (praxisTopicsRefs)
                        await $_getPrefetchedData<
                          PraxisRow,
                          $PraxisEntriesTable,
                          PraxisTopic
                        >(
                          currentTable: table,
                          referencedTable: $$PraxisEntriesTableReferences
                              ._praxisTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PraxisEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).praxisTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.praxisId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prayerPraxisLinksRefs)
                        await $_getPrefetchedData<
                          PraxisRow,
                          $PraxisEntriesTable,
                          PrayerPraxisLink
                        >(
                          currentTable: table,
                          referencedTable: $$PraxisEntriesTableReferences
                              ._prayerPraxisLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PraxisEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).prayerPraxisLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.praxisId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PraxisEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PraxisEntriesTable,
      PraxisRow,
      $$PraxisEntriesTableFilterComposer,
      $$PraxisEntriesTableOrderingComposer,
      $$PraxisEntriesTableAnnotationComposer,
      $$PraxisEntriesTableCreateCompanionBuilder,
      $$PraxisEntriesTableUpdateCompanionBuilder,
      (PraxisRow, $$PraxisEntriesTableReferences),
      PraxisRow,
      PrefetchHooks Function({
        bool praxisEmotionsRefs,
        bool praxisTriggersRefs,
        bool praxisTopicsRefs,
        bool prayerPraxisLinksRefs,
      })
    >;
typedef $$PraxisEmotionsTableCreateCompanionBuilder =
    PraxisEmotionsCompanion Function({
      required String praxisId,
      required String emotionId,
      Value<int> rowid,
    });
typedef $$PraxisEmotionsTableUpdateCompanionBuilder =
    PraxisEmotionsCompanion Function({
      Value<String> praxisId,
      Value<String> emotionId,
      Value<int> rowid,
    });

final class $$PraxisEmotionsTableReferences
    extends BaseReferences<_$AppDatabase, $PraxisEmotionsTable, PraxisEmotion> {
  $$PraxisEmotionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PraxisEntriesTable _praxisIdTable(_$AppDatabase db) => db
      .praxisEntries
      .createAlias('praxis_emotions__praxis_id__praxis_entries__id');

  $$PraxisEntriesTableProcessedTableManager get praxisId {
    final $_column = $_itemColumn<String>('praxis_id')!;

    final manager = $$PraxisEntriesTableTableManager(
      $_db,
      $_db.praxisEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_praxisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $EmotionsTable _emotionIdTable(_$AppDatabase db) =>
      db.emotions.createAlias('praxis_emotions__emotion_id__emotions__id');

  $$EmotionsTableProcessedTableManager get emotionId {
    final $_column = $_itemColumn<String>('emotion_id')!;

    final manager = $$EmotionsTableTableManager(
      $_db,
      $_db.emotions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_emotionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PraxisEmotionsTableFilterComposer
    extends Composer<_$AppDatabase, $PraxisEmotionsTable> {
  $$PraxisEmotionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableFilterComposer get praxisId {
    final $$PraxisEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableFilterComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmotionsTableFilterComposer get emotionId {
    final $$EmotionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emotionId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableFilterComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisEmotionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PraxisEmotionsTable> {
  $$PraxisEmotionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableOrderingComposer get praxisId {
    final $$PraxisEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmotionsTableOrderingComposer get emotionId {
    final $$EmotionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emotionId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableOrderingComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisEmotionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PraxisEmotionsTable> {
  $$PraxisEmotionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableAnnotationComposer get praxisId {
    final $$PraxisEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$EmotionsTableAnnotationComposer get emotionId {
    final $$EmotionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.emotionId,
      referencedTable: $db.emotions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmotionsTableAnnotationComposer(
            $db: $db,
            $table: $db.emotions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisEmotionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PraxisEmotionsTable,
          PraxisEmotion,
          $$PraxisEmotionsTableFilterComposer,
          $$PraxisEmotionsTableOrderingComposer,
          $$PraxisEmotionsTableAnnotationComposer,
          $$PraxisEmotionsTableCreateCompanionBuilder,
          $$PraxisEmotionsTableUpdateCompanionBuilder,
          (PraxisEmotion, $$PraxisEmotionsTableReferences),
          PraxisEmotion,
          PrefetchHooks Function({bool praxisId, bool emotionId})
        > {
  $$PraxisEmotionsTableTableManager(
    _$AppDatabase db,
    $PraxisEmotionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PraxisEmotionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PraxisEmotionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PraxisEmotionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> praxisId = const Value.absent(),
                Value<String> emotionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PraxisEmotionsCompanion(
                praxisId: praxisId,
                emotionId: emotionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String praxisId,
                required String emotionId,
                Value<int> rowid = const Value.absent(),
              }) => PraxisEmotionsCompanion.insert(
                praxisId: praxisId,
                emotionId: emotionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PraxisEmotionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({praxisId = false, emotionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (praxisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.praxisId,
                                referencedTable: $$PraxisEmotionsTableReferences
                                    ._praxisIdTable(db),
                                referencedColumn:
                                    $$PraxisEmotionsTableReferences
                                        ._praxisIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (emotionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.emotionId,
                                referencedTable: $$PraxisEmotionsTableReferences
                                    ._emotionIdTable(db),
                                referencedColumn:
                                    $$PraxisEmotionsTableReferences
                                        ._emotionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PraxisEmotionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PraxisEmotionsTable,
      PraxisEmotion,
      $$PraxisEmotionsTableFilterComposer,
      $$PraxisEmotionsTableOrderingComposer,
      $$PraxisEmotionsTableAnnotationComposer,
      $$PraxisEmotionsTableCreateCompanionBuilder,
      $$PraxisEmotionsTableUpdateCompanionBuilder,
      (PraxisEmotion, $$PraxisEmotionsTableReferences),
      PraxisEmotion,
      PrefetchHooks Function({bool praxisId, bool emotionId})
    >;
typedef $$PraxisTriggersTableCreateCompanionBuilder =
    PraxisTriggersCompanion Function({
      required String praxisId,
      required String triggerId,
      Value<int> rowid,
    });
typedef $$PraxisTriggersTableUpdateCompanionBuilder =
    PraxisTriggersCompanion Function({
      Value<String> praxisId,
      Value<String> triggerId,
      Value<int> rowid,
    });

final class $$PraxisTriggersTableReferences
    extends BaseReferences<_$AppDatabase, $PraxisTriggersTable, PraxisTrigger> {
  $$PraxisTriggersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PraxisEntriesTable _praxisIdTable(_$AppDatabase db) => db
      .praxisEntries
      .createAlias('praxis_triggers__praxis_id__praxis_entries__id');

  $$PraxisEntriesTableProcessedTableManager get praxisId {
    final $_column = $_itemColumn<String>('praxis_id')!;

    final manager = $$PraxisEntriesTableTableManager(
      $_db,
      $_db.praxisEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_praxisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TriggersTable _triggerIdTable(_$AppDatabase db) =>
      db.triggers.createAlias('praxis_triggers__trigger_id__triggers__id');

  $$TriggersTableProcessedTableManager get triggerId {
    final $_column = $_itemColumn<String>('trigger_id')!;

    final manager = $$TriggersTableTableManager(
      $_db,
      $_db.triggers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_triggerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PraxisTriggersTableFilterComposer
    extends Composer<_$AppDatabase, $PraxisTriggersTable> {
  $$PraxisTriggersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableFilterComposer get praxisId {
    final $$PraxisEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableFilterComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableFilterComposer get triggerId {
    final $$TriggersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableFilterComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTriggersTableOrderingComposer
    extends Composer<_$AppDatabase, $PraxisTriggersTable> {
  $$PraxisTriggersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableOrderingComposer get praxisId {
    final $$PraxisEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableOrderingComposer get triggerId {
    final $$TriggersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableOrderingComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTriggersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PraxisTriggersTable> {
  $$PraxisTriggersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableAnnotationComposer get praxisId {
    final $$PraxisEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TriggersTableAnnotationComposer get triggerId {
    final $$TriggersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.triggerId,
      referencedTable: $db.triggers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TriggersTableAnnotationComposer(
            $db: $db,
            $table: $db.triggers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTriggersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PraxisTriggersTable,
          PraxisTrigger,
          $$PraxisTriggersTableFilterComposer,
          $$PraxisTriggersTableOrderingComposer,
          $$PraxisTriggersTableAnnotationComposer,
          $$PraxisTriggersTableCreateCompanionBuilder,
          $$PraxisTriggersTableUpdateCompanionBuilder,
          (PraxisTrigger, $$PraxisTriggersTableReferences),
          PraxisTrigger,
          PrefetchHooks Function({bool praxisId, bool triggerId})
        > {
  $$PraxisTriggersTableTableManager(
    _$AppDatabase db,
    $PraxisTriggersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PraxisTriggersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PraxisTriggersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PraxisTriggersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> praxisId = const Value.absent(),
                Value<String> triggerId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PraxisTriggersCompanion(
                praxisId: praxisId,
                triggerId: triggerId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String praxisId,
                required String triggerId,
                Value<int> rowid = const Value.absent(),
              }) => PraxisTriggersCompanion.insert(
                praxisId: praxisId,
                triggerId: triggerId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PraxisTriggersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({praxisId = false, triggerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (praxisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.praxisId,
                                referencedTable: $$PraxisTriggersTableReferences
                                    ._praxisIdTable(db),
                                referencedColumn:
                                    $$PraxisTriggersTableReferences
                                        ._praxisIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (triggerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.triggerId,
                                referencedTable: $$PraxisTriggersTableReferences
                                    ._triggerIdTable(db),
                                referencedColumn:
                                    $$PraxisTriggersTableReferences
                                        ._triggerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PraxisTriggersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PraxisTriggersTable,
      PraxisTrigger,
      $$PraxisTriggersTableFilterComposer,
      $$PraxisTriggersTableOrderingComposer,
      $$PraxisTriggersTableAnnotationComposer,
      $$PraxisTriggersTableCreateCompanionBuilder,
      $$PraxisTriggersTableUpdateCompanionBuilder,
      (PraxisTrigger, $$PraxisTriggersTableReferences),
      PraxisTrigger,
      PrefetchHooks Function({bool praxisId, bool triggerId})
    >;
typedef $$PraxisTopicsTableCreateCompanionBuilder =
    PraxisTopicsCompanion Function({
      required String praxisId,
      required String topicId,
      Value<int> rowid,
    });
typedef $$PraxisTopicsTableUpdateCompanionBuilder =
    PraxisTopicsCompanion Function({
      Value<String> praxisId,
      Value<String> topicId,
      Value<int> rowid,
    });

final class $$PraxisTopicsTableReferences
    extends BaseReferences<_$AppDatabase, $PraxisTopicsTable, PraxisTopic> {
  $$PraxisTopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PraxisEntriesTable _praxisIdTable(_$AppDatabase db) => db
      .praxisEntries
      .createAlias('praxis_topics__praxis_id__praxis_entries__id');

  $$PraxisEntriesTableProcessedTableManager get praxisId {
    final $_column = $_itemColumn<String>('praxis_id')!;

    final manager = $$PraxisEntriesTableTableManager(
      $_db,
      $_db.praxisEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_praxisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicsTable _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('praxis_topics__topic_id__topics__id');

  $$TopicsTableProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $$TopicsTableTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PraxisTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $PraxisTopicsTable> {
  $$PraxisTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableFilterComposer get praxisId {
    final $$PraxisEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableFilterComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $PraxisTopicsTable> {
  $$PraxisTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableOrderingComposer get praxisId {
    final $$PraxisEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PraxisTopicsTable> {
  $$PraxisTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PraxisEntriesTableAnnotationComposer get praxisId {
    final $$PraxisEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PraxisTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PraxisTopicsTable,
          PraxisTopic,
          $$PraxisTopicsTableFilterComposer,
          $$PraxisTopicsTableOrderingComposer,
          $$PraxisTopicsTableAnnotationComposer,
          $$PraxisTopicsTableCreateCompanionBuilder,
          $$PraxisTopicsTableUpdateCompanionBuilder,
          (PraxisTopic, $$PraxisTopicsTableReferences),
          PraxisTopic,
          PrefetchHooks Function({bool praxisId, bool topicId})
        > {
  $$PraxisTopicsTableTableManager(_$AppDatabase db, $PraxisTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PraxisTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PraxisTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PraxisTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> praxisId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PraxisTopicsCompanion(
                praxisId: praxisId,
                topicId: topicId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String praxisId,
                required String topicId,
                Value<int> rowid = const Value.absent(),
              }) => PraxisTopicsCompanion.insert(
                praxisId: praxisId,
                topicId: topicId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PraxisTopicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({praxisId = false, topicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (praxisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.praxisId,
                                referencedTable: $$PraxisTopicsTableReferences
                                    ._praxisIdTable(db),
                                referencedColumn: $$PraxisTopicsTableReferences
                                    ._praxisIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (topicId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.topicId,
                                referencedTable: $$PraxisTopicsTableReferences
                                    ._topicIdTable(db),
                                referencedColumn: $$PraxisTopicsTableReferences
                                    ._topicIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PraxisTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PraxisTopicsTable,
      PraxisTopic,
      $$PraxisTopicsTableFilterComposer,
      $$PraxisTopicsTableOrderingComposer,
      $$PraxisTopicsTableAnnotationComposer,
      $$PraxisTopicsTableCreateCompanionBuilder,
      $$PraxisTopicsTableUpdateCompanionBuilder,
      (PraxisTopic, $$PraxisTopicsTableReferences),
      PraxisTopic,
      PrefetchHooks Function({bool praxisId, bool topicId})
    >;
typedef $$PrayersTableCreateCompanionBuilder =
    PrayersCompanion Function({
      required String id,
      required DateTime date,
      required String transcript,
      required PrayerIntent intent,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PrayersTableUpdateCompanionBuilder =
    PrayersCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String> transcript,
      Value<PrayerIntent> intent,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PrayersTableReferences
    extends BaseReferences<_$AppDatabase, $PrayersTable, PrayerRow> {
  $$PrayersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PrayerTopicsTable, List<PrayerTopic>>
  _prayerTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.prayerTopics,
    aliasName: 'prayers__id__prayer_topics__prayer_id',
  );

  $$PrayerTopicsTableProcessedTableManager get prayerTopicsRefs {
    final manager = $$PrayerTopicsTableTableManager(
      $_db,
      $_db.prayerTopics,
    ).filter((f) => f.prayerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_prayerTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PrayerPraxisLinksTable, List<PrayerPraxisLink>>
  _prayerPraxisLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.prayerPraxisLinks,
        aliasName: 'prayers__id__prayer_praxis_links__prayer_id',
      );

  $$PrayerPraxisLinksTableProcessedTableManager get prayerPraxisLinksRefs {
    final manager = $$PrayerPraxisLinksTableTableManager(
      $_db,
      $_db.prayerPraxisLinks,
    ).filter((f) => f.prayerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _prayerPraxisLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PrayersTableFilterComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrayerIntent, PrayerIntent, String>
  get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> prayerTopicsRefs(
    Expression<bool> Function($$PrayerTopicsTableFilterComposer f) f,
  ) {
    final $$PrayerTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerTopics,
      getReferencedColumn: (t) => t.prayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTopicsTableFilterComposer(
            $db: $db,
            $table: $db.prayerTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> prayerPraxisLinksRefs(
    Expression<bool> Function($$PrayerPraxisLinksTableFilterComposer f) f,
  ) {
    final $$PrayerPraxisLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerPraxisLinks,
      getReferencedColumn: (t) => t.prayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerPraxisLinksTableFilterComposer(
            $db: $db,
            $table: $db.prayerPraxisLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PrayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PrayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayersTable> {
  $$PrayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PrayerIntent, String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> prayerTopicsRefs<T extends Object>(
    Expression<T> Function($$PrayerTopicsTableAnnotationComposer a) f,
  ) {
    final $$PrayerTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.prayerTopics,
      getReferencedColumn: (t) => t.prayerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayerTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.prayerTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> prayerPraxisLinksRefs<T extends Object>(
    Expression<T> Function($$PrayerPraxisLinksTableAnnotationComposer a) f,
  ) {
    final $$PrayerPraxisLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.prayerPraxisLinks,
          getReferencedColumn: (t) => t.prayerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PrayerPraxisLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.prayerPraxisLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PrayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayersTable,
          PrayerRow,
          $$PrayersTableFilterComposer,
          $$PrayersTableOrderingComposer,
          $$PrayersTableAnnotationComposer,
          $$PrayersTableCreateCompanionBuilder,
          $$PrayersTableUpdateCompanionBuilder,
          (PrayerRow, $$PrayersTableReferences),
          PrayerRow,
          PrefetchHooks Function({
            bool prayerTopicsRefs,
            bool prayerPraxisLinksRefs,
          })
        > {
  $$PrayersTableTableManager(_$AppDatabase db, $PrayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> transcript = const Value.absent(),
                Value<PrayerIntent> intent = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayersCompanion(
                id: id,
                date: date,
                transcript: transcript,
                intent: intent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                required String transcript,
                required PrayerIntent intent,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PrayersCompanion.insert(
                id: id,
                date: date,
                transcript: transcript,
                intent: intent,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({prayerTopicsRefs = false, prayerPraxisLinksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (prayerTopicsRefs) db.prayerTopics,
                    if (prayerPraxisLinksRefs) db.prayerPraxisLinks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (prayerTopicsRefs)
                        await $_getPrefetchedData<
                          PrayerRow,
                          $PrayersTable,
                          PrayerTopic
                        >(
                          currentTable: table,
                          referencedTable: $$PrayersTableReferences
                              ._prayerTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrayersTableReferences(
                                db,
                                table,
                                p0,
                              ).prayerTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.prayerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (prayerPraxisLinksRefs)
                        await $_getPrefetchedData<
                          PrayerRow,
                          $PrayersTable,
                          PrayerPraxisLink
                        >(
                          currentTable: table,
                          referencedTable: $$PrayersTableReferences
                              ._prayerPraxisLinksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PrayersTableReferences(
                                db,
                                table,
                                p0,
                              ).prayerPraxisLinksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.prayerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PrayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayersTable,
      PrayerRow,
      $$PrayersTableFilterComposer,
      $$PrayersTableOrderingComposer,
      $$PrayersTableAnnotationComposer,
      $$PrayersTableCreateCompanionBuilder,
      $$PrayersTableUpdateCompanionBuilder,
      (PrayerRow, $$PrayersTableReferences),
      PrayerRow,
      PrefetchHooks Function({
        bool prayerTopicsRefs,
        bool prayerPraxisLinksRefs,
      })
    >;
typedef $$PrayerTopicsTableCreateCompanionBuilder =
    PrayerTopicsCompanion Function({
      required String prayerId,
      required String topicId,
      Value<int> rowid,
    });
typedef $$PrayerTopicsTableUpdateCompanionBuilder =
    PrayerTopicsCompanion Function({
      Value<String> prayerId,
      Value<String> topicId,
      Value<int> rowid,
    });

final class $$PrayerTopicsTableReferences
    extends BaseReferences<_$AppDatabase, $PrayerTopicsTable, PrayerTopic> {
  $$PrayerTopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PrayersTable _prayerIdTable(_$AppDatabase db) =>
      db.prayers.createAlias('prayer_topics__prayer_id__prayers__id');

  $$PrayersTableProcessedTableManager get prayerId {
    final $_column = $_itemColumn<String>('prayer_id')!;

    final manager = $$PrayersTableTableManager(
      $_db,
      $_db.prayers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicsTable _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('prayer_topics__topic_id__topics__id');

  $$TopicsTableProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $$TopicsTableTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrayerTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerTopicsTable> {
  $$PrayerTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableFilterComposer get prayerId {
    final $$PrayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableFilterComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerTopicsTable> {
  $$PrayerTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableOrderingComposer get prayerId {
    final $$PrayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableOrderingComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerTopicsTable> {
  $$PrayerTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableAnnotationComposer get prayerId {
    final $$PrayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableAnnotationComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerTopicsTable,
          PrayerTopic,
          $$PrayerTopicsTableFilterComposer,
          $$PrayerTopicsTableOrderingComposer,
          $$PrayerTopicsTableAnnotationComposer,
          $$PrayerTopicsTableCreateCompanionBuilder,
          $$PrayerTopicsTableUpdateCompanionBuilder,
          (PrayerTopic, $$PrayerTopicsTableReferences),
          PrayerTopic,
          PrefetchHooks Function({bool prayerId, bool topicId})
        > {
  $$PrayerTopicsTableTableManager(_$AppDatabase db, $PrayerTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> prayerId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerTopicsCompanion(
                prayerId: prayerId,
                topicId: topicId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prayerId,
                required String topicId,
                Value<int> rowid = const Value.absent(),
              }) => PrayerTopicsCompanion.insert(
                prayerId: prayerId,
                topicId: topicId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayerTopicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({prayerId = false, topicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (prayerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.prayerId,
                                referencedTable: $$PrayerTopicsTableReferences
                                    ._prayerIdTable(db),
                                referencedColumn: $$PrayerTopicsTableReferences
                                    ._prayerIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (topicId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.topicId,
                                referencedTable: $$PrayerTopicsTableReferences
                                    ._topicIdTable(db),
                                referencedColumn: $$PrayerTopicsTableReferences
                                    ._topicIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrayerTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerTopicsTable,
      PrayerTopic,
      $$PrayerTopicsTableFilterComposer,
      $$PrayerTopicsTableOrderingComposer,
      $$PrayerTopicsTableAnnotationComposer,
      $$PrayerTopicsTableCreateCompanionBuilder,
      $$PrayerTopicsTableUpdateCompanionBuilder,
      (PrayerTopic, $$PrayerTopicsTableReferences),
      PrayerTopic,
      PrefetchHooks Function({bool prayerId, bool topicId})
    >;
typedef $$PrayerPraxisLinksTableCreateCompanionBuilder =
    PrayerPraxisLinksCompanion Function({
      required String prayerId,
      required String praxisId,
      Value<int> rowid,
    });
typedef $$PrayerPraxisLinksTableUpdateCompanionBuilder =
    PrayerPraxisLinksCompanion Function({
      Value<String> prayerId,
      Value<String> praxisId,
      Value<int> rowid,
    });

final class $$PrayerPraxisLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PrayerPraxisLinksTable,
          PrayerPraxisLink
        > {
  $$PrayerPraxisLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PrayersTable _prayerIdTable(_$AppDatabase db) =>
      db.prayers.createAlias('prayer_praxis_links__prayer_id__prayers__id');

  $$PrayersTableProcessedTableManager get prayerId {
    final $_column = $_itemColumn<String>('prayer_id')!;

    final manager = $$PrayersTableTableManager(
      $_db,
      $_db.prayers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_prayerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PraxisEntriesTable _praxisIdTable(_$AppDatabase db) => db
      .praxisEntries
      .createAlias('prayer_praxis_links__praxis_id__praxis_entries__id');

  $$PraxisEntriesTableProcessedTableManager get praxisId {
    final $_column = $_itemColumn<String>('praxis_id')!;

    final manager = $$PraxisEntriesTableTableManager(
      $_db,
      $_db.praxisEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_praxisIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PrayerPraxisLinksTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerPraxisLinksTable> {
  $$PrayerPraxisLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableFilterComposer get prayerId {
    final $$PrayersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableFilterComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PraxisEntriesTableFilterComposer get praxisId {
    final $$PraxisEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableFilterComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerPraxisLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerPraxisLinksTable> {
  $$PrayerPraxisLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableOrderingComposer get prayerId {
    final $$PrayersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableOrderingComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PraxisEntriesTableOrderingComposer get praxisId {
    final $$PraxisEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerPraxisLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerPraxisLinksTable> {
  $$PrayerPraxisLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$PrayersTableAnnotationComposer get prayerId {
    final $$PrayersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.prayerId,
      referencedTable: $db.prayers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PrayersTableAnnotationComposer(
            $db: $db,
            $table: $db.prayers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PraxisEntriesTableAnnotationComposer get praxisId {
    final $$PraxisEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.praxisId,
      referencedTable: $db.praxisEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PraxisEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.praxisEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PrayerPraxisLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PrayerPraxisLinksTable,
          PrayerPraxisLink,
          $$PrayerPraxisLinksTableFilterComposer,
          $$PrayerPraxisLinksTableOrderingComposer,
          $$PrayerPraxisLinksTableAnnotationComposer,
          $$PrayerPraxisLinksTableCreateCompanionBuilder,
          $$PrayerPraxisLinksTableUpdateCompanionBuilder,
          (PrayerPraxisLink, $$PrayerPraxisLinksTableReferences),
          PrayerPraxisLink,
          PrefetchHooks Function({bool prayerId, bool praxisId})
        > {
  $$PrayerPraxisLinksTableTableManager(
    _$AppDatabase db,
    $PrayerPraxisLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerPraxisLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerPraxisLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerPraxisLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> prayerId = const Value.absent(),
                Value<String> praxisId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PrayerPraxisLinksCompanion(
                prayerId: prayerId,
                praxisId: praxisId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String prayerId,
                required String praxisId,
                Value<int> rowid = const Value.absent(),
              }) => PrayerPraxisLinksCompanion.insert(
                prayerId: prayerId,
                praxisId: praxisId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PrayerPraxisLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({prayerId = false, praxisId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (prayerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.prayerId,
                                referencedTable:
                                    $$PrayerPraxisLinksTableReferences
                                        ._prayerIdTable(db),
                                referencedColumn:
                                    $$PrayerPraxisLinksTableReferences
                                        ._prayerIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (praxisId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.praxisId,
                                referencedTable:
                                    $$PrayerPraxisLinksTableReferences
                                        ._praxisIdTable(db),
                                referencedColumn:
                                    $$PrayerPraxisLinksTableReferences
                                        ._praxisIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PrayerPraxisLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PrayerPraxisLinksTable,
      PrayerPraxisLink,
      $$PrayerPraxisLinksTableFilterComposer,
      $$PrayerPraxisLinksTableOrderingComposer,
      $$PrayerPraxisLinksTableAnnotationComposer,
      $$PrayerPraxisLinksTableCreateCompanionBuilder,
      $$PrayerPraxisLinksTableUpdateCompanionBuilder,
      (PrayerPraxisLink, $$PrayerPraxisLinksTableReferences),
      PrayerPraxisLink,
      PrefetchHooks Function({bool prayerId, bool praxisId})
    >;
typedef $$AttachmentsTableCreateCompanionBuilder =
    AttachmentsCompanion Function({
      required String id,
      required String ownerType,
      required String ownerId,
      required String fileName,
      required String mimeType,
      Value<int?> width,
      Value<int?> height,
      required int sizeBytes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentsTableUpdateCompanionBuilder =
    AttachmentsCompanion Function({
      Value<String> id,
      Value<String> ownerType,
      Value<String> ownerId,
      Value<String> fileName,
      Value<String> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int> sizeBytes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentsTable> {
  $$AttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentsTable,
          AttachmentRow,
          $$AttachmentsTableFilterComposer,
          $$AttachmentsTableOrderingComposer,
          $$AttachmentsTableAnnotationComposer,
          $$AttachmentsTableCreateCompanionBuilder,
          $$AttachmentsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentsTableTableManager(_$AppDatabase db, $AttachmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                fileName: fileName,
                mimeType: mimeType,
                width: width,
                height: height,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerType,
                required String ownerId,
                required String fileName,
                required String mimeType,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                required int sizeBytes,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentsCompanion.insert(
                id: id,
                ownerType: ownerType,
                ownerId: ownerId,
                fileName: fileName,
                mimeType: mimeType,
                width: width,
                height: height,
                sizeBytes: sizeBytes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentsTable,
      AttachmentRow,
      $$AttachmentsTableFilterComposer,
      $$AttachmentsTableOrderingComposer,
      $$AttachmentsTableAnnotationComposer,
      $$AttachmentsTableCreateCompanionBuilder,
      $$AttachmentsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$BeliefsTableCreateCompanionBuilder =
    BeliefsCompanion Function({
      required String id,
      required String proposition,
      required BeliefStatus status,
      required BeliefOrigin origin,
      Value<String?> dimensionId,
      Value<String?> devotionalId,
      Value<String?> basePassage,
      Value<String?> note,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BeliefsTableUpdateCompanionBuilder =
    BeliefsCompanion Function({
      Value<String> id,
      Value<String> proposition,
      Value<BeliefStatus> status,
      Value<BeliefOrigin> origin,
      Value<String?> dimensionId,
      Value<String?> devotionalId,
      Value<String?> basePassage,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$BeliefsTableReferences
    extends BaseReferences<_$AppDatabase, $BeliefsTable, BeliefRow> {
  $$BeliefsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DimensionsTable _dimensionIdTable(_$AppDatabase db) =>
      db.dimensions.createAlias('beliefs__dimension_id__dimensions__id');

  $$DimensionsTableProcessedTableManager? get dimensionId {
    final $_column = $_itemColumn<String>('dimension_id');
    if ($_column == null) return null;
    final manager = $$DimensionsTableTableManager(
      $_db,
      $_db.dimensions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dimensionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DevotionalsTable _devotionalIdTable(_$AppDatabase db) =>
      db.devotionals.createAlias('beliefs__devotional_id__devotionals__id');

  $$DevotionalsTableProcessedTableManager? get devotionalId {
    final $_column = $_itemColumn<String>('devotional_id');
    if ($_column == null) return null;
    final manager = $$DevotionalsTableTableManager(
      $_db,
      $_db.devotionals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_devotionalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BeliefTopicsTable, List<BeliefTopic>>
  _beliefTopicsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.beliefTopics,
    aliasName: 'beliefs__id__belief_topics__belief_id',
  );

  $$BeliefTopicsTableProcessedTableManager get beliefTopicsRefs {
    final manager = $$BeliefTopicsTableTableManager(
      $_db,
      $_db.beliefTopics,
    ).filter((f) => f.beliefId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_beliefTopicsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BeliefEvidenceTableTable, List<BeliefEvidenceRow>>
  _beliefEvidenceTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.beliefEvidenceTable,
        aliasName: 'beliefs__id__belief_evidence__belief_id',
      );

  $$BeliefEvidenceTableTableProcessedTableManager get beliefEvidenceTableRefs {
    final manager = $$BeliefEvidenceTableTableTableManager(
      $_db,
      $_db.beliefEvidenceTable,
    ).filter((f) => f.beliefId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _beliefEvidenceTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ActionBeliefsTable, List<ActionBeliefRow>>
  _actionBeliefsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.actionBeliefs,
    aliasName: 'beliefs__id__action_beliefs__belief_id',
  );

  $$ActionBeliefsTableProcessedTableManager get actionBeliefsRefs {
    final manager = $$ActionBeliefsTableTableManager(
      $_db,
      $_db.actionBeliefs,
    ).filter((f) => f.beliefId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_actionBeliefsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BeliefsTableFilterComposer
    extends Composer<_$AppDatabase, $BeliefsTable> {
  $$BeliefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposition => $composableBuilder(
    column: $table.proposition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BeliefStatus, BeliefStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<BeliefOrigin, BeliefOrigin, String>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get basePassage => $composableBuilder(
    column: $table.basePassage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DimensionsTableFilterComposer get dimensionId {
    final $$DimensionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableFilterComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevotionalsTableFilterComposer get devotionalId {
    final $$DevotionalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableFilterComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> beliefTopicsRefs(
    Expression<bool> Function($$BeliefTopicsTableFilterComposer f) f,
  ) {
    final $$BeliefTopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefTopics,
      getReferencedColumn: (t) => t.beliefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefTopicsTableFilterComposer(
            $db: $db,
            $table: $db.beliefTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> beliefEvidenceTableRefs(
    Expression<bool> Function($$BeliefEvidenceTableTableFilterComposer f) f,
  ) {
    final $$BeliefEvidenceTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefEvidenceTable,
      getReferencedColumn: (t) => t.beliefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefEvidenceTableTableFilterComposer(
            $db: $db,
            $table: $db.beliefEvidenceTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> actionBeliefsRefs(
    Expression<bool> Function($$ActionBeliefsTableFilterComposer f) f,
  ) {
    final $$ActionBeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionBeliefs,
      getReferencedColumn: (t) => t.beliefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionBeliefsTableFilterComposer(
            $db: $db,
            $table: $db.actionBeliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BeliefsTableOrderingComposer
    extends Composer<_$AppDatabase, $BeliefsTable> {
  $$BeliefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposition => $composableBuilder(
    column: $table.proposition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basePassage => $composableBuilder(
    column: $table.basePassage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DimensionsTableOrderingComposer get dimensionId {
    final $$DimensionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableOrderingComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevotionalsTableOrderingComposer get devotionalId {
    final $$DevotionalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableOrderingComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeliefsTable> {
  $$BeliefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get proposition => $composableBuilder(
    column: $table.proposition,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<BeliefStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BeliefOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get basePassage => $composableBuilder(
    column: $table.basePassage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$DimensionsTableAnnotationComposer get dimensionId {
    final $$DimensionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dimensionId,
      referencedTable: $db.dimensions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DimensionsTableAnnotationComposer(
            $db: $db,
            $table: $db.dimensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DevotionalsTableAnnotationComposer get devotionalId {
    final $$DevotionalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.devotionalId,
      referencedTable: $db.devotionals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevotionalsTableAnnotationComposer(
            $db: $db,
            $table: $db.devotionals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> beliefTopicsRefs<T extends Object>(
    Expression<T> Function($$BeliefTopicsTableAnnotationComposer a) f,
  ) {
    final $$BeliefTopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.beliefTopics,
      getReferencedColumn: (t) => t.beliefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefTopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefTopics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> beliefEvidenceTableRefs<T extends Object>(
    Expression<T> Function($$BeliefEvidenceTableTableAnnotationComposer a) f,
  ) {
    final $$BeliefEvidenceTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.beliefEvidenceTable,
          getReferencedColumn: (t) => t.beliefId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$BeliefEvidenceTableTableAnnotationComposer(
                $db: $db,
                $table: $db.beliefEvidenceTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> actionBeliefsRefs<T extends Object>(
    Expression<T> Function($$ActionBeliefsTableAnnotationComposer a) f,
  ) {
    final $$ActionBeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.actionBeliefs,
      getReferencedColumn: (t) => t.beliefId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ActionBeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.actionBeliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BeliefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BeliefsTable,
          BeliefRow,
          $$BeliefsTableFilterComposer,
          $$BeliefsTableOrderingComposer,
          $$BeliefsTableAnnotationComposer,
          $$BeliefsTableCreateCompanionBuilder,
          $$BeliefsTableUpdateCompanionBuilder,
          (BeliefRow, $$BeliefsTableReferences),
          BeliefRow,
          PrefetchHooks Function({
            bool dimensionId,
            bool devotionalId,
            bool beliefTopicsRefs,
            bool beliefEvidenceTableRefs,
            bool actionBeliefsRefs,
          })
        > {
  $$BeliefsTableTableManager(_$AppDatabase db, $BeliefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeliefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeliefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeliefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> proposition = const Value.absent(),
                Value<BeliefStatus> status = const Value.absent(),
                Value<BeliefOrigin> origin = const Value.absent(),
                Value<String?> dimensionId = const Value.absent(),
                Value<String?> devotionalId = const Value.absent(),
                Value<String?> basePassage = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeliefsCompanion(
                id: id,
                proposition: proposition,
                status: status,
                origin: origin,
                dimensionId: dimensionId,
                devotionalId: devotionalId,
                basePassage: basePassage,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String proposition,
                required BeliefStatus status,
                required BeliefOrigin origin,
                Value<String?> dimensionId = const Value.absent(),
                Value<String?> devotionalId = const Value.absent(),
                Value<String?> basePassage = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BeliefsCompanion.insert(
                id: id,
                proposition: proposition,
                status: status,
                origin: origin,
                dimensionId: dimensionId,
                devotionalId: devotionalId,
                basePassage: basePassage,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BeliefsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                dimensionId = false,
                devotionalId = false,
                beliefTopicsRefs = false,
                beliefEvidenceTableRefs = false,
                actionBeliefsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (beliefTopicsRefs) db.beliefTopics,
                    if (beliefEvidenceTableRefs) db.beliefEvidenceTable,
                    if (actionBeliefsRefs) db.actionBeliefs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (dimensionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.dimensionId,
                                    referencedTable: $$BeliefsTableReferences
                                        ._dimensionIdTable(db),
                                    referencedColumn: $$BeliefsTableReferences
                                        ._dimensionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (devotionalId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.devotionalId,
                                    referencedTable: $$BeliefsTableReferences
                                        ._devotionalIdTable(db),
                                    referencedColumn: $$BeliefsTableReferences
                                        ._devotionalIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (beliefTopicsRefs)
                        await $_getPrefetchedData<
                          BeliefRow,
                          $BeliefsTable,
                          BeliefTopic
                        >(
                          currentTable: table,
                          referencedTable: $$BeliefsTableReferences
                              ._beliefTopicsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeliefsTableReferences(
                                db,
                                table,
                                p0,
                              ).beliefTopicsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beliefId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (beliefEvidenceTableRefs)
                        await $_getPrefetchedData<
                          BeliefRow,
                          $BeliefsTable,
                          BeliefEvidenceRow
                        >(
                          currentTable: table,
                          referencedTable: $$BeliefsTableReferences
                              ._beliefEvidenceTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeliefsTableReferences(
                                db,
                                table,
                                p0,
                              ).beliefEvidenceTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beliefId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (actionBeliefsRefs)
                        await $_getPrefetchedData<
                          BeliefRow,
                          $BeliefsTable,
                          ActionBeliefRow
                        >(
                          currentTable: table,
                          referencedTable: $$BeliefsTableReferences
                              ._actionBeliefsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BeliefsTableReferences(
                                db,
                                table,
                                p0,
                              ).actionBeliefsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.beliefId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BeliefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BeliefsTable,
      BeliefRow,
      $$BeliefsTableFilterComposer,
      $$BeliefsTableOrderingComposer,
      $$BeliefsTableAnnotationComposer,
      $$BeliefsTableCreateCompanionBuilder,
      $$BeliefsTableUpdateCompanionBuilder,
      (BeliefRow, $$BeliefsTableReferences),
      BeliefRow,
      PrefetchHooks Function({
        bool dimensionId,
        bool devotionalId,
        bool beliefTopicsRefs,
        bool beliefEvidenceTableRefs,
        bool actionBeliefsRefs,
      })
    >;
typedef $$BeliefTopicsTableCreateCompanionBuilder =
    BeliefTopicsCompanion Function({
      required String beliefId,
      required String topicId,
      Value<int> rowid,
    });
typedef $$BeliefTopicsTableUpdateCompanionBuilder =
    BeliefTopicsCompanion Function({
      Value<String> beliefId,
      Value<String> topicId,
      Value<int> rowid,
    });

final class $$BeliefTopicsTableReferences
    extends BaseReferences<_$AppDatabase, $BeliefTopicsTable, BeliefTopic> {
  $$BeliefTopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BeliefsTable _beliefIdTable(_$AppDatabase db) =>
      db.beliefs.createAlias('belief_topics__belief_id__beliefs__id');

  $$BeliefsTableProcessedTableManager get beliefId {
    final $_column = $_itemColumn<String>('belief_id')!;

    final manager = $$BeliefsTableTableManager(
      $_db,
      $_db.beliefs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beliefIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TopicsTable _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('belief_topics__topic_id__topics__id');

  $$TopicsTableProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $$TopicsTableTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BeliefTopicsTableFilterComposer
    extends Composer<_$AppDatabase, $BeliefTopicsTable> {
  $$BeliefTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BeliefsTableFilterComposer get beliefId {
    final $$BeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableFilterComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefTopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $BeliefTopicsTable> {
  $$BeliefTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BeliefsTableOrderingComposer get beliefId {
    final $$BeliefsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableOrderingComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefTopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeliefTopicsTable> {
  $$BeliefTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BeliefsTableAnnotationComposer get beliefId {
    final $$BeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TopicsTableAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefTopicsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BeliefTopicsTable,
          BeliefTopic,
          $$BeliefTopicsTableFilterComposer,
          $$BeliefTopicsTableOrderingComposer,
          $$BeliefTopicsTableAnnotationComposer,
          $$BeliefTopicsTableCreateCompanionBuilder,
          $$BeliefTopicsTableUpdateCompanionBuilder,
          (BeliefTopic, $$BeliefTopicsTableReferences),
          BeliefTopic,
          PrefetchHooks Function({bool beliefId, bool topicId})
        > {
  $$BeliefTopicsTableTableManager(_$AppDatabase db, $BeliefTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeliefTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeliefTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BeliefTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> beliefId = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeliefTopicsCompanion(
                beliefId: beliefId,
                topicId: topicId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String beliefId,
                required String topicId,
                Value<int> rowid = const Value.absent(),
              }) => BeliefTopicsCompanion.insert(
                beliefId: beliefId,
                topicId: topicId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BeliefTopicsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({beliefId = false, topicId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (beliefId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.beliefId,
                                referencedTable: $$BeliefTopicsTableReferences
                                    ._beliefIdTable(db),
                                referencedColumn: $$BeliefTopicsTableReferences
                                    ._beliefIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (topicId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.topicId,
                                referencedTable: $$BeliefTopicsTableReferences
                                    ._topicIdTable(db),
                                referencedColumn: $$BeliefTopicsTableReferences
                                    ._topicIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BeliefTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BeliefTopicsTable,
      BeliefTopic,
      $$BeliefTopicsTableFilterComposer,
      $$BeliefTopicsTableOrderingComposer,
      $$BeliefTopicsTableAnnotationComposer,
      $$BeliefTopicsTableCreateCompanionBuilder,
      $$BeliefTopicsTableUpdateCompanionBuilder,
      (BeliefTopic, $$BeliefTopicsTableReferences),
      BeliefTopic,
      PrefetchHooks Function({bool beliefId, bool topicId})
    >;
typedef $$BeliefEvidenceTableTableCreateCompanionBuilder =
    BeliefEvidenceTableCompanion Function({
      required String id,
      required String beliefId,
      required String passage,
      required EvidenceKind kind,
      required EvidenceSource source,
      Value<int?> votes,
      Value<double?> probEntail,
      Value<double?> probContra,
      Value<String?> modelVersion,
      Value<bool> resolved,
      Value<bool> confirmed,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BeliefEvidenceTableTableUpdateCompanionBuilder =
    BeliefEvidenceTableCompanion Function({
      Value<String> id,
      Value<String> beliefId,
      Value<String> passage,
      Value<EvidenceKind> kind,
      Value<EvidenceSource> source,
      Value<int?> votes,
      Value<double?> probEntail,
      Value<double?> probContra,
      Value<String?> modelVersion,
      Value<bool> resolved,
      Value<bool> confirmed,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$BeliefEvidenceTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $BeliefEvidenceTableTable,
          BeliefEvidenceRow
        > {
  $$BeliefEvidenceTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BeliefsTable _beliefIdTable(_$AppDatabase db) =>
      db.beliefs.createAlias('belief_evidence__belief_id__beliefs__id');

  $$BeliefsTableProcessedTableManager get beliefId {
    final $_column = $_itemColumn<String>('belief_id')!;

    final manager = $$BeliefsTableTableManager(
      $_db,
      $_db.beliefs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beliefIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BeliefEvidenceTableTableFilterComposer
    extends Composer<_$AppDatabase, $BeliefEvidenceTableTable> {
  $$BeliefEvidenceTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EvidenceKind, EvidenceKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<EvidenceSource, EvidenceSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get probEntail => $composableBuilder(
    column: $table.probEntail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get probContra => $composableBuilder(
    column: $table.probContra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BeliefsTableFilterComposer get beliefId {
    final $$BeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableFilterComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefEvidenceTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BeliefEvidenceTableTable> {
  $$BeliefEvidenceTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passage => $composableBuilder(
    column: $table.passage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get votes => $composableBuilder(
    column: $table.votes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get probEntail => $composableBuilder(
    column: $table.probEntail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get probContra => $composableBuilder(
    column: $table.probContra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get resolved => $composableBuilder(
    column: $table.resolved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BeliefsTableOrderingComposer get beliefId {
    final $$BeliefsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableOrderingComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefEvidenceTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BeliefEvidenceTableTable> {
  $$BeliefEvidenceTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get passage =>
      $composableBuilder(column: $table.passage, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EvidenceKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EvidenceSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get votes =>
      $composableBuilder(column: $table.votes, builder: (column) => column);

  GeneratedColumn<double> get probEntail => $composableBuilder(
    column: $table.probEntail,
    builder: (column) => column,
  );

  GeneratedColumn<double> get probContra => $composableBuilder(
    column: $table.probContra,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get resolved =>
      $composableBuilder(column: $table.resolved, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BeliefsTableAnnotationComposer get beliefId {
    final $$BeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BeliefEvidenceTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BeliefEvidenceTableTable,
          BeliefEvidenceRow,
          $$BeliefEvidenceTableTableFilterComposer,
          $$BeliefEvidenceTableTableOrderingComposer,
          $$BeliefEvidenceTableTableAnnotationComposer,
          $$BeliefEvidenceTableTableCreateCompanionBuilder,
          $$BeliefEvidenceTableTableUpdateCompanionBuilder,
          (BeliefEvidenceRow, $$BeliefEvidenceTableTableReferences),
          BeliefEvidenceRow,
          PrefetchHooks Function({bool beliefId})
        > {
  $$BeliefEvidenceTableTableTableManager(
    _$AppDatabase db,
    $BeliefEvidenceTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BeliefEvidenceTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BeliefEvidenceTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BeliefEvidenceTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> beliefId = const Value.absent(),
                Value<String> passage = const Value.absent(),
                Value<EvidenceKind> kind = const Value.absent(),
                Value<EvidenceSource> source = const Value.absent(),
                Value<int?> votes = const Value.absent(),
                Value<double?> probEntail = const Value.absent(),
                Value<double?> probContra = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BeliefEvidenceTableCompanion(
                id: id,
                beliefId: beliefId,
                passage: passage,
                kind: kind,
                source: source,
                votes: votes,
                probEntail: probEntail,
                probContra: probContra,
                modelVersion: modelVersion,
                resolved: resolved,
                confirmed: confirmed,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String beliefId,
                required String passage,
                required EvidenceKind kind,
                required EvidenceSource source,
                Value<int?> votes = const Value.absent(),
                Value<double?> probEntail = const Value.absent(),
                Value<double?> probContra = const Value.absent(),
                Value<String?> modelVersion = const Value.absent(),
                Value<bool> resolved = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BeliefEvidenceTableCompanion.insert(
                id: id,
                beliefId: beliefId,
                passage: passage,
                kind: kind,
                source: source,
                votes: votes,
                probEntail: probEntail,
                probContra: probContra,
                modelVersion: modelVersion,
                resolved: resolved,
                confirmed: confirmed,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BeliefEvidenceTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({beliefId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (beliefId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.beliefId,
                                referencedTable:
                                    $$BeliefEvidenceTableTableReferences
                                        ._beliefIdTable(db),
                                referencedColumn:
                                    $$BeliefEvidenceTableTableReferences
                                        ._beliefIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BeliefEvidenceTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BeliefEvidenceTableTable,
      BeliefEvidenceRow,
      $$BeliefEvidenceTableTableFilterComposer,
      $$BeliefEvidenceTableTableOrderingComposer,
      $$BeliefEvidenceTableTableAnnotationComposer,
      $$BeliefEvidenceTableTableCreateCompanionBuilder,
      $$BeliefEvidenceTableTableUpdateCompanionBuilder,
      (BeliefEvidenceRow, $$BeliefEvidenceTableTableReferences),
      BeliefEvidenceRow,
      PrefetchHooks Function({bool beliefId})
    >;
typedef $$ActionBeliefsTableCreateCompanionBuilder =
    ActionBeliefsCompanion Function({
      required ActionKind actionKind,
      required String actionId,
      required String beliefId,
      required ActionAlignment alignment,
      required LinkOrigin origin,
      Value<double?> confidence,
      Value<String?> source,
      Value<bool> confirmed,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ActionBeliefsTableUpdateCompanionBuilder =
    ActionBeliefsCompanion Function({
      Value<ActionKind> actionKind,
      Value<String> actionId,
      Value<String> beliefId,
      Value<ActionAlignment> alignment,
      Value<LinkOrigin> origin,
      Value<double?> confidence,
      Value<String?> source,
      Value<bool> confirmed,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ActionBeliefsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ActionBeliefsTable, ActionBeliefRow> {
  $$ActionBeliefsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BeliefsTable _beliefIdTable(_$AppDatabase db) =>
      db.beliefs.createAlias('action_beliefs__belief_id__beliefs__id');

  $$BeliefsTableProcessedTableManager get beliefId {
    final $_column = $_itemColumn<String>('belief_id')!;

    final manager = $$BeliefsTableTableManager(
      $_db,
      $_db.beliefs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_beliefIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ActionBeliefsTableFilterComposer
    extends Composer<_$AppDatabase, $ActionBeliefsTable> {
  $$ActionBeliefsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ActionKind, ActionKind, String>
  get actionKind => $composableBuilder(
    column: $table.actionKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ActionAlignment, ActionAlignment, String>
  get alignment => $composableBuilder(
    column: $table.alignment,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LinkOrigin, LinkOrigin, String> get origin =>
      $composableBuilder(
        column: $table.origin,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BeliefsTableFilterComposer get beliefId {
    final $$BeliefsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableFilterComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionBeliefsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActionBeliefsTable> {
  $$ActionBeliefsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get actionKind => $composableBuilder(
    column: $table.actionKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alignment => $composableBuilder(
    column: $table.alignment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BeliefsTableOrderingComposer get beliefId {
    final $$BeliefsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableOrderingComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionBeliefsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActionBeliefsTable> {
  $$ActionBeliefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ActionKind, String> get actionKind =>
      $composableBuilder(
        column: $table.actionKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get actionId =>
      $composableBuilder(column: $table.actionId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ActionAlignment, String> get alignment =>
      $composableBuilder(column: $table.alignment, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LinkOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BeliefsTableAnnotationComposer get beliefId {
    final $$BeliefsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.beliefId,
      referencedTable: $db.beliefs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BeliefsTableAnnotationComposer(
            $db: $db,
            $table: $db.beliefs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ActionBeliefsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActionBeliefsTable,
          ActionBeliefRow,
          $$ActionBeliefsTableFilterComposer,
          $$ActionBeliefsTableOrderingComposer,
          $$ActionBeliefsTableAnnotationComposer,
          $$ActionBeliefsTableCreateCompanionBuilder,
          $$ActionBeliefsTableUpdateCompanionBuilder,
          (ActionBeliefRow, $$ActionBeliefsTableReferences),
          ActionBeliefRow,
          PrefetchHooks Function({bool beliefId})
        > {
  $$ActionBeliefsTableTableManager(_$AppDatabase db, $ActionBeliefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActionBeliefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActionBeliefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActionBeliefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<ActionKind> actionKind = const Value.absent(),
                Value<String> actionId = const Value.absent(),
                Value<String> beliefId = const Value.absent(),
                Value<ActionAlignment> alignment = const Value.absent(),
                Value<LinkOrigin> origin = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActionBeliefsCompanion(
                actionKind: actionKind,
                actionId: actionId,
                beliefId: beliefId,
                alignment: alignment,
                origin: origin,
                confidence: confidence,
                source: source,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required ActionKind actionKind,
                required String actionId,
                required String beliefId,
                required ActionAlignment alignment,
                required LinkOrigin origin,
                Value<double?> confidence = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool> confirmed = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ActionBeliefsCompanion.insert(
                actionKind: actionKind,
                actionId: actionId,
                beliefId: beliefId,
                alignment: alignment,
                origin: origin,
                confidence: confidence,
                source: source,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ActionBeliefsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({beliefId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (beliefId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.beliefId,
                                referencedTable: $$ActionBeliefsTableReferences
                                    ._beliefIdTable(db),
                                referencedColumn: $$ActionBeliefsTableReferences
                                    ._beliefIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ActionBeliefsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActionBeliefsTable,
      ActionBeliefRow,
      $$ActionBeliefsTableFilterComposer,
      $$ActionBeliefsTableOrderingComposer,
      $$ActionBeliefsTableAnnotationComposer,
      $$ActionBeliefsTableCreateCompanionBuilder,
      $$ActionBeliefsTableUpdateCompanionBuilder,
      (ActionBeliefRow, $$ActionBeliefsTableReferences),
      ActionBeliefRow,
      PrefetchHooks Function({bool beliefId})
    >;
typedef $$SharedLabelsTableCreateCompanionBuilder =
    SharedLabelsCompanion Function({
      required String itemId,
      required String label,
      required bool isGold,
      Value<bool?> correct,
      required int durationMs,
      required DateTime answeredAt,
      Value<int> rowid,
    });
typedef $$SharedLabelsTableUpdateCompanionBuilder =
    SharedLabelsCompanion Function({
      Value<String> itemId,
      Value<String> label,
      Value<bool> isGold,
      Value<bool?> correct,
      Value<int> durationMs,
      Value<DateTime> answeredAt,
      Value<int> rowid,
    });

class $$SharedLabelsTableFilterComposer
    extends Composer<_$AppDatabase, $SharedLabelsTable> {
  $$SharedLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGold => $composableBuilder(
    column: $table.isGold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SharedLabelsTableOrderingComposer
    extends Composer<_$AppDatabase, $SharedLabelsTable> {
  $$SharedLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGold => $composableBuilder(
    column: $table.isGold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get correct => $composableBuilder(
    column: $table.correct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SharedLabelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SharedLabelsTable> {
  $$SharedLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<bool> get isGold =>
      $composableBuilder(column: $table.isGold, builder: (column) => column);

  GeneratedColumn<bool> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );
}

class $$SharedLabelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SharedLabelsTable,
          SharedLabelRow,
          $$SharedLabelsTableFilterComposer,
          $$SharedLabelsTableOrderingComposer,
          $$SharedLabelsTableAnnotationComposer,
          $$SharedLabelsTableCreateCompanionBuilder,
          $$SharedLabelsTableUpdateCompanionBuilder,
          (
            SharedLabelRow,
            BaseReferences<_$AppDatabase, $SharedLabelsTable, SharedLabelRow>,
          ),
          SharedLabelRow,
          PrefetchHooks Function()
        > {
  $$SharedLabelsTableTableManager(_$AppDatabase db, $SharedLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SharedLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SharedLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SharedLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<bool> isGold = const Value.absent(),
                Value<bool?> correct = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> answeredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SharedLabelsCompanion(
                itemId: itemId,
                label: label,
                isGold: isGold,
                correct: correct,
                durationMs: durationMs,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String label,
                required bool isGold,
                Value<bool?> correct = const Value.absent(),
                required int durationMs,
                required DateTime answeredAt,
                Value<int> rowid = const Value.absent(),
              }) => SharedLabelsCompanion.insert(
                itemId: itemId,
                label: label,
                isGold: isGold,
                correct: correct,
                durationMs: durationMs,
                answeredAt: answeredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SharedLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SharedLabelsTable,
      SharedLabelRow,
      $$SharedLabelsTableFilterComposer,
      $$SharedLabelsTableOrderingComposer,
      $$SharedLabelsTableAnnotationComposer,
      $$SharedLabelsTableCreateCompanionBuilder,
      $$SharedLabelsTableUpdateCompanionBuilder,
      (
        SharedLabelRow,
        BaseReferences<_$AppDatabase, $SharedLabelsTable, SharedLabelRow>,
      ),
      SharedLabelRow,
      PrefetchHooks Function()
    >;
typedef $$ThoughtPatternsTableCreateCompanionBuilder =
    ThoughtPatternsCompanion Function({
      required ActionKind actionKind,
      required String actionId,
      required String prototypeId,
      required double similarity,
      required String modelVersion,
      Value<bool?> confirmed,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ThoughtPatternsTableUpdateCompanionBuilder =
    ThoughtPatternsCompanion Function({
      Value<ActionKind> actionKind,
      Value<String> actionId,
      Value<String> prototypeId,
      Value<double> similarity,
      Value<String> modelVersion,
      Value<bool?> confirmed,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ThoughtPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $ThoughtPatternsTable> {
  $$ThoughtPatternsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<ActionKind, ActionKind, String>
  get actionKind => $composableBuilder(
    column: $table.actionKind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prototypeId => $composableBuilder(
    column: $table.prototypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThoughtPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $ThoughtPatternsTable> {
  $$ThoughtPatternsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get actionKind => $composableBuilder(
    column: $table.actionKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionId => $composableBuilder(
    column: $table.actionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prototypeId => $composableBuilder(
    column: $table.prototypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmed => $composableBuilder(
    column: $table.confirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThoughtPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThoughtPatternsTable> {
  $$ThoughtPatternsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<ActionKind, String> get actionKind =>
      $composableBuilder(
        column: $table.actionKind,
        builder: (column) => column,
      );

  GeneratedColumn<String> get actionId =>
      $composableBuilder(column: $table.actionId, builder: (column) => column);

  GeneratedColumn<String> get prototypeId => $composableBuilder(
    column: $table.prototypeId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmed =>
      $composableBuilder(column: $table.confirmed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ThoughtPatternsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThoughtPatternsTable,
          ThoughtPatternRow,
          $$ThoughtPatternsTableFilterComposer,
          $$ThoughtPatternsTableOrderingComposer,
          $$ThoughtPatternsTableAnnotationComposer,
          $$ThoughtPatternsTableCreateCompanionBuilder,
          $$ThoughtPatternsTableUpdateCompanionBuilder,
          (
            ThoughtPatternRow,
            BaseReferences<
              _$AppDatabase,
              $ThoughtPatternsTable,
              ThoughtPatternRow
            >,
          ),
          ThoughtPatternRow,
          PrefetchHooks Function()
        > {
  $$ThoughtPatternsTableTableManager(
    _$AppDatabase db,
    $ThoughtPatternsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThoughtPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThoughtPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThoughtPatternsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<ActionKind> actionKind = const Value.absent(),
                Value<String> actionId = const Value.absent(),
                Value<String> prototypeId = const Value.absent(),
                Value<double> similarity = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<bool?> confirmed = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThoughtPatternsCompanion(
                actionKind: actionKind,
                actionId: actionId,
                prototypeId: prototypeId,
                similarity: similarity,
                modelVersion: modelVersion,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required ActionKind actionKind,
                required String actionId,
                required String prototypeId,
                required double similarity,
                required String modelVersion,
                Value<bool?> confirmed = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ThoughtPatternsCompanion.insert(
                actionKind: actionKind,
                actionId: actionId,
                prototypeId: prototypeId,
                similarity: similarity,
                modelVersion: modelVersion,
                confirmed: confirmed,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThoughtPatternsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThoughtPatternsTable,
      ThoughtPatternRow,
      $$ThoughtPatternsTableFilterComposer,
      $$ThoughtPatternsTableOrderingComposer,
      $$ThoughtPatternsTableAnnotationComposer,
      $$ThoughtPatternsTableCreateCompanionBuilder,
      $$ThoughtPatternsTableUpdateCompanionBuilder,
      (
        ThoughtPatternRow,
        BaseReferences<_$AppDatabase, $ThoughtPatternsTable, ThoughtPatternRow>,
      ),
      ThoughtPatternRow,
      PrefetchHooks Function()
    >;
typedef $$JudgeFeedbackTableCreateCompanionBuilder =
    JudgeFeedbackCompanion Function({
      required String id,
      required String judgeVersion,
      required String task,
      required String predicted,
      required double probability,
      required String userLabel,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$JudgeFeedbackTableUpdateCompanionBuilder =
    JudgeFeedbackCompanion Function({
      Value<String> id,
      Value<String> judgeVersion,
      Value<String> task,
      Value<String> predicted,
      Value<double> probability,
      Value<String> userLabel,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$JudgeFeedbackTableFilterComposer
    extends Composer<_$AppDatabase, $JudgeFeedbackTable> {
  $$JudgeFeedbackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get judgeVersion => $composableBuilder(
    column: $table.judgeVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get predicted => $composableBuilder(
    column: $table.predicted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userLabel => $composableBuilder(
    column: $table.userLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JudgeFeedbackTableOrderingComposer
    extends Composer<_$AppDatabase, $JudgeFeedbackTable> {
  $$JudgeFeedbackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get judgeVersion => $composableBuilder(
    column: $table.judgeVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get task => $composableBuilder(
    column: $table.task,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get predicted => $composableBuilder(
    column: $table.predicted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userLabel => $composableBuilder(
    column: $table.userLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JudgeFeedbackTableAnnotationComposer
    extends Composer<_$AppDatabase, $JudgeFeedbackTable> {
  $$JudgeFeedbackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get judgeVersion => $composableBuilder(
    column: $table.judgeVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get task =>
      $composableBuilder(column: $table.task, builder: (column) => column);

  GeneratedColumn<String> get predicted =>
      $composableBuilder(column: $table.predicted, builder: (column) => column);

  GeneratedColumn<double> get probability => $composableBuilder(
    column: $table.probability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userLabel =>
      $composableBuilder(column: $table.userLabel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$JudgeFeedbackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JudgeFeedbackTable,
          JudgeFeedbackRow,
          $$JudgeFeedbackTableFilterComposer,
          $$JudgeFeedbackTableOrderingComposer,
          $$JudgeFeedbackTableAnnotationComposer,
          $$JudgeFeedbackTableCreateCompanionBuilder,
          $$JudgeFeedbackTableUpdateCompanionBuilder,
          (
            JudgeFeedbackRow,
            BaseReferences<
              _$AppDatabase,
              $JudgeFeedbackTable,
              JudgeFeedbackRow
            >,
          ),
          JudgeFeedbackRow,
          PrefetchHooks Function()
        > {
  $$JudgeFeedbackTableTableManager(_$AppDatabase db, $JudgeFeedbackTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JudgeFeedbackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JudgeFeedbackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JudgeFeedbackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> judgeVersion = const Value.absent(),
                Value<String> task = const Value.absent(),
                Value<String> predicted = const Value.absent(),
                Value<double> probability = const Value.absent(),
                Value<String> userLabel = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JudgeFeedbackCompanion(
                id: id,
                judgeVersion: judgeVersion,
                task: task,
                predicted: predicted,
                probability: probability,
                userLabel: userLabel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String judgeVersion,
                required String task,
                required String predicted,
                required double probability,
                required String userLabel,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => JudgeFeedbackCompanion.insert(
                id: id,
                judgeVersion: judgeVersion,
                task: task,
                predicted: predicted,
                probability: probability,
                userLabel: userLabel,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JudgeFeedbackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JudgeFeedbackTable,
      JudgeFeedbackRow,
      $$JudgeFeedbackTableFilterComposer,
      $$JudgeFeedbackTableOrderingComposer,
      $$JudgeFeedbackTableAnnotationComposer,
      $$JudgeFeedbackTableCreateCompanionBuilder,
      $$JudgeFeedbackTableUpdateCompanionBuilder,
      (
        JudgeFeedbackRow,
        BaseReferences<_$AppDatabase, $JudgeFeedbackTable, JudgeFeedbackRow>,
      ),
      JudgeFeedbackRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DimensionsTableTableManager get dimensions =>
      $$DimensionsTableTableManager(_db, _db.dimensions);
  $$EmotionsTableTableManager get emotions =>
      $$EmotionsTableTableManager(_db, _db.emotions);
  $$TriggersTableTableManager get triggers =>
      $$TriggersTableTableManager(_db, _db.triggers);
  $$TopicsTableTableManager get topics =>
      $$TopicsTableTableManager(_db, _db.topics);
  $$DevotionalsTableTableManager get devotionals =>
      $$DevotionalsTableTableManager(_db, _db.devotionals);
  $$DevotionalTopicsTableTableManager get devotionalTopics =>
      $$DevotionalTopicsTableTableManager(_db, _db.devotionalTopics);
  $$PraxisEntriesTableTableManager get praxisEntries =>
      $$PraxisEntriesTableTableManager(_db, _db.praxisEntries);
  $$PraxisEmotionsTableTableManager get praxisEmotions =>
      $$PraxisEmotionsTableTableManager(_db, _db.praxisEmotions);
  $$PraxisTriggersTableTableManager get praxisTriggers =>
      $$PraxisTriggersTableTableManager(_db, _db.praxisTriggers);
  $$PraxisTopicsTableTableManager get praxisTopics =>
      $$PraxisTopicsTableTableManager(_db, _db.praxisTopics);
  $$PrayersTableTableManager get prayers =>
      $$PrayersTableTableManager(_db, _db.prayers);
  $$PrayerTopicsTableTableManager get prayerTopics =>
      $$PrayerTopicsTableTableManager(_db, _db.prayerTopics);
  $$PrayerPraxisLinksTableTableManager get prayerPraxisLinks =>
      $$PrayerPraxisLinksTableTableManager(_db, _db.prayerPraxisLinks);
  $$AttachmentsTableTableManager get attachments =>
      $$AttachmentsTableTableManager(_db, _db.attachments);
  $$BeliefsTableTableManager get beliefs =>
      $$BeliefsTableTableManager(_db, _db.beliefs);
  $$BeliefTopicsTableTableManager get beliefTopics =>
      $$BeliefTopicsTableTableManager(_db, _db.beliefTopics);
  $$BeliefEvidenceTableTableTableManager get beliefEvidenceTable =>
      $$BeliefEvidenceTableTableTableManager(_db, _db.beliefEvidenceTable);
  $$ActionBeliefsTableTableManager get actionBeliefs =>
      $$ActionBeliefsTableTableManager(_db, _db.actionBeliefs);
  $$SharedLabelsTableTableManager get sharedLabels =>
      $$SharedLabelsTableTableManager(_db, _db.sharedLabels);
  $$ThoughtPatternsTableTableManager get thoughtPatterns =>
      $$ThoughtPatternsTableTableManager(_db, _db.thoughtPatterns);
  $$JudgeFeedbackTableTableManager get judgeFeedback =>
      $$JudgeFeedbackTableTableManager(_db, _db.judgeFeedback);
}
