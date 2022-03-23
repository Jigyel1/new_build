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
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: logidze_compact_history(jsonb, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_compact_history(log_data jsonb, cutoff integer DEFAULT 1) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
  -- version: 1
  DECLARE
    merged jsonb;
  BEGIN
    LOOP
      merged := jsonb_build_object(
        'ts',
        log_data#>'{h,1,ts}',
        'v',
        log_data#>'{h,1,v}',
        'c',
        (log_data#>'{h,0,c}') || (log_data#>'{h,1,c}')
      );

      IF (log_data#>'{h,1}' ? 'm') THEN
        merged := jsonb_set(merged, ARRAY['m'], log_data#>'{h,1,m}');
      END IF;

      log_data := jsonb_set(
        log_data,
        '{h}',
        jsonb_set(
          log_data->'h',
          '{1}',
          merged
        ) - 0
      );

      cutoff := cutoff - 1;

      EXIT WHEN cutoff <= 0;
    END LOOP;

    return log_data;
  END;
$$;


--
-- Name: logidze_filter_keys(jsonb, text[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_filter_keys(obj jsonb, keys text[], include_columns boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
  -- version: 1
  DECLARE
    res jsonb;
    key text;
  BEGIN
    res := '{}';

    IF include_columns THEN
      FOREACH key IN ARRAY keys
      LOOP
        IF obj ? key THEN
          res = jsonb_insert(res, ARRAY[key], obj->key);
        END IF;
      END LOOP;
    ELSE
      res = obj;
      FOREACH key IN ARRAY keys
      LOOP
        res = res - key;
      END LOOP;
    END IF;

    RETURN res;
  END;
$$;


--
-- Name: logidze_logger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_logger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  -- version: 1
  DECLARE
    changes jsonb;
    version jsonb;
    snapshot jsonb;
    new_v integer;
    size integer;
    history_limit integer;
    debounce_time integer;
    current_version integer;
    merged jsonb;
    iterator integer;
    item record;
    columns text[];
    include_columns boolean;
    ts timestamp with time zone;
    ts_column text;
  BEGIN
    ts_column := NULLIF(TG_ARGV[1], 'null');
    columns := NULLIF(TG_ARGV[2], 'null');
    include_columns := NULLIF(TG_ARGV[3], 'null');

    IF TG_OP = 'INSERT' THEN
      -- always exclude log_data column
      changes := to_jsonb(NEW.*) - 'log_data';

      IF columns IS NOT NULL THEN
        snapshot = logidze_snapshot(changes, ts_column, columns, include_columns);
      ELSE
        snapshot = logidze_snapshot(changes, ts_column);
      END IF;

      IF snapshot#>>'{h, -1, c}' != '{}' THEN
        NEW.log_data := snapshot;
      END IF;

    ELSIF TG_OP = 'UPDATE' THEN

      IF OLD.log_data is NULL OR OLD.log_data = '{}'::jsonb THEN
        -- always exclude log_data column
        changes := to_jsonb(NEW.*) - 'log_data';

        IF columns IS NOT NULL THEN
          snapshot = logidze_snapshot(changes, ts_column, columns, include_columns);
        ELSE
          snapshot = logidze_snapshot(changes, ts_column);
        END IF;

        IF snapshot#>>'{h, -1, c}' != '{}' THEN
          NEW.log_data := snapshot;
        END IF;
        RETURN NEW;
      END IF;

      history_limit := NULLIF(TG_ARGV[0], 'null');
      debounce_time := NULLIF(TG_ARGV[4], 'null');

      current_version := (NEW.log_data->>'v')::int;

      IF ts_column IS NULL THEN
        ts := statement_timestamp();
      ELSE
        ts := (to_jsonb(NEW.*)->>ts_column)::timestamp with time zone;
        IF ts IS NULL OR ts = (to_jsonb(OLD.*)->>ts_column)::timestamp with time zone THEN
          ts := statement_timestamp();
        END IF;
      END IF;

      IF NEW = OLD THEN
        RETURN NEW;
      END IF;

      IF current_version < (NEW.log_data#>>'{h,-1,v}')::int THEN
        iterator := 0;
        FOR item in SELECT * FROM jsonb_array_elements(NEW.log_data->'h')
        LOOP
          IF (item.value->>'v')::int > current_version THEN
            NEW.log_data := jsonb_set(
              NEW.log_data,
              '{h}',
              (NEW.log_data->'h') - iterator
            );
          END IF;
          iterator := iterator + 1;
        END LOOP;
      END IF;

      changes := '{}';

      IF (coalesce(current_setting('logidze.full_snapshot', true), '') = 'on') THEN
        changes = hstore_to_jsonb_loose(hstore(NEW.*));
      ELSE
        changes = hstore_to_jsonb_loose(
          hstore(NEW.*) - hstore(OLD.*)
        );
      END IF;

      changes = changes - 'log_data';

      IF columns IS NOT NULL THEN
        changes = logidze_filter_keys(changes, columns, include_columns);
      END IF;

      IF changes = '{}' THEN
        RETURN NEW;
      END IF;

      new_v := (NEW.log_data#>>'{h,-1,v}')::int + 1;

      size := jsonb_array_length(NEW.log_data->'h');
      version := logidze_version(new_v, changes, ts);

      IF (
        debounce_time IS NOT NULL AND
        (version->>'ts')::bigint - (NEW.log_data#>'{h,-1,ts}')::text::bigint <= debounce_time
      ) THEN
        -- merge new version with the previous one
        new_v := (NEW.log_data#>>'{h,-1,v}')::int;
        version := logidze_version(new_v, (NEW.log_data#>'{h,-1,c}')::jsonb || changes, ts);
        -- remove the previous version from log
        NEW.log_data := jsonb_set(
          NEW.log_data,
          '{h}',
          (NEW.log_data->'h') - (size - 1)
        );
      END IF;

      NEW.log_data := jsonb_set(
        NEW.log_data,
        ARRAY['h', size::text],
        version,
        true
      );

      NEW.log_data := jsonb_set(
        NEW.log_data,
        '{v}',
        to_jsonb(new_v)
      );

      IF history_limit IS NOT NULL AND history_limit <= size THEN
        NEW.log_data := logidze_compact_history(NEW.log_data, size - history_limit + 1);
      END IF;
    END IF;

    return NEW;
  END;
$$;


--
-- Name: logidze_snapshot(jsonb, text, text[], boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_snapshot(item jsonb, ts_column text DEFAULT NULL::text, columns text[] DEFAULT NULL::text[], include_columns boolean DEFAULT false) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
  -- version: 2
  DECLARE
    ts timestamp with time zone;
    k text;
  BEGIN
    IF ts_column IS NULL THEN
      ts := statement_timestamp();
    ELSE
      ts := coalesce((item->>ts_column)::timestamp with time zone, statement_timestamp());
    END IF;

    IF columns IS NOT NULL THEN
      item := logidze_filter_keys(item, columns, include_columns);
    END IF;

    FOR k IN (SELECT key FROM jsonb_each(item))
    LOOP
      IF jsonb_typeof(item->k) = 'object' THEN
         item := jsonb_set(item, ARRAY[k], to_jsonb(item->>k));
      END IF;
    END LOOP;

    return json_build_object(
      'v', 1,
      'h', jsonb_build_array(
              logidze_version(1, item, ts)
            )
      );
  END;
$$;


--
-- Name: logidze_version(bigint, jsonb, timestamp with time zone); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.logidze_version(v bigint, data jsonb, ts timestamp with time zone) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
  -- version: 1
  DECLARE
    buf jsonb;
  BEGIN
    buf := jsonb_build_object(
              'ts',
              (extract(epoch from ts) * 1000)::bigint,
              'v',
              v,
              'c',
              data
              );
    IF coalesce(current_setting('logidze.meta', true), '') <> '' THEN
      buf := jsonb_insert(buf, '{m}', current_setting('logidze.meta')::jsonb);
    END IF;
    RETURN buf;
  END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id uuid NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    owner_id uuid
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: activities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activities (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    owner_id uuid NOT NULL,
    trackable_type character varying,
    trackable_id uuid,
    recipient_id uuid,
    action character varying NOT NULL,
    log_data text DEFAULT ''::text NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    street character varying DEFAULT ''::character varying,
    street_no character varying DEFAULT ''::character varying,
    city character varying DEFAULT ''::character varying,
    zip character varying DEFAULT ''::character varying,
    addressable_type character varying,
    addressable_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    log_data jsonb
);


--
-- Name: admin_toolkit_competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_competitions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    factor double precision NOT NULL,
    lease_rate numeric NOT NULL,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    sfn boolean DEFAULT false,
    code character varying
);


--
-- Name: admin_toolkit_cost_thresholds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_cost_thresholds (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    exceeding numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_footprint_apartments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_footprint_apartments (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    min integer NOT NULL,
    max integer NOT NULL,
    index integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_footprint_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_footprint_types (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    provider character varying NOT NULL,
    index integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_footprint_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_footprint_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    category character varying NOT NULL,
    footprint_apartment_id uuid NOT NULL,
    footprint_type_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_kam_investors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_kam_investors (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    kam_id uuid NOT NULL,
    investor_id character varying NOT NULL,
    investor_description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_kam_regions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_kam_regions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    kam_id uuid,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_label_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_label_groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    code character varying NOT NULL,
    label_list character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_offer_additional_costs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_offer_additional_costs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name jsonb DEFAULT '{}'::jsonb,
    value numeric NOT NULL,
    additional_cost_type character varying DEFAULT 'discount'::character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_offer_contents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_offer_contents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title jsonb DEFAULT '{}'::jsonb,
    content jsonb DEFAULT '{}'::jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_offer_marketings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_offer_marketings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    activity_name jsonb DEFAULT '{}'::jsonb,
    value numeric NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_offer_prices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_offer_prices (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    min_apartments integer NOT NULL,
    max_apartments integer NOT NULL,
    name jsonb DEFAULT '{}'::jsonb,
    value numeric NOT NULL,
    index integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_pct_costs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_pct_costs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    index integer NOT NULL,
    min integer NOT NULL,
    max integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_pct_months; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_pct_months (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    index integer NOT NULL,
    min integer NOT NULL,
    max integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_pct_values; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_pct_values (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    status character varying NOT NULL,
    pct_month_id uuid NOT NULL,
    pct_cost_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_penetration_competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_penetration_competitions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    penetration_id uuid NOT NULL,
    competition_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_penetrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_penetrations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    zip character varying NOT NULL,
    city character varying NOT NULL,
    rate double precision NOT NULL,
    kam_region_id uuid NOT NULL,
    hfc_footprint boolean NOT NULL,
    type character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: admin_toolkit_project_costs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.admin_toolkit_project_costs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    standard numeric(15,2),
    arpu numeric(15,2),
    socket_installation_rate numeric(15,2),
    index integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    cpe_hfc numeric(15,2),
    cpe_ftth numeric(15,2),
    olt_cost_per_customer numeric(15,2),
    olt_cost_per_unit numeric(15,2),
    patching_cost numeric(15,2),
    mrc_standard numeric(15,2),
    mrc_high_tiers numeric(15,2),
    iru_sfn numeric(15,2),
    mrc_sfn numeric(15,2),
    ftth_cost numeric(15,2),
    high_tiers_product_share double precision,
    hfc_payback integer,
    ftth_payback integer
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    resource character varying NOT NULL,
    actions jsonb DEFAULT '{}'::jsonb NOT NULL,
    accessor_type character varying,
    accessor_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.profiles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    salutation character varying NOT NULL,
    firstname character varying DEFAULT ''::character varying NOT NULL,
    lastname character varying DEFAULT ''::character varying NOT NULL,
    phone character varying NOT NULL,
    department character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    log_data jsonb,
    avatar_url character varying
);


--
-- Name: projects_project_nr_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.projects_project_nr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    external_id character varying,
    internal_id character varying,
    project_nr character varying DEFAULT nextval('public.projects_project_nr_seq'::regclass),
    priority character varying,
    category character varying,
    status character varying DEFAULT 'Open'::character varying NOT NULL,
    assignee_type character varying DEFAULT 'NBO Project'::character varying NOT NULL,
    entry_type character varying DEFAULT 'Manual'::character varying NOT NULL,
    assignee_id uuid,
    kam_region_id uuid,
    construction_type character varying,
    construction_starts_on date,
    move_in_starts_on date,
    move_in_ends_on date,
    lot_number character varying,
    buildings_count integer DEFAULT 0 NOT NULL,
    apartments_count integer,
    description text,
    additional_info text,
    coordinate_east double precision,
    coordinate_north double precision,
    label_list character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    additional_details jsonb DEFAULT '{}'::jsonb,
    address_books_count integer DEFAULT 0 NOT NULL,
    files_count integer DEFAULT 0 NOT NULL,
    tasks_count integer DEFAULT 0 NOT NULL,
    completed_tasks_count integer DEFAULT 0 NOT NULL,
    access_technology character varying,
    in_house_installation boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    competition_id uuid,
    incharge_id uuid,
    os_id character varying,
    analysis text,
    customer_request boolean DEFAULT true,
    verdicts jsonb DEFAULT '{}'::jsonb,
    draft_version jsonb DEFAULT '{}'::jsonb,
    system_sorted_category boolean DEFAULT true,
    gis_url character varying,
    info_manager_url character varying,
    previous_status character varying,
    discarded_at timestamp without time zone,
    building_type character varying,
    cable_installations text[] DEFAULT '{}'::text[],
    priority_tac character varying,
    access_technology_tac character varying,
    exceeding_cost numeric,
    kam_assignee_id uuid,
    confirmation_status character varying,
    description_on_other character varying,
    prio_status character varying,
    added_labels character varying
);


--
-- Name: projects_address_books; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_address_books (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    external_id character varying,
    type character varying NOT NULL,
    display_name character varying NOT NULL,
    entry_type character varying NOT NULL,
    main_contact boolean DEFAULT false NOT NULL,
    name character varying,
    additional_name character varying,
    company character varying,
    po_box character varying,
    language character varying,
    phone character varying,
    mobile character varying,
    email character varying,
    website character varying,
    province character varying,
    contact character varying,
    project_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: projects_buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_buildings (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    external_id character varying,
    assignee_id uuid,
    project_id uuid NOT NULL,
    apartments_count integer DEFAULT 0 NOT NULL,
    move_in_starts_on date,
    move_in_ends_on date,
    additional_details jsonb DEFAULT '{}'::jsonb,
    files_count integer DEFAULT 0 NOT NULL,
    tasks_count integer DEFAULT 0 NOT NULL,
    completed_tasks_count integer DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp without time zone
);


--
-- Name: projects_connection_costs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_connection_costs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    connection_type character varying NOT NULL,
    cost_type character varying NOT NULL,
    project_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: projects_installation_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_installation_details (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    sockets integer,
    builder character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: projects_label_groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_label_groups (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    system_generated boolean DEFAULT false,
    label_list character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    project_id uuid NOT NULL,
    label_group_id uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: telco_uam_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telco_uam_users (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    discarded_at timestamp without time zone,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_type character varying,
    invited_by_id uuid,
    invitations_count integer DEFAULT 0,
    role_id uuid NOT NULL,
    active boolean DEFAULT true NOT NULL,
    log_data jsonb,
    provider character varying,
    uid character varying,
    jti character varying NOT NULL
);


--
-- Name: projects_lists; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.projects_lists AS
 SELECT projects.id,
    projects.external_id,
    projects.project_nr,
    projects.status,
    projects.category,
    projects.name,
    COALESCE(projects.priority_tac, projects.priority) AS priority,
    projects.construction_type,
    projects.apartments_count,
    projects.move_in_starts_on,
    projects.move_in_ends_on,
    projects.buildings_count,
    projects.lot_number,
    projects.internal_id,
    projects.draft_version,
    projects.assignee_type,
    projects.customer_request,
    cardinality(projects.label_list) AS labels,
    addresses.city,
    addresses.zip,
    projects.added_labels,
    concat(addresses.street, ' ', addresses.street_no, ', ', addresses.zip, ', ', addresses.city) AS address,
    COALESCE(NULLIF(concat(profiles.firstname, ' ', profiles.lastname), ' '::text), (projects.assignee_type)::text) AS assignee,
    projects.assignee_id,
    projects_address_books.name AS investor,
    admin_toolkit_kam_regions.name AS kam_region
   FROM (((((public.projects
     LEFT JOIN public.telco_uam_users ON ((telco_uam_users.id = projects.assignee_id)))
     LEFT JOIN public.profiles ON ((profiles.user_id = telco_uam_users.id)))
     LEFT JOIN public.addresses ON (((addresses.addressable_id = projects.id) AND ((addresses.addressable_type)::text = 'Project'::text))))
     LEFT JOIN public.projects_address_books ON (((projects_address_books.project_id = projects.id) AND ((projects_address_books.type)::text = 'Investor'::text))))
     LEFT JOIN public.admin_toolkit_kam_regions ON ((admin_toolkit_kam_regions.id = projects.kam_region_id)))
  WHERE (projects.discarded_at IS NULL)
  ORDER BY projects.move_in_starts_on
  WITH NO DATA;


--
-- Name: projects_pct_costs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_pct_costs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    project_cost numeric(15,2),
    socket_installation_cost numeric(15,2) DEFAULT 0.0,
    project_connection_cost numeric(15,2),
    arpu numeric(15,2),
    lease_cost numeric(15,2),
    penetration_rate double precision,
    payback_period double precision DEFAULT 0 NOT NULL,
    system_generated_payback_period boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    build_cost numeric(15,2),
    roi numeric(15,2),
    connection_cost_id uuid
);


--
-- Name: projects_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects_tasks (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    taskable_type character varying NOT NULL,
    taskable_id uuid NOT NULL,
    title character varying NOT NULL,
    status character varying DEFAULT 'To-Do'::character varying NOT NULL,
    previous_status character varying,
    description text NOT NULL,
    due_date date NOT NULL,
    assignee_id uuid NOT NULL,
    owner_id uuid NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    users_count integer DEFAULT 0 NOT NULL,
    description character varying
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users_lists; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.users_lists AS
 SELECT telco_uam_users.id,
    telco_uam_users.active,
    telco_uam_users.email,
    concat(profiles.firstname, ' ', profiles.lastname) AS name,
    profiles.phone,
    profiles.department,
    roles.id AS role_id,
    roles.name AS role,
    profiles.avatar_url
   FROM ((public.telco_uam_users
     JOIN public.profiles ON ((profiles.user_id = telco_uam_users.id)))
     JOIN public.roles ON ((roles.id = telco_uam_users.role_id)))
  WHERE (telco_uam_users.discarded_at IS NULL)
  ORDER BY (concat(profiles.firstname, ' ', profiles.lastname))
  WITH NO DATA;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_competitions admin_toolkit_competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_competitions
    ADD CONSTRAINT admin_toolkit_competitions_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_cost_thresholds admin_toolkit_cost_thresholds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_cost_thresholds
    ADD CONSTRAINT admin_toolkit_cost_thresholds_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_footprint_apartments admin_toolkit_footprint_apartments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_footprint_apartments
    ADD CONSTRAINT admin_toolkit_footprint_apartments_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_footprint_types admin_toolkit_footprint_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_footprint_types
    ADD CONSTRAINT admin_toolkit_footprint_types_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_footprint_values admin_toolkit_footprint_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_footprint_values
    ADD CONSTRAINT admin_toolkit_footprint_values_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_kam_investors admin_toolkit_kam_investors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_kam_investors
    ADD CONSTRAINT admin_toolkit_kam_investors_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_kam_regions admin_toolkit_kam_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_kam_regions
    ADD CONSTRAINT admin_toolkit_kam_regions_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_label_groups admin_toolkit_label_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_label_groups
    ADD CONSTRAINT admin_toolkit_label_groups_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_offer_additional_costs admin_toolkit_offer_additional_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_offer_additional_costs
    ADD CONSTRAINT admin_toolkit_offer_additional_costs_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_offer_contents admin_toolkit_offer_contents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_offer_contents
    ADD CONSTRAINT admin_toolkit_offer_contents_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_offer_marketings admin_toolkit_offer_marketings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_offer_marketings
    ADD CONSTRAINT admin_toolkit_offer_marketings_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_offer_prices admin_toolkit_offer_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_offer_prices
    ADD CONSTRAINT admin_toolkit_offer_prices_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_pct_costs admin_toolkit_pct_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_pct_costs
    ADD CONSTRAINT admin_toolkit_pct_costs_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_pct_months admin_toolkit_pct_months_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_pct_months
    ADD CONSTRAINT admin_toolkit_pct_months_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_pct_values admin_toolkit_pct_values_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_pct_values
    ADD CONSTRAINT admin_toolkit_pct_values_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_penetration_competitions admin_toolkit_penetration_competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_penetration_competitions
    ADD CONSTRAINT admin_toolkit_penetration_competitions_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_penetrations admin_toolkit_penetrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_penetrations
    ADD CONSTRAINT admin_toolkit_penetrations_pkey PRIMARY KEY (id);


--
-- Name: admin_toolkit_project_costs admin_toolkit_project_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_project_costs
    ADD CONSTRAINT admin_toolkit_project_costs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: projects_address_books projects_address_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_address_books
    ADD CONSTRAINT projects_address_books_pkey PRIMARY KEY (id);


--
-- Name: projects_buildings projects_buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_buildings
    ADD CONSTRAINT projects_buildings_pkey PRIMARY KEY (id);


--
-- Name: projects_connection_costs projects_connection_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_connection_costs
    ADD CONSTRAINT projects_connection_costs_pkey PRIMARY KEY (id);


--
-- Name: projects_installation_details projects_installation_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_installation_details
    ADD CONSTRAINT projects_installation_details_pkey PRIMARY KEY (id);


--
-- Name: projects_label_groups projects_label_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_label_groups
    ADD CONSTRAINT projects_label_groups_pkey PRIMARY KEY (id);


--
-- Name: projects_pct_costs projects_pct_costs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_pct_costs
    ADD CONSTRAINT projects_pct_costs_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: projects_tasks projects_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_tasks
    ADD CONSTRAINT projects_tasks_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: telco_uam_users telco_uam_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telco_uam_users
    ADD CONSTRAINT telco_uam_users_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_owner_id ON public.active_storage_attachments USING btree (owner_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_activities_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_created_at ON public.activities USING btree (created_at DESC);


--
-- Name: index_activities_on_log_data; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_log_data ON public.activities USING btree (log_data);


--
-- Name: index_activities_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_owner_id ON public.activities USING btree (owner_id);


--
-- Name: index_activities_on_recipient_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_recipient_id ON public.activities USING btree (recipient_id);


--
-- Name: index_activities_on_trackable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_trackable ON public.activities USING btree (trackable_type, trackable_id);


--
-- Name: index_activities_on_trackable_id_and_trackable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_activities_on_trackable_id_and_trackable_type ON public.activities USING btree (trackable_id, trackable_type);


--
-- Name: index_addresses_on_addressable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_addresses_on_addressable ON public.addresses USING btree (addressable_type, addressable_id);


--
-- Name: index_admin_toolkit_competitions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_competitions_on_name ON public.admin_toolkit_competitions USING btree (name);


--
-- Name: index_admin_toolkit_competitions_on_sfn; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_competitions_on_sfn ON public.admin_toolkit_competitions USING btree (sfn);


--
-- Name: index_admin_toolkit_footprint_apartments_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_footprint_apartments_on_index ON public.admin_toolkit_footprint_apartments USING btree (index);


--
-- Name: index_admin_toolkit_footprint_types_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_footprint_types_on_index ON public.admin_toolkit_footprint_types USING btree (index);


--
-- Name: index_admin_toolkit_footprint_values_on_footprint_apartment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_footprint_values_on_footprint_apartment_id ON public.admin_toolkit_footprint_values USING btree (footprint_apartment_id);


--
-- Name: index_admin_toolkit_footprint_values_on_footprint_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_footprint_values_on_footprint_type_id ON public.admin_toolkit_footprint_values USING btree (footprint_type_id);


--
-- Name: index_admin_toolkit_kam_investors_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_kam_investors_on_investor_id ON public.admin_toolkit_kam_investors USING btree (investor_id);


--
-- Name: index_admin_toolkit_kam_investors_on_kam_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_kam_investors_on_kam_id ON public.admin_toolkit_kam_investors USING btree (kam_id);


--
-- Name: index_admin_toolkit_kam_regions_on_kam_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_kam_regions_on_kam_id ON public.admin_toolkit_kam_regions USING btree (kam_id);


--
-- Name: index_admin_toolkit_kam_regions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_kam_regions_on_name ON public.admin_toolkit_kam_regions USING btree (name);


--
-- Name: index_admin_toolkit_label_groups_on_code; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_label_groups_on_code ON public.admin_toolkit_label_groups USING btree (code);


--
-- Name: index_admin_toolkit_label_groups_on_label_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_label_groups_on_label_list ON public.admin_toolkit_label_groups USING btree (label_list);


--
-- Name: index_admin_toolkit_label_groups_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_label_groups_on_name ON public.admin_toolkit_label_groups USING btree (name);


--
-- Name: index_admin_toolkit_pct_costs_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_pct_costs_on_index ON public.admin_toolkit_pct_costs USING btree (index);


--
-- Name: index_admin_toolkit_pct_months_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_pct_months_on_index ON public.admin_toolkit_pct_months USING btree (index);


--
-- Name: index_admin_toolkit_pct_values_on_pct_cost_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_pct_values_on_pct_cost_id ON public.admin_toolkit_pct_values USING btree (pct_cost_id);


--
-- Name: index_admin_toolkit_pct_values_on_pct_month_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_pct_values_on_pct_month_id ON public.admin_toolkit_pct_values USING btree (pct_month_id);


--
-- Name: index_admin_toolkit_penetration_competitions_on_competition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_penetration_competitions_on_competition_id ON public.admin_toolkit_penetration_competitions USING btree (competition_id);


--
-- Name: index_admin_toolkit_penetration_competitions_on_penetration_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_penetration_competitions_on_penetration_id ON public.admin_toolkit_penetration_competitions USING btree (penetration_id);


--
-- Name: index_admin_toolkit_penetrations_on_kam_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_admin_toolkit_penetrations_on_kam_region_id ON public.admin_toolkit_penetrations USING btree (kam_region_id);


--
-- Name: index_admin_toolkit_penetrations_on_zip; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_penetrations_on_zip ON public.admin_toolkit_penetrations USING btree (zip);


--
-- Name: index_admin_toolkit_project_costs_on_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_admin_toolkit_project_costs_on_index ON public.admin_toolkit_project_costs USING btree (index);


--
-- Name: index_footprint_values_on_category_and_references; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_footprint_values_on_category_and_references ON public.admin_toolkit_footprint_values USING btree (category, footprint_type_id, footprint_apartment_id);


--
-- Name: index_pct_values_on_status_and_references; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pct_values_on_status_and_references ON public.admin_toolkit_pct_values USING btree (status, pct_month_id, pct_cost_id);


--
-- Name: index_permissions_on_accessor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_accessor ON public.permissions USING btree (accessor_type, accessor_id);


--
-- Name: index_permissions_on_actions; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_permissions_on_actions ON public.permissions USING btree (actions);


--
-- Name: index_permissions_on_resource_and_accessor_id_and_accessor_type; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_permissions_on_resource_and_accessor_id_and_accessor_type ON public.permissions USING btree (resource, accessor_id, accessor_type);


--
-- Name: index_profiles_on_firstname_and_lastname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profiles_on_firstname_and_lastname ON public.profiles USING btree (firstname, lastname);


--
-- Name: index_profiles_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_profiles_on_user_id ON public.profiles USING btree (user_id);


--
-- Name: index_projects_address_books_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_address_books_on_discarded_at ON public.projects_address_books USING btree (discarded_at);


--
-- Name: index_projects_address_books_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_address_books_on_external_id ON public.projects_address_books USING btree (external_id);


--
-- Name: index_projects_address_books_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_address_books_on_project_id ON public.projects_address_books USING btree (project_id);


--
-- Name: index_projects_address_books_on_type_and_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_address_books_on_type_and_project_id ON public.projects_address_books USING btree (type, project_id) WHERE ((type)::text <> 'Others'::text);


--
-- Name: index_projects_buildings_on_additional_details; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_buildings_on_additional_details ON public.projects_buildings USING btree (additional_details);


--
-- Name: index_projects_buildings_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_buildings_on_assignee_id ON public.projects_buildings USING btree (assignee_id);


--
-- Name: index_projects_buildings_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_buildings_on_discarded_at ON public.projects_buildings USING btree (discarded_at);


--
-- Name: index_projects_buildings_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_buildings_on_external_id ON public.projects_buildings USING btree (external_id);


--
-- Name: index_projects_buildings_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_buildings_on_project_id ON public.projects_buildings USING btree (project_id);


--
-- Name: index_projects_connection_costs_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_connection_costs_on_project_id ON public.projects_connection_costs USING btree (project_id);


--
-- Name: index_projects_installation_details_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_installation_details_on_project_id ON public.projects_installation_details USING btree (project_id);


--
-- Name: index_projects_label_groups_on_label_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_label_groups_on_label_group_id ON public.projects_label_groups USING btree (label_group_id);


--
-- Name: index_projects_label_groups_on_label_list; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_label_groups_on_label_list ON public.projects_label_groups USING btree (label_list);


--
-- Name: index_projects_label_groups_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_label_groups_on_project_id ON public.projects_label_groups USING btree (project_id);


--
-- Name: index_projects_on_additional_details; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_additional_details ON public.projects USING btree (additional_details);


--
-- Name: index_projects_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_assignee_id ON public.projects USING btree (assignee_id);


--
-- Name: index_projects_on_competition_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_competition_id ON public.projects USING btree (competition_id);


--
-- Name: index_projects_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_discarded_at ON public.projects USING btree (discarded_at);


--
-- Name: index_projects_on_external_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_external_id ON public.projects USING btree (external_id);


--
-- Name: index_projects_on_incharge_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_incharge_id ON public.projects USING btree (incharge_id);


--
-- Name: index_projects_on_kam_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_kam_assignee_id ON public.projects USING btree (kam_assignee_id);


--
-- Name: index_projects_on_kam_region_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_kam_region_id ON public.projects USING btree (kam_region_id);


--
-- Name: index_projects_on_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_status ON public.projects USING btree (status);


--
-- Name: index_projects_pct_costs_on_connection_cost_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_pct_costs_on_connection_cost_id ON public.projects_pct_costs USING btree (connection_cost_id);


--
-- Name: index_projects_tasks_on_assignee_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_tasks_on_assignee_id ON public.projects_tasks USING btree (assignee_id);


--
-- Name: index_projects_tasks_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_tasks_on_owner_id ON public.projects_tasks USING btree (owner_id);


--
-- Name: index_projects_tasks_on_taskable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_tasks_on_taskable ON public.projects_tasks USING btree (taskable_type, taskable_id);


--
-- Name: index_projects_tasks_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_tasks_on_updated_at ON public.projects_tasks USING btree (updated_at DESC);


--
-- Name: index_roles_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_roles_on_name ON public.roles USING btree (name);


--
-- Name: index_telco_uam_users_on_discarded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telco_uam_users_on_discarded_at ON public.telco_uam_users USING btree (discarded_at);


--
-- Name: index_telco_uam_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_telco_uam_users_on_email ON public.telco_uam_users USING btree (email);


--
-- Name: index_telco_uam_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_telco_uam_users_on_invitation_token ON public.telco_uam_users USING btree (invitation_token);


--
-- Name: index_telco_uam_users_on_invited_by; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telco_uam_users_on_invited_by ON public.telco_uam_users USING btree (invited_by_type, invited_by_id);


--
-- Name: index_telco_uam_users_on_invited_by_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telco_uam_users_on_invited_by_id ON public.telco_uam_users USING btree (invited_by_id);


--
-- Name: index_telco_uam_users_on_jti; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_telco_uam_users_on_jti ON public.telco_uam_users USING btree (jti);


--
-- Name: index_telco_uam_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_telco_uam_users_on_reset_password_token ON public.telco_uam_users USING btree (reset_password_token);


--
-- Name: index_telco_uam_users_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_telco_uam_users_on_role_id ON public.telco_uam_users USING btree (role_id);


--
-- Name: addresses logidze_on_addresses; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER logidze_on_addresses BEFORE INSERT OR UPDATE ON public.addresses FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION public.logidze_logger('null', 'updated_at');


--
-- Name: profiles logidze_on_profiles; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER logidze_on_profiles BEFORE INSERT OR UPDATE ON public.profiles FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION public.logidze_logger('null', 'updated_at', '{salutation,firstname,lastname,phone,department}', 'true');


--
-- Name: telco_uam_users logidze_on_telco_uam_users; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER logidze_on_telco_uam_users BEFORE INSERT OR UPDATE ON public.telco_uam_users FOR EACH ROW WHEN ((COALESCE(current_setting('logidze.disabled'::text, true), ''::text) <> 'on'::text)) EXECUTE FUNCTION public.logidze_logger('null', 'updated_at', '{active,email,invitation_created_at,invited_by_id,discarded_at,role_id}', 'true');


--
-- Name: activities fk_rails_02313f8952; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_02313f8952 FOREIGN KEY (recipient_id) REFERENCES public.telco_uam_users(id);


--
-- Name: admin_toolkit_kam_investors fk_rails_1648c14d14; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_kam_investors
    ADD CONSTRAINT fk_rails_1648c14d14 FOREIGN KEY (kam_id) REFERENCES public.telco_uam_users(id);


--
-- Name: admin_toolkit_penetration_competitions fk_rails_23e3df12e1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_penetration_competitions
    ADD CONSTRAINT fk_rails_23e3df12e1 FOREIGN KEY (competition_id) REFERENCES public.admin_toolkit_competitions(id);


--
-- Name: admin_toolkit_penetration_competitions fk_rails_2efc921e87; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_penetration_competitions
    ADD CONSTRAINT fk_rails_2efc921e87 FOREIGN KEY (penetration_id) REFERENCES public.admin_toolkit_penetrations(id);


--
-- Name: projects_buildings fk_rails_2f76a3f772; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_buildings
    ADD CONSTRAINT fk_rails_2f76a3f772 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects_label_groups fk_rails_32341b9dfb; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_label_groups
    ADD CONSTRAINT fk_rails_32341b9dfb FOREIGN KEY (label_group_id) REFERENCES public.admin_toolkit_label_groups(id);


--
-- Name: projects_buildings fk_rails_34f45f79c2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_buildings
    ADD CONSTRAINT fk_rails_34f45f79c2 FOREIGN KEY (assignee_id) REFERENCES public.telco_uam_users(id);


--
-- Name: projects_address_books fk_rails_39b8a18518; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_address_books
    ADD CONSTRAINT fk_rails_39b8a18518 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: admin_toolkit_pct_values fk_rails_5300556c7f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_pct_values
    ADD CONSTRAINT fk_rails_5300556c7f FOREIGN KEY (pct_month_id) REFERENCES public.admin_toolkit_pct_months(id);


--
-- Name: projects fk_rails_5fff1d9455; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_5fff1d9455 FOREIGN KEY (competition_id) REFERENCES public.admin_toolkit_competitions(id);


--
-- Name: projects_connection_costs fk_rails_602bcfc988; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_connection_costs
    ADD CONSTRAINT fk_rails_602bcfc988 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects_tasks fk_rails_60d576e258; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_tasks
    ADD CONSTRAINT fk_rails_60d576e258 FOREIGN KEY (assignee_id) REFERENCES public.telco_uam_users(id);


--
-- Name: admin_toolkit_pct_values fk_rails_7272faf5b9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_pct_values
    ADD CONSTRAINT fk_rails_7272faf5b9 FOREIGN KEY (pct_cost_id) REFERENCES public.admin_toolkit_pct_costs(id);


--
-- Name: admin_toolkit_penetrations fk_rails_743612a9a0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_penetrations
    ADD CONSTRAINT fk_rails_743612a9a0 FOREIGN KEY (kam_region_id) REFERENCES public.admin_toolkit_kam_regions(id);


--
-- Name: admin_toolkit_kam_regions fk_rails_74c804eab4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_kam_regions
    ADD CONSTRAINT fk_rails_74c804eab4 FOREIGN KEY (kam_id) REFERENCES public.telco_uam_users(id);


--
-- Name: projects_pct_costs fk_rails_7ba6849ad5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_pct_costs
    ADD CONSTRAINT fk_rails_7ba6849ad5 FOREIGN KEY (connection_cost_id) REFERENCES public.projects_connection_costs(id);


--
-- Name: activities fk_rails_8c2b010743; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT fk_rails_8c2b010743 FOREIGN KEY (owner_id) REFERENCES public.telco_uam_users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: projects fk_rails_993c2a6f6a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_993c2a6f6a FOREIGN KEY (kam_assignee_id) REFERENCES public.telco_uam_users(id);


--
-- Name: projects fk_rails_99fc2a1a9e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_99fc2a1a9e FOREIGN KEY (kam_region_id) REFERENCES public.admin_toolkit_kam_regions(id);


--
-- Name: projects_tasks fk_rails_ab5dd7512c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_tasks
    ADD CONSTRAINT fk_rails_ab5dd7512c FOREIGN KEY (owner_id) REFERENCES public.telco_uam_users(id);


--
-- Name: projects fk_rails_bb113a6e04; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_bb113a6e04 FOREIGN KEY (incharge_id) REFERENCES public.telco_uam_users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: admin_toolkit_footprint_values fk_rails_c5fec1ddda; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_footprint_values
    ADD CONSTRAINT fk_rails_c5fec1ddda FOREIGN KEY (footprint_type_id) REFERENCES public.admin_toolkit_footprint_types(id);


--
-- Name: admin_toolkit_footprint_values fk_rails_d2d68aa044; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.admin_toolkit_footprint_values
    ADD CONSTRAINT fk_rails_d2d68aa044 FOREIGN KEY (footprint_apartment_id) REFERENCES public.admin_toolkit_footprint_apartments(id);


--
-- Name: projects_label_groups fk_rails_decd154e23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_label_groups
    ADD CONSTRAINT fk_rails_decd154e23 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: profiles fk_rails_e424190865; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT fk_rails_e424190865 FOREIGN KEY (user_id) REFERENCES public.telco_uam_users(id);


--
-- Name: active_storage_attachments fk_rails_e5f3338b0c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_e5f3338b0c FOREIGN KEY (owner_id) REFERENCES public.telco_uam_users(id);


--
-- Name: projects_installation_details fk_rails_ebab25d49a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects_installation_details
    ADD CONSTRAINT fk_rails_ebab25d49a FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: projects fk_rails_ef70228550; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_ef70228550 FOREIGN KEY (assignee_id) REFERENCES public.telco_uam_users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20210403005708'),
('20210403005709'),
('20210403005710'),
('20210403005711'),
('20210403005712'),
('20210403005713'),
('20210403100122'),
('20210408104835'),
('20210409151253'),
('20210419104850'),
('20210420015215'),
('20210420015216'),
('20210420050727'),
('20210420050751'),
('20210422050925'),
('20210425904822'),
('20210426065837'),
('20210428110340'),
('20210504155710'),
('20210510070226'),
('20210511095338'),
('20210523105703'),
('20210527121206'),
('20210601074347'),
('20210701091541'),
('20210701091755'),
('20210701094813'),
('20210702094659'),
('20210702095119'),
('20210702101004'),
('20210702112728'),
('20210702172133'),
('20210713104513'),
('20210715055509'),
('20210717131742'),
('20210719124603'),
('20210722055733'),
('20210727111136'),
('20210804105002'),
('20210804120138'),
('20210810122815'),
('20210811121923'),
('20210812065826'),
('20210812065902'),
('20210820072417'),
('20210906101429'),
('20210908121800'),
('20210908121948'),
('20210908122833'),
('20210911120552'),
('20211020080514'),
('20211020111623'),
('20211124085124'),
('20211125062330'),
('20211125102510'),
('20211125113806'),
('20211125113858'),
('20211125115233'),
('20211202075403'),
('20211206065430'),
('20211213113309'),
('20211214061605'),
('20211214080557'),
('20211214115619'),
('20211214120927'),
('20211215033130'),
('20211215051430'),
('20211215052925'),
('20211215052949'),
('20211215121358'),
('20211220101735'),
('20211220120052'),
('20220103082627'),
('20220213091922'),
('20220306212410'),
('20220318172640'),
('20220322150514'),
('20220323102355'),
('20220323110252');


