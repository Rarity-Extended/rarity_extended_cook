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

    event createdNewRecipe(address addr, string name, string symbol, string effect, address[] ingredients, uint[] quantities);
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

    /**********************************************************************************************
    **  @dev Add a new recipe in the cookbook. The recipe has a name, a symbol, an effect and a
    **  list of ingredients. The ingredients are the addresses of the meals. The quantities are 
    **  also provided in an array of the same size.
    **	@param name: Name of the recipe and the associated ERC721. Must be unique.
    **	@param symbol: Symbol of the recipe and the associated ERC721.
    **	@param effect: Information about the recipe. Abstract.
    **	@param ingredients: Array of the addresses of the ingredients required. rERC20.
    **	@param quantities: Array of the quantities of the ingredients required.
    **  @return the address of the new meal contract
    **********************************************************************************************/
    function createNewRecipe(
        string memory name,
        string memory symbol,
        string memory effect,
        address[] memory ingredients,
        uint[] memory quantities
    ) external onlyExtended returns (address) {
        require(ingredients.length == quantities.length, "!length");

        Meal meal = new Meal(name, symbol, address(this), rm);
        address newMealAddr = address(meal);
        recipes[newMealAddr] = Recipe(name, effect, ingredients, quantities);
        meals.push(newMealAddr);
        emit createdNewRecipe(newMealAddr, name, symbol, effect, ingredients, quantities);
    }

    function modifyRecipe(address mealAddr, Recipe memory newRecipe) external onlyExtended {
        recipes[mealAddr] = newRecipe;
        emit modifiedRecipe(mealAddr);
    }

    /**********************************************************************************************
    **  @dev Cook a new meal. The meal is created with the recipe provided. It mint a new ERC721
    **  for the adventurer. The ingredients required are sent to the cook and locked in this
    **  contract forever.
    **  An optional receiver uint can be provided. If provided, the meal is sent to this uint
    **  instead.
    **	@param mealAddr: Address of the mean contract.
    **	@param adventurer: Adventurer asking to cook the meal.
    **	@param receiver: Adventurer receiving the cooked meal.
    **********************************************************************************************/
    function cook(address mealAddr, uint adventurer) external {
        Recipe memory recipe = recipes[mealAddr];

        for (uint256 i = 0; i < recipe.ingredients.length; i++) {
            IrERC20(recipe.ingredients[i])
                .transferFrom(summonerCook, adventurer, summonerCook, recipe.quantities[i]);
        }
        IrERC721(mealAddr).mint(adventurer);
        emit cooked(mealAddr, adventurer);
    }
    function cook(address mealAddr, uint adventurer, uint receiver) external {
        Recipe memory recipe = recipes[mealAddr];

        for (uint256 i = 0; i < recipe.ingredients.length; i++) {
            IrERC20(recipe.ingredients[i])
                .transferFrom(summonerCook, adventurer, summonerCook, recipe.quantities[i]);
        }

        IrERC721(mealAddr).mint(receiver);
        emit cooked(mealAddr, adventurer);
    }

    /**********************************************************************************************
    **  @dev For a specific adventurer, retrieve the list of meals cooked.
    **	@param summonerId: tokenID of the adventurer to check
    **  @return a MealBalance array
    **********************************************************************************************/
    function getTotalMealsBySummoner(uint256 summonerId) public view returns (MealBalance[] memory) {
        MealBalance[] memory totalMeals = new MealBalance[](meals.length);

        for (uint256 i = 0; i < meals.length; i++) {
            uint[] memory _meals = IMeal(meals[i]).getMealsBySummoner(summonerId);
            totalMeals[i] = MealBalance(meals[i], _meals);
        }

        return totalMeals;
    }

    /**********************************************************************************************
    **  @dev Try to retrieve a recipe based on the meal name.
    **	@param name: Name of the meal
    **  @return the recipe of this meal
    **********************************************************************************************/
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

    /**********************************************************************************************
    **  @dev Try to retrieve a meal address based on the meal name.
    **	@param name: Name of the meal
    **  @return the address of the meal contract
    **********************************************************************************************/
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