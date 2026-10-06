// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedAssetsTable extends CachedAssets
    with TableInfo<$CachedAssetsTable, CachedAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _assetTypeMeta =
      const VerificationMeta('assetType');
  @override
  late final GeneratedColumn<String> assetType = GeneratedColumn<String>(
      'asset_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exchangeMeta =
      const VerificationMeta('exchange');
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
      'exchange', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [symbol, name, assetType, exchange, currency, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_assets';
  @override
  VerificationContext validateIntegrity(Insertable<CachedAssetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('asset_type')) {
      context.handle(_assetTypeMeta,
          assetType.isAcceptableOrUnknown(data['asset_type']!, _assetTypeMeta));
    } else if (isInserting) {
      context.missing(_assetTypeMeta);
    }
    if (data.containsKey('exchange')) {
      context.handle(_exchangeMeta,
          exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta));
    } else if (isInserting) {
      context.missing(_exchangeMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  CachedAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAssetRow(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      assetType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_type'])!,
      exchange: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exchange'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedAssetsTable createAlias(String alias) {
    return $CachedAssetsTable(attachedDatabase, alias);
  }
}

class CachedAssetRow extends DataClass implements Insertable<CachedAssetRow> {
  final String symbol;
  final String name;
  final String assetType;
  final String exchange;
  final String currency;
  final DateTime updatedAt;
  const CachedAssetRow(
      {required this.symbol,
      required this.name,
      required this.assetType,
      required this.exchange,
      required this.currency,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['asset_type'] = Variable<String>(assetType);
    map['exchange'] = Variable<String>(exchange);
    map['currency'] = Variable<String>(currency);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedAssetsCompanion toCompanion(bool nullToAbsent) {
    return CachedAssetsCompanion(
      symbol: Value(symbol),
      name: Value(name),
      assetType: Value(assetType),
      exchange: Value(exchange),
      currency: Value(currency),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedAssetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAssetRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      assetType: serializer.fromJson<String>(json['assetType']),
      exchange: serializer.fromJson<String>(json['exchange']),
      currency: serializer.fromJson<String>(json['currency']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'assetType': serializer.toJson<String>(assetType),
      'exchange': serializer.toJson<String>(exchange),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedAssetRow copyWith(
          {String? symbol,
          String? name,
          String? assetType,
          String? exchange,
          String? currency,
          DateTime? updatedAt}) =>
      CachedAssetRow(
        symbol: symbol ?? this.symbol,
        name: name ?? this.name,
        assetType: assetType ?? this.assetType,
        exchange: exchange ?? this.exchange,
        currency: currency ?? this.currency,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedAssetRow copyWithCompanion(CachedAssetsCompanion data) {
    return CachedAssetRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      assetType: data.assetType.present ? data.assetType.value : this.assetType,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      currency: data.currency.present ? data.currency.value : this.currency,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAssetRow(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('assetType: $assetType, ')
          ..write('exchange: $exchange, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(symbol, name, assetType, exchange, currency, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAssetRow &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.assetType == this.assetType &&
          other.exchange == this.exchange &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class CachedAssetsCompanion extends UpdateCompanion<CachedAssetRow> {
  final Value<String> symbol;
  final Value<String> name;
  final Value<String> assetType;
  final Value<String> exchange;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedAssetsCompanion({
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.assetType = const Value.absent(),
    this.exchange = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAssetsCompanion.insert({
    required String symbol,
    required String name,
    required String assetType,
    required String exchange,
    required String currency,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        name = Value(name),
        assetType = Value(assetType),
        exchange = Value(exchange),
        currency = Value(currency),
        updatedAt = Value(updatedAt);
  static Insertable<CachedAssetRow> custom({
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? assetType,
    Expression<String>? exchange,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (assetType != null) 'asset_type': assetType,
      if (exchange != null) 'exchange': exchange,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAssetsCompanion copyWith(
      {Value<String>? symbol,
      Value<String>? name,
      Value<String>? assetType,
      Value<String>? exchange,
      Value<String>? currency,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CachedAssetsCompanion(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      assetType: assetType ?? this.assetType,
      exchange: exchange ?? this.exchange,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (assetType.present) {
      map['asset_type'] = Variable<String>(assetType.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
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
    return (StringBuffer('CachedAssetsCompanion(')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('assetType: $assetType, ')
          ..write('exchange: $exchange, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedAssetProfilesTable extends CachedAssetProfiles
    with TableInfo<$CachedAssetProfilesTable, CachedAssetProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedAssetProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _companyNameMeta =
      const VerificationMeta('companyName');
  @override
  late final GeneratedColumn<String> companyName = GeneratedColumn<String>(
      'company_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
      'sector', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _industryMeta =
      const VerificationMeta('industry');
  @override
  late final GeneratedColumn<String> industry = GeneratedColumn<String>(
      'industry', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _exchangeMeta =
      const VerificationMeta('exchange');
  @override
  late final GeneratedColumn<String> exchange = GeneratedColumn<String>(
      'exchange', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        symbol,
        companyName,
        description,
        sector,
        industry,
        website,
        imageUrl,
        currency,
        exchange,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_asset_profiles';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedAssetProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('company_name')) {
      context.handle(
          _companyNameMeta,
          companyName.isAcceptableOrUnknown(
              data['company_name']!, _companyNameMeta));
    } else if (isInserting) {
      context.missing(_companyNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('sector')) {
      context.handle(_sectorMeta,
          sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta));
    }
    if (data.containsKey('industry')) {
      context.handle(_industryMeta,
          industry.isAcceptableOrUnknown(data['industry']!, _industryMeta));
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('exchange')) {
      context.handle(_exchangeMeta,
          exchange.isAcceptableOrUnknown(data['exchange']!, _exchangeMeta));
    } else if (isInserting) {
      context.missing(_exchangeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  CachedAssetProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedAssetProfileRow(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      companyName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}company_name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      sector: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sector']),
      industry: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}industry']),
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      exchange: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}exchange'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CachedAssetProfilesTable createAlias(String alias) {
    return $CachedAssetProfilesTable(attachedDatabase, alias);
  }
}

class CachedAssetProfileRow extends DataClass
    implements Insertable<CachedAssetProfileRow> {
  final String symbol;
  final String companyName;
  final String description;
  final String? sector;
  final String? industry;
  final String? website;
  final String? imageUrl;
  final String currency;
  final String exchange;
  final DateTime updatedAt;
  const CachedAssetProfileRow(
      {required this.symbol,
      required this.companyName,
      required this.description,
      this.sector,
      this.industry,
      this.website,
      this.imageUrl,
      required this.currency,
      required this.exchange,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['company_name'] = Variable<String>(companyName);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    if (!nullToAbsent || industry != null) {
      map['industry'] = Variable<String>(industry);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['currency'] = Variable<String>(currency);
    map['exchange'] = Variable<String>(exchange);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedAssetProfilesCompanion toCompanion(bool nullToAbsent) {
    return CachedAssetProfilesCompanion(
      symbol: Value(symbol),
      companyName: Value(companyName),
      description: Value(description),
      sector:
          sector == null && nullToAbsent ? const Value.absent() : Value(sector),
      industry: industry == null && nullToAbsent
          ? const Value.absent()
          : Value(industry),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      currency: Value(currency),
      exchange: Value(exchange),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedAssetProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedAssetProfileRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      companyName: serializer.fromJson<String>(json['companyName']),
      description: serializer.fromJson<String>(json['description']),
      sector: serializer.fromJson<String?>(json['sector']),
      industry: serializer.fromJson<String?>(json['industry']),
      website: serializer.fromJson<String?>(json['website']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      currency: serializer.fromJson<String>(json['currency']),
      exchange: serializer.fromJson<String>(json['exchange']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'companyName': serializer.toJson<String>(companyName),
      'description': serializer.toJson<String>(description),
      'sector': serializer.toJson<String?>(sector),
      'industry': serializer.toJson<String?>(industry),
      'website': serializer.toJson<String?>(website),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'currency': serializer.toJson<String>(currency),
      'exchange': serializer.toJson<String>(exchange),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedAssetProfileRow copyWith(
          {String? symbol,
          String? companyName,
          String? description,
          Value<String?> sector = const Value.absent(),
          Value<String?> industry = const Value.absent(),
          Value<String?> website = const Value.absent(),
          Value<String?> imageUrl = const Value.absent(),
          String? currency,
          String? exchange,
          DateTime? updatedAt}) =>
      CachedAssetProfileRow(
        symbol: symbol ?? this.symbol,
        companyName: companyName ?? this.companyName,
        description: description ?? this.description,
        sector: sector.present ? sector.value : this.sector,
        industry: industry.present ? industry.value : this.industry,
        website: website.present ? website.value : this.website,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        currency: currency ?? this.currency,
        exchange: exchange ?? this.exchange,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CachedAssetProfileRow copyWithCompanion(CachedAssetProfilesCompanion data) {
    return CachedAssetProfileRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      companyName:
          data.companyName.present ? data.companyName.value : this.companyName,
      description:
          data.description.present ? data.description.value : this.description,
      sector: data.sector.present ? data.sector.value : this.sector,
      industry: data.industry.present ? data.industry.value : this.industry,
      website: data.website.present ? data.website.value : this.website,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      currency: data.currency.present ? data.currency.value : this.currency,
      exchange: data.exchange.present ? data.exchange.value : this.exchange,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedAssetProfileRow(')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('description: $description, ')
          ..write('sector: $sector, ')
          ..write('industry: $industry, ')
          ..write('website: $website, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('currency: $currency, ')
          ..write('exchange: $exchange, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, companyName, description, sector,
      industry, website, imageUrl, currency, exchange, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedAssetProfileRow &&
          other.symbol == this.symbol &&
          other.companyName == this.companyName &&
          other.description == this.description &&
          other.sector == this.sector &&
          other.industry == this.industry &&
          other.website == this.website &&
          other.imageUrl == this.imageUrl &&
          other.currency == this.currency &&
          other.exchange == this.exchange &&
          other.updatedAt == this.updatedAt);
}

class CachedAssetProfilesCompanion
    extends UpdateCompanion<CachedAssetProfileRow> {
  final Value<String> symbol;
  final Value<String> companyName;
  final Value<String> description;
  final Value<String?> sector;
  final Value<String?> industry;
  final Value<String?> website;
  final Value<String?> imageUrl;
  final Value<String> currency;
  final Value<String> exchange;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedAssetProfilesCompanion({
    this.symbol = const Value.absent(),
    this.companyName = const Value.absent(),
    this.description = const Value.absent(),
    this.sector = const Value.absent(),
    this.industry = const Value.absent(),
    this.website = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.currency = const Value.absent(),
    this.exchange = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedAssetProfilesCompanion.insert({
    required String symbol,
    required String companyName,
    required String description,
    this.sector = const Value.absent(),
    this.industry = const Value.absent(),
    this.website = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required String currency,
    required String exchange,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        companyName = Value(companyName),
        description = Value(description),
        currency = Value(currency),
        exchange = Value(exchange),
        updatedAt = Value(updatedAt);
  static Insertable<CachedAssetProfileRow> custom({
    Expression<String>? symbol,
    Expression<String>? companyName,
    Expression<String>? description,
    Expression<String>? sector,
    Expression<String>? industry,
    Expression<String>? website,
    Expression<String>? imageUrl,
    Expression<String>? currency,
    Expression<String>? exchange,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (companyName != null) 'company_name': companyName,
      if (description != null) 'description': description,
      if (sector != null) 'sector': sector,
      if (industry != null) 'industry': industry,
      if (website != null) 'website': website,
      if (imageUrl != null) 'image_url': imageUrl,
      if (currency != null) 'currency': currency,
      if (exchange != null) 'exchange': exchange,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedAssetProfilesCompanion copyWith(
      {Value<String>? symbol,
      Value<String>? companyName,
      Value<String>? description,
      Value<String?>? sector,
      Value<String?>? industry,
      Value<String?>? website,
      Value<String?>? imageUrl,
      Value<String>? currency,
      Value<String>? exchange,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CachedAssetProfilesCompanion(
      symbol: symbol ?? this.symbol,
      companyName: companyName ?? this.companyName,
      description: description ?? this.description,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      website: website ?? this.website,
      imageUrl: imageUrl ?? this.imageUrl,
      currency: currency ?? this.currency,
      exchange: exchange ?? this.exchange,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (companyName.present) {
      map['company_name'] = Variable<String>(companyName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (industry.present) {
      map['industry'] = Variable<String>(industry.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (exchange.present) {
      map['exchange'] = Variable<String>(exchange.value);
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
    return (StringBuffer('CachedAssetProfilesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('companyName: $companyName, ')
          ..write('description: $description, ')
          ..write('sector: $sector, ')
          ..write('industry: $industry, ')
          ..write('website: $website, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('currency: $currency, ')
          ..write('exchange: $exchange, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedMarketQuotesTable extends CachedMarketQuotes
    with TableInfo<$CachedMarketQuotesTable, CachedMarketQuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedMarketQuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _priceChangeMeta =
      const VerificationMeta('priceChange');
  @override
  late final GeneratedColumn<double> priceChange = GeneratedColumn<double>(
      'price_change', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _changePercentMeta =
      const VerificationMeta('changePercent');
  @override
  late final GeneratedColumn<double> changePercent = GeneratedColumn<double>(
      'change_percent', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _previousCloseMeta =
      const VerificationMeta('previousClose');
  @override
  late final GeneratedColumn<double> previousClose = GeneratedColumn<double>(
      'previous_close', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _quotedAtMeta =
      const VerificationMeta('quotedAt');
  @override
  late final GeneratedColumn<DateTime> quotedAt = GeneratedColumn<DateTime>(
      'quoted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        symbol,
        price,
        priceChange,
        changePercent,
        previousClose,
        quotedAt,
        fetchedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_market_quotes';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedMarketQuoteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('price_change')) {
      context.handle(
          _priceChangeMeta,
          priceChange.isAcceptableOrUnknown(
              data['price_change']!, _priceChangeMeta));
    } else if (isInserting) {
      context.missing(_priceChangeMeta);
    }
    if (data.containsKey('change_percent')) {
      context.handle(
          _changePercentMeta,
          changePercent.isAcceptableOrUnknown(
              data['change_percent']!, _changePercentMeta));
    } else if (isInserting) {
      context.missing(_changePercentMeta);
    }
    if (data.containsKey('previous_close')) {
      context.handle(
          _previousCloseMeta,
          previousClose.isAcceptableOrUnknown(
              data['previous_close']!, _previousCloseMeta));
    }
    if (data.containsKey('quoted_at')) {
      context.handle(_quotedAtMeta,
          quotedAt.isAcceptableOrUnknown(data['quoted_at']!, _quotedAtMeta));
    } else if (isInserting) {
      context.missing(_quotedAtMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  CachedMarketQuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedMarketQuoteRow(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      priceChange: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price_change'])!,
      changePercent: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}change_percent'])!,
      previousClose: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}previous_close']),
      quotedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}quoted_at'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $CachedMarketQuotesTable createAlias(String alias) {
    return $CachedMarketQuotesTable(attachedDatabase, alias);
  }
}

class CachedMarketQuoteRow extends DataClass
    implements Insertable<CachedMarketQuoteRow> {
  final String symbol;
  final double price;
  final double priceChange;
  final double changePercent;
  final double? previousClose;
  final DateTime quotedAt;
  final DateTime fetchedAt;
  const CachedMarketQuoteRow(
      {required this.symbol,
      required this.price,
      required this.priceChange,
      required this.changePercent,
      this.previousClose,
      required this.quotedAt,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['price'] = Variable<double>(price);
    map['price_change'] = Variable<double>(priceChange);
    map['change_percent'] = Variable<double>(changePercent);
    if (!nullToAbsent || previousClose != null) {
      map['previous_close'] = Variable<double>(previousClose);
    }
    map['quoted_at'] = Variable<DateTime>(quotedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedMarketQuotesCompanion toCompanion(bool nullToAbsent) {
    return CachedMarketQuotesCompanion(
      symbol: Value(symbol),
      price: Value(price),
      priceChange: Value(priceChange),
      changePercent: Value(changePercent),
      previousClose: previousClose == null && nullToAbsent
          ? const Value.absent()
          : Value(previousClose),
      quotedAt: Value(quotedAt),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedMarketQuoteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedMarketQuoteRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      price: serializer.fromJson<double>(json['price']),
      priceChange: serializer.fromJson<double>(json['priceChange']),
      changePercent: serializer.fromJson<double>(json['changePercent']),
      previousClose: serializer.fromJson<double?>(json['previousClose']),
      quotedAt: serializer.fromJson<DateTime>(json['quotedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'price': serializer.toJson<double>(price),
      'priceChange': serializer.toJson<double>(priceChange),
      'changePercent': serializer.toJson<double>(changePercent),
      'previousClose': serializer.toJson<double?>(previousClose),
      'quotedAt': serializer.toJson<DateTime>(quotedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedMarketQuoteRow copyWith(
          {String? symbol,
          double? price,
          double? priceChange,
          double? changePercent,
          Value<double?> previousClose = const Value.absent(),
          DateTime? quotedAt,
          DateTime? fetchedAt}) =>
      CachedMarketQuoteRow(
        symbol: symbol ?? this.symbol,
        price: price ?? this.price,
        priceChange: priceChange ?? this.priceChange,
        changePercent: changePercent ?? this.changePercent,
        previousClose:
            previousClose.present ? previousClose.value : this.previousClose,
        quotedAt: quotedAt ?? this.quotedAt,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  CachedMarketQuoteRow copyWithCompanion(CachedMarketQuotesCompanion data) {
    return CachedMarketQuoteRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      price: data.price.present ? data.price.value : this.price,
      priceChange:
          data.priceChange.present ? data.priceChange.value : this.priceChange,
      changePercent: data.changePercent.present
          ? data.changePercent.value
          : this.changePercent,
      previousClose: data.previousClose.present
          ? data.previousClose.value
          : this.previousClose,
      quotedAt: data.quotedAt.present ? data.quotedAt.value : this.quotedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedMarketQuoteRow(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('priceChange: $priceChange, ')
          ..write('changePercent: $changePercent, ')
          ..write('previousClose: $previousClose, ')
          ..write('quotedAt: $quotedAt, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, price, priceChange, changePercent,
      previousClose, quotedAt, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedMarketQuoteRow &&
          other.symbol == this.symbol &&
          other.price == this.price &&
          other.priceChange == this.priceChange &&
          other.changePercent == this.changePercent &&
          other.previousClose == this.previousClose &&
          other.quotedAt == this.quotedAt &&
          other.fetchedAt == this.fetchedAt);
}

class CachedMarketQuotesCompanion
    extends UpdateCompanion<CachedMarketQuoteRow> {
  final Value<String> symbol;
  final Value<double> price;
  final Value<double> priceChange;
  final Value<double> changePercent;
  final Value<double?> previousClose;
  final Value<DateTime> quotedAt;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedMarketQuotesCompanion({
    this.symbol = const Value.absent(),
    this.price = const Value.absent(),
    this.priceChange = const Value.absent(),
    this.changePercent = const Value.absent(),
    this.previousClose = const Value.absent(),
    this.quotedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedMarketQuotesCompanion.insert({
    required String symbol,
    required double price,
    required double priceChange,
    required double changePercent,
    this.previousClose = const Value.absent(),
    required DateTime quotedAt,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        price = Value(price),
        priceChange = Value(priceChange),
        changePercent = Value(changePercent),
        quotedAt = Value(quotedAt),
        fetchedAt = Value(fetchedAt);
  static Insertable<CachedMarketQuoteRow> custom({
    Expression<String>? symbol,
    Expression<double>? price,
    Expression<double>? priceChange,
    Expression<double>? changePercent,
    Expression<double>? previousClose,
    Expression<DateTime>? quotedAt,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (price != null) 'price': price,
      if (priceChange != null) 'price_change': priceChange,
      if (changePercent != null) 'change_percent': changePercent,
      if (previousClose != null) 'previous_close': previousClose,
      if (quotedAt != null) 'quoted_at': quotedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedMarketQuotesCompanion copyWith(
      {Value<String>? symbol,
      Value<double>? price,
      Value<double>? priceChange,
      Value<double>? changePercent,
      Value<double?>? previousClose,
      Value<DateTime>? quotedAt,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return CachedMarketQuotesCompanion(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      priceChange: priceChange ?? this.priceChange,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      quotedAt: quotedAt ?? this.quotedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (priceChange.present) {
      map['price_change'] = Variable<double>(priceChange.value);
    }
    if (changePercent.present) {
      map['change_percent'] = Variable<double>(changePercent.value);
    }
    if (previousClose.present) {
      map['previous_close'] = Variable<double>(previousClose.value);
    }
    if (quotedAt.present) {
      map['quoted_at'] = Variable<DateTime>(quotedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedMarketQuotesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('priceChange: $priceChange, ')
          ..write('changePercent: $changePercent, ')
          ..write('previousClose: $previousClose, ')
          ..write('quotedAt: $quotedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedHistoricalPricesTable extends CachedHistoricalPrices
    with TableInfo<$CachedHistoricalPricesTable, CachedHistoricalPriceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedHistoricalPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quoteDateMeta =
      const VerificationMeta('quoteDate');
  @override
  late final GeneratedColumn<DateTime> quoteDate = GeneratedColumn<DateTime>(
      'quote_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _openMeta = const VerificationMeta('open');
  @override
  late final GeneratedColumn<double> open = GeneratedColumn<double>(
      'open', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _highMeta = const VerificationMeta('high');
  @override
  late final GeneratedColumn<double> high = GeneratedColumn<double>(
      'high', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lowMeta = const VerificationMeta('low');
  @override
  late final GeneratedColumn<double> low = GeneratedColumn<double>(
      'low', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _closeMeta = const VerificationMeta('close');
  @override
  late final GeneratedColumn<double> close = GeneratedColumn<double>(
      'close', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<int> volume = GeneratedColumn<int>(
      'volume', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fetchedAtMeta =
      const VerificationMeta('fetchedAt');
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
      'fetched_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [symbol, quoteDate, open, high, low, close, volume, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_historical_prices';
  @override
  VerificationContext validateIntegrity(
      Insertable<CachedHistoricalPriceRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('quote_date')) {
      context.handle(_quoteDateMeta,
          quoteDate.isAcceptableOrUnknown(data['quote_date']!, _quoteDateMeta));
    } else if (isInserting) {
      context.missing(_quoteDateMeta);
    }
    if (data.containsKey('open')) {
      context.handle(
          _openMeta, open.isAcceptableOrUnknown(data['open']!, _openMeta));
    } else if (isInserting) {
      context.missing(_openMeta);
    }
    if (data.containsKey('high')) {
      context.handle(
          _highMeta, high.isAcceptableOrUnknown(data['high']!, _highMeta));
    } else if (isInserting) {
      context.missing(_highMeta);
    }
    if (data.containsKey('low')) {
      context.handle(
          _lowMeta, low.isAcceptableOrUnknown(data['low']!, _lowMeta));
    } else if (isInserting) {
      context.missing(_lowMeta);
    }
    if (data.containsKey('close')) {
      context.handle(
          _closeMeta, close.isAcceptableOrUnknown(data['close']!, _closeMeta));
    } else if (isInserting) {
      context.missing(_closeMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(_volumeMeta,
          volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta));
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(_fetchedAtMeta,
          fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta));
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol, quoteDate};
  @override
  CachedHistoricalPriceRow map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedHistoricalPriceRow(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      quoteDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}quote_date'])!,
      open: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}open'])!,
      high: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}high'])!,
      low: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}low'])!,
      close: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}close'])!,
      volume: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}volume'])!,
      fetchedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fetched_at'])!,
    );
  }

  @override
  $CachedHistoricalPricesTable createAlias(String alias) {
    return $CachedHistoricalPricesTable(attachedDatabase, alias);
  }
}

class CachedHistoricalPriceRow extends DataClass
    implements Insertable<CachedHistoricalPriceRow> {
  final String symbol;
  final DateTime quoteDate;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final DateTime fetchedAt;
  const CachedHistoricalPriceRow(
      {required this.symbol,
      required this.quoteDate,
      required this.open,
      required this.high,
      required this.low,
      required this.close,
      required this.volume,
      required this.fetchedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['quote_date'] = Variable<DateTime>(quoteDate);
    map['open'] = Variable<double>(open);
    map['high'] = Variable<double>(high);
    map['low'] = Variable<double>(low);
    map['close'] = Variable<double>(close);
    map['volume'] = Variable<int>(volume);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  CachedHistoricalPricesCompanion toCompanion(bool nullToAbsent) {
    return CachedHistoricalPricesCompanion(
      symbol: Value(symbol),
      quoteDate: Value(quoteDate),
      open: Value(open),
      high: Value(high),
      low: Value(low),
      close: Value(close),
      volume: Value(volume),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory CachedHistoricalPriceRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedHistoricalPriceRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      quoteDate: serializer.fromJson<DateTime>(json['quoteDate']),
      open: serializer.fromJson<double>(json['open']),
      high: serializer.fromJson<double>(json['high']),
      low: serializer.fromJson<double>(json['low']),
      close: serializer.fromJson<double>(json['close']),
      volume: serializer.fromJson<int>(json['volume']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'quoteDate': serializer.toJson<DateTime>(quoteDate),
      'open': serializer.toJson<double>(open),
      'high': serializer.toJson<double>(high),
      'low': serializer.toJson<double>(low),
      'close': serializer.toJson<double>(close),
      'volume': serializer.toJson<int>(volume),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  CachedHistoricalPriceRow copyWith(
          {String? symbol,
          DateTime? quoteDate,
          double? open,
          double? high,
          double? low,
          double? close,
          int? volume,
          DateTime? fetchedAt}) =>
      CachedHistoricalPriceRow(
        symbol: symbol ?? this.symbol,
        quoteDate: quoteDate ?? this.quoteDate,
        open: open ?? this.open,
        high: high ?? this.high,
        low: low ?? this.low,
        close: close ?? this.close,
        volume: volume ?? this.volume,
        fetchedAt: fetchedAt ?? this.fetchedAt,
      );
  CachedHistoricalPriceRow copyWithCompanion(
      CachedHistoricalPricesCompanion data) {
    return CachedHistoricalPriceRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      quoteDate: data.quoteDate.present ? data.quoteDate.value : this.quoteDate,
      open: data.open.present ? data.open.value : this.open,
      high: data.high.present ? data.high.value : this.high,
      low: data.low.present ? data.low.value : this.low,
      close: data.close.present ? data.close.value : this.close,
      volume: data.volume.present ? data.volume.value : this.volume,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedHistoricalPriceRow(')
          ..write('symbol: $symbol, ')
          ..write('quoteDate: $quoteDate, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(symbol, quoteDate, open, high, low, close, volume, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedHistoricalPriceRow &&
          other.symbol == this.symbol &&
          other.quoteDate == this.quoteDate &&
          other.open == this.open &&
          other.high == this.high &&
          other.low == this.low &&
          other.close == this.close &&
          other.volume == this.volume &&
          other.fetchedAt == this.fetchedAt);
}

class CachedHistoricalPricesCompanion
    extends UpdateCompanion<CachedHistoricalPriceRow> {
  final Value<String> symbol;
  final Value<DateTime> quoteDate;
  final Value<double> open;
  final Value<double> high;
  final Value<double> low;
  final Value<double> close;
  final Value<int> volume;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const CachedHistoricalPricesCompanion({
    this.symbol = const Value.absent(),
    this.quoteDate = const Value.absent(),
    this.open = const Value.absent(),
    this.high = const Value.absent(),
    this.low = const Value.absent(),
    this.close = const Value.absent(),
    this.volume = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedHistoricalPricesCompanion.insert({
    required String symbol,
    required DateTime quoteDate,
    required double open,
    required double high,
    required double low,
    required double close,
    required int volume,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        quoteDate = Value(quoteDate),
        open = Value(open),
        high = Value(high),
        low = Value(low),
        close = Value(close),
        volume = Value(volume),
        fetchedAt = Value(fetchedAt);
  static Insertable<CachedHistoricalPriceRow> custom({
    Expression<String>? symbol,
    Expression<DateTime>? quoteDate,
    Expression<double>? open,
    Expression<double>? high,
    Expression<double>? low,
    Expression<double>? close,
    Expression<int>? volume,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (quoteDate != null) 'quote_date': quoteDate,
      if (open != null) 'open': open,
      if (high != null) 'high': high,
      if (low != null) 'low': low,
      if (close != null) 'close': close,
      if (volume != null) 'volume': volume,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedHistoricalPricesCompanion copyWith(
      {Value<String>? symbol,
      Value<DateTime>? quoteDate,
      Value<double>? open,
      Value<double>? high,
      Value<double>? low,
      Value<double>? close,
      Value<int>? volume,
      Value<DateTime>? fetchedAt,
      Value<int>? rowid}) {
    return CachedHistoricalPricesCompanion(
      symbol: symbol ?? this.symbol,
      quoteDate: quoteDate ?? this.quoteDate,
      open: open ?? this.open,
      high: high ?? this.high,
      low: low ?? this.low,
      close: close ?? this.close,
      volume: volume ?? this.volume,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (quoteDate.present) {
      map['quote_date'] = Variable<DateTime>(quoteDate.value);
    }
    if (open.present) {
      map['open'] = Variable<double>(open.value);
    }
    if (high.present) {
      map['high'] = Variable<double>(high.value);
    }
    if (low.present) {
      map['low'] = Variable<double>(low.value);
    }
    if (close.present) {
      map['close'] = Variable<double>(close.value);
    }
    if (volume.present) {
      map['volume'] = Variable<int>(volume.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedHistoricalPricesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('quoteDate: $quoteDate, ')
          ..write('open: $open, ')
          ..write('high: $high, ')
          ..write('low: $low, ')
          ..write('close: $close, ')
          ..write('volume: $volume, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CacheMetadataTable extends CacheMetadata
    with TableInfo<$CacheMetadataTable, CacheMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceKeyMeta =
      const VerificationMeta('resourceKey');
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
      'resource_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _newestDataAtMeta =
      const VerificationMeta('newestDataAt');
  @override
  late final GeneratedColumn<DateTime> newestDataAt = GeneratedColumn<DateTime>(
      'newest_data_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _oldestDataAtMeta =
      const VerificationMeta('oldestDataAt');
  @override
  late final GeneratedColumn<DateTime> oldestDataAt = GeneratedColumn<DateTime>(
      'oldest_data_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [resourceKey, lastSyncedAt, newestDataAt, oldestDataAt, status, detail];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_metadata';
  @override
  VerificationContext validateIntegrity(Insertable<CacheMetadataRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_key')) {
      context.handle(
          _resourceKeyMeta,
          resourceKey.isAcceptableOrUnknown(
              data['resource_key']!, _resourceKeyMeta));
    } else if (isInserting) {
      context.missing(_resourceKeyMeta);
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    } else if (isInserting) {
      context.missing(_lastSyncedAtMeta);
    }
    if (data.containsKey('newest_data_at')) {
      context.handle(
          _newestDataAtMeta,
          newestDataAt.isAcceptableOrUnknown(
              data['newest_data_at']!, _newestDataAtMeta));
    }
    if (data.containsKey('oldest_data_at')) {
      context.handle(
          _oldestDataAtMeta,
          oldestDataAt.isAcceptableOrUnknown(
              data['oldest_data_at']!, _oldestDataAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceKey};
  @override
  CacheMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMetadataRow(
      resourceKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_key'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at'])!,
      newestDataAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}newest_data_at']),
      oldestDataAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}oldest_data_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail']),
    );
  }

  @override
  $CacheMetadataTable createAlias(String alias) {
    return $CacheMetadataTable(attachedDatabase, alias);
  }
}

class CacheMetadataRow extends DataClass
    implements Insertable<CacheMetadataRow> {
  final String resourceKey;
  final DateTime lastSyncedAt;
  final DateTime? newestDataAt;
  final DateTime? oldestDataAt;
  final String status;
  final String? detail;
  const CacheMetadataRow(
      {required this.resourceKey,
      required this.lastSyncedAt,
      this.newestDataAt,
      this.oldestDataAt,
      required this.status,
      this.detail});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_key'] = Variable<String>(resourceKey);
    map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    if (!nullToAbsent || newestDataAt != null) {
      map['newest_data_at'] = Variable<DateTime>(newestDataAt);
    }
    if (!nullToAbsent || oldestDataAt != null) {
      map['oldest_data_at'] = Variable<DateTime>(oldestDataAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  CacheMetadataCompanion toCompanion(bool nullToAbsent) {
    return CacheMetadataCompanion(
      resourceKey: Value(resourceKey),
      lastSyncedAt: Value(lastSyncedAt),
      newestDataAt: newestDataAt == null && nullToAbsent
          ? const Value.absent()
          : Value(newestDataAt),
      oldestDataAt: oldestDataAt == null && nullToAbsent
          ? const Value.absent()
          : Value(oldestDataAt),
      status: Value(status),
      detail:
          detail == null && nullToAbsent ? const Value.absent() : Value(detail),
    );
  }

  factory CacheMetadataRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMetadataRow(
      resourceKey: serializer.fromJson<String>(json['resourceKey']),
      lastSyncedAt: serializer.fromJson<DateTime>(json['lastSyncedAt']),
      newestDataAt: serializer.fromJson<DateTime?>(json['newestDataAt']),
      oldestDataAt: serializer.fromJson<DateTime?>(json['oldestDataAt']),
      status: serializer.fromJson<String>(json['status']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceKey': serializer.toJson<String>(resourceKey),
      'lastSyncedAt': serializer.toJson<DateTime>(lastSyncedAt),
      'newestDataAt': serializer.toJson<DateTime?>(newestDataAt),
      'oldestDataAt': serializer.toJson<DateTime?>(oldestDataAt),
      'status': serializer.toJson<String>(status),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  CacheMetadataRow copyWith(
          {String? resourceKey,
          DateTime? lastSyncedAt,
          Value<DateTime?> newestDataAt = const Value.absent(),
          Value<DateTime?> oldestDataAt = const Value.absent(),
          String? status,
          Value<String?> detail = const Value.absent()}) =>
      CacheMetadataRow(
        resourceKey: resourceKey ?? this.resourceKey,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        newestDataAt:
            newestDataAt.present ? newestDataAt.value : this.newestDataAt,
        oldestDataAt:
            oldestDataAt.present ? oldestDataAt.value : this.oldestDataAt,
        status: status ?? this.status,
        detail: detail.present ? detail.value : this.detail,
      );
  CacheMetadataRow copyWithCompanion(CacheMetadataCompanion data) {
    return CacheMetadataRow(
      resourceKey:
          data.resourceKey.present ? data.resourceKey.value : this.resourceKey,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      newestDataAt: data.newestDataAt.present
          ? data.newestDataAt.value
          : this.newestDataAt,
      oldestDataAt: data.oldestDataAt.present
          ? data.oldestDataAt.value
          : this.oldestDataAt,
      status: data.status.present ? data.status.value : this.status,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataRow(')
          ..write('resourceKey: $resourceKey, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('newestDataAt: $newestDataAt, ')
          ..write('oldestDataAt: $oldestDataAt, ')
          ..write('status: $status, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      resourceKey, lastSyncedAt, newestDataAt, oldestDataAt, status, detail);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMetadataRow &&
          other.resourceKey == this.resourceKey &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.newestDataAt == this.newestDataAt &&
          other.oldestDataAt == this.oldestDataAt &&
          other.status == this.status &&
          other.detail == this.detail);
}

class CacheMetadataCompanion extends UpdateCompanion<CacheMetadataRow> {
  final Value<String> resourceKey;
  final Value<DateTime> lastSyncedAt;
  final Value<DateTime?> newestDataAt;
  final Value<DateTime?> oldestDataAt;
  final Value<String> status;
  final Value<String?> detail;
  final Value<int> rowid;
  const CacheMetadataCompanion({
    this.resourceKey = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.newestDataAt = const Value.absent(),
    this.oldestDataAt = const Value.absent(),
    this.status = const Value.absent(),
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetadataCompanion.insert({
    required String resourceKey,
    required DateTime lastSyncedAt,
    this.newestDataAt = const Value.absent(),
    this.oldestDataAt = const Value.absent(),
    required String status,
    this.detail = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : resourceKey = Value(resourceKey),
        lastSyncedAt = Value(lastSyncedAt),
        status = Value(status);
  static Insertable<CacheMetadataRow> custom({
    Expression<String>? resourceKey,
    Expression<DateTime>? lastSyncedAt,
    Expression<DateTime>? newestDataAt,
    Expression<DateTime>? oldestDataAt,
    Expression<String>? status,
    Expression<String>? detail,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceKey != null) 'resource_key': resourceKey,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (newestDataAt != null) 'newest_data_at': newestDataAt,
      if (oldestDataAt != null) 'oldest_data_at': oldestDataAt,
      if (status != null) 'status': status,
      if (detail != null) 'detail': detail,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetadataCompanion copyWith(
      {Value<String>? resourceKey,
      Value<DateTime>? lastSyncedAt,
      Value<DateTime?>? newestDataAt,
      Value<DateTime?>? oldestDataAt,
      Value<String>? status,
      Value<String?>? detail,
      Value<int>? rowid}) {
    return CacheMetadataCompanion(
      resourceKey: resourceKey ?? this.resourceKey,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      newestDataAt: newestDataAt ?? this.newestDataAt,
      oldestDataAt: oldestDataAt ?? this.oldestDataAt,
      status: status ?? this.status,
      detail: detail ?? this.detail,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (newestDataAt.present) {
      map['newest_data_at'] = Variable<DateTime>(newestDataAt.value);
    }
    if (oldestDataAt.present) {
      map['oldest_data_at'] = Variable<DateTime>(oldestDataAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetadataCompanion(')
          ..write('resourceKey: $resourceKey, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('newestDataAt: $newestDataAt, ')
          ..write('oldestDataAt: $oldestDataAt, ')
          ..write('status: $status, ')
          ..write('detail: $detail, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [symbol, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorites';
  @override
  VerificationContext validateIntegrity(Insertable<FavoriteRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
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
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final String symbol;
  final DateTime createdAt;
  const FavoriteRow({required this.symbol, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      symbol: Value(symbol),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      symbol: serializer.fromJson<String>(json['symbol']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({String? symbol, DateTime? createdAt}) => FavoriteRow(
        symbol: symbol ?? this.symbol,
        createdAt: createdAt ?? this.createdAt,
      );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('symbol: $symbol, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.symbol == this.symbol &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<String> symbol;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FavoritesCompanion({
    this.symbol = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoritesCompanion.insert({
    required String symbol,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : symbol = Value(symbol),
        createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<String>? symbol,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoritesCompanion copyWith(
      {Value<String>? symbol, Value<DateTime>? createdAt, Value<int>? rowid}) {
    return FavoritesCompanion(
      symbol: symbol ?? this.symbol,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
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
    return (StringBuffer('FavoritesCompanion(')
          ..write('symbol: $symbol, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedAssetsTable cachedAssets = $CachedAssetsTable(this);
  late final $CachedAssetProfilesTable cachedAssetProfiles =
      $CachedAssetProfilesTable(this);
  late final $CachedMarketQuotesTable cachedMarketQuotes =
      $CachedMarketQuotesTable(this);
  late final $CachedHistoricalPricesTable cachedHistoricalPrices =
      $CachedHistoricalPricesTable(this);
  late final $CacheMetadataTable cacheMetadata = $CacheMetadataTable(this);
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final MarketDataDao marketDataDao = MarketDataDao(this as AppDatabase);
  late final FavoriteDao favoriteDao = FavoriteDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        cachedAssets,
        cachedAssetProfiles,
        cachedMarketQuotes,
        cachedHistoricalPrices,
        cacheMetadata,
        favorites
      ];
}

typedef $$CachedAssetsTableCreateCompanionBuilder = CachedAssetsCompanion
    Function({
  required String symbol,
  required String name,
  required String assetType,
  required String exchange,
  required String currency,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CachedAssetsTableUpdateCompanionBuilder = CachedAssetsCompanion
    Function({
  Value<String> symbol,
  Value<String> name,
  Value<String> assetType,
  Value<String> exchange,
  Value<String> currency,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CachedAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetType => $composableBuilder(
      column: $table.assetType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exchange => $composableBuilder(
      column: $table.exchange, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetType => $composableBuilder(
      column: $table.assetType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exchange => $composableBuilder(
      column: $table.exchange, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAssetsTable> {
  $$CachedAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get assetType =>
      $composableBuilder(column: $table.assetType, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedAssetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAssetsTable,
    CachedAssetRow,
    $$CachedAssetsTableFilterComposer,
    $$CachedAssetsTableOrderingComposer,
    $$CachedAssetsTableAnnotationComposer,
    $$CachedAssetsTableCreateCompanionBuilder,
    $$CachedAssetsTableUpdateCompanionBuilder,
    (
      CachedAssetRow,
      BaseReferences<_$AppDatabase, $CachedAssetsTable, CachedAssetRow>
    ),
    CachedAssetRow,
    PrefetchHooks Function()> {
  $$CachedAssetsTableTableManager(_$AppDatabase db, $CachedAssetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> assetType = const Value.absent(),
            Value<String> exchange = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedAssetsCompanion(
            symbol: symbol,
            name: name,
            assetType: assetType,
            exchange: exchange,
            currency: currency,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required String name,
            required String assetType,
            required String exchange,
            required String currency,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedAssetsCompanion.insert(
            symbol: symbol,
            name: name,
            assetType: assetType,
            exchange: exchange,
            currency: currency,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAssetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAssetsTable,
    CachedAssetRow,
    $$CachedAssetsTableFilterComposer,
    $$CachedAssetsTableOrderingComposer,
    $$CachedAssetsTableAnnotationComposer,
    $$CachedAssetsTableCreateCompanionBuilder,
    $$CachedAssetsTableUpdateCompanionBuilder,
    (
      CachedAssetRow,
      BaseReferences<_$AppDatabase, $CachedAssetsTable, CachedAssetRow>
    ),
    CachedAssetRow,
    PrefetchHooks Function()>;
typedef $$CachedAssetProfilesTableCreateCompanionBuilder
    = CachedAssetProfilesCompanion Function({
  required String symbol,
  required String companyName,
  required String description,
  Value<String?> sector,
  Value<String?> industry,
  Value<String?> website,
  Value<String?> imageUrl,
  required String currency,
  required String exchange,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CachedAssetProfilesTableUpdateCompanionBuilder
    = CachedAssetProfilesCompanion Function({
  Value<String> symbol,
  Value<String> companyName,
  Value<String> description,
  Value<String?> sector,
  Value<String?> industry,
  Value<String?> website,
  Value<String?> imageUrl,
  Value<String> currency,
  Value<String> exchange,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$CachedAssetProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedAssetProfilesTable> {
  $$CachedAssetProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sector => $composableBuilder(
      column: $table.sector, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get industry => $composableBuilder(
      column: $table.industry, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get exchange => $composableBuilder(
      column: $table.exchange, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedAssetProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedAssetProfilesTable> {
  $$CachedAssetProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sector => $composableBuilder(
      column: $table.sector, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get industry => $composableBuilder(
      column: $table.industry, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currency => $composableBuilder(
      column: $table.currency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get exchange => $composableBuilder(
      column: $table.exchange, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedAssetProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedAssetProfilesTable> {
  $$CachedAssetProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get companyName => $composableBuilder(
      column: $table.companyName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get industry =>
      $composableBuilder(column: $table.industry, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get exchange =>
      $composableBuilder(column: $table.exchange, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedAssetProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedAssetProfilesTable,
    CachedAssetProfileRow,
    $$CachedAssetProfilesTableFilterComposer,
    $$CachedAssetProfilesTableOrderingComposer,
    $$CachedAssetProfilesTableAnnotationComposer,
    $$CachedAssetProfilesTableCreateCompanionBuilder,
    $$CachedAssetProfilesTableUpdateCompanionBuilder,
    (
      CachedAssetProfileRow,
      BaseReferences<_$AppDatabase, $CachedAssetProfilesTable,
          CachedAssetProfileRow>
    ),
    CachedAssetProfileRow,
    PrefetchHooks Function()> {
  $$CachedAssetProfilesTableTableManager(
      _$AppDatabase db, $CachedAssetProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedAssetProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedAssetProfilesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedAssetProfilesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<String> companyName = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String?> sector = const Value.absent(),
            Value<String?> industry = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<String> currency = const Value.absent(),
            Value<String> exchange = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedAssetProfilesCompanion(
            symbol: symbol,
            companyName: companyName,
            description: description,
            sector: sector,
            industry: industry,
            website: website,
            imageUrl: imageUrl,
            currency: currency,
            exchange: exchange,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required String companyName,
            required String description,
            Value<String?> sector = const Value.absent(),
            Value<String?> industry = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            required String currency,
            required String exchange,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedAssetProfilesCompanion.insert(
            symbol: symbol,
            companyName: companyName,
            description: description,
            sector: sector,
            industry: industry,
            website: website,
            imageUrl: imageUrl,
            currency: currency,
            exchange: exchange,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedAssetProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedAssetProfilesTable,
    CachedAssetProfileRow,
    $$CachedAssetProfilesTableFilterComposer,
    $$CachedAssetProfilesTableOrderingComposer,
    $$CachedAssetProfilesTableAnnotationComposer,
    $$CachedAssetProfilesTableCreateCompanionBuilder,
    $$CachedAssetProfilesTableUpdateCompanionBuilder,
    (
      CachedAssetProfileRow,
      BaseReferences<_$AppDatabase, $CachedAssetProfilesTable,
          CachedAssetProfileRow>
    ),
    CachedAssetProfileRow,
    PrefetchHooks Function()>;
typedef $$CachedMarketQuotesTableCreateCompanionBuilder
    = CachedMarketQuotesCompanion Function({
  required String symbol,
  required double price,
  required double priceChange,
  required double changePercent,
  Value<double?> previousClose,
  required DateTime quotedAt,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$CachedMarketQuotesTableUpdateCompanionBuilder
    = CachedMarketQuotesCompanion Function({
  Value<String> symbol,
  Value<double> price,
  Value<double> priceChange,
  Value<double> changePercent,
  Value<double?> previousClose,
  Value<DateTime> quotedAt,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$CachedMarketQuotesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedMarketQuotesTable> {
  $$CachedMarketQuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get changePercent => $composableBuilder(
      column: $table.changePercent, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get previousClose => $composableBuilder(
      column: $table.previousClose, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get quotedAt => $composableBuilder(
      column: $table.quotedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedMarketQuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedMarketQuotesTable> {
  $$CachedMarketQuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get changePercent => $composableBuilder(
      column: $table.changePercent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get previousClose => $composableBuilder(
      column: $table.previousClose,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get quotedAt => $composableBuilder(
      column: $table.quotedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedMarketQuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedMarketQuotesTable> {
  $$CachedMarketQuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get priceChange => $composableBuilder(
      column: $table.priceChange, builder: (column) => column);

  GeneratedColumn<double> get changePercent => $composableBuilder(
      column: $table.changePercent, builder: (column) => column);

  GeneratedColumn<double> get previousClose => $composableBuilder(
      column: $table.previousClose, builder: (column) => column);

  GeneratedColumn<DateTime> get quotedAt =>
      $composableBuilder(column: $table.quotedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedMarketQuotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedMarketQuotesTable,
    CachedMarketQuoteRow,
    $$CachedMarketQuotesTableFilterComposer,
    $$CachedMarketQuotesTableOrderingComposer,
    $$CachedMarketQuotesTableAnnotationComposer,
    $$CachedMarketQuotesTableCreateCompanionBuilder,
    $$CachedMarketQuotesTableUpdateCompanionBuilder,
    (
      CachedMarketQuoteRow,
      BaseReferences<_$AppDatabase, $CachedMarketQuotesTable,
          CachedMarketQuoteRow>
    ),
    CachedMarketQuoteRow,
    PrefetchHooks Function()> {
  $$CachedMarketQuotesTableTableManager(
      _$AppDatabase db, $CachedMarketQuotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedMarketQuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedMarketQuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedMarketQuotesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> priceChange = const Value.absent(),
            Value<double> changePercent = const Value.absent(),
            Value<double?> previousClose = const Value.absent(),
            Value<DateTime> quotedAt = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMarketQuotesCompanion(
            symbol: symbol,
            price: price,
            priceChange: priceChange,
            changePercent: changePercent,
            previousClose: previousClose,
            quotedAt: quotedAt,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required double price,
            required double priceChange,
            required double changePercent,
            Value<double?> previousClose = const Value.absent(),
            required DateTime quotedAt,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedMarketQuotesCompanion.insert(
            symbol: symbol,
            price: price,
            priceChange: priceChange,
            changePercent: changePercent,
            previousClose: previousClose,
            quotedAt: quotedAt,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedMarketQuotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CachedMarketQuotesTable,
    CachedMarketQuoteRow,
    $$CachedMarketQuotesTableFilterComposer,
    $$CachedMarketQuotesTableOrderingComposer,
    $$CachedMarketQuotesTableAnnotationComposer,
    $$CachedMarketQuotesTableCreateCompanionBuilder,
    $$CachedMarketQuotesTableUpdateCompanionBuilder,
    (
      CachedMarketQuoteRow,
      BaseReferences<_$AppDatabase, $CachedMarketQuotesTable,
          CachedMarketQuoteRow>
    ),
    CachedMarketQuoteRow,
    PrefetchHooks Function()>;
typedef $$CachedHistoricalPricesTableCreateCompanionBuilder
    = CachedHistoricalPricesCompanion Function({
  required String symbol,
  required DateTime quoteDate,
  required double open,
  required double high,
  required double low,
  required double close,
  required int volume,
  required DateTime fetchedAt,
  Value<int> rowid,
});
typedef $$CachedHistoricalPricesTableUpdateCompanionBuilder
    = CachedHistoricalPricesCompanion Function({
  Value<String> symbol,
  Value<DateTime> quoteDate,
  Value<double> open,
  Value<double> high,
  Value<double> low,
  Value<double> close,
  Value<int> volume,
  Value<DateTime> fetchedAt,
  Value<int> rowid,
});

class $$CachedHistoricalPricesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedHistoricalPricesTable> {
  $$CachedHistoricalPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get quoteDate => $composableBuilder(
      column: $table.quoteDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get open => $composableBuilder(
      column: $table.open, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get high => $composableBuilder(
      column: $table.high, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get low => $composableBuilder(
      column: $table.low, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get close => $composableBuilder(
      column: $table.close, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnFilters(column));
}

class $$CachedHistoricalPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedHistoricalPricesTable> {
  $$CachedHistoricalPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get quoteDate => $composableBuilder(
      column: $table.quoteDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get open => $composableBuilder(
      column: $table.open, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get high => $composableBuilder(
      column: $table.high, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get low => $composableBuilder(
      column: $table.low, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get close => $composableBuilder(
      column: $table.close, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get volume => $composableBuilder(
      column: $table.volume, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
      column: $table.fetchedAt, builder: (column) => ColumnOrderings(column));
}

class $$CachedHistoricalPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedHistoricalPricesTable> {
  $$CachedHistoricalPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<DateTime> get quoteDate =>
      $composableBuilder(column: $table.quoteDate, builder: (column) => column);

  GeneratedColumn<double> get open =>
      $composableBuilder(column: $table.open, builder: (column) => column);

  GeneratedColumn<double> get high =>
      $composableBuilder(column: $table.high, builder: (column) => column);

  GeneratedColumn<double> get low =>
      $composableBuilder(column: $table.low, builder: (column) => column);

  GeneratedColumn<double> get close =>
      $composableBuilder(column: $table.close, builder: (column) => column);

  GeneratedColumn<int> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $$CachedHistoricalPricesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CachedHistoricalPricesTable,
    CachedHistoricalPriceRow,
    $$CachedHistoricalPricesTableFilterComposer,
    $$CachedHistoricalPricesTableOrderingComposer,
    $$CachedHistoricalPricesTableAnnotationComposer,
    $$CachedHistoricalPricesTableCreateCompanionBuilder,
    $$CachedHistoricalPricesTableUpdateCompanionBuilder,
    (
      CachedHistoricalPriceRow,
      BaseReferences<_$AppDatabase, $CachedHistoricalPricesTable,
          CachedHistoricalPriceRow>
    ),
    CachedHistoricalPriceRow,
    PrefetchHooks Function()> {
  $$CachedHistoricalPricesTableTableManager(
      _$AppDatabase db, $CachedHistoricalPricesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedHistoricalPricesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedHistoricalPricesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedHistoricalPricesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<DateTime> quoteDate = const Value.absent(),
            Value<double> open = const Value.absent(),
            Value<double> high = const Value.absent(),
            Value<double> low = const Value.absent(),
            Value<double> close = const Value.absent(),
            Value<int> volume = const Value.absent(),
            Value<DateTime> fetchedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedHistoricalPricesCompanion(
            symbol: symbol,
            quoteDate: quoteDate,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required DateTime quoteDate,
            required double open,
            required double high,
            required double low,
            required double close,
            required int volume,
            required DateTime fetchedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedHistoricalPricesCompanion.insert(
            symbol: symbol,
            quoteDate: quoteDate,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            fetchedAt: fetchedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedHistoricalPricesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $CachedHistoricalPricesTable,
        CachedHistoricalPriceRow,
        $$CachedHistoricalPricesTableFilterComposer,
        $$CachedHistoricalPricesTableOrderingComposer,
        $$CachedHistoricalPricesTableAnnotationComposer,
        $$CachedHistoricalPricesTableCreateCompanionBuilder,
        $$CachedHistoricalPricesTableUpdateCompanionBuilder,
        (
          CachedHistoricalPriceRow,
          BaseReferences<_$AppDatabase, $CachedHistoricalPricesTable,
              CachedHistoricalPriceRow>
        ),
        CachedHistoricalPriceRow,
        PrefetchHooks Function()>;
typedef $$CacheMetadataTableCreateCompanionBuilder = CacheMetadataCompanion
    Function({
  required String resourceKey,
  required DateTime lastSyncedAt,
  Value<DateTime?> newestDataAt,
  Value<DateTime?> oldestDataAt,
  required String status,
  Value<String?> detail,
  Value<int> rowid,
});
typedef $$CacheMetadataTableUpdateCompanionBuilder = CacheMetadataCompanion
    Function({
  Value<String> resourceKey,
  Value<DateTime> lastSyncedAt,
  Value<DateTime?> newestDataAt,
  Value<DateTime?> oldestDataAt,
  Value<String> status,
  Value<String?> detail,
  Value<int> rowid,
});

class $$CacheMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get resourceKey => $composableBuilder(
      column: $table.resourceKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get newestDataAt => $composableBuilder(
      column: $table.newestDataAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get oldestDataAt => $composableBuilder(
      column: $table.oldestDataAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));
}

class $$CacheMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get resourceKey => $composableBuilder(
      column: $table.resourceKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get newestDataAt => $composableBuilder(
      column: $table.newestDataAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get oldestDataAt => $composableBuilder(
      column: $table.oldestDataAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));
}

class $$CacheMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetadataTable> {
  $$CacheMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get resourceKey => $composableBuilder(
      column: $table.resourceKey, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get newestDataAt => $composableBuilder(
      column: $table.newestDataAt, builder: (column) => column);

  GeneratedColumn<DateTime> get oldestDataAt => $composableBuilder(
      column: $table.oldestDataAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$CacheMetadataTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CacheMetadataTable,
    CacheMetadataRow,
    $$CacheMetadataTableFilterComposer,
    $$CacheMetadataTableOrderingComposer,
    $$CacheMetadataTableAnnotationComposer,
    $$CacheMetadataTableCreateCompanionBuilder,
    $$CacheMetadataTableUpdateCompanionBuilder,
    (
      CacheMetadataRow,
      BaseReferences<_$AppDatabase, $CacheMetadataTable, CacheMetadataRow>
    ),
    CacheMetadataRow,
    PrefetchHooks Function()> {
  $$CacheMetadataTableTableManager(_$AppDatabase db, $CacheMetadataTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> resourceKey = const Value.absent(),
            Value<DateTime> lastSyncedAt = const Value.absent(),
            Value<DateTime?> newestDataAt = const Value.absent(),
            Value<DateTime?> oldestDataAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> detail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheMetadataCompanion(
            resourceKey: resourceKey,
            lastSyncedAt: lastSyncedAt,
            newestDataAt: newestDataAt,
            oldestDataAt: oldestDataAt,
            status: status,
            detail: detail,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String resourceKey,
            required DateTime lastSyncedAt,
            Value<DateTime?> newestDataAt = const Value.absent(),
            Value<DateTime?> oldestDataAt = const Value.absent(),
            required String status,
            Value<String?> detail = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CacheMetadataCompanion.insert(
            resourceKey: resourceKey,
            lastSyncedAt: lastSyncedAt,
            newestDataAt: newestDataAt,
            oldestDataAt: oldestDataAt,
            status: status,
            detail: detail,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CacheMetadataTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CacheMetadataTable,
    CacheMetadataRow,
    $$CacheMetadataTableFilterComposer,
    $$CacheMetadataTableOrderingComposer,
    $$CacheMetadataTableAnnotationComposer,
    $$CacheMetadataTableCreateCompanionBuilder,
    $$CacheMetadataTableUpdateCompanionBuilder,
    (
      CacheMetadataRow,
      BaseReferences<_$AppDatabase, $CacheMetadataTable, CacheMetadataRow>
    ),
    CacheMetadataRow,
    PrefetchHooks Function()>;
typedef $$FavoritesTableCreateCompanionBuilder = FavoritesCompanion Function({
  required String symbol,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FavoritesTableUpdateCompanionBuilder = FavoritesCompanion Function({
  Value<String> symbol,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$FavoritesTableFilterComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FavoritesTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FavoritesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoritesTable> {
  $$FavoritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoritesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (FavoriteRow, BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>),
    FavoriteRow,
    PrefetchHooks Function()> {
  $$FavoritesTableTableManager(_$AppDatabase db, $FavoritesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> symbol = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion(
            symbol: symbol,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String symbol,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FavoritesCompanion.insert(
            symbol: symbol,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FavoritesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FavoritesTable,
    FavoriteRow,
    $$FavoritesTableFilterComposer,
    $$FavoritesTableOrderingComposer,
    $$FavoritesTableAnnotationComposer,
    $$FavoritesTableCreateCompanionBuilder,
    $$FavoritesTableUpdateCompanionBuilder,
    (FavoriteRow, BaseReferences<_$AppDatabase, $FavoritesTable, FavoriteRow>),
    FavoriteRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedAssetsTableTableManager get cachedAssets =>
      $$CachedAssetsTableTableManager(_db, _db.cachedAssets);
  $$CachedAssetProfilesTableTableManager get cachedAssetProfiles =>
      $$CachedAssetProfilesTableTableManager(_db, _db.cachedAssetProfiles);
  $$CachedMarketQuotesTableTableManager get cachedMarketQuotes =>
      $$CachedMarketQuotesTableTableManager(_db, _db.cachedMarketQuotes);
  $$CachedHistoricalPricesTableTableManager get cachedHistoricalPrices =>
      $$CachedHistoricalPricesTableTableManager(
          _db, _db.cachedHistoricalPrices);
  $$CacheMetadataTableTableManager get cacheMetadata =>
      $$CacheMetadataTableTableManager(_db, _db.cacheMetadata);
  $$FavoritesTableTableManager get favorites =>
      $$FavoritesTableTableManager(_db, _db.favorites);
}
