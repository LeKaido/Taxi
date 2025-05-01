--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: taxi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA taxi;


ALTER SCHEMA taxi OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: samplerides; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.samplerides (
    tripid character varying(255),
    taxiid character varying(255),
    tripstart timestamp without time zone,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.samplerides OWNER TO postgres;

--
-- Name: seq_shiftmodelid; Type: SEQUENCE; Schema: taxi; Owner: postgres
--

CREATE SEQUENCE taxi.seq_shiftmodelid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 10000;


ALTER SEQUENCE taxi.seq_shiftmodelid OWNER TO postgres;

--
-- Name: taxifileload; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxifileload (
    fileid bigint NOT NULL,
    filename character varying(1000) NOT NULL,
    filesize bigint NOT NULL,
    filetime timestamp without time zone NOT NULL,
    loadstart timestamp without time zone NOT NULL,
    loadend timestamp without time zone,
    rowsread bigint
);


ALTER TABLE taxi.taxifileload OWNER TO postgres;

--
-- Name: seq_taxifileload; Type: SEQUENCE; Schema: taxi; Owner: postgres
--

CREATE SEQUENCE taxi.seq_taxifileload
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE taxi.seq_taxifileload OWNER TO postgres;

--
-- Name: seq_taxifileload; Type: SEQUENCE OWNED BY; Schema: taxi; Owner: postgres
--

ALTER SEQUENCE taxi.seq_taxifileload OWNED BY taxi.taxifileload.fileid;


--
-- Name: shiftmodel; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.shiftmodel (
    shiftmodelid bigint DEFAULT nextval('taxi.seq_shiftmodelid'::regclass) NOT NULL,
    taxiid character varying(255),
    shiftstart timestamp without time zone,
    shiftend timestamp without time zone,
    shiftminutes numeric,
    ridecount bigint,
    sum_tripseconds bigint,
    sum_tripmiles numeric,
    sum_fare numeric,
    sum_tips numeric,
    sum_tolls numeric,
    sum_extracharges numeric,
    sum_triptotal numeric,
    max_rec_updated timestamp without time zone
);


ALTER TABLE taxi.shiftmodel OWNER TO postgres;

--
-- Name: taxirides; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
)
PARTITION BY RANGE (tripstart);


ALTER TABLE taxi.taxirides OWNER TO postgres;

--
-- Name: taxirides_2024_01; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_01 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_01 OWNER TO postgres;

--
-- Name: taxirides_2024_02; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_02 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_02 OWNER TO postgres;

--
-- Name: taxirides_2024_03; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_03 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_03 OWNER TO postgres;

--
-- Name: taxirides_2024_04; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_04 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_04 OWNER TO postgres;

--
-- Name: taxirides_2024_05; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_05 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_05 OWNER TO postgres;

--
-- Name: taxirides_2024_06; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_06 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_06 OWNER TO postgres;

--
-- Name: taxirides_2024_07; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_07 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_07 OWNER TO postgres;

--
-- Name: taxirides_2024_08; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_08 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_08 OWNER TO postgres;

--
-- Name: taxirides_2024_09; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_09 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_09 OWNER TO postgres;

--
-- Name: taxirides_2024_10; Type: TABLE; Schema: taxi; Owner: postgres
--

CREATE TABLE taxi.taxirides_2024_10 (
    tripid character varying(255) NOT NULL,
    taxiid character varying(255),
    tripstart timestamp without time zone NOT NULL,
    tripend timestamp without time zone,
    tripseconds integer,
    tripmiles numeric(10,2),
    pickupcensus character varying(255),
    dropoffcensus character varying(255),
    pickupcomarea character varying(255),
    dropoffcomarea character varying(255),
    fare numeric(10,2),
    tips numeric(10,2),
    tolls numeric(10,2),
    extracharges numeric(10,2),
    triptotal numeric(10,2),
    paymenttype character varying(255),
    taxicompany character varying(255),
    pickupcentroidlatitude character varying(255),
    pickupcentroidlongitude character varying(255),
    pickupcentroidlocation character varying(255),
    dropoffcentroidlatitude character varying(255),
    dropoffcentroidlongitude character varying(255),
    dropoffcentroidlocation character varying(255),
    rec_updated timestamp without time zone
);


ALTER TABLE taxi.taxirides_2024_10 OWNER TO postgres;

--
-- Name: taxirides_2024_01; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_01 FOR VALUES FROM ('2024-01-01 00:00:00') TO ('2024-01-07 00:00:00');


