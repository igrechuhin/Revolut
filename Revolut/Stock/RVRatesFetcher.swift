//
//  RVRatesFetcher.swift
//  Revolut
//
//  Created by Ilya Grechuhin on 22.07.16.
//
//

import Foundation

protocol RVRatesFetcherDelegate: class {

  func onRatesUpdateStarted()
  func onRatesUpdateCompleted()

}

final class RVRatesFetcher : NSObject {

  //MARK: - Const
  private struct Const {
    static let fetchInterval: NSTimeInterval = 30

    static let dataTag = "Cube"

    static let symbolKey = "currency"
    static let rateKey = "rate"
  }

  //MARK: - Public var
  weak var rates: RVRates?
  weak var delegate: RVRatesFetcherDelegate?

  //MARK: - Private var
  private var stockUrl: NSURL
  private var timer: NSTimer?

  //MARK: - Public functions
  init(stockUrl: NSURL) {
    self.stockUrl = stockUrl
    super.init()
  }

  deinit {
    timer?.invalidate()
  }

  func schedule() {
    timer = NSTimer.scheduledTimerWithTimeInterval(Const.fetchInterval, target: self, selector: #selector(fetch), userInfo: nil, repeats: true)
  }

  func fetch() {
    guard let rates = rates else { return }

    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)) {
      rates.lock.lock()
      rates.valid = false

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.onRatesUpdateStarted()
      }

      if let parser = NSXMLParser(contentsOfURL: self.stockUrl) {
        parser.delegate = self
        rates.valid = parser.parse()
      }
      rates.lock.unlock()

      dispatch_async(dispatch_get_main_queue()) {
        self.delegate?.onRatesUpdateCompleted()
      }
    }
  }

}

extension RVRatesFetcher : NSXMLParserDelegate {

  func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?,
              qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    guard elementName == Const.dataTag && !attributeDict.isEmpty else { return }
    guard let currencyShortName = attributeDict[Const.symbolKey], let rate = attributeDict[Const.rateKey] else { return }
    guard let rates = rates else { return }

    rates[currencyShortName] = Double(rate)
  }
  
}