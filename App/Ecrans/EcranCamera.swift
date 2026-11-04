import Core
import SwiftUI

/// Figma « Camera capture » puis « Photo review ».
///
/// SQUELETTE : le déclencheur envoie une photo factice au Core (qui appelle le
/// module OCR). La vraie caméra viendra avec le module OCR.
///
/// AJOUTÉ au Figma (séquence d'appareils du squelette) : l'appareil à
/// photographier, « Pas de … ici » et « + Ajouter une pompe ».
struct EcranCamera: View {
    /// Appelé avec le nombre de photos prises quand on touche « Téléverser ».
    let termine: (Int) -> Void

    @Environment(EtatApp.self) private var etat
    @Environment(\.dismiss) private var fermer

    @State private var enRevue = false
    /// Photos prises depuis l'ouverture de la caméra.
    @State private var prisesIci = 0
    @State private var erreur: String?
    /// Où en était la séquence à l'ouverture, pour que « Annuler » défasse tout.
    @State private var indexAuDepart: Int?

    var body: some View {
        Group {
            if enRevue {
                revue
            } else {
                camera
            }
        }
        .onAppear {
            if indexAuDepart == nil { indexAuDepart = etat.session.indexEtape }
        }
    }

    // MARK: - Caméra

    private var camera: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Annuler") { annuler() }
                    .font(.system(size: 17))
                Spacer()
                Text("Prendre des photos")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Image(systemName: "bolt.slash")
                    .font(.system(size: 18))
                    .accessibilityLabel("Flash désactivé")
            }
            .foregroundStyle(Color.white)
            .padding(.horizontal, 24)
            .frame(height: 52)

            apercu

            VStack(spacing: 16) {
                controlesDeSequence

                Text("PHOTO")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)

                HStack {
                    boutonRond("photo", etiquette: "Galerie")
                    Spacer()
                    Button {
                        Task { await declencher() }
                    } label: {
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                            .frame(width: 76, height: 76)
                            .overlay(Circle().fill(Color.white).padding(7))
                    }
                    .disabled(etat.session.etapeCourante == nil)
                    .opacity(etat.session.etapeCourante == nil ? 0.4 : 1)
                    .accessibilityLabel("Prendre la photo")
                    Spacer()
                    boutonRond("arrow.triangle.2.circlepath.camera", etiquette: "Changer de caméra")
                }
                .padding(.horizontal, 32)

                if prisesIci > 0 && etat.session.etapeCourante == nil {
                    Button("Voir les photos") { enRevue = true }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Couleurs.bleu)
                }
                Text("Aperçu de caméra démo")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.white.opacity(0.7))
                if let erreur {
                    Text(erreur)
                        .font(.system(size: 13))
                        .foregroundStyle(Couleurs.rouge)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
        }
        .background(Couleurs.cameraFond)
    }

    private var apercu: some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: 0x5A5A5E))
            // Grille de cadrage, comme dans le Figma.
            GeometryReader { geo in
                Path { trace in
                    for i in 1 ... 2 {
                        let x = geo.size.width * CGFloat(i) / 3
                        let y = geo.size.height * CGFloat(i) / 3
                        trace.move(to: CGPoint(x: x, y: 0))
                        trace.addLine(to: CGPoint(x: x, y: geo.size.height))
                        trace.move(to: CGPoint(x: 0, y: y))
                        trace.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.25), lineWidth: 1)
            }
            VStack {
                VStack(spacing: 8) {
                    pastille("MODE DÉMO")
                    if let etape = etat.session.etapeCourante {
                        pastille("Photographier : \(etape.titre)")
                    } else {
                        pastille("Toutes les photos sont prises")
                    }
                }
                .padding(.top, 16)
                Spacer()
                Text("1×")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.55))
                    .clipShape(Circle())
                    .padding(.bottom, 16)
            }
        }
        .frame(maxHeight: .infinity)
    }

    /// AJOUTÉ : sauter l'appareil absent, ajouter une pompe.
    private var controlesDeSequence: some View {
        HStack {
            if let etape = etat.session.etapeCourante {
                Button("Pas de \(etape.titre.lowercased()) ici") {
                    var copie = etat.session
                    copie.passerEtape()
                    etat.session = copie
                }
            }
            Spacer()
            Button("+ Ajouter une pompe") {
                var copie = etat.session
                copie.ajouterPompe()
                etat.session = copie
            }
        }
        .font(.system(size: 15))
        .foregroundStyle(Couleurs.bleu)
        .padding(.horizontal, 24)
    }

    // MARK: - Revue

    private var revue: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Vérifier la photo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Couleurs.texte)
                HStack {
                    BoutonRetour(titre: "Caméra") { enRevue = false }
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 52)

            BandeauDemo()

            VStack(spacing: 16) {
                HStack {
                    Text(prisesIci > 1 ? "\(prisesIci) photos" : "\(prisesIci) photo")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Couleurs.texte)
                    Spacer()
                    Button {
                        supprimerDerniere()
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                            .font(.system(size: 15))
                            .foregroundStyle(Couleurs.bleu)
                    }
                }
                .padding(.top, 24)

                ZStack(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: 0xC7C7CC))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.white))
                    if let derniere = etat.session.dossier.lectures.last {
                        pastille(derniere.etape.titre)
                            .padding(12)
                    }
                }
                .frame(maxHeight: .infinity)

                HStack {
                    BoutonLien(titre: "Reprendre", taille: 17) { reprendre() }
                    Spacer()
                    if let suivante = etat.session.etapeCourante {
                        BoutonLien(titre: "+ Prendre une autre (\(suivante.titre))", taille: 17) { enRevue = false }
                    }
                }
            }
            .padding(.horizontal, 24)

            VStack(spacing: 12) {
                NoteDeBas(texte: "Démo seulement. Rien ne sera téléversé.")
                BoutonPrincipal(titre: "Téléverser", actif: prisesIci > 0) { termine(prisesIci) }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
        }
        .background(Couleurs.fond)
    }

    // MARK: - Éléments

    private func pastille(_ texte: String) -> some View {
        Text(texte)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.55))
            .clipShape(Capsule())
    }

    private func boutonRond(_ symbole: String, etiquette: String) -> some View {
        Image(systemName: symbole)
            .font(.system(size: 20))
            .foregroundStyle(Color.white)
            .frame(width: 44, height: 44)
            .background(Color.white.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .accessibilityLabel(etiquette)
    }

    // MARK: - Actions

    private func declencher() async {
        var copie = etat.session
        do {
            try await copie.capturerPhoto(Photo(donnees: Data([0x01])))
            etat.session = copie
            prisesIci += 1
            erreur = nil
            enRevue = true
        } catch {
            erreur = "La photo n'a pas pu être lue : \(error)"
        }
    }

    private func supprimerDerniere() {
        var copie = etat.session
        try? copie.revenirEnArriere()
        etat.session = copie
        prisesIci = max(prisesIci - 1, 0)
        if prisesIci == 0 { enRevue = false }
    }

    private func reprendre() {
        supprimerDerniere()
        enRevue = false
    }

    /// « Annuler » défait tout depuis l'ouverture de la caméra (photos et appareils sautés).
    private func annuler() {
        var copie = etat.session
        let depart = indexAuDepart ?? copie.indexEtape
        while copie.indexEtape > depart {
            // Dossier déjà validé : on ne touche à rien (et on évite une boucle sans fin).
            guard (try? copie.revenirEnArriere()) != nil else { break }
        }
        etat.session = copie
        fermer()
    }
}
