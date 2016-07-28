//
//  RVCurrency.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 23.07.16.
//
//

import Foundation

struct RVCurrency: Hashable {

  //MARK: - Public let
  let name: String
  let shortName: String
  let symbol: String

  //MARK: - Public var
  var hashValue: Int {
    return shortName.hashValue
  }

}

func ==(lhs: RVCurrency, rhs: RVCurrency) -> Bool {
  return lhs.name == rhs.name && lhs.shortName == rhs.shortName && lhs.symbol == rhs.symbol
}
