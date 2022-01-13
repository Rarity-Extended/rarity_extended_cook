const { expect } = require("chai");
const {
    rarityManifestedAddr
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
    });

    it("Should create new recipe...", async function () {

    });

    it("Should modify a recipe...", async function () {

    });

    it("Should cook...", async function () {

    });

});