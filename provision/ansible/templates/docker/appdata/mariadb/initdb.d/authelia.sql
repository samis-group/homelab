-- Authelia setup:
-- Default db name = `authelia`
CREATE DATABASE IF NOT EXISTS {{ authelia.database.name }};
-- Default db user = `authelia`
CREATE USER IF NOT EXISTS '{{ authelia.database.username }}'@'%' IDENTIFIED BY '{{ authelia.database.password }}';
GRANT ALL PRIVILEGES ON *.* TO '{{ authelia.database.username }}'@'%';
FLUSH PRIVILEGES;
-- The home assistant/authelia users must have grants on the home assistant/authelia db's with host set to '%'. Use this command to find out:
SELECT User, Host, Password FROM mysql.user;
