BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_location_profile" (
    "id" bigserial PRIMARY KEY,
    "authUserId" uuid NOT NULL,
    "homeAddress" text NOT NULL,
    "homeLat" double precision NOT NULL,
    "homeLng" double precision NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_location_profile_auth_user_idx" ON "user_location_profile" USING btree ("authUserId");


--
-- MIGRATION VERSION FOR serverpod_aducky
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_aducky', '20260916175103856', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260916175103856', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
