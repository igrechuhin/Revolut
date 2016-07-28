//
//  RVStock.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 23.07.16.
//
//

import Foundation

protocol RVStockDelegate: class {

  func onStockStatusUpdated()

}

final class RVStock {

  //MARK: - Const
  private struct Const {
    // TODO: Replace with https version of url in real app
    static let url = NSURL(string: "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")!

    static let baseCurrency = "EUR"
  }

  //MARK: - Public var
  var available: Bool {
    var available = false
    if rates.lock.tryLock() {
      available = rates.valid
      rates.lock.unlock()
    }
    return available
  }

  weak var delegate: RVStockDelegate?

  //MARK: - Private let
  private let rates = RVRates()
  private let fetcher = RVRatesFetcher(stockUrl: Const.url)

  //MARK: - Public functions
  init() {
    fetcher.rates = rates
    fetcher.delegate = self
    fetcher.fetch()
    fetcher.schedule()
  }

  func getRate(fromShortName fromShortName: String, toShortName: String) -> Double? {
    guard fromShortName != toShortName else { return 1.0 }
    guard rates.lock.tryLock() else { return nil }

    func rate(shortName: String) -> Double? {
      return shortName == Const.baseCurrency ? 1.0 : rates[shortName]
    }

    guard let numerator = rate(toShortName) else { return nil }
    guard let denominator = rate(fromShortName) where !denominator.isZero else { return nil }

    rates.lock.unlock()
    return numerator / denominator
  }

  func estimateAmount(fromShortName fromShortName: String, toShortName: String, fromAmount: Double) -> Double? {
    guard let rate = getRate(fromShortName: fromShortName, toShortName: toShortName) else { return nil }

    return fromAmount * rate
  }

}

extension RVStock: RVRatesFetcherDelegate {

  func onRatesUpdateStarted() {
    delegate?.onStockStatusUpdated()
  }

  func onRatesUpdateCompleted() {
    delegate?.onStockStatusUpdated()
  }

}