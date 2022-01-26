import time
from brownie import Cooking, accounts
from ape_safe import ApeSafe

RARITY_MANIFEST = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
RARITY_GOLD = '0x2069B76Afe6b734Fb65D1d099E7ec64ee9CC76B2'
RARITY_EXTENDED_LOOT_MUSHROOM = '0xcd80cE7E28fC9288e20b806ca53683a439041738'
RARITY_EXTENDED_LOOT_BERRIES = '0x9d6C92CCa7d8936ade0976282B82F921F7C50696'
RARITY_EXTENDED_LOOT_MEAT = '0x95174B2c7E08986eE44D65252E3323A782429809'
RARITY_EXTENDED_OP_MS = '0xFaEc40354d9F43A57b58Dc2b5cffe41564D18BB3'

safe = ApeSafe(RARITY_EXTENDED_OP_MS)

# 🏹 - Rarity Extended #########################################################
# This script is used to deploy the Rarity Extended Cooking contract from the
# dev wallet, and then deploy some meals.
#
# Cooking:							0x7474002fe5640d612c9a76cb0b6857932ff891e8
# Meals:
# - Grilled Meat					0x97e8f1061224cb532f808b074786c76e977ba6ee
# - Mushroom soup					0x2e3e1c1f49a288ebf88be66a3ed3539b5971f25d
# - Berries pie						0x57e4cd55289da26aa7cb607c00c5ddcd0f7980a2
# - Mushroom and Meat Skewer		0x65567a2fbc14b4abcd414bb6902384745d4353f6
# - Mushroom and Berries Mix		0xf06ffe67cb96641eec55ea19126bd8f0107ff0ad
# - Berries Wine					0xa0e9159efc4407c4465bbcdf0e7538d6869d81a3
#
# Deployment cost: 5,1380111487 FTM
###############################################################################
def deployWithDev():
	deployer = accounts.load('rarityextended')
	cooking = deployer.deploy(Cooking, RARITY_MANIFEST)
	time.sleep(5)
	Cooking.publish_source(cooking)

	recipes = [
		("Grilled Meat", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MEAT], [10, 10]),
		("Mushroom soup", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MUSHROOM], [10, 10]),
		("Berries pie", [RARITY_GOLD, RARITY_EXTENDED_LOOT_BERRIES], [10, 10]),
		("Mushroom and Meat Skewer", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MEAT, RARITY_EXTENDED_LOOT_MUSHROOM], [10, 10, 10]),
		("Mushroom and Berries Mix", [RARITY_GOLD, RARITY_EXTENDED_LOOT_MUSHROOM, RARITY_EXTENDED_LOOT_BERRIES], [10, 10, 10]),
		("Berries Wine", [RARITY_GOLD, RARITY_EXTENDED_LOOT_BERRIES], [50, 100]),
	]

	for (name, ingredients, quantities) in recipes:
		cooking.createNewRecipe(
			name,
			name + ' - (Meal)',
			'',
			ingredients,
			quantities,
			{"from": deployer}
		)
		time.sleep(5)

def main():
	deployWithDev()
