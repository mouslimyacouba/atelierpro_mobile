# Plan d'amélioration et de débogage - AtelierPro

Amélioration de la robustesse de l'application, correction de bugs sur la gestion des commandes et amélioration de l'expérience utilisateur sur les formulaires.

## User Review Required

> [!IMPORTANT]
> La correction sur `updateOrder` dans `OrdersProvider` changera légèrement le comportement : la fiche de mesures ne pourra plus être "détachée" (mise à NULL) via cette méthode simple sans passer explicitement une valeur spéciale ou modifier l'appel. Pour l'instant, l'UI ne permet pas de détacher une fiche, donc c'est sans risque immédiat.

## Proposed Changes

### [Core/Providers]

#### [MODIFY] [orders_provider.dart](file:///C:/Users/mousl/OneDrive/Desktop/atelierpro_mobile/lib/providers/orders_provider.dart)
- Modifier `updateOrder` pour ne mettre à jour `fiche_mesure_id` que si la valeur est explicitement fournie et non nulle (ou gérer le cas de modification intentionnelle).
- Améliorer la gestion des erreurs lors de la mise à jour du statut.

### [Screens/Orders]

#### [MODIFY] [order_detail_screen.dart](file:///C:/Users/mousl/OneDrive/Desktop/atelierpro_mobile/lib/screens/orders/order_detail_screen.dart)
- Utiliser `double.tryParse` pour les montants et afficher une erreur propre si la saisie est invalide.
- Gérer le retour d'erreur de `updateStatus` avec une SnackBar.
- Empêcher l'appel à `updateOrder` d'écraser la fiche de mesures existante.

#### [MODIFY] [new_order_screen.dart](file:///C:/Users/mousl/OneDrive/Desktop/atelierpro_mobile/lib/screens/orders/new_order_screen.dart)
- Sécuriser le parsing du montant total.

### [Screens/Mesures]

#### [MODIFY] [mesures_screen.dart](file:///C:/Users/mousl/OneDrive/Desktop/atelierpro_mobile/lib/screens/mesures/mesures_screen.dart)
- Ajouter une `Scrollbar` visible dans le formulaire des mesures.
- Améliorer la validation des champs numériques pour les mesures.

## Verification Plan

### Automated Tests
- N/A (Tests unitaires non configurés pour Supabase dans ce projet).

### Manual Verification
1. Créer une commande liée à une fiche de mesures.
2. Modifier la description de la commande et vérifier que la fiche reste liée.
3. Tenter de saisir un montant avec des caractères invalides et vérifier l'alerte.
4. Changer le statut en mode avion (simulé) et vérifier l'apparition d'une SnackBar d'erreur.
5. Ouvrir le formulaire de mesures et vérifier le défilement fluide.
