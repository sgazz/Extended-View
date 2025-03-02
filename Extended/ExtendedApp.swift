//
//  ExtendedApp.swift
//  Extended
//
//  Created by Gazza on 2.3.25..
//

import SwiftUI

// MARK: - Dozvole za pristup fotografijama
// Za dodavanje dozvola za pristup fotografijama, potrebno je dodati sledeće u Info.plist:
// NSPhotoLibraryUsageDescription - "Ova aplikacija zahteva pristup vašim fotografijama da bi omogućila uvoz i rotaciju slika."
//
// U novijim verzijama Xcode-a, ovo se može dodati kroz Target > Info sekciju:
// 1. Izaberite Target Extended
// 2. Idite na Info tab
// 3. Dodajte novi red sa ključem "Privacy - Photo Library Usage Description"
// 4. Postavite vrednost na "Ova aplikacija zahteva pristup vašim fotografijama da bi omogućila uvoz i rotaciju slika."

@main
struct ExtendedApp: App {
    init() {
        // Ovde možete dodati inicijalizaciju za aplikaciju
        print("Aplikacija za pregled i rotaciju slika je pokrenuta")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
