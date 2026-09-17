// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EquipmentProfilesTable extends EquipmentProfiles
    with TableInfo<$EquipmentProfilesTable, EquipmentProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EquipmentProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
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
  static const VerificationMeta _sensorWidthMeta = const VerificationMeta(
    'sensorWidth',
  );
  @override
  late final GeneratedColumn<double> sensorWidth = GeneratedColumn<double>(
    'sensor_width',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorHeightMeta = const VerificationMeta(
    'sensorHeight',
  );
  @override
  late final GeneratedColumn<double> sensorHeight = GeneratedColumn<double>(
    'sensor_height',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pixelPitchMeta = const VerificationMeta(
    'pixelPitch',
  );
  @override
  late final GeneratedColumn<double> pixelPitch = GeneratedColumn<double>(
    'pixel_pitch',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionWidthMeta = const VerificationMeta(
    'resolutionWidth',
  );
  @override
  late final GeneratedColumn<int> resolutionWidth = GeneratedColumn<int>(
    'resolution_width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionHeightMeta = const VerificationMeta(
    'resolutionHeight',
  );
  @override
  late final GeneratedColumn<int> resolutionHeight = GeneratedColumn<int>(
    'resolution_height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focalLengthMeta = const VerificationMeta(
    'focalLength',
  );
  @override
  late final GeneratedColumn<double> focalLength = GeneratedColumn<double>(
    'focal_length',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _apertureMeta = const VerificationMeta(
    'aperture',
  );
  @override
  late final GeneratedColumn<double> aperture = GeneratedColumn<double>(
    'aperture',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opticalMultiplierMeta = const VerificationMeta(
    'opticalMultiplier',
  );
  @override
  late final GeneratedColumn<double> opticalMultiplier =
      GeneratedColumn<double>(
        'optical_multiplier',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(1.0),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    sensorWidth,
    sensorHeight,
    pixelPitch,
    resolutionWidth,
    resolutionHeight,
    focalLength,
    aperture,
    opticalMultiplier,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'equipment_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<EquipmentProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sensor_width')) {
      context.handle(
        _sensorWidthMeta,
        sensorWidth.isAcceptableOrUnknown(
          data['sensor_width']!,
          _sensorWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorWidthMeta);
    }
    if (data.containsKey('sensor_height')) {
      context.handle(
        _sensorHeightMeta,
        sensorHeight.isAcceptableOrUnknown(
          data['sensor_height']!,
          _sensorHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorHeightMeta);
    }
    if (data.containsKey('pixel_pitch')) {
      context.handle(
        _pixelPitchMeta,
        pixelPitch.isAcceptableOrUnknown(data['pixel_pitch']!, _pixelPitchMeta),
      );
    } else if (isInserting) {
      context.missing(_pixelPitchMeta);
    }
    if (data.containsKey('resolution_width')) {
      context.handle(
        _resolutionWidthMeta,
        resolutionWidth.isAcceptableOrUnknown(
          data['resolution_width']!,
          _resolutionWidthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionWidthMeta);
    }
    if (data.containsKey('resolution_height')) {
      context.handle(
        _resolutionHeightMeta,
        resolutionHeight.isAcceptableOrUnknown(
          data['resolution_height']!,
          _resolutionHeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionHeightMeta);
    }
    if (data.containsKey('focal_length')) {
      context.handle(
        _focalLengthMeta,
        focalLength.isAcceptableOrUnknown(
          data['focal_length']!,
          _focalLengthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_focalLengthMeta);
    }
    if (data.containsKey('aperture')) {
      context.handle(
        _apertureMeta,
        aperture.isAcceptableOrUnknown(data['aperture']!, _apertureMeta),
      );
    } else if (isInserting) {
      context.missing(_apertureMeta);
    }
    if (data.containsKey('optical_multiplier')) {
      context.handle(
        _opticalMultiplierMeta,
        opticalMultiplier.isAcceptableOrUnknown(
          data['optical_multiplier']!,
          _opticalMultiplierMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EquipmentProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EquipmentProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sensorWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_width'],
      )!,
      sensorHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_height'],
      )!,
      pixelPitch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pixel_pitch'],
      )!,
      resolutionWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_width'],
      )!,
      resolutionHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_height'],
      )!,
      focalLength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focal_length'],
      )!,
      aperture: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aperture'],
      )!,
      opticalMultiplier: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}optical_multiplier'],
      )!,
    );
  }

  @override
  $EquipmentProfilesTable createAlias(String alias) {
    return $EquipmentProfilesTable(attachedDatabase, alias);
  }
}

