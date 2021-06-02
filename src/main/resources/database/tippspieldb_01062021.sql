--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.22
-- Dumped by pg_dump version 9.6.22

-- Started on 2021-06-01 21:43:05

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 1 (class 3079 OID 12387)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2328 (class 0 OID 0)
-- Dependencies: 1
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 185 (class 1259 OID 16577)
-- Name: Bet; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Bet" (
    "betId" integer NOT NULL,
    "userId" integer NOT NULL,
    betkind character varying(20) NOT NULL,
    "matchId" integer,
    "scoreHome" integer,
    "scoreGuest" integer,
    "teamId" integer,
    "bracketId" integer
);


ALTER TABLE public."Bet" OWNER TO tippspiel;

--
-- TOC entry 186 (class 1259 OID 16580)
-- Name: Bet_betId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Bet_betId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Bet_betId_seq" OWNER TO tippspiel;

--
-- TOC entry 2329 (class 0 OID 0)
-- Dependencies: 186
-- Name: Bet_betId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Bet_betId_seq" OWNED BY public."Bet"."betId";


--
-- TOC entry 187 (class 1259 OID 16582)
-- Name: Betgroup; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Betgroup" (
    "betgroupId" integer NOT NULL,
    betgroupname character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Betgroup" OWNER TO tippspiel;

--
-- TOC entry 188 (class 1259 OID 16586)
-- Name: Betgroup_betgroupId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Betgroup_betgroupId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Betgroup_betgroupId_seq" OWNER TO tippspiel;

--
-- TOC entry 2330 (class 0 OID 0)
-- Dependencies: 188
-- Name: Betgroup_betgroupId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Betgroup_betgroupId_seq" OWNED BY public."Betgroup"."betgroupId";


--
-- TOC entry 189 (class 1259 OID 16588)
-- Name: Bracket; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Bracket" (
    "bracketId" integer NOT NULL,
    bracketname character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying,
    "phaseId" integer NOT NULL
);


ALTER TABLE public."Bracket" OWNER TO tippspiel;

--
-- TOC entry 190 (class 1259 OID 16592)
-- Name: BracketTeam; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."BracketTeam" (
    "bracketTeamId" integer NOT NULL,
    "bracketId" integer NOT NULL,
    "teamId" integer NOT NULL
);


ALTER TABLE public."BracketTeam" OWNER TO tippspiel;

--
-- TOC entry 191 (class 1259 OID 16595)
-- Name: SoccerMatch; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."SoccerMatch" (
    "matchId" integer NOT NULL,
    "phaseId" integer NOT NULL,
    datetime timestamp without time zone NOT NULL,
    "teamIdHome" integer NOT NULL,
    "teamIdGuest" integer NOT NULL,
    "scoreHome" integer,
    "scoreGuest" integer,
    isfinals boolean DEFAULT false NOT NULL
);


ALTER TABLE public."SoccerMatch" OWNER TO tippspiel;

--
-- TOC entry 192 (class 1259 OID 16599)
-- Name: Team; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Team" (
    "teamId" integer NOT NULL,
    teamname character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Team" OWNER TO tippspiel;

--
-- TOC entry 193 (class 1259 OID 16603)
-- Name: BracketStanding_Sub1; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketStanding_Sub1" AS
 SELECT t1."bracketId",
    t1.description AS "bracketDescription",
    t3."teamId",
    t3.description AS "teamDescription",
        CASE
            WHEN ((t4."scoreHome" IS NULL) OR (t4."scoreGuest" IS NULL)) THEN 0
            ELSE 1
        END AS matchdone,
        CASE
            WHEN ((t4."scoreHome" IS NOT NULL) AND (t4."scoreGuest" IS NOT NULL)) THEN
            CASE
                WHEN (t3."teamId" = t4."teamIdHome") THEN (t4."scoreHome" - t4."scoreGuest")
                ELSE (t4."scoreGuest" - t4."scoreHome")
            END
            ELSE 0
        END AS scorediff,
        CASE
            WHEN ((t4."scoreHome" IS NOT NULL) AND (t4."scoreGuest" IS NOT NULL)) THEN
            CASE
                WHEN (t3."teamId" = t4."teamIdHome") THEN t4."scoreHome"
                ELSE t4."scoreGuest"
            END
            ELSE 0
        END AS goalsshot,
        CASE
            WHEN ((t4."scoreHome" IS NOT NULL) AND (t4."scoreGuest" IS NOT NULL)) THEN
            CASE
                WHEN (t3."teamId" = t4."teamIdHome") THEN t4."scoreGuest"
                ELSE t4."scoreHome"
            END
            ELSE 0
        END AS goalstaken
   FROM (((public."Bracket" t1
     JOIN public."BracketTeam" t2 ON ((t1."bracketId" = t2."bracketId")))
     JOIN public."Team" t3 ON ((t2."teamId" = t3."teamId")))
     JOIN public."SoccerMatch" t4 ON ((((t3."teamId" = t4."teamIdHome") OR (t3."teamId" = t4."teamIdGuest")) AND (t1."phaseId" = t4."phaseId"))));


ALTER TABLE public."BracketStanding_Sub1" OWNER TO tippspiel;

--
-- TOC entry 194 (class 1259 OID 16608)
-- Name: BracketStanding_Sub2; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketStanding_Sub2" AS
 SELECT t1."bracketId",
    t1."bracketDescription",
    t1."teamId",
    t1."teamDescription",
    t1.matchdone,
    t1.scorediff,
    t1.goalsshot,
    t1.goalstaken,
        CASE
            WHEN ((t1.matchdone = 1) AND (t1.scorediff > 0)) THEN 3
            WHEN ((t1.matchdone = 1) AND (t1.scorediff = 0)) THEN 1
            WHEN ((t1.matchdone = 1) AND (t1.scorediff < 0)) THEN 0
            ELSE 0
        END AS points,
        CASE
            WHEN ((t1.matchdone = 1) AND (t1.scorediff > 0)) THEN 1
            ELSE 0
        END AS win,
        CASE
            WHEN ((t1.matchdone = 1) AND (t1.scorediff = 0)) THEN 1
            ELSE 0
        END AS draw,
        CASE
            WHEN ((t1.matchdone = 1) AND (t1.scorediff < 0)) THEN 1
            ELSE 0
        END AS loss
   FROM public."BracketStanding_Sub1" t1;


ALTER TABLE public."BracketStanding_Sub2" OWNER TO tippspiel;

--
-- TOC entry 195 (class 1259 OID 16612)
-- Name: BracketStanding; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketStanding" AS
 SELECT ((((sum(t1.points) * 10000) + ((sum(t1.scorediff) + 50) * 100)) + sum(t1.goalsshot)) +
        CASE
            WHEN ((t1."teamDescription")::text = 'Italien'::text) THEN 2
            ELSE 0
        END) AS rank,
    t1."bracketId",
    t1."bracketDescription",
    t1."teamId",
    t1."teamDescription",
    sum(t1.matchdone) AS matchesplayed,
    sum(t1.scorediff) AS scorediff,
    sum(t1.goalsshot) AS goalsshot,
    sum(t1.goalstaken) AS goalstaken,
    sum(t1.points) AS points,
    sum(t1.win) AS wins,
    sum(t1.draw) AS draws,
    sum(t1.loss) AS losses
   FROM public."BracketStanding_Sub2" t1
  GROUP BY t1."bracketId", t1."bracketDescription", t1."teamId", t1."teamDescription";


ALTER TABLE public."BracketStanding" OWNER TO tippspiel;

--
-- TOC entry 196 (class 1259 OID 16617)
-- Name: BracketMaxRank; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketMaxRank" AS
 SELECT "BracketStanding"."bracketId",
    max("BracketStanding".rank) AS maxrank
   FROM public."BracketStanding"
  GROUP BY "BracketStanding"."bracketId";


ALTER TABLE public."BracketMaxRank" OWNER TO tippspiel;

--
-- TOC entry 197 (class 1259 OID 16621)
-- Name: BracketMinDatetime; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketMinDatetime" AS
 SELECT t1."bracketId",
    min(t2.datetime) AS datetime
   FROM (public."BracketTeam" t1
     JOIN public."SoccerMatch" t2 ON (((t1."teamId" = t2."teamIdHome") OR (t1."teamId" = t2."teamIdGuest"))))
  GROUP BY t1."bracketId";


ALTER TABLE public."BracketMinDatetime" OWNER TO tippspiel;

--
-- TOC entry 198 (class 1259 OID 16625)
-- Name: BracketTeam_bracketTeamId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."BracketTeam_bracketTeamId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."BracketTeam_bracketTeamId_seq" OWNER TO tippspiel;

--
-- TOC entry 2331 (class 0 OID 0)
-- Dependencies: 198
-- Name: BracketTeam_bracketTeamId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."BracketTeam_bracketTeamId_seq" OWNED BY public."BracketTeam"."bracketTeamId";


--
-- TOC entry 199 (class 1259 OID 16627)
-- Name: BracketWinner; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketWinner" AS
 SELECT t1."bracketId",
    min(t1."teamId") AS "teamId"
   FROM (public."BracketStanding" t1
     JOIN public."BracketMaxRank" t2 ON (((t1."bracketId" = t2."bracketId") AND (t1.rank = t2.maxrank))))
  WHERE (t1.matchesplayed = 3)
  GROUP BY t1."bracketId";


ALTER TABLE public."BracketWinner" OWNER TO tippspiel;

--
-- TOC entry 200 (class 1259 OID 16631)
-- Name: Bracket_bracketId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Bracket_bracketId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Bracket_bracketId_seq" OWNER TO tippspiel;

--
-- TOC entry 2332 (class 0 OID 0)
-- Dependencies: 200
-- Name: Bracket_bracketId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Bracket_bracketId_seq" OWNED BY public."Bracket"."bracketId";


--
-- TOC entry 201 (class 1259 OID 16633)
-- Name: Phase; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Phase" (
    "phaseId" integer NOT NULL,
    phasename character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying,
    datefrom timestamp without time zone NOT NULL,
    isgroupphase boolean DEFAULT false NOT NULL
);


ALTER TABLE public."Phase" OWNER TO tippspiel;

--
-- TOC entry 202 (class 1259 OID 16638)
-- Name: Phase_phaseId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Phase_phaseId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Phase_phaseId_seq" OWNER TO tippspiel;

--
-- TOC entry 2333 (class 0 OID 0)
-- Dependencies: 202
-- Name: Phase_phaseId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Phase_phaseId_seq" OWNED BY public."Phase"."phaseId";


--
-- TOC entry 203 (class 1259 OID 16640)
-- Name: Role; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Role" (
    "roleId" integer NOT NULL,
    rolename character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Role" OWNER TO tippspiel;

--
-- TOC entry 204 (class 1259 OID 16644)
-- Name: Role_roleId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Role_roleId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Role_roleId_seq" OWNER TO tippspiel;

--
-- TOC entry 2334 (class 0 OID 0)
-- Dependencies: 204
-- Name: Role_roleId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Role_roleId_seq" OWNED BY public."Role"."roleId";


--
-- TOC entry 205 (class 1259 OID 16646)
-- Name: SoccerMatchBetWithTendency; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."SoccerMatchBetWithTendency" AS
 SELECT "Bet"."betId",
    "Bet"."userId",
    "Bet"."matchId",
    "Bet"."scoreHome",
    "Bet"."scoreGuest",
        CASE
            WHEN ("Bet"."scoreHome" > "Bet"."scoreGuest") THEN 1
            WHEN ("Bet"."scoreHome" < "Bet"."scoreGuest") THEN 2
            ELSE 3
        END AS tendency
   FROM public."Bet"
  WHERE (("Bet".betkind)::text = 'MATCH'::text);


ALTER TABLE public."SoccerMatchBetWithTendency" OWNER TO tippspiel;

--
-- TOC entry 206 (class 1259 OID 16650)
-- Name: SoccerMatchWithTendency; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."SoccerMatchWithTendency" AS
 SELECT "SoccerMatch"."matchId",
    "SoccerMatch"."scoreHome",
    "SoccerMatch"."scoreGuest",
        CASE
            WHEN (("SoccerMatch"."scoreHome" IS NULL) OR ("SoccerMatch"."scoreGuest" IS NULL)) THEN 0
            WHEN ("SoccerMatch"."scoreHome" > "SoccerMatch"."scoreGuest") THEN 1
            WHEN ("SoccerMatch"."scoreHome" < "SoccerMatch"."scoreGuest") THEN 2
            ELSE 3
        END AS tendency
   FROM public."SoccerMatch";


ALTER TABLE public."SoccerMatchWithTendency" OWNER TO tippspiel;

--
-- TOC entry 207 (class 1259 OID 16654)
-- Name: SoccerMatch_matchId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."SoccerMatch_matchId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."SoccerMatch_matchId_seq" OWNER TO tippspiel;

--
-- TOC entry 2335 (class 0 OID 0)
-- Dependencies: 207
-- Name: SoccerMatch_matchId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."SoccerMatch_matchId_seq" OWNED BY public."SoccerMatch"."matchId";


--
-- TOC entry 208 (class 1259 OID 16656)
-- Name: Team_teamId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."Team_teamId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Team_teamId_seq" OWNER TO tippspiel;

--
-- TOC entry 2336 (class 0 OID 0)
-- Dependencies: 208
-- Name: Team_teamId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Team_teamId_seq" OWNED BY public."Team"."teamId";


--
-- TOC entry 209 (class 1259 OID 16658)
-- Name: TourneyWinner; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."TourneyWinner" AS
 SELECT
        CASE
            WHEN (t1.tendency = 1) THEN t2."teamIdHome"
            WHEN (t1.tendency = 2) THEN t2."teamIdGuest"
            ELSE NULL::integer
        END AS "teamId"
   FROM (public."SoccerMatchWithTendency" t1
     JOIN public."SoccerMatch" t2 ON (((t1."matchId" = t2."matchId") AND (t2.isfinals = true))));


ALTER TABLE public."TourneyWinner" OWNER TO tippspiel;

--
-- TOC entry 210 (class 1259 OID 16662)
-- Name: User; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."User" (
    "userId" integer NOT NULL,
    username character varying(20) NOT NULL,
    password character varying(50) DEFAULT NULL::character varying,
    lastname character varying(50) DEFAULT NULL::character varying,
    firstname character varying(50) DEFAULT NULL::character varying,
    email character varying(100) DEFAULT NULL::character varying,
    passwordinit character varying(50),
    haspaidentryfee boolean DEFAULT false NOT NULL
);


ALTER TABLE public."User" OWNER TO tippspiel;

--
-- TOC entry 211 (class 1259 OID 16670)
-- Name: UserBetScore; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."UserBetScore" AS
 SELECT t1."userId",
    t2."betId",
        CASE
            WHEN (t2.tendency = t3.tendency) THEN
            CASE
                WHEN ((t2."scoreHome" <> t3."scoreHome") AND (t2."scoreGuest" <> t3."scoreGuest")) THEN 1
                WHEN ((t2."scoreHome" <> t3."scoreHome") OR (t2."scoreGuest" <> t3."scoreGuest")) THEN 2
                ELSE 3
            END
            ELSE 0
        END AS score
   FROM ((public."User" t1
     JOIN public."SoccerMatchBetWithTendency" t2 ON ((t1."userId" = t2."userId")))
     JOIN public."SoccerMatchWithTendency" t3 ON ((t2."matchId" = t3."matchId")))
UNION ALL
 SELECT t1."userId",
    t2."betId",
        CASE
            WHEN (t2."teamId" = t3."teamId") THEN 3
            ELSE 0
        END AS score
   FROM ((public."User" t1
     JOIN public."Bet" t2 ON (((t1."userId" = t2."userId") AND ((t2.betkind)::text = 'BRACKETWINNER'::text))))
     JOIN public."BracketWinner" t3 ON ((t2."bracketId" = t3."bracketId")))
UNION ALL
 SELECT t1."userId",
    t2."betId",
        CASE
            WHEN (t2."teamId" = t3."teamId") THEN 5
            ELSE 0
        END AS score
   FROM ((public."User" t1
     JOIN public."Bet" t2 ON (((t1."userId" = t2."userId") AND ((t2.betkind)::text = 'CHAMPION'::text))))
     JOIN public."TourneyWinner" t3 ON ((1 = 1)))
UNION ALL
 SELECT t1."userId",
    0 AS "betId",
    0 AS score
   FROM public."User" t1;


ALTER TABLE public."UserBetScore" OWNER TO tippspiel;

--
-- TOC entry 212 (class 1259 OID 16675)
-- Name: UserBetgroup; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."UserBetgroup" (
    "userBetgroupId" integer NOT NULL,
    "userId" integer NOT NULL,
    "betgroupId" integer NOT NULL
);


ALTER TABLE public."UserBetgroup" OWNER TO tippspiel;

--
-- TOC entry 213 (class 1259 OID 16678)
-- Name: UserBetScoreAggr; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."UserBetScoreAggr" AS
 SELECT tmp2."userId",
    tmp2.score,
    tmp2.rank,
        CASE
            WHEN (tmp2.rank = 1) THEN 4
            WHEN (tmp2.rank = 2) THEN 2
            WHEN (tmp2.rank = 3) THEN 1
            ELSE 0
        END AS winparts,
    tmp2."betgroupId"
   FROM ( SELECT tmp1."userId",
            tmp1.score,
            dense_rank() OVER (PARTITION BY tmp1."betgroupId" ORDER BY tmp1.score DESC) AS rank,
            tmp1."betgroupId"
           FROM ( SELECT t1."userId",
                    t2."betgroupId",
                    sum(t1.score) AS score
                   FROM (public."UserBetScore" t1
                     JOIN public."UserBetgroup" t2 ON ((t1."userId" = t2."userId")))
                  GROUP BY t1."userId", t2."betgroupId") tmp1) tmp2;


ALTER TABLE public."UserBetScoreAggr" OWNER TO tippspiel;

--
-- TOC entry 214 (class 1259 OID 16683)
-- Name: UserBetgroup_userBetgroupId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."UserBetgroup_userBetgroupId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."UserBetgroup_userBetgroupId_seq" OWNER TO tippspiel;

--
-- TOC entry 2337 (class 0 OID 0)
-- Dependencies: 214
-- Name: UserBetgroup_userBetgroupId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserBetgroup_userBetgroupId_seq" OWNED BY public."UserBetgroup"."userBetgroupId";


--
-- TOC entry 215 (class 1259 OID 16685)
-- Name: UserPost; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."UserPost" (
    "userPostId" integer NOT NULL,
    "userId" integer NOT NULL,
    "betgroupId" integer NOT NULL,
    post text,
    createdate timestamp without time zone NOT NULL
);


ALTER TABLE public."UserPost" OWNER TO tippspiel;

--
-- TOC entry 216 (class 1259 OID 16691)
-- Name: UserPost_userPostId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."UserPost_userPostId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."UserPost_userPostId_seq" OWNER TO tippspiel;

--
-- TOC entry 2338 (class 0 OID 0)
-- Dependencies: 216
-- Name: UserPost_userPostId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserPost_userPostId_seq" OWNED BY public."UserPost"."userPostId";


--
-- TOC entry 217 (class 1259 OID 16693)
-- Name: UserRole; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."UserRole" (
    "userRoleId" integer NOT NULL,
    "userId" integer NOT NULL,
    "roleId" integer NOT NULL
);


ALTER TABLE public."UserRole" OWNER TO tippspiel;

--
-- TOC entry 218 (class 1259 OID 16696)
-- Name: UserRole_userRoleId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."UserRole_userRoleId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."UserRole_userRoleId_seq" OWNER TO tippspiel;

--
-- TOC entry 2339 (class 0 OID 0)
-- Dependencies: 218
-- Name: UserRole_userRoleId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserRole_userRoleId_seq" OWNED BY public."UserRole"."userRoleId";


--
-- TOC entry 219 (class 1259 OID 16698)
-- Name: User_userId_seq; Type: SEQUENCE; Schema: public; Owner: tippspiel
--

CREATE SEQUENCE public."User_userId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."User_userId_seq" OWNER TO tippspiel;

--
-- TOC entry 2340 (class 0 OID 0)
-- Dependencies: 219
-- Name: User_userId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."User_userId_seq" OWNED BY public."User"."userId";


--
-- TOC entry 2112 (class 2604 OID 16700)
-- Name: Bet betId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bet" ALTER COLUMN "betId" SET DEFAULT nextval('public."Bet_betId_seq"'::regclass);


--
-- TOC entry 2114 (class 2604 OID 16701)
-- Name: Betgroup betgroupId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Betgroup" ALTER COLUMN "betgroupId" SET DEFAULT nextval('public."Betgroup_betgroupId_seq"'::regclass);


--
-- TOC entry 2116 (class 2604 OID 16702)
-- Name: Bracket bracketId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bracket" ALTER COLUMN "bracketId" SET DEFAULT nextval('public."Bracket_bracketId_seq"'::regclass);


--
-- TOC entry 2117 (class 2604 OID 16703)
-- Name: BracketTeam bracketTeamId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."BracketTeam" ALTER COLUMN "bracketTeamId" SET DEFAULT nextval('public."BracketTeam_bracketTeamId_seq"'::regclass);


