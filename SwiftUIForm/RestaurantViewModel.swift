//
//  RestaurantViewModel.swift
//  SwiftUIForm
//
//  Created by Luis on 17/4/24.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore


class RestaurantViewModel: ObservableObject {
    
    @Published var restaurants:[Restaurant] = []
    @Published var selectedRestaurant: Restaurant?
    @Published var showSettings: Bool = false
    @ObservedObject var settingStore:SettingStore
    //Variable para contener la BBDD descargado
    @Published var restaurantDB: [Restaurant] = []
    
    private var databaseReference = Firestore.firestore().collection("restaurantes")
    
    
    
    init(settingStore: SettingStore){
        
        
        self.settingStore = settingStore
        
        compruebaBaseDatos()
        //fetchRestaurant()
        
        self.restaurants = [
            Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", phone: "232-923423", image: "cafedeadend", priceLevel: 3),
            Restaurant(name: "Homei", type: "Cafe", phone: "348-233423", image: "homei", priceLevel: 3),
            Restaurant(name: "Teakha", type: "Tea House", phone: "354-243523", image: "teakha", priceLevel: 3, isFavorite: true, isCheckIn: true),
            Restaurant(name: "Cafe loisl", type: "Austrian / Casual Drink", phone: "453-333423", image: "cafeloisl", priceLevel: 2, isFavorite: true, isCheckIn: true),
            Restaurant(name: "Petite Oyster", type: "French", phone: "983-284334", image: "petiteoyster", priceLevel: 5, isCheckIn: true),
            Restaurant(name: "For Kee Restaurant", type: "Hong Kong", phone: "232-434222", image: "forkeerestaurant", priceLevel: 2, isFavorite: true, isCheckIn: true),
            Restaurant(name: "Po's Atelier", type: "Bakery", phone: "234-834322", image: "posatelier", priceLevel: 4),
            Restaurant(name: "Bourke Street Backery", type: "Chocolate", phone: "982-434343", image: "bourkestreetbakery", priceLevel: 4, isCheckIn: true),
            Restaurant(name: "Haigh's Chocolate", type: "Cafe", phone: "734-232323", image: "haighschocolate", priceLevel: 3, isFavorite: true),
            Restaurant(name: "Palomino Espresso", type: "American / Seafood", phone: "872-734343", image: "palominoespresso", priceLevel: 2),
            Restaurant(name: "Upstate", type: "Seafood", phone: "343-233221", image: "upstate", priceLevel: 4),
            Restaurant(name: "Traif", type: "American", phone: "985-723623", image: "traif", priceLevel: 5),
            Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch", phone: "455-232345", image: "grahamavenuemeats", priceLevel: 3),
            Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", phone: "434-232322", image: "wafflewolf", priceLevel: 3),
            Restaurant(name: "Five Leaves", type: "Bistro", phone: "343-234553", image: "fiveleaves", priceLevel: 4, isFavorite: true, isCheckIn: true),
            Restaurant(name: "Cafe Lore", type: "Latin American", phone: "342-455433", image: "cafelore", priceLevel: 2, isFavorite: true, isCheckIn: true),
            Restaurant(name: "Confessional", type: "Spanish", phone: "643-332323", image: "confessional", priceLevel: 4),
            Restaurant(name: "Barrafina", type: "Spanish", phone: "542-343434", image: "barrafina", priceLevel: 2, isCheckIn: true),
            Restaurant(name: "Donostia", type: "Spanish", phone: "722-232323", image: "donostia", priceLevel: 1),
            Restaurant(name: "Royal Oak", type: "British", phone: "343-988834", image: "royaloak", priceLevel: 2, isFavorite: true),
            Restaurant(name: "CASK Pub and Kitchen", type: "Thai", phone: "432-344050", image: "caskpubkitchen", priceLevel: 1)
        ]
        
    }
    
    func shouldShowItem(restaurant: Restaurant) -> Bool {
        return (!self.settingStore.showCheckInOnly || restaurant.isCheckIn) && (restaurant.priceLevel <= self.settingStore.maxPriceLevel) }
    
