import Foundation

/// Fabrique un PDF d'une ou plusieurs pages à partir de lignes de texte.
///
/// Écrit à la main, sans aucun framework Apple : il tourne partout, donc on peut
/// tester la note infirmière sur n'importe quel ordinateur. Plus tard, l'équipe
/// pourra le remplacer par un rendu plus riche (tableaux, cases à cocher) sans
/// changer la prise.
///
/// Vous n'avez pas besoin de comprendre l'intérieur pour vous en servir :
///
///     let pdf = PDFSimple.fabriquer([.init("TITRE", gras: true), .init("FC : 88 bpm")])
struct PDFSimple {
    struct Ligne: Equatable {
        var texte: String
        var gras: Bool

        init(_ texte: String, gras: Bool = false) {
            self.texte = texte
            self.gras = gras
        }
    }

    /// Format Lettre (8,5 × 11 po), en points.
    static let largeurPage = 612
    static let hauteurPage = 792
    static let lignesParPage = 46
    static let caracteresParLigne = 90

    static func fabriquer(_ lignes: [Ligne]) -> Data {
        let pages = decouperEnPages(lignes)

        // Objets du PDF, numérotés à partir de 1 :
        //   1 catalogue, 2 liste des pages, 3 police normale, 4 police grasse,
        //   puis, pour chaque page : la page, puis son contenu.
        var objets: [[UInt8]] = []
        let premierePage = 5
        let renvois = pages.indices.map { "\(premierePage + 2 * $0) 0 R" }.joined(separator: " ")

        objets.append(octets("<< /Type /Catalog /Pages 2 0 R >>"))
        objets.append(octets("<< /Type /Pages /Kids [\(renvois)] /Count \(pages.count) >>"))
        objets.append(octets("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>"))
        objets.append(octets("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>"))

        for (index, page) in pages.enumerated() {
            let numeroContenu = premierePage + 2 * index + 1
            objets.append(octets(
                "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 \(largeurPage) \(hauteurPage)] "
                + "/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents \(numeroContenu) 0 R >>"))

            let flux = fluxDeTexte(page)
            objets.append(octets("<< /Length \(flux.count) >>\nstream\n") + flux + octets("\nendstream"))
        }

        // Assemblage, en notant où commence chaque objet (la table « xref »).
        var sortie = octets("%PDF-1.4\n")
        var positions: [Int] = []
        for (index, corps) in objets.enumerated() {
            positions.append(sortie.count)
            sortie += octets("\(index + 1) 0 obj\n") + corps + octets("\nendobj\n")
        }

        let debutTable = sortie.count
        sortie += octets("xref\n0 \(objets.count + 1)\n")
        sortie += octets("0000000000 65535 f \n")
        for position in positions {
            let chiffres = String(position)
            sortie += octets(String(repeating: "0", count: 10 - chiffres.count) + chiffres + " 00000 n \n")
        }
        sortie += octets("trailer\n<< /Size \(objets.count + 1) /Root 1 0 R >>\nstartxref\n\(debutTable)\n%%EOF\n")

        return Data(sortie)
    }

    // MARK: - Détails

    /// Les instructions qui écrivent les lignes d'une page, de haut en bas.
    private static func fluxDeTexte(_ lignes: [Ligne]) -> [UInt8] {
        var flux = octets("BT\n15 TL\n50 \(hauteurPage - 50) Td\n")
        for ligne in lignes {
            let police = ligne.gras ? "/F2" : "/F1"
            flux += octets("\(police) 11 Tf (")
            flux += octets(echapper(ligne.texte))
            flux += octets(") Tj T*\n")
        }
        flux += octets("ET")
        return flux
    }

    /// Coupe les lignes trop longues, puis répartit les lignes en pages.
    private static func decouperEnPages(_ lignes: [Ligne]) -> [[Ligne]] {
        var coupees: [Ligne] = []
        for ligne in lignes {
            for paragraphe in ligne.texte.split(separator: "\n", omittingEmptySubsequences: false) {
                for morceau in couper(String(paragraphe)) {
                    coupees.append(Ligne(morceau, gras: ligne.gras))
                }
            }
        }

        var pages: [[Ligne]] = []
        var debut = 0
        while debut < coupees.count {
            let fin = min(debut + lignesParPage, coupees.count)
            pages.append(Array(coupees[debut ..< fin]))
            debut = fin
        }
        return pages.isEmpty ? [[]] : pages
    }

    /// Coupe un texte entre les mots pour ne pas dépasser la largeur de la page.
    private static func couper(_ texte: String) -> [String] {
        guard texte.count > caracteresParLigne else { return [texte] }

        var resultat: [String] = []
        var courante = ""
        for mot in texte.split(separator: " ") {
            var reste = String(mot)
            // Un mot plus long qu'une ligne entière est coupé net.
            while reste.count > caracteresParLigne {
                if !courante.isEmpty { resultat.append(courante); courante = "" }
                resultat.append(String(reste.prefix(caracteresParLigne)))
                reste = String(reste.dropFirst(caracteresParLigne))
            }
            if courante.isEmpty {
                courante = reste
            } else if courante.count + 1 + reste.count <= caracteresParLigne {
                courante += " " + reste
            } else {
                resultat.append(courante)
                courante = reste
            }
        }
        if !courante.isEmpty { resultat.append(courante) }
        return resultat
    }

    /// Dans un PDF, les parenthèses et la barre oblique inverse délimitent le texte :
    /// il faut les précéder d'une barre oblique inverse.
    private static func echapper(_ texte: String) -> String {
        texte
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "(", with: "\\(")
            .replacingOccurrences(of: ")", with: "\\)")
    }

    /// Texte → octets dans le codage des polices standard du PDF (WinAnsi).
    /// Les lettres accentuées du français y sont toutes; un caractère absent
    /// devient « ? ».
    private static func octets(_ texte: String) -> [UInt8] {
        texte.unicodeScalars.map { caractere in
            if let special = winAnsi[caractere.value] { return special }
            if caractere.value < 0x80 || (0xA0 ... 0xFF).contains(caractere.value) {
                return UInt8(caractere.value)
            }
            return UInt8(ascii: "?")
        }
    }

    /// Les caractères typographiques courants qui ne sont pas au même endroit en WinAnsi.
    private static let winAnsi: [UInt32: UInt8] = [
        0x2019: 0x92, // ’
        0x2018: 0x91, // ‘
        0x201C: 0x93, // “
        0x201D: 0x94, // ”
        0x2013: 0x96, // –
        0x2014: 0x97, // —
        0x2026: 0x85, // …
        0x0153: 0x9C, // œ
        0x0152: 0x8C, // Œ
        0x20AC: 0x80, // €
        0x00A0: 0x20, // espace insécable → espace
    ]
}
