
//: Playground - noun: a place where people can play

import Cocoa
import Vapor

class BlockchainNode : Codable {
    
    var address :String
    
    init?(request :Request) {
        
        guard let address = request.data["address"]?.string else {
            return nil
        }
        
        self.address = address
        
    }
    
    init(address :String) {
        self.address = address
    }
    
}

class Transaction : Codable {
    
    var driverLicenseNumber :String
    var voilationType :String
    var noOfVoilations :Int = 1
    var isDrivingLicenseSuspended :Bool = false
    
    init(licenseNoHash :String, voilationType :String) {
        self.driverLicenseNumber = licenseNoHash
        self.voilationType = voilationType
    }
    
    init?(request :Request) {
        
        guard let driverLicenseNumber = request.data["driverLicense"]?.string,
            let voilationType = request.data["voilationType"]?.string else {
                return nil
        }
        
        self.driverLicenseNumber = driverLicenseNumber.sha1Hash()
        self.voilationType = voilationType
        
    }
    
}

class Block : Codable  {
    
    var index :Int = 0
    var previousHash :String = ""
    var hash :String!
    var nonce :Int
    
    private (set) var transactions :[Transaction] = [Transaction]()
    
    var key :String {
        get {
            
            let transactionsData = try! JSONEncoder().encode(self.transactions)
            let transactionsJSONString = String(data: transactionsData, encoding: .utf8)
            
            return String(self.index) + self.previousHash + String(self.nonce) + transactionsJSONString!
        }
    }
    
    func addTransaction(transaction :Transaction) {
        self.transactions.append(transaction)
    }
    
    init() {
        self.nonce = 0
    }
    
}

class Blockchain : Codable  {
    
    var blocks :[Block] = [Block]()
    
    private var drivingRecordSmartContract :DrivingRecordSmartContract = DrivingRecordSmartContract()
    
    private (set) var nodes :[BlockchainNode] = [BlockchainNode]()
    
    init(genesisBlock :Block) {
        addBlock(genesisBlock)
    }
    
    func addNode(_ node :BlockchainNode) {
        self.nodes.append(node)
    }
    
    func addBlock(_ block :Block) {
        
        if self.blocks.isEmpty {
            block.previousHash = "0000000000000000"
            block.hash = generateHash(for :block)
        }
        
        self.blocks.append(block)
    }
    
    func transactionsBy(drivingLicenseNumber :String) -> [Transaction] {
        
        var transactions = [Transaction]()
        
        self.blocks.forEach { block in
            
            block.transactions.forEach { transaction in
                
                if transaction.driverLicenseNumber == drivingLicenseNumber.sha1Hash() {
                    transactions.append(transaction)
                }
            }
        }
        
        return transactions
        
    }
    
    func getNextBlock(transactions :[Transaction]) -> Block {
        
        let block = Block()
        transactions.forEach { transaction in
            
            // applying smart contract
            self.drivingRecordSmartContract.apply(transaction: transaction, allBlocks: self.blocks)
            
            block.addTransaction(transaction: transaction)
        }
        
        let previousBlock = getPreviousBlock()
        block.index = self.blocks.count
        block.previousHash = previousBlock.hash
        block.hash = generateHash(for: block)
        return block
        
    }
    
    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }
    
    func generateHash(for block :Block) -> String {
        
        var hash = block.key.sha1Hash()
        
        while(!hash.hasPrefix("00")) {
            block.nonce += 1
            hash = block.key.sha1Hash()
            print(hash)
        }
        
        return hash
    }
    
}

// String Extension
extension String {
    
    func sha1Hash() -> String {
        
        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []
        
        let inputPipe = Pipe()
        
        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)
        
        inputPipe.fileHandleForWriting.closeFile()
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()
        
        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "  -\n", with: "")
    }
}















