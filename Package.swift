// swift-tools-version: 6.0
//
// La carte du projet. Chaque bloc ci-dessous est une « cible » : un morceau de
// code avec son dossier. La flèche de dépendance va toujours vers le Core :
//
//   Modules/OCR ──────────┐
//   Modules/Transcription ┼──► Core   (le tuyau central et les 3 prises)
//   Modules/Export ───────┘
//
// Vous n'avez normalement pas besoin de modifier ce fichier. Si vous pensez que
// oui, ouvrez d'abord une issue (docs/GUIDE-EQUIPE.md, « Les règles »).

import PackageDescription

let package = Package(
    name: "CaptureICU",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "ModuleOCR", targets: ["ModuleOCR"]),
        .library(name: "ModuleTranscription", targets: ["ModuleTranscription"]),
        .library(name: "ModuleExport", targets: ["ModuleExport"]),
    ],
    targets: [
        // ── Core : le tuyau central (Thomas) ─────────────────────────────
        .target(name: "Core", path: "Core/Code"),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "OutilsDeTest"],
            path: "Core/Tests"),

        // ── Module 1 : OCR (photo → valeurs) ─────────────────────────────
        .target(name: "ModuleOCR", dependencies: ["Core"], path: "Modules/OCR/Code"),
        .testTarget(
            name: "ModuleOCRTests",
            dependencies: ["Core", "ModuleOCR", "OutilsDeTest"],
            path: "Modules/OCR/Tests"),

        // ── Module 2 : Transcription (audio → texte) ─────────────────────
        .target(name: "ModuleTranscription", dependencies: ["Core"], path: "Modules/Transcription/Code"),
        .testTarget(
            name: "ModuleTranscriptionTests",
            dependencies: ["Core", "ModuleTranscription", "OutilsDeTest"],
            path: "Modules/Transcription/Tests"),

        // ── Module 3 : Export (dossier → note infirmière PDF) ────────────
        .target(name: "ModuleExport", dependencies: ["Core"], path: "Modules/Export/Code"),
        .testTarget(
            name: "ModuleExportTests",
            dependencies: ["Core", "ModuleExport", "OutilsDeTest"],
            path: "Modules/Export/Tests"),

        // ── Outils partagés par tous les tests ───────────────────────────
        // Faux modules + vérification des prises. Jamais dans l'app livrée.
        .target(name: "OutilsDeTest", dependencies: ["Core"], path: "OutilsDeTest"),

        // ── Le parcours complet, avec les vrais modules ──────────────────
        .testTarget(
            name: "BoutEnBoutTests",
            dependencies: ["Core", "ModuleOCR", "ModuleTranscription", "ModuleExport", "OutilsDeTest"],
            path: "BoutEnBout"),
    ],
    // Outils Swift 6 (pour Swift Testing), mais mode de langage 5 : les erreurs
    // de concurrence stricte de Swift 6 sont illisibles quand on débute.
    swiftLanguageModes: [.v5]
)
