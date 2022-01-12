// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;

import "./Meal.sol";
import "./OnlyExtended.sol";
import "./interfaces/IrERC20.sol";
import "./interfaces/IrERC721.sol";

contract Cooking is OnlyExtended {

    address private rm;
    mapping(address => Recipe) public recipes;
    address[] public meals;

    struct Recipe {
        string name;
        string effect;
        address[] ingredients;
        uint[] quantities;
    }

    constructor (address _rm) {
        rm = _rm;
    }

    function createNewRecipe(string memory name, string memory symbol, string memory effect, address[] memory ingredients, uint[] memory quantities) external onlyExtended {
        Meal meal = new Meal(name, symbol, msg.sender, rm);
        recipes[address(meal)] = Recipe(name, effect, ingredients, quantities);
        meals.push(address(meal));
    }

    function modifyRecipe(address mealAddr, Recipe memory newRecipe) external onlyExtended {
        recipes[mealAddr] = newRecipe;
    }

    function cook(address mealAddr, uint chef) external {
        Recipe memory recipe = recipes[mealAddr];

        for (uint256 i = 0; i < recipe.ingredients.length; i++) {
            IrERC20(recipe.ingredients[i]).burn(chef, recipe.quantities[i]);
        }

        IrERC721(mealAddr).mint(chef);
    }

}