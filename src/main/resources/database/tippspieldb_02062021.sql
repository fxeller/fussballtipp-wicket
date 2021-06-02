--
-- PostgreSQL database dump
--

-- Dumped from database version 12.7
-- Dumped by pg_dump version 12.7

-- Started on 2021-06-02 21:39:49

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 202 (class 1259 OID 16395)
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
-- TOC entry 203 (class 1259 OID 16398)
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
-- TOC entry 3021 (class 0 OID 0)
-- Dependencies: 203
-- Name: Bet_betId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Bet_betId_seq" OWNED BY public."Bet"."betId";


--
-- TOC entry 204 (class 1259 OID 16400)
-- Name: Betgroup; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Betgroup" (
    "betgroupId" integer NOT NULL,
    betgroupname character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Betgroup" OWNER TO tippspiel;

--
-- TOC entry 205 (class 1259 OID 16404)
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
-- TOC entry 3022 (class 0 OID 0)
-- Dependencies: 205
-- Name: Betgroup_betgroupId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Betgroup_betgroupId_seq" OWNED BY public."Betgroup"."betgroupId";


--
-- TOC entry 206 (class 1259 OID 16406)
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
-- TOC entry 207 (class 1259 OID 16410)
-- Name: BracketTeam; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."BracketTeam" (
    "bracketTeamId" integer NOT NULL,
    "bracketId" integer NOT NULL,
    "teamId" integer NOT NULL
);


ALTER TABLE public."BracketTeam" OWNER TO tippspiel;

--
-- TOC entry 208 (class 1259 OID 16413)
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
-- TOC entry 209 (class 1259 OID 16417)
-- Name: Team; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Team" (
    "teamId" integer NOT NULL,
    teamname character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Team" OWNER TO tippspiel;

--
-- TOC entry 210 (class 1259 OID 16421)
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
-- TOC entry 211 (class 1259 OID 16426)
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
-- TOC entry 212 (class 1259 OID 16431)
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
-- TOC entry 213 (class 1259 OID 16436)
-- Name: BracketMaxRank; Type: VIEW; Schema: public; Owner: tippspiel
--

CREATE VIEW public."BracketMaxRank" AS
 SELECT "BracketStanding"."bracketId",
    max("BracketStanding".rank) AS maxrank
   FROM public."BracketStanding"
  GROUP BY "BracketStanding"."bracketId";


ALTER TABLE public."BracketMaxRank" OWNER TO tippspiel;

--
-- TOC entry 214 (class 1259 OID 16440)
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
-- TOC entry 215 (class 1259 OID 16444)
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
-- TOC entry 3023 (class 0 OID 0)
-- Dependencies: 215
-- Name: BracketTeam_bracketTeamId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."BracketTeam_bracketTeamId_seq" OWNED BY public."BracketTeam"."bracketTeamId";


--
-- TOC entry 216 (class 1259 OID 16446)
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
-- TOC entry 217 (class 1259 OID 16450)
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
-- TOC entry 3024 (class 0 OID 0)
-- Dependencies: 217
-- Name: Bracket_bracketId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Bracket_bracketId_seq" OWNED BY public."Bracket"."bracketId";


--
-- TOC entry 218 (class 1259 OID 16452)
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
-- TOC entry 219 (class 1259 OID 16457)
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
-- TOC entry 3025 (class 0 OID 0)
-- Dependencies: 219
-- Name: Phase_phaseId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Phase_phaseId_seq" OWNED BY public."Phase"."phaseId";