class EquipmentProfile extends DataClass
    implements Insertable<EquipmentProfile> {
  final int id;
  final String name;
  final double sensorWidth;
  final double sensorHeight;
  final double pixelPitch;
  final int resolutionWidth;
  final int resolutionHeight;
  final double focalLength;
  final double aperture;
  final double opticalMultiplier;
  const EquipmentProfile({
    required this.id,
    required this.name,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.pixelPitch,
    required this.resolutionWidth,
    required this.resolutionHeight,
    required this.focalLength,
    required this.aperture,
    required this.opticalMultiplier,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sensor_width'] = Variable<double>(sensorWidth);
    map['sensor_height'] = Variable<double>(sensorHeight);
    map['pixel_pitch'] = Variable<double>(pixelPitch);
    map['resolution_width'] = Variable<int>(resolutionWidth);
    map['resolution_height'] = Variable<int>(resolutionHeight);
    map['focal_length'] = Variable<double>(focalLength);
    map['aperture'] = Variable<double>(aperture);
    map['optical_multiplier'] = Variable<double>(opticalMultiplier);
    return map;
  }

  EquipmentProfilesCompanion toCompanion(bool nullToAbsent) {
    return EquipmentProfilesCompanion(
      id: Value(id),
      name: Value(name),
      sensorWidth: Value(sensorWidth),
      sensorHeight: Value(sensorHeight),
      pixelPitch: Value(pixelPitch),
      resolutionWidth: Value(resolutionWidth),
      resolutionHeight: Value(resolutionHeight),
      focalLength: Value(focalLength),
      aperture: Value(aperture),
      opticalMultiplier: Value(opticalMultiplier),
    );
  }

  factory EquipmentProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EquipmentProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sensorWidth: serializer.fromJson<double>(json['sensorWidth']),
      sensorHeight: serializer.fromJson<double>(json['sensorHeight']),
      pixelPitch: serializer.fromJson<double>(json['pixelPitch']),
      resolutionWidth: serializer.fromJson<int>(json['resolutionWidth']),
      resolutionHeight: serializer.fromJson<int>(json['resolutionHeight']),
      focalLength: serializer.fromJson<double>(json['focalLength']),
      aperture: serializer.fromJson<double>(json['aperture']),
      opticalMultiplier: serializer.fromJson<double>(json['opticalMultiplier']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sensorWidth': serializer.toJson<double>(sensorWidth),
      'sensorHeight': serializer.toJson<double>(sensorHeight),
      'pixelPitch': serializer.toJson<double>(pixelPitch),
      'resolutionWidth': serializer.toJson<int>(resolutionWidth),
      'resolutionHeight': serializer.toJson<int>(resolutionHeight),
      'focalLength': serializer.toJson<double>(focalLength),
      'aperture': serializer.toJson<double>(aperture),
      'opticalMultiplier': serializer.toJson<double>(opticalMultiplier),
    };
  }

  EquipmentProfile copyWith({
    int? id,
    String? name,
    double? sensorWidth,
    double? sensorHeight,
    double? pixelPitch,
    int? resolutionWidth,
    int? resolutionHeight,
    double? focalLength,
    double? aperture,
    double? opticalMultiplier,
  }) => EquipmentProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    sensorWidth: sensorWidth ?? this.sensorWidth,
    sensorHeight: sensorHeight ?? this.sensorHeight,
    pixelPitch: pixelPitch ?? this.pixelPitch,
    resolutionWidth: resolutionWidth ?? this.resolutionWidth,
    resolutionHeight: resolutionHeight ?? this.resolutionHeight,
    focalLength: focalLength ?? this.focalLength,
    aperture: aperture ?? this.aperture,
    opticalMultiplier: opticalMultiplier ?? this.opticalMultiplier,
  );
  EquipmentProfile copyWithCompanion(EquipmentProfilesCompanion data) {
    return EquipmentProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sensorWidth: data.sensorWidth.present
          ? data.sensorWidth.value
          : this.sensorWidth,
      sensorHeight: data.sensorHeight.present
          ? data.sensorHeight.value
          : this.sensorHeight,
      pixelPitch: data.pixelPitch.present
          ? data.pixelPitch.value
          : this.pixelPitch,
      resolutionWidth: data.resolutionWidth.present
          ? data.resolutionWidth.value
          : this.resolutionWidth,
      resolutionHeight: data.resolutionHeight.present
          ? data.resolutionHeight.value
          : this.resolutionHeight,
      focalLength: data.focalLength.present
          ? data.focalLength.value
          : this.focalLength,
      aperture: data.aperture.present ? data.aperture.value : this.aperture,
      opticalMultiplier: data.opticalMultiplier.present
          ? data.opticalMultiplier.value
          : this.opticalMultiplier,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sensorWidth: $sensorWidth, ')
          ..write('sensorHeight: $sensorHeight, ')
          ..write('pixelPitch: $pixelPitch, ')
          ..write('resolutionWidth: $resolutionWidth, ')
          ..write('resolutionHeight: $resolutionHeight, ')
          ..write('focalLength: $focalLength, ')
          ..write('aperture: $aperture, ')
          ..write('opticalMultiplier: $opticalMultiplier')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    sensorWidth,
    sensorHeight,
    pixelPitch,
    resolutionWidth,
    resolutionHeight,
    focalLength,
    aperture,
    opticalMultiplier,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EquipmentProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.sensorWidth == this.sensorWidth &&
          other.sensorHeight == this.sensorHeight &&
          other.pixelPitch == this.pixelPitch &&
          other.resolutionWidth == this.resolutionWidth &&
          other.resolutionHeight == this.resolutionHeight &&
          other.focalLength == this.focalLength &&
          other.aperture == this.aperture &&
          other.opticalMultiplier == this.opticalMultiplier);
}

class EquipmentProfilesCompanion extends UpdateCompanion<EquipmentProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> sensorWidth;
  final Value<double> sensorHeight;
  final Value<double> pixelPitch;
  final Value<int> resolutionWidth;
  final Value<int> resolutionHeight;
  final Value<double> focalLength;
  final Value<double> aperture;
  final Value<double> opticalMultiplier;
  const EquipmentProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sensorWidth = const Value.absent(),
    this.sensorHeight = const Value.absent(),
    this.pixelPitch = const Value.absent(),
    this.resolutionWidth = const Value.absent(),
    this.resolutionHeight = const Value.absent(),
    this.focalLength = const Value.absent(),
    this.aperture = const Value.absent(),
    this.opticalMultiplier = const Value.absent(),
  });
  EquipmentProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double sensorWidth,
    required double sensorHeight,
    required double pixelPitch,
    required int resolutionWidth,
    required int resolutionHeight,
    required double focalLength,
    required double aperture,
    this.opticalMultiplier = const Value.absent(),
  }) : name = Value(name),
       sensorWidth = Value(sensorWidth),
       sensorHeight = Value(sensorHeight),
       pixelPitch = Value(pixelPitch),
       resolutionWidth = Value(resolutionWidth),
       resolutionHeight = Value(resolutionHeight),
       focalLength = Value(focalLength),
       aperture = Value(aperture);
  static Insertable<EquipmentProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? sensorWidth,
    Expression<double>? sensorHeight,
    Expression<double>? pixelPitch,
    Expression<int>? resolutionWidth,
    Expression<int>? resolutionHeight,
    Expression<double>? focalLength,
    Expression<double>? aperture,
    Expression<double>? opticalMultiplier,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sensorWidth != null) 'sensor_width': sensorWidth,
      if (sensorHeight != null) 'sensor_height': sensorHeight,
      if (pixelPitch != null) 'pixel_pitch': pixelPitch,
      if (resolutionWidth != null) 'resolution_width': resolutionWidth,
      if (resolutionHeight != null) 'resolution_height': resolutionHeight,
      if (focalLength != null) 'focal_length': focalLength,
      if (aperture != null) 'aperture': aperture,
      if (opticalMultiplier != null) 'optical_multiplier': opticalMultiplier,
    });
  }

  EquipmentProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? sensorWidth,
    Value<double>? sensorHeight,
    Value<double>? pixelPitch,
    Value<int>? resolutionWidth,
    Value<int>? resolutionHeight,
    Value<double>? focalLength,
    Value<double>? aperture,
    Value<double>? opticalMultiplier,
  }) {
    return EquipmentProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sensorWidth: sensorWidth ?? this.sensorWidth,
      sensorHeight: sensorHeight ?? this.sensorHeight,
      pixelPitch: pixelPitch ?? this.pixelPitch,
      resolutionWidth: resolutionWidth ?? this.resolutionWidth,
      resolutionHeight: resolutionHeight ?? this.resolutionHeight,
      focalLength: focalLength ?? this.focalLength,
      aperture: aperture ?? this.aperture,
      opticalMultiplier: opticalMultiplier ?? this.opticalMultiplier,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sensorWidth.present) {
      map['sensor_width'] = Variable<double>(sensorWidth.value);
    }
    if (sensorHeight.present) {
      map['sensor_height'] = Variable<double>(sensorHeight.value);
    }
    if (pixelPitch.present) {
      map['pixel_pitch'] = Variable<double>(pixelPitch.value);
    }
    if (resolutionWidth.present) {
      map['resolution_width'] = Variable<int>(resolutionWidth.value);
    }
    if (resolutionHeight.present) {
      map['resolution_height'] = Variable<int>(resolutionHeight.value);
    }
    if (focalLength.present) {
      map['focal_length'] = Variable<double>(focalLength.value);
    }
    if (aperture.present) {
      map['aperture'] = Variable<double>(aperture.value);
    }
    if (opticalMultiplier.present) {
      map['optical_multiplier'] = Variable<double>(opticalMultiplier.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EquipmentProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sensorWidth: $sensorWidth, ')
          ..write('sensorHeight: $sensorHeight, ')
          ..write('pixelPitch: $pixelPitch, ')
          ..write('resolutionWidth: $resolutionWidth, ')
          ..write('resolutionHeight: $resolutionHeight, ')
          ..write('focalLength: $focalLength, ')
          ..write('aperture: $aperture, ')
          ..write('opticalMultiplier: $opticalMultiplier')
          ..write(')'))
        .toString();
  }
}

