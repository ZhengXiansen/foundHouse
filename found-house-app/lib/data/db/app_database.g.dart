// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VillagesTable extends Villages with TableInfo<$VillagesTable, Village> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VillagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('preparing'));
  static const VerificationMeta _areaNoteMeta =
      const VerificationMeta('areaNote');
  @override
  late final GeneratedColumn<String> areaNote = GeneratedColumn<String>(
      'area_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commuteMinutesMeta =
      const VerificationMeta('commuteMinutes');
  @override
  late final GeneratedColumn<int> commuteMinutes = GeneratedColumn<int>(
      'commute_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _commuteNoteMeta =
      const VerificationMeta('commuteNote');
  @override
  late final GeneratedColumn<String> commuteNote = GeneratedColumn<String>(
      'commute_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _surroundingsTagsJsonMeta =
      const VerificationMeta('surroundingsTagsJson');
  @override
  late final GeneratedColumn<String> surroundingsTagsJson =
      GeneratedColumn<String>('surroundings_tags_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _surroundingsScoreMeta =
      const VerificationMeta('surroundingsScore');
  @override
  late final GeneratedColumn<int> surroundingsScore = GeneratedColumn<int>(
      'surroundings_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _environmentScoreMeta =
      const VerificationMeta('environmentScore');
  @override
  late final GeneratedColumn<int> environmentScore = GeneratedColumn<int>(
      'environment_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _safetyScoreMeta =
      const VerificationMeta('safetyScore');
  @override
  late final GeneratedColumn<int> safetyScore = GeneratedColumn<int>(
      'safety_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noiseScoreMeta =
      const VerificationMeta('noiseScore');
  @override
  late final GeneratedColumn<int> noiseScore = GeneratedColumn<int>(
      'noise_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastVisitedAtMeta =
      const VerificationMeta('lastVisitedAt');
  @override
  late final GeneratedColumn<int> lastVisitedAt = GeneratedColumn<int>(
      'last_visited_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        status,
        areaNote,
        commuteMinutes,
        commuteNote,
        surroundingsTagsJson,
        surroundingsScore,
        environmentScore,
        safetyScore,
        noiseScore,
        note,
        createdAt,
        updatedAt,
        lastVisitedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'village';
  @override
  VerificationContext validateIntegrity(Insertable<Village> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('area_note')) {
      context.handle(_areaNoteMeta,
          areaNote.isAcceptableOrUnknown(data['area_note']!, _areaNoteMeta));
    }
    if (data.containsKey('commute_minutes')) {
      context.handle(
          _commuteMinutesMeta,
          commuteMinutes.isAcceptableOrUnknown(
              data['commute_minutes']!, _commuteMinutesMeta));
    }
    if (data.containsKey('commute_note')) {
      context.handle(
          _commuteNoteMeta,
          commuteNote.isAcceptableOrUnknown(
              data['commute_note']!, _commuteNoteMeta));
    }
    if (data.containsKey('surroundings_tags_json')) {
      context.handle(
          _surroundingsTagsJsonMeta,
          surroundingsTagsJson.isAcceptableOrUnknown(
              data['surroundings_tags_json']!, _surroundingsTagsJsonMeta));
    }
    if (data.containsKey('surroundings_score')) {
      context.handle(
          _surroundingsScoreMeta,
          surroundingsScore.isAcceptableOrUnknown(
              data['surroundings_score']!, _surroundingsScoreMeta));
    }
    if (data.containsKey('environment_score')) {
      context.handle(
          _environmentScoreMeta,
          environmentScore.isAcceptableOrUnknown(
              data['environment_score']!, _environmentScoreMeta));
    }
    if (data.containsKey('safety_score')) {
      context.handle(
          _safetyScoreMeta,
          safetyScore.isAcceptableOrUnknown(
              data['safety_score']!, _safetyScoreMeta));
    }
    if (data.containsKey('noise_score')) {
      context.handle(
          _noiseScoreMeta,
          noiseScore.isAcceptableOrUnknown(
              data['noise_score']!, _noiseScoreMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_visited_at')) {
      context.handle(
          _lastVisitedAtMeta,
          lastVisitedAt.isAcceptableOrUnknown(
              data['last_visited_at']!, _lastVisitedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Village map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Village(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      areaNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}area_note']),
      commuteMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}commute_minutes']),
      commuteNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commute_note']),
      surroundingsTagsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}surroundings_tags_json']),
      surroundingsScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surroundings_score']),
      environmentScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}environment_score']),
      safetyScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}safety_score']),
      noiseScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}noise_score']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      lastVisitedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_visited_at']),
    );
  }

  @override
  $VillagesTable createAlias(String alias) {
    return $VillagesTable(attachedDatabase, alias);
  }
}

class Village extends DataClass implements Insertable<Village> {
  /// UUID v4 或系统固定 id（未分组）。
  final String id;

  /// 村名 / 片区名。
  final String name;

  /// 生命周期：preparing/scouting/paused/completed/archived。
  final String status;

  /// 区域备注：如范围、入口、管理处位置等。
  final String? areaNote;

  /// 手动记录的默认通勤分钟。
  final int? commuteMinutes;

  /// 通勤备注：如到地铁、公司、常走路线。
  final String? commuteNote;

  /// 周边标签 JSON：菜市场/地铁/夜宵/噪音等。
  final String? surroundingsTagsJson;

  /// 主观周边评分。
  final int? surroundingsScore;

  /// 环境评分。
  final int? environmentScore;

  /// 安全评分。
  final int? safetyScore;

  /// 噪音评分。
  final int? noiseScore;

  /// 备注。
  final String? note;

  /// 创建时间（本地毫秒时间戳）。
  final int createdAt;

  /// 更新时间（本地毫秒时间戳）。
  final int updatedAt;

  /// 最近扫楼/访问时间。
  final int? lastVisitedAt;
  const Village(
      {required this.id,
      required this.name,
      required this.status,
      this.areaNote,
      this.commuteMinutes,
      this.commuteNote,
      this.surroundingsTagsJson,
      this.surroundingsScore,
      this.environmentScore,
      this.safetyScore,
      this.noiseScore,
      this.note,
      required this.createdAt,
      required this.updatedAt,
      this.lastVisitedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || areaNote != null) {
      map['area_note'] = Variable<String>(areaNote);
    }
    if (!nullToAbsent || commuteMinutes != null) {
      map['commute_minutes'] = Variable<int>(commuteMinutes);
    }
    if (!nullToAbsent || commuteNote != null) {
      map['commute_note'] = Variable<String>(commuteNote);
    }
    if (!nullToAbsent || surroundingsTagsJson != null) {
      map['surroundings_tags_json'] = Variable<String>(surroundingsTagsJson);
    }
    if (!nullToAbsent || surroundingsScore != null) {
      map['surroundings_score'] = Variable<int>(surroundingsScore);
    }
    if (!nullToAbsent || environmentScore != null) {
      map['environment_score'] = Variable<int>(environmentScore);
    }
    if (!nullToAbsent || safetyScore != null) {
      map['safety_score'] = Variable<int>(safetyScore);
    }
    if (!nullToAbsent || noiseScore != null) {
      map['noise_score'] = Variable<int>(noiseScore);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || lastVisitedAt != null) {
      map['last_visited_at'] = Variable<int>(lastVisitedAt);
    }
    return map;
  }

  VillagesCompanion toCompanion(bool nullToAbsent) {
    return VillagesCompanion(
      id: Value(id),
      name: Value(name),
      status: Value(status),
      areaNote: areaNote == null && nullToAbsent
          ? const Value.absent()
          : Value(areaNote),
      commuteMinutes: commuteMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(commuteMinutes),
      commuteNote: commuteNote == null && nullToAbsent
          ? const Value.absent()
          : Value(commuteNote),
      surroundingsTagsJson: surroundingsTagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(surroundingsTagsJson),
      surroundingsScore: surroundingsScore == null && nullToAbsent
          ? const Value.absent()
          : Value(surroundingsScore),
      environmentScore: environmentScore == null && nullToAbsent
          ? const Value.absent()
          : Value(environmentScore),
      safetyScore: safetyScore == null && nullToAbsent
          ? const Value.absent()
          : Value(safetyScore),
      noiseScore: noiseScore == null && nullToAbsent
          ? const Value.absent()
          : Value(noiseScore),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastVisitedAt: lastVisitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitedAt),
    );
  }

  factory Village.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Village(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      areaNote: serializer.fromJson<String?>(json['areaNote']),
      commuteMinutes: serializer.fromJson<int?>(json['commuteMinutes']),
      commuteNote: serializer.fromJson<String?>(json['commuteNote']),
      surroundingsTagsJson:
          serializer.fromJson<String?>(json['surroundingsTagsJson']),
      surroundingsScore: serializer.fromJson<int?>(json['surroundingsScore']),
      environmentScore: serializer.fromJson<int?>(json['environmentScore']),
      safetyScore: serializer.fromJson<int?>(json['safetyScore']),
      noiseScore: serializer.fromJson<int?>(json['noiseScore']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastVisitedAt: serializer.fromJson<int?>(json['lastVisitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'areaNote': serializer.toJson<String?>(areaNote),
      'commuteMinutes': serializer.toJson<int?>(commuteMinutes),
      'commuteNote': serializer.toJson<String?>(commuteNote),
      'surroundingsTagsJson': serializer.toJson<String?>(surroundingsTagsJson),
      'surroundingsScore': serializer.toJson<int?>(surroundingsScore),
      'environmentScore': serializer.toJson<int?>(environmentScore),
      'safetyScore': serializer.toJson<int?>(safetyScore),
      'noiseScore': serializer.toJson<int?>(noiseScore),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastVisitedAt': serializer.toJson<int?>(lastVisitedAt),
    };
  }

  Village copyWith(
          {String? id,
          String? name,
          String? status,
          Value<String?> areaNote = const Value.absent(),
          Value<int?> commuteMinutes = const Value.absent(),
          Value<String?> commuteNote = const Value.absent(),
          Value<String?> surroundingsTagsJson = const Value.absent(),
          Value<int?> surroundingsScore = const Value.absent(),
          Value<int?> environmentScore = const Value.absent(),
          Value<int?> safetyScore = const Value.absent(),
          Value<int?> noiseScore = const Value.absent(),
          Value<String?> note = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> lastVisitedAt = const Value.absent()}) =>
      Village(
        id: id ?? this.id,
        name: name ?? this.name,
        status: status ?? this.status,
        areaNote: areaNote.present ? areaNote.value : this.areaNote,
        commuteMinutes:
            commuteMinutes.present ? commuteMinutes.value : this.commuteMinutes,
        commuteNote: commuteNote.present ? commuteNote.value : this.commuteNote,
        surroundingsTagsJson: surroundingsTagsJson.present
            ? surroundingsTagsJson.value
            : this.surroundingsTagsJson,
        surroundingsScore: surroundingsScore.present
            ? surroundingsScore.value
            : this.surroundingsScore,
        environmentScore: environmentScore.present
            ? environmentScore.value
            : this.environmentScore,
        safetyScore: safetyScore.present ? safetyScore.value : this.safetyScore,
        noiseScore: noiseScore.present ? noiseScore.value : this.noiseScore,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastVisitedAt:
            lastVisitedAt.present ? lastVisitedAt.value : this.lastVisitedAt,
      );
  Village copyWithCompanion(VillagesCompanion data) {
    return Village(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      areaNote: data.areaNote.present ? data.areaNote.value : this.areaNote,
      commuteMinutes: data.commuteMinutes.present
          ? data.commuteMinutes.value
          : this.commuteMinutes,
      commuteNote:
          data.commuteNote.present ? data.commuteNote.value : this.commuteNote,
      surroundingsTagsJson: data.surroundingsTagsJson.present
          ? data.surroundingsTagsJson.value
          : this.surroundingsTagsJson,
      surroundingsScore: data.surroundingsScore.present
          ? data.surroundingsScore.value
          : this.surroundingsScore,
      environmentScore: data.environmentScore.present
          ? data.environmentScore.value
          : this.environmentScore,
      safetyScore:
          data.safetyScore.present ? data.safetyScore.value : this.safetyScore,
      noiseScore:
          data.noiseScore.present ? data.noiseScore.value : this.noiseScore,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastVisitedAt: data.lastVisitedAt.present
          ? data.lastVisitedAt.value
          : this.lastVisitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Village(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('areaNote: $areaNote, ')
          ..write('commuteMinutes: $commuteMinutes, ')
          ..write('commuteNote: $commuteNote, ')
          ..write('surroundingsTagsJson: $surroundingsTagsJson, ')
          ..write('surroundingsScore: $surroundingsScore, ')
          ..write('environmentScore: $environmentScore, ')
          ..write('safetyScore: $safetyScore, ')
          ..write('noiseScore: $noiseScore, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastVisitedAt: $lastVisitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      status,
      areaNote,
      commuteMinutes,
      commuteNote,
      surroundingsTagsJson,
      surroundingsScore,
      environmentScore,
      safetyScore,
      noiseScore,
      note,
      createdAt,
      updatedAt,
      lastVisitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Village &&
          other.id == this.id &&
          other.name == this.name &&
          other.status == this.status &&
          other.areaNote == this.areaNote &&
          other.commuteMinutes == this.commuteMinutes &&
          other.commuteNote == this.commuteNote &&
          other.surroundingsTagsJson == this.surroundingsTagsJson &&
          other.surroundingsScore == this.surroundingsScore &&
          other.environmentScore == this.environmentScore &&
          other.safetyScore == this.safetyScore &&
          other.noiseScore == this.noiseScore &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastVisitedAt == this.lastVisitedAt);
}

class VillagesCompanion extends UpdateCompanion<Village> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> status;
  final Value<String?> areaNote;
  final Value<int?> commuteMinutes;
  final Value<String?> commuteNote;
  final Value<String?> surroundingsTagsJson;
  final Value<int?> surroundingsScore;
  final Value<int?> environmentScore;
  final Value<int?> safetyScore;
  final Value<int?> noiseScore;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> lastVisitedAt;
  final Value<int> rowid;
  const VillagesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.areaNote = const Value.absent(),
    this.commuteMinutes = const Value.absent(),
    this.commuteNote = const Value.absent(),
    this.surroundingsTagsJson = const Value.absent(),
    this.surroundingsScore = const Value.absent(),
    this.environmentScore = const Value.absent(),
    this.safetyScore = const Value.absent(),
    this.noiseScore = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VillagesCompanion.insert({
    required String id,
    required String name,
    this.status = const Value.absent(),
    this.areaNote = const Value.absent(),
    this.commuteMinutes = const Value.absent(),
    this.commuteNote = const Value.absent(),
    this.surroundingsTagsJson = const Value.absent(),
    this.surroundingsScore = const Value.absent(),
    this.environmentScore = const Value.absent(),
    this.safetyScore = const Value.absent(),
    this.noiseScore = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Village> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? areaNote,
    Expression<int>? commuteMinutes,
    Expression<String>? commuteNote,
    Expression<String>? surroundingsTagsJson,
    Expression<int>? surroundingsScore,
    Expression<int>? environmentScore,
    Expression<int>? safetyScore,
    Expression<int>? noiseScore,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? lastVisitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (areaNote != null) 'area_note': areaNote,
      if (commuteMinutes != null) 'commute_minutes': commuteMinutes,
      if (commuteNote != null) 'commute_note': commuteNote,
      if (surroundingsTagsJson != null)
        'surroundings_tags_json': surroundingsTagsJson,
      if (surroundingsScore != null) 'surroundings_score': surroundingsScore,
      if (environmentScore != null) 'environment_score': environmentScore,
      if (safetyScore != null) 'safety_score': safetyScore,
      if (noiseScore != null) 'noise_score': noiseScore,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastVisitedAt != null) 'last_visited_at': lastVisitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VillagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? status,
      Value<String?>? areaNote,
      Value<int?>? commuteMinutes,
      Value<String?>? commuteNote,
      Value<String?>? surroundingsTagsJson,
      Value<int?>? surroundingsScore,
      Value<int?>? environmentScore,
      Value<int?>? safetyScore,
      Value<int?>? noiseScore,
      Value<String?>? note,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? lastVisitedAt,
      Value<int>? rowid}) {
    return VillagesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      areaNote: areaNote ?? this.areaNote,
      commuteMinutes: commuteMinutes ?? this.commuteMinutes,
      commuteNote: commuteNote ?? this.commuteNote,
      surroundingsTagsJson: surroundingsTagsJson ?? this.surroundingsTagsJson,
      surroundingsScore: surroundingsScore ?? this.surroundingsScore,
      environmentScore: environmentScore ?? this.environmentScore,
      safetyScore: safetyScore ?? this.safetyScore,
      noiseScore: noiseScore ?? this.noiseScore,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
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
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (areaNote.present) {
      map['area_note'] = Variable<String>(areaNote.value);
    }
    if (commuteMinutes.present) {
      map['commute_minutes'] = Variable<int>(commuteMinutes.value);
    }
    if (commuteNote.present) {
      map['commute_note'] = Variable<String>(commuteNote.value);
    }
    if (surroundingsTagsJson.present) {
      map['surroundings_tags_json'] =
          Variable<String>(surroundingsTagsJson.value);
    }
    if (surroundingsScore.present) {
      map['surroundings_score'] = Variable<int>(surroundingsScore.value);
    }
    if (environmentScore.present) {
      map['environment_score'] = Variable<int>(environmentScore.value);
    }
    if (safetyScore.present) {
      map['safety_score'] = Variable<int>(safetyScore.value);
    }
    if (noiseScore.present) {
      map['noise_score'] = Variable<int>(noiseScore.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastVisitedAt.present) {
      map['last_visited_at'] = Variable<int>(lastVisitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VillagesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('areaNote: $areaNote, ')
          ..write('commuteMinutes: $commuteMinutes, ')
          ..write('commuteNote: $commuteNote, ')
          ..write('surroundingsTagsJson: $surroundingsTagsJson, ')
          ..write('surroundingsScore: $surroundingsScore, ')
          ..write('environmentScore: $environmentScore, ')
          ..write('safetyScore: $safetyScore, ')
          ..write('noiseScore: $noiseScore, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastVisitedAt: $lastVisitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _villageIdMeta =
      const VerificationMeta('villageId');
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
      'village_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES village (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('not_scouted'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entranceNoteMeta =
      const VerificationMeta('entranceNote');
  @override
  late final GeneratedColumn<String> entranceNote = GeneratedColumn<String>(
      'entrance_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _totalFloorMeta =
      const VerificationMeta('totalFloor');
  @override
  late final GeneratedColumn<int> totalFloor = GeneratedColumn<int>(
      'total_floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasElevatorMeta =
      const VerificationMeta('hasElevator');
  @override
  late final GeneratedColumn<bool> hasElevator = GeneratedColumn<bool>(
      'has_elevator', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_elevator" IN (0, 1))'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lastVisitedAtMeta =
      const VerificationMeta('lastVisitedAt');
  @override
  late final GeneratedColumn<int> lastVisitedAt = GeneratedColumn<int>(
      'last_visited_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        villageId,
        name,
        status,
        tagsJson,
        entranceNote,
        totalFloor,
        hasElevator,
        note,
        createdAt,
        updatedAt,
        lastVisitedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'building';
  @override
  VerificationContext validateIntegrity(Insertable<Building> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('village_id')) {
      context.handle(_villageIdMeta,
          villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta));
    } else if (isInserting) {
      context.missing(_villageIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('entrance_note')) {
      context.handle(
          _entranceNoteMeta,
          entranceNote.isAcceptableOrUnknown(
              data['entrance_note']!, _entranceNoteMeta));
    }
    if (data.containsKey('total_floor')) {
      context.handle(
          _totalFloorMeta,
          totalFloor.isAcceptableOrUnknown(
              data['total_floor']!, _totalFloorMeta));
    }
    if (data.containsKey('has_elevator')) {
      context.handle(
          _hasElevatorMeta,
          hasElevator.isAcceptableOrUnknown(
              data['has_elevator']!, _hasElevatorMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_visited_at')) {
      context.handle(
          _lastVisitedAtMeta,
          lastVisitedAt.isAcceptableOrUnknown(
              data['last_visited_at']!, _lastVisitedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      villageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}village_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json']),
      entranceNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entrance_note']),
      totalFloor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_floor']),
      hasElevator: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_elevator']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      lastVisitedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_visited_at']),
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }
}

class Building extends DataClass implements Insertable<Building> {
  /// UUID v4 主键。
  final String id;
  final String villageId;

  /// 楼栋 / 入口名。
  final String name;

  /// 状态：not_scouted/no_vacancy/has_vacancy/contacting/needs_revisit/abandoned。
  final String status;

  /// 标签 JSON：电话没人接/门禁进不去等。
  final String? tagsJson;

  /// 入口备注。
  final String? entranceNote;

  /// 总楼层。
  final int? totalFloor;

  /// 是否有电梯。
  final bool? hasElevator;

  /// 备注。
  final String? note;

  /// 创建时间（本地毫秒时间戳）。
  final int createdAt;

  /// 更新时间（本地毫秒时间戳）。
  final int updatedAt;

  /// 最近扫楼/访问时间。
  final int? lastVisitedAt;
  const Building(
      {required this.id,
      required this.villageId,
      required this.name,
      required this.status,
      this.tagsJson,
      this.entranceNote,
      this.totalFloor,
      this.hasElevator,
      this.note,
      required this.createdAt,
      required this.updatedAt,
      this.lastVisitedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['village_id'] = Variable<String>(villageId);
    map['name'] = Variable<String>(name);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || tagsJson != null) {
      map['tags_json'] = Variable<String>(tagsJson);
    }
    if (!nullToAbsent || entranceNote != null) {
      map['entrance_note'] = Variable<String>(entranceNote);
    }
    if (!nullToAbsent || totalFloor != null) {
      map['total_floor'] = Variable<int>(totalFloor);
    }
    if (!nullToAbsent || hasElevator != null) {
      map['has_elevator'] = Variable<bool>(hasElevator);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || lastVisitedAt != null) {
      map['last_visited_at'] = Variable<int>(lastVisitedAt);
    }
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      id: Value(id),
      villageId: Value(villageId),
      name: Value(name),
      status: Value(status),
      tagsJson: tagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(tagsJson),
      entranceNote: entranceNote == null && nullToAbsent
          ? const Value.absent()
          : Value(entranceNote),
      totalFloor: totalFloor == null && nullToAbsent
          ? const Value.absent()
          : Value(totalFloor),
      hasElevator: hasElevator == null && nullToAbsent
          ? const Value.absent()
          : Value(hasElevator),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastVisitedAt: lastVisitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVisitedAt),
    );
  }

  factory Building.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      id: serializer.fromJson<String>(json['id']),
      villageId: serializer.fromJson<String>(json['villageId']),
      name: serializer.fromJson<String>(json['name']),
      status: serializer.fromJson<String>(json['status']),
      tagsJson: serializer.fromJson<String?>(json['tagsJson']),
      entranceNote: serializer.fromJson<String?>(json['entranceNote']),
      totalFloor: serializer.fromJson<int?>(json['totalFloor']),
      hasElevator: serializer.fromJson<bool?>(json['hasElevator']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      lastVisitedAt: serializer.fromJson<int?>(json['lastVisitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'villageId': serializer.toJson<String>(villageId),
      'name': serializer.toJson<String>(name),
      'status': serializer.toJson<String>(status),
      'tagsJson': serializer.toJson<String?>(tagsJson),
      'entranceNote': serializer.toJson<String?>(entranceNote),
      'totalFloor': serializer.toJson<int?>(totalFloor),
      'hasElevator': serializer.toJson<bool?>(hasElevator),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'lastVisitedAt': serializer.toJson<int?>(lastVisitedAt),
    };
  }

  Building copyWith(
          {String? id,
          String? villageId,
          String? name,
          String? status,
          Value<String?> tagsJson = const Value.absent(),
          Value<String?> entranceNote = const Value.absent(),
          Value<int?> totalFloor = const Value.absent(),
          Value<bool?> hasElevator = const Value.absent(),
          Value<String?> note = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> lastVisitedAt = const Value.absent()}) =>
      Building(
        id: id ?? this.id,
        villageId: villageId ?? this.villageId,
        name: name ?? this.name,
        status: status ?? this.status,
        tagsJson: tagsJson.present ? tagsJson.value : this.tagsJson,
        entranceNote:
            entranceNote.present ? entranceNote.value : this.entranceNote,
        totalFloor: totalFloor.present ? totalFloor.value : this.totalFloor,
        hasElevator: hasElevator.present ? hasElevator.value : this.hasElevator,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastVisitedAt:
            lastVisitedAt.present ? lastVisitedAt.value : this.lastVisitedAt,
      );
  Building copyWithCompanion(BuildingsCompanion data) {
    return Building(
      id: data.id.present ? data.id.value : this.id,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      name: data.name.present ? data.name.value : this.name,
      status: data.status.present ? data.status.value : this.status,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      entranceNote: data.entranceNote.present
          ? data.entranceNote.value
          : this.entranceNote,
      totalFloor:
          data.totalFloor.present ? data.totalFloor.value : this.totalFloor,
      hasElevator:
          data.hasElevator.present ? data.hasElevator.value : this.hasElevator,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastVisitedAt: data.lastVisitedAt.present
          ? data.lastVisitedAt.value
          : this.lastVisitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('entranceNote: $entranceNote, ')
          ..write('totalFloor: $totalFloor, ')
          ..write('hasElevator: $hasElevator, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastVisitedAt: $lastVisitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      villageId,
      name,
      status,
      tagsJson,
      entranceNote,
      totalFloor,
      hasElevator,
      note,
      createdAt,
      updatedAt,
      lastVisitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.id == this.id &&
          other.villageId == this.villageId &&
          other.name == this.name &&
          other.status == this.status &&
          other.tagsJson == this.tagsJson &&
          other.entranceNote == this.entranceNote &&
          other.totalFloor == this.totalFloor &&
          other.hasElevator == this.hasElevator &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastVisitedAt == this.lastVisitedAt);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<String> id;
  final Value<String> villageId;
  final Value<String> name;
  final Value<String> status;
  final Value<String?> tagsJson;
  final Value<String?> entranceNote;
  final Value<int?> totalFloor;
  final Value<bool?> hasElevator;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> lastVisitedAt;
  final Value<int> rowid;
  const BuildingsCompanion({
    this.id = const Value.absent(),
    this.villageId = const Value.absent(),
    this.name = const Value.absent(),
    this.status = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.entranceNote = const Value.absent(),
    this.totalFloor = const Value.absent(),
    this.hasElevator = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuildingsCompanion.insert({
    required String id,
    required String villageId,
    required String name,
    this.status = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.entranceNote = const Value.absent(),
    this.totalFloor = const Value.absent(),
    this.hasElevator = const Value.absent(),
    this.note = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.lastVisitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        villageId = Value(villageId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Building> custom({
    Expression<String>? id,
    Expression<String>? villageId,
    Expression<String>? name,
    Expression<String>? status,
    Expression<String>? tagsJson,
    Expression<String>? entranceNote,
    Expression<int>? totalFloor,
    Expression<bool>? hasElevator,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? lastVisitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (villageId != null) 'village_id': villageId,
      if (name != null) 'name': name,
      if (status != null) 'status': status,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (entranceNote != null) 'entrance_note': entranceNote,
      if (totalFloor != null) 'total_floor': totalFloor,
      if (hasElevator != null) 'has_elevator': hasElevator,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastVisitedAt != null) 'last_visited_at': lastVisitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuildingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? villageId,
      Value<String>? name,
      Value<String>? status,
      Value<String?>? tagsJson,
      Value<String?>? entranceNote,
      Value<int?>? totalFloor,
      Value<bool?>? hasElevator,
      Value<String?>? note,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? lastVisitedAt,
      Value<int>? rowid}) {
    return BuildingsCompanion(
      id: id ?? this.id,
      villageId: villageId ?? this.villageId,
      name: name ?? this.name,
      status: status ?? this.status,
      tagsJson: tagsJson ?? this.tagsJson,
      entranceNote: entranceNote ?? this.entranceNote,
      totalFloor: totalFloor ?? this.totalFloor,
      hasElevator: hasElevator ?? this.hasElevator,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVisitedAt: lastVisitedAt ?? this.lastVisitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (entranceNote.present) {
      map['entrance_note'] = Variable<String>(entranceNote.value);
    }
    if (totalFloor.present) {
      map['total_floor'] = Variable<int>(totalFloor.value);
    }
    if (hasElevator.present) {
      map['has_elevator'] = Variable<bool>(hasElevator.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastVisitedAt.present) {
      map['last_visited_at'] = Variable<int>(lastVisitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('id: $id, ')
          ..write('villageId: $villageId, ')
          ..write('name: $name, ')
          ..write('status: $status, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('entranceNote: $entranceNote, ')
          ..write('totalFloor: $totalFloor, ')
          ..write('hasElevator: $hasElevator, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastVisitedAt: $lastVisitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HouseRecordsTable extends HouseRecords
    with TableInfo<$HouseRecordsTable, HouseRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HouseRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _villageIdMeta =
      const VerificationMeta('villageId');
  @override
  late final GeneratedColumn<String> villageId = GeneratedColumn<String>(
      'village_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES village (id) ON DELETE SET NULL'));
  static const VerificationMeta _buildingIdMeta =
      const VerificationMeta('buildingId');
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
      'building_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES building (id) ON DELETE SET NULL'));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _addressTextMeta =
      const VerificationMeta('addressText');
  @override
  late final GeneratedColumn<String> addressText = GeneratedColumn<String>(
      'address_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buildingNameMeta =
      const VerificationMeta('buildingName');
  @override
  late final GeneratedColumn<String> buildingName = GeneratedColumn<String>(
      'building_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roomNoMeta = const VerificationMeta('roomNo');
  @override
  late final GeneratedColumn<String> roomNo = GeneratedColumn<String>(
      'room_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _visitedAtMeta =
      const VerificationMeta('visitedAt');
  @override
  late final GeneratedColumn<int> visitedAt = GeneratedColumn<int>(
      'visited_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        status,
        villageId,
        buildingId,
        latitude,
        longitude,
        addressText,
        buildingName,
        roomNo,
        createdAt,
        updatedAt,
        visitedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'house_record';
  @override
  VerificationContext validateIntegrity(Insertable<HouseRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('village_id')) {
      context.handle(_villageIdMeta,
          villageId.isAcceptableOrUnknown(data['village_id']!, _villageIdMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
          _buildingIdMeta,
          buildingId.isAcceptableOrUnknown(
              data['building_id']!, _buildingIdMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('address_text')) {
      context.handle(
          _addressTextMeta,
          addressText.isAcceptableOrUnknown(
              data['address_text']!, _addressTextMeta));
    }
    if (data.containsKey('building_name')) {
      context.handle(
          _buildingNameMeta,
          buildingName.isAcceptableOrUnknown(
              data['building_name']!, _buildingNameMeta));
    }
    if (data.containsKey('room_no')) {
      context.handle(_roomNoMeta,
          roomNo.isAcceptableOrUnknown(data['room_no']!, _roomNoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('visited_at')) {
      context.handle(_visitedAtMeta,
          visitedAt.isAcceptableOrUnknown(data['visited_at']!, _visitedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HouseRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HouseRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      villageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}village_id']),
      buildingId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}building_id']),
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      addressText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_text']),
      buildingName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}building_name']),
      roomNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}room_no']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
      visitedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}visited_at']),
    );
  }

  @override
  $HouseRecordsTable createAlias(String alias) {
    return $HouseRecordsTable(attachedDatabase, alias);
  }
}

class HouseRecord extends DataClass implements Insertable<HouseRecord> {
  /// UUID v4 主键。
  final String id;

  /// 标题：用户标题或自动生成标题。
  final String title;

  /// 状态：draft/active/shortlisted/rejected/chosen。
  final String status;

  /// 所属村 / 片区。DB 层允许空以兼容旧数据，仓库层自动补“未分组”。
  final String? villageId;

  /// 所属楼栋 / 入口，可空表示村内未分楼栋房源。
  final String? buildingId;

  /// 纬度（遗留字段，V0.2 手动扫楼流程不再展示/依赖）。
  final double? latitude;

  /// 经度（导出可隐藏精确经纬度）。
  final double? longitude;

  /// 用户输入地址文本。
  final String? addressText;

  /// 楼栋或村名。
  final String? buildingName;

  /// 门牌：存全量原文，脱敏在导出层（F9）。敏感字段，密文存储。
  final String? roomNo;

  /// 创建时间（本地毫秒时间戳）。
  final int createdAt;

  /// 更新时间（本地毫秒时间戳）。
  final int updatedAt;

  /// 看房时间。
  final int? visitedAt;
  const HouseRecord(
      {required this.id,
      required this.title,
      required this.status,
      this.villageId,
      this.buildingId,
      this.latitude,
      this.longitude,
      this.addressText,
      this.buildingName,
      this.roomNo,
      required this.createdAt,
      required this.updatedAt,
      this.visitedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || villageId != null) {
      map['village_id'] = Variable<String>(villageId);
    }
    if (!nullToAbsent || buildingId != null) {
      map['building_id'] = Variable<String>(buildingId);
    }
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || addressText != null) {
      map['address_text'] = Variable<String>(addressText);
    }
    if (!nullToAbsent || buildingName != null) {
      map['building_name'] = Variable<String>(buildingName);
    }
    if (!nullToAbsent || roomNo != null) {
      map['room_no'] = Variable<String>(roomNo);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || visitedAt != null) {
      map['visited_at'] = Variable<int>(visitedAt);
    }
    return map;
  }

  HouseRecordsCompanion toCompanion(bool nullToAbsent) {
    return HouseRecordsCompanion(
      id: Value(id),
      title: Value(title),
      status: Value(status),
      villageId: villageId == null && nullToAbsent
          ? const Value.absent()
          : Value(villageId),
      buildingId: buildingId == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingId),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      addressText: addressText == null && nullToAbsent
          ? const Value.absent()
          : Value(addressText),
      buildingName: buildingName == null && nullToAbsent
          ? const Value.absent()
          : Value(buildingName),
      roomNo:
          roomNo == null && nullToAbsent ? const Value.absent() : Value(roomNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      visitedAt: visitedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(visitedAt),
    );
  }

  factory HouseRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HouseRecord(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      villageId: serializer.fromJson<String?>(json['villageId']),
      buildingId: serializer.fromJson<String?>(json['buildingId']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      addressText: serializer.fromJson<String?>(json['addressText']),
      buildingName: serializer.fromJson<String?>(json['buildingName']),
      roomNo: serializer.fromJson<String?>(json['roomNo']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
      visitedAt: serializer.fromJson<int?>(json['visitedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'villageId': serializer.toJson<String?>(villageId),
      'buildingId': serializer.toJson<String?>(buildingId),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'addressText': serializer.toJson<String?>(addressText),
      'buildingName': serializer.toJson<String?>(buildingName),
      'roomNo': serializer.toJson<String?>(roomNo),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
      'visitedAt': serializer.toJson<int?>(visitedAt),
    };
  }

  HouseRecord copyWith(
          {String? id,
          String? title,
          String? status,
          Value<String?> villageId = const Value.absent(),
          Value<String?> buildingId = const Value.absent(),
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> addressText = const Value.absent(),
          Value<String?> buildingName = const Value.absent(),
          Value<String?> roomNo = const Value.absent(),
          int? createdAt,
          int? updatedAt,
          Value<int?> visitedAt = const Value.absent()}) =>
      HouseRecord(
        id: id ?? this.id,
        title: title ?? this.title,
        status: status ?? this.status,
        villageId: villageId.present ? villageId.value : this.villageId,
        buildingId: buildingId.present ? buildingId.value : this.buildingId,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        addressText: addressText.present ? addressText.value : this.addressText,
        buildingName:
            buildingName.present ? buildingName.value : this.buildingName,
        roomNo: roomNo.present ? roomNo.value : this.roomNo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        visitedAt: visitedAt.present ? visitedAt.value : this.visitedAt,
      );
  HouseRecord copyWithCompanion(HouseRecordsCompanion data) {
    return HouseRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      villageId: data.villageId.present ? data.villageId.value : this.villageId,
      buildingId:
          data.buildingId.present ? data.buildingId.value : this.buildingId,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      addressText:
          data.addressText.present ? data.addressText.value : this.addressText,
      buildingName: data.buildingName.present
          ? data.buildingName.value
          : this.buildingName,
      roomNo: data.roomNo.present ? data.roomNo.value : this.roomNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HouseRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('villageId: $villageId, ')
          ..write('buildingId: $buildingId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('addressText: $addressText, ')
          ..write('buildingName: $buildingName, ')
          ..write('roomNo: $roomNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('visitedAt: $visitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      status,
      villageId,
      buildingId,
      latitude,
      longitude,
      addressText,
      buildingName,
      roomNo,
      createdAt,
      updatedAt,
      visitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HouseRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.status == this.status &&
          other.villageId == this.villageId &&
          other.buildingId == this.buildingId &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.addressText == this.addressText &&
          other.buildingName == this.buildingName &&
          other.roomNo == this.roomNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.visitedAt == this.visitedAt);
}

class HouseRecordsCompanion extends UpdateCompanion<HouseRecord> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> status;
  final Value<String?> villageId;
  final Value<String?> buildingId;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> addressText;
  final Value<String?> buildingName;
  final Value<String?> roomNo;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int?> visitedAt;
  final Value<int> rowid;
  const HouseRecordsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.villageId = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.addressText = const Value.absent(),
    this.buildingName = const Value.absent(),
    this.roomNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.visitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseRecordsCompanion.insert({
    required String id,
    required String title,
    this.status = const Value.absent(),
    this.villageId = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.addressText = const Value.absent(),
    this.buildingName = const Value.absent(),
    this.roomNo = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.visitedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<HouseRecord> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? villageId,
    Expression<String>? buildingId,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? addressText,
    Expression<String>? buildingName,
    Expression<String>? roomNo,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? visitedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (villageId != null) 'village_id': villageId,
      if (buildingId != null) 'building_id': buildingId,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (addressText != null) 'address_text': addressText,
      if (buildingName != null) 'building_name': buildingName,
      if (roomNo != null) 'room_no': roomNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? status,
      Value<String?>? villageId,
      Value<String?>? buildingId,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? addressText,
      Value<String?>? buildingName,
      Value<String?>? roomNo,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int?>? visitedAt,
      Value<int>? rowid}) {
    return HouseRecordsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      villageId: villageId ?? this.villageId,
      buildingId: buildingId ?? this.buildingId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressText: addressText ?? this.addressText,
      buildingName: buildingName ?? this.buildingName,
      roomNo: roomNo ?? this.roomNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      visitedAt: visitedAt ?? this.visitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (villageId.present) {
      map['village_id'] = Variable<String>(villageId.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (addressText.present) {
      map['address_text'] = Variable<String>(addressText.value);
    }
    if (buildingName.present) {
      map['building_name'] = Variable<String>(buildingName.value);
    }
    if (roomNo.present) {
      map['room_no'] = Variable<String>(roomNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (visitedAt.present) {
      map['visited_at'] = Variable<int>(visitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseRecordsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('villageId: $villageId, ')
          ..write('buildingId: $buildingId, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('addressText: $addressText, ')
          ..write('buildingName: $buildingName, ')
          ..write('roomNo: $roomNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FeeInfosTable extends FeeInfos with TableInfo<$FeeInfosTable, FeeInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _rentMonthlyMeta =
      const VerificationMeta('rentMonthly');
  @override
  late final GeneratedColumn<int> rentMonthly = GeneratedColumn<int>(
      'rent_monthly', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _depositMeta =
      const VerificationMeta('deposit');
  @override
  late final GeneratedColumn<int> deposit = GeneratedColumn<int>(
      'deposit', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _paymentCycleMeta =
      const VerificationMeta('paymentCycle');
  @override
  late final GeneratedColumn<String> paymentCycle = GeneratedColumn<String>(
      'payment_cycle', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _managementFeeMeta =
      const VerificationMeta('managementFee');
  @override
  late final GeneratedColumn<int> managementFee = GeneratedColumn<int>(
      'management_fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _internetFeeMeta =
      const VerificationMeta('internetFee');
  @override
  late final GeneratedColumn<int> internetFee = GeneratedColumn<int>(
      'internet_fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _waterUnitPriceMeta =
      const VerificationMeta('waterUnitPrice');
  @override
  late final GeneratedColumn<double> waterUnitPrice = GeneratedColumn<double>(
      'water_unit_price', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _electricityUnitPriceMeta =
      const VerificationMeta('electricityUnitPrice');
  @override
  late final GeneratedColumn<double> electricityUnitPrice =
      GeneratedColumn<double>('electricity_unit_price', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _gasFeeMeta = const VerificationMeta('gasFee');
  @override
  late final GeneratedColumn<int> gasFee = GeneratedColumn<int>(
      'gas_fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _otherFeeMeta =
      const VerificationMeta('otherFee');
  @override
  late final GeneratedColumn<int> otherFee = GeneratedColumn<int>(
      'other_fee', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _estimatedTotalMonthlyMeta =
      const VerificationMeta('estimatedTotalMonthly');
  @override
  late final GeneratedColumn<int> estimatedTotalMonthly = GeneratedColumn<int>(
      'estimated_total_monthly', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        houseId,
        rentMonthly,
        deposit,
        paymentCycle,
        managementFee,
        internetFee,
        waterUnitPrice,
        electricityUnitPrice,
        gasFee,
        otherFee,
        estimatedTotalMonthly
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_info';
  @override
  VerificationContext validateIntegrity(Insertable<FeeInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('rent_monthly')) {
      context.handle(
          _rentMonthlyMeta,
          rentMonthly.isAcceptableOrUnknown(
              data['rent_monthly']!, _rentMonthlyMeta));
    }
    if (data.containsKey('deposit')) {
      context.handle(_depositMeta,
          deposit.isAcceptableOrUnknown(data['deposit']!, _depositMeta));
    }
    if (data.containsKey('payment_cycle')) {
      context.handle(
          _paymentCycleMeta,
          paymentCycle.isAcceptableOrUnknown(
              data['payment_cycle']!, _paymentCycleMeta));
    }
    if (data.containsKey('management_fee')) {
      context.handle(
          _managementFeeMeta,
          managementFee.isAcceptableOrUnknown(
              data['management_fee']!, _managementFeeMeta));
    }
    if (data.containsKey('internet_fee')) {
      context.handle(
          _internetFeeMeta,
          internetFee.isAcceptableOrUnknown(
              data['internet_fee']!, _internetFeeMeta));
    }
    if (data.containsKey('water_unit_price')) {
      context.handle(
          _waterUnitPriceMeta,
          waterUnitPrice.isAcceptableOrUnknown(
              data['water_unit_price']!, _waterUnitPriceMeta));
    }
    if (data.containsKey('electricity_unit_price')) {
      context.handle(
          _electricityUnitPriceMeta,
          electricityUnitPrice.isAcceptableOrUnknown(
              data['electricity_unit_price']!, _electricityUnitPriceMeta));
    }
    if (data.containsKey('gas_fee')) {
      context.handle(_gasFeeMeta,
          gasFee.isAcceptableOrUnknown(data['gas_fee']!, _gasFeeMeta));
    }
    if (data.containsKey('other_fee')) {
      context.handle(_otherFeeMeta,
          otherFee.isAcceptableOrUnknown(data['other_fee']!, _otherFeeMeta));
    }
    if (data.containsKey('estimated_total_monthly')) {
      context.handle(
          _estimatedTotalMonthlyMeta,
          estimatedTotalMonthly.isAcceptableOrUnknown(
              data['estimated_total_monthly']!, _estimatedTotalMonthlyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  FeeInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeInfo(
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      rentMonthly: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rent_monthly']),
      deposit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deposit']),
      paymentCycle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_cycle']),
      managementFee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}management_fee']),
      internetFee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}internet_fee']),
      waterUnitPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}water_unit_price']),
      electricityUnitPrice: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}electricity_unit_price']),
      gasFee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}gas_fee']),
      otherFee: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}other_fee']),
      estimatedTotalMonthly: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}estimated_total_monthly']),
    );
  }

  @override
  $FeeInfosTable createAlias(String alias) {
    return $FeeInfosTable(attachedDatabase, alias);
  }
}

class FeeInfo extends DataClass implements Insertable<FeeInfo> {
  final String houseId;

  /// 月租（元/月）。
  final int? rentMonthly;

  /// 押金（元）。
  final int? deposit;

  /// 付款周期（押一付一等）。
  final String? paymentCycle;

  /// 管理费（元/月）。
  final int? managementFee;

  /// 网费（元/月）。
  final int? internetFee;

  /// 水费单价（元/吨）；缺失触发保守估值（F2）。
  final double? waterUnitPrice;

  /// 电费单价（元/度）；缺失触发保守估值（F2）。
  final double? electricityUnitPrice;

  /// 燃气费（元/月）。
  final int? gasFee;

  /// 其他固定费用（元/月）。
  final int? otherFee;

  /// 预估月总成本（元/月）：由引擎计算，含缺失补偿（F2）。
  final int? estimatedTotalMonthly;
  const FeeInfo(
      {required this.houseId,
      this.rentMonthly,
      this.deposit,
      this.paymentCycle,
      this.managementFee,
      this.internetFee,
      this.waterUnitPrice,
      this.electricityUnitPrice,
      this.gasFee,
      this.otherFee,
      this.estimatedTotalMonthly});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    if (!nullToAbsent || rentMonthly != null) {
      map['rent_monthly'] = Variable<int>(rentMonthly);
    }
    if (!nullToAbsent || deposit != null) {
      map['deposit'] = Variable<int>(deposit);
    }
    if (!nullToAbsent || paymentCycle != null) {
      map['payment_cycle'] = Variable<String>(paymentCycle);
    }
    if (!nullToAbsent || managementFee != null) {
      map['management_fee'] = Variable<int>(managementFee);
    }
    if (!nullToAbsent || internetFee != null) {
      map['internet_fee'] = Variable<int>(internetFee);
    }
    if (!nullToAbsent || waterUnitPrice != null) {
      map['water_unit_price'] = Variable<double>(waterUnitPrice);
    }
    if (!nullToAbsent || electricityUnitPrice != null) {
      map['electricity_unit_price'] = Variable<double>(electricityUnitPrice);
    }
    if (!nullToAbsent || gasFee != null) {
      map['gas_fee'] = Variable<int>(gasFee);
    }
    if (!nullToAbsent || otherFee != null) {
      map['other_fee'] = Variable<int>(otherFee);
    }
    if (!nullToAbsent || estimatedTotalMonthly != null) {
      map['estimated_total_monthly'] = Variable<int>(estimatedTotalMonthly);
    }
    return map;
  }

  FeeInfosCompanion toCompanion(bool nullToAbsent) {
    return FeeInfosCompanion(
      houseId: Value(houseId),
      rentMonthly: rentMonthly == null && nullToAbsent
          ? const Value.absent()
          : Value(rentMonthly),
      deposit: deposit == null && nullToAbsent
          ? const Value.absent()
          : Value(deposit),
      paymentCycle: paymentCycle == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentCycle),
      managementFee: managementFee == null && nullToAbsent
          ? const Value.absent()
          : Value(managementFee),
      internetFee: internetFee == null && nullToAbsent
          ? const Value.absent()
          : Value(internetFee),
      waterUnitPrice: waterUnitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(waterUnitPrice),
      electricityUnitPrice: electricityUnitPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(electricityUnitPrice),
      gasFee:
          gasFee == null && nullToAbsent ? const Value.absent() : Value(gasFee),
      otherFee: otherFee == null && nullToAbsent
          ? const Value.absent()
          : Value(otherFee),
      estimatedTotalMonthly: estimatedTotalMonthly == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedTotalMonthly),
    );
  }

  factory FeeInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeInfo(
      houseId: serializer.fromJson<String>(json['houseId']),
      rentMonthly: serializer.fromJson<int?>(json['rentMonthly']),
      deposit: serializer.fromJson<int?>(json['deposit']),
      paymentCycle: serializer.fromJson<String?>(json['paymentCycle']),
      managementFee: serializer.fromJson<int?>(json['managementFee']),
      internetFee: serializer.fromJson<int?>(json['internetFee']),
      waterUnitPrice: serializer.fromJson<double?>(json['waterUnitPrice']),
      electricityUnitPrice:
          serializer.fromJson<double?>(json['electricityUnitPrice']),
      gasFee: serializer.fromJson<int?>(json['gasFee']),
      otherFee: serializer.fromJson<int?>(json['otherFee']),
      estimatedTotalMonthly:
          serializer.fromJson<int?>(json['estimatedTotalMonthly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'rentMonthly': serializer.toJson<int?>(rentMonthly),
      'deposit': serializer.toJson<int?>(deposit),
      'paymentCycle': serializer.toJson<String?>(paymentCycle),
      'managementFee': serializer.toJson<int?>(managementFee),
      'internetFee': serializer.toJson<int?>(internetFee),
      'waterUnitPrice': serializer.toJson<double?>(waterUnitPrice),
      'electricityUnitPrice': serializer.toJson<double?>(electricityUnitPrice),
      'gasFee': serializer.toJson<int?>(gasFee),
      'otherFee': serializer.toJson<int?>(otherFee),
      'estimatedTotalMonthly': serializer.toJson<int?>(estimatedTotalMonthly),
    };
  }

  FeeInfo copyWith(
          {String? houseId,
          Value<int?> rentMonthly = const Value.absent(),
          Value<int?> deposit = const Value.absent(),
          Value<String?> paymentCycle = const Value.absent(),
          Value<int?> managementFee = const Value.absent(),
          Value<int?> internetFee = const Value.absent(),
          Value<double?> waterUnitPrice = const Value.absent(),
          Value<double?> electricityUnitPrice = const Value.absent(),
          Value<int?> gasFee = const Value.absent(),
          Value<int?> otherFee = const Value.absent(),
          Value<int?> estimatedTotalMonthly = const Value.absent()}) =>
      FeeInfo(
        houseId: houseId ?? this.houseId,
        rentMonthly: rentMonthly.present ? rentMonthly.value : this.rentMonthly,
        deposit: deposit.present ? deposit.value : this.deposit,
        paymentCycle:
            paymentCycle.present ? paymentCycle.value : this.paymentCycle,
        managementFee:
            managementFee.present ? managementFee.value : this.managementFee,
        internetFee: internetFee.present ? internetFee.value : this.internetFee,
        waterUnitPrice:
            waterUnitPrice.present ? waterUnitPrice.value : this.waterUnitPrice,
        electricityUnitPrice: electricityUnitPrice.present
            ? electricityUnitPrice.value
            : this.electricityUnitPrice,
        gasFee: gasFee.present ? gasFee.value : this.gasFee,
        otherFee: otherFee.present ? otherFee.value : this.otherFee,
        estimatedTotalMonthly: estimatedTotalMonthly.present
            ? estimatedTotalMonthly.value
            : this.estimatedTotalMonthly,
      );
  FeeInfo copyWithCompanion(FeeInfosCompanion data) {
    return FeeInfo(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      rentMonthly:
          data.rentMonthly.present ? data.rentMonthly.value : this.rentMonthly,
      deposit: data.deposit.present ? data.deposit.value : this.deposit,
      paymentCycle: data.paymentCycle.present
          ? data.paymentCycle.value
          : this.paymentCycle,
      managementFee: data.managementFee.present
          ? data.managementFee.value
          : this.managementFee,
      internetFee:
          data.internetFee.present ? data.internetFee.value : this.internetFee,
      waterUnitPrice: data.waterUnitPrice.present
          ? data.waterUnitPrice.value
          : this.waterUnitPrice,
      electricityUnitPrice: data.electricityUnitPrice.present
          ? data.electricityUnitPrice.value
          : this.electricityUnitPrice,
      gasFee: data.gasFee.present ? data.gasFee.value : this.gasFee,
      otherFee: data.otherFee.present ? data.otherFee.value : this.otherFee,
      estimatedTotalMonthly: data.estimatedTotalMonthly.present
          ? data.estimatedTotalMonthly.value
          : this.estimatedTotalMonthly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeInfo(')
          ..write('houseId: $houseId, ')
          ..write('rentMonthly: $rentMonthly, ')
          ..write('deposit: $deposit, ')
          ..write('paymentCycle: $paymentCycle, ')
          ..write('managementFee: $managementFee, ')
          ..write('internetFee: $internetFee, ')
          ..write('waterUnitPrice: $waterUnitPrice, ')
          ..write('electricityUnitPrice: $electricityUnitPrice, ')
          ..write('gasFee: $gasFee, ')
          ..write('otherFee: $otherFee, ')
          ..write('estimatedTotalMonthly: $estimatedTotalMonthly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      houseId,
      rentMonthly,
      deposit,
      paymentCycle,
      managementFee,
      internetFee,
      waterUnitPrice,
      electricityUnitPrice,
      gasFee,
      otherFee,
      estimatedTotalMonthly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeInfo &&
          other.houseId == this.houseId &&
          other.rentMonthly == this.rentMonthly &&
          other.deposit == this.deposit &&
          other.paymentCycle == this.paymentCycle &&
          other.managementFee == this.managementFee &&
          other.internetFee == this.internetFee &&
          other.waterUnitPrice == this.waterUnitPrice &&
          other.electricityUnitPrice == this.electricityUnitPrice &&
          other.gasFee == this.gasFee &&
          other.otherFee == this.otherFee &&
          other.estimatedTotalMonthly == this.estimatedTotalMonthly);
}

class FeeInfosCompanion extends UpdateCompanion<FeeInfo> {
  final Value<String> houseId;
  final Value<int?> rentMonthly;
  final Value<int?> deposit;
  final Value<String?> paymentCycle;
  final Value<int?> managementFee;
  final Value<int?> internetFee;
  final Value<double?> waterUnitPrice;
  final Value<double?> electricityUnitPrice;
  final Value<int?> gasFee;
  final Value<int?> otherFee;
  final Value<int?> estimatedTotalMonthly;
  final Value<int> rowid;
  const FeeInfosCompanion({
    this.houseId = const Value.absent(),
    this.rentMonthly = const Value.absent(),
    this.deposit = const Value.absent(),
    this.paymentCycle = const Value.absent(),
    this.managementFee = const Value.absent(),
    this.internetFee = const Value.absent(),
    this.waterUnitPrice = const Value.absent(),
    this.electricityUnitPrice = const Value.absent(),
    this.gasFee = const Value.absent(),
    this.otherFee = const Value.absent(),
    this.estimatedTotalMonthly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeeInfosCompanion.insert({
    required String houseId,
    this.rentMonthly = const Value.absent(),
    this.deposit = const Value.absent(),
    this.paymentCycle = const Value.absent(),
    this.managementFee = const Value.absent(),
    this.internetFee = const Value.absent(),
    this.waterUnitPrice = const Value.absent(),
    this.electricityUnitPrice = const Value.absent(),
    this.gasFee = const Value.absent(),
    this.otherFee = const Value.absent(),
    this.estimatedTotalMonthly = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId);
  static Insertable<FeeInfo> custom({
    Expression<String>? houseId,
    Expression<int>? rentMonthly,
    Expression<int>? deposit,
    Expression<String>? paymentCycle,
    Expression<int>? managementFee,
    Expression<int>? internetFee,
    Expression<double>? waterUnitPrice,
    Expression<double>? electricityUnitPrice,
    Expression<int>? gasFee,
    Expression<int>? otherFee,
    Expression<int>? estimatedTotalMonthly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (rentMonthly != null) 'rent_monthly': rentMonthly,
      if (deposit != null) 'deposit': deposit,
      if (paymentCycle != null) 'payment_cycle': paymentCycle,
      if (managementFee != null) 'management_fee': managementFee,
      if (internetFee != null) 'internet_fee': internetFee,
      if (waterUnitPrice != null) 'water_unit_price': waterUnitPrice,
      if (electricityUnitPrice != null)
        'electricity_unit_price': electricityUnitPrice,
      if (gasFee != null) 'gas_fee': gasFee,
      if (otherFee != null) 'other_fee': otherFee,
      if (estimatedTotalMonthly != null)
        'estimated_total_monthly': estimatedTotalMonthly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeeInfosCompanion copyWith(
      {Value<String>? houseId,
      Value<int?>? rentMonthly,
      Value<int?>? deposit,
      Value<String?>? paymentCycle,
      Value<int?>? managementFee,
      Value<int?>? internetFee,
      Value<double?>? waterUnitPrice,
      Value<double?>? electricityUnitPrice,
      Value<int?>? gasFee,
      Value<int?>? otherFee,
      Value<int?>? estimatedTotalMonthly,
      Value<int>? rowid}) {
    return FeeInfosCompanion(
      houseId: houseId ?? this.houseId,
      rentMonthly: rentMonthly ?? this.rentMonthly,
      deposit: deposit ?? this.deposit,
      paymentCycle: paymentCycle ?? this.paymentCycle,
      managementFee: managementFee ?? this.managementFee,
      internetFee: internetFee ?? this.internetFee,
      waterUnitPrice: waterUnitPrice ?? this.waterUnitPrice,
      electricityUnitPrice: electricityUnitPrice ?? this.electricityUnitPrice,
      gasFee: gasFee ?? this.gasFee,
      otherFee: otherFee ?? this.otherFee,
      estimatedTotalMonthly:
          estimatedTotalMonthly ?? this.estimatedTotalMonthly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (rentMonthly.present) {
      map['rent_monthly'] = Variable<int>(rentMonthly.value);
    }
    if (deposit.present) {
      map['deposit'] = Variable<int>(deposit.value);
    }
    if (paymentCycle.present) {
      map['payment_cycle'] = Variable<String>(paymentCycle.value);
    }
    if (managementFee.present) {
      map['management_fee'] = Variable<int>(managementFee.value);
    }
    if (internetFee.present) {
      map['internet_fee'] = Variable<int>(internetFee.value);
    }
    if (waterUnitPrice.present) {
      map['water_unit_price'] = Variable<double>(waterUnitPrice.value);
    }
    if (electricityUnitPrice.present) {
      map['electricity_unit_price'] =
          Variable<double>(electricityUnitPrice.value);
    }
    if (gasFee.present) {
      map['gas_fee'] = Variable<int>(gasFee.value);
    }
    if (otherFee.present) {
      map['other_fee'] = Variable<int>(otherFee.value);
    }
    if (estimatedTotalMonthly.present) {
      map['estimated_total_monthly'] =
          Variable<int>(estimatedTotalMonthly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeInfosCompanion(')
          ..write('houseId: $houseId, ')
          ..write('rentMonthly: $rentMonthly, ')
          ..write('deposit: $deposit, ')
          ..write('paymentCycle: $paymentCycle, ')
          ..write('managementFee: $managementFee, ')
          ..write('internetFee: $internetFee, ')
          ..write('waterUnitPrice: $waterUnitPrice, ')
          ..write('electricityUnitPrice: $electricityUnitPrice, ')
          ..write('gasFee: $gasFee, ')
          ..write('otherFee: $otherFee, ')
          ..write('estimatedTotalMonthly: $estimatedTotalMonthly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomInfosTable extends RoomInfos
    with TableInfo<$RoomInfosTable, RoomInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _layoutMeta = const VerificationMeta('layout');
  @override
  late final GeneratedColumn<String> layout = GeneratedColumn<String>(
      'layout', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<double> area = GeneratedColumn<double>(
      'area', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _floorMeta = const VerificationMeta('floor');
  @override
  late final GeneratedColumn<int> floor = GeneratedColumn<int>(
      'floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalFloorMeta =
      const VerificationMeta('totalFloor');
  @override
  late final GeneratedColumn<int> totalFloor = GeneratedColumn<int>(
      'total_floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _hasElevatorMeta =
      const VerificationMeta('hasElevator');
  @override
  late final GeneratedColumn<bool> hasElevator = GeneratedColumn<bool>(
      'has_elevator', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_elevator" IN (0, 1))'));
  static const VerificationMeta _orientationMeta =
      const VerificationMeta('orientation');
  @override
  late final GeneratedColumn<String> orientation = GeneratedColumn<String>(
      'orientation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hasPrivateBathroomMeta =
      const VerificationMeta('hasPrivateBathroom');
  @override
  late final GeneratedColumn<bool> hasPrivateBathroom = GeneratedColumn<bool>(
      'has_private_bathroom', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_private_bathroom" IN (0, 1))'));
  static const VerificationMeta _hasKitchenMeta =
      const VerificationMeta('hasKitchen');
  @override
  late final GeneratedColumn<bool> hasKitchen = GeneratedColumn<bool>(
      'has_kitchen', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("has_kitchen" IN (0, 1))'));
  static const VerificationMeta _canCookMeta =
      const VerificationMeta('canCook');
  @override
  late final GeneratedColumn<bool> canCook = GeneratedColumn<bool>(
      'can_cook', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("can_cook" IN (0, 1))'));
  static const VerificationMeta _canPetMeta = const VerificationMeta('canPet');
  @override
  late final GeneratedColumn<bool> canPet = GeneratedColumn<bool>(
      'can_pet', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("can_pet" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [
        houseId,
        layout,
        area,
        floor,
        totalFloor,
        hasElevator,
        orientation,
        hasPrivateBathroom,
        hasKitchen,
        canCook,
        canPet
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'room_info';
  @override
  VerificationContext validateIntegrity(Insertable<RoomInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('layout')) {
      context.handle(_layoutMeta,
          layout.isAcceptableOrUnknown(data['layout']!, _layoutMeta));
    }
    if (data.containsKey('area')) {
      context.handle(
          _areaMeta, area.isAcceptableOrUnknown(data['area']!, _areaMeta));
    }
    if (data.containsKey('floor')) {
      context.handle(
          _floorMeta, floor.isAcceptableOrUnknown(data['floor']!, _floorMeta));
    }
    if (data.containsKey('total_floor')) {
      context.handle(
          _totalFloorMeta,
          totalFloor.isAcceptableOrUnknown(
              data['total_floor']!, _totalFloorMeta));
    }
    if (data.containsKey('has_elevator')) {
      context.handle(
          _hasElevatorMeta,
          hasElevator.isAcceptableOrUnknown(
              data['has_elevator']!, _hasElevatorMeta));
    }
    if (data.containsKey('orientation')) {
      context.handle(
          _orientationMeta,
          orientation.isAcceptableOrUnknown(
              data['orientation']!, _orientationMeta));
    }
    if (data.containsKey('has_private_bathroom')) {
      context.handle(
          _hasPrivateBathroomMeta,
          hasPrivateBathroom.isAcceptableOrUnknown(
              data['has_private_bathroom']!, _hasPrivateBathroomMeta));
    }
    if (data.containsKey('has_kitchen')) {
      context.handle(
          _hasKitchenMeta,
          hasKitchen.isAcceptableOrUnknown(
              data['has_kitchen']!, _hasKitchenMeta));
    }
    if (data.containsKey('can_cook')) {
      context.handle(_canCookMeta,
          canCook.isAcceptableOrUnknown(data['can_cook']!, _canCookMeta));
    }
    if (data.containsKey('can_pet')) {
      context.handle(_canPetMeta,
          canPet.isAcceptableOrUnknown(data['can_pet']!, _canPetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  RoomInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoomInfo(
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      layout: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}layout']),
      area: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area']),
      floor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}floor']),
      totalFloor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_floor']),
      hasElevator: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_elevator']),
      orientation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}orientation']),
      hasPrivateBathroom: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}has_private_bathroom']),
      hasKitchen: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}has_kitchen']),
      canCook: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_cook']),
      canPet: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}can_pet']),
    );
  }

  @override
  $RoomInfosTable createAlias(String alias) {
    return $RoomInfosTable(attachedDatabase, alias);
  }
}

class RoomInfo extends DataClass implements Insertable<RoomInfo> {
  final String houseId;

  /// 房型（单间/一房一厅等）。
  final String? layout;

  /// 面积（平米）。
  final double? area;

  /// 所在楼层。
  final int? floor;

  /// 楼栋总层数。
  final int? totalFloor;

  /// 电梯（硬筛可选条件）。
  final bool? hasElevator;

  /// 朝向。
  final String? orientation;

  /// 独卫（硬筛可选条件）。
  final bool? hasPrivateBathroom;

  /// 厨房（硬筛可选条件）。
  final bool? hasKitchen;

  /// 能否做饭（硬筛可选条件）。
  final bool? canCook;

  /// 能否养宠（硬筛可选条件）。
  final bool? canPet;
  const RoomInfo(
      {required this.houseId,
      this.layout,
      this.area,
      this.floor,
      this.totalFloor,
      this.hasElevator,
      this.orientation,
      this.hasPrivateBathroom,
      this.hasKitchen,
      this.canCook,
      this.canPet});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    if (!nullToAbsent || layout != null) {
      map['layout'] = Variable<String>(layout);
    }
    if (!nullToAbsent || area != null) {
      map['area'] = Variable<double>(area);
    }
    if (!nullToAbsent || floor != null) {
      map['floor'] = Variable<int>(floor);
    }
    if (!nullToAbsent || totalFloor != null) {
      map['total_floor'] = Variable<int>(totalFloor);
    }
    if (!nullToAbsent || hasElevator != null) {
      map['has_elevator'] = Variable<bool>(hasElevator);
    }
    if (!nullToAbsent || orientation != null) {
      map['orientation'] = Variable<String>(orientation);
    }
    if (!nullToAbsent || hasPrivateBathroom != null) {
      map['has_private_bathroom'] = Variable<bool>(hasPrivateBathroom);
    }
    if (!nullToAbsent || hasKitchen != null) {
      map['has_kitchen'] = Variable<bool>(hasKitchen);
    }
    if (!nullToAbsent || canCook != null) {
      map['can_cook'] = Variable<bool>(canCook);
    }
    if (!nullToAbsent || canPet != null) {
      map['can_pet'] = Variable<bool>(canPet);
    }
    return map;
  }

  RoomInfosCompanion toCompanion(bool nullToAbsent) {
    return RoomInfosCompanion(
      houseId: Value(houseId),
      layout:
          layout == null && nullToAbsent ? const Value.absent() : Value(layout),
      area: area == null && nullToAbsent ? const Value.absent() : Value(area),
      floor:
          floor == null && nullToAbsent ? const Value.absent() : Value(floor),
      totalFloor: totalFloor == null && nullToAbsent
          ? const Value.absent()
          : Value(totalFloor),
      hasElevator: hasElevator == null && nullToAbsent
          ? const Value.absent()
          : Value(hasElevator),
      orientation: orientation == null && nullToAbsent
          ? const Value.absent()
          : Value(orientation),
      hasPrivateBathroom: hasPrivateBathroom == null && nullToAbsent
          ? const Value.absent()
          : Value(hasPrivateBathroom),
      hasKitchen: hasKitchen == null && nullToAbsent
          ? const Value.absent()
          : Value(hasKitchen),
      canCook: canCook == null && nullToAbsent
          ? const Value.absent()
          : Value(canCook),
      canPet:
          canPet == null && nullToAbsent ? const Value.absent() : Value(canPet),
    );
  }

  factory RoomInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoomInfo(
      houseId: serializer.fromJson<String>(json['houseId']),
      layout: serializer.fromJson<String?>(json['layout']),
      area: serializer.fromJson<double?>(json['area']),
      floor: serializer.fromJson<int?>(json['floor']),
      totalFloor: serializer.fromJson<int?>(json['totalFloor']),
      hasElevator: serializer.fromJson<bool?>(json['hasElevator']),
      orientation: serializer.fromJson<String?>(json['orientation']),
      hasPrivateBathroom:
          serializer.fromJson<bool?>(json['hasPrivateBathroom']),
      hasKitchen: serializer.fromJson<bool?>(json['hasKitchen']),
      canCook: serializer.fromJson<bool?>(json['canCook']),
      canPet: serializer.fromJson<bool?>(json['canPet']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'layout': serializer.toJson<String?>(layout),
      'area': serializer.toJson<double?>(area),
      'floor': serializer.toJson<int?>(floor),
      'totalFloor': serializer.toJson<int?>(totalFloor),
      'hasElevator': serializer.toJson<bool?>(hasElevator),
      'orientation': serializer.toJson<String?>(orientation),
      'hasPrivateBathroom': serializer.toJson<bool?>(hasPrivateBathroom),
      'hasKitchen': serializer.toJson<bool?>(hasKitchen),
      'canCook': serializer.toJson<bool?>(canCook),
      'canPet': serializer.toJson<bool?>(canPet),
    };
  }

  RoomInfo copyWith(
          {String? houseId,
          Value<String?> layout = const Value.absent(),
          Value<double?> area = const Value.absent(),
          Value<int?> floor = const Value.absent(),
          Value<int?> totalFloor = const Value.absent(),
          Value<bool?> hasElevator = const Value.absent(),
          Value<String?> orientation = const Value.absent(),
          Value<bool?> hasPrivateBathroom = const Value.absent(),
          Value<bool?> hasKitchen = const Value.absent(),
          Value<bool?> canCook = const Value.absent(),
          Value<bool?> canPet = const Value.absent()}) =>
      RoomInfo(
        houseId: houseId ?? this.houseId,
        layout: layout.present ? layout.value : this.layout,
        area: area.present ? area.value : this.area,
        floor: floor.present ? floor.value : this.floor,
        totalFloor: totalFloor.present ? totalFloor.value : this.totalFloor,
        hasElevator: hasElevator.present ? hasElevator.value : this.hasElevator,
        orientation: orientation.present ? orientation.value : this.orientation,
        hasPrivateBathroom: hasPrivateBathroom.present
            ? hasPrivateBathroom.value
            : this.hasPrivateBathroom,
        hasKitchen: hasKitchen.present ? hasKitchen.value : this.hasKitchen,
        canCook: canCook.present ? canCook.value : this.canCook,
        canPet: canPet.present ? canPet.value : this.canPet,
      );
  RoomInfo copyWithCompanion(RoomInfosCompanion data) {
    return RoomInfo(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      layout: data.layout.present ? data.layout.value : this.layout,
      area: data.area.present ? data.area.value : this.area,
      floor: data.floor.present ? data.floor.value : this.floor,
      totalFloor:
          data.totalFloor.present ? data.totalFloor.value : this.totalFloor,
      hasElevator:
          data.hasElevator.present ? data.hasElevator.value : this.hasElevator,
      orientation:
          data.orientation.present ? data.orientation.value : this.orientation,
      hasPrivateBathroom: data.hasPrivateBathroom.present
          ? data.hasPrivateBathroom.value
          : this.hasPrivateBathroom,
      hasKitchen:
          data.hasKitchen.present ? data.hasKitchen.value : this.hasKitchen,
      canCook: data.canCook.present ? data.canCook.value : this.canCook,
      canPet: data.canPet.present ? data.canPet.value : this.canPet,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoomInfo(')
          ..write('houseId: $houseId, ')
          ..write('layout: $layout, ')
          ..write('area: $area, ')
          ..write('floor: $floor, ')
          ..write('totalFloor: $totalFloor, ')
          ..write('hasElevator: $hasElevator, ')
          ..write('orientation: $orientation, ')
          ..write('hasPrivateBathroom: $hasPrivateBathroom, ')
          ..write('hasKitchen: $hasKitchen, ')
          ..write('canCook: $canCook, ')
          ..write('canPet: $canPet')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      houseId,
      layout,
      area,
      floor,
      totalFloor,
      hasElevator,
      orientation,
      hasPrivateBathroom,
      hasKitchen,
      canCook,
      canPet);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoomInfo &&
          other.houseId == this.houseId &&
          other.layout == this.layout &&
          other.area == this.area &&
          other.floor == this.floor &&
          other.totalFloor == this.totalFloor &&
          other.hasElevator == this.hasElevator &&
          other.orientation == this.orientation &&
          other.hasPrivateBathroom == this.hasPrivateBathroom &&
          other.hasKitchen == this.hasKitchen &&
          other.canCook == this.canCook &&
          other.canPet == this.canPet);
}

class RoomInfosCompanion extends UpdateCompanion<RoomInfo> {
  final Value<String> houseId;
  final Value<String?> layout;
  final Value<double?> area;
  final Value<int?> floor;
  final Value<int?> totalFloor;
  final Value<bool?> hasElevator;
  final Value<String?> orientation;
  final Value<bool?> hasPrivateBathroom;
  final Value<bool?> hasKitchen;
  final Value<bool?> canCook;
  final Value<bool?> canPet;
  final Value<int> rowid;
  const RoomInfosCompanion({
    this.houseId = const Value.absent(),
    this.layout = const Value.absent(),
    this.area = const Value.absent(),
    this.floor = const Value.absent(),
    this.totalFloor = const Value.absent(),
    this.hasElevator = const Value.absent(),
    this.orientation = const Value.absent(),
    this.hasPrivateBathroom = const Value.absent(),
    this.hasKitchen = const Value.absent(),
    this.canCook = const Value.absent(),
    this.canPet = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomInfosCompanion.insert({
    required String houseId,
    this.layout = const Value.absent(),
    this.area = const Value.absent(),
    this.floor = const Value.absent(),
    this.totalFloor = const Value.absent(),
    this.hasElevator = const Value.absent(),
    this.orientation = const Value.absent(),
    this.hasPrivateBathroom = const Value.absent(),
    this.hasKitchen = const Value.absent(),
    this.canCook = const Value.absent(),
    this.canPet = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId);
  static Insertable<RoomInfo> custom({
    Expression<String>? houseId,
    Expression<String>? layout,
    Expression<double>? area,
    Expression<int>? floor,
    Expression<int>? totalFloor,
    Expression<bool>? hasElevator,
    Expression<String>? orientation,
    Expression<bool>? hasPrivateBathroom,
    Expression<bool>? hasKitchen,
    Expression<bool>? canCook,
    Expression<bool>? canPet,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (layout != null) 'layout': layout,
      if (area != null) 'area': area,
      if (floor != null) 'floor': floor,
      if (totalFloor != null) 'total_floor': totalFloor,
      if (hasElevator != null) 'has_elevator': hasElevator,
      if (orientation != null) 'orientation': orientation,
      if (hasPrivateBathroom != null)
        'has_private_bathroom': hasPrivateBathroom,
      if (hasKitchen != null) 'has_kitchen': hasKitchen,
      if (canCook != null) 'can_cook': canCook,
      if (canPet != null) 'can_pet': canPet,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomInfosCompanion copyWith(
      {Value<String>? houseId,
      Value<String?>? layout,
      Value<double?>? area,
      Value<int?>? floor,
      Value<int?>? totalFloor,
      Value<bool?>? hasElevator,
      Value<String?>? orientation,
      Value<bool?>? hasPrivateBathroom,
      Value<bool?>? hasKitchen,
      Value<bool?>? canCook,
      Value<bool?>? canPet,
      Value<int>? rowid}) {
    return RoomInfosCompanion(
      houseId: houseId ?? this.houseId,
      layout: layout ?? this.layout,
      area: area ?? this.area,
      floor: floor ?? this.floor,
      totalFloor: totalFloor ?? this.totalFloor,
      hasElevator: hasElevator ?? this.hasElevator,
      orientation: orientation ?? this.orientation,
      hasPrivateBathroom: hasPrivateBathroom ?? this.hasPrivateBathroom,
      hasKitchen: hasKitchen ?? this.hasKitchen,
      canCook: canCook ?? this.canCook,
      canPet: canPet ?? this.canPet,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (layout.present) {
      map['layout'] = Variable<String>(layout.value);
    }
    if (area.present) {
      map['area'] = Variable<double>(area.value);
    }
    if (floor.present) {
      map['floor'] = Variable<int>(floor.value);
    }
    if (totalFloor.present) {
      map['total_floor'] = Variable<int>(totalFloor.value);
    }
    if (hasElevator.present) {
      map['has_elevator'] = Variable<bool>(hasElevator.value);
    }
    if (orientation.present) {
      map['orientation'] = Variable<String>(orientation.value);
    }
    if (hasPrivateBathroom.present) {
      map['has_private_bathroom'] = Variable<bool>(hasPrivateBathroom.value);
    }
    if (hasKitchen.present) {
      map['has_kitchen'] = Variable<bool>(hasKitchen.value);
    }
    if (canCook.present) {
      map['can_cook'] = Variable<bool>(canCook.value);
    }
    if (canPet.present) {
      map['can_pet'] = Variable<bool>(canPet.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomInfosCompanion(')
          ..write('houseId: $houseId, ')
          ..write('layout: $layout, ')
          ..write('area: $area, ')
          ..write('floor: $floor, ')
          ..write('totalFloor: $totalFloor, ')
          ..write('hasElevator: $hasElevator, ')
          ..write('orientation: $orientation, ')
          ..write('hasPrivateBathroom: $hasPrivateBathroom, ')
          ..write('hasKitchen: $hasKitchen, ')
          ..write('canCook: $canCook, ')
          ..write('canPet: $canPet, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactInfosTable extends ContactInfos
    with TableInfo<$ContactInfosTable, ContactInfo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactInfosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wechatMeta = const VerificationMeta('wechat');
  @override
  late final GeneratedColumn<String> wechat = GeneratedColumn<String>(
      'wechat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _identityVerifiedMeta =
      const VerificationMeta('identityVerified');
  @override
  late final GeneratedColumn<bool> identityVerified = GeneratedColumn<bool>(
      'identity_verified', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("identity_verified" IN (0, 1))'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [houseId, name, role, phone, wechat, identityVerified, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contact_info';
  @override
  VerificationContext validateIntegrity(Insertable<ContactInfo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('wechat')) {
      context.handle(_wechatMeta,
          wechat.isAcceptableOrUnknown(data['wechat']!, _wechatMeta));
    }
    if (data.containsKey('identity_verified')) {
      context.handle(
          _identityVerifiedMeta,
          identityVerified.isAcceptableOrUnknown(
              data['identity_verified']!, _identityVerifiedMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  ContactInfo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContactInfo(
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      wechat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wechat']),
      identityVerified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}identity_verified']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ContactInfosTable createAlias(String alias) {
    return $ContactInfosTable(attachedDatabase, alias);
  }
}

class ContactInfo extends DataClass implements Insertable<ContactInfo> {
  final String houseId;

  /// 称呼。
  final String? name;

  /// 角色（房东/管理员/中介/二房东/未知）。
  final String? role;

  /// 电话：敏感字段，本地加密（AES-256-GCM，F7）后存密文。
  final String? phone;

  /// 微信：敏感字段，本地加密后存密文。
  final String? wechat;

  /// 身份是否已核验（是否看过证件/授权）。
  final bool? identityVerified;

  /// 备注：用户标记敏感时加密。
  final String? note;
  const ContactInfo(
      {required this.houseId,
      this.name,
      this.role,
      this.phone,
      this.wechat,
      this.identityVerified,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(role);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || wechat != null) {
      map['wechat'] = Variable<String>(wechat);
    }
    if (!nullToAbsent || identityVerified != null) {
      map['identity_verified'] = Variable<bool>(identityVerified);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ContactInfosCompanion toCompanion(bool nullToAbsent) {
    return ContactInfosCompanion(
      houseId: Value(houseId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      wechat:
          wechat == null && nullToAbsent ? const Value.absent() : Value(wechat),
      identityVerified: identityVerified == null && nullToAbsent
          ? const Value.absent()
          : Value(identityVerified),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ContactInfo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContactInfo(
      houseId: serializer.fromJson<String>(json['houseId']),
      name: serializer.fromJson<String?>(json['name']),
      role: serializer.fromJson<String?>(json['role']),
      phone: serializer.fromJson<String?>(json['phone']),
      wechat: serializer.fromJson<String?>(json['wechat']),
      identityVerified: serializer.fromJson<bool?>(json['identityVerified']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'name': serializer.toJson<String?>(name),
      'role': serializer.toJson<String?>(role),
      'phone': serializer.toJson<String?>(phone),
      'wechat': serializer.toJson<String?>(wechat),
      'identityVerified': serializer.toJson<bool?>(identityVerified),
      'note': serializer.toJson<String?>(note),
    };
  }

  ContactInfo copyWith(
          {String? houseId,
          Value<String?> name = const Value.absent(),
          Value<String?> role = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> wechat = const Value.absent(),
          Value<bool?> identityVerified = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      ContactInfo(
        houseId: houseId ?? this.houseId,
        name: name.present ? name.value : this.name,
        role: role.present ? role.value : this.role,
        phone: phone.present ? phone.value : this.phone,
        wechat: wechat.present ? wechat.value : this.wechat,
        identityVerified: identityVerified.present
            ? identityVerified.value
            : this.identityVerified,
        note: note.present ? note.value : this.note,
      );
  ContactInfo copyWithCompanion(ContactInfosCompanion data) {
    return ContactInfo(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      phone: data.phone.present ? data.phone.value : this.phone,
      wechat: data.wechat.present ? data.wechat.value : this.wechat,
      identityVerified: data.identityVerified.present
          ? data.identityVerified.value
          : this.identityVerified,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContactInfo(')
          ..write('houseId: $houseId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('wechat: $wechat, ')
          ..write('identityVerified: $identityVerified, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(houseId, name, role, phone, wechat, identityVerified, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContactInfo &&
          other.houseId == this.houseId &&
          other.name == this.name &&
          other.role == this.role &&
          other.phone == this.phone &&
          other.wechat == this.wechat &&
          other.identityVerified == this.identityVerified &&
          other.note == this.note);
}

class ContactInfosCompanion extends UpdateCompanion<ContactInfo> {
  final Value<String> houseId;
  final Value<String?> name;
  final Value<String?> role;
  final Value<String?> phone;
  final Value<String?> wechat;
  final Value<bool?> identityVerified;
  final Value<String?> note;
  final Value<int> rowid;
  const ContactInfosCompanion({
    this.houseId = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.wechat = const Value.absent(),
    this.identityVerified = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactInfosCompanion.insert({
    required String houseId,
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.phone = const Value.absent(),
    this.wechat = const Value.absent(),
    this.identityVerified = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId);
  static Insertable<ContactInfo> custom({
    Expression<String>? houseId,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? phone,
    Expression<String>? wechat,
    Expression<bool>? identityVerified,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (phone != null) 'phone': phone,
      if (wechat != null) 'wechat': wechat,
      if (identityVerified != null) 'identity_verified': identityVerified,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactInfosCompanion copyWith(
      {Value<String>? houseId,
      Value<String?>? name,
      Value<String?>? role,
      Value<String?>? phone,
      Value<String?>? wechat,
      Value<bool?>? identityVerified,
      Value<String?>? note,
      Value<int>? rowid}) {
    return ContactInfosCompanion(
      houseId: houseId ?? this.houseId,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      wechat: wechat ?? this.wechat,
      identityVerified: identityVerified ?? this.identityVerified,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (wechat.present) {
      map['wechat'] = Variable<String>(wechat.value);
    }
    if (identityVerified.present) {
      map['identity_verified'] = Variable<bool>(identityVerified.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactInfosCompanion(')
          ..write('houseId: $houseId, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('phone: $phone, ')
          ..write('wechat: $wechat, ')
          ..write('identityVerified: $identityVerified, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
      'module', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, houseId, module, key, value, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_item';
  @override
  VerificationContext validateIntegrity(Insertable<ChecklistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('module')) {
      context.handle(_moduleMeta,
          module.isAcceptableOrUnknown(data['module']!, _moduleMeta));
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      module: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}module'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistItem extends DataClass implements Insertable<ChecklistItem> {
  /// UUID 主键。
  final String id;
  final String houseId;

  /// 模块：room/kitchen/building/contract/risk。
  final String module;

  /// 检查项编码（见 docs/rules/checklist-template.json）。
  final String key;

  /// 取值：good/ok/bad/not_seen（risk 模块用 hit/not_hit/not_seen）。
  final String? value;

  /// 备注。
  final String? note;
  const ChecklistItem(
      {required this.id,
      required this.houseId,
      required this.module,
      required this.key,
      this.value,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['house_id'] = Variable<String>(houseId);
    map['module'] = Variable<String>(module);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  ChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemsCompanion(
      id: Value(id),
      houseId: Value(houseId),
      module: Value(module),
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistItem(
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String>(json['houseId']),
      module: serializer.fromJson<String>(json['module']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String>(houseId),
      'module': serializer.toJson<String>(module),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'note': serializer.toJson<String?>(note),
    };
  }

  ChecklistItem copyWith(
          {String? id,
          String? houseId,
          String? module,
          String? key,
          Value<String?> value = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      ChecklistItem(
        id: id ?? this.id,
        houseId: houseId ?? this.houseId,
        module: module ?? this.module,
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
        note: note.present ? note.value : this.note,
      );
  ChecklistItem copyWithCompanion(ChecklistItemsCompanion data) {
    return ChecklistItem(
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      module: data.module.present ? data.module.value : this.module,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItem(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('module: $module, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, houseId, module, key, value, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistItem &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.module == this.module &&
          other.key == this.key &&
          other.value == this.value &&
          other.note == this.note);
}

class ChecklistItemsCompanion extends UpdateCompanion<ChecklistItem> {
  final Value<String> id;
  final Value<String> houseId;
  final Value<String> module;
  final Value<String> key;
  final Value<String?> value;
  final Value<String?> note;
  final Value<int> rowid;
  const ChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.module = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChecklistItemsCompanion.insert({
    required String id,
    required String houseId,
    required String module,
    required String key,
    this.value = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        houseId = Value(houseId),
        module = Value(module),
        key = Value(key);
  static Insertable<ChecklistItem> custom({
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? module,
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (module != null) 'module': module,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChecklistItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? houseId,
      Value<String>? module,
      Value<String>? key,
      Value<String?>? value,
      Value<String?>? note,
      Value<int>? rowid}) {
    return ChecklistItemsCompanion(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      module: module ?? this.module,
      key: key ?? this.key,
      value: value ?? this.value,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('module: $module, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RiskFlagsTable extends RiskFlags
    with TableInfo<$RiskFlagsTable, RiskFlag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RiskFlagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('user'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, houseId, key, severity, source, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'risk_flag';
  @override
  VerificationContext validateIntegrity(Insertable<RiskFlag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RiskFlag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RiskFlag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $RiskFlagsTable createAlias(String alias) {
    return $RiskFlagsTable(attachedDatabase, alias);
  }
}

class RiskFlag extends DataClass implements Insertable<RiskFlag> {
  /// UUID 主键。
  final String id;
  final String houseId;

  /// 风险编码（risk_second_landlord 等，见评分规则）。
  final String key;

  /// 严重度：warning（扣分）/ blocker（硬筛淘汰）。
  final String severity;

  /// 来源：user / system。
  final String source;

  /// 风险说明。
  final String? note;
  const RiskFlag(
      {required this.id,
      required this.houseId,
      required this.key,
      required this.severity,
      required this.source,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['house_id'] = Variable<String>(houseId);
    map['key'] = Variable<String>(key);
    map['severity'] = Variable<String>(severity);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  RiskFlagsCompanion toCompanion(bool nullToAbsent) {
    return RiskFlagsCompanion(
      id: Value(id),
      houseId: Value(houseId),
      key: Value(key),
      severity: Value(severity),
      source: Value(source),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory RiskFlag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RiskFlag(
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String>(json['houseId']),
      key: serializer.fromJson<String>(json['key']),
      severity: serializer.fromJson<String>(json['severity']),
      source: serializer.fromJson<String>(json['source']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String>(houseId),
      'key': serializer.toJson<String>(key),
      'severity': serializer.toJson<String>(severity),
      'source': serializer.toJson<String>(source),
      'note': serializer.toJson<String?>(note),
    };
  }

  RiskFlag copyWith(
          {String? id,
          String? houseId,
          String? key,
          String? severity,
          String? source,
          Value<String?> note = const Value.absent()}) =>
      RiskFlag(
        id: id ?? this.id,
        houseId: houseId ?? this.houseId,
        key: key ?? this.key,
        severity: severity ?? this.severity,
        source: source ?? this.source,
        note: note.present ? note.value : this.note,
      );
  RiskFlag copyWithCompanion(RiskFlagsCompanion data) {
    return RiskFlag(
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      key: data.key.present ? data.key.value : this.key,
      severity: data.severity.present ? data.severity.value : this.severity,
      source: data.source.present ? data.source.value : this.source,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RiskFlag(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('key: $key, ')
          ..write('severity: $severity, ')
          ..write('source: $source, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, houseId, key, severity, source, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RiskFlag &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.key == this.key &&
          other.severity == this.severity &&
          other.source == this.source &&
          other.note == this.note);
}

class RiskFlagsCompanion extends UpdateCompanion<RiskFlag> {
  final Value<String> id;
  final Value<String> houseId;
  final Value<String> key;
  final Value<String> severity;
  final Value<String> source;
  final Value<String?> note;
  final Value<int> rowid;
  const RiskFlagsCompanion({
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.key = const Value.absent(),
    this.severity = const Value.absent(),
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RiskFlagsCompanion.insert({
    required String id,
    required String houseId,
    required String key,
    required String severity,
    this.source = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        houseId = Value(houseId),
        key = Value(key),
        severity = Value(severity);
  static Insertable<RiskFlag> custom({
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? key,
    Expression<String>? severity,
    Expression<String>? source,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (key != null) 'key': key,
      if (severity != null) 'severity': severity,
      if (source != null) 'source': source,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RiskFlagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? houseId,
      Value<String>? key,
      Value<String>? severity,
      Value<String>? source,
      Value<String?>? note,
      Value<int>? rowid}) {
    return RiskFlagsCompanion(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      key: key ?? this.key,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RiskFlagsCompanion(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('key: $key, ')
          ..write('severity: $severity, ')
          ..write('source: $source, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotoAssetsTable extends PhotoAssets
    with TableInfo<$PhotoAssetsTable, PhotoAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotoAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _ownerTypeMeta =
      const VerificationMeta('ownerType');
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
      'owner_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('house'));
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localPathMeta =
      const VerificationMeta('localPath');
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
      'local_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
      'tag', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<int> takenAt = GeneratedColumn<int>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _exifRemovedMeta =
      const VerificationMeta('exifRemoved');
  @override
  late final GeneratedColumn<bool> exifRemoved = GeneratedColumn<bool>(
      'exif_removed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("exif_removed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _storageProviderMeta =
      const VerificationMeta('storageProvider');
  @override
  late final GeneratedColumn<String> storageProvider = GeneratedColumn<String>(
      'storage_provider', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _objectKeyMeta =
      const VerificationMeta('objectKey');
  @override
  late final GeneratedColumn<String> objectKey = GeneratedColumn<String>(
      'object_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        houseId,
        ownerType,
        ownerId,
        localPath,
        tag,
        takenAt,
        exifRemoved,
        storageProvider,
        remoteUrl,
        objectKey
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photo_asset';
  @override
  VerificationContext validateIntegrity(Insertable<PhotoAsset> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    }
    if (data.containsKey('owner_type')) {
      context.handle(_ownerTypeMeta,
          ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(_localPathMeta,
          localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta));
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
          _tagMeta, tag.isAcceptableOrUnknown(data['tag']!, _tagMeta));
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('exif_removed')) {
      context.handle(
          _exifRemovedMeta,
          exifRemoved.isAcceptableOrUnknown(
              data['exif_removed']!, _exifRemovedMeta));
    }
    if (data.containsKey('storage_provider')) {
      context.handle(
          _storageProviderMeta,
          storageProvider.isAcceptableOrUnknown(
              data['storage_provider']!, _storageProviderMeta));
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('object_key')) {
      context.handle(_objectKeyMeta,
          objectKey.isAcceptableOrUnknown(data['object_key']!, _objectKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoAsset(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id']),
      ownerType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_type'])!,
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id'])!,
      localPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_path'])!,
      tag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}taken_at'])!,
      exifRemoved: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}exif_removed'])!,
      storageProvider: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}storage_provider'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      objectKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}object_key']),
    );
  }

  @override
  $PhotoAssetsTable createAlias(String alias) {
    return $PhotoAssetsTable(attachedDatabase, alias);
  }
}

class PhotoAsset extends DataClass implements Insertable<PhotoAsset> {
  /// UUID 主键。
  final String id;
  final String? houseId;

  /// 归属类型：village/building/house。
  final String ownerType;

  /// 归属对象 id。house 照片与 houseId 相同；building/village 照片不写 houseId。
  final String ownerId;

  /// 端侧文件路径。
  final String localPath;

  /// 标签：sign/building/room/window/bathroom/meter/contract/damage。
  final String tag;

  /// 拍摄时间（毫秒时间戳）。
  final int takenAt;

  /// 导出时是否去 EXIF。
  final bool exifRemoved;

  /// 存储位置：local（仅端侧）/ oss（已直传对象存储）。默认 local（V1.1 云同步）。
  final String storageProvider;

  /// 远端公网可读地址；仅 storageProvider 为 oss 时非空。
  final String? remoteUrl;

  /// 远端对象键；仅 storageProvider 为 oss 时非空。
  final String? objectKey;
  const PhotoAsset(
      {required this.id,
      this.houseId,
      required this.ownerType,
      required this.ownerId,
      required this.localPath,
      required this.tag,
      required this.takenAt,
      required this.exifRemoved,
      required this.storageProvider,
      this.remoteUrl,
      this.objectKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || houseId != null) {
      map['house_id'] = Variable<String>(houseId);
    }
    map['owner_type'] = Variable<String>(ownerType);
    map['owner_id'] = Variable<String>(ownerId);
    map['local_path'] = Variable<String>(localPath);
    map['tag'] = Variable<String>(tag);
    map['taken_at'] = Variable<int>(takenAt);
    map['exif_removed'] = Variable<bool>(exifRemoved);
    map['storage_provider'] = Variable<String>(storageProvider);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || objectKey != null) {
      map['object_key'] = Variable<String>(objectKey);
    }
    return map;
  }

  PhotoAssetsCompanion toCompanion(bool nullToAbsent) {
    return PhotoAssetsCompanion(
      id: Value(id),
      houseId: houseId == null && nullToAbsent
          ? const Value.absent()
          : Value(houseId),
      ownerType: Value(ownerType),
      ownerId: Value(ownerId),
      localPath: Value(localPath),
      tag: Value(tag),
      takenAt: Value(takenAt),
      exifRemoved: Value(exifRemoved),
      storageProvider: Value(storageProvider),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      objectKey: objectKey == null && nullToAbsent
          ? const Value.absent()
          : Value(objectKey),
    );
  }

  factory PhotoAsset.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoAsset(
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String?>(json['houseId']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      tag: serializer.fromJson<String>(json['tag']),
      takenAt: serializer.fromJson<int>(json['takenAt']),
      exifRemoved: serializer.fromJson<bool>(json['exifRemoved']),
      storageProvider: serializer.fromJson<String>(json['storageProvider']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      objectKey: serializer.fromJson<String?>(json['objectKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String?>(houseId),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String>(ownerId),
      'localPath': serializer.toJson<String>(localPath),
      'tag': serializer.toJson<String>(tag),
      'takenAt': serializer.toJson<int>(takenAt),
      'exifRemoved': serializer.toJson<bool>(exifRemoved),
      'storageProvider': serializer.toJson<String>(storageProvider),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'objectKey': serializer.toJson<String?>(objectKey),
    };
  }

  PhotoAsset copyWith(
          {String? id,
          Value<String?> houseId = const Value.absent(),
          String? ownerType,
          String? ownerId,
          String? localPath,
          String? tag,
          int? takenAt,
          bool? exifRemoved,
          String? storageProvider,
          Value<String?> remoteUrl = const Value.absent(),
          Value<String?> objectKey = const Value.absent()}) =>
      PhotoAsset(
        id: id ?? this.id,
        houseId: houseId.present ? houseId.value : this.houseId,
        ownerType: ownerType ?? this.ownerType,
        ownerId: ownerId ?? this.ownerId,
        localPath: localPath ?? this.localPath,
        tag: tag ?? this.tag,
        takenAt: takenAt ?? this.takenAt,
        exifRemoved: exifRemoved ?? this.exifRemoved,
        storageProvider: storageProvider ?? this.storageProvider,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        objectKey: objectKey.present ? objectKey.value : this.objectKey,
      );
  PhotoAsset copyWithCompanion(PhotoAssetsCompanion data) {
    return PhotoAsset(
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      tag: data.tag.present ? data.tag.value : this.tag,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      exifRemoved:
          data.exifRemoved.present ? data.exifRemoved.value : this.exifRemoved,
      storageProvider: data.storageProvider.present
          ? data.storageProvider.value
          : this.storageProvider,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      objectKey: data.objectKey.present ? data.objectKey.value : this.objectKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoAsset(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localPath: $localPath, ')
          ..write('tag: $tag, ')
          ..write('takenAt: $takenAt, ')
          ..write('exifRemoved: $exifRemoved, ')
          ..write('storageProvider: $storageProvider, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('objectKey: $objectKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, houseId, ownerType, ownerId, localPath,
      tag, takenAt, exifRemoved, storageProvider, remoteUrl, objectKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoAsset &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.localPath == this.localPath &&
          other.tag == this.tag &&
          other.takenAt == this.takenAt &&
          other.exifRemoved == this.exifRemoved &&
          other.storageProvider == this.storageProvider &&
          other.remoteUrl == this.remoteUrl &&
          other.objectKey == this.objectKey);
}

class PhotoAssetsCompanion extends UpdateCompanion<PhotoAsset> {
  final Value<String> id;
  final Value<String?> houseId;
  final Value<String> ownerType;
  final Value<String> ownerId;
  final Value<String> localPath;
  final Value<String> tag;
  final Value<int> takenAt;
  final Value<bool> exifRemoved;
  final Value<String> storageProvider;
  final Value<String?> remoteUrl;
  final Value<String?> objectKey;
  final Value<int> rowid;
  const PhotoAssetsCompanion({
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.tag = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.exifRemoved = const Value.absent(),
    this.storageProvider = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotoAssetsCompanion.insert({
    required String id,
    this.houseId = const Value.absent(),
    this.ownerType = const Value.absent(),
    required String ownerId,
    required String localPath,
    required String tag,
    required int takenAt,
    this.exifRemoved = const Value.absent(),
    this.storageProvider = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.objectKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        ownerId = Value(ownerId),
        localPath = Value(localPath),
        tag = Value(tag),
        takenAt = Value(takenAt);
  static Insertable<PhotoAsset> custom({
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? localPath,
    Expression<String>? tag,
    Expression<int>? takenAt,
    Expression<bool>? exifRemoved,
    Expression<String>? storageProvider,
    Expression<String>? remoteUrl,
    Expression<String>? objectKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (localPath != null) 'local_path': localPath,
      if (tag != null) 'tag': tag,
      if (takenAt != null) 'taken_at': takenAt,
      if (exifRemoved != null) 'exif_removed': exifRemoved,
      if (storageProvider != null) 'storage_provider': storageProvider,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (objectKey != null) 'object_key': objectKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotoAssetsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? houseId,
      Value<String>? ownerType,
      Value<String>? ownerId,
      Value<String>? localPath,
      Value<String>? tag,
      Value<int>? takenAt,
      Value<bool>? exifRemoved,
      Value<String>? storageProvider,
      Value<String?>? remoteUrl,
      Value<String?>? objectKey,
      Value<int>? rowid}) {
    return PhotoAssetsCompanion(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      localPath: localPath ?? this.localPath,
      tag: tag ?? this.tag,
      takenAt: takenAt ?? this.takenAt,
      exifRemoved: exifRemoved ?? this.exifRemoved,
      storageProvider: storageProvider ?? this.storageProvider,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      objectKey: objectKey ?? this.objectKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<int>(takenAt.value);
    }
    if (exifRemoved.present) {
      map['exif_removed'] = Variable<bool>(exifRemoved.value);
    }
    if (storageProvider.present) {
      map['storage_provider'] = Variable<String>(storageProvider.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (objectKey.present) {
      map['object_key'] = Variable<String>(objectKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotoAssetsCompanion(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localPath: $localPath, ')
          ..write('tag: $tag, ')
          ..write('takenAt: $takenAt, ')
          ..write('exifRemoved: $exifRemoved, ')
          ..write('storageProvider: $storageProvider, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('objectKey: $objectKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MapSnapshotsTable extends MapSnapshots
    with TableInfo<$MapSnapshotsTable, MapSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MapSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('amap'));
  static const VerificationMeta _commuteJsonMeta =
      const VerificationMeta('commuteJson');
  @override
  late final GeneratedColumn<String> commuteJson = GeneratedColumn<String>(
      'commute_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _poiSummaryJsonMeta =
      const VerificationMeta('poiSummaryJson');
  @override
  late final GeneratedColumn<String> poiSummaryJson = GeneratedColumn<String>(
      'poi_summary_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userCorrectionJsonMeta =
      const VerificationMeta('userCorrectionJson');
  @override
  late final GeneratedColumn<String> userCorrectionJson =
      GeneratedColumn<String>('user_correction_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
      'fetched_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        houseId,
        provider,
        commuteJson,
        poiSummaryJson,
        userCorrectionJson,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'map_snapshot';
  @override
  VerificationContext validateIntegrity(Insertable<MapSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    }
    if (data.containsKey('commute_json')) {
      context.handle(
          _commuteJsonMeta,
          commuteJson.isAcceptableOrUnknown(
              data['commute_json']!, _commuteJsonMeta));
    }
    if (data.containsKey('poi_summary_json')) {
      context.handle(
          _poiSummaryJsonMeta,
          poiSummaryJson.isAcceptableOrUnknown(
              data['poi_summary_json']!, _poiSummaryJsonMeta));
    }
    if (data.containsKey('user_correction_json')) {
      context.handle(
          _userCorrectionJsonMeta,
          userCorrectionJson.isAcceptableOrUnknown(
              data['user_correction_json']!, _userCorrectionJsonMeta));
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {houseId};
  @override
  MapSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MapSnapshot(
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      commuteJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}commute_json']),
      poiSummaryJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}poi_summary_json']),
      userCorrectionJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}user_correction_json']),
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fetched_at']),
    );
  }

  @override
  $MapSnapshotsTable createAlias(String alias) {
    return $MapSnapshotsTable(attachedDatabase, alias);
  }
}

class MapSnapshot extends DataClass implements Insertable<MapSnapshot> {
  final String houseId;

  /// 提供方（amap）。
  final String provider;

  /// 通勤路线摘要 JSON（含 transit 主口径，F5）。
  final String? commuteJson;

  /// 分半径 POI 统计 JSON。
  final String? poiSummaryJson;

  /// 用户主观修正 JSON。
  final String? userCorrectionJson;

  /// 获取时间（毫秒时间戳）。
  final int? fetchedAt;
  const MapSnapshot(
      {required this.houseId,
      required this.provider,
      this.commuteJson,
      this.poiSummaryJson,
      this.userCorrectionJson,
      this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['house_id'] = Variable<String>(houseId);
    map['provider'] = Variable<String>(provider);
    if (!nullToAbsent || commuteJson != null) {
      map['commute_json'] = Variable<String>(commuteJson);
    }
    if (!nullToAbsent || poiSummaryJson != null) {
      map['poi_summary_json'] = Variable<String>(poiSummaryJson);
    }
    if (!nullToAbsent || userCorrectionJson != null) {
      map['user_correction_json'] = Variable<String>(userCorrectionJson);
    }
    if (!nullToAbsent || fetchedAt != null) {
      map['fetched_at'] = Variable<int>(fetchedAt);
    }
    return map;
  }

  MapSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return MapSnapshotsCompanion(
      houseId: Value(houseId),
      provider: Value(provider),
      commuteJson: commuteJson == null && nullToAbsent
          ? const Value.absent()
          : Value(commuteJson),
      poiSummaryJson: poiSummaryJson == null && nullToAbsent
          ? const Value.absent()
          : Value(poiSummaryJson),
      userCorrectionJson: userCorrectionJson == null && nullToAbsent
          ? const Value.absent()
          : Value(userCorrectionJson),
      fetchedAt: fetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fetchedAt),
    );
  }

  factory MapSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MapSnapshot(
      houseId: serializer.fromJson<String>(json['houseId']),
      provider: serializer.fromJson<String>(json['provider']),
      commuteJson: serializer.fromJson<String?>(json['commuteJson']),
      poiSummaryJson: serializer.fromJson<String?>(json['poiSummaryJson']),
      userCorrectionJson:
          serializer.fromJson<String?>(json['userCorrectionJson']),
      fetchedAt: serializer.fromJson<int?>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'houseId': serializer.toJson<String>(houseId),
      'provider': serializer.toJson<String>(provider),
      'commuteJson': serializer.toJson<String?>(commuteJson),
      'poiSummaryJson': serializer.toJson<String?>(poiSummaryJson),
      'userCorrectionJson': serializer.toJson<String?>(userCorrectionJson),
      'fetchedAt': serializer.toJson<int?>(fetchedAt),
    };
  }

  MapSnapshot copyWith(
          {String? houseId,
          String? provider,
          Value<String?> commuteJson = const Value.absent(),
          Value<String?> poiSummaryJson = const Value.absent(),
          Value<String?> userCorrectionJson = const Value.absent(),
          Value<int?> fetchedAt = const Value.absent()}) =>
      MapSnapshot(
        houseId: houseId ?? this.houseId,
        provider: provider ?? this.provider,
        commuteJson: commuteJson.present ? commuteJson.value : this.commuteJson,
        poiSummaryJson:
            poiSummaryJson.present ? poiSummaryJson.value : this.poiSummaryJson,
        userCorrectionJson: userCorrectionJson.present
            ? userCorrectionJson.value
            : this.userCorrectionJson,
        fetchedAt: fetchedAt.present ? fetchedAt.value : this.fetchedAt,
      );
  MapSnapshot copyWithCompanion(MapSnapshotsCompanion data) {
    return MapSnapshot(
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      provider: data.provider.present ? data.provider.value : this.provider,
      commuteJson:
          data.commuteJson.present ? data.commuteJson.value : this.commuteJson,
      poiSummaryJson: data.poiSummaryJson.present
          ? data.poiSummaryJson.value
          : this.poiSummaryJson,
      userCorrectionJson: data.userCorrectionJson.present
          ? data.userCorrectionJson.value
          : this.userCorrectionJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MapSnapshot(')
          ..write('houseId: $houseId, ')
          ..write('provider: $provider, ')
          ..write('commuteJson: $commuteJson, ')
          ..write('poiSummaryJson: $poiSummaryJson, ')
          ..write('userCorrectionJson: $userCorrectionJson, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(houseId, provider, commuteJson,
      poiSummaryJson, userCorrectionJson, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MapSnapshot &&
          other.houseId == this.houseId &&
          other.provider == this.provider &&
          other.commuteJson == this.commuteJson &&
          other.poiSummaryJson == this.poiSummaryJson &&
          other.userCorrectionJson == this.userCorrectionJson &&
          other.fetchedAt == this.fetchedAt);
}

class MapSnapshotsCompanion extends UpdateCompanion<MapSnapshot> {
  final Value<String> houseId;
  final Value<String> provider;
  final Value<String?> commuteJson;
  final Value<String?> poiSummaryJson;
  final Value<String?> userCorrectionJson;
  final Value<int?> fetchedAt;
  final Value<int> rowid;
  const MapSnapshotsCompanion({
    this.houseId = const Value.absent(),
    this.provider = const Value.absent(),
    this.commuteJson = const Value.absent(),
    this.poiSummaryJson = const Value.absent(),
    this.userCorrectionJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MapSnapshotsCompanion.insert({
    required String houseId,
    this.provider = const Value.absent(),
    this.commuteJson = const Value.absent(),
    this.poiSummaryJson = const Value.absent(),
    this.userCorrectionJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : houseId = Value(houseId);
  static Insertable<MapSnapshot> custom({
    Expression<String>? houseId,
    Expression<String>? provider,
    Expression<String>? commuteJson,
    Expression<String>? poiSummaryJson,
    Expression<String>? userCorrectionJson,
    Expression<int>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (houseId != null) 'house_id': houseId,
      if (provider != null) 'provider': provider,
      if (commuteJson != null) 'commute_json': commuteJson,
      if (poiSummaryJson != null) 'poi_summary_json': poiSummaryJson,
      if (userCorrectionJson != null)
        'user_correction_json': userCorrectionJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MapSnapshotsCompanion copyWith(
      {Value<String>? houseId,
      Value<String>? provider,
      Value<String?>? commuteJson,
      Value<String?>? poiSummaryJson,
      Value<String?>? userCorrectionJson,
      Value<int?>? fetchedAt,
      Value<int>? rowid}) {
    return MapSnapshotsCompanion(
      houseId: houseId ?? this.houseId,
      provider: provider ?? this.provider,
      commuteJson: commuteJson ?? this.commuteJson,
      poiSummaryJson: poiSummaryJson ?? this.poiSummaryJson,
      userCorrectionJson: userCorrectionJson ?? this.userCorrectionJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (commuteJson.present) {
      map['commute_json'] = Variable<String>(commuteJson.value);
    }
    if (poiSummaryJson.present) {
      map['poi_summary_json'] = Variable<String>(poiSummaryJson.value);
    }
    if (userCorrectionJson.present) {
      map['user_correction_json'] = Variable<String>(userCorrectionJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MapSnapshotsCompanion(')
          ..write('houseId: $houseId, ')
          ..write('provider: $provider, ')
          ..write('commuteJson: $commuteJson, ')
          ..write('poiSummaryJson: $poiSummaryJson, ')
          ..write('userCorrectionJson: $userCorrectionJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScoreSnapshotsTable extends ScoreSnapshots
    with TableInfo<$ScoreSnapshotsTable, ScoreSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScoreSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _houseIdMeta =
      const VerificationMeta('houseId');
  @override
  late final GeneratedColumn<String> houseId = GeneratedColumn<String>(
      'house_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES house_record (id) ON DELETE CASCADE'));
  static const VerificationMeta _ruleVersionMeta =
      const VerificationMeta('ruleVersion');
  @override
  late final GeneratedColumn<String> ruleVersion = GeneratedColumn<String>(
      'rule_version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hardFilterResultMeta =
      const VerificationMeta('hardFilterResult');
  @override
  late final GeneratedColumn<String> hardFilterResult = GeneratedColumn<String>(
      'hard_filter_result', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hardFilterReasonsJsonMeta =
      const VerificationMeta('hardFilterReasonsJson');
  @override
  late final GeneratedColumn<String> hardFilterReasonsJson =
      GeneratedColumn<String>('hard_filter_reasons_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _scoreTotalMeta =
      const VerificationMeta('scoreTotal');
  @override
  late final GeneratedColumn<double> scoreTotal = GeneratedColumn<double>(
      'score_total', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _scoreBreakdownJsonMeta =
      const VerificationMeta('scoreBreakdownJson');
  @override
  late final GeneratedColumn<String> scoreBreakdownJson =
      GeneratedColumn<String>('score_breakdown_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _explanationJsonMeta =
      const VerificationMeta('explanationJson');
  @override
  late final GeneratedColumn<String> explanationJson = GeneratedColumn<String>(
      'explanation_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        houseId,
        ruleVersion,
        hardFilterResult,
        hardFilterReasonsJson,
        scoreTotal,
        scoreBreakdownJson,
        explanationJson,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'score_snapshot';
  @override
  VerificationContext validateIntegrity(Insertable<ScoreSnapshot> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('house_id')) {
      context.handle(_houseIdMeta,
          houseId.isAcceptableOrUnknown(data['house_id']!, _houseIdMeta));
    } else if (isInserting) {
      context.missing(_houseIdMeta);
    }
    if (data.containsKey('rule_version')) {
      context.handle(
          _ruleVersionMeta,
          ruleVersion.isAcceptableOrUnknown(
              data['rule_version']!, _ruleVersionMeta));
    } else if (isInserting) {
      context.missing(_ruleVersionMeta);
    }
    if (data.containsKey('hard_filter_result')) {
      context.handle(
          _hardFilterResultMeta,
          hardFilterResult.isAcceptableOrUnknown(
              data['hard_filter_result']!, _hardFilterResultMeta));
    } else if (isInserting) {
      context.missing(_hardFilterResultMeta);
    }
    if (data.containsKey('hard_filter_reasons_json')) {
      context.handle(
          _hardFilterReasonsJsonMeta,
          hardFilterReasonsJson.isAcceptableOrUnknown(
              data['hard_filter_reasons_json']!, _hardFilterReasonsJsonMeta));
    }
    if (data.containsKey('score_total')) {
      context.handle(
          _scoreTotalMeta,
          scoreTotal.isAcceptableOrUnknown(
              data['score_total']!, _scoreTotalMeta));
    } else if (isInserting) {
      context.missing(_scoreTotalMeta);
    }
    if (data.containsKey('score_breakdown_json')) {
      context.handle(
          _scoreBreakdownJsonMeta,
          scoreBreakdownJson.isAcceptableOrUnknown(
              data['score_breakdown_json']!, _scoreBreakdownJsonMeta));
    }
    if (data.containsKey('explanation_json')) {
      context.handle(
          _explanationJsonMeta,
          explanationJson.isAcceptableOrUnknown(
              data['explanation_json']!, _explanationJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScoreSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScoreSnapshot(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      houseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}house_id'])!,
      ruleVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rule_version'])!,
      hardFilterResult: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}hard_filter_result'])!,
      hardFilterReasonsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}hard_filter_reasons_json']),
      scoreTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}score_total'])!,
      scoreBreakdownJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}score_breakdown_json']),
      explanationJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}explanation_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ScoreSnapshotsTable createAlias(String alias) {
    return $ScoreSnapshotsTable(attachedDatabase, alias);
  }
}

class ScoreSnapshot extends DataClass implements Insertable<ScoreSnapshot> {
  /// UUID 主键（一套房可有多条历史快照）。
  final String id;
  final String houseId;

  /// 冻结计算时的规则版本（F8）。
  final String ruleVersion;

  /// 硬筛结果：pass / rejected。
  final String hardFilterResult;

  /// 硬筛淘汰原因清单 JSON。
  final String? hardFilterReasonsJson;

  /// 加权总分。
  final double scoreTotal;

  /// 5 维分项 JSON。
  final String? scoreBreakdownJson;

  /// 可解释文案 JSON。
  final String? explanationJson;

  /// 生成时间（毫秒时间戳）。
  final int createdAt;
  const ScoreSnapshot(
      {required this.id,
      required this.houseId,
      required this.ruleVersion,
      required this.hardFilterResult,
      this.hardFilterReasonsJson,
      required this.scoreTotal,
      this.scoreBreakdownJson,
      this.explanationJson,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['house_id'] = Variable<String>(houseId);
    map['rule_version'] = Variable<String>(ruleVersion);
    map['hard_filter_result'] = Variable<String>(hardFilterResult);
    if (!nullToAbsent || hardFilterReasonsJson != null) {
      map['hard_filter_reasons_json'] = Variable<String>(hardFilterReasonsJson);
    }
    map['score_total'] = Variable<double>(scoreTotal);
    if (!nullToAbsent || scoreBreakdownJson != null) {
      map['score_breakdown_json'] = Variable<String>(scoreBreakdownJson);
    }
    if (!nullToAbsent || explanationJson != null) {
      map['explanation_json'] = Variable<String>(explanationJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ScoreSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ScoreSnapshotsCompanion(
      id: Value(id),
      houseId: Value(houseId),
      ruleVersion: Value(ruleVersion),
      hardFilterResult: Value(hardFilterResult),
      hardFilterReasonsJson: hardFilterReasonsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(hardFilterReasonsJson),
      scoreTotal: Value(scoreTotal),
      scoreBreakdownJson: scoreBreakdownJson == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreBreakdownJson),
      explanationJson: explanationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(explanationJson),
      createdAt: Value(createdAt),
    );
  }

  factory ScoreSnapshot.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScoreSnapshot(
      id: serializer.fromJson<String>(json['id']),
      houseId: serializer.fromJson<String>(json['houseId']),
      ruleVersion: serializer.fromJson<String>(json['ruleVersion']),
      hardFilterResult: serializer.fromJson<String>(json['hardFilterResult']),
      hardFilterReasonsJson:
          serializer.fromJson<String?>(json['hardFilterReasonsJson']),
      scoreTotal: serializer.fromJson<double>(json['scoreTotal']),
      scoreBreakdownJson:
          serializer.fromJson<String?>(json['scoreBreakdownJson']),
      explanationJson: serializer.fromJson<String?>(json['explanationJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'houseId': serializer.toJson<String>(houseId),
      'ruleVersion': serializer.toJson<String>(ruleVersion),
      'hardFilterResult': serializer.toJson<String>(hardFilterResult),
      'hardFilterReasonsJson':
          serializer.toJson<String?>(hardFilterReasonsJson),
      'scoreTotal': serializer.toJson<double>(scoreTotal),
      'scoreBreakdownJson': serializer.toJson<String?>(scoreBreakdownJson),
      'explanationJson': serializer.toJson<String?>(explanationJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  ScoreSnapshot copyWith(
          {String? id,
          String? houseId,
          String? ruleVersion,
          String? hardFilterResult,
          Value<String?> hardFilterReasonsJson = const Value.absent(),
          double? scoreTotal,
          Value<String?> scoreBreakdownJson = const Value.absent(),
          Value<String?> explanationJson = const Value.absent(),
          int? createdAt}) =>
      ScoreSnapshot(
        id: id ?? this.id,
        houseId: houseId ?? this.houseId,
        ruleVersion: ruleVersion ?? this.ruleVersion,
        hardFilterResult: hardFilterResult ?? this.hardFilterResult,
        hardFilterReasonsJson: hardFilterReasonsJson.present
            ? hardFilterReasonsJson.value
            : this.hardFilterReasonsJson,
        scoreTotal: scoreTotal ?? this.scoreTotal,
        scoreBreakdownJson: scoreBreakdownJson.present
            ? scoreBreakdownJson.value
            : this.scoreBreakdownJson,
        explanationJson: explanationJson.present
            ? explanationJson.value
            : this.explanationJson,
        createdAt: createdAt ?? this.createdAt,
      );
  ScoreSnapshot copyWithCompanion(ScoreSnapshotsCompanion data) {
    return ScoreSnapshot(
      id: data.id.present ? data.id.value : this.id,
      houseId: data.houseId.present ? data.houseId.value : this.houseId,
      ruleVersion:
          data.ruleVersion.present ? data.ruleVersion.value : this.ruleVersion,
      hardFilterResult: data.hardFilterResult.present
          ? data.hardFilterResult.value
          : this.hardFilterResult,
      hardFilterReasonsJson: data.hardFilterReasonsJson.present
          ? data.hardFilterReasonsJson.value
          : this.hardFilterReasonsJson,
      scoreTotal:
          data.scoreTotal.present ? data.scoreTotal.value : this.scoreTotal,
      scoreBreakdownJson: data.scoreBreakdownJson.present
          ? data.scoreBreakdownJson.value
          : this.scoreBreakdownJson,
      explanationJson: data.explanationJson.present
          ? data.explanationJson.value
          : this.explanationJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScoreSnapshot(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('hardFilterResult: $hardFilterResult, ')
          ..write('hardFilterReasonsJson: $hardFilterReasonsJson, ')
          ..write('scoreTotal: $scoreTotal, ')
          ..write('scoreBreakdownJson: $scoreBreakdownJson, ')
          ..write('explanationJson: $explanationJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      houseId,
      ruleVersion,
      hardFilterResult,
      hardFilterReasonsJson,
      scoreTotal,
      scoreBreakdownJson,
      explanationJson,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScoreSnapshot &&
          other.id == this.id &&
          other.houseId == this.houseId &&
          other.ruleVersion == this.ruleVersion &&
          other.hardFilterResult == this.hardFilterResult &&
          other.hardFilterReasonsJson == this.hardFilterReasonsJson &&
          other.scoreTotal == this.scoreTotal &&
          other.scoreBreakdownJson == this.scoreBreakdownJson &&
          other.explanationJson == this.explanationJson &&
          other.createdAt == this.createdAt);
}

class ScoreSnapshotsCompanion extends UpdateCompanion<ScoreSnapshot> {
  final Value<String> id;
  final Value<String> houseId;
  final Value<String> ruleVersion;
  final Value<String> hardFilterResult;
  final Value<String?> hardFilterReasonsJson;
  final Value<double> scoreTotal;
  final Value<String?> scoreBreakdownJson;
  final Value<String?> explanationJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ScoreSnapshotsCompanion({
    this.id = const Value.absent(),
    this.houseId = const Value.absent(),
    this.ruleVersion = const Value.absent(),
    this.hardFilterResult = const Value.absent(),
    this.hardFilterReasonsJson = const Value.absent(),
    this.scoreTotal = const Value.absent(),
    this.scoreBreakdownJson = const Value.absent(),
    this.explanationJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ScoreSnapshotsCompanion.insert({
    required String id,
    required String houseId,
    required String ruleVersion,
    required String hardFilterResult,
    this.hardFilterReasonsJson = const Value.absent(),
    required double scoreTotal,
    this.scoreBreakdownJson = const Value.absent(),
    this.explanationJson = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        houseId = Value(houseId),
        ruleVersion = Value(ruleVersion),
        hardFilterResult = Value(hardFilterResult),
        scoreTotal = Value(scoreTotal),
        createdAt = Value(createdAt);
  static Insertable<ScoreSnapshot> custom({
    Expression<String>? id,
    Expression<String>? houseId,
    Expression<String>? ruleVersion,
    Expression<String>? hardFilterResult,
    Expression<String>? hardFilterReasonsJson,
    Expression<double>? scoreTotal,
    Expression<String>? scoreBreakdownJson,
    Expression<String>? explanationJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (houseId != null) 'house_id': houseId,
      if (ruleVersion != null) 'rule_version': ruleVersion,
      if (hardFilterResult != null) 'hard_filter_result': hardFilterResult,
      if (hardFilterReasonsJson != null)
        'hard_filter_reasons_json': hardFilterReasonsJson,
      if (scoreTotal != null) 'score_total': scoreTotal,
      if (scoreBreakdownJson != null)
        'score_breakdown_json': scoreBreakdownJson,
      if (explanationJson != null) 'explanation_json': explanationJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ScoreSnapshotsCompanion copyWith(
      {Value<String>? id,
      Value<String>? houseId,
      Value<String>? ruleVersion,
      Value<String>? hardFilterResult,
      Value<String?>? hardFilterReasonsJson,
      Value<double>? scoreTotal,
      Value<String?>? scoreBreakdownJson,
      Value<String?>? explanationJson,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return ScoreSnapshotsCompanion(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      ruleVersion: ruleVersion ?? this.ruleVersion,
      hardFilterResult: hardFilterResult ?? this.hardFilterResult,
      hardFilterReasonsJson:
          hardFilterReasonsJson ?? this.hardFilterReasonsJson,
      scoreTotal: scoreTotal ?? this.scoreTotal,
      scoreBreakdownJson: scoreBreakdownJson ?? this.scoreBreakdownJson,
      explanationJson: explanationJson ?? this.explanationJson,
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
    if (houseId.present) {
      map['house_id'] = Variable<String>(houseId.value);
    }
    if (ruleVersion.present) {
      map['rule_version'] = Variable<String>(ruleVersion.value);
    }
    if (hardFilterResult.present) {
      map['hard_filter_result'] = Variable<String>(hardFilterResult.value);
    }
    if (hardFilterReasonsJson.present) {
      map['hard_filter_reasons_json'] =
          Variable<String>(hardFilterReasonsJson.value);
    }
    if (scoreTotal.present) {
      map['score_total'] = Variable<double>(scoreTotal.value);
    }
    if (scoreBreakdownJson.present) {
      map['score_breakdown_json'] = Variable<String>(scoreBreakdownJson.value);
    }
    if (explanationJson.present) {
      map['explanation_json'] = Variable<String>(explanationJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScoreSnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('houseId: $houseId, ')
          ..write('ruleVersion: $ruleVersion, ')
          ..write('hardFilterResult: $hardFilterResult, ')
          ..write('hardFilterReasonsJson: $hardFilterReasonsJson, ')
          ..write('scoreTotal: $scoreTotal, ')
          ..write('scoreBreakdownJson: $scoreBreakdownJson, ')
          ..write('explanationJson: $explanationJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenceProfilesTable extends PreferenceProfiles
    with TableInfo<$PreferenceProfilesTable, PreferenceProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenceProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _maxRentTotalMeta =
      const VerificationMeta('maxRentTotal');
  @override
  late final GeneratedColumn<int> maxRentTotal = GeneratedColumn<int>(
      'max_rent_total', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _maxCommuteMinutesMeta =
      const VerificationMeta('maxCommuteMinutes');
  @override
  late final GeneratedColumn<int> maxCommuteMinutes = GeneratedColumn<int>(
      'max_commute_minutes', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _destinationsJsonMeta =
      const VerificationMeta('destinationsJson');
  @override
  late final GeneratedColumn<String> destinationsJson = GeneratedColumn<String>(
      'destinations_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _requiredFeaturesJsonMeta =
      const VerificationMeta('requiredFeaturesJson');
  @override
  late final GeneratedColumn<String> requiredFeaturesJson =
      GeneratedColumn<String>('required_features_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _weightsJsonMeta =
      const VerificationMeta('weightsJson');
  @override
  late final GeneratedColumn<String> weightsJson = GeneratedColumn<String>(
      'weights_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _preferredCommuteModeMeta =
      const VerificationMeta('preferredCommuteMode');
  @override
  late final GeneratedColumn<String> preferredCommuteMode =
      GeneratedColumn<String>('preferred_commute_mode', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        maxRentTotal,
        maxCommuteMinutes,
        destinationsJson,
        requiredFeaturesJson,
        weightsJson,
        preferredCommuteMode
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preference_profile';
  @override
  VerificationContext validateIntegrity(Insertable<PreferenceProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('max_rent_total')) {
      context.handle(
          _maxRentTotalMeta,
          maxRentTotal.isAcceptableOrUnknown(
              data['max_rent_total']!, _maxRentTotalMeta));
    }
    if (data.containsKey('max_commute_minutes')) {
      context.handle(
          _maxCommuteMinutesMeta,
          maxCommuteMinutes.isAcceptableOrUnknown(
              data['max_commute_minutes']!, _maxCommuteMinutesMeta));
    }
    if (data.containsKey('destinations_json')) {
      context.handle(
          _destinationsJsonMeta,
          destinationsJson.isAcceptableOrUnknown(
              data['destinations_json']!, _destinationsJsonMeta));
    }
    if (data.containsKey('required_features_json')) {
      context.handle(
          _requiredFeaturesJsonMeta,
          requiredFeaturesJson.isAcceptableOrUnknown(
              data['required_features_json']!, _requiredFeaturesJsonMeta));
    }
    if (data.containsKey('weights_json')) {
      context.handle(
          _weightsJsonMeta,
          weightsJson.isAcceptableOrUnknown(
              data['weights_json']!, _weightsJsonMeta));
    }
    if (data.containsKey('preferred_commute_mode')) {
      context.handle(
          _preferredCommuteModeMeta,
          preferredCommuteMode.isAcceptableOrUnknown(
              data['preferred_commute_mode']!, _preferredCommuteModeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferenceProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferenceProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      maxRentTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_rent_total']),
      maxCommuteMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_commute_minutes']),
      destinationsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}destinations_json']),
      requiredFeaturesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}required_features_json']),
      weightsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weights_json']),
      preferredCommuteMode: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}preferred_commute_mode']),
    );
  }

  @override
  $PreferenceProfilesTable createAlias(String alias) {
    return $PreferenceProfilesTable(attachedDatabase, alias);
  }
}

class PreferenceProfile extends DataClass
    implements Insertable<PreferenceProfile> {
  /// 默认 profile 主键。
  final String id;

  /// 月总成本上限：预算硬筛唯一基准（F1），非月租口径。
  final int? maxRentTotal;

  /// 最大通勤时间（分钟）。
  final int? maxCommuteMinutes;

  /// 目的地 JSON：`[{id,label,lat,lng,primary}]`，primary=true 为主要目的地（F5）。
  final String? destinationsJson;

  /// 硬性条件 JSON：独卫/厨房/电梯/宠物/楼层/押付。
  final String? requiredFeaturesJson;

  /// 权重 JSON：默认 `{cost:30,commute:20,living:25,nearby:15,risk:10}`（F4）。
  final String? weightsJson;

  /// 首选通勤方式（walking/bicycling/transit/driving）；空则默认 transit（F5）。
  final String? preferredCommuteMode;
  const PreferenceProfile(
      {required this.id,
      this.maxRentTotal,
      this.maxCommuteMinutes,
      this.destinationsJson,
      this.requiredFeaturesJson,
      this.weightsJson,
      this.preferredCommuteMode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || maxRentTotal != null) {
      map['max_rent_total'] = Variable<int>(maxRentTotal);
    }
    if (!nullToAbsent || maxCommuteMinutes != null) {
      map['max_commute_minutes'] = Variable<int>(maxCommuteMinutes);
    }
    if (!nullToAbsent || destinationsJson != null) {
      map['destinations_json'] = Variable<String>(destinationsJson);
    }
    if (!nullToAbsent || requiredFeaturesJson != null) {
      map['required_features_json'] = Variable<String>(requiredFeaturesJson);
    }
    if (!nullToAbsent || weightsJson != null) {
      map['weights_json'] = Variable<String>(weightsJson);
    }
    if (!nullToAbsent || preferredCommuteMode != null) {
      map['preferred_commute_mode'] = Variable<String>(preferredCommuteMode);
    }
    return map;
  }

  PreferenceProfilesCompanion toCompanion(bool nullToAbsent) {
    return PreferenceProfilesCompanion(
      id: Value(id),
      maxRentTotal: maxRentTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(maxRentTotal),
      maxCommuteMinutes: maxCommuteMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(maxCommuteMinutes),
      destinationsJson: destinationsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationsJson),
      requiredFeaturesJson: requiredFeaturesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(requiredFeaturesJson),
      weightsJson: weightsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(weightsJson),
      preferredCommuteMode: preferredCommuteMode == null && nullToAbsent
          ? const Value.absent()
          : Value(preferredCommuteMode),
    );
  }

  factory PreferenceProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferenceProfile(
      id: serializer.fromJson<String>(json['id']),
      maxRentTotal: serializer.fromJson<int?>(json['maxRentTotal']),
      maxCommuteMinutes: serializer.fromJson<int?>(json['maxCommuteMinutes']),
      destinationsJson: serializer.fromJson<String?>(json['destinationsJson']),
      requiredFeaturesJson:
          serializer.fromJson<String?>(json['requiredFeaturesJson']),
      weightsJson: serializer.fromJson<String?>(json['weightsJson']),
      preferredCommuteMode:
          serializer.fromJson<String?>(json['preferredCommuteMode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'maxRentTotal': serializer.toJson<int?>(maxRentTotal),
      'maxCommuteMinutes': serializer.toJson<int?>(maxCommuteMinutes),
      'destinationsJson': serializer.toJson<String?>(destinationsJson),
      'requiredFeaturesJson': serializer.toJson<String?>(requiredFeaturesJson),
      'weightsJson': serializer.toJson<String?>(weightsJson),
      'preferredCommuteMode': serializer.toJson<String?>(preferredCommuteMode),
    };
  }

  PreferenceProfile copyWith(
          {String? id,
          Value<int?> maxRentTotal = const Value.absent(),
          Value<int?> maxCommuteMinutes = const Value.absent(),
          Value<String?> destinationsJson = const Value.absent(),
          Value<String?> requiredFeaturesJson = const Value.absent(),
          Value<String?> weightsJson = const Value.absent(),
          Value<String?> preferredCommuteMode = const Value.absent()}) =>
      PreferenceProfile(
        id: id ?? this.id,
        maxRentTotal:
            maxRentTotal.present ? maxRentTotal.value : this.maxRentTotal,
        maxCommuteMinutes: maxCommuteMinutes.present
            ? maxCommuteMinutes.value
            : this.maxCommuteMinutes,
        destinationsJson: destinationsJson.present
            ? destinationsJson.value
            : this.destinationsJson,
        requiredFeaturesJson: requiredFeaturesJson.present
            ? requiredFeaturesJson.value
            : this.requiredFeaturesJson,
        weightsJson: weightsJson.present ? weightsJson.value : this.weightsJson,
        preferredCommuteMode: preferredCommuteMode.present
            ? preferredCommuteMode.value
            : this.preferredCommuteMode,
      );
  PreferenceProfile copyWithCompanion(PreferenceProfilesCompanion data) {
    return PreferenceProfile(
      id: data.id.present ? data.id.value : this.id,
      maxRentTotal: data.maxRentTotal.present
          ? data.maxRentTotal.value
          : this.maxRentTotal,
      maxCommuteMinutes: data.maxCommuteMinutes.present
          ? data.maxCommuteMinutes.value
          : this.maxCommuteMinutes,
      destinationsJson: data.destinationsJson.present
          ? data.destinationsJson.value
          : this.destinationsJson,
      requiredFeaturesJson: data.requiredFeaturesJson.present
          ? data.requiredFeaturesJson.value
          : this.requiredFeaturesJson,
      weightsJson:
          data.weightsJson.present ? data.weightsJson.value : this.weightsJson,
      preferredCommuteMode: data.preferredCommuteMode.present
          ? data.preferredCommuteMode.value
          : this.preferredCommuteMode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceProfile(')
          ..write('id: $id, ')
          ..write('maxRentTotal: $maxRentTotal, ')
          ..write('maxCommuteMinutes: $maxCommuteMinutes, ')
          ..write('destinationsJson: $destinationsJson, ')
          ..write('requiredFeaturesJson: $requiredFeaturesJson, ')
          ..write('weightsJson: $weightsJson, ')
          ..write('preferredCommuteMode: $preferredCommuteMode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      maxRentTotal,
      maxCommuteMinutes,
      destinationsJson,
      requiredFeaturesJson,
      weightsJson,
      preferredCommuteMode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferenceProfile &&
          other.id == this.id &&
          other.maxRentTotal == this.maxRentTotal &&
          other.maxCommuteMinutes == this.maxCommuteMinutes &&
          other.destinationsJson == this.destinationsJson &&
          other.requiredFeaturesJson == this.requiredFeaturesJson &&
          other.weightsJson == this.weightsJson &&
          other.preferredCommuteMode == this.preferredCommuteMode);
}

class PreferenceProfilesCompanion extends UpdateCompanion<PreferenceProfile> {
  final Value<String> id;
  final Value<int?> maxRentTotal;
  final Value<int?> maxCommuteMinutes;
  final Value<String?> destinationsJson;
  final Value<String?> requiredFeaturesJson;
  final Value<String?> weightsJson;
  final Value<String?> preferredCommuteMode;
  final Value<int> rowid;
  const PreferenceProfilesCompanion({
    this.id = const Value.absent(),
    this.maxRentTotal = const Value.absent(),
    this.maxCommuteMinutes = const Value.absent(),
    this.destinationsJson = const Value.absent(),
    this.requiredFeaturesJson = const Value.absent(),
    this.weightsJson = const Value.absent(),
    this.preferredCommuteMode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenceProfilesCompanion.insert({
    required String id,
    this.maxRentTotal = const Value.absent(),
    this.maxCommuteMinutes = const Value.absent(),
    this.destinationsJson = const Value.absent(),
    this.requiredFeaturesJson = const Value.absent(),
    this.weightsJson = const Value.absent(),
    this.preferredCommuteMode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<PreferenceProfile> custom({
    Expression<String>? id,
    Expression<int>? maxRentTotal,
    Expression<int>? maxCommuteMinutes,
    Expression<String>? destinationsJson,
    Expression<String>? requiredFeaturesJson,
    Expression<String>? weightsJson,
    Expression<String>? preferredCommuteMode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (maxRentTotal != null) 'max_rent_total': maxRentTotal,
      if (maxCommuteMinutes != null) 'max_commute_minutes': maxCommuteMinutes,
      if (destinationsJson != null) 'destinations_json': destinationsJson,
      if (requiredFeaturesJson != null)
        'required_features_json': requiredFeaturesJson,
      if (weightsJson != null) 'weights_json': weightsJson,
      if (preferredCommuteMode != null)
        'preferred_commute_mode': preferredCommuteMode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenceProfilesCompanion copyWith(
      {Value<String>? id,
      Value<int?>? maxRentTotal,
      Value<int?>? maxCommuteMinutes,
      Value<String?>? destinationsJson,
      Value<String?>? requiredFeaturesJson,
      Value<String?>? weightsJson,
      Value<String?>? preferredCommuteMode,
      Value<int>? rowid}) {
    return PreferenceProfilesCompanion(
      id: id ?? this.id,
      maxRentTotal: maxRentTotal ?? this.maxRentTotal,
      maxCommuteMinutes: maxCommuteMinutes ?? this.maxCommuteMinutes,
      destinationsJson: destinationsJson ?? this.destinationsJson,
      requiredFeaturesJson: requiredFeaturesJson ?? this.requiredFeaturesJson,
      weightsJson: weightsJson ?? this.weightsJson,
      preferredCommuteMode: preferredCommuteMode ?? this.preferredCommuteMode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (maxRentTotal.present) {
      map['max_rent_total'] = Variable<int>(maxRentTotal.value);
    }
    if (maxCommuteMinutes.present) {
      map['max_commute_minutes'] = Variable<int>(maxCommuteMinutes.value);
    }
    if (destinationsJson.present) {
      map['destinations_json'] = Variable<String>(destinationsJson.value);
    }
    if (requiredFeaturesJson.present) {
      map['required_features_json'] =
          Variable<String>(requiredFeaturesJson.value);
    }
    if (weightsJson.present) {
      map['weights_json'] = Variable<String>(weightsJson.value);
    }
    if (preferredCommuteMode.present) {
      map['preferred_commute_mode'] =
          Variable<String>(preferredCommuteMode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenceProfilesCompanion(')
          ..write('id: $id, ')
          ..write('maxRentTotal: $maxRentTotal, ')
          ..write('maxCommuteMinutes: $maxCommuteMinutes, ')
          ..write('destinationsJson: $destinationsJson, ')
          ..write('requiredFeaturesJson: $requiredFeaturesJson, ')
          ..write('weightsJson: $weightsJson, ')
          ..write('preferredCommuteMode: $preferredCommuteMode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VillagesTable villages = $VillagesTable(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $HouseRecordsTable houseRecords = $HouseRecordsTable(this);
  late final $FeeInfosTable feeInfos = $FeeInfosTable(this);
  late final $RoomInfosTable roomInfos = $RoomInfosTable(this);
  late final $ContactInfosTable contactInfos = $ContactInfosTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  late final $RiskFlagsTable riskFlags = $RiskFlagsTable(this);
  late final $PhotoAssetsTable photoAssets = $PhotoAssetsTable(this);
  late final $MapSnapshotsTable mapSnapshots = $MapSnapshotsTable(this);
  late final $ScoreSnapshotsTable scoreSnapshots = $ScoreSnapshotsTable(this);
  late final $PreferenceProfilesTable preferenceProfiles =
      $PreferenceProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        villages,
        buildings,
        houseRecords,
        feeInfos,
        roomInfos,
        contactInfos,
        checklistItems,
        riskFlags,
        photoAssets,
        mapSnapshots,
        scoreSnapshots,
        preferenceProfiles
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('village',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('building', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('village',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('house_record', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('building',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('house_record', kind: UpdateKind.update),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('fee_info', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('room_info', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('contact_info', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('checklist_item', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('risk_flag', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('photo_asset', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('map_snapshot', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('house_record',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('score_snapshot', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$VillagesTableCreateCompanionBuilder = VillagesCompanion Function({
  required String id,
  required String name,
  Value<String> status,
  Value<String?> areaNote,
  Value<int?> commuteMinutes,
  Value<String?> commuteNote,
  Value<String?> surroundingsTagsJson,
  Value<int?> surroundingsScore,
  Value<int?> environmentScore,
  Value<int?> safetyScore,
  Value<int?> noiseScore,
  Value<String?> note,
  required int createdAt,
  required int updatedAt,
  Value<int?> lastVisitedAt,
  Value<int> rowid,
});
typedef $$VillagesTableUpdateCompanionBuilder = VillagesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> status,
  Value<String?> areaNote,
  Value<int?> commuteMinutes,
  Value<String?> commuteNote,
  Value<String?> surroundingsTagsJson,
  Value<int?> surroundingsScore,
  Value<int?> environmentScore,
  Value<int?> safetyScore,
  Value<int?> noiseScore,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> lastVisitedAt,
  Value<int> rowid,
});

final class $$VillagesTableReferences
    extends BaseReferences<_$AppDatabase, $VillagesTable, Village> {
  $$VillagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BuildingsTable, List<Building>>
      _buildingsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.buildings,
              aliasName: 'village__id__building__village_id');

  $$BuildingsTableProcessedTableManager get buildingsRefs {
    final manager = $$BuildingsTableTableManager($_db, $_db.buildings)
        .filter((f) => f.villageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_buildingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$HouseRecordsTable, List<HouseRecord>>
      _houseRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.houseRecords,
              aliasName: 'village__id__house_record__village_id');

  $$HouseRecordsTableProcessedTableManager get houseRecordsRefs {
    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.villageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_houseRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$VillagesTableFilterComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get areaNote => $composableBuilder(
      column: $table.areaNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get commuteMinutes => $composableBuilder(
      column: $table.commuteMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commuteNote => $composableBuilder(
      column: $table.commuteNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get surroundingsTagsJson => $composableBuilder(
      column: $table.surroundingsTagsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get surroundingsScore => $composableBuilder(
      column: $table.surroundingsScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get environmentScore => $composableBuilder(
      column: $table.environmentScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get safetyScore => $composableBuilder(
      column: $table.safetyScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get noiseScore => $composableBuilder(
      column: $table.noiseScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> buildingsRefs(
      Expression<bool> Function($$BuildingsTableFilterComposer f) f) {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.villageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableFilterComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> houseRecordsRefs(
      Expression<bool> Function($$HouseRecordsTableFilterComposer f) f) {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.villageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VillagesTableOrderingComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get areaNote => $composableBuilder(
      column: $table.areaNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get commuteMinutes => $composableBuilder(
      column: $table.commuteMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commuteNote => $composableBuilder(
      column: $table.commuteNote, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get surroundingsTagsJson => $composableBuilder(
      column: $table.surroundingsTagsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get surroundingsScore => $composableBuilder(
      column: $table.surroundingsScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get environmentScore => $composableBuilder(
      column: $table.environmentScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get safetyScore => $composableBuilder(
      column: $table.safetyScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get noiseScore => $composableBuilder(
      column: $table.noiseScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$VillagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VillagesTable> {
  $$VillagesTableAnnotationComposer({
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get areaNote =>
      $composableBuilder(column: $table.areaNote, builder: (column) => column);

  GeneratedColumn<int> get commuteMinutes => $composableBuilder(
      column: $table.commuteMinutes, builder: (column) => column);

  GeneratedColumn<String> get commuteNote => $composableBuilder(
      column: $table.commuteNote, builder: (column) => column);

  GeneratedColumn<String> get surroundingsTagsJson => $composableBuilder(
      column: $table.surroundingsTagsJson, builder: (column) => column);

  GeneratedColumn<int> get surroundingsScore => $composableBuilder(
      column: $table.surroundingsScore, builder: (column) => column);

  GeneratedColumn<int> get environmentScore => $composableBuilder(
      column: $table.environmentScore, builder: (column) => column);

  GeneratedColumn<int> get safetyScore => $composableBuilder(
      column: $table.safetyScore, builder: (column) => column);

  GeneratedColumn<int> get noiseScore => $composableBuilder(
      column: $table.noiseScore, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => column);

  Expression<T> buildingsRefs<T extends Object>(
      Expression<T> Function($$BuildingsTableAnnotationComposer a) f) {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.villageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableAnnotationComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> houseRecordsRefs<T extends Object>(
      Expression<T> Function($$HouseRecordsTableAnnotationComposer a) f) {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.villageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$VillagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $VillagesTable,
    Village,
    $$VillagesTableFilterComposer,
    $$VillagesTableOrderingComposer,
    $$VillagesTableAnnotationComposer,
    $$VillagesTableCreateCompanionBuilder,
    $$VillagesTableUpdateCompanionBuilder,
    (Village, $$VillagesTableReferences),
    Village,
    PrefetchHooks Function({bool buildingsRefs, bool houseRecordsRefs})> {
  $$VillagesTableTableManager(_$AppDatabase db, $VillagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VillagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VillagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VillagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> areaNote = const Value.absent(),
            Value<int?> commuteMinutes = const Value.absent(),
            Value<String?> commuteNote = const Value.absent(),
            Value<String?> surroundingsTagsJson = const Value.absent(),
            Value<int?> surroundingsScore = const Value.absent(),
            Value<int?> environmentScore = const Value.absent(),
            Value<int?> safetyScore = const Value.absent(),
            Value<int?> noiseScore = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> lastVisitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VillagesCompanion(
            id: id,
            name: name,
            status: status,
            areaNote: areaNote,
            commuteMinutes: commuteMinutes,
            commuteNote: commuteNote,
            surroundingsTagsJson: surroundingsTagsJson,
            surroundingsScore: surroundingsScore,
            environmentScore: environmentScore,
            safetyScore: safetyScore,
            noiseScore: noiseScore,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String> status = const Value.absent(),
            Value<String?> areaNote = const Value.absent(),
            Value<int?> commuteMinutes = const Value.absent(),
            Value<String?> commuteNote = const Value.absent(),
            Value<String?> surroundingsTagsJson = const Value.absent(),
            Value<int?> surroundingsScore = const Value.absent(),
            Value<int?> environmentScore = const Value.absent(),
            Value<int?> safetyScore = const Value.absent(),
            Value<int?> noiseScore = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> lastVisitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              VillagesCompanion.insert(
            id: id,
            name: name,
            status: status,
            areaNote: areaNote,
            commuteMinutes: commuteMinutes,
            commuteNote: commuteNote,
            surroundingsTagsJson: surroundingsTagsJson,
            surroundingsScore: surroundingsScore,
            environmentScore: environmentScore,
            safetyScore: safetyScore,
            noiseScore: noiseScore,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$VillagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {buildingsRefs = false, houseRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (buildingsRefs) db.buildings,
                if (houseRecordsRefs) db.houseRecords
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (buildingsRefs)
                    await $_getPrefetchedData<Village, $VillagesTable,
                            Building>(
                        currentTable: table,
                        referencedTable:
                            $$VillagesTableReferences._buildingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VillagesTableReferences(db, table, p0)
                                .buildingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.villageId == item.id),
                        typedResults: items),
                  if (houseRecordsRefs)
                    await $_getPrefetchedData<Village, $VillagesTable,
                            HouseRecord>(
                        currentTable: table,
                        referencedTable: $$VillagesTableReferences
                            ._houseRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$VillagesTableReferences(db, table, p0)
                                .houseRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.villageId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$VillagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $VillagesTable,
    Village,
    $$VillagesTableFilterComposer,
    $$VillagesTableOrderingComposer,
    $$VillagesTableAnnotationComposer,
    $$VillagesTableCreateCompanionBuilder,
    $$VillagesTableUpdateCompanionBuilder,
    (Village, $$VillagesTableReferences),
    Village,
    PrefetchHooks Function({bool buildingsRefs, bool houseRecordsRefs})>;
typedef $$BuildingsTableCreateCompanionBuilder = BuildingsCompanion Function({
  required String id,
  required String villageId,
  required String name,
  Value<String> status,
  Value<String?> tagsJson,
  Value<String?> entranceNote,
  Value<int?> totalFloor,
  Value<bool?> hasElevator,
  Value<String?> note,
  required int createdAt,
  required int updatedAt,
  Value<int?> lastVisitedAt,
  Value<int> rowid,
});
typedef $$BuildingsTableUpdateCompanionBuilder = BuildingsCompanion Function({
  Value<String> id,
  Value<String> villageId,
  Value<String> name,
  Value<String> status,
  Value<String?> tagsJson,
  Value<String?> entranceNote,
  Value<int?> totalFloor,
  Value<bool?> hasElevator,
  Value<String?> note,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> lastVisitedAt,
  Value<int> rowid,
});

final class $$BuildingsTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingsTable, Building> {
  $$BuildingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillagesTable _villageIdTable(_$AppDatabase db) =>
      db.villages.createAlias('building__village_id__village__id');

  $$VillagesTableProcessedTableManager get villageId {
    final $_column = $_itemColumn<String>('village_id')!;

    final manager = $$VillagesTableTableManager($_db, $_db.villages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$HouseRecordsTable, List<HouseRecord>>
      _houseRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.houseRecords,
              aliasName: 'building__id__house_record__building_id');

  $$HouseRecordsTableProcessedTableManager get houseRecordsRefs {
    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.buildingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_houseRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BuildingsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entranceNote => $composableBuilder(
      column: $table.entranceNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => ColumnFilters(column));

  $$VillagesTableFilterComposer get villageId {
    final $$VillagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableFilterComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> houseRecordsRefs(
      Expression<bool> Function($$HouseRecordsTableFilterComposer f) f) {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BuildingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entranceNote => $composableBuilder(
      column: $table.entranceNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt,
      builder: (column) => ColumnOrderings(column));

  $$VillagesTableOrderingComposer get villageId {
    final $$VillagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableOrderingComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BuildingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableAnnotationComposer({
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

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get entranceNote => $composableBuilder(
      column: $table.entranceNote, builder: (column) => column);

  GeneratedColumn<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => column);

  GeneratedColumn<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get lastVisitedAt => $composableBuilder(
      column: $table.lastVisitedAt, builder: (column) => column);

  $$VillagesTableAnnotationComposer get villageId {
    final $$VillagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableAnnotationComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> houseRecordsRefs<T extends Object>(
      Expression<T> Function($$HouseRecordsTableAnnotationComposer a) f) {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.buildingId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BuildingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BuildingsTable,
    Building,
    $$BuildingsTableFilterComposer,
    $$BuildingsTableOrderingComposer,
    $$BuildingsTableAnnotationComposer,
    $$BuildingsTableCreateCompanionBuilder,
    $$BuildingsTableUpdateCompanionBuilder,
    (Building, $$BuildingsTableReferences),
    Building,
    PrefetchHooks Function({bool villageId, bool houseRecordsRefs})> {
  $$BuildingsTableTableManager(_$AppDatabase db, $BuildingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> villageId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> entranceNote = const Value.absent(),
            Value<int?> totalFloor = const Value.absent(),
            Value<bool?> hasElevator = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> lastVisitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BuildingsCompanion(
            id: id,
            villageId: villageId,
            name: name,
            status: status,
            tagsJson: tagsJson,
            entranceNote: entranceNote,
            totalFloor: totalFloor,
            hasElevator: hasElevator,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String villageId,
            required String name,
            Value<String> status = const Value.absent(),
            Value<String?> tagsJson = const Value.absent(),
            Value<String?> entranceNote = const Value.absent(),
            Value<int?> totalFloor = const Value.absent(),
            Value<bool?> hasElevator = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> lastVisitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BuildingsCompanion.insert(
            id: id,
            villageId: villageId,
            name: name,
            status: status,
            tagsJson: tagsJson,
            entranceNote: entranceNote,
            totalFloor: totalFloor,
            hasElevator: hasElevator,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            lastVisitedAt: lastVisitedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BuildingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {villageId = false, houseRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (houseRecordsRefs) db.houseRecords],
              addJoins: <
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
                      dynamic>>(state) {
                if (villageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.villageId,
                    referencedTable:
                        $$BuildingsTableReferences._villageIdTable(db),
                    referencedColumn:
                        $$BuildingsTableReferences._villageIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (houseRecordsRefs)
                    await $_getPrefetchedData<Building, $BuildingsTable,
                            HouseRecord>(
                        currentTable: table,
                        referencedTable: $$BuildingsTableReferences
                            ._houseRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BuildingsTableReferences(db, table, p0)
                                .houseRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.buildingId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BuildingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BuildingsTable,
    Building,
    $$BuildingsTableFilterComposer,
    $$BuildingsTableOrderingComposer,
    $$BuildingsTableAnnotationComposer,
    $$BuildingsTableCreateCompanionBuilder,
    $$BuildingsTableUpdateCompanionBuilder,
    (Building, $$BuildingsTableReferences),
    Building,
    PrefetchHooks Function({bool villageId, bool houseRecordsRefs})>;
typedef $$HouseRecordsTableCreateCompanionBuilder = HouseRecordsCompanion
    Function({
  required String id,
  required String title,
  Value<String> status,
  Value<String?> villageId,
  Value<String?> buildingId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> addressText,
  Value<String?> buildingName,
  Value<String?> roomNo,
  required int createdAt,
  required int updatedAt,
  Value<int?> visitedAt,
  Value<int> rowid,
});
typedef $$HouseRecordsTableUpdateCompanionBuilder = HouseRecordsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> status,
  Value<String?> villageId,
  Value<String?> buildingId,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> addressText,
  Value<String?> buildingName,
  Value<String?> roomNo,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int?> visitedAt,
  Value<int> rowid,
});

final class $$HouseRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $HouseRecordsTable, HouseRecord> {
  $$HouseRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VillagesTable _villageIdTable(_$AppDatabase db) =>
      db.villages.createAlias('house_record__village_id__village__id');

  $$VillagesTableProcessedTableManager? get villageId {
    final $_column = $_itemColumn<String>('village_id');
    if ($_column == null) return null;
    final manager = $$VillagesTableTableManager($_db, $_db.villages)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_villageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias('house_record__building_id__building__id');

  $$BuildingsTableProcessedTableManager? get buildingId {
    final $_column = $_itemColumn<String>('building_id');
    if ($_column == null) return null;
    final manager = $$BuildingsTableTableManager($_db, $_db.buildings)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FeeInfosTable, List<FeeInfo>> _feeInfosRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.feeInfos,
          aliasName: 'house_record__id__fee_info__house_id');

  $$FeeInfosTableProcessedTableManager get feeInfosRefs {
    final manager = $$FeeInfosTableTableManager($_db, $_db.feeInfos)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_feeInfosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoomInfosTable, List<RoomInfo>>
      _roomInfosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.roomInfos,
              aliasName: 'house_record__id__room_info__house_id');

  $$RoomInfosTableProcessedTableManager get roomInfosRefs {
    final manager = $$RoomInfosTableTableManager($_db, $_db.roomInfos)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roomInfosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ContactInfosTable, List<ContactInfo>>
      _contactInfosRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.contactInfos,
              aliasName: 'house_record__id__contact_info__house_id');

  $$ContactInfosTableProcessedTableManager get contactInfosRefs {
    final manager = $$ContactInfosTableTableManager($_db, $_db.contactInfos)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contactInfosRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ChecklistItemsTable, List<ChecklistItem>>
      _checklistItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.checklistItems,
              aliasName: 'house_record__id__checklist_item__house_id');

  $$ChecklistItemsTableProcessedTableManager get checklistItemsRefs {
    final manager = $$ChecklistItemsTableTableManager($_db, $_db.checklistItems)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_checklistItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RiskFlagsTable, List<RiskFlag>>
      _riskFlagsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.riskFlags,
              aliasName: 'house_record__id__risk_flag__house_id');

  $$RiskFlagsTableProcessedTableManager get riskFlagsRefs {
    final manager = $$RiskFlagsTableTableManager($_db, $_db.riskFlags)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_riskFlagsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PhotoAssetsTable, List<PhotoAsset>>
      _photoAssetsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.photoAssets,
              aliasName: 'house_record__id__photo_asset__house_id');

  $$PhotoAssetsTableProcessedTableManager get photoAssetsRefs {
    final manager = $$PhotoAssetsTableTableManager($_db, $_db.photoAssets)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photoAssetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MapSnapshotsTable, List<MapSnapshot>>
      _mapSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.mapSnapshots,
              aliasName: 'house_record__id__map_snapshot__house_id');

  $$MapSnapshotsTableProcessedTableManager get mapSnapshotsRefs {
    final manager = $$MapSnapshotsTableTableManager($_db, $_db.mapSnapshots)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mapSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ScoreSnapshotsTable, List<ScoreSnapshot>>
      _scoreSnapshotsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.scoreSnapshots,
              aliasName: 'house_record__id__score_snapshot__house_id');

  $$ScoreSnapshotsTableProcessedTableManager get scoreSnapshotsRefs {
    final manager = $$ScoreSnapshotsTableTableManager($_db, $_db.scoreSnapshots)
        .filter((f) => f.houseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_scoreSnapshotsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$HouseRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $HouseRecordsTable> {
  $$HouseRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressText => $composableBuilder(
      column: $table.addressText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get buildingName => $composableBuilder(
      column: $table.buildingName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roomNo => $composableBuilder(
      column: $table.roomNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get visitedAt => $composableBuilder(
      column: $table.visitedAt, builder: (column) => ColumnFilters(column));

  $$VillagesTableFilterComposer get villageId {
    final $$VillagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableFilterComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableFilterComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> feeInfosRefs(
      Expression<bool> Function($$FeeInfosTableFilterComposer f) f) {
    final $$FeeInfosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.feeInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeeInfosTableFilterComposer(
              $db: $db,
              $table: $db.feeInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roomInfosRefs(
      Expression<bool> Function($$RoomInfosTableFilterComposer f) f) {
    final $$RoomInfosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roomInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomInfosTableFilterComposer(
              $db: $db,
              $table: $db.roomInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> contactInfosRefs(
      Expression<bool> Function($$ContactInfosTableFilterComposer f) f) {
    final $$ContactInfosTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contactInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactInfosTableFilterComposer(
              $db: $db,
              $table: $db.contactInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> checklistItemsRefs(
      Expression<bool> Function($$ChecklistItemsTableFilterComposer f) f) {
    final $$ChecklistItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.checklistItems,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChecklistItemsTableFilterComposer(
              $db: $db,
              $table: $db.checklistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> riskFlagsRefs(
      Expression<bool> Function($$RiskFlagsTableFilterComposer f) f) {
    final $$RiskFlagsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.riskFlags,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RiskFlagsTableFilterComposer(
              $db: $db,
              $table: $db.riskFlags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> photoAssetsRefs(
      Expression<bool> Function($$PhotoAssetsTableFilterComposer f) f) {
    final $$PhotoAssetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photoAssets,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoAssetsTableFilterComposer(
              $db: $db,
              $table: $db.photoAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mapSnapshotsRefs(
      Expression<bool> Function($$MapSnapshotsTableFilterComposer f) f) {
    final $$MapSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mapSnapshots,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MapSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.mapSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> scoreSnapshotsRefs(
      Expression<bool> Function($$ScoreSnapshotsTableFilterComposer f) f) {
    final $$ScoreSnapshotsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scoreSnapshots,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScoreSnapshotsTableFilterComposer(
              $db: $db,
              $table: $db.scoreSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HouseRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $HouseRecordsTable> {
  $$HouseRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressText => $composableBuilder(
      column: $table.addressText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get buildingName => $composableBuilder(
      column: $table.buildingName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roomNo => $composableBuilder(
      column: $table.roomNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get visitedAt => $composableBuilder(
      column: $table.visitedAt, builder: (column) => ColumnOrderings(column));

  $$VillagesTableOrderingComposer get villageId {
    final $$VillagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableOrderingComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableOrderingComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$HouseRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HouseRecordsTable> {
  $$HouseRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get addressText => $composableBuilder(
      column: $table.addressText, builder: (column) => column);

  GeneratedColumn<String> get buildingName => $composableBuilder(
      column: $table.buildingName, builder: (column) => column);

  GeneratedColumn<String> get roomNo =>
      $composableBuilder(column: $table.roomNo, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  $$VillagesTableAnnotationComposer get villageId {
    final $$VillagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.villageId,
        referencedTable: $db.villages,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$VillagesTableAnnotationComposer(
              $db: $db,
              $table: $db.villages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.buildingId,
        referencedTable: $db.buildings,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BuildingsTableAnnotationComposer(
              $db: $db,
              $table: $db.buildings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> feeInfosRefs<T extends Object>(
      Expression<T> Function($$FeeInfosTableAnnotationComposer a) f) {
    final $$FeeInfosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.feeInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FeeInfosTableAnnotationComposer(
              $db: $db,
              $table: $db.feeInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roomInfosRefs<T extends Object>(
      Expression<T> Function($$RoomInfosTableAnnotationComposer a) f) {
    final $$RoomInfosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roomInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoomInfosTableAnnotationComposer(
              $db: $db,
              $table: $db.roomInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> contactInfosRefs<T extends Object>(
      Expression<T> Function($$ContactInfosTableAnnotationComposer a) f) {
    final $$ContactInfosTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.contactInfos,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ContactInfosTableAnnotationComposer(
              $db: $db,
              $table: $db.contactInfos,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> checklistItemsRefs<T extends Object>(
      Expression<T> Function($$ChecklistItemsTableAnnotationComposer a) f) {
    final $$ChecklistItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.checklistItems,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChecklistItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.checklistItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> riskFlagsRefs<T extends Object>(
      Expression<T> Function($$RiskFlagsTableAnnotationComposer a) f) {
    final $$RiskFlagsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.riskFlags,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RiskFlagsTableAnnotationComposer(
              $db: $db,
              $table: $db.riskFlags,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> photoAssetsRefs<T extends Object>(
      Expression<T> Function($$PhotoAssetsTableAnnotationComposer a) f) {
    final $$PhotoAssetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.photoAssets,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PhotoAssetsTableAnnotationComposer(
              $db: $db,
              $table: $db.photoAssets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mapSnapshotsRefs<T extends Object>(
      Expression<T> Function($$MapSnapshotsTableAnnotationComposer a) f) {
    final $$MapSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.mapSnapshots,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MapSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.mapSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> scoreSnapshotsRefs<T extends Object>(
      Expression<T> Function($$ScoreSnapshotsTableAnnotationComposer a) f) {
    final $$ScoreSnapshotsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.scoreSnapshots,
        getReferencedColumn: (t) => t.houseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ScoreSnapshotsTableAnnotationComposer(
              $db: $db,
              $table: $db.scoreSnapshots,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$HouseRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HouseRecordsTable,
    HouseRecord,
    $$HouseRecordsTableFilterComposer,
    $$HouseRecordsTableOrderingComposer,
    $$HouseRecordsTableAnnotationComposer,
    $$HouseRecordsTableCreateCompanionBuilder,
    $$HouseRecordsTableUpdateCompanionBuilder,
    (HouseRecord, $$HouseRecordsTableReferences),
    HouseRecord,
    PrefetchHooks Function(
        {bool villageId,
        bool buildingId,
        bool feeInfosRefs,
        bool roomInfosRefs,
        bool contactInfosRefs,
        bool checklistItemsRefs,
        bool riskFlagsRefs,
        bool photoAssetsRefs,
        bool mapSnapshotsRefs,
        bool scoreSnapshotsRefs})> {
  $$HouseRecordsTableTableManager(_$AppDatabase db, $HouseRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HouseRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HouseRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HouseRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> villageId = const Value.absent(),
            Value<String?> buildingId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> addressText = const Value.absent(),
            Value<String?> buildingName = const Value.absent(),
            Value<String?> roomNo = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int?> visitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseRecordsCompanion(
            id: id,
            title: title,
            status: status,
            villageId: villageId,
            buildingId: buildingId,
            latitude: latitude,
            longitude: longitude,
            addressText: addressText,
            buildingName: buildingName,
            roomNo: roomNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            visitedAt: visitedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            Value<String> status = const Value.absent(),
            Value<String?> villageId = const Value.absent(),
            Value<String?> buildingId = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> addressText = const Value.absent(),
            Value<String?> buildingName = const Value.absent(),
            Value<String?> roomNo = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int?> visitedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseRecordsCompanion.insert(
            id: id,
            title: title,
            status: status,
            villageId: villageId,
            buildingId: buildingId,
            latitude: latitude,
            longitude: longitude,
            addressText: addressText,
            buildingName: buildingName,
            roomNo: roomNo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            visitedAt: visitedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$HouseRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {villageId = false,
              buildingId = false,
              feeInfosRefs = false,
              roomInfosRefs = false,
              contactInfosRefs = false,
              checklistItemsRefs = false,
              riskFlagsRefs = false,
              photoAssetsRefs = false,
              mapSnapshotsRefs = false,
              scoreSnapshotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (feeInfosRefs) db.feeInfos,
                if (roomInfosRefs) db.roomInfos,
                if (contactInfosRefs) db.contactInfos,
                if (checklistItemsRefs) db.checklistItems,
                if (riskFlagsRefs) db.riskFlags,
                if (photoAssetsRefs) db.photoAssets,
                if (mapSnapshotsRefs) db.mapSnapshots,
                if (scoreSnapshotsRefs) db.scoreSnapshots
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (villageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.villageId,
                    referencedTable:
                        $$HouseRecordsTableReferences._villageIdTable(db),
                    referencedColumn:
                        $$HouseRecordsTableReferences._villageIdTable(db).id,
                  ) as T;
                }
                if (buildingId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.buildingId,
                    referencedTable:
                        $$HouseRecordsTableReferences._buildingIdTable(db),
                    referencedColumn:
                        $$HouseRecordsTableReferences._buildingIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (feeInfosRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            FeeInfo>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._feeInfosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .feeInfosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (roomInfosRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            RoomInfo>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._roomInfosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .roomInfosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (contactInfosRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            ContactInfo>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._contactInfosRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .contactInfosRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (checklistItemsRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            ChecklistItem>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._checklistItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .checklistItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (riskFlagsRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            RiskFlag>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._riskFlagsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .riskFlagsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (photoAssetsRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            PhotoAsset>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._photoAssetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .photoAssetsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (mapSnapshotsRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            MapSnapshot>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._mapSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .mapSnapshotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items),
                  if (scoreSnapshotsRefs)
                    await $_getPrefetchedData<HouseRecord, $HouseRecordsTable,
                            ScoreSnapshot>(
                        currentTable: table,
                        referencedTable: $$HouseRecordsTableReferences
                            ._scoreSnapshotsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$HouseRecordsTableReferences(db, table, p0)
                                .scoreSnapshotsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.houseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$HouseRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HouseRecordsTable,
    HouseRecord,
    $$HouseRecordsTableFilterComposer,
    $$HouseRecordsTableOrderingComposer,
    $$HouseRecordsTableAnnotationComposer,
    $$HouseRecordsTableCreateCompanionBuilder,
    $$HouseRecordsTableUpdateCompanionBuilder,
    (HouseRecord, $$HouseRecordsTableReferences),
    HouseRecord,
    PrefetchHooks Function(
        {bool villageId,
        bool buildingId,
        bool feeInfosRefs,
        bool roomInfosRefs,
        bool contactInfosRefs,
        bool checklistItemsRefs,
        bool riskFlagsRefs,
        bool photoAssetsRefs,
        bool mapSnapshotsRefs,
        bool scoreSnapshotsRefs})>;
typedef $$FeeInfosTableCreateCompanionBuilder = FeeInfosCompanion Function({
  required String houseId,
  Value<int?> rentMonthly,
  Value<int?> deposit,
  Value<String?> paymentCycle,
  Value<int?> managementFee,
  Value<int?> internetFee,
  Value<double?> waterUnitPrice,
  Value<double?> electricityUnitPrice,
  Value<int?> gasFee,
  Value<int?> otherFee,
  Value<int?> estimatedTotalMonthly,
  Value<int> rowid,
});
typedef $$FeeInfosTableUpdateCompanionBuilder = FeeInfosCompanion Function({
  Value<String> houseId,
  Value<int?> rentMonthly,
  Value<int?> deposit,
  Value<String?> paymentCycle,
  Value<int?> managementFee,
  Value<int?> internetFee,
  Value<double?> waterUnitPrice,
  Value<double?> electricityUnitPrice,
  Value<int?> gasFee,
  Value<int?> otherFee,
  Value<int?> estimatedTotalMonthly,
  Value<int> rowid,
});

final class $$FeeInfosTableReferences
    extends BaseReferences<_$AppDatabase, $FeeInfosTable, FeeInfo> {
  $$FeeInfosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('fee_info__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FeeInfosTableFilterComposer
    extends Composer<_$AppDatabase, $FeeInfosTable> {
  $$FeeInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get rentMonthly => $composableBuilder(
      column: $table.rentMonthly, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentCycle => $composableBuilder(
      column: $table.paymentCycle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get managementFee => $composableBuilder(
      column: $table.managementFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get internetFee => $composableBuilder(
      column: $table.internetFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get waterUnitPrice => $composableBuilder(
      column: $table.waterUnitPrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get electricityUnitPrice => $composableBuilder(
      column: $table.electricityUnitPrice,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get gasFee => $composableBuilder(
      column: $table.gasFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get otherFee => $composableBuilder(
      column: $table.otherFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get estimatedTotalMonthly => $composableBuilder(
      column: $table.estimatedTotalMonthly,
      builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeeInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeInfosTable> {
  $$FeeInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get rentMonthly => $composableBuilder(
      column: $table.rentMonthly, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get deposit => $composableBuilder(
      column: $table.deposit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentCycle => $composableBuilder(
      column: $table.paymentCycle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get managementFee => $composableBuilder(
      column: $table.managementFee,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get internetFee => $composableBuilder(
      column: $table.internetFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get waterUnitPrice => $composableBuilder(
      column: $table.waterUnitPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get electricityUnitPrice => $composableBuilder(
      column: $table.electricityUnitPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get gasFee => $composableBuilder(
      column: $table.gasFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get otherFee => $composableBuilder(
      column: $table.otherFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get estimatedTotalMonthly => $composableBuilder(
      column: $table.estimatedTotalMonthly,
      builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeeInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeInfosTable> {
  $$FeeInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get rentMonthly => $composableBuilder(
      column: $table.rentMonthly, builder: (column) => column);

  GeneratedColumn<int> get deposit =>
      $composableBuilder(column: $table.deposit, builder: (column) => column);

  GeneratedColumn<String> get paymentCycle => $composableBuilder(
      column: $table.paymentCycle, builder: (column) => column);

  GeneratedColumn<int> get managementFee => $composableBuilder(
      column: $table.managementFee, builder: (column) => column);

  GeneratedColumn<int> get internetFee => $composableBuilder(
      column: $table.internetFee, builder: (column) => column);

  GeneratedColumn<double> get waterUnitPrice => $composableBuilder(
      column: $table.waterUnitPrice, builder: (column) => column);

  GeneratedColumn<double> get electricityUnitPrice => $composableBuilder(
      column: $table.electricityUnitPrice, builder: (column) => column);

  GeneratedColumn<int> get gasFee =>
      $composableBuilder(column: $table.gasFee, builder: (column) => column);

  GeneratedColumn<int> get otherFee =>
      $composableBuilder(column: $table.otherFee, builder: (column) => column);

  GeneratedColumn<int> get estimatedTotalMonthly => $composableBuilder(
      column: $table.estimatedTotalMonthly, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FeeInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeeInfosTable,
    FeeInfo,
    $$FeeInfosTableFilterComposer,
    $$FeeInfosTableOrderingComposer,
    $$FeeInfosTableAnnotationComposer,
    $$FeeInfosTableCreateCompanionBuilder,
    $$FeeInfosTableUpdateCompanionBuilder,
    (FeeInfo, $$FeeInfosTableReferences),
    FeeInfo,
    PrefetchHooks Function({bool houseId})> {
  $$FeeInfosTableTableManager(_$AppDatabase db, $FeeInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> houseId = const Value.absent(),
            Value<int?> rentMonthly = const Value.absent(),
            Value<int?> deposit = const Value.absent(),
            Value<String?> paymentCycle = const Value.absent(),
            Value<int?> managementFee = const Value.absent(),
            Value<int?> internetFee = const Value.absent(),
            Value<double?> waterUnitPrice = const Value.absent(),
            Value<double?> electricityUnitPrice = const Value.absent(),
            Value<int?> gasFee = const Value.absent(),
            Value<int?> otherFee = const Value.absent(),
            Value<int?> estimatedTotalMonthly = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeInfosCompanion(
            houseId: houseId,
            rentMonthly: rentMonthly,
            deposit: deposit,
            paymentCycle: paymentCycle,
            managementFee: managementFee,
            internetFee: internetFee,
            waterUnitPrice: waterUnitPrice,
            electricityUnitPrice: electricityUnitPrice,
            gasFee: gasFee,
            otherFee: otherFee,
            estimatedTotalMonthly: estimatedTotalMonthly,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String houseId,
            Value<int?> rentMonthly = const Value.absent(),
            Value<int?> deposit = const Value.absent(),
            Value<String?> paymentCycle = const Value.absent(),
            Value<int?> managementFee = const Value.absent(),
            Value<int?> internetFee = const Value.absent(),
            Value<double?> waterUnitPrice = const Value.absent(),
            Value<double?> electricityUnitPrice = const Value.absent(),
            Value<int?> gasFee = const Value.absent(),
            Value<int?> otherFee = const Value.absent(),
            Value<int?> estimatedTotalMonthly = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FeeInfosCompanion.insert(
            houseId: houseId,
            rentMonthly: rentMonthly,
            deposit: deposit,
            paymentCycle: paymentCycle,
            managementFee: managementFee,
            internetFee: internetFee,
            waterUnitPrice: waterUnitPrice,
            electricityUnitPrice: electricityUnitPrice,
            gasFee: gasFee,
            otherFee: otherFee,
            estimatedTotalMonthly: estimatedTotalMonthly,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$FeeInfosTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$FeeInfosTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$FeeInfosTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FeeInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeeInfosTable,
    FeeInfo,
    $$FeeInfosTableFilterComposer,
    $$FeeInfosTableOrderingComposer,
    $$FeeInfosTableAnnotationComposer,
    $$FeeInfosTableCreateCompanionBuilder,
    $$FeeInfosTableUpdateCompanionBuilder,
    (FeeInfo, $$FeeInfosTableReferences),
    FeeInfo,
    PrefetchHooks Function({bool houseId})>;
typedef $$RoomInfosTableCreateCompanionBuilder = RoomInfosCompanion Function({
  required String houseId,
  Value<String?> layout,
  Value<double?> area,
  Value<int?> floor,
  Value<int?> totalFloor,
  Value<bool?> hasElevator,
  Value<String?> orientation,
  Value<bool?> hasPrivateBathroom,
  Value<bool?> hasKitchen,
  Value<bool?> canCook,
  Value<bool?> canPet,
  Value<int> rowid,
});
typedef $$RoomInfosTableUpdateCompanionBuilder = RoomInfosCompanion Function({
  Value<String> houseId,
  Value<String?> layout,
  Value<double?> area,
  Value<int?> floor,
  Value<int?> totalFloor,
  Value<bool?> hasElevator,
  Value<String?> orientation,
  Value<bool?> hasPrivateBathroom,
  Value<bool?> hasKitchen,
  Value<bool?> canCook,
  Value<bool?> canPet,
  Value<int> rowid,
});

final class $$RoomInfosTableReferences
    extends BaseReferences<_$AppDatabase, $RoomInfosTable, RoomInfo> {
  $$RoomInfosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('room_info__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoomInfosTableFilterComposer
    extends Composer<_$AppDatabase, $RoomInfosTable> {
  $$RoomInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get layout => $composableBuilder(
      column: $table.layout, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get floor => $composableBuilder(
      column: $table.floor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orientation => $composableBuilder(
      column: $table.orientation, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasPrivateBathroom => $composableBuilder(
      column: $table.hasPrivateBathroom,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasKitchen => $composableBuilder(
      column: $table.hasKitchen, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canCook => $composableBuilder(
      column: $table.canCook, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canPet => $composableBuilder(
      column: $table.canPet, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomInfosTable> {
  $$RoomInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get layout => $composableBuilder(
      column: $table.layout, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get area => $composableBuilder(
      column: $table.area, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get floor => $composableBuilder(
      column: $table.floor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orientation => $composableBuilder(
      column: $table.orientation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasPrivateBathroom => $composableBuilder(
      column: $table.hasPrivateBathroom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasKitchen => $composableBuilder(
      column: $table.hasKitchen, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canCook => $composableBuilder(
      column: $table.canCook, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canPet => $composableBuilder(
      column: $table.canPet, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomInfosTable> {
  $$RoomInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get layout =>
      $composableBuilder(column: $table.layout, builder: (column) => column);

  GeneratedColumn<double> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<int> get floor =>
      $composableBuilder(column: $table.floor, builder: (column) => column);

  GeneratedColumn<int> get totalFloor => $composableBuilder(
      column: $table.totalFloor, builder: (column) => column);

  GeneratedColumn<bool> get hasElevator => $composableBuilder(
      column: $table.hasElevator, builder: (column) => column);

  GeneratedColumn<String> get orientation => $composableBuilder(
      column: $table.orientation, builder: (column) => column);

  GeneratedColumn<bool> get hasPrivateBathroom => $composableBuilder(
      column: $table.hasPrivateBathroom, builder: (column) => column);

  GeneratedColumn<bool> get hasKitchen => $composableBuilder(
      column: $table.hasKitchen, builder: (column) => column);

  GeneratedColumn<bool> get canCook =>
      $composableBuilder(column: $table.canCook, builder: (column) => column);

  GeneratedColumn<bool> get canPet =>
      $composableBuilder(column: $table.canPet, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoomInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoomInfosTable,
    RoomInfo,
    $$RoomInfosTableFilterComposer,
    $$RoomInfosTableOrderingComposer,
    $$RoomInfosTableAnnotationComposer,
    $$RoomInfosTableCreateCompanionBuilder,
    $$RoomInfosTableUpdateCompanionBuilder,
    (RoomInfo, $$RoomInfosTableReferences),
    RoomInfo,
    PrefetchHooks Function({bool houseId})> {
  $$RoomInfosTableTableManager(_$AppDatabase db, $RoomInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> houseId = const Value.absent(),
            Value<String?> layout = const Value.absent(),
            Value<double?> area = const Value.absent(),
            Value<int?> floor = const Value.absent(),
            Value<int?> totalFloor = const Value.absent(),
            Value<bool?> hasElevator = const Value.absent(),
            Value<String?> orientation = const Value.absent(),
            Value<bool?> hasPrivateBathroom = const Value.absent(),
            Value<bool?> hasKitchen = const Value.absent(),
            Value<bool?> canCook = const Value.absent(),
            Value<bool?> canPet = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomInfosCompanion(
            houseId: houseId,
            layout: layout,
            area: area,
            floor: floor,
            totalFloor: totalFloor,
            hasElevator: hasElevator,
            orientation: orientation,
            hasPrivateBathroom: hasPrivateBathroom,
            hasKitchen: hasKitchen,
            canCook: canCook,
            canPet: canPet,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String houseId,
            Value<String?> layout = const Value.absent(),
            Value<double?> area = const Value.absent(),
            Value<int?> floor = const Value.absent(),
            Value<int?> totalFloor = const Value.absent(),
            Value<bool?> hasElevator = const Value.absent(),
            Value<String?> orientation = const Value.absent(),
            Value<bool?> hasPrivateBathroom = const Value.absent(),
            Value<bool?> hasKitchen = const Value.absent(),
            Value<bool?> canCook = const Value.absent(),
            Value<bool?> canPet = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoomInfosCompanion.insert(
            houseId: houseId,
            layout: layout,
            area: area,
            floor: floor,
            totalFloor: totalFloor,
            hasElevator: hasElevator,
            orientation: orientation,
            hasPrivateBathroom: hasPrivateBathroom,
            hasKitchen: hasKitchen,
            canCook: canCook,
            canPet: canPet,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoomInfosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$RoomInfosTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$RoomInfosTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoomInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoomInfosTable,
    RoomInfo,
    $$RoomInfosTableFilterComposer,
    $$RoomInfosTableOrderingComposer,
    $$RoomInfosTableAnnotationComposer,
    $$RoomInfosTableCreateCompanionBuilder,
    $$RoomInfosTableUpdateCompanionBuilder,
    (RoomInfo, $$RoomInfosTableReferences),
    RoomInfo,
    PrefetchHooks Function({bool houseId})>;
typedef $$ContactInfosTableCreateCompanionBuilder = ContactInfosCompanion
    Function({
  required String houseId,
  Value<String?> name,
  Value<String?> role,
  Value<String?> phone,
  Value<String?> wechat,
  Value<bool?> identityVerified,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$ContactInfosTableUpdateCompanionBuilder = ContactInfosCompanion
    Function({
  Value<String> houseId,
  Value<String?> name,
  Value<String?> role,
  Value<String?> phone,
  Value<String?> wechat,
  Value<bool?> identityVerified,
  Value<String?> note,
  Value<int> rowid,
});

final class $$ContactInfosTableReferences
    extends BaseReferences<_$AppDatabase, $ContactInfosTable, ContactInfo> {
  $$ContactInfosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('contact_info__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ContactInfosTableFilterComposer
    extends Composer<_$AppDatabase, $ContactInfosTable> {
  $$ContactInfosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wechat => $composableBuilder(
      column: $table.wechat, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get identityVerified => $composableBuilder(
      column: $table.identityVerified,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactInfosTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactInfosTable> {
  $$ContactInfosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wechat => $composableBuilder(
      column: $table.wechat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get identityVerified => $composableBuilder(
      column: $table.identityVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactInfosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactInfosTable> {
  $$ContactInfosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get wechat =>
      $composableBuilder(column: $table.wechat, builder: (column) => column);

  GeneratedColumn<bool> get identityVerified => $composableBuilder(
      column: $table.identityVerified, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ContactInfosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactInfosTable,
    ContactInfo,
    $$ContactInfosTableFilterComposer,
    $$ContactInfosTableOrderingComposer,
    $$ContactInfosTableAnnotationComposer,
    $$ContactInfosTableCreateCompanionBuilder,
    $$ContactInfosTableUpdateCompanionBuilder,
    (ContactInfo, $$ContactInfosTableReferences),
    ContactInfo,
    PrefetchHooks Function({bool houseId})> {
  $$ContactInfosTableTableManager(_$AppDatabase db, $ContactInfosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactInfosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactInfosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactInfosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> houseId = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> wechat = const Value.absent(),
            Value<bool?> identityVerified = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactInfosCompanion(
            houseId: houseId,
            name: name,
            role: role,
            phone: phone,
            wechat: wechat,
            identityVerified: identityVerified,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String houseId,
            Value<String?> name = const Value.absent(),
            Value<String?> role = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> wechat = const Value.absent(),
            Value<bool?> identityVerified = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactInfosCompanion.insert(
            houseId: houseId,
            name: name,
            role: role,
            phone: phone,
            wechat: wechat,
            identityVerified: identityVerified,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ContactInfosTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$ContactInfosTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$ContactInfosTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ContactInfosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactInfosTable,
    ContactInfo,
    $$ContactInfosTableFilterComposer,
    $$ContactInfosTableOrderingComposer,
    $$ContactInfosTableAnnotationComposer,
    $$ContactInfosTableCreateCompanionBuilder,
    $$ContactInfosTableUpdateCompanionBuilder,
    (ContactInfo, $$ContactInfosTableReferences),
    ContactInfo,
    PrefetchHooks Function({bool houseId})>;
typedef $$ChecklistItemsTableCreateCompanionBuilder = ChecklistItemsCompanion
    Function({
  required String id,
  required String houseId,
  required String module,
  required String key,
  Value<String?> value,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$ChecklistItemsTableUpdateCompanionBuilder = ChecklistItemsCompanion
    Function({
  Value<String> id,
  Value<String> houseId,
  Value<String> module,
  Value<String> key,
  Value<String?> value,
  Value<String?> note,
  Value<int> rowid,
});

final class $$ChecklistItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ChecklistItemsTable, ChecklistItem> {
  $$ChecklistItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('checklist_item__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get module => $composableBuilder(
      column: $table.module, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChecklistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChecklistItemsTable,
    ChecklistItem,
    $$ChecklistItemsTableFilterComposer,
    $$ChecklistItemsTableOrderingComposer,
    $$ChecklistItemsTableAnnotationComposer,
    $$ChecklistItemsTableCreateCompanionBuilder,
    $$ChecklistItemsTableUpdateCompanionBuilder,
    (ChecklistItem, $$ChecklistItemsTableReferences),
    ChecklistItem,
    PrefetchHooks Function({bool houseId})> {
  $$ChecklistItemsTableTableManager(
      _$AppDatabase db, $ChecklistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> houseId = const Value.absent(),
            Value<String> module = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChecklistItemsCompanion(
            id: id,
            houseId: houseId,
            module: module,
            key: key,
            value: value,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String houseId,
            required String module,
            required String key,
            Value<String?> value = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChecklistItemsCompanion.insert(
            id: id,
            houseId: houseId,
            module: module,
            key: key,
            value: value,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ChecklistItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$ChecklistItemsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$ChecklistItemsTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChecklistItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChecklistItemsTable,
    ChecklistItem,
    $$ChecklistItemsTableFilterComposer,
    $$ChecklistItemsTableOrderingComposer,
    $$ChecklistItemsTableAnnotationComposer,
    $$ChecklistItemsTableCreateCompanionBuilder,
    $$ChecklistItemsTableUpdateCompanionBuilder,
    (ChecklistItem, $$ChecklistItemsTableReferences),
    ChecklistItem,
    PrefetchHooks Function({bool houseId})>;
typedef $$RiskFlagsTableCreateCompanionBuilder = RiskFlagsCompanion Function({
  required String id,
  required String houseId,
  required String key,
  required String severity,
  Value<String> source,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$RiskFlagsTableUpdateCompanionBuilder = RiskFlagsCompanion Function({
  Value<String> id,
  Value<String> houseId,
  Value<String> key,
  Value<String> severity,
  Value<String> source,
  Value<String?> note,
  Value<int> rowid,
});

final class $$RiskFlagsTableReferences
    extends BaseReferences<_$AppDatabase, $RiskFlagsTable, RiskFlag> {
  $$RiskFlagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('risk_flag__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RiskFlagsTableFilterComposer
    extends Composer<_$AppDatabase, $RiskFlagsTable> {
  $$RiskFlagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RiskFlagsTableOrderingComposer
    extends Composer<_$AppDatabase, $RiskFlagsTable> {
  $$RiskFlagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RiskFlagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RiskFlagsTable> {
  $$RiskFlagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RiskFlagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RiskFlagsTable,
    RiskFlag,
    $$RiskFlagsTableFilterComposer,
    $$RiskFlagsTableOrderingComposer,
    $$RiskFlagsTableAnnotationComposer,
    $$RiskFlagsTableCreateCompanionBuilder,
    $$RiskFlagsTableUpdateCompanionBuilder,
    (RiskFlag, $$RiskFlagsTableReferences),
    RiskFlag,
    PrefetchHooks Function({bool houseId})> {
  $$RiskFlagsTableTableManager(_$AppDatabase db, $RiskFlagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RiskFlagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RiskFlagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RiskFlagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> houseId = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RiskFlagsCompanion(
            id: id,
            houseId: houseId,
            key: key,
            severity: severity,
            source: source,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String houseId,
            required String key,
            required String severity,
            Value<String> source = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RiskFlagsCompanion.insert(
            id: id,
            houseId: houseId,
            key: key,
            severity: severity,
            source: source,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RiskFlagsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$RiskFlagsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$RiskFlagsTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RiskFlagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RiskFlagsTable,
    RiskFlag,
    $$RiskFlagsTableFilterComposer,
    $$RiskFlagsTableOrderingComposer,
    $$RiskFlagsTableAnnotationComposer,
    $$RiskFlagsTableCreateCompanionBuilder,
    $$RiskFlagsTableUpdateCompanionBuilder,
    (RiskFlag, $$RiskFlagsTableReferences),
    RiskFlag,
    PrefetchHooks Function({bool houseId})>;
typedef $$PhotoAssetsTableCreateCompanionBuilder = PhotoAssetsCompanion
    Function({
  required String id,
  Value<String?> houseId,
  Value<String> ownerType,
  required String ownerId,
  required String localPath,
  required String tag,
  required int takenAt,
  Value<bool> exifRemoved,
  Value<String> storageProvider,
  Value<String?> remoteUrl,
  Value<String?> objectKey,
  Value<int> rowid,
});
typedef $$PhotoAssetsTableUpdateCompanionBuilder = PhotoAssetsCompanion
    Function({
  Value<String> id,
  Value<String?> houseId,
  Value<String> ownerType,
  Value<String> ownerId,
  Value<String> localPath,
  Value<String> tag,
  Value<int> takenAt,
  Value<bool> exifRemoved,
  Value<String> storageProvider,
  Value<String?> remoteUrl,
  Value<String?> objectKey,
  Value<int> rowid,
});

final class $$PhotoAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $PhotoAssetsTable, PhotoAsset> {
  $$PhotoAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('photo_asset__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager? get houseId {
    final $_column = $_itemColumn<String>('house_id');
    if ($_column == null) return null;
    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PhotoAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get exifRemoved => $composableBuilder(
      column: $table.exifRemoved, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get storageProvider => $composableBuilder(
      column: $table.storageProvider,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objectKey => $composableBuilder(
      column: $table.objectKey, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerType => $composableBuilder(
      column: $table.ownerType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localPath => $composableBuilder(
      column: $table.localPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tag => $composableBuilder(
      column: $table.tag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get exifRemoved => $composableBuilder(
      column: $table.exifRemoved, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get storageProvider => $composableBuilder(
      column: $table.storageProvider,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objectKey => $composableBuilder(
      column: $table.objectKey, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotoAssetsTable> {
  $$PhotoAssetsTableAnnotationComposer({
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

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);

  GeneratedColumn<int> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get exifRemoved => $composableBuilder(
      column: $table.exifRemoved, builder: (column) => column);

  GeneratedColumn<String> get storageProvider => $composableBuilder(
      column: $table.storageProvider, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get objectKey =>
      $composableBuilder(column: $table.objectKey, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PhotoAssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotoAssetsTable,
    PhotoAsset,
    $$PhotoAssetsTableFilterComposer,
    $$PhotoAssetsTableOrderingComposer,
    $$PhotoAssetsTableAnnotationComposer,
    $$PhotoAssetsTableCreateCompanionBuilder,
    $$PhotoAssetsTableUpdateCompanionBuilder,
    (PhotoAsset, $$PhotoAssetsTableReferences),
    PhotoAsset,
    PrefetchHooks Function({bool houseId})> {
  $$PhotoAssetsTableTableManager(_$AppDatabase db, $PhotoAssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotoAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotoAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotoAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> houseId = const Value.absent(),
            Value<String> ownerType = const Value.absent(),
            Value<String> ownerId = const Value.absent(),
            Value<String> localPath = const Value.absent(),
            Value<String> tag = const Value.absent(),
            Value<int> takenAt = const Value.absent(),
            Value<bool> exifRemoved = const Value.absent(),
            Value<String> storageProvider = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> objectKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotoAssetsCompanion(
            id: id,
            houseId: houseId,
            ownerType: ownerType,
            ownerId: ownerId,
            localPath: localPath,
            tag: tag,
            takenAt: takenAt,
            exifRemoved: exifRemoved,
            storageProvider: storageProvider,
            remoteUrl: remoteUrl,
            objectKey: objectKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> houseId = const Value.absent(),
            Value<String> ownerType = const Value.absent(),
            required String ownerId,
            required String localPath,
            required String tag,
            required int takenAt,
            Value<bool> exifRemoved = const Value.absent(),
            Value<String> storageProvider = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<String?> objectKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PhotoAssetsCompanion.insert(
            id: id,
            houseId: houseId,
            ownerType: ownerType,
            ownerId: ownerId,
            localPath: localPath,
            tag: tag,
            takenAt: takenAt,
            exifRemoved: exifRemoved,
            storageProvider: storageProvider,
            remoteUrl: remoteUrl,
            objectKey: objectKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PhotoAssetsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$PhotoAssetsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$PhotoAssetsTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PhotoAssetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PhotoAssetsTable,
    PhotoAsset,
    $$PhotoAssetsTableFilterComposer,
    $$PhotoAssetsTableOrderingComposer,
    $$PhotoAssetsTableAnnotationComposer,
    $$PhotoAssetsTableCreateCompanionBuilder,
    $$PhotoAssetsTableUpdateCompanionBuilder,
    (PhotoAsset, $$PhotoAssetsTableReferences),
    PhotoAsset,
    PrefetchHooks Function({bool houseId})>;
typedef $$MapSnapshotsTableCreateCompanionBuilder = MapSnapshotsCompanion
    Function({
  required String houseId,
  Value<String> provider,
  Value<String?> commuteJson,
  Value<String?> poiSummaryJson,
  Value<String?> userCorrectionJson,
  Value<int?> fetchedAt,
  Value<int> rowid,
});
typedef $$MapSnapshotsTableUpdateCompanionBuilder = MapSnapshotsCompanion
    Function({
  Value<String> houseId,
  Value<String> provider,
  Value<String?> commuteJson,
  Value<String?> poiSummaryJson,
  Value<String?> userCorrectionJson,
  Value<int?> fetchedAt,
  Value<int> rowid,
});

final class $$MapSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $MapSnapshotsTable, MapSnapshot> {
  $$MapSnapshotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('map_snapshot__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MapSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $MapSnapshotsTable> {
  $$MapSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commuteJson => $composableBuilder(
      column: $table.commuteJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get poiSummaryJson => $composableBuilder(
      column: $table.poiSummaryJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userCorrectionJson => $composableBuilder(
      column: $table.userCorrectionJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MapSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $MapSnapshotsTable> {
  $$MapSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commuteJson => $composableBuilder(
      column: $table.commuteJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get poiSummaryJson => $composableBuilder(
      column: $table.poiSummaryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userCorrectionJson => $composableBuilder(
      column: $table.userCorrectionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MapSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MapSnapshotsTable> {
  $$MapSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get commuteJson => $composableBuilder(
      column: $table.commuteJson, builder: (column) => column);

  GeneratedColumn<String> get poiSummaryJson => $composableBuilder(
      column: $table.poiSummaryJson, builder: (column) => column);

  GeneratedColumn<String> get userCorrectionJson => $composableBuilder(
      column: $table.userCorrectionJson, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MapSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MapSnapshotsTable,
    MapSnapshot,
    $$MapSnapshotsTableFilterComposer,
    $$MapSnapshotsTableOrderingComposer,
    $$MapSnapshotsTableAnnotationComposer,
    $$MapSnapshotsTableCreateCompanionBuilder,
    $$MapSnapshotsTableUpdateCompanionBuilder,
    (MapSnapshot, $$MapSnapshotsTableReferences),
    MapSnapshot,
    PrefetchHooks Function({bool houseId})> {
  $$MapSnapshotsTableTableManager(_$AppDatabase db, $MapSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MapSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MapSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MapSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> houseId = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String?> commuteJson = const Value.absent(),
            Value<String?> poiSummaryJson = const Value.absent(),
            Value<String?> userCorrectionJson = const Value.absent(),
            Value<int?> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MapSnapshotsCompanion(
            houseId: houseId,
            provider: provider,
            commuteJson: commuteJson,
            poiSummaryJson: poiSummaryJson,
            userCorrectionJson: userCorrectionJson,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String houseId,
            Value<String> provider = const Value.absent(),
            Value<String?> commuteJson = const Value.absent(),
            Value<String?> poiSummaryJson = const Value.absent(),
            Value<String?> userCorrectionJson = const Value.absent(),
            Value<int?> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MapSnapshotsCompanion.insert(
            houseId: houseId,
            provider: provider,
            commuteJson: commuteJson,
            poiSummaryJson: poiSummaryJson,
            userCorrectionJson: userCorrectionJson,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MapSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$MapSnapshotsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$MapSnapshotsTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MapSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MapSnapshotsTable,
    MapSnapshot,
    $$MapSnapshotsTableFilterComposer,
    $$MapSnapshotsTableOrderingComposer,
    $$MapSnapshotsTableAnnotationComposer,
    $$MapSnapshotsTableCreateCompanionBuilder,
    $$MapSnapshotsTableUpdateCompanionBuilder,
    (MapSnapshot, $$MapSnapshotsTableReferences),
    MapSnapshot,
    PrefetchHooks Function({bool houseId})>;
typedef $$ScoreSnapshotsTableCreateCompanionBuilder = ScoreSnapshotsCompanion
    Function({
  required String id,
  required String houseId,
  required String ruleVersion,
  required String hardFilterResult,
  Value<String?> hardFilterReasonsJson,
  required double scoreTotal,
  Value<String?> scoreBreakdownJson,
  Value<String?> explanationJson,
  required int createdAt,
  Value<int> rowid,
});
typedef $$ScoreSnapshotsTableUpdateCompanionBuilder = ScoreSnapshotsCompanion
    Function({
  Value<String> id,
  Value<String> houseId,
  Value<String> ruleVersion,
  Value<String> hardFilterResult,
  Value<String?> hardFilterReasonsJson,
  Value<double> scoreTotal,
  Value<String?> scoreBreakdownJson,
  Value<String?> explanationJson,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$ScoreSnapshotsTableReferences
    extends BaseReferences<_$AppDatabase, $ScoreSnapshotsTable, ScoreSnapshot> {
  $$ScoreSnapshotsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $HouseRecordsTable _houseIdTable(_$AppDatabase db) =>
      db.houseRecords.createAlias('score_snapshot__house_id__house_record__id');

  $$HouseRecordsTableProcessedTableManager get houseId {
    final $_column = $_itemColumn<String>('house_id')!;

    final manager = $$HouseRecordsTableTableManager($_db, $_db.houseRecords)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_houseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ScoreSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $ScoreSnapshotsTable> {
  $$ScoreSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ruleVersion => $composableBuilder(
      column: $table.ruleVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hardFilterResult => $composableBuilder(
      column: $table.hardFilterResult,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hardFilterReasonsJson => $composableBuilder(
      column: $table.hardFilterReasonsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get scoreTotal => $composableBuilder(
      column: $table.scoreTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scoreBreakdownJson => $composableBuilder(
      column: $table.scoreBreakdownJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanationJson => $composableBuilder(
      column: $table.explanationJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$HouseRecordsTableFilterComposer get houseId {
    final $$HouseRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableFilterComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScoreSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $ScoreSnapshotsTable> {
  $$ScoreSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ruleVersion => $composableBuilder(
      column: $table.ruleVersion, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hardFilterResult => $composableBuilder(
      column: $table.hardFilterResult,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hardFilterReasonsJson => $composableBuilder(
      column: $table.hardFilterReasonsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get scoreTotal => $composableBuilder(
      column: $table.scoreTotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scoreBreakdownJson => $composableBuilder(
      column: $table.scoreBreakdownJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanationJson => $composableBuilder(
      column: $table.explanationJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$HouseRecordsTableOrderingComposer get houseId {
    final $$HouseRecordsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableOrderingComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScoreSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScoreSnapshotsTable> {
  $$ScoreSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ruleVersion => $composableBuilder(
      column: $table.ruleVersion, builder: (column) => column);

  GeneratedColumn<String> get hardFilterResult => $composableBuilder(
      column: $table.hardFilterResult, builder: (column) => column);

  GeneratedColumn<String> get hardFilterReasonsJson => $composableBuilder(
      column: $table.hardFilterReasonsJson, builder: (column) => column);

  GeneratedColumn<double> get scoreTotal => $composableBuilder(
      column: $table.scoreTotal, builder: (column) => column);

  GeneratedColumn<String> get scoreBreakdownJson => $composableBuilder(
      column: $table.scoreBreakdownJson, builder: (column) => column);

  GeneratedColumn<String> get explanationJson => $composableBuilder(
      column: $table.explanationJson, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$HouseRecordsTableAnnotationComposer get houseId {
    final $$HouseRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.houseId,
        referencedTable: $db.houseRecords,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$HouseRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.houseRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ScoreSnapshotsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ScoreSnapshotsTable,
    ScoreSnapshot,
    $$ScoreSnapshotsTableFilterComposer,
    $$ScoreSnapshotsTableOrderingComposer,
    $$ScoreSnapshotsTableAnnotationComposer,
    $$ScoreSnapshotsTableCreateCompanionBuilder,
    $$ScoreSnapshotsTableUpdateCompanionBuilder,
    (ScoreSnapshot, $$ScoreSnapshotsTableReferences),
    ScoreSnapshot,
    PrefetchHooks Function({bool houseId})> {
  $$ScoreSnapshotsTableTableManager(
      _$AppDatabase db, $ScoreSnapshotsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScoreSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScoreSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScoreSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> houseId = const Value.absent(),
            Value<String> ruleVersion = const Value.absent(),
            Value<String> hardFilterResult = const Value.absent(),
            Value<String?> hardFilterReasonsJson = const Value.absent(),
            Value<double> scoreTotal = const Value.absent(),
            Value<String?> scoreBreakdownJson = const Value.absent(),
            Value<String?> explanationJson = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ScoreSnapshotsCompanion(
            id: id,
            houseId: houseId,
            ruleVersion: ruleVersion,
            hardFilterResult: hardFilterResult,
            hardFilterReasonsJson: hardFilterReasonsJson,
            scoreTotal: scoreTotal,
            scoreBreakdownJson: scoreBreakdownJson,
            explanationJson: explanationJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String houseId,
            required String ruleVersion,
            required String hardFilterResult,
            Value<String?> hardFilterReasonsJson = const Value.absent(),
            required double scoreTotal,
            Value<String?> scoreBreakdownJson = const Value.absent(),
            Value<String?> explanationJson = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ScoreSnapshotsCompanion.insert(
            id: id,
            houseId: houseId,
            ruleVersion: ruleVersion,
            hardFilterResult: hardFilterResult,
            hardFilterReasonsJson: hardFilterReasonsJson,
            scoreTotal: scoreTotal,
            scoreBreakdownJson: scoreBreakdownJson,
            explanationJson: explanationJson,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ScoreSnapshotsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({houseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (houseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.houseId,
                    referencedTable:
                        $$ScoreSnapshotsTableReferences._houseIdTable(db),
                    referencedColumn:
                        $$ScoreSnapshotsTableReferences._houseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ScoreSnapshotsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ScoreSnapshotsTable,
    ScoreSnapshot,
    $$ScoreSnapshotsTableFilterComposer,
    $$ScoreSnapshotsTableOrderingComposer,
    $$ScoreSnapshotsTableAnnotationComposer,
    $$ScoreSnapshotsTableCreateCompanionBuilder,
    $$ScoreSnapshotsTableUpdateCompanionBuilder,
    (ScoreSnapshot, $$ScoreSnapshotsTableReferences),
    ScoreSnapshot,
    PrefetchHooks Function({bool houseId})>;
typedef $$PreferenceProfilesTableCreateCompanionBuilder
    = PreferenceProfilesCompanion Function({
  required String id,
  Value<int?> maxRentTotal,
  Value<int?> maxCommuteMinutes,
  Value<String?> destinationsJson,
  Value<String?> requiredFeaturesJson,
  Value<String?> weightsJson,
  Value<String?> preferredCommuteMode,
  Value<int> rowid,
});
typedef $$PreferenceProfilesTableUpdateCompanionBuilder
    = PreferenceProfilesCompanion Function({
  Value<String> id,
  Value<int?> maxRentTotal,
  Value<int?> maxCommuteMinutes,
  Value<String?> destinationsJson,
  Value<String?> requiredFeaturesJson,
  Value<String?> weightsJson,
  Value<String?> preferredCommuteMode,
  Value<int> rowid,
});

class $$PreferenceProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferenceProfilesTable> {
  $$PreferenceProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRentTotal => $composableBuilder(
      column: $table.maxRentTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxCommuteMinutes => $composableBuilder(
      column: $table.maxCommuteMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationsJson => $composableBuilder(
      column: $table.destinationsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get requiredFeaturesJson => $composableBuilder(
      column: $table.requiredFeaturesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preferredCommuteMode => $composableBuilder(
      column: $table.preferredCommuteMode,
      builder: (column) => ColumnFilters(column));
}

class $$PreferenceProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferenceProfilesTable> {
  $$PreferenceProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRentTotal => $composableBuilder(
      column: $table.maxRentTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxCommuteMinutes => $composableBuilder(
      column: $table.maxCommuteMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationsJson => $composableBuilder(
      column: $table.destinationsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get requiredFeaturesJson => $composableBuilder(
      column: $table.requiredFeaturesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preferredCommuteMode => $composableBuilder(
      column: $table.preferredCommuteMode,
      builder: (column) => ColumnOrderings(column));
}

class $$PreferenceProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferenceProfilesTable> {
  $$PreferenceProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get maxRentTotal => $composableBuilder(
      column: $table.maxRentTotal, builder: (column) => column);

  GeneratedColumn<int> get maxCommuteMinutes => $composableBuilder(
      column: $table.maxCommuteMinutes, builder: (column) => column);

  GeneratedColumn<String> get destinationsJson => $composableBuilder(
      column: $table.destinationsJson, builder: (column) => column);

  GeneratedColumn<String> get requiredFeaturesJson => $composableBuilder(
      column: $table.requiredFeaturesJson, builder: (column) => column);

  GeneratedColumn<String> get weightsJson => $composableBuilder(
      column: $table.weightsJson, builder: (column) => column);

  GeneratedColumn<String> get preferredCommuteMode => $composableBuilder(
      column: $table.preferredCommuteMode, builder: (column) => column);
}

class $$PreferenceProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PreferenceProfilesTable,
    PreferenceProfile,
    $$PreferenceProfilesTableFilterComposer,
    $$PreferenceProfilesTableOrderingComposer,
    $$PreferenceProfilesTableAnnotationComposer,
    $$PreferenceProfilesTableCreateCompanionBuilder,
    $$PreferenceProfilesTableUpdateCompanionBuilder,
    (
      PreferenceProfile,
      BaseReferences<_$AppDatabase, $PreferenceProfilesTable, PreferenceProfile>
    ),
    PreferenceProfile,
    PrefetchHooks Function()> {
  $$PreferenceProfilesTableTableManager(
      _$AppDatabase db, $PreferenceProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferenceProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferenceProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferenceProfilesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int?> maxRentTotal = const Value.absent(),
            Value<int?> maxCommuteMinutes = const Value.absent(),
            Value<String?> destinationsJson = const Value.absent(),
            Value<String?> requiredFeaturesJson = const Value.absent(),
            Value<String?> weightsJson = const Value.absent(),
            Value<String?> preferredCommuteMode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferenceProfilesCompanion(
            id: id,
            maxRentTotal: maxRentTotal,
            maxCommuteMinutes: maxCommuteMinutes,
            destinationsJson: destinationsJson,
            requiredFeaturesJson: requiredFeaturesJson,
            weightsJson: weightsJson,
            preferredCommuteMode: preferredCommuteMode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int?> maxRentTotal = const Value.absent(),
            Value<int?> maxCommuteMinutes = const Value.absent(),
            Value<String?> destinationsJson = const Value.absent(),
            Value<String?> requiredFeaturesJson = const Value.absent(),
            Value<String?> weightsJson = const Value.absent(),
            Value<String?> preferredCommuteMode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PreferenceProfilesCompanion.insert(
            id: id,
            maxRentTotal: maxRentTotal,
            maxCommuteMinutes: maxCommuteMinutes,
            destinationsJson: destinationsJson,
            requiredFeaturesJson: requiredFeaturesJson,
            weightsJson: weightsJson,
            preferredCommuteMode: preferredCommuteMode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PreferenceProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PreferenceProfilesTable,
    PreferenceProfile,
    $$PreferenceProfilesTableFilterComposer,
    $$PreferenceProfilesTableOrderingComposer,
    $$PreferenceProfilesTableAnnotationComposer,
    $$PreferenceProfilesTableCreateCompanionBuilder,
    $$PreferenceProfilesTableUpdateCompanionBuilder,
    (
      PreferenceProfile,
      BaseReferences<_$AppDatabase, $PreferenceProfilesTable, PreferenceProfile>
    ),
    PreferenceProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VillagesTableTableManager get villages =>
      $$VillagesTableTableManager(_db, _db.villages);
  $$BuildingsTableTableManager get buildings =>
      $$BuildingsTableTableManager(_db, _db.buildings);
  $$HouseRecordsTableTableManager get houseRecords =>
      $$HouseRecordsTableTableManager(_db, _db.houseRecords);
  $$FeeInfosTableTableManager get feeInfos =>
      $$FeeInfosTableTableManager(_db, _db.feeInfos);
  $$RoomInfosTableTableManager get roomInfos =>
      $$RoomInfosTableTableManager(_db, _db.roomInfos);
  $$ContactInfosTableTableManager get contactInfos =>
      $$ContactInfosTableTableManager(_db, _db.contactInfos);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(_db, _db.checklistItems);
  $$RiskFlagsTableTableManager get riskFlags =>
      $$RiskFlagsTableTableManager(_db, _db.riskFlags);
  $$PhotoAssetsTableTableManager get photoAssets =>
      $$PhotoAssetsTableTableManager(_db, _db.photoAssets);
  $$MapSnapshotsTableTableManager get mapSnapshots =>
      $$MapSnapshotsTableTableManager(_db, _db.mapSnapshots);
  $$ScoreSnapshotsTableTableManager get scoreSnapshots =>
      $$ScoreSnapshotsTableTableManager(_db, _db.scoreSnapshots);
  $$PreferenceProfilesTableTableManager get preferenceProfiles =>
      $$PreferenceProfilesTableTableManager(_db, _db.preferenceProfiles);
}
