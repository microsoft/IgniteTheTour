--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.10
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_buffercache; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_buffercache WITH SCHEMA public;


--
-- Name: EXTENSION pg_buffercache; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_buffercache IS 'examine the shared buffer cache';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Inventory; Type: TABLE; Schema: public; Owner: tuser
--

CREATE TABLE public."Inventory" (
    "Sku" text NOT NULL,
    "Quantity" integer NOT NULL,
    "Modified" timestamp without time zone DEFAULT '0001-01-01 00:00:00'::timestamp without time zone NOT NULL
);


ALTER TABLE public."Inventory" OWNER TO tuser;

--
-- Name: SecretUsers; Type: TABLE; Schema: public; Owner: tuser
--

CREATE TABLE public."SecretUsers" (
    "Username" text NOT NULL,
    "Password" text
);


ALTER TABLE public."SecretUsers" OWNER TO tuser;

--
-- Name: __EFMigrationsHistory; Type: TABLE; Schema: public; Owner: tuser
--

CREATE TABLE public."__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL
);


ALTER TABLE public."__EFMigrationsHistory" OWNER TO tuser;

--
-- Data for Name: Inventory; Type: TABLE DATA; Schema: public; Owner: tuser
--

COPY public."Inventory" ("Sku", "Quantity", "Modified") FROM stdin;
2	51	2018-11-05 13:12:28.592525
3	4	2018-11-05 13:12:28.848784
4	74	2018-11-05 13:12:28.902889
5	2	2018-11-05 13:12:28.95587
6	93	2018-11-05 13:12:29.008965
7	73	2018-11-05 13:12:29.061963
8	48	2018-11-05 13:12:29.115001
9	99	2018-11-05 13:12:29.169121
10	62	2018-11-05 13:12:29.222607
\.


--
-- Data for Name: SecretUsers; Type: TABLE DATA; Schema: public; Owner: tuser
--

COPY public."SecretUsers" ("Username", "Password") FROM stdin;
administrator	MySuperSecr3tPassword!
\.


--
-- Data for Name: __EFMigrationsHistory; Type: TABLE DATA; Schema: public; Owner: tuser
--

COPY public."__EFMigrationsHistory" ("MigrationId", "ProductVersion") FROM stdin;
20181023230148_InitialCreate	2.1.1-rtm-30846
20181101063039_AddSecretUsers	2.1.1-rtm-30846
20181102180834_AddModifiedColumn	2.1.1-rtm-30846
\.


--
-- Name: Inventory PK_Inventory; Type: CONSTRAINT; Schema: public; Owner: tuser
--

ALTER TABLE ONLY public."Inventory"
    ADD CONSTRAINT "PK_Inventory" PRIMARY KEY ("Sku");


--
-- Name: SecretUsers PK_SecretUsers; Type: CONSTRAINT; Schema: public; Owner: tuser
--

ALTER TABLE ONLY public."SecretUsers"
    ADD CONSTRAINT "PK_SecretUsers" PRIMARY KEY ("Username");


--
-- Name: __EFMigrationsHistory PK___EFMigrationsHistory; Type: CONSTRAINT; Schema: public; Owner: tuser
--

ALTER TABLE ONLY public."__EFMigrationsHistory"
    ADD CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId");


--
-- PostgreSQL database dump complete
--

