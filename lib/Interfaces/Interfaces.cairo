%lang starknet

@contract_interface
namespace IOracle:
    func getAssetPrice() -> (price : felt):
    end
end