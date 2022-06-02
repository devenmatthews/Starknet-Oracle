%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc

# --------------------------------------------------------
# storage variables
# --------------------------------------------------------
#pool admin
@storage_var
func _asset() -> (address : felt):
end

#pool admin
@storage_var
func _price() -> (address : felt):
end


# --------------------------------------------------------
# constructor
# --------------------------------------------------------

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    asset : felt, price : felt
):
    #write asset-price
    _asset.write(asset)
    _price.write(price)
    return ()
end

# --------------------------------------------------------
# getter methods
# --------------------------------------------------------

#returns the price of the asset
@view
func getAssetPrice{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}() -> (price: felt):
    let (price) = _price.read()
    return(price)
end