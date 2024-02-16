--Question1 Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
 SELECT prescription.npi, SUM(prescription.total_claim_count)
 FROM prescription
 GROUP BY prescription.npi
 ORDER BY SUM(prescription.total_claim_count) DESC
 LIMIT 3;
 

 --1a answer: NPI 1881634483, count 99707
 
 --Question1b Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.
 SELECT prescription.npi,
 prescriber.nppes_provider_first_name,
 prescriber.nppes_provider_last_org_name,
 prescriber.specialty_description, 
 SUM(prescription.total_claim_count)
 FROM prescriber
 	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
 GROUP BY prescription.npi, prescriber.nppes_provider_first_name,
 prescriber.nppes_provider_last_org_name,
 prescriber.specialty_description
 ORDER BY SUM(prescription.total_claim_count) DESC
 LIMIT 3;

--1b answer: 1881634483	"BRUCE"	"PENDLEY"	"Family Practice"	99707

--Question2a Which specialty had the most total number of claims (totaled over all drugs)?
SELECT
 prescriber.specialty_description, 
 SUM(prescription.total_claim_count)
 FROM prescriber
 	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
 GROUP BY prescriber.specialty_description
 ORDER BY SUM(prescription.total_claim_count) DESC
 LIMIT 3;
 
 --Question2a answer: 1881634483	"Family Practice"	99707
 
 --Question2b Which specialty had the most total number of claims for opioids?
 SELECT
 prescriber.specialty_description, 
 drug.opioid_drug_flag,
 SUM(prescription.total_claim_count)
 FROM prescriber
 	INNER JOIN prescription
	ON prescriber.npi = prescription.npi
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name WHERE opioid_drug_flag = 'Y'
 GROUP BY prescriber.specialty_description, drug.opioid_drug_flag
 ORDER BY SUM(prescription.total_claim_count) DESC
 LIMIT 3;
 
 --Question2b answer: "Nurse Practitioner"	"Y"	900845

 --Question2c c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
 --Question2d d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?
 
 --Question3a Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name,
 SUM(prescription.total_drug_cost)
 FROM prescription
 	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
GROUP BY drug.generic_name
ORDER BY SUM(prescription.total_drug_cost) DESC;

--Question3a answer "INSULIN GLARGINE,HUM.REC.ANLOG"	104264066.35

--Question3b Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**
SELECT drug.generic_name,
 ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply),2)
 FROM prescription
 	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
GROUP BY drug.generic_name
ORDER BY ROUND(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply),2) DESC;

--Question3b "C1 ESTERASE INHIBITOR"	3495.22

--Question4a For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs
SELECT drug_name,
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' END AS drug_type
FROM drug;

--Question4b Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics
SELECT
	CASE WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' END AS drug_type,
	SUM(MONEY(prescription.total_drug_cost))
FROM drug
	INNER JOIN prescription
	ON drug.drug_name = prescription.drug_name
	GROUP BY drug_type
	ORDER BY SUM(MONEY(prescription.total_drug_cost));

--Question4b answer "opioid"	"$105,080,626.37"

--Question5a How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.
SELECT COUNT (cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN%';

--Question5a answer: 56

--Question5b Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
SELECT SUM(population.population), cbsa.cbsaname
FROM population
	INNER JOIN cbsa
	ON population.fipscounty = cbsa.fipscounty
	GROUP BY cbsa.cbsaname
	ORDER BY SUM(population.population);
--Question5b answer MIN 116352	"Morristown, TN", MAX 1830410	"Nashville-Davidson--Murfreesboro--Franklin, TN"

--Question5c What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT population.population, fips_county.county
FROM population
	LEFT JOIN cbsa
	ON population.fipscounty = cbsa.fipscounty
	LEFT JOIN fips_county
	ON population.fipscounty = fips_county.fipscounty
	WHERE cbsa IS NULL
	ORDER BY population.population DESC;
	
--Question 6a Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name,
	total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--Quesstion6a answer:
--"OXYCODONE HCL"	4538
--"HYDROCODONE-ACETAMINOPHEN"	3376
--"GABAPENTIN"	3531
--"LISINOPRIL"	3655
--"FUROSEMIDE"	3083
--"LEVOTHYROXINE SODIUM"	3023
--"LEVOTHYROXINE SODIUM"	3101
--"LEVOTHYROXINE SODIUM"	3138
--"MIRTAZAPINE"	3085

--Question6b  For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT drug_name, opioid_drug_flag
	total_claim_count
FROM prescription
	INNER JOIN drug
	ON prescription.drug_name = drug.drug_name
	CASE WHEN drug.opioid_drug_flag = 'Y')
WHERE total_claim_count >= 3000;

--Question7a First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y').
SELECT drug.drug_name, prescriber.npi
FROM prescriber
CROSS JOIN drug
WHERE prescriber.specialty_description ilike 'pain management'
	AND prescriber.nppes_provider_city ilike 'nashville'
	AND drug.opioid_drug_flag = 'Y';
	
--Question7a answer ^
	
--Question7b Next, report the number of claims per drug per prescriber
SELECT prescriber.npi,
	drug.drug_name,
	SUM(prescription.total_claim_count)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
	ON drug.drug_name = prescription.drug_name
WHERE prescriber.specialty_description ilike 'pain management'
	AND prescriber.nppes_provider_city ilike 'nashville'
	AND drug.opioid_drug_flag = 'Y'
GROUP BY drug.drug_name,prescriber.npi

--Question7b answer^

--Question7c Finally, if you have not done so already, fill in any missing values for total_claim_count with 0
SELECT prescriber.npi,
	drug.drug_name,
	COALESCE(SUM(prescription.total_claim_count),0)
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
	ON drug.drug_name = prescription.drug_name
WHERE prescriber.specialty_description ilike 'pain management'
	AND prescriber.nppes_provider_city ilike 'nashville'
	AND drug.opioid_drug_flag = 'Y'
GROUP BY drug.drug_name,prescriber.npi

--Question7c ^