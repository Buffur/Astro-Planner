// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
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
  @override
  List<GeneratedColumn> get $columns => [id, name, manufacturer, model, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
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
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final int id;
  final String name;
  final String? manufacturer;
  final String? model;
  final String? notes;
  const Device({
    required this.id,
    required this.name,
    this.manufacturer,
    this.model,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Device copyWith({
    int? id,
    String? name,
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    model: model.present ? model.value : this.model,
    notes: notes.present ? notes.value : this.notes,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, manufacturer, model, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.notes == this.notes);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<String?> notes;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.notes = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.notes = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (notes != null) 'notes': notes,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? manufacturer,
    Value<String?>? model,
    Value<String?>? notes,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      notes: notes ?? this.notes,
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
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $CameraModulesTable extends CameraModules
    with TableInfo<$CameraModulesTable, CameraModule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CameraModulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<int> deviceId = GeneratedColumn<int>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices (id) ON DELETE RESTRICT',
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
  static const VerificationMeta _manufacturerMeta = const VerificationMeta(
    'manufacturer',
  );
  @override
  late final GeneratedColumn<String> manufacturer = GeneratedColumn<String>(
    'manufacturer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sensorWidthMmMeta = const VerificationMeta(
    'sensorWidthMm',
  );
  @override
  late final GeneratedColumn<double> sensorWidthMm = GeneratedColumn<double>(
    'sensor_width_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sensorHeightMmMeta = const VerificationMeta(
    'sensorHeightMm',
  );
  @override
  late final GeneratedColumn<double> sensorHeightMm = GeneratedColumn<double>(
    'sensor_height_mm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionWidthPxMeta = const VerificationMeta(
    'resolutionWidthPx',
  );
  @override
  late final GeneratedColumn<int> resolutionWidthPx = GeneratedColumn<int>(
    'resolution_width_px',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionHeightPxMeta =
      const VerificationMeta('resolutionHeightPx');
  @override
  late final GeneratedColumn<int> resolutionHeightPx = GeneratedColumn<int>(
    'resolution_height_px',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pixelPitchUmMeta = const VerificationMeta(
    'pixelPitchUm',
  );
  @override
  late final GeneratedColumn<double> pixelPitchUm = GeneratedColumn<double>(
    'pixel_pitch_um',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageRawFileSizeMBMeta =
      const VerificationMeta('averageRawFileSizeMB');
  @override
  late final GeneratedColumn<double> averageRawFileSizeMB =
      GeneratedColumn<double>(
        'average_raw_file_size_m_b',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    name,
    manufacturer,
    model,
    sensorWidthMm,
    sensorHeightMm,
    resolutionWidthPx,
    resolutionHeightPx,
    pixelPitchUm,
    averageRawFileSizeMB,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'camera_modules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CameraModule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('manufacturer')) {
      context.handle(
        _manufacturerMeta,
        manufacturer.isAcceptableOrUnknown(
          data['manufacturer']!,
          _manufacturerMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('sensor_width_mm')) {
      context.handle(
        _sensorWidthMmMeta,
        sensorWidthMm.isAcceptableOrUnknown(
          data['sensor_width_mm']!,
          _sensorWidthMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorWidthMmMeta);
    }
    if (data.containsKey('sensor_height_mm')) {
      context.handle(
        _sensorHeightMmMeta,
        sensorHeightMm.isAcceptableOrUnknown(
          data['sensor_height_mm']!,
          _sensorHeightMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sensorHeightMmMeta);
    }
    if (data.containsKey('resolution_width_px')) {
      context.handle(
        _resolutionWidthPxMeta,
        resolutionWidthPx.isAcceptableOrUnknown(
          data['resolution_width_px']!,
          _resolutionWidthPxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionWidthPxMeta);
    }
    if (data.containsKey('resolution_height_px')) {
      context.handle(
        _resolutionHeightPxMeta,
        resolutionHeightPx.isAcceptableOrUnknown(
          data['resolution_height_px']!,
          _resolutionHeightPxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionHeightPxMeta);
    }
    if (data.containsKey('pixel_pitch_um')) {
      context.handle(
        _pixelPitchUmMeta,
        pixelPitchUm.isAcceptableOrUnknown(
          data['pixel_pitch_um']!,
          _pixelPitchUmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pixelPitchUmMeta);
    }
    if (data.containsKey('average_raw_file_size_m_b')) {
      context.handle(
        _averageRawFileSizeMBMeta,
        averageRawFileSizeMB.isAcceptableOrUnknown(
          data['average_raw_file_size_m_b']!,
          _averageRawFileSizeMBMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CameraModule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CameraModule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      manufacturer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manufacturer'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      sensorWidthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_width_mm'],
      )!,
      sensorHeightMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sensor_height_mm'],
      )!,
      resolutionWidthPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_width_px'],
      )!,
      resolutionHeightPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolution_height_px'],
      )!,
      pixelPitchUm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pixel_pitch_um'],
      )!,
      averageRawFileSizeMB: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_raw_file_size_m_b'],
      ),
    );
  }

  @override
  $CameraModulesTable createAlias(String alias) {
    return $CameraModulesTable(attachedDatabase, alias);
  }
}

class CameraModule extends DataClass implements Insertable<CameraModule> {
  final int id;
  final int deviceId;
  final String name;
  final String? manufacturer;
  final String? model;
  final double sensorWidthMm;
  final double sensorHeightMm;
  final int resolutionWidthPx;
  final int resolutionHeightPx;
  final double pixelPitchUm;
  final double? averageRawFileSizeMB;
  const CameraModule({
    required this.id,
    required this.deviceId,
    required this.name,
    this.manufacturer,
    this.model,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.resolutionWidthPx,
    required this.resolutionHeightPx,
    required this.pixelPitchUm,
    this.averageRawFileSizeMB,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<int>(deviceId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || manufacturer != null) {
      map['manufacturer'] = Variable<String>(manufacturer);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['sensor_width_mm'] = Variable<double>(sensorWidthMm);
    map['sensor_height_mm'] = Variable<double>(sensorHeightMm);
    map['resolution_width_px'] = Variable<int>(resolutionWidthPx);
    map['resolution_height_px'] = Variable<int>(resolutionHeightPx);
    map['pixel_pitch_um'] = Variable<double>(pixelPitchUm);
    if (!nullToAbsent || averageRawFileSizeMB != null) {
      map['average_raw_file_size_m_b'] = Variable<double>(averageRawFileSizeMB);
    }
    return map;
  }

  CameraModulesCompanion toCompanion(bool nullToAbsent) {
    return CameraModulesCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      name: Value(name),
      manufacturer: manufacturer == null && nullToAbsent
          ? const Value.absent()
          : Value(manufacturer),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      sensorWidthMm: Value(sensorWidthMm),
      sensorHeightMm: Value(sensorHeightMm),
      resolutionWidthPx: Value(resolutionWidthPx),
      resolutionHeightPx: Value(resolutionHeightPx),
      pixelPitchUm: Value(pixelPitchUm),
      averageRawFileSizeMB: averageRawFileSizeMB == null && nullToAbsent
          ? const Value.absent()
          : Value(averageRawFileSizeMB),
    );
  }

  factory CameraModule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CameraModule(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<int>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      manufacturer: serializer.fromJson<String?>(json['manufacturer']),
      model: serializer.fromJson<String?>(json['model']),
      sensorWidthMm: serializer.fromJson<double>(json['sensorWidthMm']),
      sensorHeightMm: serializer.fromJson<double>(json['sensorHeightMm']),
      resolutionWidthPx: serializer.fromJson<int>(json['resolutionWidthPx']),
      resolutionHeightPx: serializer.fromJson<int>(json['resolutionHeightPx']),
      pixelPitchUm: serializer.fromJson<double>(json['pixelPitchUm']),
      averageRawFileSizeMB: serializer.fromJson<double?>(
        json['averageRawFileSizeMB'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<int>(deviceId),
      'name': serializer.toJson<String>(name),
      'manufacturer': serializer.toJson<String?>(manufacturer),
      'model': serializer.toJson<String?>(model),
      'sensorWidthMm': serializer.toJson<double>(sensorWidthMm),
      'sensorHeightMm': serializer.toJson<double>(sensorHeightMm),
      'resolutionWidthPx': serializer.toJson<int>(resolutionWidthPx),
      'resolutionHeightPx': serializer.toJson<int>(resolutionHeightPx),
      'pixelPitchUm': serializer.toJson<double>(pixelPitchUm),
      'averageRawFileSizeMB': serializer.toJson<double?>(averageRawFileSizeMB),
    };
  }

  CameraModule copyWith({
    int? id,
    int? deviceId,
    String? name,
    Value<String?> manufacturer = const Value.absent(),
    Value<String?> model = const Value.absent(),
    double? sensorWidthMm,
    double? sensorHeightMm,
    int? resolutionWidthPx,
    int? resolutionHeightPx,
    double? pixelPitchUm,
    Value<double?> averageRawFileSizeMB = const Value.absent(),
  }) => CameraModule(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    manufacturer: manufacturer.present ? manufacturer.value : this.manufacturer,
    model: model.present ? model.value : this.model,
    sensorWidthMm: sensorWidthMm ?? this.sensorWidthMm,
    sensorHeightMm: sensorHeightMm ?? this.sensorHeightMm,
    resolutionWidthPx: resolutionWidthPx ?? this.resolutionWidthPx,
    resolutionHeightPx: resolutionHeightPx ?? this.resolutionHeightPx,
    pixelPitchUm: pixelPitchUm ?? this.pixelPitchUm,
    averageRawFileSizeMB: averageRawFileSizeMB.present
        ? averageRawFileSizeMB.value
        : this.averageRawFileSizeMB,
  );
  CameraModule copyWithCompanion(CameraModulesCompanion data) {
    return CameraModule(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      manufacturer: data.manufacturer.present
          ? data.manufacturer.value
          : this.manufacturer,
      model: data.model.present ? data.model.value : this.model,
      sensorWidthMm: data.sensorWidthMm.present
          ? data.sensorWidthMm.value
          : this.sensorWidthMm,
      sensorHeightMm: data.sensorHeightMm.present
          ? data.sensorHeightMm.value
          : this.sensorHeightMm,
      resolutionWidthPx: data.resolutionWidthPx.present
          ? data.resolutionWidthPx.value
          : this.resolutionWidthPx,
      resolutionHeightPx: data.resolutionHeightPx.present
          ? data.resolutionHeightPx.value
          : this.resolutionHeightPx,
      pixelPitchUm: data.pixelPitchUm.present
          ? data.pixelPitchUm.value
          : this.pixelPitchUm,
      averageRawFileSizeMB: data.averageRawFileSizeMB.present
          ? data.averageRawFileSizeMB.value
          : this.averageRawFileSizeMB,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CameraModule(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('sensorWidthMm: $sensorWidthMm, ')
          ..write('sensorHeightMm: $sensorHeightMm, ')
          ..write('resolutionWidthPx: $resolutionWidthPx, ')
          ..write('resolutionHeightPx: $resolutionHeightPx, ')
          ..write('pixelPitchUm: $pixelPitchUm, ')
          ..write('averageRawFileSizeMB: $averageRawFileSizeMB')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    name,
    manufacturer,
    model,
    sensorWidthMm,
    sensorHeightMm,
    resolutionWidthPx,
    resolutionHeightPx,
    pixelPitchUm,
    averageRawFileSizeMB,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CameraModule &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.manufacturer == this.manufacturer &&
          other.model == this.model &&
          other.sensorWidthMm == this.sensorWidthMm &&
          other.sensorHeightMm == this.sensorHeightMm &&
          other.resolutionWidthPx == this.resolutionWidthPx &&
          other.resolutionHeightPx == this.resolutionHeightPx &&
          other.pixelPitchUm == this.pixelPitchUm &&
          other.averageRawFileSizeMB == this.averageRawFileSizeMB);
}

class CameraModulesCompanion extends UpdateCompanion<CameraModule> {
  final Value<int> id;
  final Value<int> deviceId;
  final Value<String> name;
  final Value<String?> manufacturer;
  final Value<String?> model;
  final Value<double> sensorWidthMm;
  final Value<double> sensorHeightMm;
  final Value<int> resolutionWidthPx;
  final Value<int> resolutionHeightPx;
  final Value<double> pixelPitchUm;
  final Value<double?> averageRawFileSizeMB;
  const CameraModulesCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    this.sensorWidthMm = const Value.absent(),
    this.sensorHeightMm = const Value.absent(),
    this.resolutionWidthPx = const Value.absent(),
    this.resolutionHeightPx = const Value.absent(),
    this.pixelPitchUm = const Value.absent(),
    this.averageRawFileSizeMB = const Value.absent(),
  });
  CameraModulesCompanion.insert({
    this.id = const Value.absent(),
    required int deviceId,
    required String name,
    this.manufacturer = const Value.absent(),
    this.model = const Value.absent(),
    required double sensorWidthMm,
    required double sensorHeightMm,
    required int resolutionWidthPx,
    required int resolutionHeightPx,
    required double pixelPitchUm,
    this.averageRawFileSizeMB = const Value.absent(),
  }) : deviceId = Value(deviceId),
       name = Value(name),
       sensorWidthMm = Value(sensorWidthMm),
       sensorHeightMm = Value(sensorHeightMm),
       resolutionWidthPx = Value(resolutionWidthPx),
       resolutionHeightPx = Value(resolutionHeightPx),
       pixelPitchUm = Value(pixelPitchUm);
  static Insertable<CameraModule> custom({
    Expression<int>? id,
    Expression<int>? deviceId,
    Expression<String>? name,
    Expression<String>? manufacturer,
    Expression<String>? model,
    Expression<double>? sensorWidthMm,
    Expression<double>? sensorHeightMm,
    Expression<int>? resolutionWidthPx,
    Expression<int>? resolutionHeightPx,
    Expression<double>? pixelPitchUm,
    Expression<double>? averageRawFileSizeMB,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      if (model != null) 'model': model,
      if (sensorWidthMm != null) 'sensor_width_mm': sensorWidthMm,
      if (sensorHeightMm != null) 'sensor_height_mm': sensorHeightMm,
      if (resolutionWidthPx != null) 'resolution_width_px': resolutionWidthPx,
      if (resolutionHeightPx != null)
        'resolution_height_px': resolutionHeightPx,
      if (pixelPitchUm != null) 'pixel_pitch_um': pixelPitchUm,
      if (averageRawFileSizeMB != null)
        'average_raw_file_size_m_b': averageRawFileSizeMB,
    });
  }

  CameraModulesCompanion copyWith({
    Value<int>? id,
    Value<int>? deviceId,
    Value<String>? name,
    Value<String?>? manufacturer,
    Value<String?>? model,
    Value<double>? sensorWidthMm,
    Value<double>? sensorHeightMm,
    Value<int>? resolutionWidthPx,
    Value<int>? resolutionHeightPx,
    Value<double>? pixelPitchUm,
    Value<double?>? averageRawFileSizeMB,
  }) {
    return CameraModulesCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      model: model ?? this.model,
      sensorWidthMm: sensorWidthMm ?? this.sensorWidthMm,
      sensorHeightMm: sensorHeightMm ?? this.sensorHeightMm,
      resolutionWidthPx: resolutionWidthPx ?? this.resolutionWidthPx,
      resolutionHeightPx: resolutionHeightPx ?? this.resolutionHeightPx,
      pixelPitchUm: pixelPitchUm ?? this.pixelPitchUm,
      averageRawFileSizeMB: averageRawFileSizeMB ?? this.averageRawFileSizeMB,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<int>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (manufacturer.present) {
      map['manufacturer'] = Variable<String>(manufacturer.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (sensorWidthMm.present) {
      map['sensor_width_mm'] = Variable<double>(sensorWidthMm.value);
    }
    if (sensorHeightMm.present) {
      map['sensor_height_mm'] = Variable<double>(sensorHeightMm.value);
    }
    if (resolutionWidthPx.present) {
      map['resolution_width_px'] = Variable<int>(resolutionWidthPx.value);
    }
    if (resolutionHeightPx.present) {
      map['resolution_height_px'] = Variable<int>(resolutionHeightPx.value);
    }
    if (pixelPitchUm.present) {
      map['pixel_pitch_um'] = Variable<double>(pixelPitchUm.value);
    }
    if (averageRawFileSizeMB.present) {
      map['average_raw_file_size_m_b'] = Variable<double>(
        averageRawFileSizeMB.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CameraModulesCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('manufacturer: $manufacturer, ')
          ..write('model: $model, ')
          ..write('sensorWidthMm: $sensorWidthMm, ')
          ..write('sensorHeightMm: $sensorHeightMm, ')
          ..write('resolutionWidthPx: $resolutionWidthPx, ')
          ..write('resolutionHeightPx: $resolutionHeightPx, ')
          ..write('pixelPitchUm: $pixelPitchUm, ')
          ..write('averageRawFileSizeMB: $averageRawFileSizeMB')
          ..write(')'))
        .toString();
  }
}

class $OpticalRigsTable extends OpticalRigs
    with TableInfo<$OpticalRigsTable, OpticalRig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpticalRigsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cameraModuleIdMeta = const VerificationMeta(
    'cameraModuleId',
  );
  @override
  late final GeneratedColumn<int> cameraModuleId = GeneratedColumn<int>(
    'camera_module_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES camera_modules (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _focalLengthMmMeta = const VerificationMeta(
    'focalLengthMm',
  );
  @override
  late final GeneratedColumn<double> focalLengthMm = GeneratedColumn<double>(
    'focal_length_mm',
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
  static const VerificationMeta _trackingStateMeta = const VerificationMeta(
    'trackingState',
  );
  @override
  late final GeneratedColumn<String> trackingState = GeneratedColumn<String>(
    'tracking_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _rotationDegreesMeta = const VerificationMeta(
    'rotationDegrees',
  );
  @override
  late final GeneratedColumn<double> rotationDegrees = GeneratedColumn<double>(
    'rotation_degrees',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    cameraModuleId,
    focalLengthMm,
    aperture,
    trackingState,
    rotationDegrees,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'optical_rigs';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpticalRig> instance, {
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
    if (data.containsKey('camera_module_id')) {
      context.handle(
        _cameraModuleIdMeta,
        cameraModuleId.isAcceptableOrUnknown(
          data['camera_module_id']!,
          _cameraModuleIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cameraModuleIdMeta);
    }
    if (data.containsKey('focal_length_mm')) {
      context.handle(
        _focalLengthMmMeta,
        focalLengthMm.isAcceptableOrUnknown(
          data['focal_length_mm']!,
          _focalLengthMmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_focalLengthMmMeta);
    }
    if (data.containsKey('aperture')) {
      context.handle(
        _apertureMeta,
        aperture.isAcceptableOrUnknown(data['aperture']!, _apertureMeta),
      );
    } else if (isInserting) {
      context.missing(_apertureMeta);
    }
    if (data.containsKey('tracking_state')) {
      context.handle(
        _trackingStateMeta,
        trackingState.isAcceptableOrUnknown(
          data['tracking_state']!,
          _trackingStateMeta,
        ),
      );
    }
    if (data.containsKey('rotation_degrees')) {
      context.handle(
        _rotationDegreesMeta,
        rotationDegrees.isAcceptableOrUnknown(
          data['rotation_degrees']!,
          _rotationDegreesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpticalRig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpticalRig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      cameraModuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}camera_module_id'],
      )!,
      focalLengthMm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focal_length_mm'],
      )!,
      aperture: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aperture'],
      )!,
      trackingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tracking_state'],
      )!,
      rotationDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rotation_degrees'],
      ),
    );
  }

  @override
  $OpticalRigsTable createAlias(String alias) {
    return $OpticalRigsTable(attachedDatabase, alias);
  }
}

class OpticalRig extends DataClass implements Insertable<OpticalRig> {
  final int id;
  final String name;
  final int cameraModuleId;
  final double focalLengthMm;
  final double aperture;
  final String trackingState;
  final double? rotationDegrees;
  const OpticalRig({
    required this.id,
    required this.name,
    required this.cameraModuleId,
    required this.focalLengthMm,
    required this.aperture,
    required this.trackingState,
    this.rotationDegrees,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['camera_module_id'] = Variable<int>(cameraModuleId);
    map['focal_length_mm'] = Variable<double>(focalLengthMm);
    map['aperture'] = Variable<double>(aperture);
    map['tracking_state'] = Variable<String>(trackingState);
    if (!nullToAbsent || rotationDegrees != null) {
      map['rotation_degrees'] = Variable<double>(rotationDegrees);
    }
    return map;
  }

  OpticalRigsCompanion toCompanion(bool nullToAbsent) {
    return OpticalRigsCompanion(
      id: Value(id),
      name: Value(name),
      cameraModuleId: Value(cameraModuleId),
      focalLengthMm: Value(focalLengthMm),
      aperture: Value(aperture),
      trackingState: Value(trackingState),
      rotationDegrees: rotationDegrees == null && nullToAbsent
          ? const Value.absent()
          : Value(rotationDegrees),
    );
  }

  factory OpticalRig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpticalRig(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      cameraModuleId: serializer.fromJson<int>(json['cameraModuleId']),
      focalLengthMm: serializer.fromJson<double>(json['focalLengthMm']),
      aperture: serializer.fromJson<double>(json['aperture']),
      trackingState: serializer.fromJson<String>(json['trackingState']),
      rotationDegrees: serializer.fromJson<double?>(json['rotationDegrees']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'cameraModuleId': serializer.toJson<int>(cameraModuleId),
      'focalLengthMm': serializer.toJson<double>(focalLengthMm),
      'aperture': serializer.toJson<double>(aperture),
      'trackingState': serializer.toJson<String>(trackingState),
      'rotationDegrees': serializer.toJson<double?>(rotationDegrees),
    };
  }

  OpticalRig copyWith({
    int? id,
    String? name,
    int? cameraModuleId,
    double? focalLengthMm,
    double? aperture,
    String? trackingState,
    Value<double?> rotationDegrees = const Value.absent(),
  }) => OpticalRig(
    id: id ?? this.id,
    name: name ?? this.name,
    cameraModuleId: cameraModuleId ?? this.cameraModuleId,
    focalLengthMm: focalLengthMm ?? this.focalLengthMm,
    aperture: aperture ?? this.aperture,
    trackingState: trackingState ?? this.trackingState,
    rotationDegrees: rotationDegrees.present
        ? rotationDegrees.value
        : this.rotationDegrees,
  );
  OpticalRig copyWithCompanion(OpticalRigsCompanion data) {
    return OpticalRig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      cameraModuleId: data.cameraModuleId.present
          ? data.cameraModuleId.value
          : this.cameraModuleId,
      focalLengthMm: data.focalLengthMm.present
          ? data.focalLengthMm.value
          : this.focalLengthMm,
      aperture: data.aperture.present ? data.aperture.value : this.aperture,
      trackingState: data.trackingState.present
          ? data.trackingState.value
          : this.trackingState,
      rotationDegrees: data.rotationDegrees.present
          ? data.rotationDegrees.value
          : this.rotationDegrees,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpticalRig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cameraModuleId: $cameraModuleId, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('aperture: $aperture, ')
          ..write('trackingState: $trackingState, ')
          ..write('rotationDegrees: $rotationDegrees')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    cameraModuleId,
    focalLengthMm,
    aperture,
    trackingState,
    rotationDegrees,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpticalRig &&
          other.id == this.id &&
          other.name == this.name &&
          other.cameraModuleId == this.cameraModuleId &&
          other.focalLengthMm == this.focalLengthMm &&
          other.aperture == this.aperture &&
          other.trackingState == this.trackingState &&
          other.rotationDegrees == this.rotationDegrees);
}

class OpticalRigsCompanion extends UpdateCompanion<OpticalRig> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> cameraModuleId;
  final Value<double> focalLengthMm;
  final Value<double> aperture;
  final Value<String> trackingState;
  final Value<double?> rotationDegrees;
  const OpticalRigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.cameraModuleId = const Value.absent(),
    this.focalLengthMm = const Value.absent(),
    this.aperture = const Value.absent(),
    this.trackingState = const Value.absent(),
    this.rotationDegrees = const Value.absent(),
  });
  OpticalRigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int cameraModuleId,
    required double focalLengthMm,
    required double aperture,
    this.trackingState = const Value.absent(),
    this.rotationDegrees = const Value.absent(),
  }) : name = Value(name),
       cameraModuleId = Value(cameraModuleId),
       focalLengthMm = Value(focalLengthMm),
       aperture = Value(aperture);
  static Insertable<OpticalRig> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? cameraModuleId,
    Expression<double>? focalLengthMm,
    Expression<double>? aperture,
    Expression<String>? trackingState,
    Expression<double>? rotationDegrees,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (cameraModuleId != null) 'camera_module_id': cameraModuleId,
      if (focalLengthMm != null) 'focal_length_mm': focalLengthMm,
      if (aperture != null) 'aperture': aperture,
      if (trackingState != null) 'tracking_state': trackingState,
      if (rotationDegrees != null) 'rotation_degrees': rotationDegrees,
    });
  }

  OpticalRigsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? cameraModuleId,
    Value<double>? focalLengthMm,
    Value<double>? aperture,
    Value<String>? trackingState,
    Value<double?>? rotationDegrees,
  }) {
    return OpticalRigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      cameraModuleId: cameraModuleId ?? this.cameraModuleId,
      focalLengthMm: focalLengthMm ?? this.focalLengthMm,
      aperture: aperture ?? this.aperture,
      trackingState: trackingState ?? this.trackingState,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
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
    if (cameraModuleId.present) {
      map['camera_module_id'] = Variable<int>(cameraModuleId.value);
    }
    if (focalLengthMm.present) {
      map['focal_length_mm'] = Variable<double>(focalLengthMm.value);
    }
    if (aperture.present) {
      map['aperture'] = Variable<double>(aperture.value);
    }
    if (trackingState.present) {
      map['tracking_state'] = Variable<String>(trackingState.value);
    }
    if (rotationDegrees.present) {
      map['rotation_degrees'] = Variable<double>(rotationDegrees.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpticalRigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('cameraModuleId: $cameraModuleId, ')
          ..write('focalLengthMm: $focalLengthMm, ')
          ..write('aperture: $aperture, ')
          ..write('trackingState: $trackingState, ')
          ..write('rotationDegrees: $rotationDegrees')
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
  static const VerificationMeta _bortleClassMeta = const VerificationMeta(
    'bortleClass',
  );
  @override
  late final GeneratedColumn<int> bortleClass = GeneratedColumn<int>(
    'bortle_class',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bortleSourceMeta = const VerificationMeta(
    'bortleSource',
  );
  @override
  late final GeneratedColumn<String> bortleSource = GeneratedColumn<String>(
    'bortle_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bortleDateMeta = const VerificationMeta(
    'bortleDate',
  );
  @override
  late final GeneratedColumn<String> bortleDate = GeneratedColumn<String>(
    'bortle_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sqmMeta = const VerificationMeta('sqm');
  @override
  late final GeneratedColumn<double> sqm = GeneratedColumn<double>(
    'sqm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sqmSourceMeta = const VerificationMeta(
    'sqmSource',
  );
  @override
  late final GeneratedColumn<String> sqmSource = GeneratedColumn<String>(
    'sqm_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sqmDateMeta = const VerificationMeta(
    'sqmDate',
  );
  @override
  late final GeneratedColumn<String> sqmDate = GeneratedColumn<String>(
    'sqm_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeZoneMeta = const VerificationMeta(
    'timeZone',
  );
  @override
  late final GeneratedColumn<String> timeZone = GeneratedColumn<String>(
    'time_zone',
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    latitude,
    longitude,
    elevation,
    bortleClass,
    bortleSource,
    bortleDate,
    sqm,
    sqmSource,
    sqmDate,
    timeZone,
    notes,
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
    if (data.containsKey('bortle_class')) {
      context.handle(
        _bortleClassMeta,
        bortleClass.isAcceptableOrUnknown(
          data['bortle_class']!,
          _bortleClassMeta,
        ),
      );
    }
    if (data.containsKey('bortle_source')) {
      context.handle(
        _bortleSourceMeta,
        bortleSource.isAcceptableOrUnknown(
          data['bortle_source']!,
          _bortleSourceMeta,
        ),
      );
    }
    if (data.containsKey('bortle_date')) {
      context.handle(
        _bortleDateMeta,
        bortleDate.isAcceptableOrUnknown(data['bortle_date']!, _bortleDateMeta),
      );
    }
    if (data.containsKey('sqm')) {
      context.handle(
        _sqmMeta,
        sqm.isAcceptableOrUnknown(data['sqm']!, _sqmMeta),
      );
    }
    if (data.containsKey('sqm_source')) {
      context.handle(
        _sqmSourceMeta,
        sqmSource.isAcceptableOrUnknown(data['sqm_source']!, _sqmSourceMeta),
      );
    }
    if (data.containsKey('sqm_date')) {
      context.handle(
        _sqmDateMeta,
        sqmDate.isAcceptableOrUnknown(data['sqm_date']!, _sqmDateMeta),
      );
    }
    if (data.containsKey('time_zone')) {
      context.handle(
        _timeZoneMeta,
        timeZone.isAcceptableOrUnknown(data['time_zone']!, _timeZoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
      bortleClass: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bortle_class'],
      ),
      bortleSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bortle_source'],
      ),
      bortleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bortle_date'],
      ),
      sqm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sqm'],
      ),
      sqmSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sqm_source'],
      ),
      sqmDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sqm_date'],
      ),
      timeZone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_zone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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

  /// Degrees, north positive.
  final double latitude;

  /// Degrees, east positive.
  final double longitude;

  /// Metres above mean sea level. Rows created before v12 by the old
  /// "current location" path hold 0, which may mean "not measured".
  final double elevation;

  /// Bortle class 1–9, or NULL when unknown (SI-007). Nullable since v12:
  /// the old default 4 was cleared by the v11→v12 migration (owner).
  final int? bortleClass;

  /// Provenance of [bortleClass] (ADR-008 §6): `user`, `legacy`, …
  final String? bortleSource;

  /// When [bortleClass] was determined, ISO `YYYY-MM-DD`.
  final String? bortleDate;

  /// Sky quality, mag/arcsec² (SQM), or NULL when unknown.
  final double? sqm;
  final String? sqmSource;
  final String? sqmDate;

  /// IANA time zone id (e.g. `Europe/London`), or NULL when unknown — the
  /// night then falls back to mean solar time (ADR-007 §6, L1).
  final String? timeZone;
  final String? notes;
  const LocationProfile({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.bortleClass,
    this.bortleSource,
    this.bortleDate,
    this.sqm,
    this.sqmSource,
    this.sqmDate,
    this.timeZone,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['elevation'] = Variable<double>(elevation);
    if (!nullToAbsent || bortleClass != null) {
      map['bortle_class'] = Variable<int>(bortleClass);
    }
    if (!nullToAbsent || bortleSource != null) {
      map['bortle_source'] = Variable<String>(bortleSource);
    }
    if (!nullToAbsent || bortleDate != null) {
      map['bortle_date'] = Variable<String>(bortleDate);
    }
    if (!nullToAbsent || sqm != null) {
      map['sqm'] = Variable<double>(sqm);
    }
    if (!nullToAbsent || sqmSource != null) {
      map['sqm_source'] = Variable<String>(sqmSource);
    }
    if (!nullToAbsent || sqmDate != null) {
      map['sqm_date'] = Variable<String>(sqmDate);
    }
    if (!nullToAbsent || timeZone != null) {
      map['time_zone'] = Variable<String>(timeZone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  LocationProfilesCompanion toCompanion(bool nullToAbsent) {
    return LocationProfilesCompanion(
      id: Value(id),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      elevation: Value(elevation),
      bortleClass: bortleClass == null && nullToAbsent
          ? const Value.absent()
          : Value(bortleClass),
      bortleSource: bortleSource == null && nullToAbsent
          ? const Value.absent()
          : Value(bortleSource),
      bortleDate: bortleDate == null && nullToAbsent
          ? const Value.absent()
          : Value(bortleDate),
      sqm: sqm == null && nullToAbsent ? const Value.absent() : Value(sqm),
      sqmSource: sqmSource == null && nullToAbsent
          ? const Value.absent()
          : Value(sqmSource),
      sqmDate: sqmDate == null && nullToAbsent
          ? const Value.absent()
          : Value(sqmDate),
      timeZone: timeZone == null && nullToAbsent
          ? const Value.absent()
          : Value(timeZone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
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
      bortleClass: serializer.fromJson<int?>(json['bortleClass']),
      bortleSource: serializer.fromJson<String?>(json['bortleSource']),
      bortleDate: serializer.fromJson<String?>(json['bortleDate']),
      sqm: serializer.fromJson<double?>(json['sqm']),
      sqmSource: serializer.fromJson<String?>(json['sqmSource']),
      sqmDate: serializer.fromJson<String?>(json['sqmDate']),
      timeZone: serializer.fromJson<String?>(json['timeZone']),
      notes: serializer.fromJson<String?>(json['notes']),
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
      'bortleClass': serializer.toJson<int?>(bortleClass),
      'bortleSource': serializer.toJson<String?>(bortleSource),
      'bortleDate': serializer.toJson<String?>(bortleDate),
      'sqm': serializer.toJson<double?>(sqm),
      'sqmSource': serializer.toJson<String?>(sqmSource),
      'sqmDate': serializer.toJson<String?>(sqmDate),
      'timeZone': serializer.toJson<String?>(timeZone),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  LocationProfile copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    double? elevation,
    Value<int?> bortleClass = const Value.absent(),
    Value<String?> bortleSource = const Value.absent(),
    Value<String?> bortleDate = const Value.absent(),
    Value<double?> sqm = const Value.absent(),
    Value<String?> sqmSource = const Value.absent(),
    Value<String?> sqmDate = const Value.absent(),
    Value<String?> timeZone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => LocationProfile(
    id: id ?? this.id,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    elevation: elevation ?? this.elevation,
    bortleClass: bortleClass.present ? bortleClass.value : this.bortleClass,
    bortleSource: bortleSource.present ? bortleSource.value : this.bortleSource,
    bortleDate: bortleDate.present ? bortleDate.value : this.bortleDate,
    sqm: sqm.present ? sqm.value : this.sqm,
    sqmSource: sqmSource.present ? sqmSource.value : this.sqmSource,
    sqmDate: sqmDate.present ? sqmDate.value : this.sqmDate,
    timeZone: timeZone.present ? timeZone.value : this.timeZone,
    notes: notes.present ? notes.value : this.notes,
  );
  LocationProfile copyWithCompanion(LocationProfilesCompanion data) {
    return LocationProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      elevation: data.elevation.present ? data.elevation.value : this.elevation,
      bortleClass: data.bortleClass.present
          ? data.bortleClass.value
          : this.bortleClass,
      bortleSource: data.bortleSource.present
          ? data.bortleSource.value
          : this.bortleSource,
      bortleDate: data.bortleDate.present
          ? data.bortleDate.value
          : this.bortleDate,
      sqm: data.sqm.present ? data.sqm.value : this.sqm,
      sqmSource: data.sqmSource.present ? data.sqmSource.value : this.sqmSource,
      sqmDate: data.sqmDate.present ? data.sqmDate.value : this.sqmDate,
      timeZone: data.timeZone.present ? data.timeZone.value : this.timeZone,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('elevation: $elevation, ')
          ..write('bortleClass: $bortleClass, ')
          ..write('bortleSource: $bortleSource, ')
          ..write('bortleDate: $bortleDate, ')
          ..write('sqm: $sqm, ')
          ..write('sqmSource: $sqmSource, ')
          ..write('sqmDate: $sqmDate, ')
          ..write('timeZone: $timeZone, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    latitude,
    longitude,
    elevation,
    bortleClass,
    bortleSource,
    bortleDate,
    sqm,
    sqmSource,
    sqmDate,
    timeZone,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.elevation == this.elevation &&
          other.bortleClass == this.bortleClass &&
          other.bortleSource == this.bortleSource &&
          other.bortleDate == this.bortleDate &&
          other.sqm == this.sqm &&
          other.sqmSource == this.sqmSource &&
          other.sqmDate == this.sqmDate &&
          other.timeZone == this.timeZone &&
          other.notes == this.notes);
}

class LocationProfilesCompanion extends UpdateCompanion<LocationProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> elevation;
  final Value<int?> bortleClass;
  final Value<String?> bortleSource;
  final Value<String?> bortleDate;
  final Value<double?> sqm;
  final Value<String?> sqmSource;
  final Value<String?> sqmDate;
  final Value<String?> timeZone;
  final Value<String?> notes;
  const LocationProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.elevation = const Value.absent(),
    this.bortleClass = const Value.absent(),
    this.bortleSource = const Value.absent(),
    this.bortleDate = const Value.absent(),
    this.sqm = const Value.absent(),
    this.sqmSource = const Value.absent(),
    this.sqmDate = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.notes = const Value.absent(),
  });
  LocationProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double latitude,
    required double longitude,
    required double elevation,
    this.bortleClass = const Value.absent(),
    this.bortleSource = const Value.absent(),
    this.bortleDate = const Value.absent(),
    this.sqm = const Value.absent(),
    this.sqmSource = const Value.absent(),
    this.sqmDate = const Value.absent(),
    this.timeZone = const Value.absent(),
    this.notes = const Value.absent(),
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
    Expression<int>? bortleClass,
    Expression<String>? bortleSource,
    Expression<String>? bortleDate,
    Expression<double>? sqm,
    Expression<String>? sqmSource,
    Expression<String>? sqmDate,
    Expression<String>? timeZone,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (elevation != null) 'elevation': elevation,
      if (bortleClass != null) 'bortle_class': bortleClass,
      if (bortleSource != null) 'bortle_source': bortleSource,
      if (bortleDate != null) 'bortle_date': bortleDate,
      if (sqm != null) 'sqm': sqm,
      if (sqmSource != null) 'sqm_source': sqmSource,
      if (sqmDate != null) 'sqm_date': sqmDate,
      if (timeZone != null) 'time_zone': timeZone,
      if (notes != null) 'notes': notes,
    });
  }

  LocationProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? elevation,
    Value<int?>? bortleClass,
    Value<String?>? bortleSource,
    Value<String?>? bortleDate,
    Value<double?>? sqm,
    Value<String?>? sqmSource,
    Value<String?>? sqmDate,
    Value<String?>? timeZone,
    Value<String?>? notes,
  }) {
    return LocationProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      bortleClass: bortleClass ?? this.bortleClass,
      bortleSource: bortleSource ?? this.bortleSource,
      bortleDate: bortleDate ?? this.bortleDate,
      sqm: sqm ?? this.sqm,
      sqmSource: sqmSource ?? this.sqmSource,
      sqmDate: sqmDate ?? this.sqmDate,
      timeZone: timeZone ?? this.timeZone,
      notes: notes ?? this.notes,
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
    if (bortleClass.present) {
      map['bortle_class'] = Variable<int>(bortleClass.value);
    }
    if (bortleSource.present) {
      map['bortle_source'] = Variable<String>(bortleSource.value);
    }
    if (bortleDate.present) {
      map['bortle_date'] = Variable<String>(bortleDate.value);
    }
    if (sqm.present) {
      map['sqm'] = Variable<double>(sqm.value);
    }
    if (sqmSource.present) {
      map['sqm_source'] = Variable<String>(sqmSource.value);
    }
    if (sqmDate.present) {
      map['sqm_date'] = Variable<String>(sqmDate.value);
    }
    if (timeZone.present) {
      map['time_zone'] = Variable<String>(timeZone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
          ..write('elevation: $elevation, ')
          ..write('bortleClass: $bortleClass, ')
          ..write('bortleSource: $bortleSource, ')
          ..write('bortleDate: $bortleDate, ')
          ..write('sqm: $sqm, ')
          ..write('sqmSource: $sqmSource, ')
          ..write('sqmDate: $sqmDate, ')
          ..write('timeZone: $timeZone, ')
          ..write('notes: $notes')
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
  static const VerificationMeta _epochMeta = const VerificationMeta('epoch');
  @override
  late final GeneratedColumn<String> epoch = GeneratedColumn<String>(
    'epoch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('J2000'),
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
  static const VerificationMeta _angularSizeArcminMeta = const VerificationMeta(
    'angularSizeArcmin',
  );
  @override
  late final GeneratedColumn<double> angularSizeArcmin =
      GeneratedColumn<double>(
        'angular_size_arcmin',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _magnitudeMeta = const VerificationMeta(
    'magnitude',
  );
  @override
  late final GeneratedColumn<double> magnitude = GeneratedColumn<double>(
    'magnitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    catalogId,
    commonName,
    rightAscension,
    declination,
    type,
    epoch,
    source,
    angularSizeArcmin,
    magnitude,
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
    if (data.containsKey('epoch')) {
      context.handle(
        _epochMeta,
        epoch.isAcceptableOrUnknown(data['epoch']!, _epochMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('angular_size_arcmin')) {
      context.handle(
        _angularSizeArcminMeta,
        angularSizeArcmin.isAcceptableOrUnknown(
          data['angular_size_arcmin']!,
          _angularSizeArcminMeta,
        ),
      );
    }
    if (data.containsKey('magnitude')) {
      context.handle(
        _magnitudeMeta,
        magnitude.isAcceptableOrUnknown(data['magnitude']!, _magnitudeMeta),
      );
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
      epoch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}epoch'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      angularSizeArcmin: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}angular_size_arcmin'],
      ),
      magnitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnitude'],
      ),
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

  /// Degrees, [0, 360).
  final double rightAscension;

  /// Degrees, [-90, 90].
  final double declination;
  final String type;

  /// Coordinate epoch (TASK 8.1, schema v13). Only `J2000` is supported.
  final String epoch;

  /// Provenance (ADR-008 §6); NULL = unknown (legacy rows).
  final String? source;

  /// Apparent size, arcminutes; NULL = unknown.
  final double? angularSizeArcmin;

  /// Apparent magnitude; NULL = unknown.
  final double? magnitude;
  const AstroTarget({
    required this.id,
    required this.catalogId,
    this.commonName,
    required this.rightAscension,
    required this.declination,
    required this.type,
    required this.epoch,
    this.source,
    this.angularSizeArcmin,
    this.magnitude,
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
    map['epoch'] = Variable<String>(epoch);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || angularSizeArcmin != null) {
      map['angular_size_arcmin'] = Variable<double>(angularSizeArcmin);
    }
    if (!nullToAbsent || magnitude != null) {
      map['magnitude'] = Variable<double>(magnitude);
    }
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
      epoch: Value(epoch),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      angularSizeArcmin: angularSizeArcmin == null && nullToAbsent
          ? const Value.absent()
          : Value(angularSizeArcmin),
      magnitude: magnitude == null && nullToAbsent
          ? const Value.absent()
          : Value(magnitude),
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
      epoch: serializer.fromJson<String>(json['epoch']),
      source: serializer.fromJson<String?>(json['source']),
      angularSizeArcmin: serializer.fromJson<double?>(
        json['angularSizeArcmin'],
      ),
      magnitude: serializer.fromJson<double?>(json['magnitude']),
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
      'epoch': serializer.toJson<String>(epoch),
      'source': serializer.toJson<String?>(source),
      'angularSizeArcmin': serializer.toJson<double?>(angularSizeArcmin),
      'magnitude': serializer.toJson<double?>(magnitude),
    };
  }

  AstroTarget copyWith({
    int? id,
    String? catalogId,
    Value<String?> commonName = const Value.absent(),
    double? rightAscension,
    double? declination,
    String? type,
    String? epoch,
    Value<String?> source = const Value.absent(),
    Value<double?> angularSizeArcmin = const Value.absent(),
    Value<double?> magnitude = const Value.absent(),
  }) => AstroTarget(
    id: id ?? this.id,
    catalogId: catalogId ?? this.catalogId,
    commonName: commonName.present ? commonName.value : this.commonName,
    rightAscension: rightAscension ?? this.rightAscension,
    declination: declination ?? this.declination,
    type: type ?? this.type,
    epoch: epoch ?? this.epoch,
    source: source.present ? source.value : this.source,
    angularSizeArcmin: angularSizeArcmin.present
        ? angularSizeArcmin.value
        : this.angularSizeArcmin,
    magnitude: magnitude.present ? magnitude.value : this.magnitude,
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
      epoch: data.epoch.present ? data.epoch.value : this.epoch,
      source: data.source.present ? data.source.value : this.source,
      angularSizeArcmin: data.angularSizeArcmin.present
          ? data.angularSizeArcmin.value
          : this.angularSizeArcmin,
      magnitude: data.magnitude.present ? data.magnitude.value : this.magnitude,
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
          ..write('type: $type, ')
          ..write('epoch: $epoch, ')
          ..write('source: $source, ')
          ..write('angularSizeArcmin: $angularSizeArcmin, ')
          ..write('magnitude: $magnitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    catalogId,
    commonName,
    rightAscension,
    declination,
    type,
    epoch,
    source,
    angularSizeArcmin,
    magnitude,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AstroTarget &&
          other.id == this.id &&
          other.catalogId == this.catalogId &&
          other.commonName == this.commonName &&
          other.rightAscension == this.rightAscension &&
          other.declination == this.declination &&
          other.type == this.type &&
          other.epoch == this.epoch &&
          other.source == this.source &&
          other.angularSizeArcmin == this.angularSizeArcmin &&
          other.magnitude == this.magnitude);
}

class AstroTargetsCompanion extends UpdateCompanion<AstroTarget> {
  final Value<int> id;
  final Value<String> catalogId;
  final Value<String?> commonName;
  final Value<double> rightAscension;
  final Value<double> declination;
  final Value<String> type;
  final Value<String> epoch;
  final Value<String?> source;
  final Value<double?> angularSizeArcmin;
  final Value<double?> magnitude;
  const AstroTargetsCompanion({
    this.id = const Value.absent(),
    this.catalogId = const Value.absent(),
    this.commonName = const Value.absent(),
    this.rightAscension = const Value.absent(),
    this.declination = const Value.absent(),
    this.type = const Value.absent(),
    this.epoch = const Value.absent(),
    this.source = const Value.absent(),
    this.angularSizeArcmin = const Value.absent(),
    this.magnitude = const Value.absent(),
  });
  AstroTargetsCompanion.insert({
    this.id = const Value.absent(),
    required String catalogId,
    this.commonName = const Value.absent(),
    required double rightAscension,
    required double declination,
    required String type,
    this.epoch = const Value.absent(),
    this.source = const Value.absent(),
    this.angularSizeArcmin = const Value.absent(),
    this.magnitude = const Value.absent(),
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
    Expression<String>? epoch,
    Expression<String>? source,
    Expression<double>? angularSizeArcmin,
    Expression<double>? magnitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (catalogId != null) 'catalog_id': catalogId,
      if (commonName != null) 'common_name': commonName,
      if (rightAscension != null) 'right_ascension': rightAscension,
      if (declination != null) 'declination': declination,
      if (type != null) 'type': type,
      if (epoch != null) 'epoch': epoch,
      if (source != null) 'source': source,
      if (angularSizeArcmin != null) 'angular_size_arcmin': angularSizeArcmin,
      if (magnitude != null) 'magnitude': magnitude,
    });
  }

  AstroTargetsCompanion copyWith({
    Value<int>? id,
    Value<String>? catalogId,
    Value<String?>? commonName,
    Value<double>? rightAscension,
    Value<double>? declination,
    Value<String>? type,
    Value<String>? epoch,
    Value<String?>? source,
    Value<double?>? angularSizeArcmin,
    Value<double?>? magnitude,
  }) {
    return AstroTargetsCompanion(
      id: id ?? this.id,
      catalogId: catalogId ?? this.catalogId,
      commonName: commonName ?? this.commonName,
      rightAscension: rightAscension ?? this.rightAscension,
      declination: declination ?? this.declination,
      type: type ?? this.type,
      epoch: epoch ?? this.epoch,
      source: source ?? this.source,
      angularSizeArcmin: angularSizeArcmin ?? this.angularSizeArcmin,
      magnitude: magnitude ?? this.magnitude,
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
    if (epoch.present) {
      map['epoch'] = Variable<String>(epoch.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (angularSizeArcmin.present) {
      map['angular_size_arcmin'] = Variable<double>(angularSizeArcmin.value);
    }
    if (magnitude.present) {
      map['magnitude'] = Variable<double>(magnitude.value);
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
          ..write('type: $type, ')
          ..write('epoch: $epoch, ')
          ..write('source: $source, ')
          ..write('angularSizeArcmin: $angularSizeArcmin, ')
          ..write('magnitude: $magnitude')
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
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bortleScaleMeta = const VerificationMeta(
    'bortleScale',
  );
  @override
  late final GeneratedColumn<double> bortleScale = GeneratedColumn<double>(
    'bortle_scale',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
  static const VerificationMeta _plannedDarkFramesMeta = const VerificationMeta(
    'plannedDarkFrames',
  );
  @override
  late final GeneratedColumn<int> plannedDarkFrames = GeneratedColumn<int>(
    'planned_dark_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedFlatFramesMeta = const VerificationMeta(
    'plannedFlatFrames',
  );
  @override
  late final GeneratedColumn<int> plannedFlatFrames = GeneratedColumn<int>(
    'planned_flat_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedBiasFramesMeta = const VerificationMeta(
    'plannedBiasFrames',
  );
  @override
  late final GeneratedColumn<int> plannedBiasFrames = GeneratedColumn<int>(
    'planned_bias_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _integrationTimeSecondsMeta =
      const VerificationMeta('integrationTimeSeconds');
  @override
  late final GeneratedColumn<double> integrationTimeSeconds =
      GeneratedColumn<double>(
        'integration_time_seconds',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _focalLengthMeta = const VerificationMeta(
    'focalLength',
  );
  @override
  late final GeneratedColumn<double> focalLength = GeneratedColumn<double>(
    'focal_length',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apertureMeta = const VerificationMeta(
    'aperture',
  );
  @override
  late final GeneratedColumn<double> aperture = GeneratedColumn<double>(
    'aperture',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _humidityMeta = const VerificationMeta(
    'humidity',
  );
  @override
  late final GeneratedColumn<double> humidity = GeneratedColumn<double>(
    'humidity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cloudCoverMeta = const VerificationMeta(
    'cloudCover',
  );
  @override
  late final GeneratedColumn<int> cloudCover = GeneratedColumn<int>(
    'cloud_cover',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    locationName,
    bortleScale,
    plannedLightFrames,
    plannedDarkFrames,
    plannedFlatFrames,
    plannedBiasFrames,
    integrationTimeSeconds,
    focalLength,
    aperture,
    temperature,
    humidity,
    cloudCover,
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
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('bortle_scale')) {
      context.handle(
        _bortleScaleMeta,
        bortleScale.isAcceptableOrUnknown(
          data['bortle_scale']!,
          _bortleScaleMeta,
        ),
      );
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
    if (data.containsKey('planned_dark_frames')) {
      context.handle(
        _plannedDarkFramesMeta,
        plannedDarkFrames.isAcceptableOrUnknown(
          data['planned_dark_frames']!,
          _plannedDarkFramesMeta,
        ),
      );
    }
    if (data.containsKey('planned_flat_frames')) {
      context.handle(
        _plannedFlatFramesMeta,
        plannedFlatFrames.isAcceptableOrUnknown(
          data['planned_flat_frames']!,
          _plannedFlatFramesMeta,
        ),
      );
    }
    if (data.containsKey('planned_bias_frames')) {
      context.handle(
        _plannedBiasFramesMeta,
        plannedBiasFrames.isAcceptableOrUnknown(
          data['planned_bias_frames']!,
          _plannedBiasFramesMeta,
        ),
      );
    }
    if (data.containsKey('integration_time_seconds')) {
      context.handle(
        _integrationTimeSecondsMeta,
        integrationTimeSeconds.isAcceptableOrUnknown(
          data['integration_time_seconds']!,
          _integrationTimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('focal_length')) {
      context.handle(
        _focalLengthMeta,
        focalLength.isAcceptableOrUnknown(
          data['focal_length']!,
          _focalLengthMeta,
        ),
      );
    }
    if (data.containsKey('aperture')) {
      context.handle(
        _apertureMeta,
        aperture.isAcceptableOrUnknown(data['aperture']!, _apertureMeta),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('humidity')) {
      context.handle(
        _humidityMeta,
        humidity.isAcceptableOrUnknown(data['humidity']!, _humidityMeta),
      );
    }
    if (data.containsKey('cloud_cover')) {
      context.handle(
        _cloudCoverMeta,
        cloudCover.isAcceptableOrUnknown(data['cloud_cover']!, _cloudCoverMeta),
      );
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
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      bortleScale: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bortle_scale'],
      ),
      plannedLightFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_light_frames'],
      )!,
      plannedDarkFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_dark_frames'],
      ),
      plannedFlatFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_flat_frames'],
      ),
      plannedBiasFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_bias_frames'],
      ),
      integrationTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}integration_time_seconds'],
      ),
      focalLength: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}focal_length'],
      ),
      aperture: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aperture'],
      ),
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      ),
      humidity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}humidity'],
      ),
      cloudCover: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cloud_cover'],
      ),
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
  final String? locationName;
  final double? bortleScale;
  final int plannedLightFrames;
  final int? plannedDarkFrames;
  final int? plannedFlatFrames;
  final int? plannedBiasFrames;
  final double? integrationTimeSeconds;
  final double? focalLength;
  final double? aperture;
  final double? temperature;
  final double? humidity;
  final int? cloudCover;
  final int? actualLightFrames;
  final int? rejectedFrames;
  final String? environmentalNotes;
  final String? processingNotes;
  const SessionLog({
    required this.id,
    required this.targetName,
    required this.equipmentName,
    required this.sessionDate,
    this.locationName,
    this.bortleScale,
    required this.plannedLightFrames,
    this.plannedDarkFrames,
    this.plannedFlatFrames,
    this.plannedBiasFrames,
    this.integrationTimeSeconds,
    this.focalLength,
    this.aperture,
    this.temperature,
    this.humidity,
    this.cloudCover,
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
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || bortleScale != null) {
      map['bortle_scale'] = Variable<double>(bortleScale);
    }
    map['planned_light_frames'] = Variable<int>(plannedLightFrames);
    if (!nullToAbsent || plannedDarkFrames != null) {
      map['planned_dark_frames'] = Variable<int>(plannedDarkFrames);
    }
    if (!nullToAbsent || plannedFlatFrames != null) {
      map['planned_flat_frames'] = Variable<int>(plannedFlatFrames);
    }
    if (!nullToAbsent || plannedBiasFrames != null) {
      map['planned_bias_frames'] = Variable<int>(plannedBiasFrames);
    }
    if (!nullToAbsent || integrationTimeSeconds != null) {
      map['integration_time_seconds'] = Variable<double>(
        integrationTimeSeconds,
      );
    }
    if (!nullToAbsent || focalLength != null) {
      map['focal_length'] = Variable<double>(focalLength);
    }
    if (!nullToAbsent || aperture != null) {
      map['aperture'] = Variable<double>(aperture);
    }
    if (!nullToAbsent || temperature != null) {
      map['temperature'] = Variable<double>(temperature);
    }
    if (!nullToAbsent || humidity != null) {
      map['humidity'] = Variable<double>(humidity);
    }
    if (!nullToAbsent || cloudCover != null) {
      map['cloud_cover'] = Variable<int>(cloudCover);
    }
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
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      bortleScale: bortleScale == null && nullToAbsent
          ? const Value.absent()
          : Value(bortleScale),
      plannedLightFrames: Value(plannedLightFrames),
      plannedDarkFrames: plannedDarkFrames == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedDarkFrames),
      plannedFlatFrames: plannedFlatFrames == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedFlatFrames),
      plannedBiasFrames: plannedBiasFrames == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedBiasFrames),
      integrationTimeSeconds: integrationTimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(integrationTimeSeconds),
      focalLength: focalLength == null && nullToAbsent
          ? const Value.absent()
          : Value(focalLength),
      aperture: aperture == null && nullToAbsent
          ? const Value.absent()
          : Value(aperture),
      temperature: temperature == null && nullToAbsent
          ? const Value.absent()
          : Value(temperature),
      humidity: humidity == null && nullToAbsent
          ? const Value.absent()
          : Value(humidity),
      cloudCover: cloudCover == null && nullToAbsent
          ? const Value.absent()
          : Value(cloudCover),
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
      locationName: serializer.fromJson<String?>(json['locationName']),
      bortleScale: serializer.fromJson<double?>(json['bortleScale']),
      plannedLightFrames: serializer.fromJson<int>(json['plannedLightFrames']),
      plannedDarkFrames: serializer.fromJson<int?>(json['plannedDarkFrames']),
      plannedFlatFrames: serializer.fromJson<int?>(json['plannedFlatFrames']),
      plannedBiasFrames: serializer.fromJson<int?>(json['plannedBiasFrames']),
      integrationTimeSeconds: serializer.fromJson<double?>(
        json['integrationTimeSeconds'],
      ),
      focalLength: serializer.fromJson<double?>(json['focalLength']),
      aperture: serializer.fromJson<double?>(json['aperture']),
      temperature: serializer.fromJson<double?>(json['temperature']),
      humidity: serializer.fromJson<double?>(json['humidity']),
      cloudCover: serializer.fromJson<int?>(json['cloudCover']),
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
      'locationName': serializer.toJson<String?>(locationName),
      'bortleScale': serializer.toJson<double?>(bortleScale),
      'plannedLightFrames': serializer.toJson<int>(plannedLightFrames),
      'plannedDarkFrames': serializer.toJson<int?>(plannedDarkFrames),
      'plannedFlatFrames': serializer.toJson<int?>(plannedFlatFrames),
      'plannedBiasFrames': serializer.toJson<int?>(plannedBiasFrames),
      'integrationTimeSeconds': serializer.toJson<double?>(
        integrationTimeSeconds,
      ),
      'focalLength': serializer.toJson<double?>(focalLength),
      'aperture': serializer.toJson<double?>(aperture),
      'temperature': serializer.toJson<double?>(temperature),
      'humidity': serializer.toJson<double?>(humidity),
      'cloudCover': serializer.toJson<int?>(cloudCover),
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
    Value<String?> locationName = const Value.absent(),
    Value<double?> bortleScale = const Value.absent(),
    int? plannedLightFrames,
    Value<int?> plannedDarkFrames = const Value.absent(),
    Value<int?> plannedFlatFrames = const Value.absent(),
    Value<int?> plannedBiasFrames = const Value.absent(),
    Value<double?> integrationTimeSeconds = const Value.absent(),
    Value<double?> focalLength = const Value.absent(),
    Value<double?> aperture = const Value.absent(),
    Value<double?> temperature = const Value.absent(),
    Value<double?> humidity = const Value.absent(),
    Value<int?> cloudCover = const Value.absent(),
    Value<int?> actualLightFrames = const Value.absent(),
    Value<int?> rejectedFrames = const Value.absent(),
    Value<String?> environmentalNotes = const Value.absent(),
    Value<String?> processingNotes = const Value.absent(),
  }) => SessionLog(
    id: id ?? this.id,
    targetName: targetName ?? this.targetName,
    equipmentName: equipmentName ?? this.equipmentName,
    sessionDate: sessionDate ?? this.sessionDate,
    locationName: locationName.present ? locationName.value : this.locationName,
    bortleScale: bortleScale.present ? bortleScale.value : this.bortleScale,
    plannedLightFrames: plannedLightFrames ?? this.plannedLightFrames,
    plannedDarkFrames: plannedDarkFrames.present
        ? plannedDarkFrames.value
        : this.plannedDarkFrames,
    plannedFlatFrames: plannedFlatFrames.present
        ? plannedFlatFrames.value
        : this.plannedFlatFrames,
    plannedBiasFrames: plannedBiasFrames.present
        ? plannedBiasFrames.value
        : this.plannedBiasFrames,
    integrationTimeSeconds: integrationTimeSeconds.present
        ? integrationTimeSeconds.value
        : this.integrationTimeSeconds,
    focalLength: focalLength.present ? focalLength.value : this.focalLength,
    aperture: aperture.present ? aperture.value : this.aperture,
    temperature: temperature.present ? temperature.value : this.temperature,
    humidity: humidity.present ? humidity.value : this.humidity,
    cloudCover: cloudCover.present ? cloudCover.value : this.cloudCover,
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
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      bortleScale: data.bortleScale.present
          ? data.bortleScale.value
          : this.bortleScale,
      plannedLightFrames: data.plannedLightFrames.present
          ? data.plannedLightFrames.value
          : this.plannedLightFrames,
      plannedDarkFrames: data.plannedDarkFrames.present
          ? data.plannedDarkFrames.value
          : this.plannedDarkFrames,
      plannedFlatFrames: data.plannedFlatFrames.present
          ? data.plannedFlatFrames.value
          : this.plannedFlatFrames,
      plannedBiasFrames: data.plannedBiasFrames.present
          ? data.plannedBiasFrames.value
          : this.plannedBiasFrames,
      integrationTimeSeconds: data.integrationTimeSeconds.present
          ? data.integrationTimeSeconds.value
          : this.integrationTimeSeconds,
      focalLength: data.focalLength.present
          ? data.focalLength.value
          : this.focalLength,
      aperture: data.aperture.present ? data.aperture.value : this.aperture,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      humidity: data.humidity.present ? data.humidity.value : this.humidity,
      cloudCover: data.cloudCover.present
          ? data.cloudCover.value
          : this.cloudCover,
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
          ..write('locationName: $locationName, ')
          ..write('bortleScale: $bortleScale, ')
          ..write('plannedLightFrames: $plannedLightFrames, ')
          ..write('plannedDarkFrames: $plannedDarkFrames, ')
          ..write('plannedFlatFrames: $plannedFlatFrames, ')
          ..write('plannedBiasFrames: $plannedBiasFrames, ')
          ..write('integrationTimeSeconds: $integrationTimeSeconds, ')
          ..write('focalLength: $focalLength, ')
          ..write('aperture: $aperture, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('cloudCover: $cloudCover, ')
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
    locationName,
    bortleScale,
    plannedLightFrames,
    plannedDarkFrames,
    plannedFlatFrames,
    plannedBiasFrames,
    integrationTimeSeconds,
    focalLength,
    aperture,
    temperature,
    humidity,
    cloudCover,
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
          other.locationName == this.locationName &&
          other.bortleScale == this.bortleScale &&
          other.plannedLightFrames == this.plannedLightFrames &&
          other.plannedDarkFrames == this.plannedDarkFrames &&
          other.plannedFlatFrames == this.plannedFlatFrames &&
          other.plannedBiasFrames == this.plannedBiasFrames &&
          other.integrationTimeSeconds == this.integrationTimeSeconds &&
          other.focalLength == this.focalLength &&
          other.aperture == this.aperture &&
          other.temperature == this.temperature &&
          other.humidity == this.humidity &&
          other.cloudCover == this.cloudCover &&
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
  final Value<String?> locationName;
  final Value<double?> bortleScale;
  final Value<int> plannedLightFrames;
  final Value<int?> plannedDarkFrames;
  final Value<int?> plannedFlatFrames;
  final Value<int?> plannedBiasFrames;
  final Value<double?> integrationTimeSeconds;
  final Value<double?> focalLength;
  final Value<double?> aperture;
  final Value<double?> temperature;
  final Value<double?> humidity;
  final Value<int?> cloudCover;
  final Value<int?> actualLightFrames;
  final Value<int?> rejectedFrames;
  final Value<String?> environmentalNotes;
  final Value<String?> processingNotes;
  const SessionLogsCompanion({
    this.id = const Value.absent(),
    this.targetName = const Value.absent(),
    this.equipmentName = const Value.absent(),
    this.sessionDate = const Value.absent(),
    this.locationName = const Value.absent(),
    this.bortleScale = const Value.absent(),
    this.plannedLightFrames = const Value.absent(),
    this.plannedDarkFrames = const Value.absent(),
    this.plannedFlatFrames = const Value.absent(),
    this.plannedBiasFrames = const Value.absent(),
    this.integrationTimeSeconds = const Value.absent(),
    this.focalLength = const Value.absent(),
    this.aperture = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.cloudCover = const Value.absent(),
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
    this.locationName = const Value.absent(),
    this.bortleScale = const Value.absent(),
    required int plannedLightFrames,
    this.plannedDarkFrames = const Value.absent(),
    this.plannedFlatFrames = const Value.absent(),
    this.plannedBiasFrames = const Value.absent(),
    this.integrationTimeSeconds = const Value.absent(),
    this.focalLength = const Value.absent(),
    this.aperture = const Value.absent(),
    this.temperature = const Value.absent(),
    this.humidity = const Value.absent(),
    this.cloudCover = const Value.absent(),
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
    Expression<String>? locationName,
    Expression<double>? bortleScale,
    Expression<int>? plannedLightFrames,
    Expression<int>? plannedDarkFrames,
    Expression<int>? plannedFlatFrames,
    Expression<int>? plannedBiasFrames,
    Expression<double>? integrationTimeSeconds,
    Expression<double>? focalLength,
    Expression<double>? aperture,
    Expression<double>? temperature,
    Expression<double>? humidity,
    Expression<int>? cloudCover,
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
      if (locationName != null) 'location_name': locationName,
      if (bortleScale != null) 'bortle_scale': bortleScale,
      if (plannedLightFrames != null)
        'planned_light_frames': plannedLightFrames,
      if (plannedDarkFrames != null) 'planned_dark_frames': plannedDarkFrames,
      if (plannedFlatFrames != null) 'planned_flat_frames': plannedFlatFrames,
      if (plannedBiasFrames != null) 'planned_bias_frames': plannedBiasFrames,
      if (integrationTimeSeconds != null)
        'integration_time_seconds': integrationTimeSeconds,
      if (focalLength != null) 'focal_length': focalLength,
      if (aperture != null) 'aperture': aperture,
      if (temperature != null) 'temperature': temperature,
      if (humidity != null) 'humidity': humidity,
      if (cloudCover != null) 'cloud_cover': cloudCover,
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
    Value<String?>? locationName,
    Value<double?>? bortleScale,
    Value<int>? plannedLightFrames,
    Value<int?>? plannedDarkFrames,
    Value<int?>? plannedFlatFrames,
    Value<int?>? plannedBiasFrames,
    Value<double?>? integrationTimeSeconds,
    Value<double?>? focalLength,
    Value<double?>? aperture,
    Value<double?>? temperature,
    Value<double?>? humidity,
    Value<int?>? cloudCover,
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
      locationName: locationName ?? this.locationName,
      bortleScale: bortleScale ?? this.bortleScale,
      plannedLightFrames: plannedLightFrames ?? this.plannedLightFrames,
      plannedDarkFrames: plannedDarkFrames ?? this.plannedDarkFrames,
      plannedFlatFrames: plannedFlatFrames ?? this.plannedFlatFrames,
      plannedBiasFrames: plannedBiasFrames ?? this.plannedBiasFrames,
      integrationTimeSeconds:
          integrationTimeSeconds ?? this.integrationTimeSeconds,
      focalLength: focalLength ?? this.focalLength,
      aperture: aperture ?? this.aperture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      cloudCover: cloudCover ?? this.cloudCover,
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
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (bortleScale.present) {
      map['bortle_scale'] = Variable<double>(bortleScale.value);
    }
    if (plannedLightFrames.present) {
      map['planned_light_frames'] = Variable<int>(plannedLightFrames.value);
    }
    if (plannedDarkFrames.present) {
      map['planned_dark_frames'] = Variable<int>(plannedDarkFrames.value);
    }
    if (plannedFlatFrames.present) {
      map['planned_flat_frames'] = Variable<int>(plannedFlatFrames.value);
    }
    if (plannedBiasFrames.present) {
      map['planned_bias_frames'] = Variable<int>(plannedBiasFrames.value);
    }
    if (integrationTimeSeconds.present) {
      map['integration_time_seconds'] = Variable<double>(
        integrationTimeSeconds.value,
      );
    }
    if (focalLength.present) {
      map['focal_length'] = Variable<double>(focalLength.value);
    }
    if (aperture.present) {
      map['aperture'] = Variable<double>(aperture.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (humidity.present) {
      map['humidity'] = Variable<double>(humidity.value);
    }
    if (cloudCover.present) {
      map['cloud_cover'] = Variable<int>(cloudCover.value);
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
          ..write('locationName: $locationName, ')
          ..write('bortleScale: $bortleScale, ')
          ..write('plannedLightFrames: $plannedLightFrames, ')
          ..write('plannedDarkFrames: $plannedDarkFrames, ')
          ..write('plannedFlatFrames: $plannedFlatFrames, ')
          ..write('plannedBiasFrames: $plannedBiasFrames, ')
          ..write('integrationTimeSeconds: $integrationTimeSeconds, ')
          ..write('focalLength: $focalLength, ')
          ..write('aperture: $aperture, ')
          ..write('temperature: $temperature, ')
          ..write('humidity: $humidity, ')
          ..write('cloudCover: $cloudCover, ')
          ..write('actualLightFrames: $actualLightFrames, ')
          ..write('rejectedFrames: $rejectedFrames, ')
          ..write('environmentalNotes: $environmentalNotes, ')
          ..write('processingNotes: $processingNotes')
          ..write(')'))
        .toString();
  }
}

class $CaptureBlocksTable extends CaptureBlocks
    with TableInfo<$CaptureBlocksTable, CaptureBlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureBlocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sessionLogIdMeta = const VerificationMeta(
    'sessionLogId',
  );
  @override
  late final GeneratedColumn<int> sessionLogId = GeneratedColumn<int>(
    'session_log_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES session_logs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _frameTypeMeta = const VerificationMeta(
    'frameType',
  );
  @override
  late final GeneratedColumn<String> frameType = GeneratedColumn<String>(
    'frame_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filterNameMeta = const VerificationMeta(
    'filterName',
  );
  @override
  late final GeneratedColumn<String> filterName = GeneratedColumn<String>(
    'filter_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exposureTimeSecondsMeta =
      const VerificationMeta('exposureTimeSeconds');
  @override
  late final GeneratedColumn<double> exposureTimeSeconds =
      GeneratedColumn<double>(
        'exposure_time_seconds',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _frameCountMeta = const VerificationMeta(
    'frameCount',
  );
  @override
  late final GeneratedColumn<int> frameCount = GeneratedColumn<int>(
    'frame_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _binningMeta = const VerificationMeta(
    'binning',
  );
  @override
  late final GeneratedColumn<int> binning = GeneratedColumn<int>(
    'binning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _calibrationPolicyMeta = const VerificationMeta(
    'calibrationPolicy',
  );
  @override
  late final GeneratedColumn<String> calibrationPolicy =
      GeneratedColumn<String>(
        'calibration_policy',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gainKindMeta = const VerificationMeta(
    'gainKind',
  );
  @override
  late final GeneratedColumn<String> gainKind = GeneratedColumn<String>(
    'gain_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  static const VerificationMeta _gainValueMeta = const VerificationMeta(
    'gainValue',
  );
  @override
  late final GeneratedColumn<double> gainValue = GeneratedColumn<double>(
    'gain_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionLogId,
    frameType,
    filterName,
    exposureTimeSeconds,
    frameCount,
    binning,
    position,
    calibrationPolicy,
    gainKind,
    gainValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_blocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CaptureBlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_log_id')) {
      context.handle(
        _sessionLogIdMeta,
        sessionLogId.isAcceptableOrUnknown(
          data['session_log_id']!,
          _sessionLogIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionLogIdMeta);
    }
    if (data.containsKey('frame_type')) {
      context.handle(
        _frameTypeMeta,
        frameType.isAcceptableOrUnknown(data['frame_type']!, _frameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_frameTypeMeta);
    }
    if (data.containsKey('filter_name')) {
      context.handle(
        _filterNameMeta,
        filterName.isAcceptableOrUnknown(data['filter_name']!, _filterNameMeta),
      );
    }
    if (data.containsKey('exposure_time_seconds')) {
      context.handle(
        _exposureTimeSecondsMeta,
        exposureTimeSeconds.isAcceptableOrUnknown(
          data['exposure_time_seconds']!,
          _exposureTimeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exposureTimeSecondsMeta);
    }
    if (data.containsKey('frame_count')) {
      context.handle(
        _frameCountMeta,
        frameCount.isAcceptableOrUnknown(data['frame_count']!, _frameCountMeta),
      );
    } else if (isInserting) {
      context.missing(_frameCountMeta);
    }
    if (data.containsKey('binning')) {
      context.handle(
        _binningMeta,
        binning.isAcceptableOrUnknown(data['binning']!, _binningMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('calibration_policy')) {
      context.handle(
        _calibrationPolicyMeta,
        calibrationPolicy.isAcceptableOrUnknown(
          data['calibration_policy']!,
          _calibrationPolicyMeta,
        ),
      );
    }
    if (data.containsKey('gain_kind')) {
      context.handle(
        _gainKindMeta,
        gainKind.isAcceptableOrUnknown(data['gain_kind']!, _gainKindMeta),
      );
    }
    if (data.containsKey('gain_value')) {
      context.handle(
        _gainValueMeta,
        gainValue.isAcceptableOrUnknown(data['gain_value']!, _gainValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureBlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureBlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionLogId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_log_id'],
      )!,
      frameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_type'],
      )!,
      filterName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filter_name'],
      ),
      exposureTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exposure_time_seconds'],
      )!,
      frameCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frame_count'],
      )!,
      binning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}binning'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      calibrationPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calibration_policy'],
      ),
      gainKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gain_kind'],
      )!,
      gainValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gain_value'],
      ),
    );
  }

  @override
  $CaptureBlocksTable createAlias(String alias) {
    return $CaptureBlocksTable(attachedDatabase, alias);
  }
}

class CaptureBlock extends DataClass implements Insertable<CaptureBlock> {
  final int id;
  final int sessionLogId;
  final String frameType;
  final String? filterName;
  final double exposureTimeSeconds;
  final int frameCount;
  final int binning;
  final int position;
  final String? calibrationPolicy;
  final String gainKind;
  final double? gainValue;
  const CaptureBlock({
    required this.id,
    required this.sessionLogId,
    required this.frameType,
    this.filterName,
    required this.exposureTimeSeconds,
    required this.frameCount,
    required this.binning,
    required this.position,
    this.calibrationPolicy,
    required this.gainKind,
    this.gainValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_log_id'] = Variable<int>(sessionLogId);
    map['frame_type'] = Variable<String>(frameType);
    if (!nullToAbsent || filterName != null) {
      map['filter_name'] = Variable<String>(filterName);
    }
    map['exposure_time_seconds'] = Variable<double>(exposureTimeSeconds);
    map['frame_count'] = Variable<int>(frameCount);
    map['binning'] = Variable<int>(binning);
    map['position'] = Variable<int>(position);
    if (!nullToAbsent || calibrationPolicy != null) {
      map['calibration_policy'] = Variable<String>(calibrationPolicy);
    }
    map['gain_kind'] = Variable<String>(gainKind);
    if (!nullToAbsent || gainValue != null) {
      map['gain_value'] = Variable<double>(gainValue);
    }
    return map;
  }

  CaptureBlocksCompanion toCompanion(bool nullToAbsent) {
    return CaptureBlocksCompanion(
      id: Value(id),
      sessionLogId: Value(sessionLogId),
      frameType: Value(frameType),
      filterName: filterName == null && nullToAbsent
          ? const Value.absent()
          : Value(filterName),
      exposureTimeSeconds: Value(exposureTimeSeconds),
      frameCount: Value(frameCount),
      binning: Value(binning),
      position: Value(position),
      calibrationPolicy: calibrationPolicy == null && nullToAbsent
          ? const Value.absent()
          : Value(calibrationPolicy),
      gainKind: Value(gainKind),
      gainValue: gainValue == null && nullToAbsent
          ? const Value.absent()
          : Value(gainValue),
    );
  }

  factory CaptureBlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureBlock(
      id: serializer.fromJson<int>(json['id']),
      sessionLogId: serializer.fromJson<int>(json['sessionLogId']),
      frameType: serializer.fromJson<String>(json['frameType']),
      filterName: serializer.fromJson<String?>(json['filterName']),
      exposureTimeSeconds: serializer.fromJson<double>(
        json['exposureTimeSeconds'],
      ),
      frameCount: serializer.fromJson<int>(json['frameCount']),
      binning: serializer.fromJson<int>(json['binning']),
      position: serializer.fromJson<int>(json['position']),
      calibrationPolicy: serializer.fromJson<String?>(
        json['calibrationPolicy'],
      ),
      gainKind: serializer.fromJson<String>(json['gainKind']),
      gainValue: serializer.fromJson<double?>(json['gainValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionLogId': serializer.toJson<int>(sessionLogId),
      'frameType': serializer.toJson<String>(frameType),
      'filterName': serializer.toJson<String?>(filterName),
      'exposureTimeSeconds': serializer.toJson<double>(exposureTimeSeconds),
      'frameCount': serializer.toJson<int>(frameCount),
      'binning': serializer.toJson<int>(binning),
      'position': serializer.toJson<int>(position),
      'calibrationPolicy': serializer.toJson<String?>(calibrationPolicy),
      'gainKind': serializer.toJson<String>(gainKind),
      'gainValue': serializer.toJson<double?>(gainValue),
    };
  }

  CaptureBlock copyWith({
    int? id,
    int? sessionLogId,
    String? frameType,
    Value<String?> filterName = const Value.absent(),
    double? exposureTimeSeconds,
    int? frameCount,
    int? binning,
    int? position,
    Value<String?> calibrationPolicy = const Value.absent(),
    String? gainKind,
    Value<double?> gainValue = const Value.absent(),
  }) => CaptureBlock(
    id: id ?? this.id,
    sessionLogId: sessionLogId ?? this.sessionLogId,
    frameType: frameType ?? this.frameType,
    filterName: filterName.present ? filterName.value : this.filterName,
    exposureTimeSeconds: exposureTimeSeconds ?? this.exposureTimeSeconds,
    frameCount: frameCount ?? this.frameCount,
    binning: binning ?? this.binning,
    position: position ?? this.position,
    calibrationPolicy: calibrationPolicy.present
        ? calibrationPolicy.value
        : this.calibrationPolicy,
    gainKind: gainKind ?? this.gainKind,
    gainValue: gainValue.present ? gainValue.value : this.gainValue,
  );
  CaptureBlock copyWithCompanion(CaptureBlocksCompanion data) {
    return CaptureBlock(
      id: data.id.present ? data.id.value : this.id,
      sessionLogId: data.sessionLogId.present
          ? data.sessionLogId.value
          : this.sessionLogId,
      frameType: data.frameType.present ? data.frameType.value : this.frameType,
      filterName: data.filterName.present
          ? data.filterName.value
          : this.filterName,
      exposureTimeSeconds: data.exposureTimeSeconds.present
          ? data.exposureTimeSeconds.value
          : this.exposureTimeSeconds,
      frameCount: data.frameCount.present
          ? data.frameCount.value
          : this.frameCount,
      binning: data.binning.present ? data.binning.value : this.binning,
      position: data.position.present ? data.position.value : this.position,
      calibrationPolicy: data.calibrationPolicy.present
          ? data.calibrationPolicy.value
          : this.calibrationPolicy,
      gainKind: data.gainKind.present ? data.gainKind.value : this.gainKind,
      gainValue: data.gainValue.present ? data.gainValue.value : this.gainValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureBlock(')
          ..write('id: $id, ')
          ..write('sessionLogId: $sessionLogId, ')
          ..write('frameType: $frameType, ')
          ..write('filterName: $filterName, ')
          ..write('exposureTimeSeconds: $exposureTimeSeconds, ')
          ..write('frameCount: $frameCount, ')
          ..write('binning: $binning, ')
          ..write('position: $position, ')
          ..write('calibrationPolicy: $calibrationPolicy, ')
          ..write('gainKind: $gainKind, ')
          ..write('gainValue: $gainValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionLogId,
    frameType,
    filterName,
    exposureTimeSeconds,
    frameCount,
    binning,
    position,
    calibrationPolicy,
    gainKind,
    gainValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureBlock &&
          other.id == this.id &&
          other.sessionLogId == this.sessionLogId &&
          other.frameType == this.frameType &&
          other.filterName == this.filterName &&
          other.exposureTimeSeconds == this.exposureTimeSeconds &&
          other.frameCount == this.frameCount &&
          other.binning == this.binning &&
          other.position == this.position &&
          other.calibrationPolicy == this.calibrationPolicy &&
          other.gainKind == this.gainKind &&
          other.gainValue == this.gainValue);
}

class CaptureBlocksCompanion extends UpdateCompanion<CaptureBlock> {
  final Value<int> id;
  final Value<int> sessionLogId;
  final Value<String> frameType;
  final Value<String?> filterName;
  final Value<double> exposureTimeSeconds;
  final Value<int> frameCount;
  final Value<int> binning;
  final Value<int> position;
  final Value<String?> calibrationPolicy;
  final Value<String> gainKind;
  final Value<double?> gainValue;
  const CaptureBlocksCompanion({
    this.id = const Value.absent(),
    this.sessionLogId = const Value.absent(),
    this.frameType = const Value.absent(),
    this.filterName = const Value.absent(),
    this.exposureTimeSeconds = const Value.absent(),
    this.frameCount = const Value.absent(),
    this.binning = const Value.absent(),
    this.position = const Value.absent(),
    this.calibrationPolicy = const Value.absent(),
    this.gainKind = const Value.absent(),
    this.gainValue = const Value.absent(),
  });
  CaptureBlocksCompanion.insert({
    this.id = const Value.absent(),
    required int sessionLogId,
    required String frameType,
    this.filterName = const Value.absent(),
    required double exposureTimeSeconds,
    required int frameCount,
    this.binning = const Value.absent(),
    this.position = const Value.absent(),
    this.calibrationPolicy = const Value.absent(),
    this.gainKind = const Value.absent(),
    this.gainValue = const Value.absent(),
  }) : sessionLogId = Value(sessionLogId),
       frameType = Value(frameType),
       exposureTimeSeconds = Value(exposureTimeSeconds),
       frameCount = Value(frameCount);
  static Insertable<CaptureBlock> custom({
    Expression<int>? id,
    Expression<int>? sessionLogId,
    Expression<String>? frameType,
    Expression<String>? filterName,
    Expression<double>? exposureTimeSeconds,
    Expression<int>? frameCount,
    Expression<int>? binning,
    Expression<int>? position,
    Expression<String>? calibrationPolicy,
    Expression<String>? gainKind,
    Expression<double>? gainValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionLogId != null) 'session_log_id': sessionLogId,
      if (frameType != null) 'frame_type': frameType,
      if (filterName != null) 'filter_name': filterName,
      if (exposureTimeSeconds != null)
        'exposure_time_seconds': exposureTimeSeconds,
      if (frameCount != null) 'frame_count': frameCount,
      if (binning != null) 'binning': binning,
      if (position != null) 'position': position,
      if (calibrationPolicy != null) 'calibration_policy': calibrationPolicy,
      if (gainKind != null) 'gain_kind': gainKind,
      if (gainValue != null) 'gain_value': gainValue,
    });
  }

  CaptureBlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionLogId,
    Value<String>? frameType,
    Value<String?>? filterName,
    Value<double>? exposureTimeSeconds,
    Value<int>? frameCount,
    Value<int>? binning,
    Value<int>? position,
    Value<String?>? calibrationPolicy,
    Value<String>? gainKind,
    Value<double?>? gainValue,
  }) {
    return CaptureBlocksCompanion(
      id: id ?? this.id,
      sessionLogId: sessionLogId ?? this.sessionLogId,
      frameType: frameType ?? this.frameType,
      filterName: filterName ?? this.filterName,
      exposureTimeSeconds: exposureTimeSeconds ?? this.exposureTimeSeconds,
      frameCount: frameCount ?? this.frameCount,
      binning: binning ?? this.binning,
      position: position ?? this.position,
      calibrationPolicy: calibrationPolicy ?? this.calibrationPolicy,
      gainKind: gainKind ?? this.gainKind,
      gainValue: gainValue ?? this.gainValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionLogId.present) {
      map['session_log_id'] = Variable<int>(sessionLogId.value);
    }
    if (frameType.present) {
      map['frame_type'] = Variable<String>(frameType.value);
    }
    if (filterName.present) {
      map['filter_name'] = Variable<String>(filterName.value);
    }
    if (exposureTimeSeconds.present) {
      map['exposure_time_seconds'] = Variable<double>(
        exposureTimeSeconds.value,
      );
    }
    if (frameCount.present) {
      map['frame_count'] = Variable<int>(frameCount.value);
    }
    if (binning.present) {
      map['binning'] = Variable<int>(binning.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (calibrationPolicy.present) {
      map['calibration_policy'] = Variable<String>(calibrationPolicy.value);
    }
    if (gainKind.present) {
      map['gain_kind'] = Variable<String>(gainKind.value);
    }
    if (gainValue.present) {
      map['gain_value'] = Variable<double>(gainValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureBlocksCompanion(')
          ..write('id: $id, ')
          ..write('sessionLogId: $sessionLogId, ')
          ..write('frameType: $frameType, ')
          ..write('filterName: $filterName, ')
          ..write('exposureTimeSeconds: $exposureTimeSeconds, ')
          ..write('frameCount: $frameCount, ')
          ..write('binning: $binning, ')
          ..write('position: $position, ')
          ..write('calibrationPolicy: $calibrationPolicy, ')
          ..write('gainKind: $gainKind, ')
          ..write('gainValue: $gainValue')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $CameraModulesTable cameraModules = $CameraModulesTable(this);
  late final $OpticalRigsTable opticalRigs = $OpticalRigsTable(this);
  late final $LocationProfilesTable locationProfiles = $LocationProfilesTable(
    this,
  );
  late final $AstroTargetsTable astroTargets = $AstroTargetsTable(this);
  late final $SessionLogsTable sessionLogs = $SessionLogsTable(this);
  late final $CaptureBlocksTable captureBlocks = $CaptureBlocksTable(this);
  late final Index astroTargetsCatalogIdUnique = Index(
    'astro_targets_catalog_id_unique',
    'CREATE UNIQUE INDEX astro_targets_catalog_id_unique ON astro_targets (catalog_id) WHERE source LIKE \'seed:%\' OR source LIKE \'catalog:%\'',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devices,
    cameraModules,
    opticalRigs,
    locationProfiles,
    astroTargets,
    sessionLogs,
    captureBlocks,
    astroTargetsCatalogIdUnique,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'session_logs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('capture_blocks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DevicesTableCreateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> notes,
});
typedef $$DevicesTableUpdateCompanionBuilder = DevicesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> manufacturer,
  Value<String?> model,
  Value<String?> notes,
});

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CameraModulesTable, List<CameraModule>>
  _cameraModulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cameraModules,
    aliasName: 'devices__id__camera_modules__device_id',
  );

  $$CameraModulesTableProcessedTableManager get cameraModulesRefs {
    final manager = $$CameraModulesTableTableManager(
      $_db,
      $_db.cameraModules,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cameraModulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
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

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cameraModulesRefs(
    Expression<bool> Function($$CameraModulesTableFilterComposer f) f,
  ) {
    final $$CameraModulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cameraModules,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CameraModulesTableFilterComposer(
            $db: $db,
            $table: $db.cameraModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
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

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
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

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> cameraModulesRefs<T extends Object>(
    Expression<T> Function($$CameraModulesTableAnnotationComposer a) f,
  ) {
    final $$CameraModulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cameraModules,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CameraModulesTableAnnotationComposer(
            $db: $db,
            $table: $db.cameraModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, $$DevicesTableReferences),
          Device,
          PrefetchHooks Function({bool cameraModulesRefs})
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                manufacturer: manufacturer,
                model: model,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                manufacturer: manufacturer,
                model: model,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DevicesTable, Device>(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cameraModulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cameraModulesRefs) db.cameraModules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cameraModulesRefs)
                    await $_getPrefetchedData<
                      Device,
                      $DevicesTable,
                      CameraModule
                    >(
                      currentTable: table,
                      referencedTable: $$DevicesTableReferences
                          ._cameraModulesRefsTable(db),
                      managerFromTypedResult: (p0) => $$DevicesTableReferences(
                        db,
                        table,
                        p0,
                      ).cameraModulesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deviceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, $$DevicesTableReferences),
      Device,
      PrefetchHooks Function({bool cameraModulesRefs})
    >;
typedef $$CameraModulesTableCreateCompanionBuilder =
    CameraModulesCompanion Function({
      Value<int> id,
      required int deviceId,
      required String name,
      Value<String?> manufacturer,
      Value<String?> model,
      required double sensorWidthMm,
      required double sensorHeightMm,
      required int resolutionWidthPx,
      required int resolutionHeightPx,
      required double pixelPitchUm,
      Value<double?> averageRawFileSizeMB,
    });
typedef $$CameraModulesTableUpdateCompanionBuilder =
    CameraModulesCompanion Function({
      Value<int> id,
      Value<int> deviceId,
      Value<String> name,
      Value<String?> manufacturer,
      Value<String?> model,
      Value<double> sensorWidthMm,
      Value<double> sensorHeightMm,
      Value<int> resolutionWidthPx,
      Value<int> resolutionHeightPx,
      Value<double> pixelPitchUm,
      Value<double?> averageRawFileSizeMB,
    });

final class $$CameraModulesTableReferences
    extends BaseReferences<_$AppDatabase, $CameraModulesTable, CameraModule> {
  $$CameraModulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTable _deviceIdTable(_$AppDatabase db) =>
      db.devices.createAlias('camera_modules__device_id__devices__id');

  $$DevicesTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<int>('device_id')!;

    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OpticalRigsTable, List<OpticalRig>>
  _opticalRigsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.opticalRigs,
    aliasName: 'camera_modules__id__optical_rigs__camera_module_id',
  );

  $$OpticalRigsTableProcessedTableManager get opticalRigsRefs {
    final manager = $$OpticalRigsTableTableManager(
      $_db,
      $_db.opticalRigs,
    ).filter((f) => f.cameraModuleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_opticalRigsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CameraModulesTableFilterComposer
    extends Composer<_$AppDatabase, $CameraModulesTable> {
  $$CameraModulesTableFilterComposer({
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

  ColumnFilters<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionWidthPx => $composableBuilder(
    column: $table.resolutionWidthPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolutionHeightPx => $composableBuilder(
    column: $table.resolutionHeightPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pixelPitchUm => $composableBuilder(
    column: $table.pixelPitchUm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRawFileSizeMB => $composableBuilder(
    column: $table.averageRawFileSizeMB,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableFilterComposer get deviceId {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> opticalRigsRefs(
    Expression<bool> Function($$OpticalRigsTableFilterComposer f) f,
  ) {
    final $$OpticalRigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opticalRigs,
      getReferencedColumn: (t) => t.cameraModuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpticalRigsTableFilterComposer(
            $db: $db,
            $table: $db.opticalRigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CameraModulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CameraModulesTable> {
  $$CameraModulesTableOrderingComposer({
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

  ColumnOrderings<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionWidthPx => $composableBuilder(
    column: $table.resolutionWidthPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolutionHeightPx => $composableBuilder(
    column: $table.resolutionHeightPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pixelPitchUm => $composableBuilder(
    column: $table.pixelPitchUm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRawFileSizeMB => $composableBuilder(
    column: $table.averageRawFileSizeMB,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableOrderingComposer get deviceId {
    final $$DevicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableOrderingComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CameraModulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CameraModulesTable> {
  $$CameraModulesTableAnnotationComposer({
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

  GeneratedColumn<String> get manufacturer => $composableBuilder(
    column: $table.manufacturer,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<double> get sensorWidthMm => $composableBuilder(
    column: $table.sensorWidthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sensorHeightMm => $composableBuilder(
    column: $table.sensorHeightMm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionWidthPx => $composableBuilder(
    column: $table.resolutionWidthPx,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolutionHeightPx => $composableBuilder(
    column: $table.resolutionHeightPx,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pixelPitchUm => $composableBuilder(
    column: $table.pixelPitchUm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRawFileSizeMB => $composableBuilder(
    column: $table.averageRawFileSizeMB,
    builder: (column) => column,
  );

  $$DevicesTableAnnotationComposer get deviceId {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> opticalRigsRefs<T extends Object>(
    Expression<T> Function($$OpticalRigsTableAnnotationComposer a) f,
  ) {
    final $$OpticalRigsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opticalRigs,
      getReferencedColumn: (t) => t.cameraModuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpticalRigsTableAnnotationComposer(
            $db: $db,
            $table: $db.opticalRigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CameraModulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CameraModulesTable,
          CameraModule,
          $$CameraModulesTableFilterComposer,
          $$CameraModulesTableOrderingComposer,
          $$CameraModulesTableAnnotationComposer,
          $$CameraModulesTableCreateCompanionBuilder,
          $$CameraModulesTableUpdateCompanionBuilder,
          (CameraModule, $$CameraModulesTableReferences),
          CameraModule,
          PrefetchHooks Function({bool deviceId, bool opticalRigsRefs})
        > {
  $$CameraModulesTableTableManager(_$AppDatabase db, $CameraModulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CameraModulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CameraModulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CameraModulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<double> sensorWidthMm = const Value.absent(),
                Value<double> sensorHeightMm = const Value.absent(),
                Value<int> resolutionWidthPx = const Value.absent(),
                Value<int> resolutionHeightPx = const Value.absent(),
                Value<double> pixelPitchUm = const Value.absent(),
                Value<double?> averageRawFileSizeMB = const Value.absent(),
              }) => CameraModulesCompanion(
                id: id,
                deviceId: deviceId,
                name: name,
                manufacturer: manufacturer,
                model: model,
                sensorWidthMm: sensorWidthMm,
                sensorHeightMm: sensorHeightMm,
                resolutionWidthPx: resolutionWidthPx,
                resolutionHeightPx: resolutionHeightPx,
                pixelPitchUm: pixelPitchUm,
                averageRawFileSizeMB: averageRawFileSizeMB,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int deviceId,
                required String name,
                Value<String?> manufacturer = const Value.absent(),
                Value<String?> model = const Value.absent(),
                required double sensorWidthMm,
                required double sensorHeightMm,
                required int resolutionWidthPx,
                required int resolutionHeightPx,
                required double pixelPitchUm,
                Value<double?> averageRawFileSizeMB = const Value.absent(),
              }) => CameraModulesCompanion.insert(
                id: id,
                deviceId: deviceId,
                name: name,
                manufacturer: manufacturer,
                model: model,
                sensorWidthMm: sensorWidthMm,
                sensorHeightMm: sensorHeightMm,
                resolutionWidthPx: resolutionWidthPx,
                resolutionHeightPx: resolutionHeightPx,
                pixelPitchUm: pixelPitchUm,
                averageRawFileSizeMB: averageRawFileSizeMB,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CameraModulesTable, CameraModule>(table),
                  $$CameraModulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false, opticalRigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (opticalRigsRefs) db.opticalRigs],
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
                    if (deviceId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.deviceId,
                        referencedTable: $$CameraModulesTableReferences
                            ._deviceIdTable(db),
                        referencedColumn: $$CameraModulesTableReferences
                            ._deviceIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (opticalRigsRefs)
                    await $_getPrefetchedData<
                      CameraModule,
                      $CameraModulesTable,
                      OpticalRig
                    >(
                      currentTable: table,
                      referencedTable: $$CameraModulesTableReferences
                          ._opticalRigsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CameraModulesTableReferences(
                            db,
                            table,
                            p0,
                          ).opticalRigsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.cameraModuleId == item.id,
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

typedef $$CameraModulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CameraModulesTable,
      CameraModule,
      $$CameraModulesTableFilterComposer,
      $$CameraModulesTableOrderingComposer,
      $$CameraModulesTableAnnotationComposer,
      $$CameraModulesTableCreateCompanionBuilder,
      $$CameraModulesTableUpdateCompanionBuilder,
      (CameraModule, $$CameraModulesTableReferences),
      CameraModule,
      PrefetchHooks Function({bool deviceId, bool opticalRigsRefs})
    >;
typedef $$OpticalRigsTableCreateCompanionBuilder =
    OpticalRigsCompanion Function({
      Value<int> id,
      required String name,
      required int cameraModuleId,
      required double focalLengthMm,
      required double aperture,
      Value<String> trackingState,
      Value<double?> rotationDegrees,
    });
typedef $$OpticalRigsTableUpdateCompanionBuilder =
    OpticalRigsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> cameraModuleId,
      Value<double> focalLengthMm,
      Value<double> aperture,
      Value<String> trackingState,
      Value<double?> rotationDegrees,
    });

final class $$OpticalRigsTableReferences
    extends BaseReferences<_$AppDatabase, $OpticalRigsTable, OpticalRig> {
  $$OpticalRigsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CameraModulesTable _cameraModuleIdTable(_$AppDatabase db) => db
      .cameraModules
      .createAlias('optical_rigs__camera_module_id__camera_modules__id');

  $$CameraModulesTableProcessedTableManager get cameraModuleId {
    final $_column = $_itemColumn<int>('camera_module_id')!;

    final manager = $$CameraModulesTableTableManager(
      $_db,
      $_db.cameraModules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cameraModuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OpticalRigsTableFilterComposer
    extends Composer<_$AppDatabase, $OpticalRigsTable> {
  $$OpticalRigsTableFilterComposer({
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

  ColumnFilters<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aperture => $composableBuilder(
    column: $table.aperture,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackingState => $composableBuilder(
    column: $table.trackingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rotationDegrees => $composableBuilder(
    column: $table.rotationDegrees,
    builder: (column) => ColumnFilters(column),
  );

  $$CameraModulesTableFilterComposer get cameraModuleId {
    final $$CameraModulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cameraModuleId,
      referencedTable: $db.cameraModules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CameraModulesTableFilterComposer(
            $db: $db,
            $table: $db.cameraModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpticalRigsTableOrderingComposer
    extends Composer<_$AppDatabase, $OpticalRigsTable> {
  $$OpticalRigsTableOrderingComposer({
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

  ColumnOrderings<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aperture => $composableBuilder(
    column: $table.aperture,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackingState => $composableBuilder(
    column: $table.trackingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rotationDegrees => $composableBuilder(
    column: $table.rotationDegrees,
    builder: (column) => ColumnOrderings(column),
  );

  $$CameraModulesTableOrderingComposer get cameraModuleId {
    final $$CameraModulesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cameraModuleId,
      referencedTable: $db.cameraModules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CameraModulesTableOrderingComposer(
            $db: $db,
            $table: $db.cameraModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpticalRigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpticalRigsTable> {
  $$OpticalRigsTableAnnotationComposer({
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

  GeneratedColumn<double> get focalLengthMm => $composableBuilder(
    column: $table.focalLengthMm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aperture =>
      $composableBuilder(column: $table.aperture, builder: (column) => column);

  GeneratedColumn<String> get trackingState => $composableBuilder(
    column: $table.trackingState,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rotationDegrees => $composableBuilder(
    column: $table.rotationDegrees,
    builder: (column) => column,
  );

  $$CameraModulesTableAnnotationComposer get cameraModuleId {
    final $$CameraModulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cameraModuleId,
      referencedTable: $db.cameraModules,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CameraModulesTableAnnotationComposer(
            $db: $db,
            $table: $db.cameraModules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpticalRigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpticalRigsTable,
          OpticalRig,
          $$OpticalRigsTableFilterComposer,
          $$OpticalRigsTableOrderingComposer,
          $$OpticalRigsTableAnnotationComposer,
          $$OpticalRigsTableCreateCompanionBuilder,
          $$OpticalRigsTableUpdateCompanionBuilder,
          (OpticalRig, $$OpticalRigsTableReferences),
          OpticalRig,
          PrefetchHooks Function({bool cameraModuleId})
        > {
  $$OpticalRigsTableTableManager(_$AppDatabase db, $OpticalRigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpticalRigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpticalRigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpticalRigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> cameraModuleId = const Value.absent(),
                Value<double> focalLengthMm = const Value.absent(),
                Value<double> aperture = const Value.absent(),
                Value<String> trackingState = const Value.absent(),
                Value<double?> rotationDegrees = const Value.absent(),
              }) => OpticalRigsCompanion(
                id: id,
                name: name,
                cameraModuleId: cameraModuleId,
                focalLengthMm: focalLengthMm,
                aperture: aperture,
                trackingState: trackingState,
                rotationDegrees: rotationDegrees,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int cameraModuleId,
                required double focalLengthMm,
                required double aperture,
                Value<String> trackingState = const Value.absent(),
                Value<double?> rotationDegrees = const Value.absent(),
              }) => OpticalRigsCompanion.insert(
                id: id,
                name: name,
                cameraModuleId: cameraModuleId,
                focalLengthMm: focalLengthMm,
                aperture: aperture,
                trackingState: trackingState,
                rotationDegrees: rotationDegrees,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OpticalRigsTable, OpticalRig>(table),
                  $$OpticalRigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cameraModuleId = false}) {
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
                    if (cameraModuleId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.cameraModuleId,
                        referencedTable: $$OpticalRigsTableReferences
                            ._cameraModuleIdTable(db),
                        referencedColumn: $$OpticalRigsTableReferences
                            ._cameraModuleIdTable(db)
                            .id,
                      ) as T;
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

typedef $$OpticalRigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpticalRigsTable,
      OpticalRig,
      $$OpticalRigsTableFilterComposer,
      $$OpticalRigsTableOrderingComposer,
      $$OpticalRigsTableAnnotationComposer,
      $$OpticalRigsTableCreateCompanionBuilder,
      $$OpticalRigsTableUpdateCompanionBuilder,
      (OpticalRig, $$OpticalRigsTableReferences),
      OpticalRig,
      PrefetchHooks Function({bool cameraModuleId})
    >;
typedef $$LocationProfilesTableCreateCompanionBuilder =
    LocationProfilesCompanion Function({
      Value<int> id,
      required String name,
      required double latitude,
      required double longitude,
      required double elevation,
      Value<int?> bortleClass,
      Value<String?> bortleSource,
      Value<String?> bortleDate,
      Value<double?> sqm,
      Value<String?> sqmSource,
      Value<String?> sqmDate,
      Value<String?> timeZone,
      Value<String?> notes,
    });
typedef $$LocationProfilesTableUpdateCompanionBuilder =
    LocationProfilesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> elevation,
      Value<int?> bortleClass,
      Value<String?> bortleSource,
      Value<String?> bortleDate,
      Value<double?> sqm,
      Value<String?> sqmSource,
      Value<String?> sqmDate,
      Value<String?> timeZone,
      Value<String?> notes,
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

  ColumnFilters<int> get bortleClass => $composableBuilder(
    column: $table.bortleClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bortleSource => $composableBuilder(
    column: $table.bortleSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bortleDate => $composableBuilder(
    column: $table.bortleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sqm => $composableBuilder(
    column: $table.sqm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sqmSource => $composableBuilder(
    column: $table.sqmSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sqmDate => $composableBuilder(
    column: $table.sqmDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<int> get bortleClass => $composableBuilder(
    column: $table.bortleClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bortleSource => $composableBuilder(
    column: $table.bortleSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bortleDate => $composableBuilder(
    column: $table.bortleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sqm => $composableBuilder(
    column: $table.sqm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sqmSource => $composableBuilder(
    column: $table.sqmSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sqmDate => $composableBuilder(
    column: $table.sqmDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeZone => $composableBuilder(
    column: $table.timeZone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  GeneratedColumn<int> get bortleClass => $composableBuilder(
    column: $table.bortleClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bortleSource => $composableBuilder(
    column: $table.bortleSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bortleDate => $composableBuilder(
    column: $table.bortleDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sqm =>
      $composableBuilder(column: $table.sqm, builder: (column) => column);

  GeneratedColumn<String> get sqmSource =>
      $composableBuilder(column: $table.sqmSource, builder: (column) => column);

  GeneratedColumn<String> get sqmDate =>
      $composableBuilder(column: $table.sqmDate, builder: (column) => column);

  GeneratedColumn<String> get timeZone =>
      $composableBuilder(column: $table.timeZone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
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
                Value<int?> bortleClass = const Value.absent(),
                Value<String?> bortleSource = const Value.absent(),
                Value<String?> bortleDate = const Value.absent(),
                Value<double?> sqm = const Value.absent(),
                Value<String?> sqmSource = const Value.absent(),
                Value<String?> sqmDate = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => LocationProfilesCompanion(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
                bortleClass: bortleClass,
                bortleSource: bortleSource,
                bortleDate: bortleDate,
                sqm: sqm,
                sqmSource: sqmSource,
                sqmDate: sqmDate,
                timeZone: timeZone,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double latitude,
                required double longitude,
                required double elevation,
                Value<int?> bortleClass = const Value.absent(),
                Value<String?> bortleSource = const Value.absent(),
                Value<String?> bortleDate = const Value.absent(),
                Value<double?> sqm = const Value.absent(),
                Value<String?> sqmSource = const Value.absent(),
                Value<String?> sqmDate = const Value.absent(),
                Value<String?> timeZone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => LocationProfilesCompanion.insert(
                id: id,
                name: name,
                latitude: latitude,
                longitude: longitude,
                elevation: elevation,
                bortleClass: bortleClass,
                bortleSource: bortleSource,
                bortleDate: bortleDate,
                sqm: sqm,
                sqmSource: sqmSource,
                sqmDate: sqmDate,
                timeZone: timeZone,
                notes: notes,
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
      Value<String> epoch,
      Value<String?> source,
      Value<double?> angularSizeArcmin,
      Value<double?> magnitude,
    });
typedef $$AstroTargetsTableUpdateCompanionBuilder =
    AstroTargetsCompanion Function({
      Value<int> id,
      Value<String> catalogId,
      Value<String?> commonName,
      Value<double> rightAscension,
      Value<double> declination,
      Value<String> type,
      Value<String> epoch,
      Value<String?> source,
      Value<double?> angularSizeArcmin,
      Value<double?> magnitude,
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

  ColumnFilters<String> get epoch => $composableBuilder(
    column: $table.epoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get angularSizeArcmin => $composableBuilder(
    column: $table.angularSizeArcmin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnitude => $composableBuilder(
    column: $table.magnitude,
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

  ColumnOrderings<String> get epoch => $composableBuilder(
    column: $table.epoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get angularSizeArcmin => $composableBuilder(
    column: $table.angularSizeArcmin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnitude => $composableBuilder(
    column: $table.magnitude,
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

  GeneratedColumn<String> get epoch =>
      $composableBuilder(column: $table.epoch, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<double> get angularSizeArcmin => $composableBuilder(
    column: $table.angularSizeArcmin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnitude =>
      $composableBuilder(column: $table.magnitude, builder: (column) => column);
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
                Value<String> epoch = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<double?> angularSizeArcmin = const Value.absent(),
                Value<double?> magnitude = const Value.absent(),
              }) => AstroTargetsCompanion(
                id: id,
                catalogId: catalogId,
                commonName: commonName,
                rightAscension: rightAscension,
                declination: declination,
                type: type,
                epoch: epoch,
                source: source,
                angularSizeArcmin: angularSizeArcmin,
                magnitude: magnitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String catalogId,
                Value<String?> commonName = const Value.absent(),
                required double rightAscension,
                required double declination,
                required String type,
                Value<String> epoch = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<double?> angularSizeArcmin = const Value.absent(),
                Value<double?> magnitude = const Value.absent(),
              }) => AstroTargetsCompanion.insert(
                id: id,
                catalogId: catalogId,
                commonName: commonName,
                rightAscension: rightAscension,
                declination: declination,
                type: type,
                epoch: epoch,
                source: source,
                angularSizeArcmin: angularSizeArcmin,
                magnitude: magnitude,
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
      Value<String?> locationName,
      Value<double?> bortleScale,
      required int plannedLightFrames,
      Value<int?> plannedDarkFrames,
      Value<int?> plannedFlatFrames,
      Value<int?> plannedBiasFrames,
      Value<double?> integrationTimeSeconds,
      Value<double?> focalLength,
      Value<double?> aperture,
      Value<double?> temperature,
      Value<double?> humidity,
      Value<int?> cloudCover,
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
      Value<String?> locationName,
      Value<double?> bortleScale,
      Value<int> plannedLightFrames,
      Value<int?> plannedDarkFrames,
      Value<int?> plannedFlatFrames,
      Value<int?> plannedBiasFrames,
      Value<double?> integrationTimeSeconds,
      Value<double?> focalLength,
      Value<double?> aperture,
      Value<double?> temperature,
      Value<double?> humidity,
      Value<int?> cloudCover,
      Value<int?> actualLightFrames,
      Value<int?> rejectedFrames,
      Value<String?> environmentalNotes,
      Value<String?> processingNotes,
    });

final class $$SessionLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionLogsTable, SessionLog> {
  $$SessionLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CaptureBlocksTable, List<CaptureBlock>>
  _captureBlocksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.captureBlocks,
    aliasName: 'session_logs__id__capture_blocks__session_log_id',
  );

  $$CaptureBlocksTableProcessedTableManager get captureBlocksRefs {
    final manager = $$CaptureBlocksTableTableManager(
      $_db,
      $_db.captureBlocks,
    ).filter((f) => f.sessionLogId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_captureBlocksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bortleScale => $composableBuilder(
    column: $table.bortleScale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDarkFrames => $composableBuilder(
    column: $table.plannedDarkFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedFlatFrames => $composableBuilder(
    column: $table.plannedFlatFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedBiasFrames => $composableBuilder(
    column: $table.plannedBiasFrames,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get integrationTimeSeconds => $composableBuilder(
    column: $table.integrationTimeSeconds,
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

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cloudCover => $composableBuilder(
    column: $table.cloudCover,
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

  Expression<bool> captureBlocksRefs(
    Expression<bool> Function($$CaptureBlocksTableFilterComposer f) f,
  ) {
    final $$CaptureBlocksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.captureBlocks,
      getReferencedColumn: (t) => t.sessionLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaptureBlocksTableFilterComposer(
            $db: $db,
            $table: $db.captureBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bortleScale => $composableBuilder(
    column: $table.bortleScale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDarkFrames => $composableBuilder(
    column: $table.plannedDarkFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedFlatFrames => $composableBuilder(
    column: $table.plannedFlatFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedBiasFrames => $composableBuilder(
    column: $table.plannedBiasFrames,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get integrationTimeSeconds => $composableBuilder(
    column: $table.integrationTimeSeconds,
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

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get humidity => $composableBuilder(
    column: $table.humidity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cloudCover => $composableBuilder(
    column: $table.cloudCover,
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

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bortleScale => $composableBuilder(
    column: $table.bortleScale,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedLightFrames => $composableBuilder(
    column: $table.plannedLightFrames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedDarkFrames => $composableBuilder(
    column: $table.plannedDarkFrames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedFlatFrames => $composableBuilder(
    column: $table.plannedFlatFrames,
    builder: (column) => column,
  );

  GeneratedColumn<int> get plannedBiasFrames => $composableBuilder(
    column: $table.plannedBiasFrames,
    builder: (column) => column,
  );

  GeneratedColumn<double> get integrationTimeSeconds => $composableBuilder(
    column: $table.integrationTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get focalLength => $composableBuilder(
    column: $table.focalLength,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aperture =>
      $composableBuilder(column: $table.aperture, builder: (column) => column);

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get humidity =>
      $composableBuilder(column: $table.humidity, builder: (column) => column);

  GeneratedColumn<int> get cloudCover => $composableBuilder(
    column: $table.cloudCover,
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

  Expression<T> captureBlocksRefs<T extends Object>(
    Expression<T> Function($$CaptureBlocksTableAnnotationComposer a) f,
  ) {
    final $$CaptureBlocksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.captureBlocks,
      getReferencedColumn: (t) => t.sessionLogId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CaptureBlocksTableAnnotationComposer(
            $db: $db,
            $table: $db.captureBlocks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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
          (SessionLog, $$SessionLogsTableReferences),
          SessionLog,
          PrefetchHooks Function({bool captureBlocksRefs})
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
                Value<String?> locationName = const Value.absent(),
                Value<double?> bortleScale = const Value.absent(),
                Value<int> plannedLightFrames = const Value.absent(),
                Value<int?> plannedDarkFrames = const Value.absent(),
                Value<int?> plannedFlatFrames = const Value.absent(),
                Value<int?> plannedBiasFrames = const Value.absent(),
                Value<double?> integrationTimeSeconds = const Value.absent(),
                Value<double?> focalLength = const Value.absent(),
                Value<double?> aperture = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> humidity = const Value.absent(),
                Value<int?> cloudCover = const Value.absent(),
                Value<int?> actualLightFrames = const Value.absent(),
                Value<int?> rejectedFrames = const Value.absent(),
                Value<String?> environmentalNotes = const Value.absent(),
                Value<String?> processingNotes = const Value.absent(),
              }) => SessionLogsCompanion(
                id: id,
                targetName: targetName,
                equipmentName: equipmentName,
                sessionDate: sessionDate,
                locationName: locationName,
                bortleScale: bortleScale,
                plannedLightFrames: plannedLightFrames,
                plannedDarkFrames: plannedDarkFrames,
                plannedFlatFrames: plannedFlatFrames,
                plannedBiasFrames: plannedBiasFrames,
                integrationTimeSeconds: integrationTimeSeconds,
                focalLength: focalLength,
                aperture: aperture,
                temperature: temperature,
                humidity: humidity,
                cloudCover: cloudCover,
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
                Value<String?> locationName = const Value.absent(),
                Value<double?> bortleScale = const Value.absent(),
                required int plannedLightFrames,
                Value<int?> plannedDarkFrames = const Value.absent(),
                Value<int?> plannedFlatFrames = const Value.absent(),
                Value<int?> plannedBiasFrames = const Value.absent(),
                Value<double?> integrationTimeSeconds = const Value.absent(),
                Value<double?> focalLength = const Value.absent(),
                Value<double?> aperture = const Value.absent(),
                Value<double?> temperature = const Value.absent(),
                Value<double?> humidity = const Value.absent(),
                Value<int?> cloudCover = const Value.absent(),
                Value<int?> actualLightFrames = const Value.absent(),
                Value<int?> rejectedFrames = const Value.absent(),
                Value<String?> environmentalNotes = const Value.absent(),
                Value<String?> processingNotes = const Value.absent(),
              }) => SessionLogsCompanion.insert(
                id: id,
                targetName: targetName,
                equipmentName: equipmentName,
                sessionDate: sessionDate,
                locationName: locationName,
                bortleScale: bortleScale,
                plannedLightFrames: plannedLightFrames,
                plannedDarkFrames: plannedDarkFrames,
                plannedFlatFrames: plannedFlatFrames,
                plannedBiasFrames: plannedBiasFrames,
                integrationTimeSeconds: integrationTimeSeconds,
                focalLength: focalLength,
                aperture: aperture,
                temperature: temperature,
                humidity: humidity,
                cloudCover: cloudCover,
                actualLightFrames: actualLightFrames,
                rejectedFrames: rejectedFrames,
                environmentalNotes: environmentalNotes,
                processingNotes: processingNotes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionLogsTable, SessionLog>(table),
                  $$SessionLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({captureBlocksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (captureBlocksRefs) db.captureBlocks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (captureBlocksRefs)
                    await $_getPrefetchedData<
                      SessionLog,
                      $SessionLogsTable,
                      CaptureBlock
                    >(
                      currentTable: table,
                      referencedTable: $$SessionLogsTableReferences
                          ._captureBlocksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionLogsTableReferences(
                            db,
                            table,
                            p0,
                          ).captureBlocksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.sessionLogId == item.id,
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
      (SessionLog, $$SessionLogsTableReferences),
      SessionLog,
      PrefetchHooks Function({bool captureBlocksRefs})
    >;
typedef $$CaptureBlocksTableCreateCompanionBuilder =
    CaptureBlocksCompanion Function({
      Value<int> id,
      required int sessionLogId,
      required String frameType,
      Value<String?> filterName,
      required double exposureTimeSeconds,
      required int frameCount,
      Value<int> binning,
      Value<int> position,
      Value<String?> calibrationPolicy,
      Value<String> gainKind,
      Value<double?> gainValue,
    });
typedef $$CaptureBlocksTableUpdateCompanionBuilder =
    CaptureBlocksCompanion Function({
      Value<int> id,
      Value<int> sessionLogId,
      Value<String> frameType,
      Value<String?> filterName,
      Value<double> exposureTimeSeconds,
      Value<int> frameCount,
      Value<int> binning,
      Value<int> position,
      Value<String?> calibrationPolicy,
      Value<String> gainKind,
      Value<double?> gainValue,
    });

final class $$CaptureBlocksTableReferences
    extends BaseReferences<_$AppDatabase, $CaptureBlocksTable, CaptureBlock> {
  $$CaptureBlocksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionLogsTable _sessionLogIdTable(_$AppDatabase db) => db
      .sessionLogs
      .createAlias('capture_blocks__session_log_id__session_logs__id');

  $$SessionLogsTableProcessedTableManager get sessionLogId {
    final $_column = $_itemColumn<int>('session_log_id')!;

    final manager = $$SessionLogsTableTableManager(
      $_db,
      $_db.sessionLogs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionLogIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CaptureBlocksTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureBlocksTable> {
  $$CaptureBlocksTableFilterComposer({
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

  ColumnFilters<String> get frameType => $composableBuilder(
    column: $table.frameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filterName => $composableBuilder(
    column: $table.filterName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exposureTimeSeconds => $composableBuilder(
    column: $table.exposureTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get frameCount => $composableBuilder(
    column: $table.frameCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get binning => $composableBuilder(
    column: $table.binning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calibrationPolicy => $composableBuilder(
    column: $table.calibrationPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gainKind => $composableBuilder(
    column: $table.gainKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gainValue => $composableBuilder(
    column: $table.gainValue,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionLogsTableFilterComposer get sessionLogId {
    final $$SessionLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionLogId,
      referencedTable: $db.sessionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionLogsTableFilterComposer(
            $db: $db,
            $table: $db.sessionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureBlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureBlocksTable> {
  $$CaptureBlocksTableOrderingComposer({
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

  ColumnOrderings<String> get frameType => $composableBuilder(
    column: $table.frameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filterName => $composableBuilder(
    column: $table.filterName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exposureTimeSeconds => $composableBuilder(
    column: $table.exposureTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frameCount => $composableBuilder(
    column: $table.frameCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get binning => $composableBuilder(
    column: $table.binning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calibrationPolicy => $composableBuilder(
    column: $table.calibrationPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gainKind => $composableBuilder(
    column: $table.gainKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gainValue => $composableBuilder(
    column: $table.gainValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionLogsTableOrderingComposer get sessionLogId {
    final $$SessionLogsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionLogId,
      referencedTable: $db.sessionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionLogsTableOrderingComposer(
            $db: $db,
            $table: $db.sessionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureBlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureBlocksTable> {
  $$CaptureBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frameType =>
      $composableBuilder(column: $table.frameType, builder: (column) => column);

  GeneratedColumn<String> get filterName => $composableBuilder(
    column: $table.filterName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exposureTimeSeconds => $composableBuilder(
    column: $table.exposureTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get frameCount => $composableBuilder(
    column: $table.frameCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get binning =>
      $composableBuilder(column: $table.binning, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get calibrationPolicy => $composableBuilder(
    column: $table.calibrationPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gainKind =>
      $composableBuilder(column: $table.gainKind, builder: (column) => column);

  GeneratedColumn<double> get gainValue =>
      $composableBuilder(column: $table.gainValue, builder: (column) => column);

  $$SessionLogsTableAnnotationComposer get sessionLogId {
    final $$SessionLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionLogId,
      referencedTable: $db.sessionLogs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CaptureBlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CaptureBlocksTable,
          CaptureBlock,
          $$CaptureBlocksTableFilterComposer,
          $$CaptureBlocksTableOrderingComposer,
          $$CaptureBlocksTableAnnotationComposer,
          $$CaptureBlocksTableCreateCompanionBuilder,
          $$CaptureBlocksTableUpdateCompanionBuilder,
          (CaptureBlock, $$CaptureBlocksTableReferences),
          CaptureBlock,
          PrefetchHooks Function({bool sessionLogId})
        > {
  $$CaptureBlocksTableTableManager(_$AppDatabase db, $CaptureBlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionLogId = const Value.absent(),
                Value<String> frameType = const Value.absent(),
                Value<String?> filterName = const Value.absent(),
                Value<double> exposureTimeSeconds = const Value.absent(),
                Value<int> frameCount = const Value.absent(),
                Value<int> binning = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> calibrationPolicy = const Value.absent(),
                Value<String> gainKind = const Value.absent(),
                Value<double?> gainValue = const Value.absent(),
              }) => CaptureBlocksCompanion(
                id: id,
                sessionLogId: sessionLogId,
                frameType: frameType,
                filterName: filterName,
                exposureTimeSeconds: exposureTimeSeconds,
                frameCount: frameCount,
                binning: binning,
                position: position,
                calibrationPolicy: calibrationPolicy,
                gainKind: gainKind,
                gainValue: gainValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionLogId,
                required String frameType,
                Value<String?> filterName = const Value.absent(),
                required double exposureTimeSeconds,
                required int frameCount,
                Value<int> binning = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String?> calibrationPolicy = const Value.absent(),
                Value<String> gainKind = const Value.absent(),
                Value<double?> gainValue = const Value.absent(),
              }) => CaptureBlocksCompanion.insert(
                id: id,
                sessionLogId: sessionLogId,
                frameType: frameType,
                filterName: filterName,
                exposureTimeSeconds: exposureTimeSeconds,
                frameCount: frameCount,
                binning: binning,
                position: position,
                calibrationPolicy: calibrationPolicy,
                gainKind: gainKind,
                gainValue: gainValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CaptureBlocksTable, CaptureBlock>(table),
                  $$CaptureBlocksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionLogId = false}) {
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
                    if (sessionLogId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionLogId,
                        referencedTable: $$CaptureBlocksTableReferences
                            ._sessionLogIdTable(db),
                        referencedColumn: $$CaptureBlocksTableReferences
                            ._sessionLogIdTable(db)
                            .id,
                      ) as T;
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

typedef $$CaptureBlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CaptureBlocksTable,
      CaptureBlock,
      $$CaptureBlocksTableFilterComposer,
      $$CaptureBlocksTableOrderingComposer,
      $$CaptureBlocksTableAnnotationComposer,
      $$CaptureBlocksTableCreateCompanionBuilder,
      $$CaptureBlocksTableUpdateCompanionBuilder,
      (CaptureBlock, $$CaptureBlocksTableReferences),
      CaptureBlock,
      PrefetchHooks Function({bool sessionLogId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$CameraModulesTableTableManager get cameraModules =>
      $$CameraModulesTableTableManager(_db, _db.cameraModules);
  $$OpticalRigsTableTableManager get opticalRigs =>
      $$OpticalRigsTableTableManager(_db, _db.opticalRigs);
  $$LocationProfilesTableTableManager get locationProfiles =>
      $$LocationProfilesTableTableManager(_db, _db.locationProfiles);
  $$AstroTargetsTableTableManager get astroTargets =>
      $$AstroTargetsTableTableManager(_db, _db.astroTargets);
  $$SessionLogsTableTableManager get sessionLogs =>
      $$SessionLogsTableTableManager(_db, _db.sessionLogs);
  $$CaptureBlocksTableTableManager get captureBlocks =>
      $$CaptureBlocksTableTableManager(_db, _db.captureBlocks);
}
