// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTableTable extends PatientsTable
    with TableInfo<$PatientsTableTable, PatientsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profileTypeMeta = const VerificationMeta(
    'profileType',
  );
  @override
  late final GeneratedColumn<String> profileType = GeneratedColumn<String>(
    'profile_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('autonomous'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _accessibilityConfigMeta =
      const VerificationMeta('accessibilityConfig');
  @override
  late final GeneratedColumn<String> accessibilityConfig =
      GeneratedColumn<String>(
        'accessibility_config',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _breakfastTimeMeta = const VerificationMeta(
    'breakfastTime',
  );
  @override
  late final GeneratedColumn<int> breakfastTime = GeneratedColumn<int>(
    'breakfast_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(420),
  );
  static const VerificationMeta _lunchTimeMeta = const VerificationMeta(
    'lunchTime',
  );
  @override
  late final GeneratedColumn<int> lunchTime = GeneratedColumn<int>(
    'lunch_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(780),
  );
  static const VerificationMeta _dinnerTimeMeta = const VerificationMeta(
    'dinnerTime',
  );
  @override
  late final GeneratedColumn<int> dinnerTime = GeneratedColumn<int>(
    'dinner_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1140),
  );
  static const VerificationMeta _sleepTimeMeta = const VerificationMeta(
    'sleepTime',
  );
  @override
  late final GeneratedColumn<int> sleepTime = GeneratedColumn<int>(
    'sleep_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1260),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthDate,
    photoPath,
    profileType,
    isActive,
    accessibilityConfig,
    breakfastTime,
    lunchTime,
    dinnerTime,
    sleepTime,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(
    Insertable<PatientsTableData> instance, {
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
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('profile_type')) {
      context.handle(
        _profileTypeMeta,
        profileType.isAcceptableOrUnknown(
          data['profile_type']!,
          _profileTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('accessibility_config')) {
      context.handle(
        _accessibilityConfigMeta,
        accessibilityConfig.isAcceptableOrUnknown(
          data['accessibility_config']!,
          _accessibilityConfigMeta,
        ),
      );
    }
    if (data.containsKey('breakfast_time')) {
      context.handle(
        _breakfastTimeMeta,
        breakfastTime.isAcceptableOrUnknown(
          data['breakfast_time']!,
          _breakfastTimeMeta,
        ),
      );
    }
    if (data.containsKey('lunch_time')) {
      context.handle(
        _lunchTimeMeta,
        lunchTime.isAcceptableOrUnknown(data['lunch_time']!, _lunchTimeMeta),
      );
    }
    if (data.containsKey('dinner_time')) {
      context.handle(
        _dinnerTimeMeta,
        dinnerTime.isAcceptableOrUnknown(data['dinner_time']!, _dinnerTimeMeta),
      );
    }
    if (data.containsKey('sleep_time')) {
      context.handle(
        _sleepTimeMeta,
        sleepTime.isAcceptableOrUnknown(data['sleep_time']!, _sleepTimeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      profileType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_type'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      accessibilityConfig: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accessibility_config'],
      )!,
      breakfastTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}breakfast_time'],
      )!,
      lunchTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lunch_time'],
      )!,
      dinnerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dinner_time'],
      )!,
      sleepTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sleep_time'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PatientsTableTable createAlias(String alias) {
    return $PatientsTableTable(attachedDatabase, alias);
  }
}

class PatientsTableData extends DataClass
    implements Insertable<PatientsTableData> {
  final String id;
  final String name;
  final DateTime? birthDate;
  final String? photoPath;
  final String profileType;
  final bool isActive;
  final String accessibilityConfig;
  final int breakfastTime;
  final int lunchTime;
  final int dinnerTime;
  final int sleepTime;
  final DateTime createdAt;
  const PatientsTableData({
    required this.id,
    required this.name,
    this.birthDate,
    this.photoPath,
    required this.profileType,
    required this.isActive,
    required this.accessibilityConfig,
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.sleepTime,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['profile_type'] = Variable<String>(profileType);
    map['is_active'] = Variable<bool>(isActive);
    map['accessibility_config'] = Variable<String>(accessibilityConfig);
    map['breakfast_time'] = Variable<int>(breakfastTime);
    map['lunch_time'] = Variable<int>(lunchTime);
    map['dinner_time'] = Variable<int>(dinnerTime);
    map['sleep_time'] = Variable<int>(sleepTime);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PatientsTableCompanion toCompanion(bool nullToAbsent) {
    return PatientsTableCompanion(
      id: Value(id),
      name: Value(name),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      profileType: Value(profileType),
      isActive: Value(isActive),
      accessibilityConfig: Value(accessibilityConfig),
      breakfastTime: Value(breakfastTime),
      lunchTime: Value(lunchTime),
      dinnerTime: Value(dinnerTime),
      sleepTime: Value(sleepTime),
      createdAt: Value(createdAt),
    );
  }

  factory PatientsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      profileType: serializer.fromJson<String>(json['profileType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      accessibilityConfig: serializer.fromJson<String>(
        json['accessibilityConfig'],
      ),
      breakfastTime: serializer.fromJson<int>(json['breakfastTime']),
      lunchTime: serializer.fromJson<int>(json['lunchTime']),
      dinnerTime: serializer.fromJson<int>(json['dinnerTime']),
      sleepTime: serializer.fromJson<int>(json['sleepTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'photoPath': serializer.toJson<String?>(photoPath),
      'profileType': serializer.toJson<String>(profileType),
      'isActive': serializer.toJson<bool>(isActive),
      'accessibilityConfig': serializer.toJson<String>(accessibilityConfig),
      'breakfastTime': serializer.toJson<int>(breakfastTime),
      'lunchTime': serializer.toJson<int>(lunchTime),
      'dinnerTime': serializer.toJson<int>(dinnerTime),
      'sleepTime': serializer.toJson<int>(sleepTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PatientsTableData copyWith({
    String? id,
    String? name,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    String? profileType,
    bool? isActive,
    String? accessibilityConfig,
    int? breakfastTime,
    int? lunchTime,
    int? dinnerTime,
    int? sleepTime,
    DateTime? createdAt,
  }) => PatientsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    profileType: profileType ?? this.profileType,
    isActive: isActive ?? this.isActive,
    accessibilityConfig: accessibilityConfig ?? this.accessibilityConfig,
    breakfastTime: breakfastTime ?? this.breakfastTime,
    lunchTime: lunchTime ?? this.lunchTime,
    dinnerTime: dinnerTime ?? this.dinnerTime,
    sleepTime: sleepTime ?? this.sleepTime,
    createdAt: createdAt ?? this.createdAt,
  );
  PatientsTableData copyWithCompanion(PatientsTableCompanion data) {
    return PatientsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      profileType: data.profileType.present
          ? data.profileType.value
          : this.profileType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      accessibilityConfig: data.accessibilityConfig.present
          ? data.accessibilityConfig.value
          : this.accessibilityConfig,
      breakfastTime: data.breakfastTime.present
          ? data.breakfastTime.value
          : this.breakfastTime,
      lunchTime: data.lunchTime.present ? data.lunchTime.value : this.lunchTime,
      dinnerTime: data.dinnerTime.present
          ? data.dinnerTime.value
          : this.dinnerTime,
      sleepTime: data.sleepTime.present ? data.sleepTime.value : this.sleepTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('profileType: $profileType, ')
          ..write('isActive: $isActive, ')
          ..write('accessibilityConfig: $accessibilityConfig, ')
          ..write('breakfastTime: $breakfastTime, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerTime: $dinnerTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthDate,
    photoPath,
    profileType,
    isActive,
    accessibilityConfig,
    breakfastTime,
    lunchTime,
    dinnerTime,
    sleepTime,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthDate == this.birthDate &&
          other.photoPath == this.photoPath &&
          other.profileType == this.profileType &&
          other.isActive == this.isActive &&
          other.accessibilityConfig == this.accessibilityConfig &&
          other.breakfastTime == this.breakfastTime &&
          other.lunchTime == this.lunchTime &&
          other.dinnerTime == this.dinnerTime &&
          other.sleepTime == this.sleepTime &&
          other.createdAt == this.createdAt);
}

class PatientsTableCompanion extends UpdateCompanion<PatientsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime?> birthDate;
  final Value<String?> photoPath;
  final Value<String> profileType;
  final Value<bool> isActive;
  final Value<String> accessibilityConfig;
  final Value<int> breakfastTime;
  final Value<int> lunchTime;
  final Value<int> dinnerTime;
  final Value<int> sleepTime;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PatientsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.profileType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.accessibilityConfig = const Value.absent(),
    this.breakfastTime = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerTime = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsTableCompanion.insert({
    required String id,
    required String name,
    this.birthDate = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.profileType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.accessibilityConfig = const Value.absent(),
    this.breakfastTime = const Value.absent(),
    this.lunchTime = const Value.absent(),
    this.dinnerTime = const Value.absent(),
    this.sleepTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<PatientsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? birthDate,
    Expression<String>? photoPath,
    Expression<String>? profileType,
    Expression<bool>? isActive,
    Expression<String>? accessibilityConfig,
    Expression<int>? breakfastTime,
    Expression<int>? lunchTime,
    Expression<int>? dinnerTime,
    Expression<int>? sleepTime,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthDate != null) 'birth_date': birthDate,
      if (photoPath != null) 'photo_path': photoPath,
      if (profileType != null) 'profile_type': profileType,
      if (isActive != null) 'is_active': isActive,
      if (accessibilityConfig != null)
        'accessibility_config': accessibilityConfig,
      if (breakfastTime != null) 'breakfast_time': breakfastTime,
      if (lunchTime != null) 'lunch_time': lunchTime,
      if (dinnerTime != null) 'dinner_time': dinnerTime,
      if (sleepTime != null) 'sleep_time': sleepTime,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime?>? birthDate,
    Value<String?>? photoPath,
    Value<String>? profileType,
    Value<bool>? isActive,
    Value<String>? accessibilityConfig,
    Value<int>? breakfastTime,
    Value<int>? lunchTime,
    Value<int>? dinnerTime,
    Value<int>? sleepTime,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PatientsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      photoPath: photoPath ?? this.photoPath,
      profileType: profileType ?? this.profileType,
      isActive: isActive ?? this.isActive,
      accessibilityConfig: accessibilityConfig ?? this.accessibilityConfig,
      breakfastTime: breakfastTime ?? this.breakfastTime,
      lunchTime: lunchTime ?? this.lunchTime,
      dinnerTime: dinnerTime ?? this.dinnerTime,
      sleepTime: sleepTime ?? this.sleepTime,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (profileType.present) {
      map['profile_type'] = Variable<String>(profileType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (accessibilityConfig.present) {
      map['accessibility_config'] = Variable<String>(accessibilityConfig.value);
    }
    if (breakfastTime.present) {
      map['breakfast_time'] = Variable<int>(breakfastTime.value);
    }
    if (lunchTime.present) {
      map['lunch_time'] = Variable<int>(lunchTime.value);
    }
    if (dinnerTime.present) {
      map['dinner_time'] = Variable<int>(dinnerTime.value);
    }
    if (sleepTime.present) {
      map['sleep_time'] = Variable<int>(sleepTime.value);
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
    return (StringBuffer('PatientsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoPath: $photoPath, ')
          ..write('profileType: $profileType, ')
          ..write('isActive: $isActive, ')
          ..write('accessibilityConfig: $accessibilityConfig, ')
          ..write('breakfastTime: $breakfastTime, ')
          ..write('lunchTime: $lunchTime, ')
          ..write('dinnerTime: $dinnerTime, ')
          ..write('sleepTime: $sleepTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationsTableTable extends MedicationsTable
    with TableInfo<$MedicationsTableTable, MedicationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
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
  static const VerificationMeta _activeIngredientMeta = const VerificationMeta(
    'activeIngredient',
  );
  @override
  late final GeneratedColumn<String> activeIngredient = GeneratedColumn<String>(
    'active_ingredient',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _presentationMeta = const VerificationMeta(
    'presentation',
  );
  @override
  late final GeneratedColumn<String> presentation = GeneratedColumn<String>(
    'presentation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('tablet'),
  );
  static const VerificationMeta _boxPhotoPathMeta = const VerificationMeta(
    'boxPhotoPath',
  );
  @override
  late final GeneratedColumn<String> boxPhotoPath = GeneratedColumn<String>(
    'box_photo_path',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    name,
    activeIngredient,
    presentation,
    boxPhotoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('active_ingredient')) {
      context.handle(
        _activeIngredientMeta,
        activeIngredient.isAcceptableOrUnknown(
          data['active_ingredient']!,
          _activeIngredientMeta,
        ),
      );
    }
    if (data.containsKey('presentation')) {
      context.handle(
        _presentationMeta,
        presentation.isAcceptableOrUnknown(
          data['presentation']!,
          _presentationMeta,
        ),
      );
    }
    if (data.containsKey('box_photo_path')) {
      context.handle(
        _boxPhotoPathMeta,
        boxPhotoPath.isAcceptableOrUnknown(
          data['box_photo_path']!,
          _boxPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      activeIngredient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_ingredient'],
      ),
      presentation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}presentation'],
      )!,
      boxPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}box_photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MedicationsTableTable createAlias(String alias) {
    return $MedicationsTableTable(attachedDatabase, alias);
  }
}

class MedicationsTableData extends DataClass
    implements Insertable<MedicationsTableData> {
  final String id;
  final String patientId;
  final String name;
  final String? activeIngredient;
  final String presentation;
  final String? boxPhotoPath;
  final DateTime createdAt;
  const MedicationsTableData({
    required this.id,
    required this.patientId,
    required this.name,
    this.activeIngredient,
    required this.presentation,
    this.boxPhotoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || activeIngredient != null) {
      map['active_ingredient'] = Variable<String>(activeIngredient);
    }
    map['presentation'] = Variable<String>(presentation);
    if (!nullToAbsent || boxPhotoPath != null) {
      map['box_photo_path'] = Variable<String>(boxPhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicationsTableCompanion toCompanion(bool nullToAbsent) {
    return MedicationsTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      name: Value(name),
      activeIngredient: activeIngredient == null && nullToAbsent
          ? const Value.absent()
          : Value(activeIngredient),
      presentation: Value(presentation),
      boxPhotoPath: boxPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(boxPhotoPath),
      createdAt: Value(createdAt),
    );
  }

  factory MedicationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationsTableData(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      name: serializer.fromJson<String>(json['name']),
      activeIngredient: serializer.fromJson<String?>(json['activeIngredient']),
      presentation: serializer.fromJson<String>(json['presentation']),
      boxPhotoPath: serializer.fromJson<String?>(json['boxPhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'name': serializer.toJson<String>(name),
      'activeIngredient': serializer.toJson<String?>(activeIngredient),
      'presentation': serializer.toJson<String>(presentation),
      'boxPhotoPath': serializer.toJson<String?>(boxPhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicationsTableData copyWith({
    String? id,
    String? patientId,
    String? name,
    Value<String?> activeIngredient = const Value.absent(),
    String? presentation,
    Value<String?> boxPhotoPath = const Value.absent(),
    DateTime? createdAt,
  }) => MedicationsTableData(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    name: name ?? this.name,
    activeIngredient: activeIngredient.present
        ? activeIngredient.value
        : this.activeIngredient,
    presentation: presentation ?? this.presentation,
    boxPhotoPath: boxPhotoPath.present ? boxPhotoPath.value : this.boxPhotoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  MedicationsTableData copyWithCompanion(MedicationsTableCompanion data) {
    return MedicationsTableData(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      name: data.name.present ? data.name.value : this.name,
      activeIngredient: data.activeIngredient.present
          ? data.activeIngredient.value
          : this.activeIngredient,
      presentation: data.presentation.present
          ? data.presentation.value
          : this.presentation,
      boxPhotoPath: data.boxPhotoPath.present
          ? data.boxPhotoPath.value
          : this.boxPhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationsTableData(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('presentation: $presentation, ')
          ..write('boxPhotoPath: $boxPhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    name,
    activeIngredient,
    presentation,
    boxPhotoPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationsTableData &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.name == this.name &&
          other.activeIngredient == this.activeIngredient &&
          other.presentation == this.presentation &&
          other.boxPhotoPath == this.boxPhotoPath &&
          other.createdAt == this.createdAt);
}

class MedicationsTableCompanion extends UpdateCompanion<MedicationsTableData> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> name;
  final Value<String?> activeIngredient;
  final Value<String> presentation;
  final Value<String?> boxPhotoPath;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicationsTableCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.name = const Value.absent(),
    this.activeIngredient = const Value.absent(),
    this.presentation = const Value.absent(),
    this.boxPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationsTableCompanion.insert({
    required String id,
    required String patientId,
    required String name,
    this.activeIngredient = const Value.absent(),
    this.presentation = const Value.absent(),
    this.boxPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       name = Value(name);
  static Insertable<MedicationsTableData> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? name,
    Expression<String>? activeIngredient,
    Expression<String>? presentation,
    Expression<String>? boxPhotoPath,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (name != null) 'name': name,
      if (activeIngredient != null) 'active_ingredient': activeIngredient,
      if (presentation != null) 'presentation': presentation,
      if (boxPhotoPath != null) 'box_photo_path': boxPhotoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? name,
    Value<String?>? activeIngredient,
    Value<String>? presentation,
    Value<String?>? boxPhotoPath,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MedicationsTableCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      name: name ?? this.name,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      presentation: presentation ?? this.presentation,
      boxPhotoPath: boxPhotoPath ?? this.boxPhotoPath,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (activeIngredient.present) {
      map['active_ingredient'] = Variable<String>(activeIngredient.value);
    }
    if (presentation.present) {
      map['presentation'] = Variable<String>(presentation.value);
    }
    if (boxPhotoPath.present) {
      map['box_photo_path'] = Variable<String>(boxPhotoPath.value);
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
    return (StringBuffer('MedicationsTableCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('name: $name, ')
          ..write('activeIngredient: $activeIngredient, ')
          ..write('presentation: $presentation, ')
          ..write('boxPhotoPath: $boxPhotoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreatmentsTableTable extends TreatmentsTable
    with TableInfo<$TreatmentsTableTable, TreatmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _medicationIdMeta = const VerificationMeta(
    'medicationId',
  );
  @override
  late final GeneratedColumn<String> medicationId = GeneratedColumn<String>(
    'medication_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medications (id)',
    ),
  );
  static const VerificationMeta _doseAmountMeta = const VerificationMeta(
    'doseAmount',
  );
  @override
  late final GeneratedColumn<double> doseAmount = GeneratedColumn<double>(
    'dose_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyTypeMeta = const VerificationMeta(
    'frequencyType',
  );
  @override
  late final GeneratedColumn<String> frequencyType = GeneratedColumn<String>(
    'frequency_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyValueMeta = const VerificationMeta(
    'frequencyValue',
  );
  @override
  late final GeneratedColumn<int> frequencyValue = GeneratedColumn<int>(
    'frequency_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('oral'),
  );
  static const VerificationMeta _specialInstructionsMeta =
      const VerificationMeta('specialInstructions');
  @override
  late final GeneratedColumn<String> specialInstructions =
      GeneratedColumn<String>(
        'special_instructions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _endCriterionTypeMeta = const VerificationMeta(
    'endCriterionType',
  );
  @override
  late final GeneratedColumn<String> endCriterionType = GeneratedColumn<String>(
    'end_criterion_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalDosesMeta = const VerificationMeta(
    'totalDoses',
  );
  @override
  late final GeneratedColumn<int> totalDoses = GeneratedColumn<int>(
    'total_doses',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calculatedEndDateMeta = const VerificationMeta(
    'calculatedEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> calculatedEndDate =
      GeneratedColumn<DateTime>(
        'calculated_end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isCriticalMeta = const VerificationMeta(
    'isCritical',
  );
  @override
  late final GeneratedColumn<bool> isCritical = GeneratedColumn<bool>(
    'is_critical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_critical" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _originMeta = const VerificationMeta('origin');
  @override
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manual'),
  );
  static const VerificationMeta _prescriptionImagePathMeta =
      const VerificationMeta('prescriptionImagePath');
  @override
  late final GeneratedColumn<String> prescriptionImagePath =
      GeneratedColumn<String>(
        'prescription_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _prescriptionOcrTextMeta =
      const VerificationMeta('prescriptionOcrText');
  @override
  late final GeneratedColumn<String> prescriptionOcrText =
      GeneratedColumn<String>(
        'prescription_ocr_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    medicationId,
    doseAmount,
    doseUnit,
    frequencyType,
    frequencyValue,
    route,
    specialInstructions,
    endCriterionType,
    durationDays,
    totalDoses,
    startDate,
    calculatedEndDate,
    isCritical,
    status,
    origin,
    prescriptionImagePath,
    prescriptionOcrText,
    notes,
    createdAt,
    endedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreatmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('medication_id')) {
      context.handle(
        _medicationIdMeta,
        medicationId.isAcceptableOrUnknown(
          data['medication_id']!,
          _medicationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationIdMeta);
    }
    if (data.containsKey('dose_amount')) {
      context.handle(
        _doseAmountMeta,
        doseAmount.isAcceptableOrUnknown(data['dose_amount']!, _doseAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_doseAmountMeta);
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_doseUnitMeta);
    }
    if (data.containsKey('frequency_type')) {
      context.handle(
        _frequencyTypeMeta,
        frequencyType.isAcceptableOrUnknown(
          data['frequency_type']!,
          _frequencyTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_frequencyTypeMeta);
    }
    if (data.containsKey('frequency_value')) {
      context.handle(
        _frequencyValueMeta,
        frequencyValue.isAcceptableOrUnknown(
          data['frequency_value']!,
          _frequencyValueMeta,
        ),
      );
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('special_instructions')) {
      context.handle(
        _specialInstructionsMeta,
        specialInstructions.isAcceptableOrUnknown(
          data['special_instructions']!,
          _specialInstructionsMeta,
        ),
      );
    }
    if (data.containsKey('end_criterion_type')) {
      context.handle(
        _endCriterionTypeMeta,
        endCriterionType.isAcceptableOrUnknown(
          data['end_criterion_type']!,
          _endCriterionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endCriterionTypeMeta);
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    }
    if (data.containsKey('total_doses')) {
      context.handle(
        _totalDosesMeta,
        totalDoses.isAcceptableOrUnknown(data['total_doses']!, _totalDosesMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('calculated_end_date')) {
      context.handle(
        _calculatedEndDateMeta,
        calculatedEndDate.isAcceptableOrUnknown(
          data['calculated_end_date']!,
          _calculatedEndDateMeta,
        ),
      );
    }
    if (data.containsKey('is_critical')) {
      context.handle(
        _isCriticalMeta,
        isCritical.isAcceptableOrUnknown(data['is_critical']!, _isCriticalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('origin')) {
      context.handle(
        _originMeta,
        origin.isAcceptableOrUnknown(data['origin']!, _originMeta),
      );
    }
    if (data.containsKey('prescription_image_path')) {
      context.handle(
        _prescriptionImagePathMeta,
        prescriptionImagePath.isAcceptableOrUnknown(
          data['prescription_image_path']!,
          _prescriptionImagePathMeta,
        ),
      );
    }
    if (data.containsKey('prescription_ocr_text')) {
      context.handle(
        _prescriptionOcrTextMeta,
        prescriptionOcrText.isAcceptableOrUnknown(
          data['prescription_ocr_text']!,
          _prescriptionOcrTextMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreatmentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreatmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      medicationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_id'],
      )!,
      doseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_amount'],
      )!,
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      )!,
      frequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency_type'],
      )!,
      frequencyValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency_value'],
      ),
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      )!,
      specialInstructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_instructions'],
      ),
      endCriterionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_criterion_type'],
      )!,
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      ),
      totalDoses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_doses'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      calculatedEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}calculated_end_date'],
      ),
      isCritical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_critical'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      prescriptionImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_image_path'],
      ),
      prescriptionOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prescription_ocr_text'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $TreatmentsTableTable createAlias(String alias) {
    return $TreatmentsTableTable(attachedDatabase, alias);
  }
}

class TreatmentsTableData extends DataClass
    implements Insertable<TreatmentsTableData> {
  final String id;
  final String patientId;
  final String medicationId;
  final double doseAmount;
  final String doseUnit;
  final String frequencyType;
  final int? frequencyValue;
  final String route;
  final String? specialInstructions;
  final String endCriterionType;
  final int? durationDays;
  final int? totalDoses;
  final DateTime startDate;
  final DateTime? calculatedEndDate;
  final bool isCritical;
  final String status;
  final String origin;
  final String? prescriptionImagePath;
  final String? prescriptionOcrText;
  final String? notes;
  final DateTime createdAt;
  final DateTime? endedAt;
  const TreatmentsTableData({
    required this.id,
    required this.patientId,
    required this.medicationId,
    required this.doseAmount,
    required this.doseUnit,
    required this.frequencyType,
    this.frequencyValue,
    required this.route,
    this.specialInstructions,
    required this.endCriterionType,
    this.durationDays,
    this.totalDoses,
    required this.startDate,
    this.calculatedEndDate,
    required this.isCritical,
    required this.status,
    required this.origin,
    this.prescriptionImagePath,
    this.prescriptionOcrText,
    this.notes,
    required this.createdAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['medication_id'] = Variable<String>(medicationId);
    map['dose_amount'] = Variable<double>(doseAmount);
    map['dose_unit'] = Variable<String>(doseUnit);
    map['frequency_type'] = Variable<String>(frequencyType);
    if (!nullToAbsent || frequencyValue != null) {
      map['frequency_value'] = Variable<int>(frequencyValue);
    }
    map['route'] = Variable<String>(route);
    if (!nullToAbsent || specialInstructions != null) {
      map['special_instructions'] = Variable<String>(specialInstructions);
    }
    map['end_criterion_type'] = Variable<String>(endCriterionType);
    if (!nullToAbsent || durationDays != null) {
      map['duration_days'] = Variable<int>(durationDays);
    }
    if (!nullToAbsent || totalDoses != null) {
      map['total_doses'] = Variable<int>(totalDoses);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || calculatedEndDate != null) {
      map['calculated_end_date'] = Variable<DateTime>(calculatedEndDate);
    }
    map['is_critical'] = Variable<bool>(isCritical);
    map['status'] = Variable<String>(status);
    map['origin'] = Variable<String>(origin);
    if (!nullToAbsent || prescriptionImagePath != null) {
      map['prescription_image_path'] = Variable<String>(prescriptionImagePath);
    }
    if (!nullToAbsent || prescriptionOcrText != null) {
      map['prescription_ocr_text'] = Variable<String>(prescriptionOcrText);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  TreatmentsTableCompanion toCompanion(bool nullToAbsent) {
    return TreatmentsTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      medicationId: Value(medicationId),
      doseAmount: Value(doseAmount),
      doseUnit: Value(doseUnit),
      frequencyType: Value(frequencyType),
      frequencyValue: frequencyValue == null && nullToAbsent
          ? const Value.absent()
          : Value(frequencyValue),
      route: Value(route),
      specialInstructions: specialInstructions == null && nullToAbsent
          ? const Value.absent()
          : Value(specialInstructions),
      endCriterionType: Value(endCriterionType),
      durationDays: durationDays == null && nullToAbsent
          ? const Value.absent()
          : Value(durationDays),
      totalDoses: totalDoses == null && nullToAbsent
          ? const Value.absent()
          : Value(totalDoses),
      startDate: Value(startDate),
      calculatedEndDate: calculatedEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(calculatedEndDate),
      isCritical: Value(isCritical),
      status: Value(status),
      origin: Value(origin),
      prescriptionImagePath: prescriptionImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriptionImagePath),
      prescriptionOcrText: prescriptionOcrText == null && nullToAbsent
          ? const Value.absent()
          : Value(prescriptionOcrText),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory TreatmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreatmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      medicationId: serializer.fromJson<String>(json['medicationId']),
      doseAmount: serializer.fromJson<double>(json['doseAmount']),
      doseUnit: serializer.fromJson<String>(json['doseUnit']),
      frequencyType: serializer.fromJson<String>(json['frequencyType']),
      frequencyValue: serializer.fromJson<int?>(json['frequencyValue']),
      route: serializer.fromJson<String>(json['route']),
      specialInstructions: serializer.fromJson<String?>(
        json['specialInstructions'],
      ),
      endCriterionType: serializer.fromJson<String>(json['endCriterionType']),
      durationDays: serializer.fromJson<int?>(json['durationDays']),
      totalDoses: serializer.fromJson<int?>(json['totalDoses']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      calculatedEndDate: serializer.fromJson<DateTime?>(
        json['calculatedEndDate'],
      ),
      isCritical: serializer.fromJson<bool>(json['isCritical']),
      status: serializer.fromJson<String>(json['status']),
      origin: serializer.fromJson<String>(json['origin']),
      prescriptionImagePath: serializer.fromJson<String?>(
        json['prescriptionImagePath'],
      ),
      prescriptionOcrText: serializer.fromJson<String?>(
        json['prescriptionOcrText'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'medicationId': serializer.toJson<String>(medicationId),
      'doseAmount': serializer.toJson<double>(doseAmount),
      'doseUnit': serializer.toJson<String>(doseUnit),
      'frequencyType': serializer.toJson<String>(frequencyType),
      'frequencyValue': serializer.toJson<int?>(frequencyValue),
      'route': serializer.toJson<String>(route),
      'specialInstructions': serializer.toJson<String?>(specialInstructions),
      'endCriterionType': serializer.toJson<String>(endCriterionType),
      'durationDays': serializer.toJson<int?>(durationDays),
      'totalDoses': serializer.toJson<int?>(totalDoses),
      'startDate': serializer.toJson<DateTime>(startDate),
      'calculatedEndDate': serializer.toJson<DateTime?>(calculatedEndDate),
      'isCritical': serializer.toJson<bool>(isCritical),
      'status': serializer.toJson<String>(status),
      'origin': serializer.toJson<String>(origin),
      'prescriptionImagePath': serializer.toJson<String?>(
        prescriptionImagePath,
      ),
      'prescriptionOcrText': serializer.toJson<String?>(prescriptionOcrText),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  TreatmentsTableData copyWith({
    String? id,
    String? patientId,
    String? medicationId,
    double? doseAmount,
    String? doseUnit,
    String? frequencyType,
    Value<int?> frequencyValue = const Value.absent(),
    String? route,
    Value<String?> specialInstructions = const Value.absent(),
    String? endCriterionType,
    Value<int?> durationDays = const Value.absent(),
    Value<int?> totalDoses = const Value.absent(),
    DateTime? startDate,
    Value<DateTime?> calculatedEndDate = const Value.absent(),
    bool? isCritical,
    String? status,
    String? origin,
    Value<String?> prescriptionImagePath = const Value.absent(),
    Value<String?> prescriptionOcrText = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => TreatmentsTableData(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    medicationId: medicationId ?? this.medicationId,
    doseAmount: doseAmount ?? this.doseAmount,
    doseUnit: doseUnit ?? this.doseUnit,
    frequencyType: frequencyType ?? this.frequencyType,
    frequencyValue: frequencyValue.present
        ? frequencyValue.value
        : this.frequencyValue,
    route: route ?? this.route,
    specialInstructions: specialInstructions.present
        ? specialInstructions.value
        : this.specialInstructions,
    endCriterionType: endCriterionType ?? this.endCriterionType,
    durationDays: durationDays.present ? durationDays.value : this.durationDays,
    totalDoses: totalDoses.present ? totalDoses.value : this.totalDoses,
    startDate: startDate ?? this.startDate,
    calculatedEndDate: calculatedEndDate.present
        ? calculatedEndDate.value
        : this.calculatedEndDate,
    isCritical: isCritical ?? this.isCritical,
    status: status ?? this.status,
    origin: origin ?? this.origin,
    prescriptionImagePath: prescriptionImagePath.present
        ? prescriptionImagePath.value
        : this.prescriptionImagePath,
    prescriptionOcrText: prescriptionOcrText.present
        ? prescriptionOcrText.value
        : this.prescriptionOcrText,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  TreatmentsTableData copyWithCompanion(TreatmentsTableCompanion data) {
    return TreatmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      medicationId: data.medicationId.present
          ? data.medicationId.value
          : this.medicationId,
      doseAmount: data.doseAmount.present
          ? data.doseAmount.value
          : this.doseAmount,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      frequencyType: data.frequencyType.present
          ? data.frequencyType.value
          : this.frequencyType,
      frequencyValue: data.frequencyValue.present
          ? data.frequencyValue.value
          : this.frequencyValue,
      route: data.route.present ? data.route.value : this.route,
      specialInstructions: data.specialInstructions.present
          ? data.specialInstructions.value
          : this.specialInstructions,
      endCriterionType: data.endCriterionType.present
          ? data.endCriterionType.value
          : this.endCriterionType,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      totalDoses: data.totalDoses.present
          ? data.totalDoses.value
          : this.totalDoses,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      calculatedEndDate: data.calculatedEndDate.present
          ? data.calculatedEndDate.value
          : this.calculatedEndDate,
      isCritical: data.isCritical.present
          ? data.isCritical.value
          : this.isCritical,
      status: data.status.present ? data.status.value : this.status,
      origin: data.origin.present ? data.origin.value : this.origin,
      prescriptionImagePath: data.prescriptionImagePath.present
          ? data.prescriptionImagePath.value
          : this.prescriptionImagePath,
      prescriptionOcrText: data.prescriptionOcrText.present
          ? data.prescriptionOcrText.value
          : this.prescriptionOcrText,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentsTableData(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('medicationId: $medicationId, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('frequencyValue: $frequencyValue, ')
          ..write('route: $route, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('endCriterionType: $endCriterionType, ')
          ..write('durationDays: $durationDays, ')
          ..write('totalDoses: $totalDoses, ')
          ..write('startDate: $startDate, ')
          ..write('calculatedEndDate: $calculatedEndDate, ')
          ..write('isCritical: $isCritical, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('prescriptionImagePath: $prescriptionImagePath, ')
          ..write('prescriptionOcrText: $prescriptionOcrText, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    patientId,
    medicationId,
    doseAmount,
    doseUnit,
    frequencyType,
    frequencyValue,
    route,
    specialInstructions,
    endCriterionType,
    durationDays,
    totalDoses,
    startDate,
    calculatedEndDate,
    isCritical,
    status,
    origin,
    prescriptionImagePath,
    prescriptionOcrText,
    notes,
    createdAt,
    endedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreatmentsTableData &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.medicationId == this.medicationId &&
          other.doseAmount == this.doseAmount &&
          other.doseUnit == this.doseUnit &&
          other.frequencyType == this.frequencyType &&
          other.frequencyValue == this.frequencyValue &&
          other.route == this.route &&
          other.specialInstructions == this.specialInstructions &&
          other.endCriterionType == this.endCriterionType &&
          other.durationDays == this.durationDays &&
          other.totalDoses == this.totalDoses &&
          other.startDate == this.startDate &&
          other.calculatedEndDate == this.calculatedEndDate &&
          other.isCritical == this.isCritical &&
          other.status == this.status &&
          other.origin == this.origin &&
          other.prescriptionImagePath == this.prescriptionImagePath &&
          other.prescriptionOcrText == this.prescriptionOcrText &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.endedAt == this.endedAt);
}

class TreatmentsTableCompanion extends UpdateCompanion<TreatmentsTableData> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> medicationId;
  final Value<double> doseAmount;
  final Value<String> doseUnit;
  final Value<String> frequencyType;
  final Value<int?> frequencyValue;
  final Value<String> route;
  final Value<String?> specialInstructions;
  final Value<String> endCriterionType;
  final Value<int?> durationDays;
  final Value<int?> totalDoses;
  final Value<DateTime> startDate;
  final Value<DateTime?> calculatedEndDate;
  final Value<bool> isCritical;
  final Value<String> status;
  final Value<String> origin;
  final Value<String?> prescriptionImagePath;
  final Value<String?> prescriptionOcrText;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime?> endedAt;
  final Value<int> rowid;
  const TreatmentsTableCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.medicationId = const Value.absent(),
    this.doseAmount = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.frequencyType = const Value.absent(),
    this.frequencyValue = const Value.absent(),
    this.route = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    this.endCriterionType = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.totalDoses = const Value.absent(),
    this.startDate = const Value.absent(),
    this.calculatedEndDate = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.prescriptionImagePath = const Value.absent(),
    this.prescriptionOcrText = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreatmentsTableCompanion.insert({
    required String id,
    required String patientId,
    required String medicationId,
    required double doseAmount,
    required String doseUnit,
    required String frequencyType,
    this.frequencyValue = const Value.absent(),
    this.route = const Value.absent(),
    this.specialInstructions = const Value.absent(),
    required String endCriterionType,
    this.durationDays = const Value.absent(),
    this.totalDoses = const Value.absent(),
    required DateTime startDate,
    this.calculatedEndDate = const Value.absent(),
    this.isCritical = const Value.absent(),
    this.status = const Value.absent(),
    this.origin = const Value.absent(),
    this.prescriptionImagePath = const Value.absent(),
    this.prescriptionOcrText = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       medicationId = Value(medicationId),
       doseAmount = Value(doseAmount),
       doseUnit = Value(doseUnit),
       frequencyType = Value(frequencyType),
       endCriterionType = Value(endCriterionType),
       startDate = Value(startDate);
  static Insertable<TreatmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? medicationId,
    Expression<double>? doseAmount,
    Expression<String>? doseUnit,
    Expression<String>? frequencyType,
    Expression<int>? frequencyValue,
    Expression<String>? route,
    Expression<String>? specialInstructions,
    Expression<String>? endCriterionType,
    Expression<int>? durationDays,
    Expression<int>? totalDoses,
    Expression<DateTime>? startDate,
    Expression<DateTime>? calculatedEndDate,
    Expression<bool>? isCritical,
    Expression<String>? status,
    Expression<String>? origin,
    Expression<String>? prescriptionImagePath,
    Expression<String>? prescriptionOcrText,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? endedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (medicationId != null) 'medication_id': medicationId,
      if (doseAmount != null) 'dose_amount': doseAmount,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (frequencyType != null) 'frequency_type': frequencyType,
      if (frequencyValue != null) 'frequency_value': frequencyValue,
      if (route != null) 'route': route,
      if (specialInstructions != null)
        'special_instructions': specialInstructions,
      if (endCriterionType != null) 'end_criterion_type': endCriterionType,
      if (durationDays != null) 'duration_days': durationDays,
      if (totalDoses != null) 'total_doses': totalDoses,
      if (startDate != null) 'start_date': startDate,
      if (calculatedEndDate != null) 'calculated_end_date': calculatedEndDate,
      if (isCritical != null) 'is_critical': isCritical,
      if (status != null) 'status': status,
      if (origin != null) 'origin': origin,
      if (prescriptionImagePath != null)
        'prescription_image_path': prescriptionImagePath,
      if (prescriptionOcrText != null)
        'prescription_ocr_text': prescriptionOcrText,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreatmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? medicationId,
    Value<double>? doseAmount,
    Value<String>? doseUnit,
    Value<String>? frequencyType,
    Value<int?>? frequencyValue,
    Value<String>? route,
    Value<String?>? specialInstructions,
    Value<String>? endCriterionType,
    Value<int?>? durationDays,
    Value<int?>? totalDoses,
    Value<DateTime>? startDate,
    Value<DateTime?>? calculatedEndDate,
    Value<bool>? isCritical,
    Value<String>? status,
    Value<String>? origin,
    Value<String?>? prescriptionImagePath,
    Value<String?>? prescriptionOcrText,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime?>? endedAt,
    Value<int>? rowid,
  }) {
    return TreatmentsTableCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      medicationId: medicationId ?? this.medicationId,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      route: route ?? this.route,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      endCriterionType: endCriterionType ?? this.endCriterionType,
      durationDays: durationDays ?? this.durationDays,
      totalDoses: totalDoses ?? this.totalDoses,
      startDate: startDate ?? this.startDate,
      calculatedEndDate: calculatedEndDate ?? this.calculatedEndDate,
      isCritical: isCritical ?? this.isCritical,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      prescriptionImagePath:
          prescriptionImagePath ?? this.prescriptionImagePath,
      prescriptionOcrText: prescriptionOcrText ?? this.prescriptionOcrText,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (medicationId.present) {
      map['medication_id'] = Variable<String>(medicationId.value);
    }
    if (doseAmount.present) {
      map['dose_amount'] = Variable<double>(doseAmount.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (frequencyType.present) {
      map['frequency_type'] = Variable<String>(frequencyType.value);
    }
    if (frequencyValue.present) {
      map['frequency_value'] = Variable<int>(frequencyValue.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (specialInstructions.present) {
      map['special_instructions'] = Variable<String>(specialInstructions.value);
    }
    if (endCriterionType.present) {
      map['end_criterion_type'] = Variable<String>(endCriterionType.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (totalDoses.present) {
      map['total_doses'] = Variable<int>(totalDoses.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (calculatedEndDate.present) {
      map['calculated_end_date'] = Variable<DateTime>(calculatedEndDate.value);
    }
    if (isCritical.present) {
      map['is_critical'] = Variable<bool>(isCritical.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (prescriptionImagePath.present) {
      map['prescription_image_path'] = Variable<String>(
        prescriptionImagePath.value,
      );
    }
    if (prescriptionOcrText.present) {
      map['prescription_ocr_text'] = Variable<String>(
        prescriptionOcrText.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('medicationId: $medicationId, ')
          ..write('doseAmount: $doseAmount, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('frequencyType: $frequencyType, ')
          ..write('frequencyValue: $frequencyValue, ')
          ..write('route: $route, ')
          ..write('specialInstructions: $specialInstructions, ')
          ..write('endCriterionType: $endCriterionType, ')
          ..write('durationDays: $durationDays, ')
          ..write('totalDoses: $totalDoses, ')
          ..write('startDate: $startDate, ')
          ..write('calculatedEndDate: $calculatedEndDate, ')
          ..write('isCritical: $isCritical, ')
          ..write('status: $status, ')
          ..write('origin: $origin, ')
          ..write('prescriptionImagePath: $prescriptionImagePath, ')
          ..write('prescriptionOcrText: $prescriptionOcrText, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTableTable extends RemindersTable
    with TableInfo<$RemindersTableTable, RemindersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES patients (id)',
    ),
  );
  static const VerificationMeta _treatmentIdMeta = const VerificationMeta(
    'treatmentId',
  );
  @override
  late final GeneratedColumn<String> treatmentId = GeneratedColumn<String>(
    'treatment_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES treatments (id)',
    ),
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _deadlineTimeMeta = const VerificationMeta(
    'deadlineTime',
  );
  @override
  late final GeneratedColumn<DateTime> deadlineTime = GeneratedColumn<DateTime>(
    'deadline_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _snoozeCountMeta = const VerificationMeta(
    'snoozeCount',
  );
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
    'snooze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ruleIdMeta = const VerificationMeta('ruleId');
  @override
  late final GeneratedColumn<String> ruleId = GeneratedColumn<String>(
    'rule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleExplanationMeta = const VerificationMeta(
    'ruleExplanation',
  );
  @override
  late final GeneratedColumn<String> ruleExplanation = GeneratedColumn<String>(
    'rule_explanation',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    treatmentId,
    scheduledTime,
    deadlineTime,
    status,
    snoozeCount,
    ruleId,
    ruleExplanation,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RemindersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('treatment_id')) {
      context.handle(
        _treatmentIdMeta,
        treatmentId.isAcceptableOrUnknown(
          data['treatment_id']!,
          _treatmentIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_treatmentIdMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('deadline_time')) {
      context.handle(
        _deadlineTimeMeta,
        deadlineTime.isAcceptableOrUnknown(
          data['deadline_time']!,
          _deadlineTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deadlineTimeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
        _snoozeCountMeta,
        snoozeCount.isAcceptableOrUnknown(
          data['snooze_count']!,
          _snoozeCountMeta,
        ),
      );
    }
    if (data.containsKey('rule_id')) {
      context.handle(
        _ruleIdMeta,
        ruleId.isAcceptableOrUnknown(data['rule_id']!, _ruleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ruleIdMeta);
    }
    if (data.containsKey('rule_explanation')) {
      context.handle(
        _ruleExplanationMeta,
        ruleExplanation.isAcceptableOrUnknown(
          data['rule_explanation']!,
          _ruleExplanationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ruleExplanationMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RemindersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RemindersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      treatmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}treatment_id'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      )!,
      deadlineTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deadline_time'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      snoozeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}snooze_count'],
      )!,
      ruleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_id'],
      )!,
      ruleExplanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_explanation'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RemindersTableTable createAlias(String alias) {
    return $RemindersTableTable(attachedDatabase, alias);
  }
}

class RemindersTableData extends DataClass
    implements Insertable<RemindersTableData> {
  final String id;
  final String patientId;
  final String treatmentId;
  final DateTime scheduledTime;
  final DateTime deadlineTime;
  final String status;
  final int snoozeCount;
  final String ruleId;
  final String ruleExplanation;
  final DateTime createdAt;
  const RemindersTableData({
    required this.id,
    required this.patientId,
    required this.treatmentId,
    required this.scheduledTime,
    required this.deadlineTime,
    required this.status,
    required this.snoozeCount,
    required this.ruleId,
    required this.ruleExplanation,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['treatment_id'] = Variable<String>(treatmentId);
    map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    map['deadline_time'] = Variable<DateTime>(deadlineTime);
    map['status'] = Variable<String>(status);
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['rule_id'] = Variable<String>(ruleId);
    map['rule_explanation'] = Variable<String>(ruleExplanation);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RemindersTableCompanion toCompanion(bool nullToAbsent) {
    return RemindersTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      treatmentId: Value(treatmentId),
      scheduledTime: Value(scheduledTime),
      deadlineTime: Value(deadlineTime),
      status: Value(status),
      snoozeCount: Value(snoozeCount),
      ruleId: Value(ruleId),
      ruleExplanation: Value(ruleExplanation),
      createdAt: Value(createdAt),
    );
  }

  factory RemindersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RemindersTableData(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      treatmentId: serializer.fromJson<String>(json['treatmentId']),
      scheduledTime: serializer.fromJson<DateTime>(json['scheduledTime']),
      deadlineTime: serializer.fromJson<DateTime>(json['deadlineTime']),
      status: serializer.fromJson<String>(json['status']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      ruleId: serializer.fromJson<String>(json['ruleId']),
      ruleExplanation: serializer.fromJson<String>(json['ruleExplanation']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'treatmentId': serializer.toJson<String>(treatmentId),
      'scheduledTime': serializer.toJson<DateTime>(scheduledTime),
      'deadlineTime': serializer.toJson<DateTime>(deadlineTime),
      'status': serializer.toJson<String>(status),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'ruleId': serializer.toJson<String>(ruleId),
      'ruleExplanation': serializer.toJson<String>(ruleExplanation),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RemindersTableData copyWith({
    String? id,
    String? patientId,
    String? treatmentId,
    DateTime? scheduledTime,
    DateTime? deadlineTime,
    String? status,
    int? snoozeCount,
    String? ruleId,
    String? ruleExplanation,
    DateTime? createdAt,
  }) => RemindersTableData(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    treatmentId: treatmentId ?? this.treatmentId,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    deadlineTime: deadlineTime ?? this.deadlineTime,
    status: status ?? this.status,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    ruleId: ruleId ?? this.ruleId,
    ruleExplanation: ruleExplanation ?? this.ruleExplanation,
    createdAt: createdAt ?? this.createdAt,
  );
  RemindersTableData copyWithCompanion(RemindersTableCompanion data) {
    return RemindersTableData(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      treatmentId: data.treatmentId.present
          ? data.treatmentId.value
          : this.treatmentId,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      deadlineTime: data.deadlineTime.present
          ? data.deadlineTime.value
          : this.deadlineTime,
      status: data.status.present ? data.status.value : this.status,
      snoozeCount: data.snoozeCount.present
          ? data.snoozeCount.value
          : this.snoozeCount,
      ruleId: data.ruleId.present ? data.ruleId.value : this.ruleId,
      ruleExplanation: data.ruleExplanation.present
          ? data.ruleExplanation.value
          : this.ruleExplanation,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RemindersTableData(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('deadlineTime: $deadlineTime, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('ruleId: $ruleId, ')
          ..write('ruleExplanation: $ruleExplanation, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    treatmentId,
    scheduledTime,
    deadlineTime,
    status,
    snoozeCount,
    ruleId,
    ruleExplanation,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RemindersTableData &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.treatmentId == this.treatmentId &&
          other.scheduledTime == this.scheduledTime &&
          other.deadlineTime == this.deadlineTime &&
          other.status == this.status &&
          other.snoozeCount == this.snoozeCount &&
          other.ruleId == this.ruleId &&
          other.ruleExplanation == this.ruleExplanation &&
          other.createdAt == this.createdAt);
}

class RemindersTableCompanion extends UpdateCompanion<RemindersTableData> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> treatmentId;
  final Value<DateTime> scheduledTime;
  final Value<DateTime> deadlineTime;
  final Value<String> status;
  final Value<int> snoozeCount;
  final Value<String> ruleId;
  final Value<String> ruleExplanation;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RemindersTableCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.treatmentId = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.deadlineTime = const Value.absent(),
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.ruleId = const Value.absent(),
    this.ruleExplanation = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersTableCompanion.insert({
    required String id,
    required String patientId,
    required String treatmentId,
    required DateTime scheduledTime,
    required DateTime deadlineTime,
    this.status = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    required String ruleId,
    required String ruleExplanation,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       treatmentId = Value(treatmentId),
       scheduledTime = Value(scheduledTime),
       deadlineTime = Value(deadlineTime),
       ruleId = Value(ruleId),
       ruleExplanation = Value(ruleExplanation);
  static Insertable<RemindersTableData> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? treatmentId,
    Expression<DateTime>? scheduledTime,
    Expression<DateTime>? deadlineTime,
    Expression<String>? status,
    Expression<int>? snoozeCount,
    Expression<String>? ruleId,
    Expression<String>? ruleExplanation,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (treatmentId != null) 'treatment_id': treatmentId,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (deadlineTime != null) 'deadline_time': deadlineTime,
      if (status != null) 'status': status,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (ruleId != null) 'rule_id': ruleId,
      if (ruleExplanation != null) 'rule_explanation': ruleExplanation,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<String>? treatmentId,
    Value<DateTime>? scheduledTime,
    Value<DateTime>? deadlineTime,
    Value<String>? status,
    Value<int>? snoozeCount,
    Value<String>? ruleId,
    Value<String>? ruleExplanation,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RemindersTableCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      treatmentId: treatmentId ?? this.treatmentId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      deadlineTime: deadlineTime ?? this.deadlineTime,
      status: status ?? this.status,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      ruleId: ruleId ?? this.ruleId,
      ruleExplanation: ruleExplanation ?? this.ruleExplanation,
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
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (treatmentId.present) {
      map['treatment_id'] = Variable<String>(treatmentId.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (deadlineTime.present) {
      map['deadline_time'] = Variable<DateTime>(deadlineTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (ruleId.present) {
      map['rule_id'] = Variable<String>(ruleId.value);
    }
    if (ruleExplanation.present) {
      map['rule_explanation'] = Variable<String>(ruleExplanation.value);
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
    return (StringBuffer('RemindersTableCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('treatmentId: $treatmentId, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('deadlineTime: $deadlineTime, ')
          ..write('status: $status, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('ruleId: $ruleId, ')
          ..write('ruleExplanation: $ruleExplanation, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntakesTableTable extends IntakesTable
    with TableInfo<$IntakesTableTable, IntakesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntakesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES reminders (id)',
    ),
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualTimeMeta = const VerificationMeta(
    'actualTime',
  );
  @override
  late final GeneratedColumn<DateTime> actualTime = GeneratedColumn<DateTime>(
    'actual_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minutesLateMeta = const VerificationMeta(
    'minutesLate',
  );
  @override
  late final GeneratedColumn<int> minutesLate = GeneratedColumn<int>(
    'minutes_late',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    reminderId,
    result,
    actualTime,
    minutesLate,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intakes';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntakesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('actual_time')) {
      context.handle(
        _actualTimeMeta,
        actualTime.isAcceptableOrUnknown(data['actual_time']!, _actualTimeMeta),
      );
    }
    if (data.containsKey('minutes_late')) {
      context.handle(
        _minutesLateMeta,
        minutesLate.isAcceptableOrUnknown(
          data['minutes_late']!,
          _minutesLateMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntakesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntakesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      actualTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_time'],
      ),
      minutesLate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes_late'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $IntakesTableTable createAlias(String alias) {
    return $IntakesTableTable(attachedDatabase, alias);
  }
}

class IntakesTableData extends DataClass
    implements Insertable<IntakesTableData> {
  final String id;
  final String reminderId;
  final String result;
  final DateTime? actualTime;
  final int? minutesLate;
  final DateTime recordedAt;
  const IntakesTableData({
    required this.id,
    required this.reminderId,
    required this.result,
    this.actualTime,
    this.minutesLate,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reminder_id'] = Variable<String>(reminderId);
    map['result'] = Variable<String>(result);
    if (!nullToAbsent || actualTime != null) {
      map['actual_time'] = Variable<DateTime>(actualTime);
    }
    if (!nullToAbsent || minutesLate != null) {
      map['minutes_late'] = Variable<int>(minutesLate);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  IntakesTableCompanion toCompanion(bool nullToAbsent) {
    return IntakesTableCompanion(
      id: Value(id),
      reminderId: Value(reminderId),
      result: Value(result),
      actualTime: actualTime == null && nullToAbsent
          ? const Value.absent()
          : Value(actualTime),
      minutesLate: minutesLate == null && nullToAbsent
          ? const Value.absent()
          : Value(minutesLate),
      recordedAt: Value(recordedAt),
    );
  }

  factory IntakesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntakesTableData(
      id: serializer.fromJson<String>(json['id']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      result: serializer.fromJson<String>(json['result']),
      actualTime: serializer.fromJson<DateTime?>(json['actualTime']),
      minutesLate: serializer.fromJson<int?>(json['minutesLate']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reminderId': serializer.toJson<String>(reminderId),
      'result': serializer.toJson<String>(result),
      'actualTime': serializer.toJson<DateTime?>(actualTime),
      'minutesLate': serializer.toJson<int?>(minutesLate),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  IntakesTableData copyWith({
    String? id,
    String? reminderId,
    String? result,
    Value<DateTime?> actualTime = const Value.absent(),
    Value<int?> minutesLate = const Value.absent(),
    DateTime? recordedAt,
  }) => IntakesTableData(
    id: id ?? this.id,
    reminderId: reminderId ?? this.reminderId,
    result: result ?? this.result,
    actualTime: actualTime.present ? actualTime.value : this.actualTime,
    minutesLate: minutesLate.present ? minutesLate.value : this.minutesLate,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  IntakesTableData copyWithCompanion(IntakesTableCompanion data) {
    return IntakesTableData(
      id: data.id.present ? data.id.value : this.id,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      result: data.result.present ? data.result.value : this.result,
      actualTime: data.actualTime.present
          ? data.actualTime.value
          : this.actualTime,
      minutesLate: data.minutesLate.present
          ? data.minutesLate.value
          : this.minutesLate,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntakesTableData(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('result: $result, ')
          ..write('actualTime: $actualTime, ')
          ..write('minutesLate: $minutesLate, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, reminderId, result, actualTime, minutesLate, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntakesTableData &&
          other.id == this.id &&
          other.reminderId == this.reminderId &&
          other.result == this.result &&
          other.actualTime == this.actualTime &&
          other.minutesLate == this.minutesLate &&
          other.recordedAt == this.recordedAt);
}

class IntakesTableCompanion extends UpdateCompanion<IntakesTableData> {
  final Value<String> id;
  final Value<String> reminderId;
  final Value<String> result;
  final Value<DateTime?> actualTime;
  final Value<int?> minutesLate;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const IntakesTableCompanion({
    this.id = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.result = const Value.absent(),
    this.actualTime = const Value.absent(),
    this.minutesLate = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntakesTableCompanion.insert({
    required String id,
    required String reminderId,
    required String result,
    this.actualTime = const Value.absent(),
    this.minutesLate = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       reminderId = Value(reminderId),
       result = Value(result);
  static Insertable<IntakesTableData> custom({
    Expression<String>? id,
    Expression<String>? reminderId,
    Expression<String>? result,
    Expression<DateTime>? actualTime,
    Expression<int>? minutesLate,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (reminderId != null) 'reminder_id': reminderId,
      if (result != null) 'result': result,
      if (actualTime != null) 'actual_time': actualTime,
      if (minutesLate != null) 'minutes_late': minutesLate,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntakesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? reminderId,
    Value<String>? result,
    Value<DateTime?>? actualTime,
    Value<int?>? minutesLate,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return IntakesTableCompanion(
      id: id ?? this.id,
      reminderId: reminderId ?? this.reminderId,
      result: result ?? this.result,
      actualTime: actualTime ?? this.actualTime,
      minutesLate: minutesLate ?? this.minutesLate,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (actualTime.present) {
      map['actual_time'] = Variable<DateTime>(actualTime.value);
    }
    if (minutesLate.present) {
      map['minutes_late'] = Variable<int>(minutesLate.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntakesTableCompanion(')
          ..write('id: $id, ')
          ..write('reminderId: $reminderId, ')
          ..write('result: $result, ')
          ..write('actualTime: $actualTime, ')
          ..write('minutesLate: $minutesLate, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTableTable patientsTable = $PatientsTableTable(this);
  late final $MedicationsTableTable medicationsTable = $MedicationsTableTable(
    this,
  );
  late final $TreatmentsTableTable treatmentsTable = $TreatmentsTableTable(
    this,
  );
  late final $RemindersTableTable remindersTable = $RemindersTableTable(this);
  late final $IntakesTableTable intakesTable = $IntakesTableTable(this);
  late final PatientDao patientDao = PatientDao(this as AppDatabase);
  late final MedicationDao medicationDao = MedicationDao(this as AppDatabase);
  late final TreatmentDao treatmentDao = TreatmentDao(this as AppDatabase);
  late final ReminderDao reminderDao = ReminderDao(this as AppDatabase);
  late final IntakeDao intakeDao = IntakeDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    patientsTable,
    medicationsTable,
    treatmentsTable,
    remindersTable,
    intakesTable,
  ];
}

typedef $$PatientsTableTableCreateCompanionBuilder =
    PatientsTableCompanion Function({
      required String id,
      required String name,
      Value<DateTime?> birthDate,
      Value<String?> photoPath,
      Value<String> profileType,
      Value<bool> isActive,
      Value<String> accessibilityConfig,
      Value<int> breakfastTime,
      Value<int> lunchTime,
      Value<int> dinnerTime,
      Value<int> sleepTime,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$PatientsTableTableUpdateCompanionBuilder =
    PatientsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime?> birthDate,
      Value<String?> photoPath,
      Value<String> profileType,
      Value<bool> isActive,
      Value<String> accessibilityConfig,
      Value<int> breakfastTime,
      Value<int> lunchTime,
      Value<int> dinnerTime,
      Value<int> sleepTime,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PatientsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $PatientsTableTable, PatientsTableData> {
  $$PatientsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MedicationsTableTable, List<MedicationsTableData>>
  _medicationsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicationsTable,
    aliasName: $_aliasNameGenerator(
      db.patientsTable.id,
      db.medicationsTable.patientId,
    ),
  );

  $$MedicationsTableTableProcessedTableManager get medicationsTableRefs {
    final manager = $$MedicationsTableTableTableManager(
      $_db,
      $_db.medicationsTable,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _medicationsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TreatmentsTableTable, List<TreatmentsTableData>>
  _treatmentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatmentsTable,
    aliasName: $_aliasNameGenerator(
      db.patientsTable.id,
      db.treatmentsTable.patientId,
    ),
  );

  $$TreatmentsTableTableProcessedTableManager get treatmentsTableRefs {
    final manager = $$TreatmentsTableTableTableManager(
      $_db,
      $_db.treatmentsTable,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _treatmentsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RemindersTableTable, List<RemindersTableData>>
  _remindersTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remindersTable,
    aliasName: $_aliasNameGenerator(
      db.patientsTable.id,
      db.remindersTable.patientId,
    ),
  );

  $$RemindersTableTableProcessedTableManager get remindersTableRefs {
    final manager = $$RemindersTableTableTableManager(
      $_db,
      $_db.remindersTable,
    ).filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PatientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessibilityConfig => $composableBuilder(
    column: $table.accessibilityConfig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicationsTableRefs(
    Expression<bool> Function($$MedicationsTableTableFilterComposer f) f,
  ) {
    final $$MedicationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationsTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableTableFilterComposer(
            $db: $db,
            $table: $db.medicationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> treatmentsTableRefs(
    Expression<bool> Function($$TreatmentsTableTableFilterComposer f) f,
  ) {
    final $$TreatmentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableFilterComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> remindersTableRefs(
    Expression<bool> Function($$RemindersTableTableFilterComposer f) f,
  ) {
    final $$RemindersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableFilterComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessibilityConfig => $composableBuilder(
    column: $table.accessibilityConfig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lunchTime => $composableBuilder(
    column: $table.lunchTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sleepTime => $composableBuilder(
    column: $table.sleepTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PatientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get profileType => $composableBuilder(
    column: $table.profileType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get accessibilityConfig => $composableBuilder(
    column: $table.accessibilityConfig,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakfastTime => $composableBuilder(
    column: $table.breakfastTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lunchTime =>
      $composableBuilder(column: $table.lunchTime, builder: (column) => column);

  GeneratedColumn<int> get dinnerTime => $composableBuilder(
    column: $table.dinnerTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sleepTime =>
      $composableBuilder(column: $table.sleepTime, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> medicationsTableRefs<T extends Object>(
    Expression<T> Function($$MedicationsTableTableAnnotationComposer a) f,
  ) {
    final $$MedicationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicationsTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> treatmentsTableRefs<T extends Object>(
    Expression<T> Function($$TreatmentsTableTableAnnotationComposer a) f,
  ) {
    final $$TreatmentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> remindersTableRefs<T extends Object>(
    Expression<T> Function($$RemindersTableTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.patientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PatientsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PatientsTableTable,
          PatientsTableData,
          $$PatientsTableTableFilterComposer,
          $$PatientsTableTableOrderingComposer,
          $$PatientsTableTableAnnotationComposer,
          $$PatientsTableTableCreateCompanionBuilder,
          $$PatientsTableTableUpdateCompanionBuilder,
          (PatientsTableData, $$PatientsTableTableReferences),
          PatientsTableData,
          PrefetchHooks Function({
            bool medicationsTableRefs,
            bool treatmentsTableRefs,
            bool remindersTableRefs,
          })
        > {
  $$PatientsTableTableTableManager(_$AppDatabase db, $PatientsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> profileType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> accessibilityConfig = const Value.absent(),
                Value<int> breakfastTime = const Value.absent(),
                Value<int> lunchTime = const Value.absent(),
                Value<int> dinnerTime = const Value.absent(),
                Value<int> sleepTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsTableCompanion(
                id: id,
                name: name,
                birthDate: birthDate,
                photoPath: photoPath,
                profileType: profileType,
                isActive: isActive,
                accessibilityConfig: accessibilityConfig,
                breakfastTime: breakfastTime,
                lunchTime: lunchTime,
                dinnerTime: dinnerTime,
                sleepTime: sleepTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String> profileType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> accessibilityConfig = const Value.absent(),
                Value<int> breakfastTime = const Value.absent(),
                Value<int> lunchTime = const Value.absent(),
                Value<int> dinnerTime = const Value.absent(),
                Value<int> sleepTime = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PatientsTableCompanion.insert(
                id: id,
                name: name,
                birthDate: birthDate,
                photoPath: photoPath,
                profileType: profileType,
                isActive: isActive,
                accessibilityConfig: accessibilityConfig,
                breakfastTime: breakfastTime,
                lunchTime: lunchTime,
                dinnerTime: dinnerTime,
                sleepTime: sleepTime,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PatientsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                medicationsTableRefs = false,
                treatmentsTableRefs = false,
                remindersTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (medicationsTableRefs) db.medicationsTable,
                    if (treatmentsTableRefs) db.treatmentsTable,
                    if (remindersTableRefs) db.remindersTable,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (medicationsTableRefs)
                        await $_getPrefetchedData<
                          PatientsTableData,
                          $PatientsTableTable,
                          MedicationsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableTableReferences
                              ._medicationsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).medicationsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (treatmentsTableRefs)
                        await $_getPrefetchedData<
                          PatientsTableData,
                          $PatientsTableTable,
                          TreatmentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableTableReferences
                              ._treatmentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (remindersTableRefs)
                        await $_getPrefetchedData<
                          PatientsTableData,
                          $PatientsTableTable,
                          RemindersTableData
                        >(
                          currentTable: table,
                          referencedTable: $$PatientsTableTableReferences
                              ._remindersTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PatientsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.patientId == item.id,
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

typedef $$PatientsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PatientsTableTable,
      PatientsTableData,
      $$PatientsTableTableFilterComposer,
      $$PatientsTableTableOrderingComposer,
      $$PatientsTableTableAnnotationComposer,
      $$PatientsTableTableCreateCompanionBuilder,
      $$PatientsTableTableUpdateCompanionBuilder,
      (PatientsTableData, $$PatientsTableTableReferences),
      PatientsTableData,
      PrefetchHooks Function({
        bool medicationsTableRefs,
        bool treatmentsTableRefs,
        bool remindersTableRefs,
      })
    >;
typedef $$MedicationsTableTableCreateCompanionBuilder =
    MedicationsTableCompanion Function({
      required String id,
      required String patientId,
      required String name,
      Value<String?> activeIngredient,
      Value<String> presentation,
      Value<String?> boxPhotoPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$MedicationsTableTableUpdateCompanionBuilder =
    MedicationsTableCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> name,
      Value<String?> activeIngredient,
      Value<String> presentation,
      Value<String?> boxPhotoPath,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$MedicationsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicationsTableTable,
          MedicationsTableData
        > {
  $$MedicationsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias(
        $_aliasNameGenerator(
          db.medicationsTable.patientId,
          db.patientsTable.id,
        ),
      );

  $$PatientsTableTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableTableManager(
      $_db,
      $_db.patientsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TreatmentsTableTable, List<TreatmentsTableData>>
  _treatmentsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatmentsTable,
    aliasName: $_aliasNameGenerator(
      db.medicationsTable.id,
      db.treatmentsTable.medicationId,
    ),
  );

  $$TreatmentsTableTableProcessedTableManager get treatmentsTableRefs {
    final manager = $$TreatmentsTableTableTableManager(
      $_db,
      $_db.treatmentsTable,
    ).filter((f) => f.medicationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _treatmentsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationsTableTable> {
  $$MedicationsTableTableFilterComposer({
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

  ColumnFilters<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boxPhotoPath => $composableBuilder(
    column: $table.boxPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableFilterComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> treatmentsTableRefs(
    Expression<bool> Function($$TreatmentsTableTableFilterComposer f) f,
  ) {
    final $$TreatmentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableFilterComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationsTableTable> {
  $$MedicationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boxPhotoPath => $composableBuilder(
    column: $table.boxPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableOrderingComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationsTableTable> {
  $$MedicationsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get activeIngredient => $composableBuilder(
    column: $table.activeIngredient,
    builder: (column) => column,
  );

  GeneratedColumn<String> get presentation => $composableBuilder(
    column: $table.presentation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get boxPhotoPath => $composableBuilder(
    column: $table.boxPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> treatmentsTableRefs<T extends Object>(
    Expression<T> Function($$TreatmentsTableTableAnnotationComposer a) f,
  ) {
    final $$TreatmentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.medicationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationsTableTable,
          MedicationsTableData,
          $$MedicationsTableTableFilterComposer,
          $$MedicationsTableTableOrderingComposer,
          $$MedicationsTableTableAnnotationComposer,
          $$MedicationsTableTableCreateCompanionBuilder,
          $$MedicationsTableTableUpdateCompanionBuilder,
          (MedicationsTableData, $$MedicationsTableTableReferences),
          MedicationsTableData,
          PrefetchHooks Function({bool patientId, bool treatmentsTableRefs})
        > {
  $$MedicationsTableTableTableManager(
    _$AppDatabase db,
    $MedicationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> activeIngredient = const Value.absent(),
                Value<String> presentation = const Value.absent(),
                Value<String?> boxPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsTableCompanion(
                id: id,
                patientId: patientId,
                name: name,
                activeIngredient: activeIngredient,
                presentation: presentation,
                boxPhotoPath: boxPhotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String name,
                Value<String?> activeIngredient = const Value.absent(),
                Value<String> presentation = const Value.absent(),
                Value<String?> boxPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationsTableCompanion.insert(
                id: id,
                patientId: patientId,
                name: name,
                activeIngredient: activeIngredient,
                presentation: presentation,
                boxPhotoPath: boxPhotoPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicationsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({patientId = false, treatmentsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (treatmentsTableRefs) db.treatmentsTable,
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
                        if (patientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patientId,
                                    referencedTable:
                                        $$MedicationsTableTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$MedicationsTableTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (treatmentsTableRefs)
                        await $_getPrefetchedData<
                          MedicationsTableData,
                          $MedicationsTableTable,
                          TreatmentsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$MedicationsTableTableReferences
                              ._treatmentsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicationsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicationId == item.id,
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

typedef $$MedicationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationsTableTable,
      MedicationsTableData,
      $$MedicationsTableTableFilterComposer,
      $$MedicationsTableTableOrderingComposer,
      $$MedicationsTableTableAnnotationComposer,
      $$MedicationsTableTableCreateCompanionBuilder,
      $$MedicationsTableTableUpdateCompanionBuilder,
      (MedicationsTableData, $$MedicationsTableTableReferences),
      MedicationsTableData,
      PrefetchHooks Function({bool patientId, bool treatmentsTableRefs})
    >;
typedef $$TreatmentsTableTableCreateCompanionBuilder =
    TreatmentsTableCompanion Function({
      required String id,
      required String patientId,
      required String medicationId,
      required double doseAmount,
      required String doseUnit,
      required String frequencyType,
      Value<int?> frequencyValue,
      Value<String> route,
      Value<String?> specialInstructions,
      required String endCriterionType,
      Value<int?> durationDays,
      Value<int?> totalDoses,
      required DateTime startDate,
      Value<DateTime?> calculatedEndDate,
      Value<bool> isCritical,
      Value<String> status,
      Value<String> origin,
      Value<String?> prescriptionImagePath,
      Value<String?> prescriptionOcrText,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });
typedef $$TreatmentsTableTableUpdateCompanionBuilder =
    TreatmentsTableCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> medicationId,
      Value<double> doseAmount,
      Value<String> doseUnit,
      Value<String> frequencyType,
      Value<int?> frequencyValue,
      Value<String> route,
      Value<String?> specialInstructions,
      Value<String> endCriterionType,
      Value<int?> durationDays,
      Value<int?> totalDoses,
      Value<DateTime> startDate,
      Value<DateTime?> calculatedEndDate,
      Value<bool> isCritical,
      Value<String> status,
      Value<String> origin,
      Value<String?> prescriptionImagePath,
      Value<String?> prescriptionOcrText,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime?> endedAt,
      Value<int> rowid,
    });

final class $$TreatmentsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TreatmentsTableTable,
          TreatmentsTableData
        > {
  $$TreatmentsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias(
        $_aliasNameGenerator(db.treatmentsTable.patientId, db.patientsTable.id),
      );

  $$PatientsTableTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableTableManager(
      $_db,
      $_db.patientsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MedicationsTableTable _medicationIdTable(_$AppDatabase db) =>
      db.medicationsTable.createAlias(
        $_aliasNameGenerator(
          db.treatmentsTable.medicationId,
          db.medicationsTable.id,
        ),
      );

  $$MedicationsTableTableProcessedTableManager get medicationId {
    final $_column = $_itemColumn<String>('medication_id')!;

    final manager = $$MedicationsTableTableTableManager(
      $_db,
      $_db.medicationsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RemindersTableTable, List<RemindersTableData>>
  _remindersTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.remindersTable,
    aliasName: $_aliasNameGenerator(
      db.treatmentsTable.id,
      db.remindersTable.treatmentId,
    ),
  );

  $$RemindersTableTableProcessedTableManager get remindersTableRefs {
    final manager = $$RemindersTableTableTableManager(
      $_db,
      $_db.remindersTable,
    ).filter((f) => f.treatmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_remindersTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TreatmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentsTableTable> {
  $$TreatmentsTableTableFilterComposer({
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

  ColumnFilters<double> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frequencyValue => $composableBuilder(
    column: $table.frequencyValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endCriterionType => $composableBuilder(
    column: $table.endCriterionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDoses => $composableBuilder(
    column: $table.totalDoses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get calculatedEndDate => $composableBuilder(
    column: $table.calculatedEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriptionImagePath => $composableBuilder(
    column: $table.prescriptionImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prescriptionOcrText => $composableBuilder(
    column: $table.prescriptionOcrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableFilterComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableTableFilterComposer get medicationId {
    final $$MedicationsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medicationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableTableFilterComposer(
            $db: $db,
            $table: $db.medicationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> remindersTableRefs(
    Expression<bool> Function($$RemindersTableTableFilterComposer f) f,
  ) {
    final $$RemindersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableFilterComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentsTableTable> {
  $$TreatmentsTableTableOrderingComposer({
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

  ColumnOrderings<double> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequencyValue => $composableBuilder(
    column: $table.frequencyValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endCriterionType => $composableBuilder(
    column: $table.endCriterionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDoses => $composableBuilder(
    column: $table.totalDoses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get calculatedEndDate => $composableBuilder(
    column: $table.calculatedEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
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

  ColumnOrderings<String> get prescriptionImagePath => $composableBuilder(
    column: $table.prescriptionImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prescriptionOcrText => $composableBuilder(
    column: $table.prescriptionOcrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableOrderingComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableTableOrderingComposer get medicationId {
    final $$MedicationsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medicationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableTableOrderingComposer(
            $db: $db,
            $table: $db.medicationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentsTableTable> {
  $$TreatmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get doseAmount => $composableBuilder(
    column: $table.doseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<String> get frequencyType => $composableBuilder(
    column: $table.frequencyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frequencyValue => $composableBuilder(
    column: $table.frequencyValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get specialInstructions => $composableBuilder(
    column: $table.specialInstructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endCriterionType => $composableBuilder(
    column: $table.endCriterionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDoses => $composableBuilder(
    column: $table.totalDoses,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get calculatedEndDate => $composableBuilder(
    column: $table.calculatedEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCritical => $composableBuilder(
    column: $table.isCritical,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumn<String> get prescriptionImagePath => $composableBuilder(
    column: $table.prescriptionImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prescriptionOcrText => $composableBuilder(
    column: $table.prescriptionOcrText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicationsTableTableAnnotationComposer get medicationId {
    final $$MedicationsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicationId,
      referencedTable: $db.medicationsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicationsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.medicationsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> remindersTableRefs<T extends Object>(
    Expression<T> Function($$RemindersTableTableAnnotationComposer a) f,
  ) {
    final $$RemindersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.treatmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TreatmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentsTableTable,
          TreatmentsTableData,
          $$TreatmentsTableTableFilterComposer,
          $$TreatmentsTableTableOrderingComposer,
          $$TreatmentsTableTableAnnotationComposer,
          $$TreatmentsTableTableCreateCompanionBuilder,
          $$TreatmentsTableTableUpdateCompanionBuilder,
          (TreatmentsTableData, $$TreatmentsTableTableReferences),
          TreatmentsTableData,
          PrefetchHooks Function({
            bool patientId,
            bool medicationId,
            bool remindersTableRefs,
          })
        > {
  $$TreatmentsTableTableTableManager(
    _$AppDatabase db,
    $TreatmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatmentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatmentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatmentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> medicationId = const Value.absent(),
                Value<double> doseAmount = const Value.absent(),
                Value<String> doseUnit = const Value.absent(),
                Value<String> frequencyType = const Value.absent(),
                Value<int?> frequencyValue = const Value.absent(),
                Value<String> route = const Value.absent(),
                Value<String?> specialInstructions = const Value.absent(),
                Value<String> endCriterionType = const Value.absent(),
                Value<int?> durationDays = const Value.absent(),
                Value<int?> totalDoses = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<DateTime?> calculatedEndDate = const Value.absent(),
                Value<bool> isCritical = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> prescriptionImagePath = const Value.absent(),
                Value<String?> prescriptionOcrText = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentsTableCompanion(
                id: id,
                patientId: patientId,
                medicationId: medicationId,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                frequencyType: frequencyType,
                frequencyValue: frequencyValue,
                route: route,
                specialInstructions: specialInstructions,
                endCriterionType: endCriterionType,
                durationDays: durationDays,
                totalDoses: totalDoses,
                startDate: startDate,
                calculatedEndDate: calculatedEndDate,
                isCritical: isCritical,
                status: status,
                origin: origin,
                prescriptionImagePath: prescriptionImagePath,
                prescriptionOcrText: prescriptionOcrText,
                notes: notes,
                createdAt: createdAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String medicationId,
                required double doseAmount,
                required String doseUnit,
                required String frequencyType,
                Value<int?> frequencyValue = const Value.absent(),
                Value<String> route = const Value.absent(),
                Value<String?> specialInstructions = const Value.absent(),
                required String endCriterionType,
                Value<int?> durationDays = const Value.absent(),
                Value<int?> totalDoses = const Value.absent(),
                required DateTime startDate,
                Value<DateTime?> calculatedEndDate = const Value.absent(),
                Value<bool> isCritical = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> origin = const Value.absent(),
                Value<String?> prescriptionImagePath = const Value.absent(),
                Value<String?> prescriptionOcrText = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentsTableCompanion.insert(
                id: id,
                patientId: patientId,
                medicationId: medicationId,
                doseAmount: doseAmount,
                doseUnit: doseUnit,
                frequencyType: frequencyType,
                frequencyValue: frequencyValue,
                route: route,
                specialInstructions: specialInstructions,
                endCriterionType: endCriterionType,
                durationDays: durationDays,
                totalDoses: totalDoses,
                startDate: startDate,
                calculatedEndDate: calculatedEndDate,
                isCritical: isCritical,
                status: status,
                origin: origin,
                prescriptionImagePath: prescriptionImagePath,
                prescriptionOcrText: prescriptionOcrText,
                notes: notes,
                createdAt: createdAt,
                endedAt: endedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TreatmentsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patientId = false,
                medicationId = false,
                remindersTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (remindersTableRefs) db.remindersTable,
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
                        if (patientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patientId,
                                    referencedTable:
                                        $$TreatmentsTableTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$TreatmentsTableTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (medicationId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.medicationId,
                                    referencedTable:
                                        $$TreatmentsTableTableReferences
                                            ._medicationIdTable(db),
                                    referencedColumn:
                                        $$TreatmentsTableTableReferences
                                            ._medicationIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (remindersTableRefs)
                        await $_getPrefetchedData<
                          TreatmentsTableData,
                          $TreatmentsTableTable,
                          RemindersTableData
                        >(
                          currentTable: table,
                          referencedTable: $$TreatmentsTableTableReferences
                              ._remindersTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TreatmentsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).remindersTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.treatmentId == item.id,
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

typedef $$TreatmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentsTableTable,
      TreatmentsTableData,
      $$TreatmentsTableTableFilterComposer,
      $$TreatmentsTableTableOrderingComposer,
      $$TreatmentsTableTableAnnotationComposer,
      $$TreatmentsTableTableCreateCompanionBuilder,
      $$TreatmentsTableTableUpdateCompanionBuilder,
      (TreatmentsTableData, $$TreatmentsTableTableReferences),
      TreatmentsTableData,
      PrefetchHooks Function({
        bool patientId,
        bool medicationId,
        bool remindersTableRefs,
      })
    >;
typedef $$RemindersTableTableCreateCompanionBuilder =
    RemindersTableCompanion Function({
      required String id,
      required String patientId,
      required String treatmentId,
      required DateTime scheduledTime,
      required DateTime deadlineTime,
      Value<String> status,
      Value<int> snoozeCount,
      required String ruleId,
      required String ruleExplanation,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$RemindersTableTableUpdateCompanionBuilder =
    RemindersTableCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<String> treatmentId,
      Value<DateTime> scheduledTime,
      Value<DateTime> deadlineTime,
      Value<String> status,
      Value<int> snoozeCount,
      Value<String> ruleId,
      Value<String> ruleExplanation,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$RemindersTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RemindersTableTable,
          RemindersTableData
        > {
  $$RemindersTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias(
        $_aliasNameGenerator(db.remindersTable.patientId, db.patientsTable.id),
      );

  $$PatientsTableTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableTableManager(
      $_db,
      $_db.patientsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TreatmentsTableTable _treatmentIdTable(_$AppDatabase db) =>
      db.treatmentsTable.createAlias(
        $_aliasNameGenerator(
          db.remindersTable.treatmentId,
          db.treatmentsTable.id,
        ),
      );

  $$TreatmentsTableTableProcessedTableManager get treatmentId {
    final $_column = $_itemColumn<String>('treatment_id')!;

    final manager = $$TreatmentsTableTableTableManager(
      $_db,
      $_db.treatmentsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_treatmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$IntakesTableTable, List<IntakesTableData>>
  _intakesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakesTable,
    aliasName: $_aliasNameGenerator(
      db.remindersTable.id,
      db.intakesTable.reminderId,
    ),
  );

  $$IntakesTableTableProcessedTableManager get intakesTableRefs {
    final manager = $$IntakesTableTableTableManager(
      $_db,
      $_db.intakesTable,
    ).filter((f) => f.reminderId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_intakesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RemindersTableTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableFilterComposer({
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

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deadlineTime => $composableBuilder(
    column: $table.deadlineTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleExplanation => $composableBuilder(
    column: $table.ruleExplanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableFilterComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableTableFilterComposer get treatmentId {
    final $$TreatmentsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableFilterComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> intakesTableRefs(
    Expression<bool> Function($$IntakesTableTableFilterComposer f) f,
  ) {
    final $$IntakesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakesTable,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakesTableTableFilterComposer(
            $db: $db,
            $table: $db.intakesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deadlineTime => $composableBuilder(
    column: $table.deadlineTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleId => $composableBuilder(
    column: $table.ruleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleExplanation => $composableBuilder(
    column: $table.ruleExplanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableOrderingComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableTableOrderingComposer get treatmentId {
    final $$TreatmentsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableOrderingComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RemindersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTableTable> {
  $$RemindersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deadlineTime => $composableBuilder(
    column: $table.deadlineTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
    column: $table.snoozeCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ruleId =>
      $composableBuilder(column: $table.ruleId, builder: (column) => column);

  GeneratedColumn<String> get ruleExplanation => $composableBuilder(
    column: $table.ruleExplanation,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.patientId,
      referencedTable: $db.patientsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PatientsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.patientsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TreatmentsTableTableAnnotationComposer get treatmentId {
    final $$TreatmentsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.treatmentId,
      referencedTable: $db.treatmentsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.treatmentsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> intakesTableRefs<T extends Object>(
    Expression<T> Function($$IntakesTableTableAnnotationComposer a) f,
  ) {
    final $$IntakesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakesTable,
      getReferencedColumn: (t) => t.reminderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.intakesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RemindersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTableTable,
          RemindersTableData,
          $$RemindersTableTableFilterComposer,
          $$RemindersTableTableOrderingComposer,
          $$RemindersTableTableAnnotationComposer,
          $$RemindersTableTableCreateCompanionBuilder,
          $$RemindersTableTableUpdateCompanionBuilder,
          (RemindersTableData, $$RemindersTableTableReferences),
          RemindersTableData,
          PrefetchHooks Function({
            bool patientId,
            bool treatmentId,
            bool intakesTableRefs,
          })
        > {
  $$RemindersTableTableTableManager(
    _$AppDatabase db,
    $RemindersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<String> treatmentId = const Value.absent(),
                Value<DateTime> scheduledTime = const Value.absent(),
                Value<DateTime> deadlineTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                Value<String> ruleId = const Value.absent(),
                Value<String> ruleExplanation = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersTableCompanion(
                id: id,
                patientId: patientId,
                treatmentId: treatmentId,
                scheduledTime: scheduledTime,
                deadlineTime: deadlineTime,
                status: status,
                snoozeCount: snoozeCount,
                ruleId: ruleId,
                ruleExplanation: ruleExplanation,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required String treatmentId,
                required DateTime scheduledTime,
                required DateTime deadlineTime,
                Value<String> status = const Value.absent(),
                Value<int> snoozeCount = const Value.absent(),
                required String ruleId,
                required String ruleExplanation,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersTableCompanion.insert(
                id: id,
                patientId: patientId,
                treatmentId: treatmentId,
                scheduledTime: scheduledTime,
                deadlineTime: deadlineTime,
                status: status,
                snoozeCount: snoozeCount,
                ruleId: ruleId,
                ruleExplanation: ruleExplanation,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RemindersTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                patientId = false,
                treatmentId = false,
                intakesTableRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (intakesTableRefs) db.intakesTable,
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
                        if (patientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.patientId,
                                    referencedTable:
                                        $$RemindersTableTableReferences
                                            ._patientIdTable(db),
                                    referencedColumn:
                                        $$RemindersTableTableReferences
                                            ._patientIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (treatmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.treatmentId,
                                    referencedTable:
                                        $$RemindersTableTableReferences
                                            ._treatmentIdTable(db),
                                    referencedColumn:
                                        $$RemindersTableTableReferences
                                            ._treatmentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (intakesTableRefs)
                        await $_getPrefetchedData<
                          RemindersTableData,
                          $RemindersTableTable,
                          IntakesTableData
                        >(
                          currentTable: table,
                          referencedTable: $$RemindersTableTableReferences
                              ._intakesTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RemindersTableTableReferences(
                                db,
                                table,
                                p0,
                              ).intakesTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.reminderId == item.id,
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

typedef $$RemindersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTableTable,
      RemindersTableData,
      $$RemindersTableTableFilterComposer,
      $$RemindersTableTableOrderingComposer,
      $$RemindersTableTableAnnotationComposer,
      $$RemindersTableTableCreateCompanionBuilder,
      $$RemindersTableTableUpdateCompanionBuilder,
      (RemindersTableData, $$RemindersTableTableReferences),
      RemindersTableData,
      PrefetchHooks Function({
        bool patientId,
        bool treatmentId,
        bool intakesTableRefs,
      })
    >;
typedef $$IntakesTableTableCreateCompanionBuilder =
    IntakesTableCompanion Function({
      required String id,
      required String reminderId,
      required String result,
      Value<DateTime?> actualTime,
      Value<int?> minutesLate,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });
typedef $$IntakesTableTableUpdateCompanionBuilder =
    IntakesTableCompanion Function({
      Value<String> id,
      Value<String> reminderId,
      Value<String> result,
      Value<DateTime?> actualTime,
      Value<int?> minutesLate,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

final class $$IntakesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $IntakesTableTable, IntakesTableData> {
  $$IntakesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RemindersTableTable _reminderIdTable(_$AppDatabase db) =>
      db.remindersTable.createAlias(
        $_aliasNameGenerator(db.intakesTable.reminderId, db.remindersTable.id),
      );

  $$RemindersTableTableProcessedTableManager get reminderId {
    final $_column = $_itemColumn<String>('reminder_id')!;

    final manager = $$RemindersTableTableTableManager(
      $_db,
      $_db.remindersTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_reminderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntakesTableTableFilterComposer
    extends Composer<_$AppDatabase, $IntakesTableTable> {
  $$IntakesTableTableFilterComposer({
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

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RemindersTableTableFilterComposer get reminderId {
    final $$RemindersTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableFilterComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $IntakesTableTable> {
  $$IntakesTableTableOrderingComposer({
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

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RemindersTableTableOrderingComposer get reminderId {
    final $$RemindersTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableOrderingComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntakesTableTable> {
  $$IntakesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get actualTime => $composableBuilder(
    column: $table.actualTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutesLate => $composableBuilder(
    column: $table.minutesLate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$RemindersTableTableAnnotationComposer get reminderId {
    final $$RemindersTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.reminderId,
      referencedTable: $db.remindersTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RemindersTableTableAnnotationComposer(
            $db: $db,
            $table: $db.remindersTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntakesTableTable,
          IntakesTableData,
          $$IntakesTableTableFilterComposer,
          $$IntakesTableTableOrderingComposer,
          $$IntakesTableTableAnnotationComposer,
          $$IntakesTableTableCreateCompanionBuilder,
          $$IntakesTableTableUpdateCompanionBuilder,
          (IntakesTableData, $$IntakesTableTableReferences),
          IntakesTableData,
          PrefetchHooks Function({bool reminderId})
        > {
  $$IntakesTableTableTableManager(_$AppDatabase db, $IntakesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntakesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntakesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntakesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> reminderId = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<DateTime?> actualTime = const Value.absent(),
                Value<int?> minutesLate = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakesTableCompanion(
                id: id,
                reminderId: reminderId,
                result: result,
                actualTime: actualTime,
                minutesLate: minutesLate,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String reminderId,
                required String result,
                Value<DateTime?> actualTime = const Value.absent(),
                Value<int?> minutesLate = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IntakesTableCompanion.insert(
                id: id,
                reminderId: reminderId,
                result: result,
                actualTime: actualTime,
                minutesLate: minutesLate,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntakesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({reminderId = false}) {
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
                    if (reminderId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.reminderId,
                                referencedTable: $$IntakesTableTableReferences
                                    ._reminderIdTable(db),
                                referencedColumn: $$IntakesTableTableReferences
                                    ._reminderIdTable(db)
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

typedef $$IntakesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntakesTableTable,
      IntakesTableData,
      $$IntakesTableTableFilterComposer,
      $$IntakesTableTableOrderingComposer,
      $$IntakesTableTableAnnotationComposer,
      $$IntakesTableTableCreateCompanionBuilder,
      $$IntakesTableTableUpdateCompanionBuilder,
      (IntakesTableData, $$IntakesTableTableReferences),
      IntakesTableData,
      PrefetchHooks Function({bool reminderId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db, _db.patientsTable);
  $$MedicationsTableTableTableManager get medicationsTable =>
      $$MedicationsTableTableTableManager(_db, _db.medicationsTable);
  $$TreatmentsTableTableTableManager get treatmentsTable =>
      $$TreatmentsTableTableTableManager(_db, _db.treatmentsTable);
  $$RemindersTableTableTableManager get remindersTable =>
      $$RemindersTableTableTableManager(_db, _db.remindersTable);
  $$IntakesTableTableTableManager get intakesTable =>
      $$IntakesTableTableTableManager(_db, _db.intakesTable);
}
