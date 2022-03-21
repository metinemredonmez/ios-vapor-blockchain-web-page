@_exported import Vapor

extension Droplet {
    public func setup() throws {
        setupControllers()
    }
    
    func setupControllers() {
        _ = BlockchainController(drop: self)
    }
}
