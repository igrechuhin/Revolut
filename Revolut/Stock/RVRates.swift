//
//  RVRates.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 22.07.16.
//
//

import Foundation

final class RVRates {

  //MARK: - Public let
  let lock = NSRecursiveLock()

  //MARK: - Public var
  var valid = false

  //MARK: - Private var
  private var _list: [RVCurrency : Double] = [:]

  //MARK: - Public functions
  subscript (key: RVCurrency) -> Double? {
    get {
      defer { lock.unlock() }
      lock.lock()
      return _list[key]
    }
    set(newValue) {
      lock.lock()
      _list[key] = newValue
      lock.unlock()
    }
  }

  subscript (shortName: String) -> Double? {
    get {
      defer { lock.unlock() }
      lock.lock()
      guard let index = RVCurrencyList.indexOf(shortName) else { return nil }
      return self[RVCurrencyList.get(index)]
    }
    set(newValue) {
      defer { lock.unlock() }
      lock.lock()
      guard let index = RVCurrencyList.indexOf(shortName) else { return }
      self[RVCurrencyList.get(index)] = newValue
    }
  }

}
