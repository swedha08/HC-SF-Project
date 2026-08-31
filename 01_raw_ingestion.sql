-- 1. File Format: tells Snowflake how to read the CSV
CREATE OR REPLACE FILE FORMAT CSV_FF
  TYPE = 'CSV'
  FIELD_DELIMITER = ','
  SKIP_HEADER = 1
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  NULL_IF = ('', 'NULL', 'null')
  EMPTY_FIELD_AS_NULL = TRUE;

-- 2. Stage: connects Snowflake to your S3 bucket
CREATE OR REPLACE STAGE HEALTHCARE_RAW_STAGE
  URL = 's3://healthcare-raw1/'   -- <-- replace with YOUR actual bucket name
  CREDENTIALS = (AWS_KEY_ID = '<REDACTED>' AWS_SECRET_KEY = '<REDACTED>')
  FILE_FORMAT = CSV_FF;

-- 3. Verify Snowflake can actually see your files
LIST @HEALTHCARE_RAW_STAGE;


USE DATABASE HEALTHCARE_DB;
USE SCHEMA RAW;

-- 1. Create RAW.PATIENTS — everything as VARCHAR on purpose (bronze layer rule: never let a load fail due to bad typing)
CREATE OR REPLACE TABLE RAW.PATIENTS (
    patient_id        VARCHAR,
    first_name        VARCHAR,
    last_name         VARCHAR,
    dob               VARCHAR,
    gender            VARCHAR,
    ssn               VARCHAR,
    phone             VARCHAR,
    email              VARCHAR,
    address            VARCHAR,
    city               VARCHAR,
    state              VARCHAR,
    zip                VARCHAR,
    insurance_provider VARCHAR,
    created_at         VARCHAR,
    updated_at         VARCHAR,
    _file_name         VARCHAR,
    _load_ts           TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 2. Create RAW.ENCOUNTERS
CREATE OR REPLACE TABLE RAW.ENCOUNTERS (
    encounter_id        VARCHAR,
    patient_id          VARCHAR,
    encounter_date       VARCHAR,
    encounter_type       VARCHAR,
    diagnosis_code       VARCHAR,
    department            VARCHAR,
    attending_physician   VARCHAR,
    billed_amount          VARCHAR,
    payment_status         VARCHAR,
    discharge_date          VARCHAR,
    _file_name              VARCHAR,
    _load_ts                TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- 3. Load PATIENTS from its S3 subfolder
COPY INTO RAW.PATIENTS (patient_id, first_name, last_name, dob, gender, ssn, phone, email, address, city, state, zip, insurance_provider, created_at, updated_at, _file_name)
FROM (
    SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15, METADATA$FILENAME
    FROM @HEALTHCARE_RAW_STAGE/patients/dt=2026-08-26/
)
FILE_FORMAT = (FORMAT_NAME = CSV_FF)
ON_ERROR = 'CONTINUE';

-- 4. Load ENCOUNTERS from its S3 subfolder
COPY INTO RAW.ENCOUNTERS (encounter_id, patient_id, encounter_date, encounter_type, diagnosis_code, department, attending_physician, billed_amount, payment_status, discharge_date, _file_name)
FROM (
    SELECT $1,$2,$3,$4,$5,$6,$7,$8,$9,$10, METADATA$FILENAME
    FROM @HEALTHCARE_RAW_STAGE/encounters/dt=2026-08-26/
)
FILE_FORMAT = (FORMAT_NAME = CSV_FF)
ON_ERROR = 'CONTINUE';

-- 5. Sanity check — did the rows actually land?
SELECT COUNT(*) FROM RAW.PATIENTS;
SELECT COUNT(*) FROM RAW.ENCOUNTERS;