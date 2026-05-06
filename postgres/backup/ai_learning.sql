--
-- PostgreSQL database dump
--

\restrict 0crGFSRbTj64UYAJR6wdHdQvosWT2v1QPQLdfphoZPTJ5KWnIRlRS2MMqfmii2C

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 16.13

-- Started on 2026-05-03 10:23:32 UTC

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
-- TOC entry 6 (class 2615 OID 16389)
-- Name: ai_learning; Type: SCHEMA; Schema: -; Owner: app_user
--

CREATE SCHEMA ai_learning;


ALTER SCHEMA ai_learning OWNER TO app_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 249 (class 1259 OID 16676)
-- Name: author_topics; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.author_topics (
    author_id bigint NOT NULL,
    topic_id bigint NOT NULL
);


ALTER TABLE ai_learning.author_topics OWNER TO app_user;

--
-- TOC entry 3770 (class 0 OID 0)
-- Dependencies: 249
-- Name: TABLE author_topics; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.author_topics IS 'Many-to-many relationship between authors and their expertise topics.';


--
-- TOC entry 246 (class 1259 OID 16637)
-- Name: authors; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.authors (
    author_id bigint NOT NULL,
    author_name character varying(255) NOT NULL,
    author_profile_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.authors OWNER TO app_user;

--
-- TOC entry 3771 (class 0 OID 0)
-- Dependencies: 246
-- Name: TABLE authors; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.authors IS 'Stores authors, lecturers, instructors, or content creators.';


--
-- TOC entry 245 (class 1259 OID 16636)
-- Name: authors_author_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.authors_author_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.authors_author_id_seq OWNER TO app_user;

--
-- TOC entry 3772 (class 0 OID 0)
-- Dependencies: 245
-- Name: authors_author_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.authors_author_id_seq OWNED BY ai_learning.authors.author_id;


--
-- TOC entry 238 (class 1259 OID 16575)
-- Name: categories; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.categories (
    category_id bigint NOT NULL,
    category_name character varying(150) NOT NULL
);


ALTER TABLE ai_learning.categories OWNER TO app_user;

--
-- TOC entry 3773 (class 0 OID 0)
-- Dependencies: 238
-- Name: TABLE categories; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.categories IS 'Stores broad learning categories such as AI, Machine Learning, Deep Learning.';


--
-- TOC entry 237 (class 1259 OID 16574)
-- Name: categories_category_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.categories_category_id_seq OWNER TO app_user;

--
-- TOC entry 3774 (class 0 OID 0)
-- Dependencies: 237
-- Name: categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.categories_category_id_seq OWNED BY ai_learning.categories.category_id;


--
-- TOC entry 248 (class 1259 OID 16661)
-- Name: channel_authors; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.channel_authors (
    channel_id bigint NOT NULL,
    author_id bigint NOT NULL
);


ALTER TABLE ai_learning.channel_authors OWNER TO app_user;

--
-- TOC entry 3775 (class 0 OID 0)
-- Dependencies: 248
-- Name: TABLE channel_authors; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.channel_authors IS 'Many-to-many relationship between external channels and authors.';


--
-- TOC entry 219 (class 1259 OID 16403)
-- Name: channels; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.channels (
    channel_id bigint NOT NULL,
    platform_id bigint NOT NULL,
    external_channel_id character varying(255) NOT NULL,
    channel_name character varying(255) NOT NULL,
    channel_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.channels OWNER TO app_user;

--
-- TOC entry 3776 (class 0 OID 0)
-- Dependencies: 219
-- Name: TABLE channels; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.channels IS 'Stores YouTube channels or equivalent creator channels from other platforms.';


--
-- TOC entry 218 (class 1259 OID 16402)
-- Name: channels_channel_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.channels_channel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.channels_channel_id_seq OWNER TO app_user;

--
-- TOC entry 3777 (class 0 OID 0)
-- Dependencies: 218
-- Name: channels_channel_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.channels_channel_id_seq OWNED BY ai_learning.channels.channel_id;


--
-- TOC entry 255 (class 1259 OID 16732)
-- Name: course_items; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.course_items (
    course_item_id bigint NOT NULL,
    section_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    item_order integer NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    CONSTRAINT chk_course_item_order CHECK ((item_order > 0))
);


ALTER TABLE ai_learning.course_items OWNER TO app_user;

--
-- TOC entry 3778 (class 0 OID 0)
-- Dependencies: 255
-- Name: TABLE course_items; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.course_items IS 'Stores learning resources arranged inside course sections.';


--
-- TOC entry 254 (class 1259 OID 16731)
-- Name: course_items_course_item_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.course_items_course_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.course_items_course_item_id_seq OWNER TO app_user;

--
-- TOC entry 3779 (class 0 OID 0)
-- Dependencies: 254
-- Name: course_items_course_item_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.course_items_course_item_id_seq OWNED BY ai_learning.course_items.course_item_id;


--
-- TOC entry 253 (class 1259 OID 16715)
-- Name: course_sections; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.course_sections (
    section_id bigint NOT NULL,
    course_id bigint NOT NULL,
    section_title character varying(500) NOT NULL,
    section_order integer NOT NULL,
    CONSTRAINT chk_course_section_order CHECK ((section_order > 0))
);


ALTER TABLE ai_learning.course_sections OWNER TO app_user;

--
-- TOC entry 3780 (class 0 OID 0)
-- Dependencies: 253
-- Name: TABLE course_sections; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.course_sections IS 'Stores sections or chapters inside a course.';


--
-- TOC entry 252 (class 1259 OID 16714)
-- Name: course_sections_section_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.course_sections_section_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.course_sections_section_id_seq OWNER TO app_user;

--
-- TOC entry 3781 (class 0 OID 0)
-- Dependencies: 252
-- Name: course_sections_section_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.course_sections_section_id_seq OWNED BY ai_learning.course_sections.section_id;


--
-- TOC entry 251 (class 1259 OID 16692)
-- Name: courses; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.courses (
    course_id bigint NOT NULL,
    level_id bigint,
    language_id bigint,
    course_title character varying(500) NOT NULL,
    course_description text,
    status character varying(30) DEFAULT 'DRAFT'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_course_status CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying, 'ARCHIVED'::character varying])::text[])))
);


ALTER TABLE ai_learning.courses OWNER TO app_user;

--
-- TOC entry 3782 (class 0 OID 0)
-- Dependencies: 251
-- Name: TABLE courses; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.courses IS 'Stores curated courses created from learning resources.';


--
-- TOC entry 250 (class 1259 OID 16691)
-- Name: courses_course_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.courses_course_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.courses_course_id_seq OWNER TO app_user;

