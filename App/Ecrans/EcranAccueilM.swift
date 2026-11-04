import SwiftUI

/// Figma « M home » et « M form sheet ».
///
/// DÉMO : aucune note médicale n'est produite pour l'instant (reportée par la
/// spécification). AJOUTÉ au Figma : la liste des formulaires déjà téléversés.
struct EcranAccueilM: View {
    @Environment(EtatApp.self) private var etat

    @State private var formulaireOuvert = false
    @State private var termine: Int?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BandeauDemo()

                HStack {
                    Text("Accueil")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Couleurs.texte)
                    Spacer()
                    Button {
                        formulaireOuvert = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(Color.white)
                            .frame(width: 48, height: 48)
                            .background(Couleurs.bleu)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Nouveau formulaire")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                if etat.formulairesM.isEmpty {
                    Spacer()
                    aucunFormulaire
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(etat.formulairesM.reversed()) { formulaire in
                                ligne(formulaire)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    }
                }

                PiedDeRole()
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .background(Couleurs.fond)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $formulaireOuvert) {
                EcranFormulaire(role: .m) { enregistrements in
                    formulaireOuvert = false
                    termine = enregistrements
                }
                .environment(etat)
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(item: $termine) { enregistrements in
                EcranTermine(
                    resultat: .formulaire(enregistrements: enregistrements),
                    retourAccueil: { termine = nil },
                    recommencer: {
                        termine = nil
                        formulaireOuvert = true
                    })
            }
        }
    }

    private var aucunFormulaire: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 26))
                .foregroundStyle(Couleurs.texteSecondaire)
                .frame(width: 76, height: 76)
                .background(Couleurs.carte)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Text("Aucun formulaire")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(Couleurs.texte)
            Text("Touchez + pour créer un formulaire. Tapez l'information et ajoutez de l'audio aux autres champs.")
                .font(.system(size: 17))
                .foregroundStyle(Couleurs.texteSecondaire)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
    }

    private func ligne(_ formulaire: FormulaireDemo) -> some View {
        Carte {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "doc.text")
                    .foregroundStyle(Couleurs.bleu)
                VStack(alignment: .leading, spacing: 2) {
                    Text(formulaire.information.isEmpty ? "Formulaire" : formulaire.information)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Couleurs.texte)
                        .lineLimit(1)
                    Text("\(formulaire.nombreEnregistrements) enregistrement(s) audio · Aperçu démo")
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.texteSecondaire)
                }
            }
        }
    }
}
