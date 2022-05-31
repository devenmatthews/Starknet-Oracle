%builtins output
from starkware.cairo.common.dict_access import DictAccess
from starkware.cairo.common.squash_dict import squash_dict
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.dict import dict_read, dict_write, dict_new

#constructor function creates key-pair values asset:price_source
#for this tutorial price_source = price
#input: pointer to array of assets, pointer to array of sources
#output : *DictAccess of asset:price key-pair map
func setAssetSources(asset_list:felt*,
                    price_list:felt*,
                    n_steps,
                    price_source: DictAccess*) -> (price_source : DictAccess*):

    if n_steps == 0:
        # When there are no more steps, just return the price_source pointer.
        return (price_source)
    end

    assert price_source.key = [asset_list]

    assert price_source.new_value = [price_list]

    #recursively add
    return setAssetSources(
                asset_list = asset_list + 1,
                price_list = price_list + 1,
                n_steps = n_steps - 1,
                price_source = price_source + DictAccess.SIZE
                )

end

#add asset
# func addAsset(
#                 price_source: *DictAccess,
#                 asset: *felt ,
#                 price: *felt) -> (price_source: *DictAccess):
    
#     assert price_source.key = [asset]
#     assert price_source.new_value = [price]

#     return (price_source) 

# end

#returns the price of an asset
func getAssetPrice{output_ptr : felt*}(price_source : DictAccess*, asset: felt) -> (price: felt):
    alloc_locals
    let (__fp__, _) = get_fp_and_pc()
    let price_source_ptr = price_source
    let (local price: felt) = dict_read{dict_ptr= price_source_ptr}(key = asset)
    return(price)
end

func main{output_ptr : felt*}():
    alloc_locals
    #local asset_list : (felt, felt, felt, felt, felt) = (10, 20, 30, 40, 50)
    #local price_list : (felt, felt, felt, felt, felt) = (100, 200, 300, 400, 500)

    let (__fp__, _) = get_fp_and_pc()

    %{
    initial_dict = {10:100, 20:200, 30:300, 40:400, 50:500}
    %}

    let (local price_sources_start : DictAccess*) = dict_new()

    # let (local price_sources_end: DictAccess*) = setAssetSources(
    #                                     asset_list = cast(&asset_list, felt*),
    #                                     price_list = cast(&price_list, felt*),
    #                                     n_steps = 5,
    #                                     price_source = price_sources_start)

    #release error
    #let price_source_release = cast(&price_source_end, DictAccess*)
    #let price_source_en = 0

    let (local price : felt) = getAssetPrice(price_source = price_sources_start,asset = 20)
    # serialize_word(price)
    return()
end
