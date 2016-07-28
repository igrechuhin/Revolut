//
//  RVTransaction.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 26.07.16.
//
//

import Foundation

protocol RVTransactionDelegate: class {

  func onTransactionStatusUpdated()
  func onTransactionComplete(success: Bool,
                             fromSymbol: String, toSymbol: String,
                             fromAmount: Double, toAmount: Double)

}

final class RVTransaction {

  //MARK: - Enumeration
  enum Status {
    case Available
    case Invalid
  }

  enum Side {
    case From
    case To

    func oppositeSide() -> Side {
      switch self {
      case .From:
        return .To
      case .To:
        return .From
      }
    }
  }

  //MARK: - Public var
  var status: Status {
    return _status
  }

  weak var delegate: RVTransactionDelegate?

  //MARK: - Private var
  private var _status: Status = .Available {
    didSet {
      delegate?.onTransactionStatusUpdated()
    }
  }

  private lazy var stock: RVStock = {
    let stock = RVStock()
    stock.delegate = self
    return stock
  }()

  private var exchangeItems: [Side : RVTransactionItemViewController] = [:]

  private var recentActiveSide: Side = .From

  //MARK: - Public functions
  subscript (side: Side) -> RVTransactionItemViewController? {
    get {
      return exchangeItems[side]
    }
    set(newValue) {
      exchangeItems[side] = newValue
      refresh(side.oppositeSide())
    }
  }

  func refresh(activeSide: Side) {
    recentActiveSide = activeSide
    guard let activeItem = exchangeItems[activeSide],
      let inactiveItem = exchangeItems[activeSide.oppositeSide()] else { return }
    if let activeItemAmount = activeItem.amount {
      inactiveItem.amount = stock.estimateAmount(fromShortName: activeItem.currency.shortName,
                                                   toShortName: inactiveItem.currency.shortName,
                                                   fromAmount: activeItemAmount)
    } else {
      inactiveItem.amount = 0
    }

    activeItem.becomeResponder()

    let fromItem = exchangeItems[.From]!
    let toItem = exchangeItems[.To]!
    if let rate = stock.getRate(fromShortName: toItem.currency.shortName, toShortName: fromItem.currency.shortName) {
      toItem.rateString = "\(toItem.currency.symbol)1 = \(fromItem.currency.symbol)\(String.fromCurrency(rate))"
    } else {
      toItem.rateString = ""
    }
    fromItem.refresh()
    toItem.refresh()
    updateStatus()
  }

  func perform() {
    updateStatus()
    guard _status == .Available else { return }
    guard let fromItem = exchangeItems[.From], let toItem = exchangeItems[.To] else { return }
    guard let fromAmount = fromItem.amount, let toAmount = toItem.amount else { return }
    let fromShortName = fromItem.currency.shortName
    let toShortName = toItem.currency.shortName
    let account = RVAccount.instance
    let success = account.exchange(fromShortName: fromShortName, toShortName: toShortName,
                                   fromAmount: fromAmount, toAmount: toAmount)
    if success {
      fromItem.amount = 0
      toItem.amount = 0
    }
    let fromSymbol = fromItem.currency.symbol
    let toSymbol = toItem.currency.symbol
    delegate?.onTransactionComplete(success, fromSymbol: fromSymbol, toSymbol: toSymbol,
                                    fromAmount: fromAmount, toAmount: toAmount)
    refresh(recentActiveSide)
  }

  //MARK: - Private functions
  private func updateStatus() {
    if stock.available {
      if let fromItem = exchangeItems[.From], let toItem = exchangeItems[.To] {
        if fromItem.currency == toItem.currency {
          _status = .Invalid
          return
        }
        if let fromAmount = fromItem.amount {
          let account = RVAccount.instance
          if account.check(fromItem.currency.shortName, amount: fromAmount) {
            _status = .Available
          } else {
            _status = .Invalid
          }
          return
        }
      }
    }
    _status = .Invalid
  }

}

extension RVTransaction: RVStockDelegate {

  func onStockStatusUpdated() {
    updateStatus()
  }

}