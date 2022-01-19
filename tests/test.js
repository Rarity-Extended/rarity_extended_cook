const { expect } = require("chai");
const {
    rarityManifestedAddr,
    candiesAddr,
    meatAddr,
    mushroomAddr,
    berriesAddr,
    lootMinter
} = require("../registry.json");

describe("Cooking", function () {

    before(async function () {
        this.timeout(6000000000);

        [this.user, this.anotherUser, ...this.others] = await ethers.getSigners();

        //Deploy
        this.Cooking = await ethers.getContractFactory("Cooking");
        this.cooking = await this.Cooking.connect(this.user).deploy(rarityManifestedAddr);
        await this.cooking.deployed();

        this.rarity = new ethers.Contract(rarityManifestedAddr, [
            'function approve(address to, uint256 tokenId) external',
            'function summon(uint _class) external',
            'function next_summoner() external view returns(uint)',
        ], this.user);

        //Summon
        this.summoner = await this.rarity.next_summoner();
        await this.rarity.summon(1);

        //Impersonate and mint
        await hre.network.provider.request({
            method: "hardhat_impersonateAccount",
            params: [lootMinter],
        });
        this.lootMinterSigner = await ethers.getSigner(lootMinter);

        this.loot = new ethers.Contract(meatAddr, [
            'function mint(uint dst, uint amount) external',
            'function setMinter(address _minter) external',
            'function balanceOf(uint account) external view returns (uint)',
            'function approve(uint from, uint spender, uint amount) external returns (bool)'
        ], this.lootMinterSigner);

        await this.loot.attach(meatAddr).connect(this.lootMinterSigner).setMinter(lootMinter);
        await this.loot.attach(meatAddr).connect(this.lootMinterSigner).mint(this.summoner, 1000);
        await this.loot.attach(mushroomAddr).connect(this.lootMinterSigner).setMinter(lootMinter);
        await this.loot.attach(mushroomAddr).connect(this.lootMinterSigner).mint(this.summoner, 1000);

        //rERC721
        this.rERC721 = new ethers.Contract(ethers.constants.AddressZero, [
            'function balanceOf(uint owner) external view returns (uint balance)',
        ], this.user);
    });

    it("Should create new recipe...", async function () {
        let name = "My new recipe";
        let symbol = "MNR";
        let effect = "It does amazing things in your body";
        let ingredients = [meatAddr, mushroomAddr];
        let quantities = [20, 10];
        await this.cooking.createNewRecipe(name, symbol, effect, ingredients, quantities);

        let lastRecipeNonce = Number(await this.cooking.nonce()) - 1;
        let recipe = await this.cooking.recipesByIndex(lastRecipeNonce);
        expect(recipe.effect).equal(effect);
    });

    it("Should cook...", async function () {
        let lastRecipeNonce = Number(await this.cooking.nonce()) - 1;
        let mealAddr = await this.cooking.recipeAddressesByIndex(lastRecipeNonce);
        let summonerCook = await this.cooking.summonerCook();
        await this.loot.attach(meatAddr).connect(this.user).approve(this.summoner, summonerCook, ethers.constants.MaxUint256);
        await this.loot.attach(mushroomAddr).connect(this.user).approve(this.summoner, summonerCook, ethers.constants.MaxUint256);
        await this.rarity.approve(this.cooking.address, this.summoner);
        await this.cooking['cook(address,uint256)'](mealAddr, this.summoner);

        expect(await this.rERC721.attach(mealAddr).balanceOf(this.summoner)).equal(1);
    });

    it("Should pause a meal succesfully...", async function () {
        let lastRecipeNonce = Number(await this.cooking.nonce()) - 1;
        let mealAddr = await this.cooking.recipeAddressesByIndex(lastRecipeNonce);

        await this.cooking.pauseMealSwitch(mealAddr);
        await expect(this.cooking['cook(address,uint256)'](mealAddr, this.summoner)).to.be.revertedWith("isPaused");
    });

    it("Should unpause a meal succesfully...", async function () {
        let lastRecipeNonce = Number(await this.cooking.nonce()) - 1;
        let mealAddr = await this.cooking.recipeAddressesByIndex(lastRecipeNonce);

        await this.cooking.pauseMealSwitch(mealAddr);
        await expect(this.cooking['cook(address,uint256)'](mealAddr, this.summoner)).not.to.be.reverted;
    });

    it("Should modify a recipe...", async function () {
        let lastRecipeNonce = Number(await this.cooking.nonce()) - 1;
        let mealAddr = await this.cooking.recipeAddressesByIndex(lastRecipeNonce);
        let modifiedRecipe = {
            index: lastRecipeNonce,
            isPaused: false,
            name: "Another good recipe",
            effect: "Take it, good for your health",
            ingredients: [candiesAddr],
            quantities: [10]
        };
        await this.cooking.modifyRecipe(mealAddr, modifiedRecipe);

        let recipe = await this.cooking.recipesByIndex(lastRecipeNonce);
        expect(recipe.effect).equal(modifiedRecipe.effect);
    });

});