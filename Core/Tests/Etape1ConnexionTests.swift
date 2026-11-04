import Core
import Testing

@Suite("Étape 1 · Connexion")
struct Etape1ConnexionTests {
    @Test("[8.1-2] demo / demo ouvre une session")
    func bonsIdentifiants() {
        let utilisateur = ConnexionFactice().connecter(identifiant: "demo", motDePasse: "demo")

        #expect(utilisateur == Utilisateur(identifiant: "demo"))
    }

    @Test("[8.1-2] un mauvais mot de passe est refusé")
    func mauvaisMotDePasse() {
        let utilisateur = ConnexionFactice().connecter(identifiant: "demo", motDePasse: "1234")

        #expect(utilisateur == nil)
    }

    @Test("[8.1-2] un identifiant vide est refusé")
    func identifiantVide() {
        #expect(ConnexionFactice().connecter(identifiant: "", motDePasse: "") == nil)
    }
}
