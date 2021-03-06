//
//  BITTREXApiTest.swift
//  BalanceUnitTests
//
//  Created by Naranjo on 12/13/17.
//  Copyright © 2017 Balanced Software, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import BalancemacOS

class BITTREXApiTest: XCTestCase {
    
    private let mockInstitutionRepository = MockInstitutionRepository()
    
    func testShouldGetBalances() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: balancesMockURLSession, institutionRepository: mockInstitutionRepository)
            .performAction(for: .getBalances,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let balances = result.object as? [BITTREXBalance],
                                let balance = balances.first else {
                                    XCTFail("Invalid balance Response")
                                    return
                            }
                            
                            XCTAssertTrue(balance.currency == "ADA", "Invalid currency")
                            XCTAssertTrue(balance.balance == 30000, "Invalid balance")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetCurrencies() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: currenciesMockURLSession, institutionRepository: mockInstitutionRepository)
            .performAction(for: .getCurrencies,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let currencies = result.object as? [BITTREXCurrency],
                                let currency = currencies.first else {
                                    XCTFail("Invalid balance Response")
                                    return
                            }
                            
                            XCTAssertTrue(currency.currency == "BTC", "Invalid currency")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetDeposits() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: depositsMockURLSession)
            .performAction(for: .getAllDepositHistory,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let deposits = result.object as? [BITTREXDeposit],
                                let deposit = deposits.first else {
                                    assertionFailure("Invalid deposits Response")
                                    return
                            }
                            
                            XCTAssertTrue(deposit.id == 47273562, "Invalid payment ID")
                            XCTAssertTrue(deposit.currency == "ETH", "Invalid currency")
                            XCTAssertTrue(deposit.amount == 19.9995622, "Invalid amount")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetWithdrawals() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: withdrawalsMockURLSession)
            .performAction(for: .getAllWithdrawalHistory,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard let withdrawals = result.object as? [BITTREXWithdrawal], let withdrawal = withdrawals.first else {
                                XCTFail("Invalid withdrawals Response")
                                return
                            }
                            
                            XCTAssertTrue(withdrawal.paymentUuid == "b52c7a5c-90c6-4c6e-835c-e16df12708b1", "Invalid payment UUID")
                            XCTAssertTrue(withdrawal.currency == "BTC", "Invalid currency")
                            XCTAssertTrue(withdrawal.amount == 17, "Invalid amount")
                            
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
    func testShouldGetAPIInvalidAPIKeyError() {
        let asyncTaskExpectation = expectation(description: "\(#function)\(#line)")
        
        BITTREXApi(urlSession: messageErrorMockURLSession)
            .performAction(for: .getCurrencies,
                           apiKey: "mockAPIKey123",
                           secretKey: "mockSecretKey") { (result) in
                            guard case let .message(errorDescription)? = result.error as? BITTREXApiError else {
                                XCTFail("ApiKey should be invalid")
                                return
                            }
                            
                            XCTAssertTrue(errorDescription == "Invalid aipkey")
                            asyncTaskExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            print(error ?? "Error waiting expectation")
        }
    }
    
}

private extension BITTREXApiTest {
    
    var balancesMockURLSession: URLSession {
        let balancesData = BITTREXDataHelper.loadBalances()
        return createMockURLSession(with: balancesData)
    }
    
    var currenciesMockURLSession: URLSession {
        let currenciesData = BITTREXDataHelper.loadCurrencies()
        return createMockURLSession(with: currenciesData)
    }
    
    var depositsMockURLSession: URLSession {
        let depositsData = BITTREXDataHelper.loadDeposits()
        return createMockURLSession(with: depositsData)
    }
    
    var withdrawalsMockURLSession: URLSession {
        let withdrawalsData = BITTREXDataHelper.loadWithdrawals()
        return createMockURLSession(with: withdrawalsData)
    }
    
    var messageErrorMockURLSession: URLSession {
        let invalidKeyData = BITTREXDataHelper.loadInvalidApiKey()
        return createMockURLSession(with: invalidKeyData)
    }
    
    func createMockURLSession(with responseData: Data?, statusCode: Int? = nil) -> URLSession {
        let mockURLSession = ExchangeAPIURLSession()
        let urlResponse = ExchangeAPIURLSession.httpURLResponse(statusCode: statusCode ?? 200)
        let mockResponse = MockDataTaskResponse(data: responseData,
                                                response: urlResponse,
                                                error: nil)
        mockURLSession.dataTask = mockResponse
        
        return mockURLSession
    }
    
}
