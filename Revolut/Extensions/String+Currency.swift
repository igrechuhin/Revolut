//
//  String+RVCurrency.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 26.07.16.
//
//

import Foundation

extension String {

  //MARK: - Const
  private struct Const {
    static let maxFractionDigits = 2

    static let doubleDecimalSeparator = "."
  }

  //MARK: - Static functions
  static func decimalSeparator() -> String {
    return NSNumberFormatter().decimalSeparator
  }

  static func fromCurrency(currencyValue: Double) -> String {
    if currencyValue == floor(currencyValue) {
      return "\(Int(currencyValue))"
    } else {
      let (intPart, fracPart) = "\(currencyValue)".splitToIntegerAndFractional()
      return "\(intPart)\(String.decimalSeparator())\(fracPart!)"
    }
  }

  //MARK: - Public functions
  func splitToIntegerAndFractional() -> (String, String?) {
    let doubleReadyString = doubleReady()
    if !doubleReadyString.containsString(Const.doubleDecimalSeparator) {
      return (doubleReadyString, nil)
    } else {
      let sepRange = doubleReadyString.rangeOfString(Const.doubleDecimalSeparator)!
      let intPart = doubleReadyString.substringToIndex(sepRange.startIndex)
      let fracRange = sepRange.endIndex ..< sepRange.endIndex.advancedBy(Const.maxFractionDigits, limit: endIndex)
      let fracPart = doubleReadyString.substringWithRange(fracRange)
      return (intPart, fracPart)
    }
  }

  func doubleReady() -> String {
    return self.stringByReplacingOccurrencesOfString(String.decimalSeparator(), withString: Const.doubleDecimalSeparator)
  }

}