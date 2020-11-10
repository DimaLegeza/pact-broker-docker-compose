-- These calls should be directly derived from the bootstrap instructions in the relevant modules
-- See also PRP-8540
CREATE USER picnic_wms WITH PASSWORD 'password';
CREATE USER keycloak WITH PASSWORD 'password';
CREATE USER keycloak_ping WITH PASSWORD 'password';
CREATE USER region_service WITH PASSWORD 'password';
CREATE USER list_service WITH PASSWORD 'password';
CREATE USER pam_user WITH PASSWORD 'password';
CREATE USER pact_broker_user WITH PASSWORD 'password';

CREATE DATABASE picnic_wms WITH OWNER picnic_wms;
CREATE DATABASE keycloak WITH OWNER keycloak;
CREATE DATABASE keycloak_ping WITH OWNER keycloak_ping;
CREATE DATABASE region_service WITH OWNER region_service;
CREATE DATABASE pact_broker WITH OWNER pact_broker_user;
CREATE DATABASE reservation_service;
CREATE DATABASE pam;

-- Initial Reservation Service Configuration
CREATE ROLE reservation_service_admin_role
    INHERIT;
GRANT ALL PRIVILEGES ON DATABASE reservation_service TO reservation_service_admin_role WITH GRANT OPTION;
CREATE ROLE reservation_service_user_role
    INHERIT;
GRANT ALL PRIVILEGES ON DATABASE reservation_service TO reservation_service_admin_role WITH GRANT OPTION;
CREATE USER reservation_service_admin
    IN ROLE reservation_service_admin_role;
CREATE USER reservation_service_user
    IN ROLE reservation_service_user_role;
ALTER USER reservation_service_admin WITH PASSWORD 'password';

-- Additional WMS Service Configuration
\connect picnic_wms;
CREATE SCHEMA lists;
ALTER SCHEMA lists OWNER TO picnic_wms;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO list_service;
ALTER DEFAULT PRIVILEGES FOR ROLE picnic_wms IN SCHEMA public GRANT SELECT ON TABLES TO list_service;

SET ROLE list_service;
ALTER ROLE list_service SET search_path = lists,public;

-- Create schemas for the reservation service
\connect reservation_service;
SET ROLE reservation_service_admin_role;

CREATE SCHEMA IF NOT EXISTS reservation_service;

-- PAM Schemas
\connect pam;
CREATE SCHEMA IF NOT EXISTS ml_app;

CREATE TABLE IF NOT EXISTS ml_app.model_reference (
  model_name VARCHAR,
  create_ts  TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX IF NOT EXISTS default_ts
  ON ml_app.model_reference (create_ts DESC);

-- Grant usage on the correct user.
GRANT USAGE ON SCHEMA ml_app TO pam_user;
GRANT ALL ON TABLE ml_app.model_reference TO pam_user;