--
-- Name: taxirides_2024_02; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_02 FOR VALUES FROM ('2024-01-07 00:00:00') TO ('2024-01-14 00:00:00');


--
-- Name: taxirides_2024_03; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_03 FOR VALUES FROM ('2024-01-14 00:00:00') TO ('2024-01-21 00:00:00');


--
-- Name: taxirides_2024_04; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_04 FOR VALUES FROM ('2024-01-21 00:00:00') TO ('2024-01-28 00:00:00');


--
-- Name: taxirides_2024_05; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_05 FOR VALUES FROM ('2024-01-28 00:00:00') TO ('2024-02-04 00:00:00');


--
-- Name: taxirides_2024_06; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_06 FOR VALUES FROM ('2024-02-04 00:00:00') TO ('2024-02-11 00:00:00');


--
-- Name: taxirides_2024_07; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_07 FOR VALUES FROM ('2024-02-11 00:00:00') TO ('2024-02-18 00:00:00');


--
-- Name: taxirides_2024_08; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_08 FOR VALUES FROM ('2024-02-18 00:00:00') TO ('2024-02-25 00:00:00');


--
-- Name: taxirides_2024_09; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_09 FOR VALUES FROM ('2024-02-25 00:00:00') TO ('2024-03-03 00:00:00');


--
-- Name: taxirides_2024_10; Type: TABLE ATTACH; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides ATTACH PARTITION taxi.taxirides_2024_10 FOR VALUES FROM ('2024-03-03 00:00:00') TO ('2024-03-10 00:00:00');


--
-- Name: taxifileload fileid; Type: DEFAULT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxifileload ALTER COLUMN fileid SET DEFAULT nextval('taxi.seq_taxifileload'::regclass);


--
-- Name: shiftmodel shifmodel_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.shiftmodel
    ADD CONSTRAINT shifmodel_pkey PRIMARY KEY (shiftmodelid);


--
-- Name: taxifileload taxifileload_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxifileload
    ADD CONSTRAINT taxifileload_pkey PRIMARY KEY (fileid);


--
-- Name: taxirides taxirides_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides
    ADD CONSTRAINT taxirides_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_01 taxirides_2024_01_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_01
    ADD CONSTRAINT taxirides_2024_01_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_02 taxirides_2024_02_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_02
    ADD CONSTRAINT taxirides_2024_02_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_03 taxirides_2024_03_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_03
    ADD CONSTRAINT taxirides_2024_03_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_04 taxirides_2024_04_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_04
    ADD CONSTRAINT taxirides_2024_04_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_05 taxirides_2024_05_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_05
    ADD CONSTRAINT taxirides_2024_05_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_06 taxirides_2024_06_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_06
    ADD CONSTRAINT taxirides_2024_06_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_07 taxirides_2024_07_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_07
    ADD CONSTRAINT taxirides_2024_07_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_08 taxirides_2024_08_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_08
    ADD CONSTRAINT taxirides_2024_08_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_09 taxirides_2024_09_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_09
    ADD CONSTRAINT taxirides_2024_09_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: taxirides_2024_10 taxirides_2024_10_pkey; Type: CONSTRAINT; Schema: taxi; Owner: postgres
--

ALTER TABLE ONLY taxi.taxirides_2024_10
    ADD CONSTRAINT taxirides_2024_10_pkey PRIMARY KEY (tripid, tripstart);


--
-- Name: I_FileName; Type: INDEX; Schema: taxi; Owner: postgres
--

CREATE INDEX "I_FileName" ON taxi.taxifileload USING btree (filename) WITH (deduplicate_items='true');


--
-- Name: taxirides_2024_01_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_01_pkey;


--
-- Name: taxirides_2024_02_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_02_pkey;


--
-- Name: taxirides_2024_03_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_03_pkey;


--
-- Name: taxirides_2024_04_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_04_pkey;


--
-- Name: taxirides_2024_05_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_05_pkey;


--
-- Name: taxirides_2024_06_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_06_pkey;


--
-- Name: taxirides_2024_07_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_07_pkey;


--
-- Name: taxirides_2024_08_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_08_pkey;


--
-- Name: taxirides_2024_09_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_09_pkey;


--
-- Name: taxirides_2024_10_pkey; Type: INDEX ATTACH; Schema: taxi; Owner: postgres
--

ALTER INDEX taxi.taxirides_pkey ATTACH PARTITION taxi.taxirides_2024_10_pkey;


--
-- PostgreSQL database dump complete
--

