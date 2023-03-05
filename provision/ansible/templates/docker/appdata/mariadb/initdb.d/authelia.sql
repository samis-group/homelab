-- Authelia setup:
-- Default db name = `authelia`
CREATE DATABASE IF NOT EXISTS {{ authelia_database_name }};
-- Default db user = `authelia`
CREATE USER IF NOT EXISTS '{{ authelia_database_username }}'@'%' IDENTIFIED BY '{{ authelia_database_password }}';
GRANT ALL PRIVILEGES ON *.* TO '{{ authelia_database_username }}'@'%';
FLUSH PRIVILEGES;
-- The home assistant/authelia users must have grants on the home assistant/authelia db's with host set to '%'. Use this command to find out:
SELECT User, Host, Password FROM mysql.user;