class $LocationProfilesTable extends LocationProfiles
    with TableInfo<$LocationProfilesTable, LocationProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
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
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elevationMeta = const VerificationMeta(
    'elevation',
  );
  @override
  late final GeneratedColumn<double> elevation = GeneratedColumn<double>(
    'elevation',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    elevation,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('elevation')) {
      context.handle(
        _elevationMeta,
        elevation.isAcceptableOrUnknown(data['elevation']!, _elevationMeta),
      );
    } else if (isInserting) {
      context.missing(_elevationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      elevation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation'],
      )!,
    );
  }

  @override
  $LocationProfilesTable createAlias(String alias) {
    return $LocationProfilesTable(attachedDatabase, alias);
  }
}

class LocationProfile extends DataClass implements Insertable<LocationProfile> {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double elevation;
  const LocationProfile({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['elevation'] = Variable<double>(elevation);
    return map;
  }

  LocationProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocationProfilesCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      elevation: Value(elevation),
    );
  }

  factory LocationProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      elevation: serializer.fromJson<double>(json['elevation']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'elevation': serializer.toJson<double>(elevation),
    };
  }

  LocationProfile copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    double? elevation,
  }) => LocationProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    elevation: elevation ?? this.elevation,
  );
  LocationProfile copyWithCompanion(LocationProfilesCompanion data) {
    return LocationProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      elevation: data.elevation.present ? data.elevation.value : this.elevation,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('elevation: $elevation')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, latitude, longitude, elevation);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.elevation == this.elevation);
}

class LocationProfilesCompanion extends UpdateCompanion<LocationProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> elevation;
  const LocationProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.elevation = const Value.absent(),
  });
  LocationProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double latitude,
    required double longitude,
    required double elevation,
  }) : name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       elevation = Value(elevation);
  static Insertable<LocationProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? elevation,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (elevation != null) 'elevation': elevation,
    });
  }

  LocationProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? elevation,
  }) {
    return LocationProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (elevation.present) {
      map['elevation'] = Variable<double>(elevation.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('elevation: $elevation')
          ..write(')'))
        .toString();
  }
}

class $AstroTargetsTable extends AstroTargets
    with TableInfo<$AstroTargetsTable, AstroTarget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AstroTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _catalogIdMeta = const VerificationMeta(
    'catalogId',
  );
  @override
  late final GeneratedColumn<String> catalogId = GeneratedColumn<String>(
    'catalog_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commonNameMeta = const VerificationMeta(
    'commonName',
  );
  @override
  late final GeneratedColumn<String> commonName = GeneratedColumn<String>(
    'common_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightAscensionMeta = const VerificationMeta(
    'rightAscension',
  );
  @override
  late final GeneratedColumn<double> rightAscension = GeneratedColumn<double>(
    'right_ascension',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _declinationMeta = const VerificationMeta(
    'declination',
  );
  @override
  late final GeneratedColumn<double> declination = GeneratedColumn<double>(
    'declination',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogId,
    commonName,
    rightAscension,
    declination,
    type,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'astro_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AstroTarget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('catalog_id')) {
      context.handle(
        _catalogIdMeta,
        catalogId.isAcceptableOrUnknown(data['catalog_id']!, _catalogIdMeta),
      );
    } else if (isInserting) {
      context.missing(_catalogIdMeta);
    }
    if (data.containsKey('common_name')) {
      context.handle(
        _commonNameMeta,
        commonName.isAcceptableOrUnknown(data['common_name']!, _commonNameMeta),
      );
    }
    if (data.containsKey('right_ascension')) {
      context.handle(
        _rightAscensionMeta,
        rightAscension.isAcceptableOrUnknown(
          data['right_ascension']!,
          _rightAscensionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rightAscensionMeta);
    }
    if (data.containsKey('declination')) {
      context.handle(
        _declinationMeta,
        declination.isAcceptableOrUnknown(
          data['declination']!,
          _declinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_declinationMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AstroTarget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AstroTarget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      catalogId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}catalog_id'],
      )!,
      commonName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}common_name'],
      ),
      rightAscension: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}right_ascension'],
      )!,
      declination: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}declination'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $AstroTargetsTable createAlias(String alias) {
    return $AstroTargetsTable(attachedDatabase, alias);
  }
}

