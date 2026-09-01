# AtelierPro Mobile

Application mobile **open source** (Flutter) de gestion d'atelier pour artisans nigériens
(couture/confection notamment) : clients, commandes, fiches de mesures, paiements.

> ⚠️ Projet **indépendant** de NiyaJobs et de l'AtelierPro web (PWA). Base de code séparée,
> variables d'environnement séparées (`.env` local ici, pas de `VITE_*` ni `EXPO_PUBLIC_*`).
> **Infrastructure Firebase** (`ateliers`, `clients`, `commandes`, `fiches_mesures`,
> `paiements`). Les règles de sécurité Firebase (Firestore Rules) garantissent que
> chaque artisan ne voit **que son atelier**.
> Le paiement mobile money (iPayMoney) **n'est pas encore intégré** — les paiements se
> saisissent manuellement pour l'instant depuis chaque commande.

## Stack

- **Flutter** (Dart) — cross-platform, compile en APK Android natif, portable vers iOS plus tard
- **Firebase** (`firebase_core`, `firebase_auth`, `cloud_firestore`) — backend sécurisé et temps réel
- **provider** — gestion d'état
- **go_router** — navigation déclarative

## Prérequis

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installé (`flutter doctor` doit être vert)
2. [Android Studio](https://developer.android.com/studio) avec le plugin Flutter/Dart installé
3. Le projet Firebase **atelier-pro-1a9e8** configuré

## Mise en route

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Générer les dossiers de plateforme (android/, ios/) si pas déjà fait
flutter create . --platforms=android,ios --org com.zinderdigital

# 3. Configurer les variables d'environnement
cp .env.example .env
# puis éditer .env avec les clés API de votre projet Firebase

# 4. Lancer sur un émulateur ou un téléphone branché en USB (débogage activé)
flutter run
```

## Générer l'APK

```bash
flutter build apk --release
# L'APK se trouve dans : build/app/outputs/flutter-apk/app-release.apk
```

Pour l'ouvrir directement dans **Android Studio** : `File > Open`, sélectionner le dossier
`atelierpro_mobile`, laisser Android Studio synchroniser Gradle, puis `Build > Build Bundle(s) / APK(s) > Build APK(s)`.

## Structure du projet

```
lib/
  core/            # thème, routeur
  models/          # Atelier, Client, Commande, Paiement, FicheMesure
  providers/       # état applicatif (auth, atelier, clients, commandes, fiches de mesures)
  screens/
    auth/
    onboarding/
    dashboard/
    clients/
    orders/          # commandes
    mesures/         # fiches de mesures clients
    settings/
  widgets/         # composants réutilisables
supabase/
  schema.sql       # schéma de référence (documentation — reflète la base réelle)
```

## Schéma de données (base réelle, confirmée le 29/08/2026)

```
ateliers       : id, user_id, nom_atelier, telephone, ville, specialite, logo_url, created_at, updated_at
clients        : id, user_id, nom_complet, telephone, adresse, notes, photo_url, created_at, updated_at
commandes      : id, user_id, client_id, fiche_mesure_id, description, statut(enum statut_commande),
                 date_commande, date_echeance, prix_total, acompte, solde(généré = prix_total - acompte)
fiches_mesures : id, user_id, client_id, titre, mesures(jsonb), notes, created_at, updated_at
paiements      : id, user_id, commande_id, montant, mode, date_paiement, created_at
```

Pas de table `atelier_members` : un atelier appartient directement à `user_id` (relation 1-pour-1
avec le compte connecté). `supabase/schema.sql` documente ce schéma exact et est sans danger à
rejouer (idempotent), mais n'a normalement **rien à faire** puisque ces tables existent déjà.

⚠️ Les valeurs de l'enum `statut_commande` utilisées dans `lib/models/order.dart`
(`en_attente`, `en_cours`, `termine`, `livre`) sont une hypothèse à confirmer avec :
```sql
select enumlabel from pg_enum
join pg_type on pg_type.oid = pg_enum.enumtypid
where pg_type.typname = 'statut_commande'
order by enumsortorder;
```

## Roadmap paiement mobile money

L'intégration iPayMoney (Airtel Money, Wave, Moov Flooz, Zamani Cash, Nita, Amanata) côté web
sera portée ici dans une prochaine étape, une fois le cœur de l'app validé. À noter : le fichier
`20260819_ipaymoney_transactions.sql` fourni référence des tables `orders`/`payments`/
`atelier_members` qui ne correspondent pas aux vraies tables (`commandes`/`paiements`, pas de
`atelier_members`) — il faudra l'adapter avant de l'exécuter.

## Licence

MIT — voir [LICENSE](./LICENSE).