    func delete(restaurant: Restaurant) {
        //if let sirve para el desempaquetado de nulos
        if let restaurantID = restaurant.id {
            databaseReference.document(restaurantID).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                }
            }
        }
        /* Funcion que actuaba sobre la variable local y no la de Firebase
         if let index = self.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
         self.restaurants.remove(at: index)
         }
         */
    }
    
    func setFavorite(restaurant: Restaurant) {
        if let restaurantID = restaurant.id {
            databaseReference.document(restaurantID).updateData(["isFavorite": !restaurant.isFavorite])
        }
        /*Funcion que actuaba sobre la variable local y no la de Firebase
         if let index = self.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
         self.restaurants[index].isFavorite.toggle()
         }
         */
    }
    
    func checkIn(restaurant: Restaurant) {
        if let restaurantID = restaurant.id {
            databaseReference.document(restaurantID).updateData(["isCheckIn": !restaurant.isCheckIn])
        }
        /* Funcion que actuaba sobre la variable local y no la de Firebase
         if let index = self.restaurants.firstIndex(where: { $0.id == restaurant.id }) {
         self.restaurants[index].isCheckIn.toggle()
         }
         */
    }
    
    func compruebaBaseDatos(){
        databaseReference.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard let documents = querySnapshot?.documents else{
                print("No documents found")
                return
            }
            if documents.isEmpty {
                self.addInitialRestaurants()
            } else {
                print("La coleccion no está vacía, no se agregaran elementos")
            }
        }
    }
    
    func addInitialRestaurants(){
        for restaurant in restaurants {
            self.addRestaurant(restaurant: restaurant)
        }
        /* Función a lo bestia para poder subirlo. Las líneas anteriores son más sencillas, y necestian el array del Init{}
         let initialRestaurants = [
         Restaurant(name: "Cafe Deadend", type: "Coffee & Tea Shop", phone: "232-923423", image: "cafedeadend", priceLevel: 3),
         Restaurant(name: "Homei", type: "Cafe", phone: "348-233423", image: "homei", priceLevel: 3),
         Restaurant(name: "Teakha", type: "Tea House", phone: "354-243523", image: "teakha", priceLevel: 3, isFavorite: true, isCheckIn: true),
         Restaurant(name: "Cafe loisl", type: "Austrian / Casual Drink", phone: "453-333423", image: "cafeloisl", priceLevel: 2, isFavorite: true, isCheckIn: true),
         Restaurant(name: "Petite Oyster", type: "French", phone: "983-284334", image: "petiteoyster", priceLevel: 5, isCheckIn: true),
         Restaurant(name: "For Kee Restaurant", type: "Hong Kong", phone: "232-434222", image: "forkeerestaurant", priceLevel: 2, isFavorite: true, isCheckIn: true),
         Restaurant(name: "Po's Atelier", type: "Bakery", phone: "234-834322", image: "posatelier", priceLevel: 4),
         Restaurant(name: "Bourke Street Backery", type: "Chocolate", phone: "982-434343", image: "bourkestreetbakery", priceLevel: 4, isCheckIn: true),
         Restaurant(name: "Haigh's Chocolate", type: "Cafe", phone: "734-232323", image: "haighschocolate", priceLevel: 3, isFavorite: true),
         Restaurant(name: "Palomino Espresso", type: "American / Seafood", phone: "872-734343", image: "palominoespresso", priceLevel: 2),
         Restaurant(name: "Upstate", type: "Seafood", phone: "343-233221", image: "upstate", priceLevel: 4),
         Restaurant(name: "Traif", type: "American", phone: "985-723623", image: "traif", priceLevel: 5),
         Restaurant(name: "Graham Avenue Meats", type: "Breakfast & Brunch", phone: "455-232345", image: "grahamavenuemeats", priceLevel: 3),
         Restaurant(name: "Waffle & Wolf", type: "Coffee & Tea", phone: "434-232322", image: "wafflewolf", priceLevel: 3),
         Restaurant(name: "Five Leaves", type: "Bistro", phone: "343-234553", image: "fiveleaves", priceLevel: 4, isFavorite: true, isCheckIn: true),
         Restaurant(name: "Cafe Lore", type: "Latin American", phone: "342-455433", image: "cafelore", priceLevel: 2, isFavorite: true, isCheckIn: true),
         Restaurant(name: "Confessional", type: "Spanish", phone: "643-332323", image: "confessional", priceLevel: 4),
         Restaurant(name: "Barrafina", type: "Spanish", phone: "542-343434", image: "barrafina", priceLevel: 2, isCheckIn: true),
         Restaurant(name: "Donostia", type: "Spanish", phone: "722-232323", image: "donostia", priceLevel: 1),
         Restaurant(name: "Royal Oak", type: "British", phone: "343-988834", image: "royaloak", priceLevel: 2, isFavorite: true),
         Restaurant(name: "CASK Pub and Kitchen", type: "Thai", phone: "432-344050", image: "caskpubkitchen", priceLevel: 1)
         
         ]
         for restaurant in initialRestaurants {
         self.addRestaurant(restaurant: restaurant)
         }
         */
    }
    
    func addRestaurant(restaurant: Restaurant){
        do{
            _ = try databaseReference.addDocument(from: restaurant)
        } catch {
            print("Error adding restaurant: \(error)")
        }
    }
    
    func fetchRestaurant(){
        databaseReference.getDocuments { querySnapshot, error in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            guard let documents = querySnapshot?.documents else{
                print("No documents found")
                return
            }
            if documents.isEmpty {
                
            } else {
                self.restaurantDB = documents.compactMap{ document in
                    do{
                        let restaurant = try document.data(as: Restaurant.self)
                        return restaurant
                    }catch{
                        return nil
                    }
                    
                }
            }
        }
        
    }
}

