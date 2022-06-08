%lang starknet

@contract_interface
namespace ITestOracle:

    func getAssetPrice() -> (price : felt):
    end

end

@contract_interface
namespace IAAVEOracle:

    func getAssetPrice(asset : felt) -> (price : felt):
    end

    func getAssetSource(asset : felt) -> (source: felt):
    end

    func setAssetSources(assets_len : felt, assets : felt*, sources_len : felt, sources: felt*):
    end

    func addAsset(asset : felt, source : felt):
    end

end