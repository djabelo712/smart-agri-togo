// Rapport d'audit sécurité SmartFarm Togo — mis à jour après correctifs
//
// 🔴 CRITIQUE — corrigé
// - [x] JWT / URL API → flutter_secure_storage
// - [x] URL API production + clés ML corrigées
// - [x] Validation cellId, Ks, cultures avant appels API
//
// 🟠 ÉLEVÉ — corrigé
// - [x] Timeout session 30 min + SessionActivityScope
// - [x] Double confirmation actions hardware critiques
// - [x] Plus de log de token FCM en clair
// - [x] Rate limiting client Dio
// - [x] Login API enregistre JWT + désactive mode démo
//
// 🟡 MOYEN — corrigé
// - [x] Timeouts réseau 10s / 30s (+ 60s health Render)
// - [x] AppLogger centralisé (hors logger.dart lui-même)
// - [x] AppException typées
//
// 🟢 FAIBLE — corrigé
// - [x] Bandeau DemoDataBanner (champ simulé / API)
// - [x] test/security_test.dart + test/widget_test.dart
//
// Checklist finale (code) :
// - [x] Token JWT dans flutter_secure_storage
// - [x] URL API configurable et sécurisée
// - [x] Entrées validées avant API
// - [x] Double confirmation hardware
// - [x] Session 30 min
// - [x] Pas de print sensible en production
// - [x] Rate limiting client
// - [x] Timeouts réseau
// - [x] Mode démo sans fuite (données locales/mock)
// - [x] kDebugMode pour logging

/// Marqueur de module audit (aucune API publique).
abstract final class SecurityAudit {
  SecurityAudit._();
}
