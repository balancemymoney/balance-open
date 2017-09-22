//
//  EtherscanAccount.swift
//  BalancemacOS
//
//  Created by Raimon Lapuente Ferran on 06/09/2017.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation

struct EthplorerAccount {
    let type: AccountType
    let currency: Currency
    
    let address: String
    let available: Double
    let altRate: Double
    let altCurrency: Currency
    let decimals: Int
}

struct EthplorerAccountObject {
    let type: AccountType
    
    let currency: Currency
    
    let address: String
    let ETH: Eth
    let tokens: [Token]
    
    init(dictionary: [String: Any], currencyShortName: String, type: AccountType) throws {
        self.type = type
        self.currency = Currency.rawValue(shortName: "ETH")
    
        self.address = try checkType(dictionary["address"], name: "address")
        
        let ethDict: [String: Any] = try checkType(dictionary["ETH"], name: "ETH")
        self.ETH = try Eth(dictionary: ethDict)
        
        let tokensArray: [[String: Any]] = try checkType(dictionary["tokens"], name: "tokens")
        var tokens = [Token]()
        for token in tokensArray {
            tokens.append(try Token(dictionary: token))
        }
        self.tokens = tokens
    }
    
    struct Eth {
        let balance: Double
        let totalIn: Double
        let totalOut: Double
        
        init(dictionary: [String: Any]) throws {
            self.balance = try checkType(dictionary["balance"], name: "balance")
            self.totalIn = try checkType(dictionary["totalIn"], name: "totalIn")
            self.totalOut = try checkType(dictionary["totalOut"], name: "totalOut")
        }
    }
    
    struct Token {
        let tokenInfo: TokenInfo
        let balance: Double
        let totalIn: Double
        let totalOut: Double
        
        init (dictionary: [String: Any]) throws {
            self.balance = try checkType(dictionary["balance"], name: "balance")
            self.totalIn = try checkType(dictionary["totalIn"], name: "totalIn")
            self.totalOut = try checkType(dictionary["totalOut"], name: "totalOut")
            let tokenInfoDict: [String: Any] = try checkType(dictionary["tokenInfo"], name: "tokenInfo")
            self.tokenInfo = try TokenInfo(dictionary: tokenInfoDict)
        }
    }
    
    struct TokenInfo {
        let address: String
        let name: String
        let decimals: Int
        let symbol: String
        let price: ExchangePrice?
        
        init (dictionary: [String: Any]) throws {
            self.address = try checkType(dictionary["address"], name: "address")
            self.name = try checkType(dictionary["name"], name: "name")
            self.decimals = try checkType(dictionary["decimals"], name: "decimals")
            self.symbol = try checkType(dictionary["symbol"], name: "symbol")
            if dictionary["price"] is Bool {
                self.price = nil
            } else {
                let priceDict: [String: Any] = try checkType(dictionary["price"], name: "price")
                self.price = try ExchangePrice(dictionary: priceDict)
            }
        }
    }
    
    //empty info
    struct ExchangePrice {
        let rate: Double
        let currency: Currency
        let diff: Double
        
        init (dictionary: [String: Any]) throws {
            self.rate = try checkType(dictionary["rate"], name: "rate")
            self.currency = .common(traditional: .usd)
            self.diff = try checkType(dictionary["diff"], name: "diff")
        }
    }
    
    var ethplorerAccounts: [EthplorerAccount] {
        var arrayOlder = [EthplorerAccount]()
        let ethAccount = EthplorerAccount(type: .wallet, currency: self.currency, address: self.address, available: self.ETH.balance, altRate: 0, altCurrency: Currency.rawValue(shortName: "BTC"), decimals: 8)
        arrayOlder.append(ethAccount)
        for ethplorerObject in self.tokens {
            var altRate: Double = 0
            var altCurrency: Currency = Currency.common(traditional: .usd)
            if let tokenPrice = ethplorerObject.tokenInfo.price {
                altRate = tokenPrice.rate
                altCurrency = tokenPrice.currency
            }
            let balance = ethplorerObject.balance.cientificToEightDecimals(decimals: ethplorerObject.tokenInfo.decimals)
            
            let tokenAccount = EthplorerAccount(type: .wallet, currency: Currency.rawValue(shortName: ethplorerObject.tokenInfo.symbol), address: ethplorerObject.tokenInfo.address, available: balance, altRate: altRate, altCurrency: altCurrency, decimals: 8)
            arrayOlder.append(tokenAccount)
        }
        return arrayOlder
    }
}