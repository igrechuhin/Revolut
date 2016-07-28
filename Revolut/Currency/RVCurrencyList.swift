//
//  RVCurrencyList.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 23.07.16.
//
//

import Foundation

final class RVCurrencyList {

  //MARK: - Const
  private struct Const {
    static let listName = "CurrencyList"
    static let listType = "plist"

    static let nameKey = "name"
    static let shortNameKey = "short_name"
    static let symbolKey = "symbol"
  }

  //MARK: - Static public var
  static var instance = RVCurrencyList()

  //MARK: - Static functions
  static func get() -> [RVCurrency] {
    return instance.list
  }

  static func get(index: Array<RVCurrency>.Index) -> RVCurrency {
    return get()[index]
  }

  static func indexOf(currencyShortName: String) -> Array<RVCurrency>.Index? {
    return get().indexOf { $0.shortName == currencyShortName }
  }

  //MARK: - Private functions
  private let list: [RVCurrency] = {
    let listFilePath = NSBundle.mainBundle().pathForResource(Const.listName, ofType: Const.listType)!
    let listFile = NSArray(contentsOfFile: listFilePath)!
    var arr: [RVCurrency] = []
    for cur in listFile {
      if let dict = cur as? NSDictionary {
        let name = dict[Const.nameKey] as! String
        let shortName = dict[Const.shortNameKey] as! String
        let symbol = dict[Const.symbolKey] as! String
        arr.append(RVCurrency(name: name, shortName: shortName, symbol: symbol))
      }
    }
    assert(arr.count >= 2)
    return arr
  }()

  private init() {}

}