--
-- TOC entry 3783 (class 0 OID 0)
-- Dependencies: 250
-- Name: courses_course_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.courses_course_id_seq OWNED BY ai_learning.courses.course_id;


--
-- TOC entry 233 (class 1259 OID 16517)
-- Name: languages; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.languages (
    language_id bigint NOT NULL,
    language_code character varying(10) NOT NULL,
    language_name character varying(100) NOT NULL
);


ALTER TABLE ai_learning.languages OWNER TO app_user;

--
-- TOC entry 3784 (class 0 OID 0)
-- Dependencies: 233
-- Name: TABLE languages; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.languages IS 'Stores supported languages such as English, Vietnamese, Chinese.';


--
-- TOC entry 232 (class 1259 OID 16516)
-- Name: languages_language_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.languages_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.languages_language_id_seq OWNER TO app_user;

--
-- TOC entry 3785 (class 0 OID 0)
-- Dependencies: 232
-- Name: languages_language_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.languages_language_id_seq OWNED BY ai_learning.languages.language_id;


--
-- TOC entry 259 (class 1259 OID 16778)
-- Name: learning_path_items; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.learning_path_items (
    path_item_id bigint NOT NULL,
    path_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    item_order integer NOT NULL,
    CONSTRAINT chk_learning_path_item_order CHECK ((item_order > 0))
);


ALTER TABLE ai_learning.learning_path_items OWNER TO app_user;

--
-- TOC entry 3786 (class 0 OID 0)
-- Dependencies: 259
-- Name: TABLE learning_path_items; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.learning_path_items IS 'Stores ordered resources inside a learning path.';


--
-- TOC entry 258 (class 1259 OID 16777)
-- Name: learning_path_items_path_item_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.learning_path_items_path_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.learning_path_items_path_item_id_seq OWNER TO app_user;

--
-- TOC entry 3787 (class 0 OID 0)
-- Dependencies: 258
-- Name: learning_path_items_path_item_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.learning_path_items_path_item_id_seq OWNED BY ai_learning.learning_path_items.path_item_id;


--
-- TOC entry 257 (class 1259 OID 16755)
-- Name: learning_paths; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.learning_paths (
    path_id bigint NOT NULL,
    level_id bigint,
    language_id bigint,
    path_title character varying(500) NOT NULL,
    path_description text,
    status character varying(30) DEFAULT 'DRAFT'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_learning_path_status CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PUBLISHED'::character varying, 'ARCHIVED'::character varying])::text[])))
);


ALTER TABLE ai_learning.learning_paths OWNER TO app_user;

--
-- TOC entry 3788 (class 0 OID 0)
-- Dependencies: 257
-- Name: TABLE learning_paths; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.learning_paths IS 'Stores learning roadmaps such as AI Beginner Roadmap or LLM Learning Path.';


--
-- TOC entry 256 (class 1259 OID 16754)
-- Name: learning_paths_path_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.learning_paths_path_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.learning_paths_path_id_seq OWNER TO app_user;

--
-- TOC entry 3789 (class 0 OID 0)
-- Dependencies: 256
-- Name: learning_paths_path_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.learning_paths_path_id_seq OWNED BY ai_learning.learning_paths.path_id;


--
-- TOC entry 235 (class 1259 OID 16528)
-- Name: learning_resources; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.learning_resources (
    resource_id bigint NOT NULL,
    resource_type_id bigint NOT NULL,
    level_id bigint,
    language_id bigint,
    resource_title character varying(500) NOT NULL,
    resource_description text,
    estimated_minutes integer,
    quality_score numeric(4,2),
    status character varying(30) DEFAULT 'PENDING'::character varying NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_resource_estimated_minutes CHECK (((estimated_minutes IS NULL) OR (estimated_minutes >= 0))),
    CONSTRAINT chk_resource_quality_score CHECK (((quality_score IS NULL) OR ((quality_score >= (0)::numeric) AND (quality_score <= (10)::numeric)))),
    CONSTRAINT chk_resource_status CHECK (((status)::text = ANY ((ARRAY['DRAFT'::character varying, 'PENDING'::character varying, 'APPROVED'::character varying, 'REJECTED'::character varying, 'ARCHIVED'::character varying])::text[])))
);


ALTER TABLE ai_learning.learning_resources OWNER TO app_user;

--
-- TOC entry 3790 (class 0 OID 0)
-- Dependencies: 235
-- Name: TABLE learning_resources; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.learning_resources IS 'Stores curated learning resources after normalization from external sources.';


--
-- TOC entry 234 (class 1259 OID 16527)
-- Name: learning_resources_resource_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.learning_resources_resource_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.learning_resources_resource_id_seq OWNER TO app_user;

--
-- TOC entry 3791 (class 0 OID 0)
-- Dependencies: 234
-- Name: learning_resources_resource_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.learning_resources_resource_id_seq OWNED BY ai_learning.learning_resources.resource_id;


--
-- TOC entry 231 (class 1259 OID 16505)
-- Name: levels; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.levels (
    level_id bigint NOT NULL,
    level_name character varying(100) NOT NULL,
    level_order integer NOT NULL,
    CONSTRAINT chk_level_order CHECK ((level_order > 0))
);


ALTER TABLE ai_learning.levels OWNER TO app_user;

--
-- TOC entry 3792 (class 0 OID 0)
-- Dependencies: 231
-- Name: TABLE levels; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.levels IS 'Stores learning difficulty levels such as Beginner, Intermediate, Advanced.';


--
-- TOC entry 230 (class 1259 OID 16504)
-- Name: levels_level_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.levels_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.levels_level_id_seq OWNER TO app_user;

--
-- TOC entry 3793 (class 0 OID 0)
-- Dependencies: 230
-- Name: levels_level_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.levels_level_id_seq OWNED BY ai_learning.levels.level_id;


