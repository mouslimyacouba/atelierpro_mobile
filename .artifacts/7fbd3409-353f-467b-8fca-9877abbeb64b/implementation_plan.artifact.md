# Implementation Plan - Enhancements and Bug Fixes

This plan addresses authentication flow improvements, real-time data updates, receipt generation, and general usability enhancements for AtelierPro.

## Proposed Changes

### 1. Authentication and Onboarding

#### [MODIFY] [auth_screen.dart](file:///C:/dev/atelierpro_mobile/lib/screens/auth/auth_screen.dart)
- Update `_submit` to sign out users after successful signup, clear fields, and show a confirmation message on the login screen.
- Improve error handling and loading states for a smoother experience.

#### [MODIFY] [onboarding_screen.dart](file:///C:/dev/atelierpro_mobile/lib/screens/onboarding/onboarding_screen.dart)
- Optimize the atelier creation flow to ensure immediate redirection upon success.

### 2. Real-time Data Synchronization
Switch from one-time fetches (`get()`) to real-time listeners (`snapshots()`) for a "live" feel, as requested by the user.

#### [MODIFY] [clients_provider.dart](file:///C:/dev/atelierpro_mobile/lib/providers/clients_provider.dart)
- Implement `StreamSubscription` for real-time client updates.
- Refactor `load()` to start a listener.

#### [MODIFY] [orders_provider.dart](file:///C:/dev/atelierpro_mobile/lib/providers/orders_provider.dart)
- Implement `StreamSubscription` for real-time order and payment updates.

#### [MODIFY] [fiches_mesures_provider.dart](file:///C:/dev/atelierpro_mobile/lib/providers/fiches_mesures_provider.dart)
- Implement `StreamSubscription` for real-time measurement sheet updates.

### 3. Order Management and Receipts

#### [MODIFY] [order_detail_screen.dart](file:///C:/dev/atelierpro_mobile/lib/screens/orders/order_detail_screen.dart)
- Enhance the WhatsApp button with a dedicated logo for better visibility.
- Refine the text receipt format to be more professional.
- Add a "Print/View Receipt" option (visualizing a professional receipt).

#### [MODIFY] [payment.dart](file:///C:/dev/atelierpro_mobile/lib/models/payment.dart)
- Ensure all mobile money modes (Moov Flooz, Airtel Money, etc.) are correctly represented and accessible.

### 4. Usability and UI

#### [MODIFY] [client_detail_screen.dart](file:///C:/dev/atelierpro_mobile/lib/screens/clients/client_detail_screen.dart)
- Add quick actions for reminders (order status, payments) directly from the client profile.

## Verification Plan

### Automated Tests
- N/A (Manual verification on device is preferred for UI/Real-time flows).

### Manual Verification
1. **Signup Flow**: Create a new account, verify the confirmation message appears, and check that the user is redirected to the login screen.
2. **Atelier Creation**: Log in with a new account, create an atelier, and verify immediate redirection to the dashboard.
3. **Real-time Updates**: Open the app on two devices (or simulator + Firebase Console). Change a client's name or add a payment in the console and verify the app updates instantly without refreshing.
4. **Receipts**: Generate a receipt for a dummy order and share it via WhatsApp. Verify the formatting and the WhatsApp icon.