--
-- TOC entry 220 (class 1259 OID 16459)
-- Name: Role; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."Role" (
    "roleId" integer NOT NULL,
    rolename character varying(20) NOT NULL,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE public."Role" OWNER TO tippspiel;

--
-- TOC entry 221 (class 1259 OID 16463)
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
-- TOC entry 3026 (class 0 OID 0)
-- Dependencies: 221
-- Name: Role_roleId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Role_roleId_seq" OWNED BY public."Role"."roleId";


--
-- TOC entry 222 (class 1259 OID 16465)
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
-- TOC entry 223 (class 1259 OID 16469)
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
-- TOC entry 224 (class 1259 OID 16473)
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
-- TOC entry 3027 (class 0 OID 0)
-- Dependencies: 224
-- Name: SoccerMatch_matchId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."SoccerMatch_matchId_seq" OWNED BY public."SoccerMatch"."matchId";


--
-- TOC entry 225 (class 1259 OID 16475)
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
-- TOC entry 3028 (class 0 OID 0)
-- Dependencies: 225
-- Name: Team_teamId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."Team_teamId_seq" OWNED BY public."Team"."teamId";


--
-- TOC entry 226 (class 1259 OID 16477)
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
-- TOC entry 227 (class 1259 OID 16481)
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
-- TOC entry 228 (class 1259 OID 16489)
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
-- TOC entry 229 (class 1259 OID 16494)
-- Name: UserBetgroup; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."UserBetgroup" (
    "userBetgroupId" integer NOT NULL,
    "userId" integer NOT NULL,
    "betgroupId" integer NOT NULL
);


ALTER TABLE public."UserBetgroup" OWNER TO tippspiel;

--
-- TOC entry 230 (class 1259 OID 16497)
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
-- TOC entry 231 (class 1259 OID 16502)
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
-- TOC entry 3029 (class 0 OID 0)
-- Dependencies: 231
-- Name: UserBetgroup_userBetgroupId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserBetgroup_userBetgroupId_seq" OWNED BY public."UserBetgroup"."userBetgroupId";


--
-- TOC entry 232 (class 1259 OID 16504)
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
-- TOC entry 233 (class 1259 OID 16510)
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
-- TOC entry 3030 (class 0 OID 0)
-- Dependencies: 233
-- Name: UserPost_userPostId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserPost_userPostId_seq" OWNED BY public."UserPost"."userPostId";


--
-- TOC entry 234 (class 1259 OID 16512)
-- Name: UserRole; Type: TABLE; Schema: public; Owner: tippspiel
--

CREATE TABLE public."UserRole" (
    "userRoleId" integer NOT NULL,
    "userId" integer NOT NULL,
    "roleId" integer NOT NULL
);


ALTER TABLE public."UserRole" OWNER TO tippspiel;

--
-- TOC entry 235 (class 1259 OID 16515)
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
-- TOC entry 3031 (class 0 OID 0)
-- Dependencies: 235
-- Name: UserRole_userRoleId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."UserRole_userRoleId_seq" OWNED BY public."UserRole"."userRoleId";


--
-- TOC entry 236 (class 1259 OID 16517)
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
-- TOC entry 3032 (class 0 OID 0)
-- Dependencies: 236
-- Name: User_userId_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: tippspiel
--

ALTER SEQUENCE public."User_userId_seq" OWNED BY public."User"."userId";


--
-- TOC entry 2798 (class 2604 OID 16519)
-- Name: Bet betId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bet" ALTER COLUMN "betId" SET DEFAULT nextval('public."Bet_betId_seq"'::regclass);


--
-- TOC entry 2800 (class 2604 OID 16520)
-- Name: Betgroup betgroupId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Betgroup" ALTER COLUMN "betgroupId" SET DEFAULT nextval('public."Betgroup_betgroupId_seq"'::regclass);


--
-- TOC entry 2802 (class 2604 OID 16521)
-- Name: Bracket bracketId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bracket" ALTER COLUMN "bracketId" SET DEFAULT nextval('public."Bracket_bracketId_seq"'::regclass);


--
-- TOC entry 2803 (class 2604 OID 16522)
-- Name: BracketTeam bracketTeamId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."BracketTeam" ALTER COLUMN "bracketTeamId" SET DEFAULT nextval('public."BracketTeam_bracketTeamId_seq"'::regclass);


--
-- TOC entry 2810 (class 2604 OID 16523)
-- Name: Phase phaseId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Phase" ALTER COLUMN "phaseId" SET DEFAULT nextval('public."Phase_phaseId_seq"'::regclass);


--
-- TOC entry 2812 (class 2604 OID 16524)
-- Name: Role roleId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Role" ALTER COLUMN "roleId" SET DEFAULT nextval('public."Role_roleId_seq"'::regclass);


--
-- TOC entry 2805 (class 2604 OID 16525)
-- Name: SoccerMatch matchId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."SoccerMatch" ALTER COLUMN "matchId" SET DEFAULT nextval('public."SoccerMatch_matchId_seq"'::regclass);


--
-- TOC entry 2807 (class 2604 OID 16526)
-- Name: Team teamId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Team" ALTER COLUMN "teamId" SET DEFAULT nextval('public."Team_teamId_seq"'::regclass);


--
-- TOC entry 2818 (class 2604 OID 16527)
-- Name: User userId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."User" ALTER COLUMN "userId" SET DEFAULT nextval('public."User_userId_seq"'::regclass);


--
-- TOC entry 2819 (class 2604 OID 16528)
-- Name: UserBetgroup userBetgroupId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserBetgroup" ALTER COLUMN "userBetgroupId" SET DEFAULT nextval('public."UserBetgroup_userBetgroupId_seq"'::regclass);


--
-- TOC entry 2820 (class 2604 OID 16529)
-- Name: UserPost userPostId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserPost" ALTER COLUMN "userPostId" SET DEFAULT nextval('public."UserPost_userPostId_seq"'::regclass);


--
-- TOC entry 2821 (class 2604 OID 16530)
-- Name: UserRole userRoleId; Type: DEFAULT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserRole" ALTER COLUMN "userRoleId" SET DEFAULT nextval('public."UserRole_userRoleId_seq"'::regclass);


--
-- TOC entry 2992 (class 0 OID 16395)
-- Dependencies: 202
-- Data for Name: Bet; Type: TABLE DATA; Schema: public; Owner: tippspiel
--



--
-- TOC entry 2994 (class 0 OID 16400)
-- Dependencies: 204
-- Data for Name: Betgroup; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Betgroup" VALUES (1, 'FREUNDE', 'Freunde');
INSERT INTO public."Betgroup" VALUES (2, 'KOLLEGEN', 'Kollegen');


--
-- TOC entry 2996 (class 0 OID 16406)
-- Dependencies: 206
-- Data for Name: Bracket; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Bracket" VALUES (1, 'A', 'Gruppe A', 1);
INSERT INTO public."Bracket" VALUES (2, 'B', 'Gruppe B', 1);
INSERT INTO public."Bracket" VALUES (3, 'C', 'Gruppe C', 1);
INSERT INTO public."Bracket" VALUES (4, 'D', 'Gruppe D', 1);
INSERT INTO public."Bracket" VALUES (5, 'E', 'Gruppe E', 1);
INSERT INTO public."Bracket" VALUES (6, 'F', 'Gruppe F', 1);


--
-- TOC entry 2997 (class 0 OID 16410)
-- Dependencies: 207
-- Data for Name: BracketTeam; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."BracketTeam" VALUES (65, 1, 71);
INSERT INTO public."BracketTeam" VALUES (66, 1, 81);
INSERT INTO public."BracketTeam" VALUES (67, 1, 85);
INSERT INTO public."BracketTeam" VALUES (68, 1, 88);
INSERT INTO public."BracketTeam" VALUES (69, 2, 65);
INSERT INTO public."BracketTeam" VALUES (70, 2, 66);
INSERT INTO public."BracketTeam" VALUES (71, 2, 69);
INSERT INTO public."BracketTeam" VALUES (72, 2, 78);
INSERT INTO public."BracketTeam" VALUES (73, 3, 73);
INSERT INTO public."BracketTeam" VALUES (74, 3, 74);
INSERT INTO public."BracketTeam" VALUES (75, 3, 75);
INSERT INTO public."BracketTeam" VALUES (76, 3, 86);
INSERT INTO public."BracketTeam" VALUES (77, 4, 68);
INSERT INTO public."BracketTeam" VALUES (78, 4, 72);
INSERT INTO public."BracketTeam" VALUES (79, 4, 79);
INSERT INTO public."BracketTeam" VALUES (80, 4, 84);
INSERT INTO public."BracketTeam" VALUES (81, 5, 76);
INSERT INTO public."BracketTeam" VALUES (82, 5, 80);
INSERT INTO public."BracketTeam" VALUES (83, 5, 82);
INSERT INTO public."BracketTeam" VALUES (84, 5, 83);
INSERT INTO public."BracketTeam" VALUES (85, 6, 67);
INSERT INTO public."BracketTeam" VALUES (86, 6, 70);
INSERT INTO public."BracketTeam" VALUES (87, 6, 77);
INSERT INTO public."BracketTeam" VALUES (88, 6, 87);


--
-- TOC entry 3002 (class 0 OID 16452)
-- Dependencies: 218
-- Data for Name: Phase; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Phase" VALUES (1, 'Gruppe', 'Gruppenphase', '2018-06-14 17:00:00', true);
INSERT INTO public."Phase" VALUES (2, 'Achtel', 'Achtelfinale', '2018-06-30 16:00:00', false);
INSERT INTO public."Phase" VALUES (3, 'Viertel', 'Viertelfinale', '2018-07-06 16:00:00', false);
INSERT INTO public."Phase" VALUES (4, 'Halb', 'Halbfinale', '2018-07-10 20:00:00', false);
INSERT INTO public."Phase" VALUES (5, 'Finale', 'Finale', '2018-07-15 17:00:00', false);


--
-- TOC entry 3004 (class 0 OID 16459)
-- Dependencies: 220
-- Data for Name: Role; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Role" VALUES (1, 'ADMIN', 'Administrator');
INSERT INTO public."Role" VALUES (5, 'TIPPADMIN', 'Tipp-Administrator');


--
-- TOC entry 2998 (class 0 OID 16413)
-- Dependencies: 208
-- Data for Name: SoccerMatch; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."SoccerMatch" VALUES (120, 1, '2021-06-11 21:00:00', 85, 71, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (121, 1, '2021-06-12 15:00:00', 88, 81, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (122, 1, '2021-06-16 18:00:00', 85, 88, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (123, 1, '2021-06-16 21:00:00', 71, 81, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (124, 1, '2021-06-20 18:00:00', 81, 85, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (125, 1, '2021-06-20 18:00:00', 71, 88, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (126, 1, '2021-06-12 18:00:00', 66, 69, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (127, 1, '2021-06-12 21:00:00', 65, 78, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (128, 1, '2021-06-16 15:00:00', 69, 78, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (129, 1, '2021-06-17 18:00:00', 66, 65, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (130, 1, '2021-06-21 21:00:00', 78, 66, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (131, 1, '2021-06-21 21:00:00', 69, 65, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (132, 1, '2021-06-13 18:00:00', 75, 74, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (133, 1, '2021-06-13 21:00:00', 73, 86, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (134, 1, '2021-06-17 15:00:00', 86, 74, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (135, 1, '2021-06-17 21:00:00', 73, 75, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (136, 1, '2021-06-21 18:00:00', 74, 73, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (137, 1, '2021-06-21 18:00:00', 86, 75, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (138, 1, '2021-06-13 15:00:00', 68, 72, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (139, 1, '2021-06-14 15:00:00', 79, 84, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (140, 1, '2021-06-18 18:00:00', 72, 84, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (141, 1, '2021-06-18 21:00:00', 68, 79, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (142, 1, '2021-06-22 21:00:00', 72, 79, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (143, 1, '2021-06-22 21:00:00', 84, 68, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (144, 1, '2021-06-14 18:00:00', 76, 82, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (145, 1, '2021-06-14 21:00:00', 83, 80, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (146, 1, '2021-06-18 15:00:00', 80, 82, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (147, 1, '2021-06-19 21:00:00', 83, 76, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (148, 1, '2021-06-23 18:00:00', 80, 76, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (149, 1, '2021-06-23 18:00:00', 82, 83, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (150, 1, '2021-06-15 18:00:00', 87, 77, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (151, 1, '2021-06-15 21:00:00', 70, 67, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (152, 1, '2021-06-19 15:00:00', 87, 70, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (153, 1, '2021-06-19 18:00:00', 77, 67, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (154, 1, '2021-06-23 21:00:00', 77, 70, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (155, 1, '2021-06-23 21:00:00', 67, 87, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (156, 2, '2021-06-26 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (157, 2, '2021-06-26 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (158, 2, '2021-06-27 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (159, 2, '2021-06-27 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (160, 2, '2021-06-28 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (161, 2, '2021-06-28 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (162, 2, '2021-06-29 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (163, 2, '2021-06-29 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (164, 3, '2021-07-02 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (165, 3, '2021-07-02 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (166, 3, '2021-07-03 18:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (167, 3, '2021-07-03 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (168, 4, '2021-07-06 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (169, 4, '2021-07-07 21:00:00', 89, 89, NULL, NULL, false);
INSERT INTO public."SoccerMatch" VALUES (170, 5, '2021-07-11 21:00:00', 89, 89, NULL, NULL, true);


--
-- TOC entry 2999 (class 0 OID 16417)
-- Dependencies: 209
-- Data for Name: Team; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."Team" VALUES (65, 'Belgien', 'Belgien');
INSERT INTO public."Team" VALUES (66, 'Dänemark', 'Dänemark');
INSERT INTO public."Team" VALUES (67, 'Deutschland', 'Deutschland');
INSERT INTO public."Team" VALUES (68, 'England', 'England');
INSERT INTO public."Team" VALUES (69, 'Finnland', 'Finnland');
INSERT INTO public."Team" VALUES (70, 'Frankreich', 'Frankreich');
INSERT INTO public."Team" VALUES (71, 'Italien', 'Italien');
INSERT INTO public."Team" VALUES (72, 'Kroatien', 'Kroatien');
INSERT INTO public."Team" VALUES (73, 'Niederlande', 'Niederlande');
INSERT INTO public."Team" VALUES (74, 'Nordmazedonien', 'Nordmazedonien');
INSERT INTO public."Team" VALUES (75, 'Österreich', 'Österreich');
INSERT INTO public."Team" VALUES (76, 'Polen', 'Polen');
INSERT INTO public."Team" VALUES (77, 'Portugal', 'Portugal');
INSERT INTO public."Team" VALUES (78, 'Russland', 'Russland');
INSERT INTO public."Team" VALUES (79, 'Schottland', 'Schottland');
INSERT INTO public."Team" VALUES (80, 'Schweden', 'Schweden');
INSERT INTO public."Team" VALUES (81, 'Schweiz', 'Schweiz');
INSERT INTO public."Team" VALUES (82, 'Slowakei', 'Slowakei');
INSERT INTO public."Team" VALUES (83, 'Spanien', 'Spanien');
INSERT INTO public."Team" VALUES (84, 'Tschechien', 'Tschechien');
INSERT INTO public."Team" VALUES (85, 'Türkei', 'Türkei');
INSERT INTO public."Team" VALUES (86, 'Ukraine', 'Ukraine');
INSERT INTO public."Team" VALUES (87, 'Ungarn', 'Ungarn');
INSERT INTO public."Team" VALUES (88, 'Wales', 'Wales');
INSERT INTO public."Team" VALUES (89, 'Unbekannt', 'Unbekannt');


--
-- TOC entry 3008 (class 0 OID 16481)
-- Dependencies: 227
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."User" VALUES (1, 'admin', 'MMlgnn0mae3x4RfiCyk3mVFVIEZ/+3Hr', 'Mustermann', 'Manfred', 'fxeller@delmak.de', 'flHHsoOjrB6r', false);
INSERT INTO public."User" VALUES (12, 'fxeller', 'QsI3Nu6oD2M2BDNOyvcidtGT4sjpvtXa', 'Xeller', 'Florian', 'fxeller@delmak.de', NULL, false);


--
-- TOC entry 3009 (class 0 OID 16494)
-- Dependencies: 229
-- Data for Name: UserBetgroup; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."UserBetgroup" VALUES (119, 12, 1);
INSERT INTO public."UserBetgroup" VALUES (120, 12, 2);


--
-- TOC entry 3011 (class 0 OID 16504)
-- Dependencies: 232
-- Data for Name: UserPost; Type: TABLE DATA; Schema: public; Owner: tippspiel
--



--
-- TOC entry 3013 (class 0 OID 16512)
-- Dependencies: 234
-- Data for Name: UserRole; Type: TABLE DATA; Schema: public; Owner: tippspiel
--

INSERT INTO public."UserRole" VALUES (3, 1, 1);
INSERT INTO public."UserRole" VALUES (2, 1, 5);
INSERT INTO public."UserRole" VALUES (40, 12, 1);
INSERT INTO public."UserRole" VALUES (38, 12, 5);


--
-- TOC entry 3033 (class 0 OID 0)
-- Dependencies: 203
-- Name: Bet_betId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Bet_betId_seq"', 6275, true);


--
-- TOC entry 3034 (class 0 OID 0)
-- Dependencies: 205
-- Name: Betgroup_betgroupId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Betgroup_betgroupId_seq"', 3, true);


--
-- TOC entry 3035 (class 0 OID 0)
-- Dependencies: 215
-- Name: BracketTeam_bracketTeamId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."BracketTeam_bracketTeamId_seq"', 88, true);


--
-- TOC entry 3036 (class 0 OID 0)
-- Dependencies: 217
-- Name: Bracket_bracketId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Bracket_bracketId_seq"', 18, true);


--
-- TOC entry 3037 (class 0 OID 0)
-- Dependencies: 219
-- Name: Phase_phaseId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Phase_phaseId_seq"', 9, true);


--
-- TOC entry 3038 (class 0 OID 0)
-- Dependencies: 221
-- Name: Role_roleId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Role_roleId_seq"', 15, true);


--
-- TOC entry 3039 (class 0 OID 0)
-- Dependencies: 224
-- Name: SoccerMatch_matchId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."SoccerMatch_matchId_seq"', 170, true);


--
-- TOC entry 3040 (class 0 OID 0)
-- Dependencies: 225
-- Name: Team_teamId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."Team_teamId_seq"', 89, true);


--
-- TOC entry 3041 (class 0 OID 0)
-- Dependencies: 231
-- Name: UserBetgroup_userBetgroupId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserBetgroup_userBetgroupId_seq"', 120, true);


--
-- TOC entry 3042 (class 0 OID 0)
-- Dependencies: 233
-- Name: UserPost_userPostId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserPost_userPostId_seq"', 154, true);


--
-- TOC entry 3043 (class 0 OID 0)
-- Dependencies: 235
-- Name: UserRole_userRoleId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."UserRole_userRoleId_seq"', 52, true);


--
-- TOC entry 3044 (class 0 OID 0)
-- Dependencies: 236
-- Name: User_userId_seq; Type: SEQUENCE SET; Schema: public; Owner: tippspiel
--

SELECT pg_catalog.setval('public."User_userId_seq"', 123, true);


--
-- TOC entry 2823 (class 2606 OID 16532)
-- Name: Bet Bet_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bet"
    ADD CONSTRAINT "Bet_pkey" PRIMARY KEY ("betId");


--
-- TOC entry 2825 (class 2606 OID 16534)
-- Name: Betgroup Betgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Betgroup"
    ADD CONSTRAINT "Betgroup_pkey" PRIMARY KEY ("betgroupId");


--
-- TOC entry 2831 (class 2606 OID 16536)
-- Name: BracketTeam BracketTeam_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."BracketTeam"
    ADD CONSTRAINT "BracketTeam_pkey" PRIMARY KEY ("bracketTeamId");


--
-- TOC entry 2828 (class 2606 OID 16538)
-- Name: Bracket Bracket_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Bracket"
    ADD CONSTRAINT "Bracket_pkey" PRIMARY KEY ("bracketId");


--
-- TOC entry 2839 (class 2606 OID 16540)
-- Name: Phase Phase_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Phase"
    ADD CONSTRAINT "Phase_pkey" PRIMARY KEY ("phaseId");


--
-- TOC entry 2842 (class 2606 OID 16542)
-- Name: Role Role_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Role"
    ADD CONSTRAINT "Role_pkey" PRIMARY KEY ("roleId");


--
-- TOC entry 2834 (class 2606 OID 16544)
-- Name: SoccerMatch SoccerMatch_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."SoccerMatch"
    ADD CONSTRAINT "SoccerMatch_pkey" PRIMARY KEY ("matchId");


--
-- TOC entry 2836 (class 2606 OID 16546)
-- Name: Team Team_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."Team"
    ADD CONSTRAINT "Team_pkey" PRIMARY KEY ("teamId");


--
-- TOC entry 2848 (class 2606 OID 16548)
-- Name: UserBetgroup UserBetgroup_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserBetgroup"
    ADD CONSTRAINT "UserBetgroup_pkey" PRIMARY KEY ("userBetgroupId");


--
-- TOC entry 2851 (class 2606 OID 16550)
-- Name: UserPost UserPost_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserPost"
    ADD CONSTRAINT "UserPost_pkey" PRIMARY KEY ("userPostId");


--
-- TOC entry 2853 (class 2606 OID 16552)
-- Name: UserRole UserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."UserRole"
    ADD CONSTRAINT "UserRole_pkey" PRIMARY KEY ("userRoleId");


--
-- TOC entry 2845 (class 2606 OID 16554)
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: tippspiel
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY ("userId");


--
-- TOC entry 2826 (class 1259 OID 16555)
-- Name: betgroupname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "betgroupname_UNIQUE" ON public."Betgroup" USING btree (betgroupname);


--
-- TOC entry 2832 (class 1259 OID 16556)
-- Name: bracketId_teamId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "bracketId_teamId_UNIQUE" ON public."BracketTeam" USING btree ("bracketId", "teamId");


--
-- TOC entry 2829 (class 1259 OID 16557)
-- Name: bracketname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "bracketname_UNIQUE" ON public."Bracket" USING btree (bracketname);


--
-- TOC entry 2840 (class 1259 OID 16558)
-- Name: phasename_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "phasename_UNIQUE" ON public."Phase" USING btree (phasename);


--
-- TOC entry 2843 (class 1259 OID 16559)
-- Name: rolename_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "rolename_UNIQUE" ON public."Role" USING btree (rolename);


--
-- TOC entry 2837 (class 1259 OID 16560)
-- Name: teamname_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "teamname_UNIQUE" ON public."Team" USING btree (teamname);


--
-- TOC entry 2849 (class 1259 OID 16561)
-- Name: userId_betgroupId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "userId_betgroupId_UNIQUE" ON public."UserBetgroup" USING btree ("userId", "betgroupId");


--
-- TOC entry 2854 (class 1259 OID 16562)
-- Name: userId_roleId_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "userId_roleId_UNIQUE" ON public."UserRole" USING btree ("userId", "roleId");


--
-- TOC entry 2846 (class 1259 OID 16563)
-- Name: username_UNIQUE; Type: INDEX; Schema: public; Owner: tippspiel
--

CREATE UNIQUE INDEX "username_UNIQUE" ON public."User" USING btree (username);


-- Completed on 2021-06-02 21:39:49

--
-- PostgreSQL database dump complete
--

