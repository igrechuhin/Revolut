//
//  RVAccount.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 23.07.16.
//
//

import Foundation

final class RVAccount {

  //MARK: - Const
  private struct Const {
    static let accountKey = "UserAccount"

    static let listName = "DefaultAccount"
    static let listType = "plist"

    static let shortNameKey = "short_name"
    static let amountKey = "amount"
  }

  //MARK: - Static public var
  static var instance = RVAccount()

  //MARK: - Private var
  private var account: [String: Double] = [:]

  //MARK: - Functions
  func check(shortName: String, amount: Double) -> Bool {
    guard !shortName.isEmpty && amount >= 0 else { return false }
    guard let availableAmount = account[shortName] else { return false }

    return availableAmount >= amount
  }

  func exchange(fromShortName fromShortName: String, toShortName: String, fromAmount: Double, toAmount: Double) -> Bool {
    guard !fromShortName.isEmpty && !toShortName.isEmpty else { return false }
    guard fromAmount >= 0 && toAmount >= 0 else { return false }
    guard check(fromShortName, amount: fromAmount) else { return false }

    account[fromShortName]! -= fromAmount
    account[toShortName]! += toAmount

    syncAccount()

    return true
  }

  func amount(shortName: String) -> Double {
    if let amount = account[shortName] {
      return amount
    } else {
      return 0
    }
  }

  //MARK: - Private functions
  private init() {
    let ud = NSUserDefaults.standardUserDefaults()
    if let account = ud.dictionaryForKey(Const.accountKey) as? [String: Double] {
      self.account = account
    } else {
      let accountFilePath = NSBundle.mainBundle().pathForResource(Const.listName, ofType: Const.listType)!
      let accountFile = NSDictionary(contentsOfFile: accountFilePath)!
      for (shortName, amount) in accountFile {
        self.account[shortName as! String] = amount.doubleValue
      }
      syncAccount()
    }
  }

  private func syncAccount() {
    let ud = NSUserDefaults.standardUserDefaults()
    ud.setObject(account, forKey: Const.accountKey)
    ud.synchronize()
  }

}