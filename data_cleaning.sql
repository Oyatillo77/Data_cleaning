-- data cleaning

SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data 
-- 3. null VALUES or bank VALUESdatedate;
-- 4. remove any Columns

-- 1. Remove Duplicates

CREATE TABLE layoffs_staging LIKE layoffs;

SELECT* from layoffs_staging;

INSERT INTO layoffs_staging SELECT * FROM layoffs;

SELECT *,ROW_NUMBER() OVER(
    PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) as row_num
FROM layoffs_staging;

WITH duplicate_cte As 
(
    SELECT *,ROW_NUMBER() OVER(
    PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) as row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num>1;


SELECT * FROM layoffs_staging
WHERE company="Casper";


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci

SELECT * FROM layoffs_staging2
WHERE row_num>1;


INSERT into layoffs_staging2
SELECT *,ROW_NUMBER() OVER(
    PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions
) as row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging2
WHERE row_num>1;

SELECT * FROM layoffs_staging2;

-- 2. Standardize the data 
SELECT company, TRIM(company) FROM layoffs_staging2;

UPDATE layoffs_staging2 
SET company=TRIM(company);

SELECT * FROM layoffs_staging2
WHERE industry like 'Crypto%';

UPDATE layoffs_staging2
SET industry="Crypto"
WHERE industry like "Crypto%";

SELECT industry FROM layoffs_staging2 ORDER BY 1;

SELECT DISTINCT country, TRIM(Trailing '.' from country)
FROM layoffs_staging2 
ORDER BY 1;

UPDATE layoffs_staging2 
SET country = TRIM(Trailing '.' from country)
WHERE country like "United State%";

SELECT `date` FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
WHERE `date` LIKE '%/%';

-- change format text to date 
-- Alter tabel layoffs_staning2
-- Set `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'), '%d-%m-%Y');


-- 3. null VALUES or bank VALUESdatedate;

SELECT * from layoffs_staging2
WHERE total_laid_off is NULL
and percentage_laid_off is NULL;

DELETE from layoffs_staging2
WHERE total_laid_off is NULL
and percentage_laid_off is NULL;

SELECT * FROM layoffs_staging2
WHERE industry is NULL
or industry ='';

SELECT * FROM layoffs_staging2
WHERE company='Juul';

UPDATE layoffs_staging2
SET industry=NULL
WHERE industry='';

SELECT t1.industry,t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company=t2.company
    WHERE(t1.industry IS NULL OR t1.industry='')
    AND t2.industry is NOT NULL;


UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company=t2.company
    SET t1.industry=t2.industry
    WHERE t1.industry IS NULL 
    AND t2.industry is NOT NULL;


SELECT * FROM layoffs_staging2 ORDER BY 1;

-- 4. remove any Columns
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



