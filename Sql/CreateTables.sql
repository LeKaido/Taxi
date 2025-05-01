-- DROP TABLE IF EXISTS Taxi.TaxiRides;

CREATE TABLE Taxi.TaxiRides (
    TripId VARCHAR(255),
    TaxiId VARCHAR(255),
    TripStart TIMESTAMP,
    TripEnd TIMESTAMP,
    TripSeconds INT,
    TripMiles DECIMAL(10, 2),
    PickupCensus VARCHAR(255),
    DropOffCensus VARCHAR(255),
    PickupComArea VARCHAR(255),
    DropOffComArea VARCHAR(255),
    Fare DECIMAL(10, 2),
    Tips DECIMAL(10, 2),
    Tolls DECIMAL(10, 2),
    ExtraCharges DECIMAL(10, 2),
    TripTotal DECIMAL(10, 2),
    PaymentType VARCHAR(255),
    TaxiCompany VARCHAR(255),
    PickupCentroidLatitude VARCHAR(255),
    PickupCentroidLongitude VARCHAR(255),
    PickupCentroidLocation VARCHAR(255),
    DropOffCentroidLatitude VARCHAR(255),
    DropOffCentroidLongitude VARCHAR(255),
    DropOffCentroidLocation VARCHAR(255),
    PRIMARY KEY (TripId, TripStart)
) PARTITION BY RANGE (TripStart)
;

CREATE TABLE Taxi.TaxiRides_2024_01 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-01-01') TO ('2024-01-07');

CREATE TABLE Taxi.TaxiRides_2024_02 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-01-07') TO ('2024-01-14');

CREATE TABLE Taxi.TaxiRides_2024_03 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-01-14') TO ('2024-01-21');

CREATE TABLE Taxi.TaxiRides_2024_04 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-01-21') TO ('2024-01-28');

CREATE TABLE Taxi.TaxiRides_2024_05 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-01-28') TO ('2024-02-04');

CREATE TABLE Taxi.TaxiRides_2024_06 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-02-04') TO ('2024-02-11');

CREATE TABLE Taxi.TaxiRides_2024_07 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-02-11') TO ('2024-02-18');

CREATE TABLE Taxi.TaxiRides_2024_08 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-02-18') TO ('2024-02-25');

CREATE TABLE Taxi.TaxiRides_2024_09 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-02-25') TO ('2024-03-03');

CREATE TABLE Taxi.TaxiRides_2024_10 PARTITION OF Taxi.TaxiRides
FOR VALUES FROM ('2024-03-03') TO ('2024-03-10');

-- SEQUENCE: taxi.seq_taxifileload

-- DROP SEQUENCE IF EXISTS taxi.seq_taxifileload;

CREATE SEQUENCE IF NOT EXISTS taxi.seq_taxifileload
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

ALTER SEQUENCE taxi.seq_taxifileload
    OWNED BY taxi.taxifileload.fileid;

ALTER SEQUENCE taxi.seq_taxifileload
    OWNER TO postgres;


-- Table: taxi.taxifileload

-- DROP TABLE IF EXISTS taxi.taxifileload;

CREATE TABLE IF NOT EXISTS taxi.taxifileload
(
    fileid bigint NOT NULL DEFAULT nextval('taxi.seq_taxifileload'::regclass),
    filename character varying(1000) COLLATE pg_catalog."default" NOT NULL,
    filesize bigint NOT NULL,
    filetime timestamp without time zone NOT NULL,
    loadstart timestamp without time zone NOT NULL,
    loadend timestamp without time zone,
    rowsread bigint,
    CONSTRAINT taxifileload_pkey PRIMARY KEY (fileid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS taxi.taxifileload
    OWNER to postgres;
-- Index: I_FileName

-- DROP INDEX IF EXISTS taxi."I_FileName";

CREATE INDEX IF NOT EXISTS "I_FileName"
    ON taxi.taxifileload USING btree
    (filename COLLATE pg_catalog."default" ASC NULLS LAST)
    WITH (deduplicate_items=True)
    TABLESPACE pg_default;