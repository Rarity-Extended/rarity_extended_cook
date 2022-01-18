// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Meal.sol";
import "./OnlyExtended.sol";
import "./interfaces/IMeal.sol";
import "./interfaces/IRarity.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IrERC721.sol";

contract Cooking is OnlyExtended {

    address private rm;
    mapping(address => Recipe) public recipes;
    address[] public meals;
    uint public summonerCook;

    event createdNewRecipe(string name, string symbol, string effect, address[] ingredients, uint[] quantities);
    event modifiedRecipe(address mealAddr);
    event cooked(address mealAddr, uint chef);

    struct Recipe {
        string name;
        string effect;
        address[] ingredients;
        uint[] quantities;
    }

    struct MealBalance {
        address meal;
        uint[] balance;
    }

    constructor (address _rm) {
        rm = _rm;
        summonerCook = IRarity(rm).next_summoner();
        IRarity(rm).summon(8);
    }

    function createNewRecipe(string memory name, string memory symbol, string memory effect, address[] memory ingredients, uint[] memory quantities) external onlyExtended {
        require(ingredients.length == quantities.length, "!length");
        Meal meal = new Meal(name, symbol, address(this), rm);
        address newMealAddr = address(meal);
        recipes[newMealAddr] = Recipe(name, effect, ingredients, quantities);
        meals.push(newMealAddr);
        emit createdNewRecipe(name, symbol, effect, ingredients, quantities);
    }

    function modifyRecipe(address mealAddr, Recipe memory newRecipe) external onlyExtended {
        recipes[mealAddr] = newRecipe;
        emit modifiedRecipe(mealAddr);
    }

    function cook(address mealAddr, uint chef) external {
        Recipe memory recipe = recipes[mealAddr];

        for (uint256 i = 0; i < recipe.ingredients.length; i++) {
            IrERC20(recipe.ingredients[i]).transferFrom(summonerCook, chef, type(uint).max, recipe.quantities[i]);
        }

        IrERC721(mealAddr).mint(chef);
        emit cooked(mealAddr, chef);
    }

    function getTotalMealsBySummoner(uint256 summonerId) public view returns (MealBalance[] memory) {
        MealBalance[] memory totalMeals = new MealBalance[](meals.length);

        for (uint256 i = 0; i < meals.length; i++) {
            uint[] memory _meals = IMeal(meals[i]).getMealsBySummoner(summonerId);
            totalMeals[i] = MealBalance(meals[i], _meals);
        }

        return totalMeals;
    }

    function getRecipeByMealName(string memory name) external view returns (Recipe memory) {
        for (uint256 i = 0; i < meals.length; i++) {
            Recipe memory current = recipes[meals[i]];
            if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(current.name))) {
                return current;
            }
        }

        address[] memory emptyIngredients = new address[](0);
        uint[] memory emptyQuantities = new uint[](0);
        return Recipe("", "", emptyIngredients, emptyQuantities);
    }

    function getMealAddressByMealName(string memory name) external view returns (address) {
        for (uint256 i = 0; i < meals.length; i++) {
            Recipe memory current = recipes[meals[i]];
            if (keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked(current.name))) {
                return meals[i];
            }
        }

        return address(0);
    }

}