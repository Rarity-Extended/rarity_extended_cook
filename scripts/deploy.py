import time
from brownie import Cooking, Meal, Contract, accounts, convert
from ape_safe import ApeSafe

CONTRACT_NAME = 'Rarity Extended Cooking'
RARITY_EXTENDED_OP_MS = '0xFaEc40354d9F43A57b58Dc2b5cffe41564D18BB3'
RARITY_EXTENDED_PROXY_DEPLOYER = '0x253aaEAFDA7AE3C6Ed3E3E2732C49cf077a22Ae0'
RARITY_MANIFEST = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'

RARITY_GOLD = '0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2'
RARITY_EXTENDED_LOOT_MUSHROOM = '0xcd80cE7E28fC9288e20b806ca53683a439041738'
RARITY_EXTENDED_LOOT_BERRIES = '0x9d6C92CCa7d8936ade0976282B82F921F7C50696'
RARITY_EXTENDED_LOOT_MEAT = '0x95174B2c7E08986eE44D65252E3323A782429809'

safe = ApeSafe(RARITY_EXTENDED_OP_MS)

# 🏹 - Rarity Extended #########################################################
# This script is used to deploy the Rarity Extended Cooking contract from the
# Rarity Extended Deployer, and set Extended as the operational multisig
# address.
#
# Multisig address is 0xFaEc40354d9F43A57b58Dc2b5cffe41564D18BB3.
# Deployer address is 0x253aaEAFDA7AE3C6Ed3E3E2732C49cf077a22Ae0
###############################################################################
def deployWithDev():
	# Use dev deployer account to deploy the contract, load it and setExtended to the Safe
	deployer = accounts.load('rarityextended')
	# cooking = deployer.deploy(Cooking, RARITY_MANIFEST)
	cooking = Contract.from_explorer("0xf6157fb663768ca6147f89f7495a8ab895bc4c4b")
	# cooking.setExtended(safe.account)

	# Cooking.publish_source(cooking)

	meal = Contract.from_abi('meal', "0xef28f159b3811d4AE7CAf5A55286265C053a33B6", Meal.abi)
	Meal.publish_source(meal)
	meal = Contract.from_abi('meal', "0x8cf1200204e81b8f1e610a2bfeeddf75e0d7bef0", Meal.abi)
	Meal.publish_source(meal)


	recipes = [
		# ("Grilled Meat", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MEAT], [10, 10]),
		# ("Mushroom soup", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MUSHROOM], [10, 10]),
		("Berries pie", [RARITY_GOLD, RARITY_EXTENDED_LOOT_BERRIES], [10, 10]),
		# ("Mushroom and Meat Skewer", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MEAT, RARITY_EXTENDED_LOOT_MUSHROOM], [10, 10, 10]),
		# ("Mushroom and Berries Mix", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MUSHROOM, RARITY_EXTENDED_LOOT_BERRIES], [10, 10, 10]),
		# ("Berries Wine", [RARITY_GOLD, RARITY_EXTENDED_LOOT_BERRIES], [50, 100]),
	]

	for (name, ingredients, quantities) in recipes:
		tx = cooking.createNewRecipe(
			name,
			name + ' - (Meal)',
			'',
			ingredients,
			quantities,
			{"from": deployer}
		)
		deployedMeal = tx.events['createdNewRecipe'][0]['addr'];
		Contract.from_abi(name, deployedMeal, Meal.abi)
		time.sleep(5)
		Meal.publish_source(deployedMeal)
		

	# # Send transaction to mutlisig
	# safe_tx = safe.multisend_from_receipts()
	# safe.preview(safe_tx)
	# safe.post_transaction(safe_tx)


def main():
	deployWithDev()
	# addRecipes(safe_cook)


# {'RoleGranted': [OrderedDict([('role', 0x0000000000000000000000000000000000000000000000000000000000000000), ('account', '0xF6157FB663768ca6147F89F7495A8ab895BC4C4b'),('sender', '0xF6157FB663768ca6147F89F7495A8ab895BC4C4b')]), OrderedDict([('role', 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6), ('account', '0xF6157FB663768ca6147F89F7495A8ab895BC4C4b'), ('sender', '0xF6157FB663768ca6147F89F7495A8ab895BC4C4b')])], 'createdNewRecipe': [OrderedDict([('addr', '0xef28f159b3811d4AE7CAf5A55286265C053a33B6'), ('name', 'Mushroom soup'), ('symbol', 'Mushroom soup - (Meal)'), ('effect', ''), ('ingredients', ('0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2', '0xcd80cE7E28fC9288e20b806ca53683a439041738')), ('quantities', (10, 10))])]}