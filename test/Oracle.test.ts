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

  
    before(async function() {
        this.timeout(0)
        //define oracle
        oracleContractFactory = await starknet.getContractFactory(
            "./contracts/src/Oracle"
        );

        //define oracleTest
        oracleTestContractFactory = await starknet.getContractFactory(
            "./contracts/src/TestOracle"
        );

        // //deploy oracle
        // console.log("deploying");
        // oracleContract = await oracleContractFactory.deploy({});
        // console.log("Oracle deployed at " + oracleContract.address);

        //deploy oracleTest1
        console.log("deploying Test Oracle 1 Constructor");
        oracleTest1 = await oracleTestContractFactory.deploy({asset: BigInt("10"),
        price: BigInt("1000")});
        console.log("oracleTest-1 deployed at " + oracleTest1.address);

        //deploy oracleTest2
        console.log("deploying Test Oracle 2 Constructor");
        oracleTest2 = await oracleTestContractFactory.deploy({asset: BigInt("20"),
        price: BigInt("2000")});
        console.log("oracleTest-2 deployed at " + oracleTest2.address);

      
        //deploy account
        // console.log("deploying account");
        // account = await starknet.deployAccount("OpenZeppelin");
        // accountAddress = account.starknetContract.address;
        // console.log("Account deployed at " + accountAddress);
      
        //deplot asset listing admin
        console.log("deploying asset listing admin");
        assetListingAdminAccount = await starknet.deployAccount("OpenZeppelin");
        assetListingAdminAddress = assetListingAdminAccount.starknetContract.address;
        console.log("Asset Listing Admin deployed at deployed at " + assetListingAdminAddress);

        //deploy pool admin
        console.log("deploying pool admin");
        poolAdminAccount = await starknet.deployAccount("OpenZeppelin");
        poolAdminAddress = assetListingAdminAccount.starknetContract.address;
        console.log("Pool Admin deployed at deployed at " + poolAdminAddress);

        //Deploy erc20 tokenTest1
        // console.log("deploying Test Token 1");
        // tokenTest1 = await ERC20Factory.deploy({
        //     name: BigInt("1415934836"),
        //     symbol: BigInt("5526356"),
        //     decimals: BigInt("18"),
        //     initial_supply: BigInt("1000"),
        //     recipient: accountAddress,
        // });
        // console.log("tokenTest1 contract deployed at " + tokenTest1.address);

        // //Deploy erc20-2 tokenTest2
        // console.log("deploying Test Token 2");
        // tokenTest2 = await ERC20Factory.deploy({
        //     name: 2415934836,
        //     symbol: 2526356,
        //     decimals: 28,
        //     initial_supply: bnToUint256(2000),
        //     recipient: accountAddress,
        // });
        // console.log("tokenTest2 contract deployed at " + tokenTest1.address);

        let assets = [BigInt("10"), BigInt("20")]
        let sources = [BigInt(oracleTest1.address), BigInt(oracleTest2.address)]

        //deploy oracle constructor
        console.log("deploying Oracle constructor");
        oracleContract = await oracleContractFactory.deploy({
            pool_admin_address: BigInt(poolAdminAddress),
            asset_listing_admin_address: BigInt(assetListingAdminAddress),
            //assets_len: BigInt(assets.length),
            assets: assets,
            //sources_len: BigInt(sources.length),
            sources: sources
        });
        console.log("Oracle deployed at " + oracleContract.address);



    });

    //pool_admin_address : felt, asset_listing_admin_address : felt, assets_len : felt, assets : felt*, sources_len : felt, sources : felt*
    it("Test Get Source", async () => {

        console.log("Testing getAssetSource: getting Asset 10 Source")
        let source = await oracleContract
            .call("getAssetSource", {
            //asset: tokenTest1.address,
            asset: BigInt("10")
            })
            //.then((res) => res.price);

        console.log("Got Asset 10 Source: Expecting Oracle1 address")
        expect(source["source"].toString()).equal(
            BigInt(number.toBN(oracleTest1.address).toString()).toString()
        );

    });


    it("Test Get Price", async () => {

        //Test get Asset Price from Source 
        console.log("Testing getAssetPrice: getting Asset 20 Price")
        let price = await oracleContract
            .call("getAssetPrice", {
            //asset: tokenTest1.address,
            asset: BigInt("20")
            })
            //.then((res) => res.price);

        console.log("Got Asset 20 Price: Expecting source = 2000")
        expect(price["price"].toString()).equal(
            BigInt("2000").toString()
        );

    });


    it("Test Bad Add Asset", async () => {

        console.log("Testing addAsset not Admin: add Asset 30")

        try {
            let source = await oracleContract
            .call("addAsset", {
            //asset: tokenTest1.address,
            asset: BigInt("30"),
            source: BigInt(oracleTest1.address)
            })
            expect.fail("Should have failed: not an Admin");
          } catch(err: any) {
            expect(err.message);
          }

    });

});