--
-- TOC entry 2124 (class 2604 OID 16704)
-- Name: Phase phaseId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Phase" ALTER COLUMN "phaseId" SET DEFAULT nextval('public."Phase_phaseId_seq"'::regclass);


--
-- TOC entry 2126 (class 2604 OID 16705)
-- Name: Role roleId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Role" ALTER COLUMN "roleId" SET DEFAULT nextval('public."Role_roleId_seq"'::regclass);


--
-- TOC entry 2119 (class 2604 OID 16706)
-- Name: SoccerMatch matchId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."SoccerMatch" ALTER COLUMN "matchId" SET DEFAULT nextval('public."SoccerMatch_matchId_seq"'::regclass);


--
-- TOC entry 2121 (class 2604 OID 16707)
-- Name: Team teamId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Team" ALTER COLUMN "teamId" SET DEFAULT nextval('public."Team_teamId_seq"'::regclass);


--
-- TOC entry 2132 (class 2604 OID 16708)
-- Name: User userId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."User" ALTER COLUMN "userId" SET DEFAULT nextval('public."User_userId_seq"'::regclass);


--
-- TOC entry 2133 (class 2604 OID 16709)
-- Name: UserBetgroup userBetgroupId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserBetgroup" ALTER COLUMN "userBetgroupId" SET DEFAULT nextval('public."UserBetgroup_userBetgroupId_seq"'::regclass);


--
-- TOC entry 2134 (class 2604 OID 16710)
-- Name: UserPost userPostId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserPost" ALTER COLUMN "userPostId" SET DEFAULT nextval('public."UserPost_userPostId_seq"'::regclass);


--
-- TOC entry 2135 (class 2604 OID 16711)
-- Name: UserRole userRoleId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserRole" ALTER COLUMN "userRoleId" SET DEFAULT nextval('public."UserRole_userRoleId_seq"'::regclass);


