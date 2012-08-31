-- Insert SQL Rules Here

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_CAMARADERIE'
FROM Units WHERE CombatClass IN (
	'UNITCOMBAT_RECON'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_DEFENSE_1'
FROM Units WHERE Class IN (
	'UNITCLASS_SPEARMAN',
	'UNITCLASS_PIKEMAN',
	'UNITCLASS_ANTI_TANK_GUN'
) OR CombatClass IN (
	'UNITCOMBAT_RECON'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_SMALL_CITY_PENALTY'
FROM Units WHERE Class IN (
	'UNITCLASS_TRIREME',
	'UNITCLASS_CARAVEL',
	'UNITCLASS_FRIGATE',
	'UNITCLASS_DESTROYER'
);

INSERT INTO Unit_FreePromotions (UnitType, PromotionType)
SELECT DISTINCT Type, 'PROMOTION_NAVAL_DEMOLISH'
FROM Units WHERE Class IN (
	'UNITCLASS_SHIP_OF_THE_LINE',
	'UNITCLASS_IRONCLAD',
	'UNITCLASS_BATTLESHIP',
	'UNITCLASS_MISSILE_CRUISER'
);

/*
UPDATE Units
SET Range = 1
WHERE Class IN (
	'UNITCLASS_TRIREME',
	'UNITCLASS_CARAVEL',
	'UNITCLASS_FRIGATE'
);
*/


UPDATE Units
SET ExtraMaintenanceCost = 3
WHERE Cost > 0 AND (Combat = 0 AND RangedCombat = 0);

UPDATE Units
SET ExtraMaintenanceCost = 1 + Cost / 50.0 + MAX(Combat, RangedCombat) / 5.0
WHERE Cost > 0 AND (Combat > 0 OR RangedCombat > 0);

UPDATE Units
SET ExtraMaintenanceCost = 1.5 * ExtraMaintenanceCost
WHERE Type IN (
	SELECT UnitType FROM Civilization_UnitClassOverrides
	WHERE CivilizationType = 'CIVILIZATION_BARBARIAN'
);

UPDATE Units
SET ExtraMaintenanceCost = 0.75 * ExtraMaintenanceCost
WHERE ExtraMaintenanceCost > 0 AND (
	CombatClass = 'UNITCOMBAT_RECON'
	OR Domain = 'DOMAIN_SEA'
	OR Domain = 'DOMAIN_AIR'
);

UPDATE Units
SET ExtraMaintenanceCost = MAX(ExtraMaintenanceCost, 1)
WHERE ExtraMaintenanceCost <> 0;

UPDATE Units
SET ExtraMaintenanceCost = ROUND(ExtraMaintenanceCost, 0)
WHERE ExtraMaintenanceCost > 0;

UPDATE Units SET ExtraMaintenanceCost = 0 WHERE NoMaintenance = 1;

UPDATE Units SET ExtraMaintenanceCost = 30 WHERE Class = 'UNITCLASS_ATOMIC_BOMB';
UPDATE Units SET ExtraMaintenanceCost = 60 WHERE Class = 'UNITCLASS_NUCLEAR_MISSILE';
UPDATE Units SET ExtraMaintenanceCost = 10 WHERE Class = 'UNITCLASS_GUIDED_MISSILE';