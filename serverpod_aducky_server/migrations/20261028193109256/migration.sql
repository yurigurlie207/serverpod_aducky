BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "shared_event" (
    "id" bigserial PRIMARY KEY,
    "shareToken" text NOT NULL,
    "title" text NOT NULL,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone NOT NULL,
    "location" text,
    "startLocation" text,
    "transportMode" text DEFAULT 'driving'::text,
    "travelMinutes" bigint DEFAULT 0,
    "bufferMinutes" bigint DEFAULT 0,
    "leaveByTime" timestamp without time zone NOT NULL,
    "personName" text,
    "createdById" uuid,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "shared_event_token_idx" ON "shared_event" USING btree ("shareToken");


--
-- MIGRATION VERSION FOR serverpod_aducky
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_aducky', '20261028193109256', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261028193109256', "timestamp" = now();

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
