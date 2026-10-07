# VersaTech Investment Companion

Compagnon pédagogique pour les débutants en investissement. L’application permet d’explorer des actions et des ETF, de consulter leurs historiques, de gérer des favoris, de constituer un portefeuille fictif et de réaliser des simulations.

Le socle visuel, l’écran Explorer, la fiche d’actif et le cache Drift sont en place. Les favoris persistants sont disponibles. Le portefeuille fictif est enregistré sur l’appareil : positions, montants investis, valorisation à partir du cache de marché et répartition. Il ne passe aucun ordre réel et ne dépend pas d’un appel réseau pour être modifié. Le simulateur DCA mensuel estime un investissement passé à partir de l’historique déjà fourni par le cache de marché. Il n’enregistre pas la simulation et ne projette pas l’avenir.

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

Les réponses FMP sont des DTO. Ils sont convertis vers des entités de domaine indépendantes de Dio et de FMP. `FmpMarketDataSource` isole les chemins d’API. `MarketDataRepository` expose la recherche, le profil, la cotation et l’historique, et transforme les erreurs techniques en erreurs applicatives.

Les endpoints et les limites du plan FMP devront être revérifiés : l’offre et les quotas changent, et un endpoint peut être restreint selon l’abonnement.

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
│   │       ├── entities/
│   │       └── repositories/
│   ├── portfolio/presentation/
│   └── simulator/presentation/
└── main.dart
```

La configuration de l’application, la navigation, le thème, les écrans et les données de marché sont séparés. Le cache local et le schéma Drift seront ajoutés lorsque cette couche existera.

## Principales dépendances

| Paquet | Rôle |
| --- | --- |
| `flutter_riverpod` 2.6.1 | Injection de dépendances et état |
| `go_router` | Navigation, dont la barre inférieure |
| `dio` 5.11.1 | Client HTTP vers Financial Modeling Prep |
| `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` | Cache de marché et favoris locaux |
| `fl_chart` | Graphiques des historiques et simulations |
| `intl` | Formatage des nombres et des dates |
| `build_runner`, `drift_dev` | Génération de code Drift |

`drift` et `drift_dev` sont bornés (`drift` 2.28.x, `drift_dev` 2.28.0) : les versions plus récentes exigent un SDK Dart supérieur à 3.6.1.

## Convention de branches Git

- `main` : branche stable.
- `feat/<sujet>` : nouvelle fonctionnalité ou socle, par exemple `feat/market-data-foundation`.
- `fix/<sujet>` : correction.
- Le travail se fait sur une branche dédiée. Une fonctionnalité n’est fusionnée dans `main` que lorsqu’elle est prête. Cette étape ne pousse rien vers un dépôt distant.
