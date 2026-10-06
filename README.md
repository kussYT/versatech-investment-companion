# VersaTech Investment Companion

Compagnon pédagogique pour les débutants en investissement. L’application permet d’explorer des actions et des ETF, de consulter leurs historiques, de gérer des favoris, de constituer un portefeuille fictif et de réaliser des simulations.

Le socle visuel, la couche distante et le cache local des données de marché sont en place. L’écran Explorer, les favoris, le portefeuille et les calculs de simulation ne sont pas encore implémentés. Cette branche ne crée pas les tables du portefeuille, des transactions fictives ni des simulations.

## Périmètre Actions et ETF

Le produit se limite aux **actions** et aux **ETF**. Il n’y a pas de passage d’ordres réels : le portefeuille et les simulations restent fictifs et servent à apprendre.

## Données de marché

[Financial Modeling Prep](https://site.financialmodelingprep.com/developer/docs) est l’API REST retenue : une seule source couvre la recherche de symboles, le profil, la dernière cotation et l’historique de fin de journée, pour les actions comme pour les ETF.

Les données utilisées sont :

- le symbole, le nom, la place, la devise et le type (action ou ETF) ;
- le profil : nom, description, secteur, industrie, site, image, devise et place ;
- la dernière cotation : prix, variation, variation en pourcentage, clôture précédente et horodatage ;
- l’historique quotidien : date, ouverture, plus haut, plus bas, clôture et volume.

La clé n’est pas lue au démarrage. Elle est exigée seulement lorsqu’un appel distant est lancé. Passez-la à la compilation, sans la committer :

```bash
flutter run --dart-define=FMP_API_KEY=VOTRE_CLE
```

`VOTRE_CLE` est un exemple. Aucune clé réelle ne doit figurer dans le code, les tests, le README ou l’historique Git. Ne versionnez pas de fichier secret.

Les réponses FMP sont des DTO. Ils sont convertis vers des entités de domaine indépendantes de Dio et de FMP. `FmpMarketDataSource` isole les chemins d’API. `CachedMarketDataRepository` interroge d’abord le cache Drift, puis la source distante, et expose un `CachedResult` : origine, date de dernière synchronisation et indicateur de donnée ancienne. L’interface n’a pas à lire Drift pour connaître la fraîcheur.

`search-symbol` ne fournit pas le type d’instrument. La source le complète par `profile`, au plus cinq fois par recherche. Les résultats sans type au-delà de cette limite sont omis, jamais classés comme actions par défaut.

Les endpoints et les limites du plan FMP devront être revérifiés : l’offre et les quotas changent, et un endpoint peut être restreint selon l’abonnement.

## Cache local

Drift conserve un cache des réponses API. Ce n’est pas encore le stockage des données saisies par l’utilisateur : aucun portefeuille, aucune transaction fictive et aucune simulation n’y sont enregistrés.

Le fichier `versatech_market_cache.sqlite` est créé dans le répertoire de support de l’application et survit à la fermeture du processus. Le schéma est en version 1. La migration est explicite et ne contient encore aucune étape. Les tests ouvrent une base en mémoire, ou un fichier temporaire qu’ils referment.

### Tables

| Table | Clé primaire | Contenu |
| --- | --- | --- |
| `cached_assets` | `symbol` | symbole, nom, type `stock` ou `etf`, place, devise, date de mise à jour |
| `cached_asset_profiles` | `symbol` | nom, description, secteur, industrie, site, image, devise, place, date de mise à jour |
| `cached_market_quotes` | `symbol` | prix, variation, pourcentage, clôture précédente, horodatage de cotation, date de récupération |
| `cached_historical_prices` | `symbol` + `quote_date` | open, high, low, close, volume, date de récupération |
| `cache_metadata` | `resource_key` | dernière synchronisation réussie, dates extrêmes de la donnée, statut, détail |

Les symboles sont normalisés (espaces retirés, majuscules) avant chaque lecture et écriture. L’historique est inséré ou mis à jour sur la clé composée, donc un même jour n’est pas dupliqué. L’écriture d’un lot historique et de ses métadonnées est transactionnelle.

Les montants sont des `REAL` SQLite, soit des doubles IEEE-754, la même représentation que les `double` du domaine. La conversion passe par `FinancialValues`. Les valeurs ne sont pas arrondies au centime : ce cache pédagogique n’offre pas une précision décimale exacte. Les volumes restent des entiers. Une valeur non finie est refusée.

### Fraîcheur

Les durées sont centralisées dans `CachePolicy`. Une horloge injectable (`Clock`, `FixedClock` dans les tests) évite de dépendre de l’heure réelle. Une donnée est fraîche lorsque l’âge depuis `lastSyncedAt` est strictement inférieur à la durée.

| Ressource | Durée |
| --- | --- |
| Recherche et catalogue | 24 heures |
| Profil | 7 jours |
| Dernière cotation | 15 minutes |
| Historique | 24 heures |

L’historique est considéré comme couvert lorsque la période demandée est comprise entre la plus ancienne et la plus récente date déjà synchronisées. Les jours sans cotation à l’intérieur de cet intervalle ne sont pas inventés. Une actualisation réussie renouvelle le délai de 24 heures pour le symbole entier, même si seule une borne manquante a été demandée.

### Dépôt avec cache

1. Lire le cache et sa date de synchronisation.
2. Retourner immédiatement un cache frais, avec `isStale` à faux, sans appel distant.
3. Appeler la source distante si le cache est absent, ancien, incomplet pour la période, ou si `forceRefresh` vaut vrai.
4. Persister une réponse distante valide et la retourner avec la nouvelle date de synchronisation.
5. Si l’appel distant échoue de façon récupérable et qu’un cache utilisable existe, le retourner avec `isStale` à vrai et la cause dans `remoteFailure`.
6. S’il n’existe aucun cache utilisable, propager l’erreur applicative.

`forceRefresh` force l’appel distant même lorsque le cache est encore frais. Il servira à une actualisation manuelle. Le cache ne dépend pas d’une indication de connectivité : seul le résultat réel de l’appel compte.

Le repli vers le cache concerne l’absence de réseau, le délai dépassé, la limitation temporaire, une erreur distante temporaire, une clé absente et un refus d’authentification. La cause reste visible, sans jamais exposer la clé. Une réponse introuvable, invalide ou d’un type non géré n’efface pas un cache valide et n’est pas transformée en succès local. Une recherche distante vide est une réponse valide : elle met à jour le résultat de cette recherche sans supprimer les autres actifs. Un historique distant vide n’efface pas les points déjà stockés.

En cas d’échec d’une recherche distante, la recherche locale porte sur le symbole et le nom, sans tenir compte de la casse. Pour l’historique, seuls les points locaux réellement présents dans la période sont retournés.

### Génération et tests

```bash
dart run build_runner build --delete-conflicting-outputs
flutter test
```

Les fichiers générés par Drift sont versionnés. Il ne faut pas les modifier à la main. `flutter test` exécute aussi les tests de la base, sans appel réseau.

## Prérequis

- Flutter stable **3.27.x** (Dart SDK `^3.6.1`, version vérifiée : Flutter 3.27.3 / Dart 3.6.1)
- Un émulateur, un appareil ou une cible bureau prise en charge par Flutter
- Une clé Financial Modeling Prep, fournie par `--dart-define` au moment d’interroger l’API

## Lancement

```bash
flutter pub get
flutter run --dart-define=FMP_API_KEY=VOTRE_CLE
```

L’interface démarre aussi sans clé. Le premier appel de marché échoue alors avec une erreur de configuration.

## Architecture

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── config/
│   ├── database/
│   ├── errors/
│   ├── network/
│   └── widgets/
├── features/
│   ├── dashboard/presentation/
│   ├── explorer/presentation/
│   ├── market_data/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── dto/
│   │   │   ├── parsing/
│   │   │   └── repositories/
│   │   └── domain/
│   │       ├── cache/
│   │       ├── entities/
│   │       └── repositories/
│   ├── portfolio/presentation/
│   └── simulator/presentation/
└── main.dart
```

La configuration de l’application, la navigation, le thème, les écrans et les données de marché sont séparés. La base et le DAO sont fournis par Riverpod. Aucun widget n’instancie la base. Le portefeuille et les simulations n’ont pas encore de tables.

## Principales dépendances

| Paquet | Rôle |
| --- | --- |
| `flutter_riverpod` 2.6.1 | Injection de dépendances et état |
| `go_router` | Navigation, dont la barre inférieure |
| `dio` 5.11.1 | Client HTTP vers Financial Modeling Prep |
| `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` | Cache SQLite des données de marché |
| `fl_chart` | Graphiques des historiques et simulations |
| `intl` | Formatage des nombres et des dates |
| `build_runner`, `drift_dev` | Génération de code Drift |

`drift` et `drift_dev` sont bornés (`drift` 2.28.x, `drift_dev` 2.28.0) : les versions plus récentes exigent un SDK Dart supérieur à 3.6.1.

## Convention de branches Git

- `main` : branche stable.
- `feat/<sujet>` : nouvelle fonctionnalité ou socle, par exemple `feat/market-data-foundation`.
- `fix/<sujet>` : correction.
- Le travail se fait sur une branche dédiée. Une fonctionnalité n’est fusionnée dans `main` que lorsqu’elle est prête. Cette étape ne pousse rien vers un dépôt distant.
