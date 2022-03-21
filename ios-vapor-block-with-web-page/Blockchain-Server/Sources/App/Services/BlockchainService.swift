//
//  BlockchainService.swift
//  App
//
//  Created by Mohammad Azam on 1/11/18.
//

import Foundation

class BlockchainService {
    
    private (set) var blockchain :Blockchain!
    
    init() {
        self.blockchain = Blockchain(genesisBlock: Block())
    }
    
    func resolve(completion :@escaping (Blockchain) -> ()) {
        
        let nodes = self.blockchain.nodes
        
        for node in nodes {
            
            let url = URL(string :"http://\(node.address)/blockchain")!
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                
                if let data = data {
                    
                    let blockchain = try! JSONDecoder().decode(Blockchain.self, from: data)
                    
                    if self.blockchain.blocks.count > blockchain.blocks.count {
                        completion(self.blockchain)
                    } else {
                        self.blockchain.blocks = blockchain.blocks
                        completion(blockchain)
                    }
                    
                }
                
                
            }.resume()
            
            
        }
        
    }
    
    func registerNode(_ node :BlockchainNode) {
        self.blockchain.addNode(node)
    }
    
    func getMinedBlock(transactions :[Transaction]) -> Block {
        
        let block = self.blockchain.getNextBlock(transactions: transactions)
        self.blockchain.addBlock(block)
        return block
    }
    
    func getBlockchain() -> Blockchain {
        return self.blockchain
    }
    
}