--
-- TOC entry 2297 (class 0 OID 16577)
-- Dependencies: 185
-- Data for Name: Bet; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Bet" VALUES (2664, 70, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2666, 70, 'MATCH', 80, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2673, 70, 'MATCH', 99, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2674, 70, 'MATCH', 58, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2678, 70, 'MATCH', 70, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2679, 70, 'MATCH', 71, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2681, 70, 'MATCH', 82, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2682, 70, 'MATCH', 77, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2686, 70, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2687, 70, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2688, 70, 'MATCH', 100, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2689, 70, 'MATCH', 101, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2692, 70, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2697, 70, 'MATCH', 78, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2700, 70, 'MATCH', 90, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2701, 70, 'MATCH', 84, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2702, 70, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2703, 70, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2704, 70, 'MATCH', 103, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2705, 70, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2706, 70, 'MATCH', 96, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2710, 70, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (2711, 70, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (2712, 70, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (2713, 70, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (2714, 70, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (2715, 70, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (2717, 74, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2718, 74, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2719, 74, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2730, 74, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2744, 74, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2764, 74, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2766, 74, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2768, 74, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2769, 74, 'MATCH', 109, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2771, 74, 'MATCH', 111, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2772, 74, 'MATCH', 112, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2773, 74, 'MATCH', 113, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2774, 74, 'MATCH', 114, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2775, 74, 'MATCH', 115, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2776, 74, 'MATCH', 116, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2777, 74, 'MATCH', 117, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2778, 74, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2779, 74, 'MATCH', 119, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2716, 74, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2782, 76, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2786, 76, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2788, 76, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2781, 76, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2708, 70, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (2784, 76, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2787, 76, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2720, 74, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2721, 74, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2722, 74, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2680, 70, 'MATCH', 76, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2723, 74, 'MATCH', 80, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2731, 74, 'MATCH', 58, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2725, 74, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2726, 74, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2727, 74, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2733, 74, 'MATCH', 59, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2793, 76, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2660, 70, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2667, 70, 'MATCH', 86, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2661, 70, 'MATCH', 62, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2662, 70, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2663, 70, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2665, 70, 'MATCH', 69, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2698, 70, 'MATCH', 75, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2668, 70, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2669, 70, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2670, 70, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2671, 70, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2672, 70, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2675, 70, 'MATCH', 64, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2676, 70, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2677, 70, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2790, 76, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2684, 70, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2685, 70, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2695, 70, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2696, 70, 'MATCH', 79, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2699, 70, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2755, 74, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2709, 70, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (2783, 76, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2729, 74, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2791, 76, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2792, 76, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2794, 76, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2732, 74, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2724, 74, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2734, 74, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2737, 74, 'MATCH', 76, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2735, 74, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2738, 74, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2739, 74, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2749, 74, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2736, 74, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2789, 76, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2740, 74, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2741, 74, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2742, 74, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2747, 74, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2745, 74, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2746, 74, 'MATCH', 101, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2748, 74, 'MATCH', 60, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2750, 74, 'MATCH', 67, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2751, 74, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2752, 74, 'MATCH', 73, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2754, 74, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2753, 74, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2756, 74, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2757, 74, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2759, 74, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2761, 74, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2760, 74, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2763, 74, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2690, 70, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2691, 70, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2694, 70, 'MATCH', 73, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2758, 74, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2762, 74, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2765, 74, 'MATCH', 105, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2767, 74, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2770, 74, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2707, 70, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (2804, 76, 'MATCH', 83, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2807, 76, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2810, 76, 'MATCH', 101, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2811, 76, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2820, 76, 'MATCH', 90, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2822, 76, 'MATCH', 84, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2833, 76, 'MATCH', 109, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2835, 76, 'MATCH', 111, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2836, 76, 'MATCH', 112, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2837, 76, 'MATCH', 113, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2838, 76, 'MATCH', 114, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2839, 76, 'MATCH', 115, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2840, 76, 'MATCH', 116, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2841, 76, 'MATCH', 117, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2842, 76, 'MATCH', 118, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2843, 76, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2846, 91, 'MATCH', 62, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2854, 91, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2862, 91, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2863, 91, 'MATCH', 70, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2865, 91, 'MATCH', 76, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2900, 91, 'MATCH', 112, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2901, 91, 'MATCH', 113, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2902, 91, 'MATCH', 114, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2903, 91, 'MATCH', 115, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2904, 91, 'MATCH', 116, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2905, 91, 'MATCH', 117, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2906, 91, 'MATCH', 118, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2907, 91, 'MATCH', 119, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2908, 79, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2909, 79, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2910, 79, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2911, 79, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2912, 79, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2913, 79, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2914, 79, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2915, 79, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2916, 79, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2917, 79, 'MATCH', 81, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2918, 79, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2919, 95, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2920, 95, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2921, 95, 'MATCH', 62, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2922, 95, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2923, 95, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2924, 95, 'MATCH', 74, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2926, 95, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2927, 95, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2928, 95, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2929, 95, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2930, 95, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2844, 91, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2845, 91, 'MATCH', 57, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2848, 91, 'MATCH', 68, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2849, 91, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2850, 91, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2883, 91, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2851, 91, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2852, 91, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2853, 91, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2855, 91, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2856, 91, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2857, 91, 'MATCH', 98, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2858, 91, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2860, 91, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2861, 91, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2864, 91, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2867, 91, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2868, 91, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2869, 91, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2870, 91, 'MATCH', 88, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2871, 91, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2872, 91, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2890, 91, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2891, 91, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2888, 91, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2889, 91, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2886, 91, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2887, 91, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2828, 76, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2885, 91, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2882, 91, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2878, 91, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2879, 91, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2877, 91, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2875, 91, 'MATCH', 61, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2876, 91, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2859, 91, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2880, 91, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2873, 91, 'MATCH', 100, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2874, 91, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2925, 95, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2796, 76, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2797, 76, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2799, 76, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2802, 76, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2803, 76, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2809, 76, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2806, 76, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2795, 76, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2798, 76, 'MATCH', 65, 0, 5, NULL, NULL);
INSERT INTO public."Bet" VALUES (2801, 76, 'MATCH', 76, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2816, 76, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2817, 76, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2823, 76, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2818, 76, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2821, 76, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2884, 91, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2825, 76, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2805, 76, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2808, 76, 'MATCH', 95, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2812, 76, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2814, 76, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2824, 76, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2827, 76, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2813, 76, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2815, 76, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2834, 76, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2831, 76, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2892, 91, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2893, 91, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2894, 91, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2896, 91, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2897, 91, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2898, 91, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2899, 91, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2829, 76, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2832, 76, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2830, 76, 'MATCH', 106, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2943, 95, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2958, 95, 'MATCH', 75, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2939, 95, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2968, 101, 'MATCH', 57, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2969, 101, 'MATCH', 62, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2971, 101, 'MATCH', 68, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2972, 101, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2973, 101, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2967, 101, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2974, 82, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (2975, 82, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (2976, 82, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (2977, 82, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (2978, 82, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (2979, 82, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (2980, 82, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (2981, 82, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (2970, 101, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2983, 101, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2984, 101, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2985, 101, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2986, 101, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2987, 101, 'MATCH', 92, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2988, 101, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2989, 101, 'MATCH', 98, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2990, 101, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2991, 101, 'MATCH', 58, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2992, 109, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2993, 109, 'MATCH', 57, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2994, 109, 'MATCH', 62, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2995, 109, 'MATCH', 63, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2997, 109, 'MATCH', 74, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3001, 109, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3008, 109, 'MATCH', 64, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3009, 109, 'MATCH', 59, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3010, 109, 'MATCH', 65, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3011, 109, 'MATCH', 70, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3012, 109, 'MATCH', 71, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3013, 109, 'MATCH', 76, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3022, 109, 'MATCH', 101, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3023, 109, 'MATCH', 61, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3036, 109, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3048, 109, 'MATCH', 112, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3049, 109, 'MATCH', 113, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3050, 109, 'MATCH', 114, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3051, 109, 'MATCH', 115, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3052, 109, 'MATCH', 116, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3053, 109, 'MATCH', 117, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3054, 109, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3055, 109, 'MATCH', 119, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3056, 109, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3057, 109, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3058, 109, 'BRACKETWINNER', NULL, NULL, NULL, 43, 3);
INSERT INTO public."Bet" VALUES (3059, 109, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3060, 109, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3061, 109, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3062, 109, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (3063, 109, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3065, 105, 'MATCH', 57, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2996, 109, 'MATCH', 68, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2998, 109, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3031, 109, 'MATCH', 75, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2999, 109, 'MATCH', 80, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3000, 109, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3002, 109, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3003, 109, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3004, 109, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3005, 109, 'MATCH', 98, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3006, 109, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3007, 109, 'MATCH', 58, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2931, 95, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2938, 95, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2936, 95, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2937, 95, 'MATCH', 65, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (2932, 95, 'MATCH', 98, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2933, 95, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2934, 95, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2940, 95, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2941, 95, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2942, 95, 'MATCH', 77, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2944, 95, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2945, 95, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2946, 95, 'MATCH', 89, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2947, 95, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2948, 95, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2949, 95, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2950, 95, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2953, 95, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2957, 95, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2955, 95, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2954, 95, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2956, 95, 'MATCH', 79, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2952, 95, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2959, 95, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (2960, 95, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2961, 95, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2962, 95, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2964, 95, 'MATCH', 103, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2963, 95, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2965, 95, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2966, 95, 'MATCH', 96, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3015, 109, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3016, 109, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3017, 109, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3018, 109, 'MATCH', 88, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3019, 109, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3020, 109, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3021, 109, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3024, 109, 'MATCH', 60, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3025, 109, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3026, 109, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3027, 109, 'MATCH', 72, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3028, 109, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3030, 109, 'MATCH', 79, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3029, 109, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3032, 109, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3035, 109, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3034, 109, 'MATCH', 84, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3037, 109, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3039, 109, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3038, 109, 'MATCH', 97, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2982, 82, 'CHAMPION', NULL, NULL, NULL, 62, NULL);
INSERT INTO public."Bet" VALUES (3040, 109, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3042, 109, 'MATCH', 106, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3041, 109, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3043, 109, 'MATCH', 107, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3044, 109, 'MATCH', 108, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3045, 109, 'MATCH', 109, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3046, 109, 'MATCH', 110, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3074, 105, 'MATCH', 87, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3079, 105, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3080, 105, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3081, 105, 'MATCH', 59, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3083, 105, 'MATCH', 70, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3084, 105, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3088, 105, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3090, 105, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3095, 105, 'MATCH', 61, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3097, 105, 'MATCH', 66, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3098, 105, 'MATCH', 67, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3100, 105, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3105, 105, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3108, 105, 'MATCH', 103, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3109, 105, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3113, 105, 'MATCH', 105, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3116, 105, 'MATCH', 108, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3117, 105, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3120, 105, 'MATCH', 112, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3121, 105, 'MATCH', 113, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3122, 105, 'MATCH', 114, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3123, 105, 'MATCH', 115, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3124, 105, 'MATCH', 116, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3125, 105, 'MATCH', 117, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3126, 105, 'MATCH', 118, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3127, 105, 'MATCH', 119, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3066, 105, 'MATCH', 62, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3067, 105, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3068, 105, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3069, 105, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3070, 105, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3071, 105, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3072, 105, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3073, 105, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3075, 105, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3076, 105, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3077, 105, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3078, 105, 'MATCH', 99, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3082, 105, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3085, 105, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3156, 99, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3086, 105, 'MATCH', 82, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3087, 105, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3089, 105, 'MATCH', 94, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3091, 105, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3092, 105, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3093, 105, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3094, 105, 'MATCH', 101, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3096, 105, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3111, 105, 'MATCH', 96, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3101, 105, 'MATCH', 78, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3102, 105, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3104, 105, 'MATCH', 90, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3106, 105, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3107, 105, 'MATCH', 85, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3110, 105, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3128, 105, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3129, 105, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3130, 105, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3131, 105, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3132, 105, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3133, 105, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3135, 105, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3134, 105, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3136, 105, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (3137, 99, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3138, 99, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3139, 99, 'MATCH', 62, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3140, 99, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3141, 99, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3142, 99, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3143, 99, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3144, 99, 'MATCH', 75, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3145, 99, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3146, 99, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3147, 99, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3148, 99, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3151, 99, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3152, 99, 'MATCH', 99, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3160, 99, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3162, 99, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3180, 99, 'MATCH', 84, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3183, 99, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3186, 99, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3187, 99, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3188, 99, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3189, 99, 'BRACKETWINNER', NULL, NULL, NULL, 47, 4);
INSERT INTO public."Bet" VALUES (3190, 99, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3191, 99, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3193, 99, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (3194, 111, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3195, 111, 'MATCH', 57, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3196, 111, 'MATCH', 62, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3197, 111, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3198, 111, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3199, 111, 'MATCH', 74, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3149, 99, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3192, 99, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (3150, 99, 'MATCH', 93, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3155, 99, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3157, 99, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3154, 99, 'MATCH', 64, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3158, 99, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3159, 99, 'MATCH', 76, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3161, 99, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3163, 99, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3165, 99, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3164, 99, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3166, 99, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3167, 99, 'MATCH', 100, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3172, 99, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3168, 99, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3171, 99, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3169, 99, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3170, 99, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3174, 99, 'MATCH', 73, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3176, 99, 'MATCH', 79, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3099, 105, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3175, 99, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3178, 99, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3177, 99, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3179, 99, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3185, 99, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (3181, 99, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3182, 99, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3184, 99, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3112, 105, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3114, 105, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3115, 105, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3119, 105, 'MATCH', 111, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3200, 111, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3201, 111, 'MATCH', 75, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3202, 111, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3203, 111, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3204, 111, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3205, 111, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3206, 111, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3207, 111, 'MATCH', 93, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3208, 111, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3209, 111, 'MATCH', 99, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3210, 111, 'MATCH', 58, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3211, 111, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3212, 111, 'MATCH', 59, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3213, 111, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3214, 111, 'MATCH', 70, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3215, 111, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3216, 111, 'MATCH', 76, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3217, 111, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3219, 111, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3220, 111, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3221, 111, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3222, 111, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3223, 111, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3224, 111, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3225, 111, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3226, 111, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3227, 111, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3228, 111, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3229, 111, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3230, 111, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3231, 111, 'CHAMPION', NULL, NULL, NULL, 36, NULL);
INSERT INTO public."Bet" VALUES (3232, 111, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3233, 111, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3234, 111, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3235, 111, 'MATCH', 61, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3236, 111, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3237, 111, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3238, 111, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3239, 111, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3240, 111, 'MATCH', 72, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3242, 111, 'MATCH', 79, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3243, 111, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3244, 111, 'MATCH', 90, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3245, 111, 'MATCH', 85, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3248, 111, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3249, 111, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3250, 111, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3251, 114, 'MATCH', 56, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3253, 114, 'MATCH', 62, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3254, 114, 'MATCH', 63, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3255, 114, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3256, 114, 'MATCH', 74, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3257, 114, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3258, 114, 'MATCH', 75, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3260, 114, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3261, 114, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3262, 114, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3263, 114, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3264, 114, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3265, 114, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3266, 114, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3268, 114, 'CHAMPION', NULL, NULL, NULL, 40, NULL);
INSERT INTO public."Bet" VALUES (3267, 112, 'MATCH', 56, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3269, 112, 'MATCH', 57, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3270, 112, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3271, 112, 'MATCH', 63, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3272, 112, 'MATCH', 68, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3273, 112, 'MATCH', 74, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3274, 112, 'MATCH', 69, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3275, 112, 'MATCH', 75, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3276, 112, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3277, 112, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3278, 112, 'MATCH', 81, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3279, 112, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3280, 112, 'MATCH', 92, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3281, 112, 'MATCH', 93, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3282, 112, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3283, 112, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3284, 112, 'MATCH', 58, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3285, 112, 'MATCH', 64, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3286, 112, 'MATCH', 59, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3288, 112, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3289, 112, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3290, 112, 'MATCH', 76, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3291, 112, 'MATCH', 82, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3292, 112, 'MATCH', 77, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3293, 112, 'MATCH', 83, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3294, 112, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3296, 112, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3297, 112, 'MATCH', 95, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3298, 112, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3299, 112, 'MATCH', 101, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3301, 112, 'MATCH', 60, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3303, 112, 'MATCH', 66, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3304, 112, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3309, 112, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3310, 112, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3311, 112, 'MATCH', 84, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3312, 112, 'MATCH', 102, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3314, 112, 'MATCH', 96, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3315, 112, 'MATCH', 97, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3316, 112, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3317, 112, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3318, 112, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3319, 112, 'MATCH', 107, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3320, 112, 'MATCH', 108, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3321, 112, 'MATCH', 109, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3322, 112, 'MATCH', 110, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3323, 112, 'MATCH', 111, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3324, 112, 'MATCH', 112, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3325, 112, 'MATCH', 113, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3326, 112, 'MATCH', 114, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3327, 112, 'MATCH', 115, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3328, 112, 'MATCH', 116, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3329, 112, 'MATCH', 117, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3330, 112, 'MATCH', 118, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3331, 112, 'MATCH', 119, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3332, 112, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3333, 112, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3334, 112, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3335, 112, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3259, 114, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3287, 112, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3295, 112, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3302, 112, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3313, 112, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3307, 112, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3308, 112, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3241, 111, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3218, 111, 'MATCH', 77, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3306, 112, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3305, 112, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3246, 111, 'MATCH', 84, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3247, 111, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3336, 112, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3337, 112, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3338, 112, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (3339, 112, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3347, 92, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3354, 92, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3357, 92, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3359, 92, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3361, 92, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3362, 92, 'MATCH', 71, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3366, 92, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3367, 92, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3368, 92, 'MATCH', 88, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3370, 92, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3373, 92, 'MATCH', 60, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3374, 92, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3376, 92, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3378, 92, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3379, 92, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3381, 92, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3384, 92, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3341, 92, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3342, 92, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3343, 92, 'MATCH', 62, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3344, 92, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3345, 92, 'MATCH', 68, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3350, 92, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3348, 92, 'MATCH', 75, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3349, 92, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3431, 97, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3461, 83, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3351, 92, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3353, 92, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3414, 110, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3358, 92, 'MATCH', 64, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3356, 92, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3415, 110, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3360, 92, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3363, 92, 'MATCH', 76, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3364, 92, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3365, 92, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3369, 92, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3371, 92, 'MATCH', 100, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3372, 92, 'MATCH', 101, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3375, 92, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3377, 92, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3380, 92, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3383, 92, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3387, 92, 'MATCH', 96, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3390, 92, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3391, 92, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3392, 92, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3393, 92, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3394, 92, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3395, 92, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3396, 92, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3397, 92, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3398, 110, 'MATCH', 56, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3399, 110, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3400, 110, 'MATCH', 62, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3401, 110, 'MATCH', 63, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3402, 110, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3403, 110, 'MATCH', 74, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3404, 110, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3405, 110, 'MATCH', 75, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3406, 110, 'MATCH', 80, 5, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3407, 110, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3408, 110, 'MATCH', 81, 5, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3410, 110, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3413, 110, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3420, 110, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3421, 110, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3422, 110, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3423, 110, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3424, 110, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3425, 110, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3426, 110, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3429, 97, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3430, 97, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3432, 97, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3433, 97, 'MATCH', 68, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3434, 97, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3435, 97, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3436, 97, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3437, 97, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3438, 97, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3439, 101, 'MATCH', 64, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3440, 101, 'MATCH', 59, 5, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3444, 101, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3446, 101, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3447, 101, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3448, 101, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3449, 101, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3451, 101, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3452, 101, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3457, 83, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3465, 83, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3455, 83, 'MATCH', 62, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3454, 83, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3456, 83, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3458, 83, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3459, 83, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3346, 92, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3462, 83, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3463, 83, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3464, 83, 'MATCH', 87, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3466, 83, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3467, 83, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3469, 83, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3445, 101, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3450, 101, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3460, 83, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3417, 110, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3352, 92, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3411, 110, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3409, 110, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3340, 112, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (3412, 110, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3416, 110, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3441, 101, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3427, 110, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (3385, 92, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3442, 101, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3443, 101, 'MATCH', 71, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3418, 110, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3419, 110, 'MATCH', 71, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3428, 110, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3382, 92, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3386, 92, 'MATCH', 103, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3388, 92, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3389, 92, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (3470, 83, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3475, 83, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3482, 83, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3483, 83, 'MATCH', 100, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3485, 83, 'MATCH', 61, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3490, 83, 'MATCH', 72, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3501, 83, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3503, 83, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3504, 83, 'MATCH', 107, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3506, 83, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3507, 83, 'MATCH', 110, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3508, 83, 'MATCH', 111, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3509, 83, 'MATCH', 112, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3510, 83, 'MATCH', 113, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3511, 83, 'MATCH', 114, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3512, 83, 'MATCH', 115, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3513, 83, 'MATCH', 116, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3514, 83, 'MATCH', 117, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3515, 83, 'MATCH', 118, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3516, 83, 'MATCH', 119, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3517, 83, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3518, 83, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3519, 83, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3520, 83, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3521, 83, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3522, 83, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3523, 83, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3524, 83, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3468, 83, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3474, 83, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3595, 102, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3477, 83, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3478, 83, 'MATCH', 83, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3479, 83, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3552, 84, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3481, 83, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3484, 83, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3563, 84, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3487, 83, 'MATCH', 67, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3488, 83, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3489, 83, 'MATCH', 73, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3491, 83, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3493, 83, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3496, 83, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3497, 83, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3498, 83, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3500, 83, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3505, 83, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3525, 84, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3526, 84, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3527, 84, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3529, 84, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3530, 84, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3531, 84, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3569, 84, 'MATCH', 102, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3533, 84, 'MATCH', 80, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3535, 84, 'MATCH', 81, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3536, 84, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3537, 84, 'MATCH', 92, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3538, 84, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3539, 84, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3541, 84, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3543, 84, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3544, 84, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3545, 84, 'MATCH', 70, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3547, 84, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3548, 84, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3550, 84, 'MATCH', 83, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3551, 84, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3553, 84, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3556, 84, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3557, 84, 'MATCH', 60, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3558, 84, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3559, 84, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3560, 84, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3562, 84, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3564, 84, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3565, 84, 'MATCH', 91, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3566, 84, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3567, 84, 'MATCH', 85, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3568, 84, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3570, 84, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3571, 84, 'MATCH', 96, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3572, 84, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3574, 102, 'MATCH', 57, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3577, 102, 'MATCH', 68, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3587, 102, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3588, 102, 'MATCH', 99, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3591, 102, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3593, 102, 'MATCH', 70, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3594, 102, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3599, 102, 'MATCH', 94, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3575, 102, 'MATCH', 62, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3528, 84, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3532, 84, 'MATCH', 75, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3453, 83, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3576, 102, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3578, 102, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3579, 102, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3580, 102, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3581, 102, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3585, 102, 'MATCH', 92, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3582, 102, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3534, 84, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3542, 84, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3586, 102, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3589, 102, 'MATCH', 58, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3584, 102, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3540, 84, 'MATCH', 99, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3546, 84, 'MATCH', 71, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3590, 102, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3592, 102, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3471, 83, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3472, 83, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3473, 83, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3476, 83, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3596, 102, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3598, 102, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3549, 84, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3480, 83, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3600, 102, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3601, 102, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3554, 84, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3555, 84, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3486, 83, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3561, 84, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3492, 83, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3502, 83, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3494, 83, 'MATCH', 90, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3495, 83, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3607, 102, 'MATCH', 67, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3614, 102, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3615, 102, 'MATCH', 85, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3616, 102, 'MATCH', 84, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3617, 102, 'MATCH', 102, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3618, 102, 'MATCH', 103, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3619, 102, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3626, 102, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3628, 102, 'MATCH', 111, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3629, 102, 'MATCH', 112, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3630, 102, 'MATCH', 113, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3631, 102, 'MATCH', 114, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3632, 102, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3633, 102, 'MATCH', 116, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3634, 102, 'MATCH', 117, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3635, 102, 'MATCH', 118, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3636, 102, 'MATCH', 119, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2785, 76, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2819, 76, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3637, 102, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3640, 102, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3642, 102, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3643, 102, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3646, 76, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3647, 76, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3648, 102, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3649, 76, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3650, 102, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3651, 102, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3652, 102, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3103, 105, 'MATCH', 75, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3064, 105, 'MATCH', 56, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3653, 115, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3655, 115, 'MATCH', 62, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3657, 115, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3658, 115, 'MATCH', 74, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3659, 115, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3660, 115, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3661, 115, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3662, 115, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3663, 115, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3664, 115, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3666, 115, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3667, 115, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3668, 115, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3669, 115, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3670, 115, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3671, 115, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3673, 101, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3674, 101, 'MATCH', 77, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3675, 101, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3676, 101, 'MATCH', 94, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3677, 101, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3678, 101, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3680, 101, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3681, 101, 'MATCH', 101, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3682, 101, 'MATCH', 60, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3683, 101, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3691, 101, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3692, 101, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3693, 101, 'MATCH', 84, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3694, 101, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3696, 101, 'MATCH', 96, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3697, 101, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3679, 101, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3698, 101, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3699, 94, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3700, 94, 'MATCH', 57, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3701, 94, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3702, 94, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3703, 94, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3704, 94, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3705, 94, 'MATCH', 69, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3706, 94, 'MATCH', 75, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3707, 94, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3708, 94, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3709, 94, 'MATCH', 81, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3710, 94, 'MATCH', 87, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3711, 94, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3712, 94, 'MATCH', 93, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3713, 94, 'MATCH', 98, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3714, 94, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3715, 94, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3717, 94, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3718, 94, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (3719, 94, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3720, 94, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3721, 94, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3722, 94, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3723, 94, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (3724, 94, 'BRACKETWINNER', NULL, NULL, NULL, 63, 18);
INSERT INTO public."Bet" VALUES (3725, 94, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3726, 94, 'MATCH', 59, 5, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3727, 94, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3728, 94, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3729, 94, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3730, 94, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3731, 94, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3639, 76, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3641, 76, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3644, 76, 'BRACKETWINNER', NULL, NULL, NULL, 46, 4);
INSERT INTO public."Bet" VALUES (3645, 76, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (2780, 76, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3573, 102, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3665, 115, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3656, 115, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3685, 101, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3687, 101, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3686, 101, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3689, 101, 'MATCH', 79, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3688, 101, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3690, 101, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3603, 102, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3602, 102, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3604, 102, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3606, 102, 'MATCH', 60, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3605, 102, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3608, 102, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3609, 102, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3716, 94, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (3610, 102, 'MATCH', 72, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3611, 102, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3612, 102, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3695, 101, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3613, 102, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3620, 102, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3672, 115, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3624, 102, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3622, 102, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3623, 102, 'MATCH', 106, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3625, 102, 'MATCH', 108, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3621, 102, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3732, 94, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3733, 94, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3734, 94, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3735, 94, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3736, 94, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3737, 94, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3738, 94, 'MATCH', 100, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3739, 94, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3740, 94, 'MATCH', 60, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3741, 94, 'MATCH', 61, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3742, 94, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3743, 94, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3744, 94, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3745, 94, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3746, 94, 'MATCH', 78, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3747, 94, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3748, 94, 'MATCH', 91, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3749, 94, 'MATCH', 90, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3750, 94, 'MATCH', 85, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3751, 94, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3752, 94, 'MATCH', 102, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3753, 94, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3754, 94, 'MATCH', 96, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3755, 94, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2847, 91, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (2866, 91, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3756, 71, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3757, 71, 'MATCH', 57, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3758, 71, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3761, 71, 'MATCH', 74, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3763, 71, 'MATCH', 75, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3764, 71, 'MATCH', 80, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3766, 71, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3768, 71, 'MATCH', 92, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3770, 71, 'MATCH', 98, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3772, 71, 'MATCH', 58, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3773, 71, 'MATCH', 64, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3774, 71, 'MATCH', 59, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3775, 71, 'MATCH', 65, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3776, 71, 'MATCH', 70, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3777, 71, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3778, 71, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3779, 71, 'MATCH', 82, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3780, 71, 'MATCH', 77, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3781, 71, 'MATCH', 83, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3782, 71, 'MATCH', 94, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3783, 71, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3785, 71, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3786, 71, 'MATCH', 100, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3787, 71, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3788, 71, 'MATCH', 61, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3789, 71, 'MATCH', 60, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3790, 71, 'MATCH', 67, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3791, 71, 'MATCH', 66, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3792, 71, 'MATCH', 73, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3793, 71, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3794, 71, 'MATCH', 78, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3795, 71, 'MATCH', 79, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3796, 71, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3799, 71, 'MATCH', 84, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3800, 71, 'MATCH', 102, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3801, 71, 'MATCH', 103, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3803, 71, 'MATCH', 97, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3804, 71, 'MATCH', 104, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3805, 71, 'MATCH', 105, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3806, 71, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3807, 71, 'MATCH', 107, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3808, 71, 'MATCH', 108, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3809, 71, 'MATCH', 109, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3810, 71, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3811, 71, 'MATCH', 111, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3812, 71, 'MATCH', 112, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3813, 71, 'MATCH', 113, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3814, 71, 'MATCH', 114, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3815, 71, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3816, 71, 'MATCH', 116, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3817, 71, 'MATCH', 117, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3818, 71, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3819, 71, 'MATCH', 119, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3765, 71, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3838, 86, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3762, 71, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3759, 71, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3760, 71, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3767, 71, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3769, 71, 'MATCH', 93, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3771, 71, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3853, 86, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3797, 71, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2881, 91, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3798, 71, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3802, 71, 'MATCH', 96, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3820, 91, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (3821, 91, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3822, 91, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3824, 91, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3825, 91, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3826, 91, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3827, 91, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3823, 91, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3829, 86, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3830, 86, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3831, 86, 'MATCH', 62, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3832, 86, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3833, 86, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3834, 86, 'MATCH', 74, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3835, 86, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3836, 86, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3837, 86, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3840, 86, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3841, 86, 'MATCH', 92, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3843, 86, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3844, 86, 'MATCH', 99, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3845, 86, 'MATCH', 58, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3846, 86, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3847, 86, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3849, 86, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3850, 86, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3851, 86, 'MATCH', 76, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3852, 86, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3854, 86, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3855, 86, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3857, 86, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3858, 86, 'MATCH', 95, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3859, 86, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3860, 86, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3861, 86, 'MATCH', 60, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3862, 86, 'MATCH', 61, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3863, 86, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3842, 86, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3848, 86, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3784, 71, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3828, 91, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3856, 86, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3864, 86, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3865, 86, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3866, 86, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3867, 86, 'MATCH', 78, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3868, 86, 'MATCH', 79, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3869, 86, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3870, 86, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3871, 86, 'MATCH', 85, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3872, 86, 'MATCH', 84, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3873, 86, 'MATCH', 102, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3877, 86, 'MATCH', 97, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3878, 86, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (3879, 86, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3880, 86, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3881, 86, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3882, 86, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3883, 86, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3884, 86, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3885, 86, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (3886, 86, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (3887, 101, 'MATCH', 75, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3893, 100, 'MATCH', 74, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3894, 100, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3900, 100, 'MATCH', 92, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3901, 100, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3902, 100, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3903, 100, 'MATCH', 99, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3904, 100, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3905, 100, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3907, 100, 'MATCH', 65, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3912, 100, 'MATCH', 77, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3913, 100, 'MATCH', 83, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3914, 100, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3915, 100, 'MATCH', 88, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3916, 100, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3917, 100, 'MATCH', 95, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3919, 100, 'MATCH', 101, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3924, 100, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3929, 100, 'MATCH', 90, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3932, 100, 'MATCH', 102, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3936, 100, 'MATCH', 104, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3937, 100, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3944, 100, 'MATCH', 112, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3945, 100, 'MATCH', 113, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3946, 100, 'MATCH', 114, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3947, 100, 'MATCH', 115, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3948, 100, 'MATCH', 116, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3949, 100, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3950, 100, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3951, 100, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3952, 103, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3953, 103, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (3954, 103, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (3955, 103, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (3956, 103, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (3957, 103, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (3959, 103, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (3960, 103, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3961, 103, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3962, 103, 'MATCH', 57, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3963, 103, 'MATCH', 62, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3964, 103, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3965, 103, 'MATCH', 68, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3966, 103, 'MATCH', 74, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3967, 103, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3968, 103, 'MATCH', 75, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3958, 103, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (3970, 78, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3971, 78, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3972, 78, 'MATCH', 62, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3973, 78, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3974, 78, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3975, 78, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3976, 78, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3977, 78, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3978, 78, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3979, 78, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3980, 78, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3981, 78, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3982, 78, 'MATCH', 92, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3983, 78, 'MATCH', 93, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (3984, 78, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3985, 78, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3986, 78, 'MATCH', 58, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3988, 78, 'MATCH', 59, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3990, 78, 'MATCH', 70, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3994, 78, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3995, 78, 'MATCH', 83, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3997, 78, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3998, 78, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3895, 100, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3891, 100, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3890, 100, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3889, 100, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3892, 100, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3898, 100, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3896, 100, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3899, 100, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3969, 103, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3987, 78, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3906, 100, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3908, 100, 'MATCH', 70, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3909, 100, 'MATCH', 71, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3910, 100, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3989, 78, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3991, 78, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3992, 78, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3993, 78, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3911, 100, 'MATCH', 82, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3999, 78, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3918, 100, 'MATCH', 100, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3923, 100, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3920, 100, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3922, 100, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3926, 100, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3925, 100, 'MATCH', 72, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3921, 100, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3927, 100, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3928, 100, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3931, 100, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3933, 100, 'MATCH', 103, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3930, 100, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3935, 100, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3934, 100, 'MATCH', 96, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3875, 86, 'MATCH', 103, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3876, 86, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3939, 100, 'MATCH', 107, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3940, 100, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3942, 100, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3943, 100, 'MATCH', 111, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3941, 100, 'MATCH', 109, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3938, 100, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4001, 78, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4002, 78, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4003, 78, 'MATCH', 60, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4006, 78, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4007, 78, 'MATCH', 72, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4008, 78, 'MATCH', 78, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4009, 78, 'MATCH', 79, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4010, 78, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4012, 78, 'MATCH', 85, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4013, 78, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4014, 78, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4015, 78, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4016, 78, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4017, 78, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4018, 78, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (4019, 78, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4020, 78, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4021, 78, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4022, 78, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4023, 78, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4024, 78, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4025, 78, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4026, 78, 'CHAMPION', NULL, NULL, NULL, 37, NULL);
INSERT INTO public."Bet" VALUES (4028, 88, 'MATCH', 57, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4029, 88, 'MATCH', 62, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4030, 88, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4032, 88, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4033, 88, 'MATCH', 69, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4034, 88, 'MATCH', 75, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4035, 88, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4038, 88, 'MATCH', 87, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4040, 88, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4041, 88, 'MATCH', 98, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4042, 88, 'MATCH', 99, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4043, 88, 'MATCH', 58, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4047, 88, 'MATCH', 70, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4049, 88, 'MATCH', 76, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4051, 88, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4052, 88, 'MATCH', 83, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4058, 88, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4060, 88, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4062, 88, 'MATCH', 66, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4066, 88, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4068, 88, 'MATCH', 90, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4069, 88, 'MATCH', 85, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4071, 88, 'MATCH', 102, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4072, 88, 'MATCH', 103, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4073, 88, 'MATCH', 96, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4075, 88, 'MATCH', 104, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4076, 88, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4077, 88, 'MATCH', 106, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4078, 88, 'MATCH', 107, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4079, 88, 'MATCH', 108, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4080, 88, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4081, 88, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4082, 88, 'MATCH', 111, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4083, 88, 'MATCH', 112, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4084, 88, 'MATCH', 113, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4085, 88, 'MATCH', 114, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4086, 88, 'MATCH', 115, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4087, 88, 'MATCH', 116, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4088, 88, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4089, 88, 'MATCH', 118, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4090, 88, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4036, 88, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4027, 88, 'MATCH', 56, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4031, 88, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4091, 88, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (4092, 88, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (4093, 88, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4094, 88, 'CHAMPION', NULL, NULL, NULL, 40, NULL);
INSERT INTO public."Bet" VALUES (4095, 88, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4096, 88, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4097, 88, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4098, 88, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4099, 88, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4048, 88, 'MATCH', 71, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4063, 88, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4100, 113, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4101, 113, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4102, 113, 'MATCH', 57, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4103, 113, 'MATCH', 62, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4105, 113, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4106, 113, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4107, 113, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4111, 113, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4115, 113, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4116, 113, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4110, 113, 'BRACKETWINNER', NULL, NULL, NULL, 43, 3);
INSERT INTO public."Bet" VALUES (4108, 113, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4119, 107, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4120, 107, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4121, 107, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4122, 107, 'MATCH', 63, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4123, 107, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4124, 107, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4125, 107, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4126, 107, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4127, 107, 'MATCH', 80, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4128, 107, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4129, 107, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4130, 107, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4131, 107, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4133, 107, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4134, 107, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4118, 113, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4109, 113, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4112, 113, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4000, 78, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4114, 113, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4113, 113, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4037, 88, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4039, 88, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4044, 88, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4045, 88, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4050, 88, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4046, 88, 'MATCH', 65, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4132, 107, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4117, 113, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4004, 78, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4005, 78, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4053, 88, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4054, 88, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4061, 88, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4057, 88, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4059, 88, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4055, 88, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4064, 88, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4065, 88, 'MATCH', 78, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4067, 88, 'MATCH', 91, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4070, 88, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4011, 78, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4135, 107, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4136, 107, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4137, 107, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4138, 107, 'BRACKETWINNER', NULL, NULL, NULL, 45, 4);
INSERT INTO public."Bet" VALUES (4139, 107, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4140, 107, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4141, 107, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4142, 107, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4144, 90, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4145, 90, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4146, 90, 'MATCH', 62, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4147, 90, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4148, 90, 'MATCH', 68, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4149, 90, 'MATCH', 74, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4150, 90, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4151, 90, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4152, 90, 'MATCH', 80, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4153, 90, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4154, 90, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4155, 90, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4156, 90, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4157, 90, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4158, 90, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4159, 90, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4160, 90, 'MATCH', 58, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4161, 90, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4162, 90, 'MATCH', 59, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4163, 90, 'MATCH', 65, 0, 5, NULL, NULL);
INSERT INTO public."Bet" VALUES (4164, 90, 'MATCH', 70, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4165, 90, 'MATCH', 71, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4166, 90, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4167, 90, 'MATCH', 82, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4168, 90, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4169, 90, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4170, 90, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4171, 90, 'MATCH', 88, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4172, 90, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4173, 90, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4174, 90, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4176, 90, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4177, 90, 'MATCH', 60, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4178, 90, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4179, 90, 'MATCH', 66, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4180, 90, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4181, 90, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4183, 90, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4185, 90, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4186, 90, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4187, 90, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4190, 90, 'MATCH', 96, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4192, 90, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4193, 90, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (4194, 90, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4195, 90, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4196, 90, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4197, 90, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4198, 90, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4199, 90, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4200, 90, 'CHAMPION', NULL, NULL, NULL, 40, NULL);
INSERT INTO public."Bet" VALUES (4201, 119, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4202, 119, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4203, 119, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4204, 119, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4205, 119, 'MATCH', 68, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4207, 80, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4209, 80, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4210, 80, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4213, 80, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4221, 80, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4227, 80, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4228, 80, 'MATCH', 71, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4229, 80, 'MATCH', 76, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4230, 80, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4233, 80, 'MATCH', 94, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4235, 80, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4236, 80, 'MATCH', 95, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4244, 80, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4248, 80, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4251, 80, 'MATCH', 102, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4252, 80, 'MATCH', 103, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4253, 80, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4254, 80, 'MATCH', 97, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4257, 80, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4258, 80, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4259, 80, 'MATCH', 108, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4260, 80, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4261, 80, 'MATCH', 110, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4262, 80, 'MATCH', 111, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4263, 80, 'MATCH', 112, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4264, 80, 'MATCH', 113, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4265, 80, 'MATCH', 114, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4266, 80, 'MATCH', 115, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4267, 80, 'MATCH', 116, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4268, 80, 'MATCH', 117, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4269, 80, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4270, 80, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4217, 80, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4220, 80, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4218, 80, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4212, 80, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4214, 80, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4215, 80, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4175, 90, 'MATCH', 101, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4206, 119, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4211, 80, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4208, 80, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4184, 90, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4222, 80, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4223, 80, 'MATCH', 58, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4225, 80, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4224, 80, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4226, 80, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4231, 80, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4232, 80, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4234, 80, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4237, 80, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4240, 80, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4239, 80, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4241, 80, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4242, 80, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4243, 80, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4245, 80, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4246, 80, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4256, 80, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4182, 90, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4247, 80, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4143, 107, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (4249, 80, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4189, 90, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4191, 90, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4250, 80, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4255, 80, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4216, 80, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4219, 80, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4273, 97, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4274, 97, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4275, 97, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4277, 97, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4278, 97, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4280, 97, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4281, 110, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4283, 97, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4285, 97, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4290, 97, 'MATCH', 81, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4291, 97, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4292, 97, 'MATCH', 92, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4293, 97, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4294, 97, 'MATCH', 98, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4295, 97, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4296, 97, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4297, 97, 'MATCH', 64, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4298, 97, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4299, 97, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4301, 97, 'MATCH', 71, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4303, 97, 'MATCH', 70, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4304, 97, 'MATCH', 76, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4305, 97, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4306, 97, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4307, 97, 'MATCH', 83, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4308, 97, 'MATCH', 94, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4309, 97, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4310, 97, 'MATCH', 89, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4311, 97, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4312, 97, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4313, 97, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4314, 97, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4315, 97, 'MATCH', 60, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4316, 97, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4317, 97, 'MATCH', 66, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4319, 97, 'MATCH', 73, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4320, 97, 'MATCH', 72, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4321, 97, 'MATCH', 78, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4322, 97, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4326, 110, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4328, 110, 'MATCH', 79, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4335, 110, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4336, 110, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4337, 110, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4338, 110, 'MATCH', 105, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4339, 110, 'MATCH', 106, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4340, 110, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4341, 110, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4342, 110, 'MATCH', 109, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4343, 110, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4344, 110, 'MATCH', 111, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4345, 110, 'MATCH', 112, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4346, 110, 'MATCH', 113, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4347, 110, 'MATCH', 114, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4348, 110, 'MATCH', 115, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4349, 110, 'MATCH', 116, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4350, 110, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4352, 110, 'MATCH', 119, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4353, 82, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4354, 82, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4355, 82, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4356, 82, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4357, 82, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4358, 82, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4359, 82, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4360, 82, 'MATCH', 75, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4363, 69, 'MATCH', 62, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4364, 69, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4367, 69, 'MATCH', 69, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4368, 69, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4369, 69, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4371, 69, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4372, 69, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4375, 69, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4376, 69, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4377, 69, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4378, 69, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4381, 69, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4383, 69, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4385, 69, 'MATCH', 77, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4386, 69, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4388, 69, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4391, 69, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4392, 69, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4393, 69, 'MATCH', 61, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4394, 69, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4397, 69, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4398, 69, 'MATCH', 73, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4399, 69, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4402, 69, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4403, 69, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4362, 69, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4365, 69, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4370, 69, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4373, 69, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4374, 69, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4379, 69, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4380, 69, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4382, 69, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4384, 69, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4387, 69, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4389, 69, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4390, 69, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4396, 69, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4395, 69, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4400, 69, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4401, 69, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4287, 110, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4351, 110, 'MATCH', 118, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4284, 110, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4271, 110, 'MATCH', 76, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4272, 110, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4276, 110, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4279, 110, 'MATCH', 83, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4282, 110, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4289, 110, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4286, 110, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4324, 110, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4302, 110, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4300, 110, 'MATCH', 61, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4323, 110, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4329, 110, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4325, 110, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4327, 110, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4330, 110, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4331, 110, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4332, 110, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4288, 97, 'CHAMPION', NULL, NULL, NULL, 37, NULL);
INSERT INTO public."Bet" VALUES (4334, 110, 'MATCH', 103, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4333, 110, 'MATCH', 102, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4405, 69, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4406, 69, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4407, 69, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4408, 69, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4361, 69, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4366, 69, 'MATCH', 74, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4404, 69, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4409, 69, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (4410, 89, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4411, 89, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (4412, 89, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4413, 89, 'BRACKETWINNER', NULL, NULL, NULL, 46, 4);
INSERT INTO public."Bet" VALUES (4414, 89, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4415, 89, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4416, 89, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4417, 89, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4419, 89, 'MATCH', 56, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4420, 89, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4421, 89, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4422, 89, 'MATCH', 63, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4423, 89, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4424, 89, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4425, 89, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4426, 89, 'MATCH', 75, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4427, 89, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4428, 89, 'MATCH', 86, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4429, 89, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4430, 89, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4431, 89, 'MATCH', 92, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4432, 89, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4434, 89, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4435, 89, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4437, 89, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4438, 89, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4472, 73, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4483, 73, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4487, 73, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4488, 73, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4495, 73, 'MATCH', 112, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4496, 73, 'MATCH', 113, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4497, 73, 'MATCH', 114, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4498, 73, 'MATCH', 115, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4499, 73, 'MATCH', 116, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4500, 73, 'MATCH', 117, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4501, 73, 'MATCH', 118, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4502, 73, 'MATCH', 119, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4439, 73, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4508, 69, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4441, 73, 'MATCH', 62, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4442, 73, 'MATCH', 63, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4443, 73, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4440, 73, 'MATCH', 57, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4444, 73, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4445, 73, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4446, 73, 'MATCH', 75, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4447, 73, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4448, 73, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4449, 73, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4450, 73, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4451, 73, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4452, 73, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4460, 73, 'MATCH', 71, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4454, 73, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4503, 69, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4504, 69, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4505, 69, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4506, 69, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4507, 69, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4509, 69, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4510, 69, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4511, 12, 'MATCH', 56, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4512, 12, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4513, 12, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4514, 87, 'MATCH', 56, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4515, 87, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4516, 87, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4517, 87, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4529, 93, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4519, 93, 'MATCH', 57, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4520, 93, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4521, 93, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4522, 93, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4523, 93, 'MATCH', 74, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4525, 93, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4526, 93, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4527, 93, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4456, 73, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4528, 93, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4531, 93, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4535, 93, 'MATCH', 64, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4534, 93, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4536, 93, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4474, 73, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4530, 93, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4455, 73, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4453, 73, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4461, 73, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4457, 73, 'MATCH', 59, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4458, 73, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4462, 73, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4463, 73, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4464, 73, 'MATCH', 83, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4465, 73, 'MATCH', 94, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4466, 73, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4467, 73, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4468, 73, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4469, 73, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4470, 73, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4471, 73, 'MATCH', 61, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4433, 89, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4532, 93, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4436, 89, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4473, 73, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4476, 73, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4475, 73, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4478, 73, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4482, 73, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4480, 73, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4479, 73, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4481, 73, 'MATCH', 85, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4418, 89, 'CHAMPION', NULL, NULL, NULL, 46, NULL);
INSERT INTO public."Bet" VALUES (4484, 73, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4485, 73, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4486, 73, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4477, 73, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4490, 73, 'MATCH', 107, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4491, 73, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4492, 73, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4494, 73, 'MATCH', 111, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4493, 73, 'MATCH', 110, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4542, 93, 'MATCH', 77, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4543, 93, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4545, 93, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4546, 93, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4548, 93, 'MATCH', 100, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4549, 93, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4568, 93, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4571, 93, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4572, 93, 'MATCH', 110, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4574, 93, 'MATCH', 112, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4575, 93, 'MATCH', 113, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4576, 93, 'MATCH', 114, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4577, 93, 'MATCH', 115, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4578, 93, 'MATCH', 116, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4579, 93, 'MATCH', 117, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4580, 93, 'MATCH', 118, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4581, 93, 'MATCH', 119, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4518, 93, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4524, 93, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4538, 93, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4539, 93, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4540, 93, 'MATCH', 76, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4551, 93, 'MATCH', 60, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4547, 93, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4666, 119, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4553, 93, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4554, 93, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4556, 93, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4557, 93, 'MATCH', 79, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4638, 74, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4639, 74, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4558, 93, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4559, 93, 'MATCH', 90, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4560, 93, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4563, 93, 'MATCH', 103, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4570, 93, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4582, 93, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (4583, 93, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4584, 93, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4585, 93, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4586, 93, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4640, 74, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4587, 93, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4590, 79, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4591, 79, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4592, 79, 'MATCH', 93, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (4593, 79, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4594, 79, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4595, 79, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4596, 79, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4597, 79, 'MATCH', 59, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4598, 79, 'MATCH', 65, 0, 5, NULL, NULL);
INSERT INTO public."Bet" VALUES (4599, 79, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4600, 79, 'MATCH', 71, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4601, 79, 'MATCH', 76, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4602, 79, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4603, 79, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4604, 79, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4605, 79, 'MATCH', 94, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4606, 79, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4607, 79, 'MATCH', 89, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4608, 79, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4609, 79, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4610, 79, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4611, 79, 'MATCH', 61, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4612, 79, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4613, 79, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4614, 79, 'MATCH', 66, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4615, 79, 'MATCH', 73, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4616, 79, 'MATCH', 72, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4617, 79, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4618, 79, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4619, 79, 'MATCH', 91, 0, 5, NULL, NULL);
INSERT INTO public."Bet" VALUES (4620, 79, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4621, 79, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4622, 79, 'MATCH', 84, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (4623, 79, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4624, 79, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4625, 79, 'MATCH', 96, 4, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4626, 79, 'MATCH', 97, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4627, 82, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4628, 82, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4629, 82, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4630, 82, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4632, 82, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4633, 74, 'BRACKETWINNER', NULL, NULL, NULL, 34, 1);
INSERT INTO public."Bet" VALUES (4634, 74, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4635, 74, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4637, 74, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4642, 119, 'MATCH', 69, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4643, 119, 'MATCH', 75, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4644, 119, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4645, 119, 'MATCH', 86, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4646, 119, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4647, 119, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4648, 119, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4649, 119, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4651, 119, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4652, 119, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4653, 119, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4655, 119, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4656, 119, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4658, 119, 'MATCH', 76, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4660, 119, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4661, 119, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4662, 119, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4664, 119, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4665, 119, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4667, 119, 'MATCH', 101, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4668, 119, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4669, 119, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4588, 93, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4589, 93, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4631, 82, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4654, 119, 'MATCH', 59, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4537, 93, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4657, 119, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4659, 119, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4544, 93, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4541, 93, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4663, 119, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4550, 93, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4552, 93, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4555, 93, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4561, 93, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4566, 93, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4562, 93, 'MATCH', 102, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4564, 93, 'MATCH', 96, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4567, 93, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4641, 74, 'CHAMPION', NULL, NULL, NULL, 46, NULL);
INSERT INTO public."Bet" VALUES (4573, 93, 'MATCH', 111, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4569, 93, 'MATCH', 107, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4670, 119, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4671, 119, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4672, 119, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4675, 119, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4677, 119, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4678, 119, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4679, 119, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4680, 119, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4681, 119, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4682, 119, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4683, 119, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4684, 119, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4685, 119, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4686, 119, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4687, 119, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4688, 119, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4689, 119, 'BRACKETWINNER', NULL, NULL, NULL, 53, 6);
INSERT INTO public."Bet" VALUES (4690, 119, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4691, 119, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4693, 85, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4694, 85, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4695, 85, 'MATCH', 62, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4697, 85, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3888, 100, 'MATCH', 56, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4698, 85, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4699, 85, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4700, 85, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4701, 85, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4702, 85, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4703, 85, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4704, 100, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4706, 100, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4708, 100, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4709, 100, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4710, 100, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4711, 100, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (3897, 100, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4712, 106, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4713, 106, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4714, 106, 'MATCH', 62, 5, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4715, 106, 'MATCH', 63, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4717, 106, 'MATCH', 74, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4716, 106, 'MATCH', 68, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4718, 106, 'MATCH', 69, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4719, 106, 'MATCH', 75, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4720, 106, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4721, 106, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4722, 106, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4723, 70, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4727, 70, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4731, 70, 'MATCH', 112, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4732, 70, 'MATCH', 113, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4733, 70, 'MATCH', 114, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4734, 70, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4735, 70, 'MATCH', 116, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4736, 70, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4737, 70, 'MATCH', 118, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4738, 70, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4739, 106, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4740, 106, 'MATCH', 92, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4741, 106, 'MATCH', 93, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4742, 106, 'MATCH', 98, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4743, 106, 'MATCH', 99, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4748, 106, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4749, 106, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4750, 106, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4751, 106, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4752, 106, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4753, 106, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4754, 106, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4755, 106, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (4759, 96, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4761, 12, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4762, 12, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4763, 12, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4764, 12, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4765, 96, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4766, 12, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4760, 96, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (4782, 12, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4769, 12, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4794, 12, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4783, 12, 'MATCH', 58, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4770, 12, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4771, 12, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4784, 12, 'MATCH', 62, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4772, 12, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4773, 12, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4774, 12, 'MATCH', 75, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4775, 12, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4776, 12, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4777, 12, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4778, 12, 'MATCH', 92, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4746, 96, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4779, 12, 'MATCH', 93, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4780, 96, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4781, 12, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4785, 12, 'MATCH', 80, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4786, 12, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4788, 12, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4789, 12, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2683, 70, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4745, 96, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4792, 12, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4747, 96, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4793, 12, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4757, 96, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4758, 96, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4795, 12, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4796, 12, 'MATCH', 88, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4799, 12, 'MATCH', 100, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4800, 12, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4801, 12, 'MATCH', 60, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4705, 100, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (4707, 100, 'BRACKETWINNER', NULL, NULL, NULL, 46, 4);
INSERT INTO public."Bet" VALUES (4696, 85, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4787, 12, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4790, 12, 'MATCH', 71, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4791, 12, 'MATCH', 76, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4797, 12, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4798, 12, 'MATCH', 95, 6, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4673, 119, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4674, 119, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4676, 119, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4744, 96, 'CHAMPION', NULL, NULL, NULL, 37, NULL);
INSERT INTO public."Bet" VALUES (4756, 106, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (4692, 119, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (4768, 12, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (4724, 70, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4726, 70, 'MATCH', 107, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4728, 70, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4729, 70, 'MATCH', 110, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4730, 70, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4803, 12, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4805, 12, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4808, 12, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4810, 12, 'MATCH', 91, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (4811, 96, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4812, 12, 'MATCH', 90, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4813, 12, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4814, 12, 'MATCH', 84, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4815, 12, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4816, 12, 'MATCH', 103, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4817, 12, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4819, 120, 'MATCH', 56, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4820, 120, 'MATCH', 57, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4821, 120, 'MATCH', 62, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4822, 120, 'MATCH', 63, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4823, 120, 'MATCH', 68, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4824, 120, 'MATCH', 74, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4825, 120, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4826, 120, 'MATCH', 75, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4827, 120, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4828, 120, 'MATCH', 86, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4829, 120, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4830, 120, 'MATCH', 87, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4831, 120, 'MATCH', 92, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4832, 120, 'MATCH', 93, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4833, 120, 'MATCH', 98, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4834, 120, 'MATCH', 99, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4835, 120, 'MATCH', 58, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4836, 120, 'MATCH', 64, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4837, 120, 'MATCH', 59, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4838, 120, 'MATCH', 65, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4839, 120, 'MATCH', 70, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4840, 120, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4841, 120, 'MATCH', 76, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4842, 120, 'MATCH', 82, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4843, 120, 'MATCH', 77, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4844, 120, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4845, 120, 'MATCH', 94, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4846, 120, 'MATCH', 88, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4847, 120, 'MATCH', 89, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4848, 120, 'MATCH', 95, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4849, 120, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4850, 120, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4851, 120, 'MATCH', 61, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4852, 120, 'MATCH', 60, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4853, 120, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4854, 120, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4855, 120, 'MATCH', 73, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4856, 120, 'MATCH', 72, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4857, 120, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4858, 120, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4859, 120, 'MATCH', 91, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4860, 120, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4861, 120, 'MATCH', 85, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4862, 120, 'MATCH', 84, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4863, 120, 'MATCH', 102, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4864, 120, 'MATCH', 103, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4865, 120, 'MATCH', 96, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4866, 120, 'MATCH', 97, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4867, 120, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4868, 120, 'MATCH', 105, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4869, 120, 'MATCH', 106, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4870, 120, 'MATCH', 107, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4871, 120, 'MATCH', 108, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4872, 120, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4873, 120, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4874, 120, 'MATCH', 111, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4875, 120, 'MATCH', 112, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4876, 120, 'MATCH', 113, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4877, 120, 'MATCH', 114, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4878, 120, 'MATCH', 115, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4879, 120, 'MATCH', 116, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4880, 120, 'MATCH', 117, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4881, 120, 'MATCH', 118, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4882, 120, 'MATCH', 119, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4883, 120, 'BRACKETWINNER', NULL, NULL, NULL, 34, 1);
INSERT INTO public."Bet" VALUES (4884, 120, 'BRACKETWINNER', NULL, NULL, NULL, 39, 2);
INSERT INTO public."Bet" VALUES (4885, 120, 'BRACKETWINNER', NULL, NULL, NULL, 41, 3);
INSERT INTO public."Bet" VALUES (4886, 120, 'BRACKETWINNER', NULL, NULL, NULL, 47, 4);
INSERT INTO public."Bet" VALUES (4887, 120, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4888, 120, 'BRACKETWINNER', NULL, NULL, NULL, 55, 6);
INSERT INTO public."Bet" VALUES (4889, 120, 'BRACKETWINNER', NULL, NULL, NULL, 58, 17);
INSERT INTO public."Bet" VALUES (4890, 120, 'BRACKETWINNER', NULL, NULL, NULL, 63, 18);
INSERT INTO public."Bet" VALUES (4891, 120, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (4894, 104, 'MATCH', 62, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4899, 104, 'MATCH', 75, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4902, 104, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4907, 104, 'MATCH', 99, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4916, 104, 'MATCH', 77, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4927, 104, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4930, 104, 'MATCH', 78, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4932, 104, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4893, 104, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4895, 104, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4896, 104, 'MATCH', 68, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4897, 104, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4804, 12, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4903, 104, 'MATCH', 87, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4901, 104, 'MATCH', 86, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4904, 104, 'MATCH', 92, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4905, 104, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4906, 104, 'MATCH', 98, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4908, 104, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4910, 104, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4909, 104, 'MATCH', 64, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4809, 96, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4911, 104, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4912, 104, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4913, 104, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4914, 104, 'MATCH', 76, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4917, 104, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4918, 104, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4923, 104, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4920, 104, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4921, 104, 'MATCH', 95, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4935, 104, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4924, 104, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4926, 104, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4929, 104, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4934, 104, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4937, 104, 'MATCH', 103, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4818, 122, 'MATCH', 56, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4900, 104, 'MATCH', 80, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4919, 104, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4925, 104, 'MATCH', 60, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4928, 104, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4931, 104, 'MATCH', 79, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4933, 104, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4936, 104, 'MATCH', 102, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4802, 12, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4807, 12, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4806, 12, 'MATCH', 73, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4938, 104, 'MATCH', 96, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4939, 104, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4940, 104, 'MATCH', 104, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4941, 104, 'MATCH', 105, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4944, 104, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4947, 104, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4948, 104, 'MATCH', 112, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4949, 104, 'MATCH', 113, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4950, 104, 'MATCH', 114, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4951, 104, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4952, 104, 'MATCH', 116, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4953, 104, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4954, 104, 'MATCH', 118, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4956, 104, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (4957, 104, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4958, 104, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4959, 104, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (4960, 104, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4961, 104, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (4962, 104, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (4963, 104, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (4964, 104, 'CHAMPION', NULL, NULL, NULL, 40, NULL);
INSERT INTO public."Bet" VALUES (4892, 104, 'MATCH', 56, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4898, 104, 'MATCH', 69, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4915, 104, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5051, 81, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (4967, 96, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4969, 96, 'MATCH', 75, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5052, 81, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (4965, 96, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4971, 116, 'MATCH', 57, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4972, 116, 'MATCH', 62, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4973, 116, 'MATCH', 63, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4974, 116, 'MATCH', 68, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4975, 116, 'MATCH', 74, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4976, 116, 'MATCH', 69, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4977, 116, 'MATCH', 75, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4978, 116, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4979, 116, 'MATCH', 86, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4980, 116, 'MATCH', 81, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4981, 116, 'MATCH', 87, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4982, 116, 'MATCH', 92, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4983, 116, 'MATCH', 93, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4984, 116, 'MATCH', 98, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4985, 116, 'MATCH', 99, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4986, 116, 'MATCH', 58, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4987, 116, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4988, 116, 'MATCH', 59, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4989, 116, 'MATCH', 65, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4990, 116, 'MATCH', 70, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4991, 116, 'MATCH', 71, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4992, 116, 'MATCH', 76, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4993, 116, 'MATCH', 82, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5002, 116, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5006, 116, 'MATCH', 73, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5008, 116, 'MATCH', 78, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5013, 116, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5014, 116, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5015, 116, 'MATCH', 103, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5018, 116, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5019, 116, 'MATCH', 105, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5020, 116, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5021, 116, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5022, 116, 'MATCH', 108, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5023, 116, 'MATCH', 109, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5024, 116, 'MATCH', 110, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5025, 116, 'MATCH', 111, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5026, 116, 'MATCH', 112, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5027, 116, 'MATCH', 113, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5028, 116, 'MATCH', 114, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5029, 116, 'MATCH', 115, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5030, 116, 'MATCH', 116, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5031, 116, 'MATCH', 117, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5032, 116, 'MATCH', 118, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5033, 116, 'MATCH', 119, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5060, 81, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5034, 121, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (3252, 114, 'MATCH', 57, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5035, 114, 'MATCH', 80, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5036, 114, 'MATCH', 86, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5037, 114, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5039, 114, 'MATCH', 92, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5041, 80, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (5042, 80, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (5043, 80, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5044, 80, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5045, 80, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5046, 80, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5047, 80, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (5048, 80, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5050, 81, 'BRACKETWINNER', NULL, NULL, NULL, 32, 1);
INSERT INTO public."Bet" VALUES (5053, 81, 'BRACKETWINNER', NULL, NULL, NULL, 46, 4);
INSERT INTO public."Bet" VALUES (5054, 81, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5055, 81, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5056, 81, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5057, 81, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5059, 81, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4942, 104, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5062, 81, 'MATCH', 63, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3638, 76, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (5067, 75, 'MATCH', 56, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5068, 75, 'MATCH', 57, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5061, 81, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5063, 81, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4968, 96, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5066, 81, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4966, 96, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5065, 81, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4955, 104, 'MATCH', 119, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5038, 114, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5040, 114, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4994, 116, 'MATCH', 77, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4995, 116, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4996, 116, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4997, 116, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4998, 116, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4999, 116, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5000, 116, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5017, 116, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5001, 116, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5005, 116, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5004, 116, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5003, 116, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5007, 116, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5009, 116, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5011, 116, 'MATCH', 90, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5010, 116, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5012, 116, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5049, 80, 'CHAMPION', NULL, NULL, NULL, 46, NULL);
INSERT INTO public."Bet" VALUES (5058, 81, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (4945, 104, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4943, 104, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4946, 104, 'MATCH', 110, 5, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5069, 75, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5070, 75, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5071, 75, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5072, 75, 'MATCH', 74, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5073, 75, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5074, 75, 'MATCH', 75, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5075, 75, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5076, 75, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5077, 75, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5078, 75, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5079, 75, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (5080, 75, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (5081, 75, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5082, 75, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5083, 75, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5084, 75, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5085, 75, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5086, 75, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (5087, 75, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (5088, 114, 'MATCH', 98, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5089, 114, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5090, 114, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5091, 114, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5092, 114, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2659, 70, 'MATCH', 56, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4970, 116, 'MATCH', 56, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5093, 121, 'MATCH', 56, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5094, 121, 'MATCH', 57, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5095, 77, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (5096, 77, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5097, 77, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5098, 77, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5099, 77, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5100, 77, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5101, 77, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (5103, 77, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5104, 77, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5105, 77, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5106, 77, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5107, 77, 'MATCH', 74, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5108, 77, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5109, 77, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5110, 77, 'MATCH', 80, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5111, 77, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5112, 77, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5113, 77, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5114, 77, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5115, 77, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5116, 77, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5117, 81, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5119, 81, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5121, 114, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5122, 114, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5123, 114, 'MATCH', 76, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5124, 114, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5126, 114, 'MATCH', 83, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5127, 114, 'MATCH', 94, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5128, 114, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5129, 114, 'MATCH', 89, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5131, 114, 'MATCH', 100, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5132, 114, 'MATCH', 101, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5133, 114, 'MATCH', 61, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5135, 114, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5136, 114, 'MATCH', 66, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5137, 114, 'MATCH', 73, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5138, 114, 'MATCH', 72, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5140, 114, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5141, 114, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5142, 114, 'MATCH', 90, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5144, 114, 'MATCH', 84, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5145, 114, 'MATCH', 102, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5146, 114, 'MATCH', 103, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5147, 114, 'MATCH', 96, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5148, 114, 'MATCH', 97, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5149, 114, 'MATCH', 104, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5151, 114, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5152, 114, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5153, 114, 'MATCH', 108, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5155, 114, 'MATCH', 110, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5156, 114, 'MATCH', 111, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5157, 114, 'MATCH', 112, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5158, 114, 'MATCH', 113, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5159, 114, 'MATCH', 114, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5160, 114, 'MATCH', 115, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5161, 114, 'MATCH', 116, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5162, 114, 'MATCH', 117, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5163, 114, 'MATCH', 118, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5164, 114, 'MATCH', 119, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4767, 122, 'BRACKETWINNER', NULL, NULL, NULL, 35, 1);
INSERT INTO public."Bet" VALUES (5165, 12, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5166, 12, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5125, 114, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5167, 122, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5168, 113, 'MATCH', 87, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5169, 122, 'MATCH', 62, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5170, 113, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5171, 113, 'MATCH', 93, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5172, 122, 'MATCH', 63, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5173, 122, 'MATCH', 68, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5174, 122, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5175, 122, 'MATCH', 69, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5176, 122, 'MATCH', 75, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5177, 122, 'MATCH', 80, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5178, 122, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5180, 122, 'MATCH', 81, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5181, 122, 'MATCH', 87, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5182, 122, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5183, 122, 'MATCH', 76, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5185, 122, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5186, 122, 'MATCH', 99, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5187, 122, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5188, 122, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5189, 122, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5190, 122, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5191, 122, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5192, 122, 'MATCH', 71, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5196, 122, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5197, 122, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5198, 122, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5064, 81, 'MATCH', 74, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5118, 81, 'MATCH', 86, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3654, 115, 'MATCH', 57, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5184, 122, 'MATCH', 93, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5120, 114, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5194, 122, 'MATCH', 77, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5193, 122, 'MATCH', 82, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5130, 114, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5134, 114, 'MATCH', 60, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5139, 114, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5143, 114, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5150, 114, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5102, 77, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (5154, 114, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5199, 108, 'MATCH', 57, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5200, 108, 'MATCH', 62, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5201, 108, 'MATCH', 63, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5202, 108, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5203, 108, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5204, 108, 'MATCH', 69, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5205, 108, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5206, 108, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (5207, 108, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5208, 108, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5209, 108, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5210, 108, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5211, 108, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5212, 108, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5213, 121, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (5214, 121, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5215, 121, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5216, 121, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5217, 121, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5218, 121, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5219, 121, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (5220, 121, 'MATCH', 62, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5221, 121, 'MATCH', 63, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5222, 121, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5223, 121, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5224, 121, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5232, 103, 'MATCH', 58, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5235, 103, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5237, 103, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5241, 103, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5247, 103, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5249, 103, 'MATCH', 60, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5253, 103, 'MATCH', 72, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5263, 103, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5271, 103, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5272, 103, 'MATCH', 112, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5273, 103, 'MATCH', 113, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5274, 103, 'MATCH', 114, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5275, 103, 'MATCH', 115, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5276, 103, 'MATCH', 116, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5277, 103, 'MATCH', 117, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5278, 103, 'MATCH', 118, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5279, 103, 'MATCH', 119, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5280, 85, 'BRACKETWINNER', NULL, NULL, NULL, 37, 2);
INSERT INTO public."Bet" VALUES (5281, 85, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5282, 85, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5283, 85, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5284, 85, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5285, 85, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5286, 85, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5287, 85, 'CHAMPION', NULL, NULL, NULL, 56, NULL);
INSERT INTO public."Bet" VALUES (5288, 85, 'MATCH', 87, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5289, 85, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5290, 85, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5291, 85, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5292, 85, 'MATCH', 99, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5294, 85, 'MATCH', 58, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5295, 123, 'MATCH', 57, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5296, 123, 'MATCH', 62, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5297, 123, 'MATCH', 63, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5298, 123, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5299, 123, 'MATCH', 74, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5300, 123, 'MATCH', 69, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5301, 123, 'MATCH', 75, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5302, 123, 'MATCH', 80, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5303, 123, 'MATCH', 86, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5304, 123, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5305, 123, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5306, 123, 'MATCH', 92, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5307, 123, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5308, 123, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5309, 123, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5310, 123, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5311, 123, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5312, 123, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5313, 123, 'MATCH', 65, 1, 5, NULL, NULL);
INSERT INTO public."Bet" VALUES (5314, 123, 'MATCH', 70, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5315, 123, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5316, 123, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5317, 123, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5318, 123, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5319, 123, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5320, 123, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5321, 123, 'MATCH', 88, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5322, 123, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5323, 123, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5324, 123, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5325, 123, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5326, 123, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5327, 123, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5328, 123, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5329, 123, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5330, 123, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5331, 123, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5332, 123, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5333, 123, 'MATCH', 78, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5334, 123, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5226, 103, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5228, 103, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5229, 103, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5227, 103, 'MATCH', 87, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5234, 103, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5236, 103, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5239, 103, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5240, 103, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5242, 103, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5243, 103, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5245, 103, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5248, 103, 'MATCH', 61, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5250, 103, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5251, 103, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5252, 103, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5264, 103, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5256, 103, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5260, 103, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5231, 103, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5238, 103, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5246, 103, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5255, 103, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5244, 103, 'MATCH', 89, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5258, 103, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5261, 103, 'MATCH', 103, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5262, 103, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5257, 103, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5259, 103, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5254, 103, 'MATCH', 79, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5265, 103, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5266, 103, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5267, 103, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5268, 103, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5270, 103, 'MATCH', 110, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5269, 103, 'MATCH', 109, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5335, 123, 'MATCH', 91, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5336, 123, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5337, 123, 'MATCH', 84, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5338, 123, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5339, 123, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5340, 123, 'MATCH', 97, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5341, 123, 'MATCH', 96, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5342, 121, 'MATCH', 75, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5343, 73, 'BRACKETWINNER', NULL, NULL, NULL, 36, 2);
INSERT INTO public."Bet" VALUES (5344, 73, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5345, 73, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5346, 73, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5347, 73, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5348, 73, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (5349, 73, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5351, 121, 'MATCH', 80, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5352, 121, 'MATCH', 86, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5353, 121, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4104, 113, 'MATCH', 63, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5354, 87, 'MATCH', 68, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5355, 87, 'MATCH', 74, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5356, 87, 'MATCH', 69, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5357, 87, 'MATCH', 75, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5358, 87, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5360, 87, 'MATCH', 81, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5365, 87, 'MATCH', 99, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5368, 87, 'MATCH', 59, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5369, 87, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5372, 87, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5373, 87, 'MATCH', 82, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5374, 87, 'MATCH', 77, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5376, 87, 'MATCH', 94, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5379, 87, 'MATCH', 95, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5380, 87, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5381, 87, 'MATCH', 101, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5383, 87, 'MATCH', 61, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5386, 87, 'MATCH', 73, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5387, 87, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5388, 87, 'MATCH', 78, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5389, 87, 'MATCH', 79, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5390, 87, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5391, 87, 'MATCH', 90, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5392, 87, 'MATCH', 85, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5393, 87, 'MATCH', 84, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5394, 87, 'MATCH', 103, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5395, 87, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5396, 87, 'MATCH', 96, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5397, 87, 'MATCH', 97, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5398, 87, 'MATCH', 104, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5399, 87, 'MATCH', 105, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5400, 87, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5401, 87, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5402, 87, 'MATCH', 108, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5403, 87, 'MATCH', 109, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5404, 87, 'MATCH', 110, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5405, 87, 'MATCH', 111, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5406, 87, 'MATCH', 112, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5407, 87, 'MATCH', 113, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5408, 87, 'MATCH', 114, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5409, 87, 'MATCH', 115, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5410, 87, 'MATCH', 116, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5411, 87, 'MATCH', 117, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5412, 87, 'MATCH', 118, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5413, 87, 'MATCH', 119, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5359, 87, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5414, 87, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5415, 87, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5417, 87, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5418, 87, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (5419, 87, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5416, 87, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (4636, 74, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5420, 96, 'MATCH', 80, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5421, 96, 'MATCH', 86, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5422, 96, 'MATCH', 81, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5423, 96, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5424, 96, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5425, 96, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5426, 96, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5427, 96, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5428, 96, 'MATCH', 58, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5429, 72, 'MATCH', 68, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5430, 72, 'MATCH', 74, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5431, 72, 'MATCH', 69, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5432, 72, 'MATCH', 75, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5433, 72, 'MATCH', 80, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5434, 72, 'MATCH', 86, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5436, 72, 'MATCH', 81, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5437, 72, 'BRACKETWINNER', NULL, NULL, NULL, 40, 3);
INSERT INTO public."Bet" VALUES (5438, 72, 'BRACKETWINNER', NULL, NULL, NULL, 44, 4);
INSERT INTO public."Bet" VALUES (5440, 72, 'BRACKETWINNER', NULL, NULL, NULL, 48, 5);
INSERT INTO public."Bet" VALUES (5441, 72, 'BRACKETWINNER', NULL, NULL, NULL, 52, 6);
INSERT INTO public."Bet" VALUES (5442, 72, 'BRACKETWINNER', NULL, NULL, NULL, 56, 17);
INSERT INTO public."Bet" VALUES (5443, 72, 'BRACKETWINNER', NULL, NULL, NULL, 62, 18);
INSERT INTO public."Bet" VALUES (5444, 72, 'CHAMPION', NULL, NULL, NULL, 53, NULL);
INSERT INTO public."Bet" VALUES (5445, 72, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5447, 72, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5450, 72, 'MATCH', 93, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5451, 72, 'MATCH', 98, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5452, 72, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5453, 72, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5455, 108, 'MATCH', 80, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5456, 108, 'MATCH', 86, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5457, 108, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5458, 108, 'MATCH', 87, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5460, 108, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5461, 108, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5463, 108, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5464, 108, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5465, 108, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5466, 108, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5459, 108, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5462, 108, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5361, 87, 'MATCH', 87, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5362, 87, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5363, 87, 'MATCH', 93, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5364, 87, 'MATCH', 98, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5366, 87, 'MATCH', 58, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5367, 87, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5370, 87, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5371, 87, 'MATCH', 71, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5375, 87, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5378, 87, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5377, 87, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5382, 87, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5384, 87, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5385, 87, 'MATCH', 67, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5350, 73, 'CHAMPION', NULL, NULL, NULL, 46, NULL);
INSERT INTO public."Bet" VALUES (5473, 108, 'MATCH', 94, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5477, 108, 'MATCH', 100, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5483, 108, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5467, 108, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5468, 108, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5469, 108, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5470, 108, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5471, 108, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5472, 108, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5474, 108, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5476, 108, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5478, 108, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5480, 108, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5479, 108, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5583, 77, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5481, 108, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5482, 108, 'MATCH', 67, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5484, 108, 'MATCH', 73, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5485, 108, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5486, 108, 'MATCH', 78, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5487, 108, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5488, 108, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5489, 108, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5490, 108, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5491, 108, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5492, 108, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5493, 108, 'MATCH', 97, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5494, 108, 'MATCH', 96, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2935, 95, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3583, 102, 'MATCH', 81, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5225, 103, 'MATCH', 86, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5495, 85, 'MATCH', 104, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5496, 85, 'MATCH', 105, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5498, 85, 'MATCH', 107, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5499, 85, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5500, 85, 'MATCH', 109, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5501, 85, 'MATCH', 110, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5502, 85, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5503, 85, 'MATCH', 112, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5504, 85, 'MATCH', 113, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5505, 85, 'MATCH', 114, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5506, 85, 'MATCH', 115, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5507, 85, 'MATCH', 116, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5508, 85, 'MATCH', 117, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5509, 85, 'MATCH', 118, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5510, 85, 'MATCH', 119, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3839, 86, 'MATCH', 81, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4056, 88, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5511, 85, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5512, 85, 'MATCH', 59, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5514, 85, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5515, 85, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5516, 85, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5517, 85, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5519, 85, 'MATCH', 77, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5520, 85, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5521, 85, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5522, 85, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5523, 85, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5524, 85, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5525, 85, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5526, 85, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5527, 85, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5528, 85, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5529, 85, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5530, 85, 'MATCH', 72, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5531, 85, 'MATCH', 73, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5532, 85, 'MATCH', 78, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5533, 85, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5534, 85, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5535, 85, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5536, 85, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5537, 85, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5538, 85, 'MATCH', 103, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5539, 85, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5540, 85, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5543, 113, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5544, 115, 'MATCH', 87, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5545, 81, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5546, 115, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5547, 81, 'MATCH', 92, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5548, 81, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5549, 115, 'MATCH', 93, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5550, 115, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5551, 115, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5553, 115, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5554, 115, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5233, 103, 'MATCH', 64, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5555, 115, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5556, 121, 'MATCH', 87, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5557, 121, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5558, 121, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5559, 93, 'CHAMPION', NULL, NULL, NULL, 37, NULL);
INSERT INTO public."Bet" VALUES (5560, 116, 'BRACKETWINNER', NULL, NULL, NULL, 59, 17);
INSERT INTO public."Bet" VALUES (5561, 116, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (5562, 75, 'MATCH', 92, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5563, 75, 'MATCH', 93, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5565, 77, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5567, 77, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5569, 77, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5577, 77, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5579, 77, 'MATCH', 100, 3, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5580, 77, 'MATCH', 101, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5582, 77, 'MATCH', 61, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5587, 77, 'MATCH', 78, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5588, 77, 'MATCH', 79, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5542, 113, 'MATCH', 98, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2800, 76, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5566, 77, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5564, 77, 'MATCH', 99, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5568, 77, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5552, 115, 'MATCH', 58, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5513, 85, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5541, 85, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5570, 77, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5572, 77, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5573, 77, 'MATCH', 77, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5574, 77, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5575, 77, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5578, 77, 'MATCH', 95, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5576, 77, 'MATCH', 88, 1, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5518, 85, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5475, 108, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5581, 77, 'MATCH', 60, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5584, 77, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5585, 77, 'MATCH', 72, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5590, 77, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5586, 77, 'MATCH', 73, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5592, 77, 'MATCH', 85, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5497, 85, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5591, 77, 'MATCH', 84, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5597, 77, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5599, 77, 'MATCH', 106, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5602, 77, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5603, 77, 'MATCH', 110, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5604, 77, 'MATCH', 111, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5605, 77, 'MATCH', 112, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5606, 77, 'MATCH', 113, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5607, 77, 'MATCH', 114, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5608, 77, 'MATCH', 115, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5609, 77, 'MATCH', 116, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5610, 77, 'MATCH', 117, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5611, 77, 'MATCH', 118, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5612, 77, 'MATCH', 119, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5613, 75, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5614, 75, 'MATCH', 99, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5615, 75, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5616, 75, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5617, 75, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5618, 75, 'MATCH', 65, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5619, 75, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5620, 75, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5621, 75, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5622, 75, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5623, 75, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5624, 75, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5625, 75, 'MATCH', 94, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5626, 75, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5627, 75, 'MATCH', 89, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5629, 113, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5630, 98, 'MATCH', 92, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5631, 98, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5632, 98, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5633, 98, 'MATCH', 99, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5634, 98, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5635, 98, 'MATCH', 64, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5636, 98, 'MATCH', 59, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5637, 98, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5638, 98, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5639, 98, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5640, 98, 'MATCH', 76, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5641, 98, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5642, 98, 'MATCH', 77, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5643, 98, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5644, 98, 'MATCH', 94, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5645, 98, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5646, 98, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5647, 98, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5648, 98, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5649, 98, 'MATCH', 101, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5650, 98, 'MATCH', 60, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5651, 98, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5652, 82, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5653, 82, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5654, 82, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5230, 103, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (2728, 74, 'MATCH', 93, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4459, 73, 'MATCH', 70, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3300, 112, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5660, 113, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5655, 113, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5656, 113, 'MATCH', 65, 0, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5657, 81, 'MATCH', 98, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5658, 113, 'MATCH', 70, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5659, 81, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5661, 81, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5662, 113, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5664, 113, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5666, 95, 'BRACKETWINNER', NULL, NULL, NULL, 60, 18);
INSERT INTO public."Bet" VALUES (2951, 95, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5668, 97, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5669, 97, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5670, 97, 'MATCH', 84, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5671, 97, 'MATCH', 85, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5672, 97, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5673, 97, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5674, 97, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5677, 97, 'MATCH', 96, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4650, 119, 'MATCH', 98, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5678, 121, 'MATCH', 98, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5679, 121, 'MATCH', 99, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5680, 121, 'MATCH', 58, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5681, 121, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5682, 121, 'MATCH', 59, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5683, 121, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3153, 99, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5686, 89, 'MATCH', 76, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5688, 89, 'MATCH', 77, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5689, 89, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5690, 89, 'MATCH', 94, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5692, 89, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5694, 89, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5698, 89, 'MATCH', 66, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5699, 89, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5701, 89, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5713, 89, 'MATCH', 105, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5716, 89, 'MATCH', 108, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5717, 89, 'MATCH', 109, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5718, 89, 'MATCH', 110, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5719, 89, 'MATCH', 111, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5720, 89, 'MATCH', 112, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5628, 113, 'MATCH', 58, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5685, 89, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5684, 89, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5691, 89, 'MATCH', 88, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5663, 113, 'MATCH', 82, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5687, 89, 'MATCH', 82, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5693, 89, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5695, 89, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5697, 89, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5696, 89, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5706, 89, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5700, 89, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5703, 89, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5705, 89, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5702, 89, 'MATCH', 79, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5707, 89, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5712, 89, 'MATCH', 104, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5710, 89, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5708, 89, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5709, 89, 'MATCH', 103, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5711, 89, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5598, 77, 'MATCH', 105, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5704, 89, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5715, 89, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5714, 89, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5594, 77, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5665, 95, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (5593, 77, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5596, 77, 'MATCH', 96, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5595, 77, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5600, 77, 'MATCH', 107, 2, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5601, 77, 'MATCH', 108, 4, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5721, 89, 'MATCH', 113, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5722, 89, 'MATCH', 114, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5723, 89, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5724, 89, 'MATCH', 116, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5725, 89, 'MATCH', 117, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5726, 89, 'MATCH', 118, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5727, 89, 'MATCH', 119, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (3355, 92, 'MATCH', 98, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4533, 93, 'MATCH', 99, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5729, 107, 'MATCH', 64, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5730, 107, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5732, 106, 'MATCH', 58, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5733, 106, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5734, 106, 'MATCH', 59, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5735, 106, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5736, 106, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5737, 106, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5738, 106, 'MATCH', 76, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5739, 106, 'MATCH', 82, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5740, 106, 'MATCH', 77, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5741, 106, 'MATCH', 83, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5742, 106, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5743, 106, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5744, 106, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5745, 106, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5746, 106, 'MATCH', 100, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5747, 106, 'MATCH', 101, 0, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5748, 106, 'MATCH', 60, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5749, 106, 'MATCH', 61, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5750, 106, 'MATCH', 67, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5751, 106, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5752, 106, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5753, 106, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5754, 106, 'MATCH', 79, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5755, 106, 'MATCH', 78, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5756, 106, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5757, 106, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5758, 106, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5759, 106, 'MATCH', 85, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5760, 106, 'MATCH', 103, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5761, 106, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5762, 106, 'MATCH', 97, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5763, 106, 'MATCH', 96, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5764, 106, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5765, 106, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5766, 106, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5767, 106, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5768, 106, 'MATCH', 108, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5769, 106, 'MATCH', 109, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5770, 106, 'MATCH', 110, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5771, 106, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5772, 106, 'MATCH', 112, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5773, 106, 'MATCH', 113, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5774, 106, 'MATCH', 114, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5775, 106, 'MATCH', 115, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5776, 106, 'MATCH', 116, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5777, 106, 'MATCH', 117, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5778, 106, 'MATCH', 118, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5779, 106, 'MATCH', 119, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5667, 107, 'MATCH', 58, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5782, 115, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5849, 113, 'MATCH', 89, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5783, 96, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5785, 96, 'MATCH', 65, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5787, 96, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5788, 96, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5790, 96, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5791, 96, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5792, 96, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5793, 72, 'MATCH', 59, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5794, 72, 'MATCH', 65, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5797, 72, 'MATCH', 70, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5838, 81, 'MATCH', 59, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5789, 72, 'MATCH', 64, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5798, 72, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5800, 72, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5801, 72, 'MATCH', 82, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5802, 72, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5804, 72, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5806, 72, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5808, 72, 'MATCH', 88, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5810, 72, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5811, 72, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5812, 72, 'MATCH', 100, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5814, 72, 'MATCH', 101, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5817, 72, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5818, 72, 'MATCH', 61, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5819, 72, 'MATCH', 66, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5820, 72, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5822, 72, 'MATCH', 72, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5824, 72, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5825, 72, 'MATCH', 79, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5826, 72, 'MATCH', 78, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5827, 72, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5828, 72, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5829, 72, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5831, 72, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5832, 72, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5834, 72, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5835, 72, 'MATCH', 96, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5836, 72, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5837, 81, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5839, 81, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5784, 96, 'MATCH', 59, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5786, 96, 'MATCH', 70, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5840, 82, 'MATCH', 64, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5841, 82, 'MATCH', 59, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5842, 82, 'MATCH', 65, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5843, 82, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5844, 82, 'MATCH', 71, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5845, 82, 'MATCH', 76, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5846, 113, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5847, 113, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5848, 113, 'MATCH', 88, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5850, 113, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5852, 113, 'MATCH', 101, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5853, 113, 'MATCH', 60, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5781, 115, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5851, 113, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5728, 84, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (5731, 107, 'MATCH', 65, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5854, 107, 'MATCH', 70, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5855, 107, 'MATCH', 71, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5856, 107, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5858, 81, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5857, 81, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5859, 81, 'MATCH', 76, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3996, 78, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2826, 76, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5780, 115, 'MATCH', 70, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5860, 115, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5862, 115, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5861, 115, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5863, 107, 'MATCH', 82, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5864, 107, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5865, 107, 'MATCH', 83, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5866, 107, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5867, 107, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5868, 107, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5869, 107, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5870, 107, 'MATCH', 100, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5871, 107, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5872, 121, 'MATCH', 76, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5873, 121, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5874, 121, 'MATCH', 70, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5875, 121, 'MATCH', 71, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5876, 121, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5877, 121, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5878, 121, 'MATCH', 88, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5879, 121, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5880, 121, 'MATCH', 77, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5881, 121, 'MATCH', 83, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5882, 121, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5883, 121, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5884, 121, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5571, 77, 'MATCH', 76, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5885, 81, 'MATCH', 82, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5887, 81, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5886, 81, 'MATCH', 77, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3014, 109, 'MATCH', 82, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5195, 122, 'MATCH', 83, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5888, 122, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3033, 109, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5889, 107, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5890, 107, 'MATCH', 101, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5891, 107, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5892, 96, 'MATCH', 94, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5893, 96, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5894, 96, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3597, 102, 'MATCH', 77, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5896, 82, 'MATCH', 77, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5897, 82, 'MATCH', 83, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5898, 82, 'MATCH', 94, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5899, 82, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5900, 82, 'MATCH', 89, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5901, 82, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5902, 82, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5903, 82, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5904, 82, 'MATCH', 60, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5905, 82, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5906, 82, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5907, 82, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5016, 116, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5908, 81, 'MATCH', 94, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5910, 81, 'MATCH', 89, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5912, 113, 'MATCH', 61, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5913, 113, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5915, 113, 'MATCH', 72, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5917, 113, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5919, 113, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5920, 113, 'MATCH', 91, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4074, 88, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5921, 115, 'MATCH', 94, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5922, 115, 'MATCH', 88, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5924, 115, 'MATCH', 95, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5925, 115, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5926, 115, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5909, 81, 'MATCH', 88, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5927, 107, 'MATCH', 72, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5928, 107, 'MATCH', 73, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5929, 107, 'MATCH', 78, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5930, 107, 'MATCH', 79, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5931, 107, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5932, 107, 'MATCH', 84, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (4922, 104, 'MATCH', 100, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5923, 115, 'MATCH', 89, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5951, 96, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (2743, 74, 'MATCH', 89, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5933, 115, 'MATCH', 61, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5934, 115, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5936, 115, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5937, 115, 'MATCH', 73, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5938, 115, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5940, 115, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5935, 115, 'MATCH', 60, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5941, 107, 'MATCH', 90, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5942, 107, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5943, 81, 'MATCH', 95, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5944, 81, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5945, 81, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5946, 96, 'MATCH', 95, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5947, 96, 'MATCH', 100, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5949, 96, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5950, 96, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5952, 96, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5914, 113, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4238, 80, 'MATCH', 101, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5948, 96, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5953, 75, 'MATCH', 101, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5954, 75, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5955, 75, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5956, 75, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5957, 75, 'MATCH', 67, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5962, 75, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5963, 75, 'MATCH', 96, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5964, 75, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5959, 75, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5958, 75, 'MATCH', 73, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5961, 75, 'MATCH', 79, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5960, 75, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5965, 75, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5966, 75, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5967, 75, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5968, 75, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5969, 75, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5970, 100, 'CHAMPION', NULL, NULL, NULL, 36, NULL);
INSERT INTO public."Bet" VALUES (2693, 70, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5971, 81, 'MATCH', 60, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5972, 81, 'MATCH', 61, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5973, 81, 'MATCH', 66, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5918, 113, 'MATCH', 79, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5895, 107, 'MATCH', 67, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5939, 115, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5911, 113, 'CHAMPION', NULL, NULL, NULL, 35, NULL);
INSERT INTO public."Bet" VALUES (5974, 81, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5975, 121, 'MATCH', 60, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5976, 121, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5977, 121, 'MATCH', 67, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5978, 121, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5979, 121, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5980, 121, 'MATCH', 78, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5981, 121, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5982, 121, 'MATCH', 91, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (5983, 98, 'CHAMPION', NULL, NULL, NULL, 52, NULL);
INSERT INTO public."Bet" VALUES (5916, 113, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5984, 98, 'MATCH', 66, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5985, 98, 'MATCH', 67, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5986, 98, 'MATCH', 72, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5987, 98, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5988, 98, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5989, 98, 'MATCH', 79, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5990, 98, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5991, 98, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5992, 98, 'MATCH', 85, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5993, 98, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5994, 98, 'MATCH', 102, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (5995, 98, 'MATCH', 103, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5997, 98, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (5998, 98, 'MATCH', 96, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (5999, 113, 'MATCH', 84, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6000, 113, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6001, 113, 'MATCH', 103, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6002, 113, 'MATCH', 102, 2, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (6003, 113, 'MATCH', 96, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6004, 113, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3684, 101, 'MATCH', 66, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6005, 115, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6006, 115, 'MATCH', 84, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6007, 115, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6008, 115, 'MATCH', 85, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3173, 99, 'MATCH', 72, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6009, 96, 'MATCH', 73, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6010, 96, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6011, 96, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6012, 96, 'MATCH', 79, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6013, 82, 'MATCH', 73, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6014, 82, 'MATCH', 72, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6015, 82, 'MATCH', 78, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6016, 82, 'MATCH', 79, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6017, 82, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6018, 82, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6019, 82, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6020, 82, 'MATCH', 85, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6021, 82, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6022, 82, 'MATCH', 103, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6023, 82, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6024, 82, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6025, 81, 'MATCH', 73, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6026, 81, 'MATCH', 72, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6027, 111, 'MATCH', 105, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6028, 111, 'MATCH', 106, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6029, 101, 'MATCH', 105, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6030, 101, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6032, 81, 'MATCH', 78, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6033, 81, 'MATCH', 79, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6036, 107, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6037, 107, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6038, 107, 'MATCH', 96, 2, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6039, 107, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6040, 107, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6041, 107, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4188, 90, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6042, 96, 'MATCH', 91, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6043, 96, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6044, 96, 'MATCH', 85, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6045, 96, 'MATCH', 84, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6046, 96, 'MATCH', 102, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6048, 96, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6049, 96, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6047, 96, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6051, 115, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6052, 115, 'MATCH', 97, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6053, 115, 'MATCH', 96, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6054, 111, 'MATCH', 104, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6055, 111, 'MATCH', 107, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6050, 115, 'MATCH', 103, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6056, 121, 'MATCH', 90, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6058, 121, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6057, 121, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6060, 92, 'MATCH', 105, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6061, 92, 'MATCH', 106, 5, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (5589, 77, 'MATCH', 90, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6063, 123, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6064, 123, 'MATCH', 105, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6065, 123, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6066, 123, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6067, 81, 'MATCH', 90, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6068, 81, 'MATCH', 91, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6069, 81, 'MATCH', 85, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6070, 81, 'MATCH', 84, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6071, 107, 'MATCH', 104, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6072, 107, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6073, 79, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6074, 79, 'MATCH', 105, 5, 6, NULL, NULL);
INSERT INTO public."Bet" VALUES (6075, 79, 'MATCH', 106, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6076, 79, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (4565, 93, 'MATCH', 97, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6077, 75, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6099, 82, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6079, 75, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6080, 75, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (3499, 83, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6081, 115, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6083, 115, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6085, 113, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6086, 113, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6088, 113, 'MATCH', 107, 5, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6089, 81, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6091, 81, 'MATCH', 96, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6092, 81, 'MATCH', 97, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6093, 82, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6094, 82, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6095, 82, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6096, 82, 'MATCH', 107, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6097, 82, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6098, 82, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6100, 82, 'MATCH', 111, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6101, 97, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6059, 92, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6034, 95, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6082, 115, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6084, 115, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6078, 75, 'MATCH', 105, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6087, 113, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6035, 95, 'MATCH', 106, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6062, 92, 'MATCH', 107, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6102, 97, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6103, 97, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6104, 97, 'MATCH', 107, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6105, 121, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6106, 121, 'MATCH', 103, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6121, 90, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6107, 121, 'MATCH', 96, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6108, 121, 'MATCH', 97, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6090, 81, 'MATCH', 102, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6109, 123, 'CHAMPION', NULL, NULL, NULL, 37, NULL);
INSERT INTO public."Bet" VALUES (6110, 94, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6111, 94, 'MATCH', 105, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6112, 94, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6113, 94, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6114, 94, 'MATCH', 108, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6115, 94, 'MATCH', 110, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6116, 90, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6117, 90, 'MATCH', 105, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6118, 90, 'MATCH', 106, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6119, 90, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6120, 86, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6124, 86, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6125, 86, 'MATCH', 107, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6126, 86, 'MATCH', 108, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6127, 86, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6128, 108, 'CHAMPION', NULL, NULL, NULL, 46, NULL);
INSERT INTO public."Bet" VALUES (6131, 95, 'MATCH', 110, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6129, 95, 'MATCH', 104, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6130, 95, 'MATCH', 107, 4, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6132, 95, 'MATCH', 108, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6133, 113, 'MATCH', 108, 6, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (6134, 69, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6135, 69, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6136, 69, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6137, 69, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6138, 69, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6139, 69, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (3627, 102, 'MATCH', 110, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6140, 78, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6145, 92, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6146, 92, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6147, 113, 'MATCH', 110, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6148, 107, 'MATCH', 108, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6149, 107, 'MATCH', 110, 5, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6150, 107, 'MATCH', 109, 4, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6151, 107, 'MATCH', 111, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6152, 115, 'MATCH', 108, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6153, 115, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6154, 84, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6155, 84, 'MATCH', 105, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6157, 84, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6156, 84, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6158, 84, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6159, 84, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6160, 75, 'MATCH', 108, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6161, 75, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6162, 99, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6164, 99, 'MATCH', 106, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6165, 99, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6166, 99, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6167, 99, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6168, 101, 'MATCH', 107, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6169, 101, 'MATCH', 108, 4, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6170, 101, 'MATCH', 110, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6171, 119, 'MATCH', 104, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6172, 121, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6173, 121, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6174, 97, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6175, 97, 'MATCH', 110, 1, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6176, 121, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6177, 121, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6178, 121, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6179, 99, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6180, 99, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6181, 101, 'MATCH', 104, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6182, 101, 'MATCH', 109, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6183, 101, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6184, 92, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6185, 92, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6186, 121, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (2895, 91, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6187, 94, 'MATCH', 109, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6188, 94, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6189, 94, 'MATCH', 112, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6190, 94, 'MATCH', 113, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6191, 94, 'MATCH', 114, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6192, 94, 'MATCH', 115, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6193, 94, 'MATCH', 116, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6194, 94, 'MATCH', 117, 0, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6195, 94, 'MATCH', 118, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6196, 94, 'MATCH', 119, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6197, 75, 'MATCH', 109, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6198, 75, 'MATCH', 111, 2, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6199, 72, 'MATCH', 104, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6200, 72, 'MATCH', 105, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6201, 72, 'MATCH', 106, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6202, 72, 'MATCH', 107, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6203, 72, 'MATCH', 108, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6204, 72, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6205, 72, 'MATCH', 110, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6206, 72, 'MATCH', 111, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6207, 95, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6208, 95, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6209, 90, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6210, 90, 'MATCH', 111, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6123, 90, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6211, 12, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6212, 12, 'MATCH', 105, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6213, 12, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6214, 12, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6215, 12, 'MATCH', 108, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6216, 12, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6217, 12, 'MATCH', 110, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6218, 12, 'MATCH', 111, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (4725, 70, 'MATCH', 106, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6219, 111, 'MATCH', 108, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6220, 111, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6221, 111, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6222, 111, 'MATCH', 111, 1, 3, NULL, NULL);
INSERT INTO public."Bet" VALUES (6223, 108, 'MATCH', 104, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6224, 108, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6225, 108, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6226, 108, 'MATCH', 107, 3, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6227, 97, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6228, 97, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6229, 96, 'MATCH', 104, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6230, 96, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6231, 76, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (6232, 102, 'CHAMPION', NULL, NULL, NULL, 59, NULL);
INSERT INTO public."Bet" VALUES (6142, 78, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6143, 78, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6144, 78, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6163, 99, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6122, 86, 'MATCH', 105, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (4489, 73, 'MATCH', 106, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (3118, 105, 'MATCH', 110, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6233, 83, 'CHAMPION', NULL, NULL, NULL, 48, NULL);
INSERT INTO public."Bet" VALUES (3047, 109, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6234, 96, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6235, 96, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6236, 119, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6237, 119, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6238, 119, 'MATCH', 107, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6239, 119, 'MATCH', 108, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6240, 119, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6241, 119, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6242, 119, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6141, 78, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6243, 78, 'MATCH', 109, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6244, 78, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6245, 78, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6246, 81, 'MATCH', 105, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6247, 113, 'MATCH', 109, 3, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6248, 113, 'MATCH', 111, 6, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (6249, 115, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6250, 115, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6251, 69, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6252, 69, 'MATCH', 111, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6253, 81, 'MATCH', 106, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6254, 81, 'MATCH', 107, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6255, 81, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6256, 81, 'MATCH', 109, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6257, 96, 'MATCH', 108, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6258, 96, 'MATCH', 109, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6259, 96, 'MATCH', 110, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6260, 96, 'MATCH', 111, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6261, 121, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6262, 121, 'MATCH', 110, 1, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6263, 121, 'MATCH', 111, 0, 2, NULL, NULL);
INSERT INTO public."Bet" VALUES (6264, 79, 'MATCH', 108, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6265, 79, 'MATCH', 109, 4, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6266, 79, 'MATCH', 110, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6267, 79, 'MATCH', 111, 5, 6, NULL, NULL);
INSERT INTO public."Bet" VALUES (6268, 79, 'MATCH', 112, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6269, 79, 'MATCH', 113, 6, 4, NULL, NULL);
INSERT INTO public."Bet" VALUES (6270, 79, 'MATCH', 114, 0, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6271, 79, 'MATCH', 115, 1, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6272, 108, 'MATCH', 108, 2, 1, NULL, NULL);
INSERT INTO public."Bet" VALUES (6273, 108, 'MATCH', 109, 3, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6274, 108, 'MATCH', 110, 2, 0, NULL, NULL);
INSERT INTO public."Bet" VALUES (6275, 108, 'MATCH', 111, 1, 2, NULL, NULL);


--
-- TOC entry 2341 (class 0 OID 0)
-- Dependencies: 186
-- Name: Bet_betId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Bet_betId_seq"', 6275, true);


--
-- TOC entry 2299 (class 0 OID 16582)
-- Dependencies: 187
-- Data for Name: Betgroup; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Betgroup" VALUES (1, 'FREUNDE', 'Freunde');
INSERT INTO public."Betgroup" VALUES (2, 'KOLLEGEN', 'Kollegen');
INSERT INTO public."Betgroup" VALUES (3, 'RANDOM', 'Zufall');


--
-- TOC entry 2342 (class 0 OID 0)
-- Dependencies: 188
-- Name: Betgroup_betgroupId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Betgroup_betgroupId_seq"', 3, true);


--
-- TOC entry 2301 (class 0 OID 16588)
-- Dependencies: 189
-- Data for Name: Bracket; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Bracket" VALUES (1, 'A', 'Gruppe A', 1);
INSERT INTO public."Bracket" VALUES (2, 'B', 'Gruppe B', 1);
INSERT INTO public."Bracket" VALUES (3, 'C', 'Gruppe C', 1);
INSERT INTO public."Bracket" VALUES (4, 'D', 'Gruppe D', 1);
INSERT INTO public."Bracket" VALUES (5, 'E', 'Gruppe E', 1);
INSERT INTO public."Bracket" VALUES (6, 'F', 'Gruppe F', 1);
INSERT INTO public."Bracket" VALUES (17, 'G', 'Gruppe G', 1);
INSERT INTO public."Bracket" VALUES (18, 'H', 'Gruppe H', 1);


--
-- TOC entry 2302 (class 0 OID 16592)
-- Dependencies: 190
-- Data for Name: BracketTeam; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."BracketTeam" VALUES (33, 1, 32);
INSERT INTO public."BracketTeam" VALUES (34, 1, 33);
INSERT INTO public."BracketTeam" VALUES (35, 1, 34);
INSERT INTO public."BracketTeam" VALUES (36, 1, 35);
INSERT INTO public."BracketTeam" VALUES (37, 2, 36);
INSERT INTO public."BracketTeam" VALUES (38, 2, 37);
INSERT INTO public."BracketTeam" VALUES (39, 2, 38);
INSERT INTO public."BracketTeam" VALUES (40, 2, 39);
INSERT INTO public."BracketTeam" VALUES (41, 3, 40);
INSERT INTO public."BracketTeam" VALUES (42, 3, 41);
INSERT INTO public."BracketTeam" VALUES (43, 3, 42);
INSERT INTO public."BracketTeam" VALUES (44, 3, 43);
INSERT INTO public."BracketTeam" VALUES (45, 4, 44);
INSERT INTO public."BracketTeam" VALUES (46, 4, 45);
INSERT INTO public."BracketTeam" VALUES (47, 4, 46);
INSERT INTO public."BracketTeam" VALUES (48, 4, 47);
INSERT INTO public."BracketTeam" VALUES (49, 5, 48);
INSERT INTO public."BracketTeam" VALUES (50, 5, 49);
INSERT INTO public."BracketTeam" VALUES (51, 5, 50);
INSERT INTO public."BracketTeam" VALUES (52, 5, 51);
INSERT INTO public."BracketTeam" VALUES (53, 6, 52);
INSERT INTO public."BracketTeam" VALUES (54, 6, 53);
INSERT INTO public."BracketTeam" VALUES (55, 6, 54);
INSERT INTO public."BracketTeam" VALUES (56, 6, 55);
INSERT INTO public."BracketTeam" VALUES (57, 17, 56);
INSERT INTO public."BracketTeam" VALUES (58, 17, 57);
INSERT INTO public."BracketTeam" VALUES (59, 17, 58);
INSERT INTO public."BracketTeam" VALUES (60, 17, 59);
INSERT INTO public."BracketTeam" VALUES (61, 18, 60);
INSERT INTO public."BracketTeam" VALUES (62, 18, 61);
INSERT INTO public."BracketTeam" VALUES (63, 18, 62);
INSERT INTO public."BracketTeam" VALUES (64, 18, 63);


--
-- TOC entry 2343 (class 0 OID 0)
-- Dependencies: 198
-- Name: BracketTeam_bracketTeamId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."BracketTeam_bracketTeamId_seq"', 64, true);


--
-- TOC entry 2344 (class 0 OID 0)
-- Dependencies: 200
-- Name: Bracket_bracketId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Bracket_bracketId_seq"', 18, true);


--
-- TOC entry 2307 (class 0 OID 16633)
-- Dependencies: 201
-- Data for Name: Phase; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Phase" VALUES (1, 'Gruppe', 'Gruppenphase', '2018-06-14 17:00:00', true);
INSERT INTO public."Phase" VALUES (2, 'Achtel', 'Achtelfinale', '2018-06-30 16:00:00', false);
INSERT INTO public."Phase" VALUES (3, 'Viertel', 'Viertelfinale', '2018-07-06 16:00:00', false);
INSERT INTO public."Phase" VALUES (4, 'Halb', 'Halbfinale', '2018-07-10 20:00:00', false);
INSERT INTO public."Phase" VALUES (5, 'Finale', 'Finale', '2018-07-15 17:00:00', false);
INSERT INTO public."Phase" VALUES (9, 'Platz3', 'Spiel um Platz 3', '2018-07-14 16:00:00', false);


--
-- TOC entry 2345 (class 0 OID 0)
-- Dependencies: 202
-- Name: Phase_phaseId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Phase_phaseId_seq"', 9, true);


--
-- TOC entry 2309 (class 0 OID 16640)
-- Dependencies: 203
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Role" VALUES (1, 'ADMIN', 'Administrator');
INSERT INTO public."Role" VALUES (5, 'TIPPADMIN', 'Tipp-Administrator');


--
-- TOC entry 2346 (class 0 OID 0)
-- Dependencies: 204
-- Name: Role_roleId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Role_roleId_seq"', 15, true);


--
-- TOC entry 2303 (class 0 OID 16595)
-- Dependencies: 191
-- Data for Name: SoccerMatch; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."SoccerMatch" VALUES (112, 3, '2018-07-06 16:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (113, 3, '2018-07-06 20:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (114, 3, '2018-07-07 16:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (115, 3, '2018-07-07 20:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (116, 4, '2018-07-10 20:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (117, 4, '2018-07-11 20:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (118, 9, '2018-07-14 16:00:00', 64, 64, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (119, 5, '2018-07-15 17:00:00', 64, 64, NULL, NULL, true);
INSERT INTO public."SoccerMatch" VALUES (91, 1, '2018-06-27 16:00:00', 55, 52, 2, 0, false);
INSERT INTO public."SoccerMatch" VALUES (85, 1, '2018-06-27 20:00:00', 49, 50, 2, 2, false);
INSERT INTO public."SoccerMatch" VALUES (56, 1, '2018-06-14 17:00:00', 32, 33, 5, 0, false);
INSERT INTO public."SoccerMatch" VALUES (57, 1, '2018-06-15 14:00:00', 34, 35, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (62, 1, '2018-06-15 17:00:00', 38, 39, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (63, 1, '2018-06-15 20:00:00', 36, 37, 3, 3, false);
INSERT INTO public."SoccerMatch" VALUES (68, 1, '2018-06-16 12:00:00', 40, 41, 2, 1, false);
INSERT INTO public."SoccerMatch" VALUES (74, 1, '2018-06-16 15:00:00', 44, 45, 1, 1, false);
INSERT INTO public."SoccerMatch" VALUES (69, 1, '2018-06-16 18:00:00', 42, 43, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (75, 1, '2018-06-16 21:00:00', 46, 47, 2, 0, false);
INSERT INTO public."SoccerMatch" VALUES (80, 1, '2018-06-17 14:00:00', 50, 51, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (86, 1, '2018-06-17 17:00:00', 52, 53, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (81, 1, '2018-06-17 20:00:00', 48, 49, 1, 1, false);
INSERT INTO public."SoccerMatch" VALUES (87, 1, '2018-06-18 14:00:00', 54, 55, 1, 0, false);
INSERT INTO public."SoccerMatch" VALUES (92, 1, '2018-06-18 17:00:00', 56, 57, 3, 0, false);
INSERT INTO public."SoccerMatch" VALUES (93, 1, '2018-06-18 20:00:00', 58, 59, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (98, 1, '2018-06-19 14:00:00', 62, 63, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (84, 1, '2018-06-27 20:00:00', 51, 48, 0, 2, false);
INSERT INTO public."SoccerMatch" VALUES (99, 1, '2018-06-19 17:00:00', 60, 61, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (58, 1, '2018-06-19 20:00:00', 32, 34, 3, 1, false);
INSERT INTO public."SoccerMatch" VALUES (64, 1, '2018-06-20 14:00:00', 36, 38, 1, 0, false);
INSERT INTO public."SoccerMatch" VALUES (59, 1, '2018-06-20 17:00:00', 35, 33, 1, 0, false);
INSERT INTO public."SoccerMatch" VALUES (65, 1, '2018-06-20 20:00:00', 39, 37, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (70, 1, '2018-06-21 14:00:00', 43, 41, 1, 1, false);
INSERT INTO public."SoccerMatch" VALUES (71, 1, '2018-06-21 17:00:00', 40, 42, 1, 0, false);
INSERT INTO public."SoccerMatch" VALUES (76, 1, '2018-06-21 20:00:00', 44, 46, 0, 3, false);
INSERT INTO public."SoccerMatch" VALUES (82, 1, '2018-06-22 14:00:00', 48, 50, 2, 0, false);
INSERT INTO public."SoccerMatch" VALUES (77, 1, '2018-06-22 17:00:00', 47, 45, 2, 0, false);
INSERT INTO public."SoccerMatch" VALUES (83, 1, '2018-06-22 20:00:00', 51, 49, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (94, 1, '2018-06-23 14:00:00', 56, 58, 5, 2, false);
INSERT INTO public."SoccerMatch" VALUES (88, 1, '2018-06-23 17:00:00', 55, 53, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (89, 1, '2018-06-23 20:00:00', 52, 54, 2, 1, false);
INSERT INTO public."SoccerMatch" VALUES (95, 1, '2018-06-24 14:00:00', 59, 57, 6, 1, false);
INSERT INTO public."SoccerMatch" VALUES (100, 1, '2018-06-24 17:00:00', 63, 61, 2, 2, false);
INSERT INTO public."SoccerMatch" VALUES (108, 2, '2018-07-02 16:00:00', 48, 53, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (101, 1, '2018-06-24 20:00:00', 60, 62, 0, 3, false);
INSERT INTO public."SoccerMatch" VALUES (60, 1, '2018-06-25 16:00:00', 35, 32, 3, 0, false);
INSERT INTO public."SoccerMatch" VALUES (61, 1, '2018-06-25 16:00:00', 33, 34, 2, 1, false);
INSERT INTO public."SoccerMatch" VALUES (110, 2, '2018-07-03 16:00:00', 54, 49, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (102, 1, '2018-06-28 16:00:00', 61, 62, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (66, 1, '2018-06-25 20:00:00', 37, 38, 2, 2, false);
INSERT INTO public."SoccerMatch" VALUES (67, 1, '2018-06-25 20:00:00', 39, 36, 1, 1, false);
INSERT INTO public."SoccerMatch" VALUES (73, 1, '2018-06-26 16:00:00', 41, 42, 0, 2, false);
INSERT INTO public."SoccerMatch" VALUES (72, 1, '2018-06-26 16:00:00', 43, 40, 0, 0, false);
INSERT INTO public."SoccerMatch" VALUES (103, 1, '2018-06-28 16:00:00', 63, 60, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (96, 1, '2018-06-28 20:00:00', 59, 56, 0, 1, false);
INSERT INTO public."SoccerMatch" VALUES (78, 1, '2018-06-26 20:00:00', 45, 46, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (79, 1, '2018-06-26 20:00:00', 47, 44, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (107, 2, '2018-07-01 20:00:00', 46, 43, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (90, 1, '2018-06-27 16:00:00', 53, 54, 0, 3, false);
INSERT INTO public."SoccerMatch" VALUES (97, 1, '2018-06-28 20:00:00', 57, 58, 1, 2, false);
INSERT INTO public."SoccerMatch" VALUES (109, 2, '2018-07-02 20:00:00', 56, 63, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (111, 2, '2018-07-03 20:00:00', 62, 59, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (104, 2, '2018-06-30 16:00:00', 40, 44, 4, 3, false);
INSERT INTO public."SoccerMatch" VALUES (105, 2, '2018-06-30 20:00:00', 35, 36, 2, 1, false);
INSERT INTO public."SoccerMatch" VALUES (106, 2, '2018-07-01 16:00:00', 37, 32, 3, 4, false);


--
-- TOC entry 2347 (class 0 OID 0)
-- Dependencies: 207
-- Name: SoccerMatch_matchId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."SoccerMatch_matchId_seq"', 119, true);


--
-- TOC entry 2304 (class 0 OID 16599)
-- Dependencies: 192
-- Data for Name: Team; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Team" VALUES (32, 'Russland', 'Russland');
INSERT INTO public."Team" VALUES (33, 'Saudi Arabien', 'Saudi Arabien');
INSERT INTO public."Team" VALUES (34, 'Ägypten', 'Ägypten');
INSERT INTO public."Team" VALUES (35, 'Uruguay', 'Uruguay');
INSERT INTO public."Team" VALUES (36, 'Portugal', 'Portugal');
INSERT INTO public."Team" VALUES (37, 'Spanien', 'Spanien');
INSERT INTO public."Team" VALUES (38, 'Marokko', 'Marokko');
INSERT INTO public."Team" VALUES (39, 'Iran', 'Iran');
INSERT INTO public."Team" VALUES (40, 'Frankreich', 'Frankreich');
INSERT INTO public."Team" VALUES (41, 'Australien', 'Australien');
INSERT INTO public."Team" VALUES (42, 'Peru', 'Peru');
INSERT INTO public."Team" VALUES (43, 'Dänemark', 'Dänemark');
INSERT INTO public."Team" VALUES (44, 'Argentinien', 'Argentinien');
INSERT INTO public."Team" VALUES (45, 'Island', 'Island');
INSERT INTO public."Team" VALUES (46, 'Kroatien', 'Kroatien');
INSERT INTO public."Team" VALUES (47, 'Nigeria', 'Nigeria');
INSERT INTO public."Team" VALUES (48, 'Brasilien', 'Brasilien');
INSERT INTO public."Team" VALUES (49, 'Schweiz', 'Schweiz');
INSERT INTO public."Team" VALUES (50, 'Costa Rica', 'Costa Rica');
INSERT INTO public."Team" VALUES (51, 'Serbien', 'Serbien');
INSERT INTO public."Team" VALUES (52, 'Deutschland', 'Deutschland');
INSERT INTO public."Team" VALUES (53, 'Mexiko', 'Mexiko');
INSERT INTO public."Team" VALUES (54, 'Schweden', 'Schweden');
INSERT INTO public."Team" VALUES (55, 'Südkorea', 'Südkorea');
INSERT INTO public."Team" VALUES (56, 'Belgien', 'Belgien');
INSERT INTO public."Team" VALUES (57, 'Panama', 'Panama');
INSERT INTO public."Team" VALUES (58, 'Tunesien', 'Tunesien');
INSERT INTO public."Team" VALUES (59, 'England', 'England');
INSERT INTO public."Team" VALUES (60, 'Polen', 'Polen');
INSERT INTO public."Team" VALUES (61, 'Senegal', 'Senegal');
INSERT INTO public."Team" VALUES (62, 'Kolumbien', 'Kolumbien');
INSERT INTO public."Team" VALUES (63, 'Japan', 'Japan');
INSERT INTO public."Team" VALUES (64, 'Unbekannt', 'Unbekannt');


--
-- TOC entry 2348 (class 0 OID 0)
-- Dependencies: 208
-- Name: Team_teamId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Team_teamId_seq"', 64, true);


--
-- TOC entry 2313 (class 0 OID 16662)
-- Dependencies: 210
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."User" VALUES (1, 'admin', 'MMlgnn0mae3x4RfiCyk3mVFVIEZ/+3Hr', 'Mustermann', 'Manfred', 'fxeller@delmak.de', 'flHHsoOjrB6r', false);
INSERT INTO public."User" VALUES (72, 'blocher', 'HVjlxKc8O/cXl1M2be47debfj7Ev68FV', 'Locher', 'Bernd', 'locher.be@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (69, 'kvanmeel', 'maIydAm8Hi255IjpOYFpU0oLroD07hU6', 'van Meel', 'Koos', 'koos.vanmeel@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (107, 'slamp', 'qLE/Qbo0m1V0dt5VVGvQXht/SYgNIZcX', 'Lamp', 'Stefan', 'stefan.lamp@gmx.net', NULL, true);
INSERT INTO public."User" VALUES (122, 'kxeller', 'UUk1PBe1WK2TEjpOalsY+HLbrR5Ke7oM', 'Xeller', 'Katrin', 'superkaedder@web.de', '2tqp3j9wrL9K', false);
INSERT INTO public."User" VALUES (80, 'sgutmacher', 'QKUIE3VLT7zr/AkvVr2zX/InBfIijWS1', 'Gutmacher', 'Sergej', 's.gutmacher@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (92, 'pstadler', '8aZcjVx8imAn7aG9x6UR0Kvp5bC3FzBd', 'Stadler', 'Peter', 'peter.stadler@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (94, 'uliebing', '6sdnLBEVaZGgHZyXI4bQ2kpACSsTAhFT', 'Liebing', 'Uli', 'ulrich.liebing@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (90, 'fkolaska', '006eitl4Lx4jhbp59bhFVs1bBEPp0GBm', 'Kolaska', 'Fabian', 'fabian.kolaska@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (93, 'tschreiber', 'vrcsk1WUBxdZGwbVUrlgxR3jRvqP3Y9Y', 'Schreiber', 'Tatjana', 'tatjana.schreiber@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (101, 'eschmid', 'kMizgu0UcXh4f1OUp9xxTdyWptvBJTSp', 'Schmid', 'Elmar', 'elmar.schmid@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (112, 'cgoettel', 'z0ilQqAC+l9cgjX6tj3PCCciZozLn+pA', 'Göttel', 'Christian', 'christian.goettel@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (89, 'nbartel', '/sBIIWopaWROrpRl6lhKSf5wxMIdy9xk', 'Bartel', 'Natalie', 'natalie.bartel@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (123, 'jhasenmaile', '6mJqgvEaPeqDyxWPlahiCCEcal2/us57', 'Hasenmaile', 'Jonas', 'jonashasenmaile99@web.de', NULL, true);
INSERT INTO public."User" VALUES (91, 'bnessler', 'cBsIFGnl9WQ/ItyHZneVkGv/zSS0QRIo', 'Nessler', 'Bernhard', 'bernhard.nessler@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (84, 'cfrohnhoefer', 'RXWjPt1owq6tYvxtDncT/JOyPuXClCGc', 'Frohnhöfer', 'Christoph', 'christoph.frohnhoefer@cgm.com', 'kNaSF4VrPPMZ', true);
INSERT INTO public."User" VALUES (71, 'slocher', 'sRRxKac5JztspiHA51Weatw3QrMEpk/U', 'Locher', 'Simone', 'simonelocher@gmx.de', 'aDiCTnpEqmFy', true);
INSERT INTO public."User" VALUES (119, 'jkrebs', 'vNSHzmrk3eazp8Yh+wqSEsq55D+S8+pY', 'Krebs', 'Jan', 'jan.krebs@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (83, 'zaskovic', 'A2kdMHujNzeE0vDQsD1YmfWHW/tlZ/aB', 'Askovic', 'Zoran', 'zaskovic@yahoo.com', NULL, true);
INSERT INTO public."User" VALUES (81, 'croesch', '0Tn97sOVof3wjXHDd9s3NkXHkeRnegND', 'Rösch', 'Claudia', 'claudia.roesch@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (87, 'sgrossdoepfer', 'n//V/3uIkNRcivMb1Lc5gXbqNY5ApjAu', 'Gross-Doepfer', 'Sabine', 'sabine.gross-doepfer@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (102, 'umader', 'oVfwKg3GeZw3K6hnHhjwkJrLngBl9cCc', 'Mader', 'Ute', 'Ute_Mader@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (96, 'jwagner', 'C9U6RhlVPi8Eg4aWLU1Q66vCcfO4//NU', 'Wagner', 'Julia', 'jula.w@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (98, 'skoch', 'BkOOJUBqvZ1F1m5l3WmbHSJi22gD13Ug', 'Koch', 'Steffen', 'steffen.koch@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (97, 'thepp', 'g7ZzKY6oKhH3PBFY3OkAgfuCZpOgWdDc', 'Hepp', 'Tamara', 'tamara.hepp@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (78, 'smaier', 'CCge/Xk3ySHAau5YUqBr2w3wy9ffVq3V', 'Maier', 'Sonja', 'sonja.maier@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (103, 'stympel', 'JZaUpuy9VWQ6iEEE1n3o22C2ob2pRx+f', 'Tympel', 'Stephen', 'stephen.tympel@web.de', 'tFlJORDRUFX0', true);
INSERT INTO public."User" VALUES (74, 'pniederberger', 'CHDak0ScDcCcXbfjBvx2RxKV2rDtvxv5', 'Niederberger', 'Patrick', 'p.niederberger@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (109, 'wmader', 'yT5x2qQ1RL998bU5fX44VCDXnU0Lc5PD', 'Mader', 'Wolfgang', 'wolfgang@mad3r.de', 'yFwoUYMkdBgD', true);
INSERT INTO public."User" VALUES (105, 'mmader', 'uTsj7eLsHF8e6pH0QoK2ByZjcy01a+EZ', 'Mader', 'Malenka', 'malenka.killmann@web.de', 'fXF9h2x4EgUl', true);
INSERT INTO public."User" VALUES (114, 'sweinmann', 'ecXETM/Uk9MiWJ4AN8ArwdyH1jIaCAmE', 'Weinmann', 'Stefan', 'stefan.weinmann@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (95, 'mhaumayr', 'NO2ybqgX/nUTJngF/3ZeKvs2hG2AerGX', 'Haumayr', 'Manfred', 'manfred.haumayr@t-online.de', NULL, true);
INSERT INTO public."User" VALUES (99, 'dadam', 'YS0Bx4VFsTM7RSYEYe40F/hWvc3m5t1o', 'Adam', 'Diana', 'diana.adam@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (76, 'bmader', 'PcH+NWcW1OVxsMALCdGcNZSmGtEyepbF', 'Mader', 'Bruno', 'Dr.Mader@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (85, 'sspiess', 'DA1sm9HXGapnsLnuh/q5fU1VKuIeSg47', 'Spieß', 'Sarah', 'spiesssarah@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (116, 'tlang', 'QP6ic9nC19wsCbX2BAqdM20w7EQY/UiT', 'Lang', 'Tanja', 'tanja.lang@cgm.com', 'rPiSmnggIMf2', true);
INSERT INTO public."User" VALUES (73, 'kniederberger', 'hgNzGlsIa6CwFS8S/GKDo3IPGvwVxpIS', 'Niederberger', 'Katja', 'katja_niederberger@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (79, 'gjost', '0dB4nskEuDym4cvMMuHrHPjpJeUxrCgz', 'Jost', 'Gerhard', 'gerhard.jost@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (110, 'jmusch', 'pwLbiu+6Ta0ev/+PFoJF3cFRqUcwohgO', 'Musch', 'Johannes', 'johannes.musch@web.de', NULL, true);
INSERT INTO public."User" VALUES (86, 'hwinnebeck', 'NqqbfEIC/ej52/1vx+YumjUVxM1yWS49', 'Winnebeck', 'Heiko', 'heiko.winnebeck@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (113, 'mglaserzacharias', 'SSGlPRv/Tnka6BHIdg5KeQWKvbGQWjO4', 'Glaser-Zacharias', 'Marlene', 'marlene.glaser-zacharias@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (111, 'rbeckerkessler', 'KOp446dZn0MqcT2py2qes+nuplI4Mjtz', 'Becker-Kessler', 'Ralf', 'ralf.becker-kessler@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (115, 'shefele', 'yPZRSCjKtwJEO7b4u8gHAJ3o+SMS6nDs', 'Hefele', 'Siglinde', 'siglinde.hefele@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (88, 'swuerstle', '1BsZLGNV+SbohClfhjeeUwX4NLfHbqWl', 'Würstle', 'Stefanie', 'stefanie.wuerstle@outlook.de', NULL, true);
INSERT INTO public."User" VALUES (77, 'dbirkholz', 'PMgaQ+5suQ6yNCLpz15+4svbkN2csPsJ', 'Birkholz', 'Doro', 'dorothee.birkholz@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (104, 'ktympel', 'ZB4rhk5TuMm8i9HOcACrHXdB9V/968fJ', 'Tympel', 'Karsten', 'karsten.tympel@web.de', NULL, true);
INSERT INTO public."User" VALUES (106, 'alamp', 'RfmKZZolA6iHXmzUtLm9BgQ91BBUh3RB', 'Lamp', 'Andrea', 'info@andrea-lamp.com', NULL, true);
INSERT INTO public."User" VALUES (121, 'mfritz', 'ooYnU9z7cP8TbZId4mEhMVHFu0eAew5J', 'Fritz', 'Michael', 'michael.fritz@cgm.com', 'vxIwDAivVlY1', false);
INSERT INTO public."User" VALUES (75, 'cvoelkle', 'rbUyhbUD3QTsjTWHc+cz76TNGdsT5nGA', 'Völkle', 'Christof', 'chris@sonation.de', NULL, true);
INSERT INTO public."User" VALUES (108, 'gbaur', 'iADfowGlB146Y+6ZsVD0+sskl1e/HY0Y', 'Baur', 'Gerhard', 'gerhard.baur@cgm.com', NULL, true);
INSERT INTO public."User" VALUES (82, 'bnickel', 'XOcByzxzsiORQ+bk01QwmFtJmxEAw7Zi', 'Nickel', 'Brigitte', 'brigitte.nickel@cgm.com', NULL, false);
INSERT INTO public."User" VALUES (12, 'fxeller', 'QsI3Nu6oD2M2BDNOyvcidtGT4sjpvtXa', 'Xeller', 'Florian', 'fxeller@delmak.de', NULL, true);
INSERT INTO public."User" VALUES (100, 'epizel', 'jSS+lPM1cKm3jnsXdUZW6Gfk7a1wtymZ', 'Pizel', 'Evelyn', 'evelyn.pizel@cgm.com', NULL, false);
INSERT INTO public."User" VALUES (70, 'smader', 'LXGgWROc/a7MeIQe11mbJhdvOuSSMGkm', 'Mader', 'Susanne', 'susi_mader@gmx.de', NULL, true);
INSERT INTO public."User" VALUES (120, 'rUser', 'PjM4M3kw3e1//Lv3bWShrFTGtSvBuUNL', 'User', 'Random', 'fxeller@delmak.de', NULL, true);


--
-- TOC entry 2314 (class 0 OID 16675)
-- Dependencies: 212
-- Data for Name: UserBetgroup; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."UserBetgroup" VALUES (61, 69, 1);
INSERT INTO public."UserBetgroup" VALUES (63, 71, 1);
INSERT INTO public."UserBetgroup" VALUES (64, 72, 1);
INSERT INTO public."UserBetgroup" VALUES (65, 73, 1);
INSERT INTO public."UserBetgroup" VALUES (66, 74, 1);
INSERT INTO public."UserBetgroup" VALUES (67, 75, 1);
INSERT INTO public."UserBetgroup" VALUES (68, 76, 1);
INSERT INTO public."UserBetgroup" VALUES (69, 77, 2);
INSERT INTO public."UserBetgroup" VALUES (70, 78, 2);
INSERT INTO public."UserBetgroup" VALUES (71, 79, 2);
INSERT INTO public."UserBetgroup" VALUES (72, 80, 2);
INSERT INTO public."UserBetgroup" VALUES (73, 81, 2);
INSERT INTO public."UserBetgroup" VALUES (75, 83, 2);
INSERT INTO public."UserBetgroup" VALUES (76, 84, 2);
INSERT INTO public."UserBetgroup" VALUES (77, 85, 2);
INSERT INTO public."UserBetgroup" VALUES (78, 86, 2);
INSERT INTO public."UserBetgroup" VALUES (80, 88, 2);
INSERT INTO public."UserBetgroup" VALUES (81, 89, 2);
INSERT INTO public."UserBetgroup" VALUES (82, 90, 2);
INSERT INTO public."UserBetgroup" VALUES (83, 91, 2);
INSERT INTO public."UserBetgroup" VALUES (84, 92, 2);
INSERT INTO public."UserBetgroup" VALUES (85, 93, 2);
INSERT INTO public."UserBetgroup" VALUES (86, 94, 2);
INSERT INTO public."UserBetgroup" VALUES (87, 95, 2);
INSERT INTO public."UserBetgroup" VALUES (88, 96, 2);
INSERT INTO public."UserBetgroup" VALUES (89, 97, 2);
INSERT INTO public."UserBetgroup" VALUES (90, 98, 2);
INSERT INTO public."UserBetgroup" VALUES (91, 99, 2);
INSERT INTO public."UserBetgroup" VALUES (92, 100, 2);
INSERT INTO public."UserBetgroup" VALUES (93, 101, 2);
INSERT INTO public."UserBetgroup" VALUES (79, 87, 2);
INSERT INTO public."UserBetgroup" VALUES (94, 102, 1);
INSERT INTO public."UserBetgroup" VALUES (95, 103, 1);
INSERT INTO public."UserBetgroup" VALUES (96, 104, 1);
INSERT INTO public."UserBetgroup" VALUES (97, 105, 1);
INSERT INTO public."UserBetgroup" VALUES (98, 106, 1);
INSERT INTO public."UserBetgroup" VALUES (99, 107, 1);
INSERT INTO public."UserBetgroup" VALUES (100, 108, 2);
INSERT INTO public."UserBetgroup" VALUES (101, 109, 1);
INSERT INTO public."UserBetgroup" VALUES (102, 110, 2);
INSERT INTO public."UserBetgroup" VALUES (103, 111, 2);
INSERT INTO public."UserBetgroup" VALUES (104, 112, 2);
INSERT INTO public."UserBetgroup" VALUES (105, 113, 2);
INSERT INTO public."UserBetgroup" VALUES (106, 114, 2);
INSERT INTO public."UserBetgroup" VALUES (107, 115, 2);
INSERT INTO public."UserBetgroup" VALUES (108, 116, 2);
INSERT INTO public."UserBetgroup" VALUES (74, 82, 2);
INSERT INTO public."UserBetgroup" VALUES (111, 119, 2);
INSERT INTO public."UserBetgroup" VALUES (112, 120, 3);
INSERT INTO public."UserBetgroup" VALUES (113, 121, 2);
INSERT INTO public."UserBetgroup" VALUES (114, 122, 1);
INSERT INTO public."UserBetgroup" VALUES (115, 123, 2);
INSERT INTO public."UserBetgroup" VALUES (117, 12, 3);
INSERT INTO public."UserBetgroup" VALUES (3, 12, 1);
INSERT INTO public."UserBetgroup" VALUES (4, 12, 2);
INSERT INTO public."UserBetgroup" VALUES (118, 70, 3);
INSERT INTO public."UserBetgroup" VALUES (62, 70, 1);


--
-- TOC entry 2349 (class 0 OID 0)
-- Dependencies: 214
-- Name: UserBetgroup_userBetgroupId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserBetgroup_userBetgroupId_seq"', 118, true);


--
-- TOC entry 2316 (class 0 OID 16685)
-- Dependencies: 215
-- Data for Name: UserPost; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."UserPost" VALUES (122, 92, 2, 'Erster!', '2018-05-29 06:48:07.822');
INSERT INTO public."UserPost" VALUES (123, 85, 2, 'Zweite :-)', '2018-05-29 07:59:31.658');
INSERT INTO public."UserPost" VALUES (124, 12, 2, 'Bester! ;-)', '2018-05-29 11:30:54.393');
INSERT INTO public."UserPost" VALUES (125, 101, 2, 'Fehler: am 18.06. spielt Schweden (nicht Schweiz) gegen Südkorea', '2018-05-31 21:22:15.38');
INSERT INTO public."UserPost" VALUES (126, 12, 2, 'Danke für die Info Elmar, habe es eben korrigiert. Ich werde die Tage mal noch die Spiele überprüfen.', '2018-06-03 08:41:42.577');
INSERT INTO public."UserPost" VALUES (127, 12, 1, 'Ein Dank geht an Malenka für den Hinweis auf ein falsch eingetragenes Spiel am 26.06. Das Spiel findet eigentlich am 16.06 statt. Ist korrigiert.', '2018-06-04 09:26:13.538');
INSERT INTO public."UserPost" VALUES (129, 75, 1, 'Jetzt habe ich gerade meinen Bezahlstatus auf "bezahlt" geändert. Ist das normal das ich das darf?', '2018-06-14 13:03:09.195');
INSERT INTO public."UserPost" VALUES (130, 12, 1, 'Das darf jeder Tippadmin. Aber ich merk mir das ^^.', '2018-06-14 13:30:40.127');
INSERT INTO public."UserPost" VALUES (131, 102, 1, '5:0 für Russland! Und ich hab mir heut morgen im Deutschlandfunkt erzählen lassen, dass es ein Wunder wäre, wenn Russland ins Achtelfinale käme! Die haben mich gelinkt!!', '2018-06-14 17:01:31.975');
INSERT INTO public."UserPost" VALUES (132, 112, 2, 'Platz 1 - Bitte die WM JETZT beenden :-)', '2018-06-14 17:05:55.394');
INSERT INTO public."UserPost" VALUES (133, 12, 1, 'Und dann spielt Deutschland nur 2:1 gegen die Saudis... Wo ordnen sich da jetzt die Deutschen ein?', '2018-06-14 18:30:56.41');
INSERT INTO public."UserPost" VALUES (134, 12, 2, 'Und dann spielt Deutschland nur 2:1 gegen die Saudis... Wo ordnen sich da jetzt die Deutschen ein?', '2018-06-14 18:31:08.341');
INSERT INTO public."UserPost" VALUES (135, 12, 2, 'Ach ja.

@Christian: Mach dir nen Screenshot. Sag ich dem Bernhard auch immer, der ist ganz am Anfang immer oben. ^^', '2018-06-14 18:31:40.978');
INSERT INTO public."UserPost" VALUES (136, 107, 1, 'Torreicher Auftakt!! Deutschland ist schlechter als Russland, ist doch klar ;-) Sieht man die Tipps der Mitspieler irgendwo?', '2018-06-14 19:10:25.302');
INSERT INTO public."UserPost" VALUES (137, 75, 1, 'Ja, allerdings erst nachdem die Tips nicht mehr geändert werden können, also ab 30 Minuten vor Spielbeginn. Beim entsprechenden Spiel dann auf das Lupensymbol klicken', '2018-06-14 22:07:58.817');
INSERT INTO public."UserPost" VALUES (138, 102, 1, 'Hallo, habt ihr schon mitgekriegt? Das Ergebnis gestern war zwischen Putin und dem Saudi abgesprochen!! Zumindest vermutet das Wladimir Kaminer, der russische Autor (Russsendisko). Und auch viele andere können sich das 5:0 nicht anders erklären. Ich auch nicht. Aber so.....klar, hätt man auch früher draufkommen können!', '2018-06-15 11:24:18.951');
INSERT INTO public."UserPost" VALUES (139, 107, 1, '...danke Christoph !!', '2018-06-15 14:09:25.727');
INSERT INTO public."UserPost" VALUES (140, 85, 2, 'Zufallstipp läuft auf Fehler. Liegt das nur am Handy?', '2018-06-15 20:42:16.779');
INSERT INTO public."UserPost" VALUES (141, 12, 2, 'Kann ich so nicht sagen, wo genau hast den Zufallstipp gemacht? Waren da auch Spiele dabei, die schon nicht mehr zu tippen waren?', '2018-06-15 23:17:13.764');
INSERT INTO public."UserPost" VALUES (142, 85, 2, 'Hab es über alle Spiele und Gruppenphase versucht. Ja, waren auch Spiele dabei die nicht mehr getippt werden konnten. Daran liegt es auch. In den anderen Bereichen geht es...', '2018-06-17 08:19:18.147');
INSERT INTO public."UserPost" VALUES (143, 96, 2, 'Orakel Martin, das Stachelschwein hatte recht 😅', '2018-06-17 16:55:56.136');
INSERT INTO public."UserPost" VALUES (144, 12, 2, 'Super, kann ich mir anschauen (auch wenn''s nicht furchtbar relevant sein dürfte ^^).', '2018-06-17 17:12:26.289');
INSERT INTO public."UserPost" VALUES (145, 92, 2, 'Schlaaaand?! WTF?! 🤔', '2018-06-17 17:34:33.138');
INSERT INTO public."UserPost" VALUES (146, 122, 1, 'Will Football finally come home?  - Ein Land haelt den Atem an... Uebrigens das Englische National Team ist sponsored by Lidle ;-) Ist jetzt kein Witz.', '2018-06-18 17:58:46.104');
INSERT INTO public."UserPost" VALUES (147, 89, 2, 'Der Peter schummelt doch!', '2018-06-20 14:15:33.532');
INSERT INTO public."UserPost" VALUES (149, 92, 2, 'Des woisch aber! 😂', '2018-06-20 18:43:13.791');
INSERT INTO public."UserPost" VALUES (150, 12, 1, 'Hallo zusammen,

leider war es durch einen Fehler in der Seite möglich, Tipps doppelt abzugeben. Das hat sich natürlich auch auf die Rangliste ausgewirkt.

Ich habe jetzt die doppelten Tipps entfernt. Die Rangliste sollte jetzt wieder den tatsächlichen Punktestand wiederspiegeln.

Den Fehler bitte ich zu entschuldigen.

Gruß Flo.', '2018-06-21 20:14:39.023');
INSERT INTO public."UserPost" VALUES (151, 12, 2, 'Hallo zusammen,

leider war es durch einen Fehler in der Seite möglich, Tipps doppelt abzugeben. Das hat sich natürlich auch auf die Rangliste ausgewirkt.

Ich habe jetzt die doppelten Tipps entfernt. Die Rangliste sollte jetzt wieder den tatsächlichen Punktestand wiederspiegeln.

Den Fehler bitte ich zu entschuldigen.

Gruß Flo.', '2018-06-21 20:15:00.292');
INSERT INTO public."UserPost" VALUES (153, 111, 2, 'Was ist denn das für eine WM? Die eigentlich großen Mannschaften mit Problemen ?
Und heute Abend ein echter Krimi :-)', '2018-06-26 19:51:05.033');
INSERT INTO public."UserPost" VALUES (154, 12, 1, 'Test', '2021-06-01 21:23:44.431');


--
-- TOC entry 2350 (class 0 OID 0)
-- Dependencies: 216
-- Name: UserPost_userPostId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserPost_userPostId_seq"', 154, true);


--
-- TOC entry 2318 (class 0 OID 16693)
-- Dependencies: 217
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."UserRole" VALUES (3, 1, 1);
INSERT INTO public."UserRole" VALUES (2, 1, 5);
INSERT INTO public."UserRole" VALUES (50, 75, 5);
INSERT INTO public."UserRole" VALUES (51, 92, 5);
INSERT INTO public."UserRole" VALUES (52, 99, 5);
INSERT INTO public."UserRole" VALUES (48, 69, 5);
INSERT INTO public."UserRole" VALUES (40, 12, 1);
INSERT INTO public."UserRole" VALUES (38, 12, 5);
INSERT INTO public."UserRole" VALUES (49, 70, 5);


--
-- TOC entry 2351 (class 0 OID 0)
-- Dependencies: 218
-- Name: UserRole_userRoleId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserRole_userRoleId_seq"', 52, true);


--
-- TOC entry 2352 (class 0 OID 0)
-- Dependencies: 219
-- Name: User_userId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."User_userId_seq"', 123, true);


--
-- TOC entry 2137 (class 2606 OID 16713)
-- Name: Bet Bet_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bet"
    ADD CONSTRAINT "Bet_pkey" PRIMARY KEY ("betId");


--
-- TOC entry 2139 (class 2606 OID 16715)
-- Name: Betgroup Betgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Betgroup"
    ADD CONSTRAINT "Betgroup_pkey" PRIMARY KEY ("betgroupId");


--
-- TOC entry 2145 (class 2606 OID 16717)
-- Name: BracketTeam BracketTeam_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."BracketTeam"
    ADD CONSTRAINT "BracketTeam_pkey" PRIMARY KEY ("bracketTeamId");


--
-- TOC entry 2142 (class 2606 OID 16719)
-- Name: Bracket Bracket_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bracket"
    ADD CONSTRAINT "Bracket_pkey" PRIMARY KEY ("bracketId");


--
-- TOC entry 2153 (class 2606 OID 16721)
-- Name: Phase Phase_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Phase"
    ADD CONSTRAINT "Phase_pkey" PRIMARY KEY ("phaseId");


--
-- TOC entry 2156 (class 2606 OID 16723)
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY ("roleId");


--
-- TOC entry 2148 (class 2606 OID 16725)
-- Name: SoccerMatch SoccerMatch_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."SoccerMatch"
    ADD CONSTRAINT "SoccerMatch_pkey" PRIMARY KEY ("matchId");


--
-- TOC entry 2150 (class 2606 OID 16727)
-- Name: Team Team_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_pkey" PRIMARY KEY ("teamId");


--
-- TOC entry 2162 (class 2606 OID 16729)
-- Name: UserBetgroup UserBetgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserBetgroup"
    ADD CONSTRAINT "UserBetgroup_pkey" PRIMARY KEY ("userBetgroupId");


--
-- TOC entry 2165 (class 2606 OID 16731)
-- Name: UserPost UserPost_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserPost"
    ADD CONSTRAINT "UserPost_pkey" PRIMARY KEY ("userPostId");


--
-- TOC entry 2167 (class 2606 OID 16733)
-- Name: UserRole UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY ("userRoleId");


--
-- TOC entry 2159 (class 2606 OID 16735)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY ("userId");


--
-- TOC entry 2140 (class 1259 OID 16736)
-- Name: betgroupname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "betgroupname_UNIQUE" ON public."Betgroup" USING btree (betgroupname);


--
-- TOC entry 2146 (class 1259 OID 16737)
-- Name: bracketId_teamId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "bracketId_teamId_UNIQUE" ON public."BracketTeam" USING btree ("bracketId", "teamId");


--
-- TOC entry 2143 (class 1259 OID 16738)
-- Name: bracketname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "bracketname_UNIQUE" ON public."Bracket" USING btree (bracketname);


--
-- TOC entry 2154 (class 1259 OID 16739)
-- Name: phasename_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "phasename_UNIQUE" ON public."Phase" USING btree (phasename);


--
-- TOC entry 2157 (class 1259 OID 16740)
-- Name: rolename_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "rolename_UNIQUE" ON public."Role" USING btree (rolename);


--
-- TOC entry 2151 (class 1259 OID 16741)
-- Name: teamname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "teamname_UNIQUE" ON public."Team" USING btree (teamname);


--
-- TOC entry 2163 (class 1259 OID 16742)
-- Name: userId_betgroupId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "userId_betgroupId_UNIQUE" ON public."UserBetgroup" USING btree ("userId", "betgroupId");


--
-- TOC entry 2168 (class 1259 OID 16743)
-- Name: userId_roleId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "userId_roleId_UNIQUE" ON public."UserRole" USING btree ("userId", "roleId");


--
-- TOC entry 2160 (class 1259 OID 16744)
-- Name: username_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "username_UNIQUE" ON public."User" USING btree (username);


-- Completed on 2021-06-01 21:43:05

--
-- PostgreSQL database dump complete
--

