/*
Summary

1- Set up a Snowflake warehouse for running queries.

2- Create databases and schemas to organize data.

3- Configures integration with a GitHub repository to automate pulling data (like JSON files) from GitHub.

Sets up a file format and stage to handle the data coming from GitHub.

Copies a file (airport_list.json) from the GitHub repository into the Snowflake stage (bronze.raw).

Sets up notifications via email (likely for monitoring pipeline completions).

*/

USE ROLE ACCOUNTADMIN;

CREATE OR ALTER WAREHOUSE QUICKSTART_WH 
  WAREHOUSE_SIZE = XSMALL 
  AUTO_SUSPEND = 300 
  AUTO_RESUME= TRUE;


-- Separate database for git repository
CREATE OR ALTER DATABASE QUICKSTART_COMMON;


-- API integration is needed for GitHub integration
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/rahele-al') -- INSERT YOUR GITHUB USERNAME HERE
  ENABLED = TRUE;


-- Git repository object is similar to external stage
CREATE OR REPLACE GIT REPOSITORY quickstart_common.public.quickstart_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/rahele-al/sfguide-getting-started-with-snowflake-devops'; -- INSERT URL OF FORKED REPO HERE


CREATE OR ALTER DATABASE QUICKSTART_PROD;


-- To monitor data pipeline's completion
CREATE OR REPLACE NOTIFICATION INTEGRATION email_integration
  TYPE=EMAIL
  ENABLED=TRUE;


-- Database level objects
CREATE OR ALTER SCHEMA bronze;
CREATE OR ALTER SCHEMA silver;
CREATE OR ALTER SCHEMA gold;


-- Schema level objects
CREATE OR REPLACE FILE FORMAT bronze.json_format TYPE = 'json';
CREATE OR ALTER STAGE bronze.raw;


-- Copy file from GitHub to internal stage
copy files into @bronze.raw from @quickstart_common.public.quickstart_repo/branches/main/data/airport_list.json;
