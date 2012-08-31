UPDATE Technologies SET GridX = 4 WHERE Type = 'TECH_COMPASS';
UPDATE Technologies SET GridX = 9 WHERE Type = 'TECH_ARCHAEOLOGY';

UPDATE Technologies SET Cost =    130 WHERE GridX =  1;
UPDATE Technologies SET Cost =    180 WHERE GridX =  2;
UPDATE Technologies SET Cost =    310 WHERE GridX =  3;
UPDATE Technologies SET Cost =    760 WHERE GridX =  4;
UPDATE Technologies SET Cost =   1300 WHERE GridX =  5;
UPDATE Technologies SET Cost =   2100 WHERE GridX =  6;
UPDATE Technologies SET Cost =   3200 WHERE GridX =  7;
UPDATE Technologies SET Cost =   4500 WHERE GridX =  8;
UPDATE Technologies SET Cost =   6600 WHERE GridX =  9;
UPDATE Technologies SET Cost =   8800 WHERE GridX = 10;
UPDATE Technologies SET Cost =  12000 WHERE GridX = 11;
UPDATE Technologies SET Cost =  15000 WHERE GridX = 12;
UPDATE Technologies SET Cost =  19000 WHERE GridX = 13;
UPDATE Technologies SET Cost =  23000 WHERE GridX = 14;
UPDATE Technologies SET Cost =  27000 WHERE GridX = 15;
UPDATE Technologies SET Cost =  31000 WHERE GridX = 16;
UPDATE Technologies SET Cost =  35000 WHERE GridX = 17;

UPDATE Technologies SET GridY = 0
WHERE Type IN (
	'TECH_ECOLOGY'
);

UPDATE Technologies SET GridY = 1
WHERE Type IN (
	'TECH_EDUCATION',
	'TECH_PENICILLIN',
	'TECH_PLASTIC',	
	'TECH_GLOBALIZATION'
);

/*
UPDATE Technologies SET GridY = 2
WHERE Type IN (
);
*/

UPDATE Technologies SET GridY = 3
WHERE Type IN (
	'TECH_BIOLOGY',
	'TECH_ROBOTICS'
);

UPDATE Technologies SET GridY = 4
WHERE Type IN (
	'TECH_ANIMAL_HUSBANDRY',
	'TECH_THE_WHEEL',
	'TECH_HORSEBACK_RIDING',
	'TECH_CHIVALRY',

	'TECH_RADIO',
	'TECH_MASS_MEDIA',
	'TECH_PARTICLE_PHYSICS',
	'TECH_NANOTECHNOLOGY',
	'TECH_FUTURE_TECH'
);

UPDATE Technologies SET GridY = 5
WHERE Type IN (
	'TECH_CURRENCY'
);

UPDATE Technologies SET GridY = 6
WHERE Type IN (
	'TECH_FERTILIZER',
	'TECH_STEAM_POWER',
	'TECH_REPLACEABLE_PARTS',
	'TECH_FLIGHT',
	'TECH_RADAR',
	'TECH_LASERS',
	'TECH_STEALTH',
	'TECH_NUCLEAR_FUSION'
);

UPDATE Technologies SET GridY = 8
WHERE Type IN (
	'TECH_BRONZE_WORKING',
	'TECH_IRON_WORKING',

	'TECH_MILITARY_SCIENCE',	
	'TECH_DYNAMITE',
	'TECH_RAILROAD',
	'TECH_COMBUSTION',
	'TECH_ATOMIC_THEORY',
	'TECH_NUCLEAR_FISSION',
	'TECH_ADVANCED_BALLISTICS'
);

UPDATE Technologies SET GridY = 9
WHERE Type IN (
	'TECH_MASONRY',
	'TECH_CONSTRUCTION'
);