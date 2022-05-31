%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

# --------------------------------------------------------
# storage variables
# --------------------------------------------------------

# TODO: Test storage variables

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
func price_sources(asset : felt) -> (price : felt):
end

# --------------------------------------------------------
# modifiers
# --------------------------------------------------------

# TODO: Test mod

#add pool admin check
func AssetListingOrPoolAdmins{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
let (caller_address) = get_caller_address()
    let (caller_address) = get_caller_address()
    let (_asset_listing_admin) = asset_listing_admin.read()
    let (_pool_admin) = pool_admin.read()
    #let (pool_admin) = pool_admin.read()
    with_attr error_message(
            "Caller must be AssetListing or PoolAdmin. Got: {caller_address} Expected: {asset_listing_admin}."):
        assert caller_address = _asset_listing_admin
    end
    return()
end

# --------------------------------------------------------
# constructor
# --------------------------------------------------------

# TODO: Test constructor

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    pool_admin_address : felt, asset_listing_admin_address : felt, assets_len : felt, assets : felt*, sources_len : felt, sources : felt*
):

    #write admins
    pool_admin.write(pool_admin_address)
    asset_listing_admin.write(asset_listing_admin_address)

    #construct price_sources
    _setAssetSources(assets_len = assets_len, assets = assets, sources_len = sources_len, sources = sources)


    return ()
end

# --------------------------------------------------------
# getter methods
# --------------------------------------------------------

# TODO: Test these functions

#returns the price of an asset
@view
func getAssetPrice{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(_asset : felt) -> (res: felt):
    let (price) = price_sources.read(asset=_asset)
    return(price)
end


# --------------------------------------------------------
# external setter methods
# --------------------------------------------------------

# TODO: Test these functions

@external
func setAssetSources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
assets_len : felt, assets : felt*, sources_len : felt, sources: felt*):
#onlyAssetListingOrPoolAdmins
AssetListingOrPoolAdmins()
_setAssetSources(assets_len = assets_len, assets = assets, sources_len = sources_len, sources = sources)
return()
end

#should modify to ensure is coming from PoolAdmin
#add asset
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

# TODO: Test these functions

#constructor function creates key-pair values asset:price_source
#for this tutorial price_source = price
#input: pointer to array of assets, pointer to array of sources
#output : *DictAccess of asset:price key-pair map
#internal - only constructor can call
func _setAssetSources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
assets_len : felt, assets : felt*, sources_len : felt, sources : felt*
        ):

    with_attr error_message(
            "Must be same amount of assets and sources. Got: asset_len={assets_len} and sources_len={sources_len}."):
        assert assets_len = sources_len
    end
    
    if assets_len == 0:
        # When there are no more steps, just return the price_source pointer.
        return ()
    end


    #how do you write to a map
    _addAsset([assets], [sources])

    #recursively add
    return _setAssetSources(
                assets_len = assets_len - 1,
                assets = assets + 1,
                sources_len = sources_len - 1,
                sources = sources + 1
                )

end

func _addAsset{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
asset : felt, source : felt):
    #how do you write to a map
    price_sources.write(asset, source)
    return()
end

