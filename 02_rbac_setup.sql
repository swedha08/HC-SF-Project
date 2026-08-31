-- 1. Create a dedicated virtual warehouse (compute engine) for our engineering work
CREATE WAREHOUSE IF NOT EXISTS DE_WH
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60          -- suspend after 60 seconds idle, to save credits
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

-- 2. Create a custom role for data engineering work
CREATE ROLE IF NOT EXISTS DATA_ENGINEER;

-- 3. Grant the role permission to use the warehouse and the database
GRANT USAGE ON WAREHOUSE DE_WH TO ROLE DATA_ENGINEER;
GRANT ALL ON DATABASE HEALTHCARE_DB TO ROLE DATA_ENGINEER;
GRANT ALL ON ALL SCHEMAS IN DATABASE HEALTHCARE_DB TO ROLE DATA_ENGINEER;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE HEALTHCARE_DB TO ROLE DATA_ENGINEER;
GRANT ALL ON ALL TABLES IN SCHEMA HEALTHCARE_DB.RAW TO ROLE DATA_ENGINEER;
GRANT ALL ON FUTURE TABLES IN SCHEMA HEALTHCARE_DB.RAW TO ROLE DATA_ENGINEER;

-- 4. Grant the role to YOUR user (replace with your actual Snowflake username)
GRANT ROLE DATA_ENGINEER TO USER swedha30;

-- 5. Switch to the new role and warehouse, and verify it works
USE ROLE DATA_ENGINEER;
USE WAREHOUSE DE_WH;
USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW;

SELECT COUNT(*) FROM PATIENTS; -- if this works, your role has correct permissions

SELECT CURRENT_USER();