# VersaTech Investment Companion

Compagnon pédagogique pour les débutants en investissement. L’application permet d’explorer des actions et des ETF, de consulter leurs historiques, de gérer des favoris, de constituer un portefeuille fictif et de réaliser des simulations.

Cette version pose uniquement le socle technique : navigation, thème et structure des écrans. Les données de marché, la persistance complète et les calculs métier ne sont pas encore implémentés.

## Périmètre Actions et ETF

Le produit se limite aux **actions** et aux **ETF**. Il n’y a pas de passage d’ordres réels : le portefeuille et les simulations restent fictifs et servent à apprendre.

## Prérequis

- Flutter stable **3.27.x** (Dart SDK `^3.6.1`, version vérifiée : Flutter 3.27.3 / Dart 3.6.1)
- Un émulateur, un appareil ou une cible bureau prise en charge par Flutter

## Lancement

```bash
flutter pub get
flutter run
```

## Architecture initiale

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── app_shell.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── core/
│   └── widgets/
│       └── feature_placeholder.dart
├── features/
│   ├── dashboard/presentation/
│   ├── explorer/presentation/
│   ├── portfolio/presentation/
│   └── simulator/presentation/
└── main.dart
```

La configuration de l’application, la navigation, le thème et les écrans sont séparés. Les dossiers `core/errors`, `core/network`, `core/database` et `core/utils` seront ajoutés lorsque ces couches existeront réellement.

## Principales dépendances

| Paquet | Rôle |
| --- | --- |
| `flutter_riverpod` | Injection de dépendances et état |
| `go_router` | Navigation, dont la barre inférieure |
| `dio` | Client HTTP, réservé aux futurs appels de marché |
| `drift`, `sqlite3_flutter_libs`, `path_provider`, `path` | Persistance locale, pas encore branchée |
| `fl_chart` | Graphiques des historiques et simulations |
| `intl` | Formatage des nombres et des dates |
| `build_runner`, `drift_dev` | Génération de code Drift |

`drift` et `drift_dev` sont bornés (`drift` 2.28.x, `drift_dev` 2.28.0) : les versions plus récentes exigent un SDK Dart supérieur à 3.6.1.

## Convention de branches Git

- `main` : branche stable.
- `feat/<sujet>` : nouvelle fonctionnalité ou socle, par exemple `feat/project-foundation`.
- `fix/<sujet>` : correction.
- Le travail se fait sur une branche dédiée. Une fonctionnalité n’est fusionnée dans `main` que lorsqu’elle est prête. Cette étape ne pousse rien vers un dépôt distant.