--
-- TOC entry 217 (class 1259 OID 16391)
-- Name: platforms; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.platforms (
    platform_id bigint NOT NULL,
    platform_name character varying(100) NOT NULL,
    platform_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.platforms OWNER TO app_user;

--
-- TOC entry 3794 (class 0 OID 0)
-- Dependencies: 217
-- Name: TABLE platforms; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.platforms IS 'Stores learning platforms such as YouTube, Coursera, GitHub, Medium.';


--
-- TOC entry 3795 (class 0 OID 0)
-- Dependencies: 217
-- Name: COLUMN platforms.platform_name; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON COLUMN ai_learning.platforms.platform_name IS 'Unique name of the platform. Example: YouTube.';


--
-- TOC entry 216 (class 1259 OID 16390)
-- Name: platforms_platform_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.platforms_platform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.platforms_platform_id_seq OWNER TO app_user;

--
-- TOC entry 3796 (class 0 OID 0)
-- Dependencies: 216
-- Name: platforms_platform_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.platforms_platform_id_seq OWNED BY ai_learning.platforms.platform_id;


--
-- TOC entry 221 (class 1259 OID 16420)
-- Name: playlists; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.playlists (
    playlist_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    external_playlist_id character varying(255) NOT NULL,
    playlist_title character varying(500) NOT NULL,
    playlist_url text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.playlists OWNER TO app_user;

--
-- TOC entry 3797 (class 0 OID 0)
-- Dependencies: 221
-- Name: TABLE playlists; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.playlists IS 'Stores playlists collected from external platforms such as YouTube playlists.';


--
-- TOC entry 220 (class 1259 OID 16419)
-- Name: playlists_playlist_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.playlists_playlist_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.playlists_playlist_id_seq OWNER TO app_user;

--
-- TOC entry 3798 (class 0 OID 0)
-- Dependencies: 220
-- Name: playlists_playlist_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.playlists_playlist_id_seq OWNED BY ai_learning.playlists.playlist_id;


--
-- TOC entry 247 (class 1259 OID 16646)
-- Name: resource_authors; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.resource_authors (
    resource_id bigint NOT NULL,
    author_id bigint NOT NULL,
    author_role character varying(100)
);


ALTER TABLE ai_learning.resource_authors OWNER TO app_user;

--
-- TOC entry 3799 (class 0 OID 0)
-- Dependencies: 247
-- Name: TABLE resource_authors; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.resource_authors IS 'Many-to-many relationship between learning resources and authors.';


--
-- TOC entry 244 (class 1259 OID 16621)
-- Name: resource_skills; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.resource_skills (
    resource_id bigint NOT NULL,
    skill_id bigint NOT NULL
);


ALTER TABLE ai_learning.resource_skills OWNER TO app_user;

--
-- TOC entry 3800 (class 0 OID 0)
-- Dependencies: 244
-- Name: TABLE resource_skills; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.resource_skills IS 'Many-to-many relationship between learning resources and skills.';


--
-- TOC entry 236 (class 1259 OID 16557)
-- Name: resource_sources; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.resource_sources (
    resource_id bigint NOT NULL,
    video_id bigint NOT NULL,
    source_note text
);


ALTER TABLE ai_learning.resource_sources OWNER TO app_user;

--
-- TOC entry 3801 (class 0 OID 0)
-- Dependencies: 236
-- Name: TABLE resource_sources; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.resource_sources IS 'Associates normalized learning resources with their original video sources.';


--
-- TOC entry 241 (class 1259 OID 16597)
-- Name: resource_topics; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.resource_topics (
    resource_id bigint NOT NULL,
    topic_id bigint NOT NULL
);


ALTER TABLE ai_learning.resource_topics OWNER TO app_user;

--
-- TOC entry 3802 (class 0 OID 0)
-- Dependencies: 241
-- Name: TABLE resource_topics; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.resource_topics IS 'Many-to-many relationship between learning resources and topics.';


--
-- TOC entry 229 (class 1259 OID 16496)
-- Name: resource_types; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.resource_types (
    resource_type_id bigint NOT NULL,
    resource_type_name character varying(100) NOT NULL
);


ALTER TABLE ai_learning.resource_types OWNER TO app_user;

--
-- TOC entry 3803 (class 0 OID 0)
-- Dependencies: 229
-- Name: TABLE resource_types; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.resource_types IS 'Stores resource types such as VIDEO, ARTICLE, PDF, REPOSITORY, COURSE.';


--
-- TOC entry 228 (class 1259 OID 16495)
-- Name: resource_types_resource_type_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.resource_types_resource_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.resource_types_resource_type_id_seq OWNER TO app_user;

--
-- TOC entry 3804 (class 0 OID 0)
-- Dependencies: 228
-- Name: resource_types_resource_type_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.resource_types_resource_type_id_seq OWNED BY ai_learning.resource_types.resource_type_id;


--
-- TOC entry 243 (class 1259 OID 16613)
-- Name: skills; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.skills (
    skill_id bigint NOT NULL,
    skill_name character varying(150) NOT NULL
);


ALTER TABLE ai_learning.skills OWNER TO app_user;

--
-- TOC entry 3805 (class 0 OID 0)
-- Dependencies: 243
-- Name: TABLE skills; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.skills IS 'Stores skills that can be learned from resources, such as prompt engineering or model evaluation.';


--
-- TOC entry 242 (class 1259 OID 16612)
-- Name: skills_skill_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.skills_skill_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.skills_skill_id_seq OWNER TO app_user;

--
-- TOC entry 3806 (class 0 OID 0)
-- Dependencies: 242
-- Name: skills_skill_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.skills_skill_id_seq OWNED BY ai_learning.skills.skill_id;


--
-- TOC entry 240 (class 1259 OID 16584)
-- Name: topics; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.topics (
    topic_id bigint NOT NULL,
    category_id bigint NOT NULL,
    topic_name character varying(150) NOT NULL
);


ALTER TABLE ai_learning.topics OWNER TO app_user;

--
-- TOC entry 3807 (class 0 OID 0)
-- Dependencies: 240
-- Name: TABLE topics; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.topics IS 'Stores specific topics such as LLM, RAG, Transformer, CNN.';


--
-- TOC entry 239 (class 1259 OID 16583)
-- Name: topics_topic_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.topics_topic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.topics_topic_id_seq OWNER TO app_user;

--
-- TOC entry 3808 (class 0 OID 0)
-- Dependencies: 239
-- Name: topics_topic_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.topics_topic_id_seq OWNED BY ai_learning.topics.topic_id;


--
-- TOC entry 227 (class 1259 OID 16479)
-- Name: transcripts; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.transcripts (
    transcript_id bigint NOT NULL,
    video_id bigint NOT NULL,
    language_code character varying(10) NOT NULL,
    transcript_text text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.transcripts OWNER TO app_user;

--
-- TOC entry 3809 (class 0 OID 0)
-- Dependencies: 227
-- Name: TABLE transcripts; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.transcripts IS 'Stores video transcripts or subtitles by language.';


--
-- TOC entry 226 (class 1259 OID 16478)
-- Name: transcripts_transcript_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.transcripts_transcript_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.transcripts_transcript_id_seq OWNER TO app_user;

--
-- TOC entry 3810 (class 0 OID 0)
-- Dependencies: 226
-- Name: transcripts_transcript_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.transcripts_transcript_id_seq OWNED BY ai_learning.transcripts.transcript_id;


--
-- TOC entry 263 (class 1259 OID 16827)
-- Name: user_learning_progress; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.user_learning_progress (
    user_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    progress_percent numeric(5,2) DEFAULT 0 NOT NULL,
    last_position_seconds integer DEFAULT 0 NOT NULL,
    completed_at timestamp without time zone,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_last_position_seconds CHECK ((last_position_seconds >= 0)),
    CONSTRAINT chk_progress_percent CHECK (((progress_percent >= (0)::numeric) AND (progress_percent <= (100)::numeric)))
);


ALTER TABLE ai_learning.user_learning_progress OWNER TO app_user;

--
-- TOC entry 3811 (class 0 OID 0)
-- Dependencies: 263
-- Name: TABLE user_learning_progress; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.user_learning_progress IS 'Stores each user learning progress for each resource.';


--
-- TOC entry 265 (class 1259 OID 16848)
-- Name: user_notes; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.user_notes (
    note_id bigint NOT NULL,
    user_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    note_content text NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.user_notes OWNER TO app_user;

--
-- TOC entry 3812 (class 0 OID 0)
-- Dependencies: 265
-- Name: TABLE user_notes; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.user_notes IS 'Stores personal notes written by users for learning resources.';


--
-- TOC entry 264 (class 1259 OID 16847)
-- Name: user_notes_note_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.user_notes_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.user_notes_note_id_seq OWNER TO app_user;

--
-- TOC entry 3813 (class 0 OID 0)
-- Dependencies: 264
-- Name: user_notes_note_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.user_notes_note_id_seq OWNED BY ai_learning.user_notes.note_id;


--
-- TOC entry 262 (class 1259 OID 16811)
-- Name: user_saved_resources; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.user_saved_resources (
    user_id bigint NOT NULL,
    resource_id bigint NOT NULL,
    saved_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.user_saved_resources OWNER TO app_user;

--
-- TOC entry 3814 (class 0 OID 0)
-- Dependencies: 262
-- Name: TABLE user_saved_resources; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.user_saved_resources IS 'Stores learning resources saved by users.';


--
-- TOC entry 261 (class 1259 OID 16800)
-- Name: users; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.users (
    user_id bigint NOT NULL,
    email character varying(255) NOT NULL,
    full_name character varying(255) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE ai_learning.users OWNER TO app_user;

--
-- TOC entry 3815 (class 0 OID 0)
-- Dependencies: 261
-- Name: TABLE users; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.users IS 'Stores learners who use the learning resource system.';


--
-- TOC entry 260 (class 1259 OID 16799)
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.users_user_id_seq OWNER TO app_user;

--
-- TOC entry 3816 (class 0 OID 0)
-- Dependencies: 260
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.users_user_id_seq OWNED BY ai_learning.users.user_id;


--
-- TOC entry 225 (class 1259 OID 16460)
-- Name: video_statistics; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.video_statistics (
    statistic_id bigint NOT NULL,
    video_id bigint NOT NULL,
    collected_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    view_count bigint DEFAULT 0 NOT NULL,
    like_count bigint DEFAULT 0 NOT NULL,
    comment_count bigint DEFAULT 0 NOT NULL,
    CONSTRAINT chk_video_statistics_non_negative CHECK (((view_count >= 0) AND (like_count >= 0) AND (comment_count >= 0)))
);


ALTER TABLE ai_learning.video_statistics OWNER TO app_user;

--
-- TOC entry 3817 (class 0 OID 0)
-- Dependencies: 225
-- Name: TABLE video_statistics; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.video_statistics IS 'Stores historical statistics of videos at different collection times.';


--
-- TOC entry 224 (class 1259 OID 16459)
-- Name: video_statistics_statistic_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.video_statistics_statistic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.video_statistics_statistic_id_seq OWNER TO app_user;

--
-- TOC entry 3818 (class 0 OID 0)
-- Dependencies: 224
-- Name: video_statistics_statistic_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.video_statistics_statistic_id_seq OWNED BY ai_learning.video_statistics.statistic_id;


--
-- TOC entry 223 (class 1259 OID 16437)
-- Name: videos; Type: TABLE; Schema: ai_learning; Owner: app_user
--

CREATE TABLE ai_learning.videos (
    video_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    playlist_id bigint,
    external_video_id character varying(255) NOT NULL,
    video_title character varying(500) NOT NULL,
    video_description text,
    video_url text NOT NULL,
    thumbnail_url text,
    duration_seconds integer,
    published_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT chk_video_duration CHECK (((duration_seconds IS NULL) OR (duration_seconds >= 0)))
);


ALTER TABLE ai_learning.videos OWNER TO app_user;

--
-- TOC entry 3819 (class 0 OID 0)
-- Dependencies: 223
-- Name: TABLE videos; Type: COMMENT; Schema: ai_learning; Owner: app_user
--

COMMENT ON TABLE ai_learning.videos IS 'Stores metadata of external videos, mainly YouTube videos.';


--
-- TOC entry 222 (class 1259 OID 16436)
-- Name: videos_video_id_seq; Type: SEQUENCE; Schema: ai_learning; Owner: app_user
--

CREATE SEQUENCE ai_learning.videos_video_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE ai_learning.videos_video_id_seq OWNER TO app_user;

--
-- TOC entry 3820 (class 0 OID 0)
-- Dependencies: 222
-- Name: videos_video_id_seq; Type: SEQUENCE OWNED BY; Schema: ai_learning; Owner: app_user
--

ALTER SEQUENCE ai_learning.videos_video_id_seq OWNED BY ai_learning.videos.video_id;


--
-- TOC entry 3425 (class 2604 OID 16640)
-- Name: authors author_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.authors ALTER COLUMN author_id SET DEFAULT nextval('ai_learning.authors_author_id_seq'::regclass);


--
-- TOC entry 3422 (class 2604 OID 16578)
-- Name: categories category_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.categories ALTER COLUMN category_id SET DEFAULT nextval('ai_learning.categories_category_id_seq'::regclass);


--
-- TOC entry 3402 (class 2604 OID 16406)
-- Name: channels channel_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channels ALTER COLUMN channel_id SET DEFAULT nextval('ai_learning.channels_channel_id_seq'::regclass);


--
-- TOC entry 3432 (class 2604 OID 16735)
-- Name: course_items course_item_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items ALTER COLUMN course_item_id SET DEFAULT nextval('ai_learning.course_items_course_item_id_seq'::regclass);


--
-- TOC entry 3431 (class 2604 OID 16718)
-- Name: course_sections section_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_sections ALTER COLUMN section_id SET DEFAULT nextval('ai_learning.course_sections_section_id_seq'::regclass);


--
-- TOC entry 3427 (class 2604 OID 16695)
-- Name: courses course_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.courses ALTER COLUMN course_id SET DEFAULT nextval('ai_learning.courses_course_id_seq'::regclass);


--
-- TOC entry 3417 (class 2604 OID 16520)
-- Name: languages language_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.languages ALTER COLUMN language_id SET DEFAULT nextval('ai_learning.languages_language_id_seq'::regclass);


--
-- TOC entry 3438 (class 2604 OID 16781)
-- Name: learning_path_items path_item_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items ALTER COLUMN path_item_id SET DEFAULT nextval('ai_learning.learning_path_items_path_item_id_seq'::regclass);


--
-- TOC entry 3434 (class 2604 OID 16758)
-- Name: learning_paths path_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_paths ALTER COLUMN path_id SET DEFAULT nextval('ai_learning.learning_paths_path_id_seq'::regclass);


--
-- TOC entry 3418 (class 2604 OID 16531)
-- Name: learning_resources resource_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_resources ALTER COLUMN resource_id SET DEFAULT nextval('ai_learning.learning_resources_resource_id_seq'::regclass);


--
-- TOC entry 3416 (class 2604 OID 16508)
-- Name: levels level_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.levels ALTER COLUMN level_id SET DEFAULT nextval('ai_learning.levels_level_id_seq'::regclass);


--
-- TOC entry 3400 (class 2604 OID 16394)
-- Name: platforms platform_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.platforms ALTER COLUMN platform_id SET DEFAULT nextval('ai_learning.platforms_platform_id_seq'::regclass);


--
-- TOC entry 3404 (class 2604 OID 16423)
-- Name: playlists playlist_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.playlists ALTER COLUMN playlist_id SET DEFAULT nextval('ai_learning.playlists_playlist_id_seq'::regclass);


--
-- TOC entry 3415 (class 2604 OID 16499)
-- Name: resource_types resource_type_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_types ALTER COLUMN resource_type_id SET DEFAULT nextval('ai_learning.resource_types_resource_type_id_seq'::regclass);


--
-- TOC entry 3424 (class 2604 OID 16616)
-- Name: skills skill_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.skills ALTER COLUMN skill_id SET DEFAULT nextval('ai_learning.skills_skill_id_seq'::regclass);


--
-- TOC entry 3423 (class 2604 OID 16587)
-- Name: topics topic_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.topics ALTER COLUMN topic_id SET DEFAULT nextval('ai_learning.topics_topic_id_seq'::regclass);


--
-- TOC entry 3413 (class 2604 OID 16482)
-- Name: transcripts transcript_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.transcripts ALTER COLUMN transcript_id SET DEFAULT nextval('ai_learning.transcripts_transcript_id_seq'::regclass);


--
-- TOC entry 3445 (class 2604 OID 16851)
-- Name: user_notes note_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_notes ALTER COLUMN note_id SET DEFAULT nextval('ai_learning.user_notes_note_id_seq'::regclass);


--
-- TOC entry 3439 (class 2604 OID 16803)
-- Name: users user_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.users ALTER COLUMN user_id SET DEFAULT nextval('ai_learning.users_user_id_seq'::regclass);


--
-- TOC entry 3408 (class 2604 OID 16463)
-- Name: video_statistics statistic_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.video_statistics ALTER COLUMN statistic_id SET DEFAULT nextval('ai_learning.video_statistics_statistic_id_seq'::regclass);


--
-- TOC entry 3406 (class 2604 OID 16440)
-- Name: videos video_id; Type: DEFAULT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.videos ALTER COLUMN video_id SET DEFAULT nextval('ai_learning.videos_video_id_seq'::regclass);


--
-- TOC entry 3536 (class 2606 OID 16645)
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (author_id);


--
-- TOC entry 3517 (class 2606 OID 16580)
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- TOC entry 3466 (class 2606 OID 16411)
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (channel_id);


--
-- TOC entry 3554 (class 2606 OID 16739)
-- Name: course_items course_items_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items
    ADD CONSTRAINT course_items_pkey PRIMARY KEY (course_item_id);


--
-- TOC entry 3549 (class 2606 OID 16723)
-- Name: course_sections course_sections_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_sections
    ADD CONSTRAINT course_sections_pkey PRIMARY KEY (section_id);


--
-- TOC entry 3547 (class 2606 OID 16703)
-- Name: courses courses_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (course_id);


--
-- TOC entry 3503 (class 2606 OID 16522)
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (language_id);


--
-- TOC entry 3566 (class 2606 OID 16784)
-- Name: learning_path_items learning_path_items_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items
    ADD CONSTRAINT learning_path_items_pkey PRIMARY KEY (path_item_id);


--
-- TOC entry 3562 (class 2606 OID 16766)
-- Name: learning_paths learning_paths_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_paths
    ADD CONSTRAINT learning_paths_pkey PRIMARY KEY (path_id);


--
-- TOC entry 3513 (class 2606 OID 16541)
-- Name: learning_resources learning_resources_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_resources
    ADD CONSTRAINT learning_resources_pkey PRIMARY KEY (resource_id);


--
-- TOC entry 3497 (class 2606 OID 16511)
-- Name: levels levels_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.levels
    ADD CONSTRAINT levels_pkey PRIMARY KEY (level_id);


--
-- TOC entry 3545 (class 2606 OID 16680)
-- Name: author_topics pk_author_topics; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.author_topics
    ADD CONSTRAINT pk_author_topics PRIMARY KEY (author_id, topic_id);


--
-- TOC entry 3542 (class 2606 OID 16665)
-- Name: channel_authors pk_channel_authors; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channel_authors
    ADD CONSTRAINT pk_channel_authors PRIMARY KEY (channel_id, author_id);


--
-- TOC entry 3539 (class 2606 OID 16650)
-- Name: resource_authors pk_resource_authors; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_authors
    ADD CONSTRAINT pk_resource_authors PRIMARY KEY (resource_id, author_id);


--
-- TOC entry 3534 (class 2606 OID 16625)
-- Name: resource_skills pk_resource_skills; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_skills
    ADD CONSTRAINT pk_resource_skills PRIMARY KEY (resource_id, skill_id);


--
-- TOC entry 3515 (class 2606 OID 16563)
-- Name: resource_sources pk_resource_sources; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_sources
    ADD CONSTRAINT pk_resource_sources PRIMARY KEY (resource_id, video_id);


--
-- TOC entry 3527 (class 2606 OID 16601)
-- Name: resource_topics pk_resource_topics; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_topics
    ADD CONSTRAINT pk_resource_topics PRIMARY KEY (resource_id, topic_id);


--
-- TOC entry 3580 (class 2606 OID 16836)
-- Name: user_learning_progress pk_user_learning_progress; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_learning_progress
    ADD CONSTRAINT pk_user_learning_progress PRIMARY KEY (user_id, resource_id);


--
-- TOC entry 3577 (class 2606 OID 16816)
-- Name: user_saved_resources pk_user_saved_resources; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_saved_resources
    ADD CONSTRAINT pk_user_saved_resources PRIMARY KEY (user_id, resource_id);


--
-- TOC entry 3462 (class 2606 OID 16399)
-- Name: platforms platforms_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.platforms
    ADD CONSTRAINT platforms_pkey PRIMARY KEY (platform_id);


--
-- TOC entry 3472 (class 2606 OID 16428)
-- Name: playlists playlists_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.playlists
    ADD CONSTRAINT playlists_pkey PRIMARY KEY (playlist_id);


--
-- TOC entry 3493 (class 2606 OID 16501)
-- Name: resource_types resource_types_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_types
    ADD CONSTRAINT resource_types_pkey PRIMARY KEY (resource_type_id);


--
-- TOC entry 3529 (class 2606 OID 16618)
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (skill_id);


--
-- TOC entry 3522 (class 2606 OID 16589)
-- Name: topics topics_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.topics
    ADD CONSTRAINT topics_pkey PRIMARY KEY (topic_id);


--
-- TOC entry 3489 (class 2606 OID 16487)
-- Name: transcripts transcripts_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.transcripts
    ADD CONSTRAINT transcripts_pkey PRIMARY KEY (transcript_id);


--
-- TOC entry 3519 (class 2606 OID 16582)
-- Name: categories uq_category_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.categories
    ADD CONSTRAINT uq_category_name UNIQUE (category_name);


--
-- TOC entry 3469 (class 2606 OID 16413)
-- Name: channels uq_channel_external; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channels
    ADD CONSTRAINT uq_channel_external UNIQUE (platform_id, external_channel_id);


--
-- TOC entry 3558 (class 2606 OID 16741)
-- Name: course_items uq_course_item_order; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items
    ADD CONSTRAINT uq_course_item_order UNIQUE (section_id, item_order);


--
-- TOC entry 3560 (class 2606 OID 16743)
-- Name: course_items uq_course_item_resource; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items
    ADD CONSTRAINT uq_course_item_resource UNIQUE (section_id, resource_id);


--
-- TOC entry 3552 (class 2606 OID 16725)
-- Name: course_sections uq_course_section_order; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_sections
    ADD CONSTRAINT uq_course_section_order UNIQUE (course_id, section_order);


--
-- TOC entry 3505 (class 2606 OID 16524)
-- Name: languages uq_language_code; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.languages
    ADD CONSTRAINT uq_language_code UNIQUE (language_code);


--
-- TOC entry 3507 (class 2606 OID 16526)
-- Name: languages uq_language_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.languages
    ADD CONSTRAINT uq_language_name UNIQUE (language_name);


--
-- TOC entry 3568 (class 2606 OID 16786)
-- Name: learning_path_items uq_learning_path_item_order; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items
    ADD CONSTRAINT uq_learning_path_item_order UNIQUE (path_id, item_order);


--
-- TOC entry 3570 (class 2606 OID 16788)
-- Name: learning_path_items uq_learning_path_item_resource; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items
    ADD CONSTRAINT uq_learning_path_item_resource UNIQUE (path_id, resource_id);


--
-- TOC entry 3499 (class 2606 OID 16513)
-- Name: levels uq_level_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.levels
    ADD CONSTRAINT uq_level_name UNIQUE (level_name);


--
-- TOC entry 3501 (class 2606 OID 16515)
-- Name: levels uq_level_order; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.levels
    ADD CONSTRAINT uq_level_order UNIQUE (level_order);


--
-- TOC entry 3464 (class 2606 OID 16401)
-- Name: platforms uq_platform_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.platforms
    ADD CONSTRAINT uq_platform_name UNIQUE (platform_name);


--
-- TOC entry 3474 (class 2606 OID 16430)
-- Name: playlists uq_playlist_external; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.playlists
    ADD CONSTRAINT uq_playlist_external UNIQUE (channel_id, external_playlist_id);


--
-- TOC entry 3495 (class 2606 OID 16503)
-- Name: resource_types uq_resource_type_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_types
    ADD CONSTRAINT uq_resource_type_name UNIQUE (resource_type_name);


--
-- TOC entry 3531 (class 2606 OID 16620)
-- Name: skills uq_skill_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.skills
    ADD CONSTRAINT uq_skill_name UNIQUE (skill_name);


--
-- TOC entry 3524 (class 2606 OID 16591)
-- Name: topics uq_topic_category_name; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.topics
    ADD CONSTRAINT uq_topic_category_name UNIQUE (category_id, topic_name);


--
-- TOC entry 3491 (class 2606 OID 16489)
-- Name: transcripts uq_transcript_video_language; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.transcripts
    ADD CONSTRAINT uq_transcript_video_language UNIQUE (video_id, language_code);


--
-- TOC entry 3572 (class 2606 OID 16810)
-- Name: users uq_users_email; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.users
    ADD CONSTRAINT uq_users_email UNIQUE (email);


--
-- TOC entry 3479 (class 2606 OID 16448)
-- Name: videos uq_video_external; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.videos
    ADD CONSTRAINT uq_video_external UNIQUE (channel_id, external_video_id);


--
-- TOC entry 3484 (class 2606 OID 16472)
-- Name: video_statistics uq_video_statistics_time; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.video_statistics
    ADD CONSTRAINT uq_video_statistics_time UNIQUE (video_id, collected_at);


--
-- TOC entry 3584 (class 2606 OID 16857)
-- Name: user_notes user_notes_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_notes
    ADD CONSTRAINT user_notes_pkey PRIMARY KEY (note_id);


--
-- TOC entry 3574 (class 2606 OID 16808)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- TOC entry 3486 (class 2606 OID 16470)
-- Name: video_statistics video_statistics_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.video_statistics
    ADD CONSTRAINT video_statistics_pkey PRIMARY KEY (statistic_id);


--
-- TOC entry 3481 (class 2606 OID 16446)
-- Name: videos videos_pkey; Type: CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.videos
    ADD CONSTRAINT videos_pkey PRIMARY KEY (video_id);


--
-- TOC entry 3543 (class 1259 OID 16884)
-- Name: idx_author_topics_topic_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_author_topics_topic_id ON ai_learning.author_topics USING btree (topic_id);


--
-- TOC entry 3540 (class 1259 OID 16883)
-- Name: idx_channel_authors_author_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_channel_authors_author_id ON ai_learning.channel_authors USING btree (author_id);


--
-- TOC entry 3467 (class 1259 OID 16868)
-- Name: idx_channels_platform_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_channels_platform_id ON ai_learning.channels USING btree (platform_id);


--
-- TOC entry 3555 (class 1259 OID 16887)
-- Name: idx_course_items_resource_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_course_items_resource_id ON ai_learning.course_items USING btree (resource_id);


--
-- TOC entry 3556 (class 1259 OID 16886)
-- Name: idx_course_items_section_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_course_items_section_id ON ai_learning.course_items USING btree (section_id);


--
-- TOC entry 3550 (class 1259 OID 16885)
-- Name: idx_course_sections_course_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_course_sections_course_id ON ai_learning.course_sections USING btree (course_id);


--
-- TOC entry 3563 (class 1259 OID 16888)
-- Name: idx_learning_path_items_path_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_path_items_path_id ON ai_learning.learning_path_items USING btree (path_id);


--
-- TOC entry 3564 (class 1259 OID 16889)
-- Name: idx_learning_path_items_resource_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_path_items_resource_id ON ai_learning.learning_path_items USING btree (resource_id);


--
-- TOC entry 3508 (class 1259 OID 16877)
-- Name: idx_learning_resources_language_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_resources_language_id ON ai_learning.learning_resources USING btree (language_id);


--
-- TOC entry 3509 (class 1259 OID 16876)
-- Name: idx_learning_resources_level_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_resources_level_id ON ai_learning.learning_resources USING btree (level_id);


--
-- TOC entry 3510 (class 1259 OID 16878)
-- Name: idx_learning_resources_status; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_resources_status ON ai_learning.learning_resources USING btree (status);


--
-- TOC entry 3511 (class 1259 OID 16875)
-- Name: idx_learning_resources_type_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_learning_resources_type_id ON ai_learning.learning_resources USING btree (resource_type_id);


--
-- TOC entry 3470 (class 1259 OID 16869)
-- Name: idx_playlists_channel_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_playlists_channel_id ON ai_learning.playlists USING btree (channel_id);


--
-- TOC entry 3537 (class 1259 OID 16882)
-- Name: idx_resource_authors_author_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_resource_authors_author_id ON ai_learning.resource_authors USING btree (author_id);


--
-- TOC entry 3532 (class 1259 OID 16881)
-- Name: idx_resource_skills_skill_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_resource_skills_skill_id ON ai_learning.resource_skills USING btree (skill_id);


--
-- TOC entry 3525 (class 1259 OID 16880)
-- Name: idx_resource_topics_topic_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_resource_topics_topic_id ON ai_learning.resource_topics USING btree (topic_id);


--
-- TOC entry 3520 (class 1259 OID 16879)
-- Name: idx_topics_category_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_topics_category_id ON ai_learning.topics USING btree (category_id);


--
-- TOC entry 3487 (class 1259 OID 16874)
-- Name: idx_transcripts_video_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_transcripts_video_id ON ai_learning.transcripts USING btree (video_id);


--
-- TOC entry 3578 (class 1259 OID 16891)
-- Name: idx_user_learning_progress_resource_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_user_learning_progress_resource_id ON ai_learning.user_learning_progress USING btree (resource_id);


--
-- TOC entry 3581 (class 1259 OID 16893)
-- Name: idx_user_notes_resource_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_user_notes_resource_id ON ai_learning.user_notes USING btree (resource_id);


--
-- TOC entry 3582 (class 1259 OID 16892)
-- Name: idx_user_notes_user_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_user_notes_user_id ON ai_learning.user_notes USING btree (user_id);


--
-- TOC entry 3575 (class 1259 OID 16890)
-- Name: idx_user_saved_resources_resource_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_user_saved_resources_resource_id ON ai_learning.user_saved_resources USING btree (resource_id);


--
-- TOC entry 3482 (class 1259 OID 16873)
-- Name: idx_video_statistics_video_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_video_statistics_video_id ON ai_learning.video_statistics USING btree (video_id);


--
-- TOC entry 3475 (class 1259 OID 16870)
-- Name: idx_videos_channel_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_videos_channel_id ON ai_learning.videos USING btree (channel_id);


--
-- TOC entry 3476 (class 1259 OID 16871)
-- Name: idx_videos_playlist_id; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_videos_playlist_id ON ai_learning.videos USING btree (playlist_id);


--
-- TOC entry 3477 (class 1259 OID 16872)
-- Name: idx_videos_published_at; Type: INDEX; Schema: ai_learning; Owner: app_user
--

CREATE INDEX idx_videos_published_at ON ai_learning.videos USING btree (published_at);


--
-- TOC entry 3605 (class 2606 OID 16681)
-- Name: author_topics fk_author_topics_author; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.author_topics
    ADD CONSTRAINT fk_author_topics_author FOREIGN KEY (author_id) REFERENCES ai_learning.authors(author_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3606 (class 2606 OID 16686)
-- Name: author_topics fk_author_topics_topic; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.author_topics
    ADD CONSTRAINT fk_author_topics_topic FOREIGN KEY (topic_id) REFERENCES ai_learning.topics(topic_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3603 (class 2606 OID 16671)
-- Name: channel_authors fk_channel_authors_author; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channel_authors
    ADD CONSTRAINT fk_channel_authors_author FOREIGN KEY (author_id) REFERENCES ai_learning.authors(author_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3604 (class 2606 OID 16666)
-- Name: channel_authors fk_channel_authors_channel; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channel_authors
    ADD CONSTRAINT fk_channel_authors_channel FOREIGN KEY (channel_id) REFERENCES ai_learning.channels(channel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3585 (class 2606 OID 16414)
-- Name: channels fk_channels_platform; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.channels
    ADD CONSTRAINT fk_channels_platform FOREIGN KEY (platform_id) REFERENCES ai_learning.platforms(platform_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3610 (class 2606 OID 16749)
-- Name: course_items fk_course_items_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items
    ADD CONSTRAINT fk_course_items_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3611 (class 2606 OID 16744)
-- Name: course_items fk_course_items_section; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_items
    ADD CONSTRAINT fk_course_items_section FOREIGN KEY (section_id) REFERENCES ai_learning.course_sections(section_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3609 (class 2606 OID 16726)
-- Name: course_sections fk_course_sections_course; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.course_sections
    ADD CONSTRAINT fk_course_sections_course FOREIGN KEY (course_id) REFERENCES ai_learning.courses(course_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3607 (class 2606 OID 16709)
-- Name: courses fk_courses_language; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.courses
    ADD CONSTRAINT fk_courses_language FOREIGN KEY (language_id) REFERENCES ai_learning.languages(language_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3608 (class 2606 OID 16704)
-- Name: courses fk_courses_level; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.courses
    ADD CONSTRAINT fk_courses_level FOREIGN KEY (level_id) REFERENCES ai_learning.levels(level_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3614 (class 2606 OID 16789)
-- Name: learning_path_items fk_learning_path_items_path; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items
    ADD CONSTRAINT fk_learning_path_items_path FOREIGN KEY (path_id) REFERENCES ai_learning.learning_paths(path_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3615 (class 2606 OID 16794)
-- Name: learning_path_items fk_learning_path_items_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_path_items
    ADD CONSTRAINT fk_learning_path_items_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3612 (class 2606 OID 16772)
-- Name: learning_paths fk_learning_paths_language; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_paths
    ADD CONSTRAINT fk_learning_paths_language FOREIGN KEY (language_id) REFERENCES ai_learning.languages(language_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3613 (class 2606 OID 16767)
-- Name: learning_paths fk_learning_paths_level; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_paths
    ADD CONSTRAINT fk_learning_paths_level FOREIGN KEY (level_id) REFERENCES ai_learning.levels(level_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3591 (class 2606 OID 16552)
-- Name: learning_resources fk_learning_resources_language; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_resources
    ADD CONSTRAINT fk_learning_resources_language FOREIGN KEY (language_id) REFERENCES ai_learning.languages(language_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3592 (class 2606 OID 16547)
-- Name: learning_resources fk_learning_resources_level; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_resources
    ADD CONSTRAINT fk_learning_resources_level FOREIGN KEY (level_id) REFERENCES ai_learning.levels(level_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 3593 (class 2606 OID 16542)
-- Name: learning_resources fk_learning_resources_type; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.learning_resources
    ADD CONSTRAINT fk_learning_resources_type FOREIGN KEY (resource_type_id) REFERENCES ai_learning.resource_types(resource_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3586 (class 2606 OID 16431)
-- Name: playlists fk_playlists_channel; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.playlists
    ADD CONSTRAINT fk_playlists_channel FOREIGN KEY (channel_id) REFERENCES ai_learning.channels(channel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3601 (class 2606 OID 16656)
-- Name: resource_authors fk_resource_authors_author; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_authors
    ADD CONSTRAINT fk_resource_authors_author FOREIGN KEY (author_id) REFERENCES ai_learning.authors(author_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3602 (class 2606 OID 16651)
-- Name: resource_authors fk_resource_authors_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_authors
    ADD CONSTRAINT fk_resource_authors_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3599 (class 2606 OID 16626)
-- Name: resource_skills fk_resource_skills_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_skills
    ADD CONSTRAINT fk_resource_skills_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3600 (class 2606 OID 16631)
-- Name: resource_skills fk_resource_skills_skill; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_skills
    ADD CONSTRAINT fk_resource_skills_skill FOREIGN KEY (skill_id) REFERENCES ai_learning.skills(skill_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3594 (class 2606 OID 16564)
-- Name: resource_sources fk_resource_sources_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_sources
    ADD CONSTRAINT fk_resource_sources_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3595 (class 2606 OID 16569)
-- Name: resource_sources fk_resource_sources_video; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_sources
    ADD CONSTRAINT fk_resource_sources_video FOREIGN KEY (video_id) REFERENCES ai_learning.videos(video_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3597 (class 2606 OID 16602)
-- Name: resource_topics fk_resource_topics_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_topics
    ADD CONSTRAINT fk_resource_topics_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3598 (class 2606 OID 16607)
-- Name: resource_topics fk_resource_topics_topic; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.resource_topics
    ADD CONSTRAINT fk_resource_topics_topic FOREIGN KEY (topic_id) REFERENCES ai_learning.topics(topic_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3596 (class 2606 OID 16592)
-- Name: topics fk_topics_category; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.topics
    ADD CONSTRAINT fk_topics_category FOREIGN KEY (category_id) REFERENCES ai_learning.categories(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3590 (class 2606 OID 16490)
-- Name: transcripts fk_transcripts_video; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.transcripts
    ADD CONSTRAINT fk_transcripts_video FOREIGN KEY (video_id) REFERENCES ai_learning.videos(video_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3618 (class 2606 OID 16842)
-- Name: user_learning_progress fk_user_learning_progress_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_learning_progress
    ADD CONSTRAINT fk_user_learning_progress_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3619 (class 2606 OID 16837)
-- Name: user_learning_progress fk_user_learning_progress_user; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_learning_progress
    ADD CONSTRAINT fk_user_learning_progress_user FOREIGN KEY (user_id) REFERENCES ai_learning.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3620 (class 2606 OID 16863)
-- Name: user_notes fk_user_notes_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_notes
    ADD CONSTRAINT fk_user_notes_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3621 (class 2606 OID 16858)
-- Name: user_notes fk_user_notes_user; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_notes
    ADD CONSTRAINT fk_user_notes_user FOREIGN KEY (user_id) REFERENCES ai_learning.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3616 (class 2606 OID 16822)
-- Name: user_saved_resources fk_user_saved_resources_resource; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_saved_resources
    ADD CONSTRAINT fk_user_saved_resources_resource FOREIGN KEY (resource_id) REFERENCES ai_learning.learning_resources(resource_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3617 (class 2606 OID 16817)
-- Name: user_saved_resources fk_user_saved_resources_user; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.user_saved_resources
    ADD CONSTRAINT fk_user_saved_resources_user FOREIGN KEY (user_id) REFERENCES ai_learning.users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3589 (class 2606 OID 16473)
-- Name: video_statistics fk_video_statistics_video; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.video_statistics
    ADD CONSTRAINT fk_video_statistics_video FOREIGN KEY (video_id) REFERENCES ai_learning.videos(video_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3587 (class 2606 OID 16449)
-- Name: videos fk_videos_channel; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.videos
    ADD CONSTRAINT fk_videos_channel FOREIGN KEY (channel_id) REFERENCES ai_learning.channels(channel_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3588 (class 2606 OID 16454)
-- Name: videos fk_videos_playlist; Type: FK CONSTRAINT; Schema: ai_learning; Owner: app_user
--

ALTER TABLE ONLY ai_learning.videos
    ADD CONSTRAINT fk_videos_playlist FOREIGN KEY (playlist_id) REFERENCES ai_learning.playlists(playlist_id) ON UPDATE CASCADE ON DELETE SET NULL;


-- Completed on 2026-05-03 10:23:33 UTC

--
-- PostgreSQL database dump complete
--

\unrestrict 0crGFSRbTj64UYAJR6wdHdQvosWT2v1QPQLdfphoZPTJ5KWnIRlRS2MMqfmii2C

