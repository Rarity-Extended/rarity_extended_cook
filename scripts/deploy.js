const {
    rarityManifestedAddr
} = require("../registry.json");

async function main() {
    //Compile
    await hre.run("clean");
    await hre.run("compile");

    //Deploy
    // this.Contract = await ethers.getContractFactory("Cooking");
    // this.Contract = await this.Contract.deploy(rarityManifestedAddr);
    // console.log("Deployed to:", this.Contract.address);

    // //TEST

    // const   Gold = '0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2';
    // const   Mushroom = "0xcd80cE7E28fC9288e20b806ca53683a439041738";
    // const   Berries = "0x9d6C92CCa7d8936ade0976282B82F921F7C50696";
    // const   Wood = "0xdcE321D1335eAcc510be61c00a46E6CF05d6fAA1";
    // const   Leather = "0xc5E80Eef433AF03E9380123C75231A08dC18C4B6";
    // const   Meat = "0x95174B2c7E08986eE44D65252E3323A782429809";
    // const   Tusks = "0x60bFaCc2F96f3EE847cA7D8cC713Ee40114be667";
    // const   Candies = "0x18733f3C91478B122bd0880f41411efd9988D97E";

    // let name = "Grilled Meat";
    // let symbol = "GM";
    // let effect = "Wololo missa eat meat";
    // let ingredients = [Gold, Meat];
    // let quantities = [10, 10];
    // const   nextMeal = await this.Contract.nonce();
    // await (await this.Contract.createNewRecipe(name, symbol, effect, ingredients, quantities)).wait();
    // let recipe = await this.Contract.recipeAddressesByIndex(nextMeal);
    // console.log(recipe);

    // let cook = await this.Contract.summonerCook();
    // console.log(Number(cook));

    //Verify
    await hre.run("verify:verify", {
        address: '0x8cf1200204e81b8f1e610a2bfeeddf75e0d7bef0',
        constructorArguments: [
            'Grilled Meat',
            'Grilled Meat - (Meal)',
            '0xf6157fb663768ca6147f89f7495a8ab895bc4c4b',
            '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
        ],
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });