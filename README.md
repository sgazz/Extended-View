# Extended Image Viewer

Aplikacija za pregled i manipulaciju slikama na iOS uređajima.

## Funkcionalnosti

- Učitavanje slika iz galerije
- Napredno zumiranje sa plutajućim kontrolama
  - Kontinuirano zumiranje držanjem dugmeta
  - Brzo zumiranje dvostrukim tapom
  - Precizna kontrola nivoa zuma
  - Vizuelni indikator trenutnog zuma
  - Napredni haptički fidbek pri dostizanju granica
- Rotacija slike
  - Precizna rotacija sa zaključavanjem na 45°
  - Kontinuirana rotacija držanjem dugmeta
  - Brza rotacija dvostrukim tapom (45°)
  - Vizuelni indikator ugla rotacije
  - Haptički fidbek pri zaključavanju ugla
- Pomeranje slike prevlačenjem
  - Slobodno pomeranje u svim pravcima
  - Automatsko centriranje pri resetovanju
- Podrška za levoruke i desnoruke korisnike
  - Prilagodljiv raspored kontrola
  - Intuitivno pozicioniranje dugmadi
- Moderni korisnički interfejs
  - Elegantni dizajn sa transparentnim elementima
  - Vizuelni indikatori za sve akcije
  - Responzivna dugmad sa animacijama
  - Adaptivni layout za različite orijentacije

## Tehnički detalji

- Razvijeno za iOS 17+
- Koristi SwiftUI framework
- Implementira PhotosUI za pristup galeriji
- Optimizovano za jednoruko korišćenje
- Napredni sistem za haptički fidbek
- Gesture recognizers za intuitivnu kontrolu

## Razvoj

Projekat je razvijen u Xcode-u koristeći Swift i SwiftUI. Za pokretanje projekta:

1. Klonirajte repozitorijum
2. Otvorite `Extended.xcodeproj`
3. Pokrenite aplikaciju u simulatoru ili na uređaju

## Zahtevi

- iOS 17.0 ili noviji
- Xcode 15.0 ili noviji
- Swift 5.9 ili noviji

## Grane razvoja

- `main` - Glavna grana sa stabilnim verzijama
- `feature/haptic-feedback` - Implementacija haptičkog fidbeka i UI poboljšanja
- `feature/image-movement` - Unapređenje funkcionalnosti za manipulaciju slikama 