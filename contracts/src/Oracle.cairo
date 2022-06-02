%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

# --------------------------------------------------------
#import interfaces
# --------------------------------------------------------
from lib.Interfaces.Interfaces import IOracle


# --------------------------------------------------------
# storage variables
# --------------------------------------------------------

#asset listing admin
@storage_var
func asset_listing_admin() -> (address : felt):
end

#pool admin
@storage_var
func pool_admin() -> (address : felt):
end

# storage variable mapping asset address to price oracle address
@storage_var
func asset_listing_or_pool_admin(caller : felt) -> (authorized_caller : felt):
end

# storage variable mapping asset address to price oracle address
@storage_var
func price_sources(asset : felt) -> (price : felt):
end

# --------------------------------------------------------
# modifiers
# --------------------------------------------------------

# TODO: Test mod
func AssetListingOrPoolAdmins{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (caller_address) = get_caller_address()
    let (authorized_caller) = asset_listing_or_pool_admin.read(caller=caller_address)
    with_attr error_message(
            "Caller must be AssetListing or PoolAdmin: Wanted: {authorized_caller} Got: {caller_address}."):
        assert caller_address = (authorized_caller)
    end
    return ()
end

# --------------------------------------------------------
# constructor
# --------------------------------------------------------

#Tested
#Sets variables
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pool_admin_address : felt,
    asset_listing_admin_address : felt,
    assets_len : felt,
    assets: felt*,
    sources_len : felt,
    sources: felt*
):
    #write admins
    pool_admin.write(pool_admin_address)
    asset_listing_admin.write(asset_listing_admin_address)
    asset_listing_or_pool_admin.write(pool_admin_address, pool_admin_address)
    asset_listing_or_pool_admin.write(asset_listing_admin_address, asset_listing_admin_address)
    #construct price_sources
    _setAssetSources(assets_len = assets_len,
                    assets = assets,
                    sources_len = sources_len,
                    sources = sources,
                    )
    return ()
end

# --------------------------------------------------------
# getter methods
# --------------------------------------------------------

#Tested
#calls oracle to return price of asset
@view
func getAssetPrice{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(asset : felt) -> (price: felt):
    let (source) = getAssetSource(asset=asset)
    let (price) = IOracle.getAssetPrice(
        contract_address=source
        )
    return(price)
end

#Tested
#returns price source for a single asset
@view
func getAssetSource{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(asset : felt) -> (source: felt):
    let (source) = price_sources.read(asset=asset)
    return(source)
end


# --------------------------------------------------------
# external setter methods
# --------------------------------------------------------

## TODO: Test these functions
@external
func setAssetSources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
assets_len : felt, assets : felt*, sources_len : felt, sources: felt*):
#onlyAssetListingOrPoolAdmins
AssetListingOrPoolAdmins()
_setAssetSources(assets_len = assets_len, assets = assets, sources_len = sources_len, sources = sources)
return()
end

### TODO: Test these functions
#Must be from AssetListing or Pool Admin
#add asset external
@external
func addAsset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
asset : felt, source : felt):
    AssetListingOrPoolAdmins()
    _addAsset(asset = asset, source = source)
    return () 
end




# --------------------------------------------------------
# internal setter methods
# --------------------------------------------------------

#Tested
#populates price_sources with key-pair values asset:price_source
func _setAssetSources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
assets_len : felt, assets : felt*, sources_len : felt, sources : felt*
):

    #ensure every asset has a source
    with_attr error_message(
            "Must be same amount of assets and sources. Got: asset_len={assets_len} and sources_len={sources_len}."):
        assert assets_len = sources_len
    end
    
    if assets_len == 0:
        # When there are no more steps, just return the price_source pointer.
        return ()
    end

    _addAsset([assets], [sources])

    #recursively add
    return _setAssetSources(
                assets_len = assets_len - 1,
                assets = assets + 1,
                sources_len = sources_len - 1,
                sources = sources + 1
                )

end

#Tested
#adds single asset to price_sources
func _addAsset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
asset : felt, source : felt):
    #how do you write to a map
    price_sources.write(asset, source)
    return()
end

