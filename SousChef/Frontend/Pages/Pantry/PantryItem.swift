//
//  PantryItem.swift
//  SousChef
//
//  Created by Zachary Waiksnoris on 12/8/24.
//

struct PantryItem: Decodable {
    let id: Int
    let ingredient_id: Int
    let ingredient_name: String
    let quantity: String
    let added_at: String
}
