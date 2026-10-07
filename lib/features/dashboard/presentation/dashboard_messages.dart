const dashboardGreeting = 'Votre tableau de bord';

const dashboardSubtitle =
    'Suivez vos investissements fictifs et continuez votre apprentissage.';

const dashboardEmptyPortfolioTitle = 'Commencez votre portefeuille fictif';

const dashboardEmptyPortfolioBody =
    'Ajoutez une position pour suivre son évolution sans investir d’argent réel.';

const dashboardPortfolioLoading = 'Chargement du portefeuille';

const dashboardCacheMessage =
    'Certaines données peuvent provenir du cache local.';

const dashboardLessonTitle = 'À retenir';

const dashboardLessonBody =
    'Répartir un montant fictif entre plusieurs actifs limite l’effet d’un seul cours. '
    'Une performance passée, y compris avec des versements réguliers, ne dit rien de l’avenir. '
    'Un placement peut perdre de la valeur.';

const dashboardAdviceDisclaimer =
    'Cette application ne fournit pas de conseil financier. Les montants sont fictifs.';

const dashboardShortcutExplorer = 'Explorer les actifs';

const dashboardShortcutPortfolio = 'Portefeuille fictif';

const dashboardShortcutSimulator = 'Simulateur DCA';

const dashboardAddPosition = 'Ajouter une position';

String dashboardRecordedAt(String timestamp) {
  return 'Dernières données enregistrées : $timestamp';
}

String dashboardHoldingCount(int assets, int positions) {
  final assetLabel = assets == 1 ? '1 actif' : '$assets actifs';
  final positionLabel = positions == 1 ? '1 position' : '$positions positions';
  return '$assetLabel · $positionLabel';
}
