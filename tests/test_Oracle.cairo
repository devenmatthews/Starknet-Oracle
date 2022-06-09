%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from lib.Interfaces.Interfaces import IAAVEOracle
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math import assert_not_equal, assert_not_zero

const PRANKED_POOL_ADMIN = 123
const PRANKED_ASSET_LISTING_ADMIN = 456

const ASSET_1 = 100
const ASSET_2 = 200
const ASSET_3 = 300
const ASSET_4 = 400

@view
func __setup__{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():

    %{ 
    context.test_oracle_1_address = deploy_contract("contracts/src/TestOracle.cairo", [ids.ASSET_1, 1000]).contract_address
    context.test_oracle_2_address = deploy_contract("contracts/src/TestOracle.cairo", [ids.ASSET_2, 2000]).contract_address 
    context.test_oracle_3_address = deploy_contract("contracts/src/TestOracle.cairo", [ids.ASSET_3, 3000]).contract_address
    context.oracle_address = deploy_contract("contracts/src/Oracle.cairo", [ids.PRANKED_POOL_ADMIN, ids.PRANKED_ASSET_LISTING_ADMIN, 2, ids.ASSET_1, ids.ASSET_2, 2, context.test_oracle_1_address, context.test_oracle_2_address]).contract_address
     %}

    return ()
end

@external
func test_get_price{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    tempvar oracle_address : felt
    %{ ids.oracle_address = context.oracle_address %}

    #Get Price of ASSET_1 = 100
    let (res) = IAAVEOracle.getAssetPrice(contract_address = oracle_address, asset = 100)
    assert res = 1000
    return()
end

@external
func test_source_of_asset{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    tempvar oracle_address : felt
    %{ ids.oracle_address = context.oracle_address %}

    tempvar asset_1_source : felt
    %{ ids.asset_1_source = context.test_oracle_1_address %}

    #Get Source of ASSET_1 = 100
    let (res) = IAAVEOracle.getSourceOfAsset(contract_address = oracle_address, asset = 100)
    assert res = asset_1_source
    return()
end

@external
func test_bad_get_asset{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local oracle_address : felt
    %{ ids.oracle_address = context.oracle_address %}

    let (res) = IAAVEOracle.getAssetPrice(contract_address = oracle_address, asset = 999)
    assert res = 0
    return()
end

# @external
# func test_not_admin{syscall_ptr : felt*, range_check_ptr}():
#     alloc_locals

#     local oracle_address : felt
#     local test_oracle_1_address : felt
#     %{ ids.oracle_address = context.oracle_address %}
#     %{ ids.test_oracle_1_address = context.test_oracle_1_address %}

#     IAAVEOracle.addAsset(contract_address = oracle_address, asset = 999, source = test_oracle_1_address)
#     #assert res.error_message = "Caller must be AssetListing or PoolAdmin."
#     return()
# end

@external
func test_pool_admin{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local oracle_address : felt
    local test_oracle_3_address : felt
    %{ ids.oracle_address = context.oracle_address %}
    %{ ids.test_oracle_3_address = context.test_oracle_3_address %}

    %{ stop_prank_pool_admin = start_prank(ids.PRANKED_POOL_ADMIN, target_contract_address=ids.oracle_address) %}
    IAAVEOracle.addAsset(contract_address = oracle_address, asset = ASSET_3, source = test_oracle_3_address)
    let (res) = IAAVEOracle.getAssetPrice(contract_address = oracle_address, asset = ASSET_3)
    assert res = 3000
    
    %{ stop_prank_pool_admin()%}
    return()
end

@external
func test_asset_listing_admin{syscall_ptr : felt*, range_check_ptr}():
    alloc_locals

    local oracle_address : felt
    local test_oracle_1_address : felt
    %{ ids.oracle_address = context.oracle_address %}
    %{ ids.test_oracle_1_address = context.test_oracle_1_address %}

    %{ stop_prank_asset_listing_admin = start_prank(ids.PRANKED_ASSET_LISTING_ADMIN, target_contract_address=ids.oracle_address) %}
    IAAVEOracle.addAsset(contract_address = oracle_address, asset = ASSET_4, source = test_oracle_1_address)
    let (res) = IAAVEOracle.getAssetPrice(contract_address = oracle_address, asset = ASSET_4)
    assert res = 1000
    
    %{ stop_prank_asset_listing_admin()%}
    return()
end