//
//  Festival.swift
//  EACodingTest
//
//  Created by Shweta Verma on 11/4/2023.
//

import Foundation

struct Festival: Decodable,Equatable{
    let name: String?
    let bands: [Band]
}

struct Band: Decodable,Equatable,Hashable {
    let name: String
    var recordLabel: String?
}
