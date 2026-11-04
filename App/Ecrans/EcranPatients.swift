import Core
import SwiftUI

/// Étape 2 · Choix du patient (liste factice).
struct EcranPatients: View {
    let utilisateur: Utilisateur

    var body: some View {
        NavigationStack {
            List(PatientsFactices.liste, id: \.code) { patient in
                NavigationLink {
                    EcranSession(utilisateur: utilisateur, patient: patient)
                } label: {
                    Text("\(patient.code) · \(patient.lit)")
                }
            }
            .navigationTitle("Patients")
        }
    }
}
