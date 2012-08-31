-- Production
UPDATE Units
SET Cost = ROUND((Cost * 1.4) / 10) * 10
WHERE Cost > 0;

UPDATE Buildings
SET Cost = ROUND((Cost * 1.4) / 10) * 10
WHERE Cost > 0;

UPDATE Projects
SET Cost = ROUND((Cost * 1.4) / 10) * 10
WHERE Cost > 0;

UPDATE Buildings
SET Cost = 100, NumCityCostMod = 25
WHERE NumCityCostMod > 0;

/*
UPDATE Buildings
SET NumCityCostMod = ROUND((NumCityCostMod * 1.1) / 10) * 10
WHERE NumCityCostMod > 0;
*/

UPDATE Units SET Cost =  50, HurryCostModifier =  10 WHERE Class = 'UNITCLASS_MESSENGER';
UPDATE Units SET Cost =  75, HurryCostModifier =   0 WHERE Class = 'UNITCLASS_ENVOY';
UPDATE Units SET Cost = 100, HurryCostModifier = -10 WHERE Class = 'UNITCLASS_EMISSARY';
UPDATE Units SET Cost = 150, HurryCostModifier = -20 WHERE Class = 'UNITCLASS_DIPLOMAT';
UPDATE Units SET Cost = 200, HurryCostModifier = -30 WHERE Class = 'UNITCLASS_AMBASSADOR';