class AstroTarget extends DataClass implements Insertable<AstroTarget> {
  final int id;
  final String catalogId;
  final String? commonName;
  final double rightAscension;
  final double declination;
  final String type;
  const AstroTarget({
    required this.id,
    required this.catalogId,
    this.commonName,
    required this.rightAscension,
    required this.declination,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['catalog_id'] = Variable<String>(catalogId);
    if (!nullToAbsent || commonName != null) {
      map['common_name'] = Variable<String>(commonName);
    }
    map['right_ascension'] = Variable<double>(rightAscension);
    map['declination'] = Variable<double>(declination);
    map['type'] = Variable<String>(type);
    return map;
  }

  AstroTargetsCompanion toCompanion(bool nullToAbsent) {
    return AstroTargetsCompanion(
      id: Value(id),
      catalogId: Value(catalogId),
      commonName: commonName == null && nullToAbsent
          ? const Value.absent()
          : Value(commonName),
      rightAscension: Value(rightAscension),
      declination: Value(declination),
      type: Value(type),
    );
  }

  factory AstroTarget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AstroTarget(
      id: serializer.fromJson<int>(json['id']),
      catalogId: serializer.fromJson<String>(json['catalogId']),
      commonName: serializer.fromJson<String?>(json['commonName']),
      rightAscension: serializer.fromJson<double>(json['rightAscension']),
      declination: serializer.fromJson<double>(json['declination']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'catalogId': serializer.toJson<String>(catalogId),
      'commonName': serializer.toJson<String?>(commonName),
      'rightAscension': serializer.toJson<double>(rightAscension),
      'declination': serializer.toJson<double>(declination),
      'type': serializer.toJson<String>(type),
    };
  }

  AstroTarget copyWith({
    int? id,
    String? catalogId,
    Value<String?> commonName = const Value.absent(),
    double? rightAscension,
    double? declination,
    String? type,
  }) => AstroTarget(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    commonName: commonName.present ? commonName.value : this.commonName,
    rightAscension: rightAscension ?? this.rightAscension,
    declination: declination ?? this.declination,
    type: type ?? this.type,
  );
  AstroTarget copyWithCompanion(AstroTargetsCompanion data) {
    return AstroTarget(
      id: data.id.present ? data.id.value : this.id,
      catalogId: data.catalogId.present ? data.catalogId.value : this.catalogId,
      commonName: data.commonName.present
          ? data.commonName.value
          : this.commonName,
      rightAscension: data.rightAscension.present
          ? data.rightAscension.value
          : this.rightAscension,
      declination: data.declination.present
          ? data.declination.value
          : this.declination,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AstroTarget(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('commonName: $commonName, ')
          ..write('rightAscension: $rightAscension, ')
          ..write('declination: $declination, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, catalogId, commonName, rightAscension, declination, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AstroTarget &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.commonName == this.commonName &&
          other.rightAscension == this.rightAscension &&
          other.declination == this.declination &&
          other.type == this.type);
}

class AstroTargetsCompanion extends UpdateCompanion<AstroTarget> {
  final Value<int> id;
  final Value<String> catalogId;
  final Value<String?> commonName;
  final Value<double> rightAscension;
  final Value<double> declination;
  final Value<String> type;
  const AstroTargetsCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.commonName = const Value.absent(),
    this.rightAscension = const Value.absent(),
    this.declination = const Value.absent(),
    this.type = const Value.absent(),
  });
  AstroTargetsCompanion.insert({
    this.id = const Value.absent(),
    required String catalogId,
    this.commonName = const Value.absent(),
    required double rightAscension,
    required double declination,
    required String type,
  }) : catalogId = Value(catalogId),
       rightAscension = Value(rightAscension),
       declination = Value(declination),
       type = Value(type);
  static Insertable<AstroTarget> custom({
    Expression<int>? id,
    Expression<String>? catalogId,
    Expression<String>? commonName,
    Expression<double>? rightAscension,
    Expression<double>? declination,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (commonName != null) 'common_name': commonName,
      if (rightAscension != null) 'right_ascension': rightAscension,
      if (declination != null) 'declination': declination,
      if (type != null) 'type': type,
    });
  }

  AstroTargetsCompanion copyWith({
    Value<int>? id,
    Value<String>? catalogId,
    Value<String?>? commonName,
    Value<double>? rightAscension,
    Value<double>? declination,
    Value<String>? type,
  }) {
    return AstroTargetsCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      commonName: commonName ?? this.commonName,
      rightAscension: rightAscension ?? this.rightAscension,
      declination: declination ?? this.declination,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (catalogId.present) {
      map['catalog_id'] = Variable<String>(catalogId.value);
    }
    if (commonName.present) {
      map['common_name'] = Variable<String>(commonName.value);
    }
    if (rightAscension.present) {
      map['right_ascension'] = Variable<double>(rightAscension.value);
    }
    if (declination.present) {
      map['declination'] = Variable<double>(declination.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AstroTargetsCompanion(')
          ..write('id: $id, ')
          ..write('catalogId: $catalogId, ')
          ..write('commonName: $commonName, ')
          ..write('rightAscension: $rightAscension, ')
          ..write('declination: $declination, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $SessionLogsTable extends SessionLogs
    with TableInfo<$SessionLogsTable, SessionLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _targetNameMeta = const VerificationMeta(
    'targetName',
  );
  @override
  late final GeneratedColumn<String> targetName = GeneratedColumn<String>(
    'target_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentNameMeta = const VerificationMeta(
    'equipmentName',
  );
  @override
  late final GeneratedColumn<String> equipmentName = GeneratedColumn<String>(
    'equipment_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionDateMeta = const VerificationMeta(
    'sessionDate',
  );
  @override
  late final GeneratedColumn<DateTime> sessionDate = GeneratedColumn<DateTime>(
    'session_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plannedLightFramesMeta =
      const VerificationMeta('plannedLightFrames');
  @override
  late final GeneratedColumn<int> plannedLightFrames = GeneratedColumn<int>(
    'planned_light_frames',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualLightFramesMeta = const VerificationMeta(
    'actualLightFrames',
  );
  @override
  late final GeneratedColumn<int> actualLightFrames = GeneratedColumn<int>(
    'actual_light_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedFramesMeta = const VerificationMeta(
    'rejectedFrames',
  );
  @override
  late final GeneratedColumn<int> rejectedFrames = GeneratedColumn<int>(
    'rejected_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _environmentalNotesMeta =
      const VerificationMeta('environmentalNotes');
  @override
  late final GeneratedColumn<String> environmentalNotes =
      GeneratedColumn<String>(
        'environmental_notes',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _processingNotesMeta = const VerificationMeta(
    'processingNotes',
  );
  @override
  late final GeneratedColumn<String> processingNotes = GeneratedColumn<String>(
    'processing_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetName,
    equipmentName,
    sessionDate,
    plannedLightFrames,
    actualLightFrames,
    rejectedFrames,
    environmentalNotes,
    processingNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('target_name')) {
      context.handle(
        _targetNameMeta,
        targetName.isAcceptableOrUnknown(data['target_name']!, _targetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_targetNameMeta);
    }
    if (data.containsKey('equipment_name')) {
      context.handle(
        _equipmentNameMeta,
        equipmentName.isAcceptableOrUnknown(
          data['equipment_name']!,
          _equipmentNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentNameMeta);
    }
    if (data.containsKey('session_date')) {
      context.handle(
        _sessionDateMeta,
        sessionDate.isAcceptableOrUnknown(
          data['session_date']!,
          _sessionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionDateMeta);
    }
    if (data.containsKey('planned_light_frames')) {
      context.handle(
        _plannedLightFramesMeta,
        plannedLightFrames.isAcceptableOrUnknown(
          data['planned_light_frames']!,
          _plannedLightFramesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedLightFramesMeta);
    }
    if (data.containsKey('actual_light_frames')) {
      context.handle(
        _actualLightFramesMeta,
        actualLightFrames.isAcceptableOrUnknown(
          data['actual_light_frames']!,
          _actualLightFramesMeta,
        ),
      );
    }
    if (data.containsKey('rejected_frames')) {
      context.handle(
        _rejectedFramesMeta,
        rejectedFrames.isAcceptableOrUnknown(
          data['rejected_frames']!,
          _rejectedFramesMeta,
        ),
      );
    }
    if (data.containsKey('environmental_notes')) {
      context.handle(
        _environmentalNotesMeta,
        environmentalNotes.isAcceptableOrUnknown(
          data['environmental_notes']!,
          _environmentalNotesMeta,
        ),
      );
    }
    if (data.containsKey('processing_notes')) {
      context.handle(
        _processingNotesMeta,
        processingNotes.isAcceptableOrUnknown(
          data['processing_notes']!,
          _processingNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      targetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_name'],
      )!,
      equipmentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_name'],
      )!,
      sessionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}session_date'],
      )!,
      plannedLightFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_light_frames'],
      )!,
      actualLightFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_light_frames'],
      ),
      rejectedFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rejected_frames'],
      ),
      environmentalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}environmental_notes'],
      ),
      processingNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_notes'],
      ),
    );
  }

  @override
  $SessionLogsTable createAlias(String alias) {
    return $SessionLogsTable(attachedDatabase, alias);
  }
}

class SessionLog extends DataClass implements Insertable<SessionLog> {
  final int id;
  final String targetName;
  final String equipmentName;
  final DateTime sessionDate;
  final int plannedLightFrames;
  final int? actualLightFrames;
  final int? rejectedFrames;
  final String? environmentalNotes;
  final String? processingNotes;
  const SessionLog({
    required this.id,
    required this.targetName,
    required this.equipmentName,
    required this.sessionDate,
    required this.plannedLightFrames,
    this.actualLightFrames,
    this.rejectedFrames,
    this.environmentalNotes,
    this.processingNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['target_name'] = Variable<String>(targetName);
    map['equipment_name'] = Variable<String>(equipmentName);
    map['session_date'] = Variable<DateTime>(sessionDate);
    map['planned_light_frames'] = Variable<int>(plannedLightFrames);
    if (!nullToAbsent || actualLightFrames != null) {
      map['actual_light_frames'] = Variable<int>(actualLightFrames);
    }
    if (!nullToAbsent || rejectedFrames != null) {
      map['rejected_frames'] = Variable<int>(rejectedFrames);
    }
    if (!nullToAbsent || environmentalNotes != null) {
      map['environmental_notes'] = Variable<String>(environmentalNotes);
    }
    if (!nullToAbsent || processingNotes != null) {
      map['processing_notes'] = Variable<String>(processingNotes);
    }
    return map;
  }

  SessionLogsCompanion toCompanion(bool nullToAbsent) {
    return SessionLogsCompanion(
      id: Value(id),
      targetName: Value(targetName),
      equipmentName: Value(equipmentName),
      sessionDate: Value(sessionDate),
      plannedLightFrames: Value(plannedLightFrames),
      actualLightFrames: actualLightFrames == null && nullToAbsent
          ? const Value.absent()
          : Value(actualLightFrames),
      rejectedFrames: rejectedFrames == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectedFrames),
      environmentalNotes: environmentalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(environmentalNotes),
      processingNotes: processingNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(processingNotes),
    );
  }

  factory SessionLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionLog(
      id: serializer.fromJson<int>(json['id']),
      targetName: serializer.fromJson<String>(json['targetName']),
      equipmentName: serializer.fromJson<String>(json['equipmentName']),
      sessionDate: serializer.fromJson<DateTime>(json['sessionDate']),
      plannedLightFrames: serializer.fromJson<int>(json['plannedLightFrames']),
      actualLightFrames: serializer.fromJson<int?>(json['actualLightFrames']),
      rejectedFrames: serializer.fromJson<int?>(json['rejectedFrames']),
      environmentalNotes: serializer.fromJson<String?>(
        json['environmentalNotes'],
      ),
      processingNotes: serializer.fromJson<String?>(json['processingNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'targetName': serializer.toJson<String>(targetName),
      'equipmentName': serializer.toJson<String>(equipmentName),
      'sessionDate': serializer.toJson<DateTime>(sessionDate),
      'plannedLightFrames': serializer.toJson<int>(plannedLightFrames),
      'actualLightFrames': serializer.toJson<int?>(actualLightFrames),
      'rejectedFrames': serializer.toJson<int?>(rejectedFrames),
      'environmentalNotes': serializer.toJson<String?>(environmentalNotes),
      'processingNotes': serializer.toJson<String?>(processingNotes),
    };
  }

  SessionLog copyWith({
    int? id,
    String? targetName,
    String? equipmentName,
    DateTime? sessionDate,
    int? plannedLightFrames,
    Value<int?> actualLightFrames = const Value.absent(),
    Value<int?> rejectedFrames = const Value.absent(),
    Value<String?> environmentalNotes = const Value.absent(),
    Value<String?> processingNotes = const Value.absent(),
  }) => SessionLog(
    id: id ?? this.id,
    targetName: targetName ?? this.targetName,
    equipmentName: equipmentName ?? this.equipmentName,
    sessionDate: sessionDate ?? this.sessionDate,
    plannedLightFrames: plannedLightFrames ?? this.plannedLightFrames,
    actualLightFrames: actualLightFrames.present
        ? actualLightFrames.value
        : this.actualLightFrames,
    rejectedFrames: rejectedFrames.present
        ? rejectedFrames.value
        : this.rejectedFrames,
    environmentalNotes: environmentalNotes.present
        ? environmentalNotes.value
        : this.environmentalNotes,
    processingNotes: processingNotes.present
        ? processingNotes.value
        : this.processingNotes,
  );
  SessionLog copyWithCompanion(SessionLogsCompanion data) {
    return SessionLog(
      id: data.id.present ? data.id.value : this.id,
      targetName: data.targetName.present
          ? data.targetName.value
          : this.targetName,
      equipmentName: data.equipmentName.present
          ? data.equipmentName.value
          : this.equipmentName,
      sessionDate: data.sessionDate.present
          ? data.sessionDate.value
          : this.sessionDate,
      plannedLightFrames: data.plannedLightFrames.present
          ? data.plannedLightFrames.value
          : this.plannedLightFrames,
      actualLightFrames: data.actualLightFrames.present
          ? data.actualLightFrames.value
          : this.actualLightFrames,
      rejectedFrames: data.rejectedFrames.present
          ? data.rejectedFrames.value
          : this.rejectedFrames,
      environmentalNotes: data.environmentalNotes.present
          ? data.environmentalNotes.value
          : this.environmentalNotes,
      processingNotes: data.processingNotes.present
          ? data.processingNotes.value
          : this.processingNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionLog(')
          ..write('id: $id, ')
          ..write('targetName: $targetName, ')
          ..write('equipmentName: $equipmentName, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('plannedLightFrames: $plannedLightFrames, ')
          ..write('actualLightFrames: $actualLightFrames, ')
          ..write('rejectedFrames: $rejectedFrames, ')
          ..write('environmentalNotes: $environmentalNotes, ')
          ..write('processingNotes: $processingNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetName,
    equipmentName,
    sessionDate,
    plannedLightFrames,
    actualLightFrames,
    rejectedFrames,
    environmentalNotes,
    processingNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionLog &&
          other.id == this.id &&
          other.targetName == this.targetName &&
          other.equipmentName == this.equipmentName &&
          other.sessionDate == this.sessionDate &&
          other.plannedLightFrames == this.plannedLightFrames &&
          other.actualLightFrames == this.actualLightFrames &&
          other.rejectedFrames == this.rejectedFrames &&
          other.environmentalNotes == this.environmentalNotes &&
          other.processingNotes == this.processingNotes);
}

class SessionLogsCompanion extends UpdateCompanion<SessionLog> {
  final Value<int> id;
  final Value<String> targetName;
  final Value<String> equipmentName;
  final Value<DateTime> sessionDate;
  final Value<int> plannedLightFrames;
  final Value<int?> actualLightFrames;
  final Value<int?> rejectedFrames;
  final Value<String?> environmentalNotes;
  final Value<String?> processingNotes;
  const SessionLogsCompanion({
    this.id = const Value.absent(),
    this.targetName = const Value.absent(),
    this.equipmentName = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.plannedLightFrames = const Value.absent(),
    this.actualLightFrames = const Value.absent(),
    this.rejectedFrames = const Value.absent(),
    this.environmentalNotes = const Value.absent(),
    this.processingNotes = const Value.absent(),
  });
  SessionLogsCompanion.insert({
    this.id = const Value.absent(),
    required String targetName,
    required String equipmentName,
    required DateTime sessionDate,
    required int plannedLightFrames,
    this.actualLightFrames = const Value.absent(),
    this.rejectedFrames = const Value.absent(),
    this.environmentalNotes = const Value.absent(),
    this.processingNotes = const Value.absent(),
  }) : targetName = Value(targetName),
       equipmentName = Value(equipmentName),
       sessionDate = Value(sessionDate),
       plannedLightFrames = Value(plannedLightFrames);
  static Insertable<SessionLog> custom({
    Expression<int>? id,
    Expression<String>? targetName,
    Expression<String>? equipmentName,
    Expression<DateTime>? sessionDate,
    Expression<int>? plannedLightFrames,
    Expression<int>? actualLightFrames,
    Expression<int>? rejectedFrames,
    Expression<String>? environmentalNotes,
    Expression<String>? processingNotes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetName != null) 'target_name': targetName,
      if (equipmentName != null) 'equipment_name': equipmentName,
      if (sessionDate != null) 'session_date': sessionDate,
      if (plannedLightFrames != null)
        'planned_light_frames': plannedLightFrames,
      if (actualLightFrames != null) 'actual_light_frames': actualLightFrames,
      if (rejectedFrames != null) 'rejected_frames': rejectedFrames,
      if (environmentalNotes != null) 'environmental_notes': environmentalNotes,
      if (processingNotes != null) 'processing_notes': processingNotes,
    });
  }

  SessionLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? targetName,
    Value<String>? equipmentName,
    Value<DateTime>? sessionDate,
    Value<int>? plannedLightFrames,
    Value<int?>? actualLightFrames,
    Value<int?>? rejectedFrames,
    Value<String?>? environmentalNotes,
    Value<String?>? processingNotes,
  }) {
    return SessionLogsCompanion(
      id: id ?? this.id,
      targetName: targetName ?? this.targetName,
      equipmentName: equipmentName ?? this.equipmentName,
      sessionDate: sessionDate ?? this.sessionDate,
      plannedLightFrames: plannedLightFrames ?? this.plannedLightFrames,
      actualLightFrames: actualLightFrames ?? this.actualLightFrames,
      rejectedFrames: rejectedFrames ?? this.rejectedFrames,
      environmentalNotes: environmentalNotes ?? this.environmentalNotes,
      processingNotes: processingNotes ?? this.processingNotes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (targetName.present) {
      map['target_name'] = Variable<String>(targetName.value);
    }
    if (equipmentName.present) {
      map['equipment_name'] = Variable<String>(equipmentName.value);
    }
    if (sessionDate.present) {
      map['session_date'] = Variable<DateTime>(sessionDate.value);
    }
    if (plannedLightFrames.present) {
      map['planned_light_frames'] = Variable<int>(plannedLightFrames.value);
    }
    if (actualLightFrames.present) {
      map['actual_light_frames'] = Variable<int>(actualLightFrames.value);
    }
    if (rejectedFrames.present) {
      map['rejected_frames'] = Variable<int>(rejectedFrames.value);
    }
    if (environmentalNotes.present) {
      map['environmental_notes'] = Variable<String>(environmentalNotes.value);
    }
    if (processingNotes.present) {
      map['processing_notes'] = Variable<String>(processingNotes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionLogsCompanion(')
          ..write('id: $id, ')
          ..write('targetName: $targetName, ')
          ..write('equipmentName: $equipmentName, ')
          ..write('sessionDate: $sessionDate, ')
          ..write('plannedLightFrames: $plannedLightFrames, ')
          ..write('actualLightFrames: $actualLightFrames, ')
          ..write('rejectedFrames: $rejectedFrames, ')
          ..write('environmentalNotes: $environmentalNotes, ')
          ..write('processingNotes: $processingNotes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EquipmentProfilesTable equipmentProfiles =
      $EquipmentProfilesTable(this);
  late final $LocationProfilesTable locationProfiles = $LocationProfilesTable(
    this,
  );
  late final $AstroTargetsTable astroTargets = $AstroTargetsTable(this);
  late final $SessionLogsTable sessionLogs = $SessionLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    equipmentProfiles,
    locationProfiles,
    astroTargets,
    sessionLogs,
  ];
}

typedef $$EquipmentProfilesTableCreateCompanionBuilder =
    EquipmentProfilesCompanion Function({
      Value<int> id,
      required String name,
      required double sensorWidth,
      required double sensorHeight,
      required double pixelPitch,
      required int resolutionWidth,
      required int resolutionHeight,
      required double focalLength,
      required double aperture,
      Value<double> opticalMultiplier,
    });
typedef $$EquipmentProfilesTableUpdateCompanionBuilder =
    EquipmentProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> sensorWidth,
      Value<double> sensorHeight,
      Value<double> pixelPitch,
      Value<int> resolutionWidth,
      Value<int> resolutionHeight,
      Value<double> focalLength,
      Value<double> aperture,
      Value<double> opticalMultiplier,
    });

class $$EquipmentProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $EquipmentProfilesTable> {
  $$EquipmentProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorWidth => $composableBuilder(
    column: $table.sensorWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorHeight => $composableBuilder(
    column: $table.sensorHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pixelPitch => $composableBuilder(
    column: $table.pixelPitch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionWidth => $composableBuilder(
    column: $table.resolutionWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionHeight => $composableBuilder(
    column: $table.resolutionHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aperture => $composableBuilder(
    column: $table.aperture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get opticalMultiplier => $composableBuilder(
    column: $table.opticalMultiplier,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EquipmentProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $EquipmentProfilesTable> {
  $$EquipmentProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorWidth => $composableBuilder(
    column: $table.sensorWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorHeight => $composableBuilder(
    column: $table.sensorHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pixelPitch => $composableBuilder(
    column: $table.pixelPitch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionWidth => $composableBuilder(
    column: $table.resolutionWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionHeight => $composableBuilder(
    column: $table.resolutionHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aperture => $composableBuilder(
    column: $table.aperture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get opticalMultiplier => $composableBuilder(
    column: $table.opticalMultiplier,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EquipmentProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EquipmentProfilesTable> {
  $$EquipmentProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get sensorWidth => $composableBuilder(
    column: $table.sensorWidth,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sensorHeight => $composableBuilder(
    column: $table.sensorHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pixelPitch => $composableBuilder(
    column: $table.pixelPitch,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionWidth => $composableBuilder(
    column: $table.resolutionWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionHeight => $composableBuilder(
    column: $table.resolutionHeight,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aperture =>
      $composableBuilder(column: $table.aperture, builder: (column) => column);

  GeneratedColumn<double> get opticalMultiplier => $composableBuilder(
    column: $table.opticalMultiplier,
    builder: (column) => column,
  );
}

class $$EquipmentProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EquipmentProfilesTable,
          EquipmentProfile,
          $$EquipmentProfilesTableFilterComposer,
          $$EquipmentProfilesTableOrderingComposer,
          $$EquipmentProfilesTableAnnotationComposer,
          $$EquipmentProfilesTableCreateCompanionBuilder,
          $$EquipmentProfilesTableUpdateCompanionBuilder,
          (
            EquipmentProfile,
            BaseReferences<
              _$AppDatabase,
              $EquipmentProfilesTable,
              EquipmentProfile
            >,
          ),
          EquipmentProfile,
          PrefetchHooks Function()
        > {
  $$EquipmentProfilesTableTableManager(
    _$AppDatabase db,
    $EquipmentProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EquipmentProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EquipmentProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EquipmentProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> sensorWidth = const Value.absent(),
                Value<double> sensorHeight = const Value.absent(),
                Value<double> pixelPitch = const Value.absent(),
                Value<int> resolutionWidth = const Value.absent(),
                Value<int> resolutionHeight = const Value.absent(),
                Value<double> focalLength = const Value.absent(),
                Value<double> aperture = const Value.absent(),
                Value<double> opticalMultiplier = const Value.absent(),
              }) => EquipmentProfilesCompanion(
                id: id,
                name: name,
                sensorWidth: sensorWidth,
                sensorHeight: sensorHeight,
                pixelPitch: pixelPitch,
                resolutionWidth: resolutionWidth,
                resolutionHeight: resolutionHeight,
                focalLength: focalLength,
                aperture: aperture,
                opticalMultiplier: opticalMultiplier,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double sensorWidth,
                required double sensorHeight,
                required double pixelPitch,
                required int resolutionWidth,
                required int resolutionHeight,
                required double focalLength,
                required double aperture,
                Value<double> opticalMultiplier = const Value.absent(),
              }) => EquipmentProfilesCompanion.insert(
                id: id,
                name: name,
                sensorWidth: sensorWidth,
                sensorHeight: sensorHeight,
                pixelPitch: pixelPitch,
                resolutionWidth: resolutionWidth,
                resolutionHeight: resolutionHeight,
                focalLength: focalLength,
                aperture: aperture,
                opticalMultiplier: opticalMultiplier,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EquipmentProfilesTable, EquipmentProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EquipmentProfilesTable,
                    EquipmentProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EquipmentProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EquipmentProfilesTable,
      EquipmentProfile,
      $$EquipmentProfilesTableFilterComposer,
      $$EquipmentProfilesTableOrderingComposer,
      $$EquipmentProfilesTableAnnotationComposer,
      $$EquipmentProfilesTableCreateCompanionBuilder,
      $$EquipmentProfilesTableUpdateCompanionBuilder,
      (
        EquipmentProfile,
        BaseReferences<
          _$AppDatabase,
          $EquipmentProfilesTable,
          EquipmentProfile
        >,
      ),
      EquipmentProfile,
      PrefetchHooks Function()
    >;
typedef $$LocationProfilesTableCreateCompanionBuilder =
    LocationProfilesCompanion Function({
      Value<int> id,
      required String name,
      required double latitude,
      required double longitude,
      required double elevation,
    });
typedef $$LocationProfilesTableUpdateCompanionBuilder =
    LocationProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> elevation,
    });

class $$LocationProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $LocationProfilesTable> {
  $$LocationProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevation => $composableBuilder(
    column: $table.elevation,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationProfilesTable> {
  $$LocationProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevation => $composableBuilder(
    column: $table.elevation,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationProfilesTable> {
  $$LocationProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get elevation =>
      $composableBuilder(column: $table.elevation, builder: (column) => column);
}

class $$LocationProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationProfilesTable,
          LocationProfile,
          $$LocationProfilesTableFilterComposer,
          $$LocationProfilesTableOrderingComposer,
          $$LocationProfilesTableAnnotationComposer,
          $$LocationProfilesTableCreateCompanionBuilder,
          $$LocationProfilesTableUpdateCompanionBuilder,
          (
            LocationProfile,
            BaseReferences<
              _$AppDatabase,
              $LocationProfilesTable,
              LocationProfile
            >,
          ),
          LocationProfile,
          PrefetchHooks Function()
        > {
  $$LocationProfilesTableTableManager(
    _$AppDatabase db,
    $LocationProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> elevation = const Value.absent(),
              }) => LocationProfilesCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double latitude,
                required double longitude,
                required double elevation,
              }) => LocationProfilesCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationProfilesTable, LocationProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LocationProfilesTable,
                    LocationProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationProfilesTable,
      LocationProfile,
      $$LocationProfilesTableFilterComposer,
      $$LocationProfilesTableOrderingComposer,
      $$LocationProfilesTableAnnotationComposer,
      $$LocationProfilesTableCreateCompanionBuilder,
      $$LocationProfilesTableUpdateCompanionBuilder,
      (
        LocationProfile,
        BaseReferences<_$AppDatabase, $LocationProfilesTable, LocationProfile>,
      ),
      LocationProfile,
      PrefetchHooks Function()
    >;
typedef $$AstroTargetsTableCreateCompanionBuilder =
    AstroTargetsCompanion Function({
      Value<int> id,
      required String catalogId,
      Value<String?> commonName,
      required double rightAscension,
      required double declination,
      required String type,
    });
typedef $$AstroTargetsTableUpdateCompanionBuilder =
    AstroTargetsCompanion Function({
      Value<int> id,
      Value<String> catalogId,
      Value<String?> commonName,
      Value<double> rightAscension,
      Value<double> declination,
      Value<String> type,
    });

class $$AstroTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $AstroTargetsTable> {
  $$AstroTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rightAscension => $composableBuilder(
    column: $table.rightAscension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get declination => $composableBuilder(
    column: $table.declination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AstroTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AstroTargetsTable> {
  $$AstroTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get catalogId => $composableBuilder(
    column: $table.catalogId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rightAscension => $composableBuilder(
    column: $table.rightAscension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get declination => $composableBuilder(
    column: $table.declination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AstroTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AstroTargetsTable> {
  $$AstroTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get catalogId =>
      $composableBuilder(column: $table.catalogId, builder: (column) => column);

  GeneratedColumn<String> get commonName => $composableBuilder(
    column: $table.commonName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rightAscension => $composableBuilder(
    column: $table.rightAscension,
    builder: (column) => column,
  );

  GeneratedColumn<double> get declination => $composableBuilder(
    column: $table.declination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$AstroTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AstroTargetsTable,
          AstroTarget,
          $$AstroTargetsTableFilterComposer,
          $$AstroTargetsTableOrderingComposer,
          $$AstroTargetsTableAnnotationComposer,
          $$AstroTargetsTableCreateCompanionBuilder,
          $$AstroTargetsTableUpdateCompanionBuilder,
          (
            AstroTarget,
            BaseReferences<_$AppDatabase, $AstroTargetsTable, AstroTarget>,
          ),
          AstroTarget,
          PrefetchHooks Function()
        > {
  $$AstroTargetsTableTableManager(_$AppDatabase db, $AstroTargetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AstroTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AstroTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AstroTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> catalogId = const Value.absent(),
                Value<String?> commonName = const Value.absent(),
                Value<double> rightAscension = const Value.absent(),
                Value<double> declination = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => AstroTargetsCompanion(
                id: id,
                catalogId: catalogId,
                commonName: commonName,
                rightAscension: rightAscension,
                declination: declination,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String catalogId,
                Value<String?> commonName = const Value.absent(),
                required double rightAscension,
                required double declination,
                required String type,
              }) => AstroTargetsCompanion.insert(
                id: id,
                catalogId: catalogId,
                commonName: commonName,
                rightAscension: rightAscension,
                declination: declination,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AstroTargetsTable, AstroTarget>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AstroTargetsTable,
                    AstroTarget
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AstroTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AstroTargetsTable,
      AstroTarget,
      $$AstroTargetsTableFilterComposer,
      $$AstroTargetsTableOrderingComposer,
      $$AstroTargetsTableAnnotationComposer,
      $$AstroTargetsTableCreateCompanionBuilder,
      $$AstroTargetsTableUpdateCompanionBuilder,
      (
        AstroTarget,
        BaseReferences<_$AppDatabase, $AstroTargetsTable, AstroTarget>,
      ),
      AstroTarget,
      PrefetchHooks Function()
    >;
typedef $$SessionLogsTableCreateCompanionBuilder =
    SessionLogsCompanion Function({
      Value<int> id,
      required String targetName,
      required String equipmentName,
      required DateTime sessionDate,
      required int plannedLightFrames,
      Value<int?> actualLightFrames,
      Value<int?> rejectedFrames,
      Value<String?> environmentalNotes,
      Value<String?> processingNotes,
    });
typedef $$SessionLogsTableUpdateCompanionBuilder =
    SessionLogsCompanion Function({
      Value<int> id,
      Value<String> targetName,
      Value<String> equipmentName,
      Value<DateTime> sessionDate,
      Value<int> plannedLightFrames,
      Value<int?> actualLightFrames,
      Value<int?> rejectedFrames,
      Value<String?> environmentalNotes,
      Value<String?> processingNotes,
    });

class $$SessionLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentName => $composableBuilder(
    column: $table.equipmentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualLightFrames => $composableBuilder(
    column: $table.actualLightFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rejectedFrames => $composableBuilder(
    column: $table.rejectedFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get environmentalNotes => $composableBuilder(
    column: $table.environmentalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingNotes => $composableBuilder(
    column: $table.processingNotes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentName => $composableBuilder(
    column: $table.equipmentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualLightFrames => $composableBuilder(
    column: $table.actualLightFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rejectedFrames => $composableBuilder(
    column: $table.rejectedFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get environmentalNotes => $composableBuilder(
    column: $table.environmentalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingNotes => $composableBuilder(
    column: $table.processingNotes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionLogsTable> {
  $$SessionLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get equipmentName => $composableBuilder(
    column: $table.equipmentName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get sessionDate => $composableBuilder(
    column: $table.sessionDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualLightFrames => $composableBuilder(
    column: $table.actualLightFrames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rejectedFrames => $composableBuilder(
    column: $table.rejectedFrames,
    builder: (column) => column,
  );

  GeneratedColumn<String> get environmentalNotes => $composableBuilder(
    column: $table.environmentalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingNotes => $composableBuilder(
    column: $table.processingNotes,
    builder: (column) => column,
  );
}

class $$SessionLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionLogsTable,
          SessionLog,
          $$SessionLogsTableFilterComposer,
          $$SessionLogsTableOrderingComposer,
          $$SessionLogsTableAnnotationComposer,
          $$SessionLogsTableCreateCompanionBuilder,
          $$SessionLogsTableUpdateCompanionBuilder,
          (
            SessionLog,
            BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLog>,
          ),
          SessionLog,
          PrefetchHooks Function()
        > {
  $$SessionLogsTableTableManager(_$AppDatabase db, $SessionLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> targetName = const Value.absent(),
                Value<String> equipmentName = const Value.absent(),
                Value<DateTime> sessionDate = const Value.absent(),
                Value<int> plannedLightFrames = const Value.absent(),
                Value<int?> actualLightFrames = const Value.absent(),
                Value<int?> rejectedFrames = const Value.absent(),
                Value<String?> environmentalNotes = const Value.absent(),
                Value<String?> processingNotes = const Value.absent(),
              }) => SessionLogsCompanion(
                id: id,
                targetName: targetName,
                equipmentName: equipmentName,
                sessionDate: sessionDate,
                plannedLightFrames: plannedLightFrames,
                actualLightFrames: actualLightFrames,
                rejectedFrames: rejectedFrames,
                environmentalNotes: environmentalNotes,
                processingNotes: processingNotes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String targetName,
                required String equipmentName,
                required DateTime sessionDate,
                required int plannedLightFrames,
                Value<int?> actualLightFrames = const Value.absent(),
                Value<int?> rejectedFrames = const Value.absent(),
                Value<String?> environmentalNotes = const Value.absent(),
                Value<String?> processingNotes = const Value.absent(),
              }) => SessionLogsCompanion.insert(
                id: id,
                targetName: targetName,
                equipmentName: equipmentName,
                sessionDate: sessionDate,
                plannedLightFrames: plannedLightFrames,
                actualLightFrames: actualLightFrames,
                rejectedFrames: rejectedFrames,
                environmentalNotes: environmentalNotes,
                processingNotes: processingNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionLogsTable, SessionLog>(table),
                  BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLog>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionLogsTable,
      SessionLog,
      $$SessionLogsTableFilterComposer,
      $$SessionLogsTableOrderingComposer,
      $$SessionLogsTableAnnotationComposer,
      $$SessionLogsTableCreateCompanionBuilder,
      $$SessionLogsTableUpdateCompanionBuilder,
      (
        SessionLog,
        BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLog>,
      ),
      SessionLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EquipmentProfilesTableTableManager get equipmentProfiles =>
      $$EquipmentProfilesTableTableManager(_db, _db.equipmentProfiles);
  $$LocationProfilesTableTableManager get locationProfiles =>
      $$LocationProfilesTableTableManager(_db, _db.locationProfiles);
  $$AstroTargetsTableTableManager get astroTargets =>
      $$AstroTargetsTableTableManager(_db, _db.astroTargets);
  $$SessionLogsTableTableManager get sessionLogs =>
      $$SessionLogsTableTableManager(_db, _db.sessionLogs);
}
