import {
    StarknetContract,
    StarknetContractFactory,
  } from "@shardlabs/starknet-hardhat-plugin/dist/src/types";
  
  import { expect } from "chai";
  //import { assert } from "console";
  //import { BigNumber, BigNumberish } from "ethers";
  import { starknet } from "hardhat";
  import { Account } from "hardhat/types";
  import { number } from "starknet";
  import { bnToUint256, Uint256 } from "starknet/dist/utils/uint256";
  
describe("Aave Oracle test", async () => {
    let oracleContractFactory: StarknetContractFactory;
    let oracleContract: StarknetContract;

    let oracleTestContractFactory: StarknetContractFactory;
    let oracleTest1: StarknetContract;
    let oracleTest2: StarknetContract;
    
    let ERC20Factory: StarknetContractFactory;
    let tokenTest1: StarknetContract;
    let tokenTest2: StarknetContract;

    let account: Account;
    let assetListingAdminAccount:Account
    let poolAdminAccount:Account

    let accountAddress: string;
    let assetListingAdminAddress:string;
    let poolAdminAddress: string;

  
    before(async () => {
        //define oracle
        oracleContractFactory = await starknet.getContractFactory(
            "./contracts/src/Oracle"
        );

        //define oracleTest
        oracleTestContractFactory = await starknet.getContractFactory(
            "./contracts/src/TestOracle"
        );

        //deploy oracle
        console.log("deploying");
        oracleContract = await oracleContractFactory.deploy({});
        console.log("Oracle deployed at " + oracleContract.address);

        //deploy oracleTest1
        console.log("deploying Test Oracle 1");
        oracleTest1 = await oracleTestContractFactory.deploy({});
        console.log("oracleTest-1 deployed at " + oracleTest1.address);

        //deploy oracleTest2
        console.log("deploying Test Oracle 2");
        oracleTest2 = await oracleTestContractFactory.deploy({});
        console.log("oracleTest-2 deployed at " + oracleTest2.address);

      
        //deploy account
        console.log("deploying account");
        account = await starknet.deployAccount("OpenZeppelin");
        accountAddress = account.starknetContract.address;
        console.log("Account deployed at deployed at" + accountAddress);
      
        //deplot asset listing admin
        console.log("deploying asset listing admin");
        assetListingAdminAccount = await starknet.deployAccount("OpenZeppelin");
        assetListingAdminAddress = account.starknetContract.address;
        console.log("Asset Listing Admin deployed at deployed at " + assetListingAdminAddress);

        //deploy pool admin
        console.log("deploying pool admin");
        poolAdminAccount = await starknet.deployAccount("OpenZeppelin");
        poolAdminAddress = account.starknetContract.address;
        console.log("Pool Admin deployed at deployed at " + poolAdminAddress);
  
        //Deploy erc20 tokenTest1
        console.log("deploying Test Token 1");
        tokenTest1 = await ERC20Factory.deploy({
            name: 1415934836,
            symbol: 5526356,
            decimals: 18,
            initial_supply: bnToUint256(1000),
            recipient: accountAddress,
        });
        console.log("tokenTest1 contract deployed at " + tokenTest1.address);

        //Deploy erc20-2 tokenTest2
        console.log("deploying Test Token 2");
        tokenTest2 = await ERC20Factory.deploy({
            name: 2415934836,
            symbol: 2526356,
            decimals: 28,
            initial_supply: bnToUint256(2000),
            recipient: accountAddress,
        });
        console.log("tokenTest2 contract deployed at " + tokenTest1.address);
    });

    //pool_admin_address : felt, asset_listing_admin_address : felt, assets_len : felt, assets : felt*, sources_len : felt, sources : felt*
    it("Construct Oracle", async () => {

        //contruct test oracle 1
        await account.invoke(oracleTest1, "construct", {
            _asset: tokenTest1.address,
            _price: 1000
        })

        //construct test oracle 2
        await account.invoke(oracleTest2, "construct", {
            _asset: tokenTest2.address,
            _price: 2000
        })

        let assets = [tokenTest1.address, tokenTest2.address]
        let sources = [oracleTest1.address, oracleTest2.address]

        //contruct the Oracle contract
        await account.invoke(oracleContract, "construct", {
            pool_admin_address: poolAdminAddress,
            asset_listing_admin_address: assetListingAdminAddress,
            assets_len: assets.length,
            assets: assets,
            sources_len: sources.length,
            sources: sources,
        });

        let source = await oracleContract
            .call("getAssetSource", {
            asset: tokenTest1.address,
            })
            //.then((res) => res.price);

        expect(source.toString()).equal(
            number.toBN(tokenTest1.address).toString()
        );
    });
});
