//
//  BlockchainController.swift
//  App
//
//  Created by Mohammad Azam on 1/11/18.
//

import Foundation
import Vapor
import HTTP

class BlockchainController {
    
    private (set) var drop :Droplet
    private (set) var blockchainService :BlockchainService
    
    init(drop :Droplet) {
        self.drop = drop
        self.blockchainService = BlockchainService()
        setupRoutes()
    }
    
    private func setupRoutes() {
        
        self.drop.post("/nodes/register") { request in
            
            if let blockchainNode = BlockchainNode(request: request) {
                self.blockchainService.registerNode(blockchainNode)
            }
            
            return try JSONEncoder().encode(["message":"success"])
        }
        
        
        self.drop.get("/driving-records/:drivingLicenseNumber") { request in
            
            guard let drivingLicenseNumber = request.parameters["drivingLicenseNumber"]?.string else {
                return try JSONEncoder().encode(["message":"drivingLicenseNumber parameter not found!"])
            }
            
            let blockchain = self.blockchainService.blockchain
            let transactions = blockchain?.transactionsBy(drivingLicenseNumber: drivingLicenseNumber)
            return try JSONEncoder().encode(transactions)
        }
        
        
        self.drop.get("/nodes/resolve") { request in
            
            return try Response.async { portal in
                
                self.blockchainService.resolve { blockchain in
                    let blockchain = try! JSONEncoder().encode(blockchain)
                    portal.close(with: blockchain.makeResponse())
                }
                
            }
            
        }
        
        self.drop.get("/nodes") { request in
            
            let nodes = self.blockchainService.blockchain.nodes
            return try JSONEncoder().encode(nodes)
            
        }
        
        self.drop.post("mine") { request in
            
            if let transaction = Transaction(request: request) {
                
                let block = self.blockchainService.getMinedBlock(transactions :[transaction])
               // block.addTransaction(transaction: transaction)
                return try JSONEncoder().encode(block)
            }
            
            return try JSONEncoder().encode(["message":"Something bad happend!"])
            
        }
        
        self.drop.get("blockchain") { request in
            
            let blockchain = self.blockchainService.getBlockchain()
            return try! JSONEncoder().encode(blockchain)
    
        }
        
    }
    
}
