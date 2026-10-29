// swift-tools-version: 6.0
//
// Le noyau : toute la logique du projet, sans aucune dépendance Apple.
// C'est ce qui permet de le tester sous Linux, gratuitement, en une minute.
//
//   Core         contrats, modèles, extraction, dictée, export, validation, pipelines
//   CoreTestKit  bouchons + vérifications de contrat, partagés par les tests du
//                noyau ET les tests de l'app. Jamais lié à l'app livrée.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(name: "Core", targets: ["Core"]),
        .library(name: "CoreTestKit", targets: ["CoreTestKit"]),
    ],
    targets: [
        .target(name: "Core"),
        .target(name: "CoreTestKit", dependencies: ["Core"]),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Core", "CoreTestKit"],
            resources: [.copy("Fixtures")]),
    ],
    // Outils 6.0 pour Swift Testing, mais mode de langage 5 : la concurrence
    // stricte de Swift 6 produit des erreurs illisibles pour qui débute.
    swiftLanguageModes: [.v5]
)
