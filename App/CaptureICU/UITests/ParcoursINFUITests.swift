import XCTest

/// Le parcours INF au complet, joué sur le simulateur comme une infirmière :
/// connexion → rôle INF → photos → formulaire → vérification → note PDF.
///
/// Ce test touche les vrais écrans, branchés sur le Core et les vrais modules
/// (encore factices). Une capture d'écran est gardée à chaque étape : on les
/// retrouve dans le rapport du test (TestResults.xcresult).
final class ParcoursINFUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testParcoursCompletDeLInfirmiere() {
        // 1. Connexion avec le compte de démonstration.
        capture("1-connexion")
        let courriel = app.textFields.firstMatch
        XCTAssertTrue(courriel.waitForExistence(timeout: 10))
        courriel.tap()
        courriel.typeText("demo")
        let motDePasse = app.secureTextFields.firstMatch
        motDePasse.tap()
        motDePasse.typeText("demo")
        bouton("Se connecter").tap()

        // 2. Rôle INF.
        attendre(bouton("Essayer le rôle INF"))
        capture("2-roles")
        bouton("Essayer le rôle INF").tap()

        // 3. Accueil, puis les photos : moniteur, pompe 1, ventilateur.
        attendre(bouton("Prendre des photos"))
        capture("3-accueil")
        bouton("Prendre des photos").tap()

        let declencheur = bouton("Prendre la photo")
        attendre(declencheur)
        capture("4-camera")
        declencheur.tap()
        for suivante in ["Pompe 1", "Ventilateur"] {
            let autre = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", suivante)).firstMatch
            attendre(autre)
            autre.tap()
            attendre(declencheur)
            declencheur.tap()
        }
        attendre(bouton("Téléverser"))
        capture("5-revue-photos")
        bouton("Téléverser").tap()

        attendre(bouton("Retour à l'accueil"))
        capture("6-photos-televersees")
        bouton("Retour à l'accueil").tap()

        // 4. Le formulaire : l'information tapée devient la note.
        attendre(bouton("Remplir un formulaire"))
        bouton("Remplir un formulaire").tap()
        let information = app.textViews.firstMatch
        attendre(information)
        information.tap()
        information.typeText("Patiente éveillée. Pansement sec.")
        capture("7-formulaire")
        bouton("Téléverser").tap()

        attendre(bouton("Retour à l'accueil"))
        bouton("Retour à l'accueil").tap()

        // 5. Vérification : remplir les cases que l'OCR n'a pas pu lire.
        attendre(bouton("Vérifier et créer la note"))
        capture("8-accueil-progression")
        bouton("Vérifier et créer la note").tap()
        attendre(bouton("Valider et créer la note"))
        capture("9-verification")

        var garde = 0
        while app.textFields["à remplir"].exists && garde < 20 {
            let caseVide = app.textFields["à remplir"].firstMatch
            caseVide.tap()
            caseVide.typeText("80")
            app.buttons["OK"].firstMatch.tap()
            garde += 1
        }

        // 6. Valider : la note infirmière PDF est créée.
        let valider = bouton("Valider et créer la note")
        valider.tap()
        attendre(bouton("Retour à l'accueil"))
        capture("10-note-creee")
    }

    // MARK: - Aides

    /// Un bouton par son titre. Les cartes ajoutent leur description au titre
    /// (« Essayer le rôle INF, Prendre des photos… ») : on compare le début.
    private func bouton(_ titre: String) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label == %@ OR label BEGINSWITH %@", titre, titre + ",")).firstMatch
    }

    private func attendre(_ element: XCUIElement, _ secondes: TimeInterval = 10) {
        if !element.waitForExistence(timeout: secondes) {
            capture("ECHEC")
            XCTFail("Introuvable à l'écran : \(element)")
        }
    }

    private func capture(_ nom: String) {
        let piece = XCTAttachment(screenshot: app.screenshot())
        piece.name = nom
        piece.lifetime = .keepAlways
        add(piece)
    }
}
