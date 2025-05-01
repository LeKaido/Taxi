create or replace function staging.po_map_access_session(batch_id integer)
returns staging.po_ret_tp as
$$
declare
    ret staging.po_ret_tp;
    ct_base integer;
    ct integer;
    stg_schema  text = 'staging';
    stg_tab     text = 'access_session';
    dst_schema  text = 'dat';
    dst_tab     text = 'access_session';
begin
    RAISE NOTICE '== Starting processing into %.% ==', upper(dst_schema), upper(dst_tab);
    ret.ins_ct = 0;
    ret.upd_ct = 0;
    ----------------------------------------------------------------------------
    -- CHECKS
    ----------------------------------------------------------------------------
    EXECUTE 'select count(*) from '||stg_schema||'.'||stg_tab INTO ct_base;
    RAISE NOTICE 'Number of rows in %.%: %', stg_schema, stg_tab, ct_base;
    ----------------------------------------------------------------------------
    -- BASE TEMP
    ----------------------------------------------------------------------------
    create temp table TEMP_BASE 
        with (orientation=column, appendonly=true, compresslevel=1)
		on commit drop
    as
    select a.id_session
          , coalesce(a.session_state, -1) as session_state
          , etl.uhash(a.key_user) as bi_key_uhash
          , coalesce(a.key_partner, -1) as key_partner
          , substring(a.user_challenge,1,50) as user_challenge
          , coalesce(a.key_session_lookup, -1) as key_session_lookup
          , a.key_ccy
          , a.key_ccy_c
          , case when a.key_ccy_c is null then -1 else
                coalesce(b.bi_id_ccy, -2)
            end as bi_key_ccy
          , a.price / (1.00 + coalesce(a.tax_rate, 0.0)) as price
          , a.price as gross_price
          , a.start_balance
          , a.total_price / (1.00 + coalesce(a.tax_rate, 0.0)) as total_price
          , a.total_price as gross_total_price
          , coalesce(a.create_time, '1000-01-01'::timestamp) as create_time
          , coalesce(a.create_time::date, '1000-01-01'::date) as create_dt
          , coalesce(a.start_time, '1000-01-01'::timestamp) as start_time
          , coalesce(a.start_time::date, '1000-01-01'::date) as start_dt
          , a.session_timeout
          , a.idle_timeout
          , a.duration
          , coalesce(a.close_time, '1000-01-01'::timestamp) as close_time
          , coalesce(a.close_time::date, '1000-01-01'::date) as close_dt
          , a.close_reason
          , case when a.user_ip in (0,1) then -1
                else etl.unsigned(a.user_ip) end as user_ip
          , a.user_ip_country
          , a.user_ip_country_c
          , case when a.user_ip_country_c is null then -1
                else coalesce(c.bi_id_country, -2) 
            end as bi_key_iso_country
          , a.user_node_id
          , substring(a.user_si_fp,1,50) as user_si_fp
          , a.nas_ip
          , a.called_id
          , a.calling_id
          , a.nas_id
          , a.nas_port_type
          , a.radius_sess_id
          , a.octets_in
          , a.octets_out
          , a.packets_in
          , a.packets_out
          , a.radius_duration
          , a.radius_term_cause
          , a.last_tick_seq
          , coalesce(a.last_tick_time::timestamp, '1000-01-01'::timestamp) as last_tick_time
          , coalesce(a.last_tick_time::date, '1000-01-01'::date) as last_tick_dt
          , substring(a.location_description,1,255) as location_descr
          , a.system_id
          , etl.url_decode(a.version) as version -- for logging and final insert
          , (a.vsplt).platform as platform
          , (a.vsplt).version as ver
          , (a.vsplt).cobrand as cobrand
          , (a.vsplt).tag as tag
          , (a.vsplt).key_tracking_source as key_tracking_source
          , (a.vsplt).application_id as application_id
          , coalesce(f.bi_id_platformversion, -2) as bi_key_platformversion
          , coalesce(g.bi_id_partnerapplication, -2) as bi_key_partnerapplication
          , coalesce(a.key_promo_wifi, -1) as key_promo_wifi
          , a.dns_country
          , a.dns_country_c
          , case when a.dns_country_c is null then -1
                else coalesce(d.bi_id_country, -2) 
            end as bi_key_dns_country
          , coalesce(a.dns_ip, -1) as dns_ip
          , substring(a.ssid, 1,100) as ssid
          , a.venue_country
          , a.venue_country_c
          , case when a.venue_country_c is null then -1 
                else coalesce(e.bi_id_country, -2) 
            end as bi_key_venue_country
          , etl.bool_to_i(a.autodiscovered_venue) as flag_autodiscovered_venue
          , a.pricing_type
          , a.pricing_type_c
          , case when a.pricing_type_c is null then -1 
                else coalesce(h.bi_id_access_session_pricing_type, -2) 
            end as bi_key_access_session_pricing_type
          , a.operator_name 
          , case when a.operator_name is null or trim(a.operator_name) = ''
                then -1 else coalesce(i.bi_id_access_operator, -2) 
            end as bi_key_access_operator
          , a.ssid_mac
		  , a.package_name
		  , case when a.package_name is null then -1 else coalesce(j.bi_id_productpackage,-2) end as bi_key_productpackage
		  , coalesce(a.package_expire_time, '1000-01-01'::timestamp) as package_expire_time
          , coalesce(a.package_expire_time::date, '1000-01-01'::date) as package_expire_dt
		  , coalesce(a.key_entitlement_usage::bigint,-1)::bigint as key_entitlement_usage
		  , coalesce(a.tax_rate,0.0)::numeric(20,5) as tax_rate
		  , a.tax_location
		  , a.tax_location_c
		  , case when a.tax_location_c is null then -1 
                else coalesce(k.bi_id_country, -2) 
            end as bi_key_tax_location_country
		  , coalesce(a.ikey_tax_context,-1)::integer as ikey_tax_context
    from
    (
        select
             a.*
             , upper(etl.empty_to_null(a.key_ccy)) as key_ccy_c
             , etl.version_split_access(a.version) as vsplt
             , etl.empty_to_null(a.user_ip_country) as user_ip_country_c
             , upper(etl.empty_to_null(a.dns_country)) as dns_country_c
             , upper(etl.empty_to_null(a.venue_country)) as venue_country_c
             , upper(etl.empty_to_null(a.tax_location)) as tax_location_c
             , etl.empty_to_null(a.pricing_type) as pricing_type_c
        from STAGING.ACCESS_SESSION as a
    ) as a
        left outer join DAT.DIMCURRENCY b
            on b.currency = a.key_ccy_c
        left outer join DAT.ISO_COUNTRIES c
            on c.iso_code2 = a.user_ip_country_c
        left outer join DAT.ISO_COUNTRIES d
            on d.iso_code2 = a.dns_country_c     
        left outer join DAT.ISO_COUNTRIES e
            on e.iso_code2 = a.venue_country_c    
        left outer join DAT.DIMPLATFORMVERSION f
            on f.platform = (a.vsplt).platform 
                and f.version = (a.vsplt).version
        left outer join DAT.DIMPARTNERAPPLICATION g
            on g.application_id = (a.vsplt).application_id
        left outer join DAT.ACCESS_SESSION_PRICING_TYPE h
            on h.pricing_type = a.pricing_type_c
        left outer join DAT.ACCESS_OPERATOR i
            on i.operator =  a.operator_name
		left outer join dat.infodb_product_package j
			on (j.id_package = a.package_name)
		left outer join DAT.ISO_COUNTRIES k
            on k.iso_code2 = a.tax_location_c    

    distributed by (bi_key_uhash)
    ;
    GET DIAGNOSTICS ct = ROW_COUNT;
    RAISE NOTICE 'Rows inserted to TEMP_BASE: %',ct;    
    -- FAILSAFE: check against base count, if not equal, then error
    if ct != ct_base then
        RAISE EXCEPTION 'TEMP_BASE count and staging count do not match: % != %',ct_base, ct;
    end if;
    ----------------------------------------------------------------------------
    -- LOOKUPS
    ----------------------------------------------------------------------------
    
    -- EUR/USD rates
    RAISE NOTICE '--- Rates Lookup ---';
    create temp table TEMP_RATES 
        with (orientation=column, appendonly=true, compresslevel=1)
		on commit drop
    as
    select a.id_session
         , a.bi_key_uhash
         , a.gross_price/coalesce(b.avg, 0) as gross_price_eur
         , a.gross_price/coalesce(c.avg, 0) as gross_price_usd
         , a.price/coalesce(b.avg, 0) as price_eur
         , a.price/coalesce(c.avg, 0) as price_usd
         , a.start_balance/coalesce(b.avg, 0) as start_balance_eur
         , a.start_balance/coalesce(c.avg, 0) as start_balance_usd
         , a.gross_total_price/coalesce(b.avg, 0) as gross_total_price_eur
         , a.gross_total_price/coalesce(c.avg, 0) as gross_total_price_usd
         , a.total_price/coalesce(b.avg, 0) as total_price_eur
         , a.total_price/coalesce(c.avg, 0) as total_price_usd
      from TEMP_BASE a
        left outer join dat.euro_rates as b 
            on (a.bi_key_ccy = b.bi_key_ccy
                and a.create_dt = b.start_dt)
        left outer join dat.usd_rates as c 
            on (a.bi_key_ccy = c.bi_key_ccy 
                and a.create_dt = c.start_dt)  
    distributed by(bi_key_uhash)
    ;
    GET DIAGNOSTICS ct = ROW_COUNT;
    RAISE NOTICE 'Rows inserted to TEMP_BASE: %',ct;    
    -- FAILSAFE: check against base count, if not equal, then error
    if ct != ct_base then
        RAISE EXCEPTION 'TEMP_BASE count and staging count do not match: % != %',ct_base, ct;
    end if;
    
    --== GEOIP ==--
    RAISE NOTICE '--- IP Lookup ---';
    ct = etl.lookup_geoip('TEMP_BASE'
                        , 'id_session'
                        , 'user_ip'
                        , 'bi_key_uhash'
                        , 'TEMP_USER_IP_LOOKUP'
                        , 'ETLDATA.GEOIP_BLOCKS_CHUNKS_COUNTRY');
    
    ct = etl.lookup_geoip('TEMP_BASE'
                        , 'id_session'
                        , 'dns_ip'
                        , 'bi_key_uhash'
                        , 'TEMP_DNS_IP_LOOKUP'
                        , 'ETLDATA.GEOIP_BLOCKS_CHUNKS_COUNTRY');
    
    ----------------------------------------------------------------------------
    -- FINAL TEMP
    ----------------------------------------------------------------------------
    CREATE TEMPORARY TABLE TEMP_FINAL
        with (orientation=column, appendonly=true, compresslevel=1)
		on commit drop
        as 
        select a.*
               , b.gross_price_eur
			   , b.gross_price_usd
			   , b.price_eur
               , b.price_usd
               , b.start_balance_eur
               , b.start_balance_usd
			   , b.gross_total_price_eur
			   , b.gross_total_price_usd
               , b.total_price_eur
               , b.total_price_usd
               , case a.user_ip = -1 when true then -1
                    else coalesce(c.bi_key_country, -2) 
                 end as bi_key_user_ip_country
               , case a.user_ip = -1 when true then -1
                    else coalesce(c.bi_key_iplocation, -2) 
                 end as bi_key_user_iplocation
               , case a.dns_ip = -1 when true then -1
                    else coalesce(d.bi_key_country, -2) 
                 end as bi_key_dns_ip_country
               , case a.dns_ip = -1 when true then -1
                    else coalesce(d.bi_key_iplocation, -2) 
                 end as bi_key_dns_iplocation
            from TEMP_BASE a
                left outer join TEMP_RATES b
                    on a.id_session = b.id_session
                left outer join TEMP_USER_IP_LOOKUP c 
                    on a.id_session = c.id_session
                left outer join TEMP_DNS_IP_LOOKUP d 
                    on a.id_session = d.id_session
      distributed by (bi_key_uhash)
    ;
    GET DIAGNOSTICS ct = ROW_COUNT;
    RAISE NOTICE 'Rows inserted TEMP_FINAL: %',ct;
    -- FAILSAFE: check against base count, if not equal, then error
    select count(*) into ct from TEMP_FINAL;
    if ct != ct_base then
        RAISE EXCEPTION 'TEMP_FINAL count and staging count do not match: % != %',ct_base, ct;
    end if;                        
                        
    ----------------------------------------------------------------------------
    -- LOG LOOKUP FAILURES
    ----------------------------------------------------------------------------
    -- bi_key_ccy 
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_ccy' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'dimcurrencies' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'key_ccy' -- nat_val_column text
                            , ARRAY['key_ccy_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    
    -- user IP lookup fails                        
    ct = etl.log_lookup_fail(batch_id
	                        , dst_schema --fact_schema text
	                        , dst_tab -- fact_table text
	                        , 'bi_key_user_ip_country' -- fact_column text
	                        , ARRAY['id_session'] -- fact_pk_columns text[]
	                        , 'etldata' -- lookup_schema text
	                        , 'geoip_blocks_chunks_country' --lookup_table text
	                        , stg_schema -- nat_val_schema text
	                        , stg_tab -- nat_val_table text
	                        , 'user_ip' -- nat_val_column text
	                        , ARRAY['user_ip'] -- nat_val_lookup_columns text
	                        , 'TEMP_FINAL' -- temp_table text
	                        , '-2' -- fail_indicator text
	                        );
    -- bi_key_iso_country
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_iso_country' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'iso_countries' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'user_ip_country' -- nat_val_column text
                            , ARRAY['user_ip_country_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- dimplatformversion
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_platformversion' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'dimplatformversion' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'version' -- nat_val_column text
                            , ARRAY['platform','ver'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- dimpartnerapplication
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_partnerapplication' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'dimpartnerapplication' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'version' -- nat_val_column text
                            , ARRAY['application_id'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- bi_key_venue_country
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_venue_country' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'iso_countries' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'venue_country' -- nat_val_column text
                            , ARRAY['venue_country_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- bi_key_dns_country
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_dns_country' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , dst_schema -- lookup_schema text
                            , 'iso_countries' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'dns_country' -- nat_val_column text
                            , ARRAY['dns_country_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- DNS IP lookup fails
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_dns_ip_country' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , 'etldata' -- lookup_schema text
                            , 'geoip_blocks_chunks_country' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'dns_ip' -- nat_val_column text
                            , ARRAY['dns_ip'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- bi_key_access_session_pricing_type
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_access_session_pricing_type' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , 'dat' -- lookup_schema text
                            , 'access_session_pricing_type' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'pricing_type' -- nat_val_column text
                            , ARRAY['pricing_type_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );
    -- bi_key_access_operator
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_access_operator' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , 'dat' -- lookup_schema text
                            , 'access_operator' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'operator_name' -- nat_val_column text
                            , ARRAY['operator_name'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );   
    -- bi_key_productpackage
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_productpackage' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , 'dat' -- lookup_schema text
                            , 'infodb_product_package' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'package_name' -- nat_val_column text
                            , ARRAY['package_name'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );      	
    -- bi_key_tax_location_country
    ct = etl.log_lookup_fail(batch_id
                            , dst_schema --fact_schema text
                            , dst_tab -- fact_table text
                            , 'bi_key_tax_location_country' -- fact_column text
                            , ARRAY['id_session'] -- fact_pk_columns text[]
                            , 'dat' -- lookup_schema text
                            , 'iso_countries' --lookup_table text
                            , stg_schema -- nat_val_schema text
                            , stg_tab -- nat_val_table text
                            , 'tax_location' -- nat_val_column text
                            , ARRAY['tax_location_c'] -- nat_val_lookup_columns text
                            , 'TEMP_FINAL' -- temp_table text
                            , '-2' -- fail_indicator text
                            );      	
    ----------------------------------------------------------------------------
    -- TO DESTINATION
    ----------------------------------------------------------------------------
    -- update
    update dat.access_session b
    set session_state = a.session_state
      , key_partner = a.key_partner
      , user_challenge = a.user_challenge
      , key_session_lookup = a.key_session_lookup
      , bi_key_ccy = a.bi_key_ccy
      , gross_price = a.gross_price
      , gross_price_eur = a.gross_price_eur
      , gross_price_usd = a.gross_price_usd
      , price = a.price
      , price_eur = a.price_eur
      , price_usd = a.price_usd
      , start_balance = a.start_balance
      , start_balance_eur = a.start_balance_eur
      , start_balance_usd = a.start_balance_usd
      , gross_total_price = a.gross_total_price
      , gross_total_price_eur = a.gross_total_price_eur
      , gross_total_price_usd = a.gross_total_price_usd
      , total_price = a.total_price
      , total_price_eur = a.total_price_eur
      , total_price_usd = a.total_price_usd
      , create_time = a.create_time
      , create_dt = a.create_dt
      , start_time = a.start_time
      , start_dt = a.start_dt
      , session_timeout = a.session_timeout
      , idle_timeout = a.idle_timeout
      , duration = a.duration
      , close_time = a.close_time
      , close_dt = a.close_dt
      , close_reason = a.close_reason
      , user_ip = a.user_ip
      , bi_key_user_ip_country = a.bi_key_user_ip_country
      , bi_key_iso_country = a.bi_key_iso_country
      , bi_key_user_iplocation = a.bi_key_user_iplocation
      , user_node_id = a.user_node_id
      , user_si_fp = a.user_si_fp
      , nas_ip = a.nas_ip
      , called_id = a.called_id
      , calling_id = a.calling_id
      , nas_id = a.nas_id
      , nas_port_type = a.nas_port_type
      , radius_sess_id = a.radius_sess_id
      , octets_in = a.octets_in
      , octets_out = a.octets_out
      , packets_in = a.packets_in
      , packets_out = a.packets_out
      , radius_duration = a.radius_duration
      , radius_term_cause = a.radius_term_cause
      , last_tick_seq = a.last_tick_seq
      , last_tick_time = a.last_tick_time
      , last_tick_dt = a.last_tick_dt
      , location_descr = a.location_descr
      , system_id = a.system_id
      , version = a.version
      , bi_key_last_batch = batch_id
      , key_promo_wifi = a.key_promo_wifi
      , bi_key_platformversion = a.bi_key_platformversion
      , cobrand = a.cobrand
      , tag = a.tag
      , key_tracking_source = a.key_tracking_source
      , bi_key_partnerapplication = a.bi_key_partnerapplication
      , bi_key_venue_country = a.bi_key_venue_country
      , bi_key_dns_country = a.bi_key_dns_country
      , dns_ip = a.dns_ip
      , bi_key_dns_ip_country = a.bi_key_dns_ip_country
      , bi_key_dns_iplocation = a.bi_key_dns_iplocation
      , ssid = a.ssid
      , flag_autodiscovered_venue = a.flag_autodiscovered_venue
      , bi_key_access_session_pricing_type = a.bi_key_access_session_pricing_type
      , bi_key_access_operator = a.bi_key_access_operator
      , ssid_mac = a.ssid_mac 
	  , bi_key_productpackage = a.bi_key_productpackage
	  , package_expire_time = a.package_expire_time
	  , package_expire_dt = a.package_expire_dt
	  , key_entitlement_usage = a.key_entitlement_usage
	  , tax_rate = a.tax_rate
	  , bi_key_tax_location_country = a.bi_key_tax_location_country
	  , ikey_tax_context = a.ikey_tax_context
    from TEMP_FINAL as a
    where b.id_session = a.id_session
        and b.bi_key_uhash = a.bi_key_uhash
    ;
    GET DIAGNOSTICS ct = ROW_COUNT;
    RAISE NOTICE 'Rows updated in %.%: %', upper(dst_schema), upper(dst_tab), ct;
    ret.upd_ct = ct;
    
    -- insert
    insert into dat.access_session
    ( id_session
    , session_state
    , bi_key_uhash
    , key_partner
    , user_challenge
    , key_session_lookup
    , bi_key_ccy
    , gross_price
    , gross_price_eur
    , gross_price_usd
    , price
    , price_eur
    , price_usd
    , start_balance
    , start_balance_eur
    , start_balance_usd
    , gross_total_price
    , gross_total_price_eur
    , gross_total_price_usd
    , total_price
    , total_price_eur
    , total_price_usd
    , create_time
    , create_dt
    , start_time
    , start_dt
    , session_timeout
    , idle_timeout
    , duration
    , close_time
    , close_dt
    , close_reason
    , user_ip
    , bi_key_user_ip_country
    , bi_key_iso_country
    , bi_key_user_iplocation
    , user_node_id
    , user_si_fp
    , nas_ip
    , called_id
    , calling_id
    , nas_id
    , nas_port_type
    , radius_sess_id
    , octets_in
    , octets_out
    , packets_in
    , packets_out
    , radius_duration
    , radius_term_cause
    , last_tick_seq
    , last_tick_time
    , last_tick_dt
    , location_descr
    , system_id
    , version
    , bi_key_first_batch
    , bi_key_last_batch
    , key_promo_wifi
    , bi_key_platformversion
    , cobrand
    , tag
    , key_tracking_source
    , bi_key_partnerapplication
    , bi_key_venue_country
    , bi_key_dns_country
    , dns_ip
    , bi_key_dns_ip_country
	, bi_key_dns_iplocation
	, ssid
	, flag_autodiscovered_venue
	, bi_key_access_session_pricing_type
	, bi_key_access_operator
    , ssid_mac
	, bi_key_productpackage
	, package_expire_time
	, package_expire_dt
	, key_entitlement_usage
	, tax_rate
	, bi_key_tax_location_country
	, ikey_tax_context
    )
    select a.id_session
         , a.session_state
         , a.bi_key_uhash
         , a.key_partner
         , a.user_challenge
         , a.key_session_lookup
         , a.bi_key_ccy
         , a.gross_price
         , a.gross_price_eur
         , a.gross_price_usd
         , a.price
         , a.price_eur
         , a.price_usd
         , a.start_balance
         , a.start_balance_eur
         , a.start_balance_usd
         , a.gross_total_price
         , a.gross_total_price_eur
         , a.gross_total_price_usd
         , a.total_price
         , a.total_price_eur
         , a.total_price_usd
         , a.create_time
         , a.create_dt
         , a.start_time
         , a.start_dt
         , a.session_timeout
         , a.idle_timeout
         , a.duration
         , a.close_time
         , a.close_dt
         , a.close_reason
         , a.user_ip
         , a.bi_key_user_ip_country
         , a.bi_key_iso_country
         , a.bi_key_user_iplocation
         , a.user_node_id
         , a.user_si_fp
         , a.nas_ip
         , a.called_id
         , a.calling_id
         , a.nas_id
         , a.nas_port_type
         , a.radius_sess_id
         , a.octets_in
         , a.octets_out
         , a.packets_in
         , a.packets_out
         , a.radius_duration
         , a.radius_term_cause
         , a.last_tick_seq
         , a.last_tick_time
         , a.last_tick_dt
         , a.location_descr
         , a.system_id
         , a.version
         , batch_id
         , batch_id
         , a.key_promo_wifi
         , a.bi_key_platformversion
         , a.cobrand
         , a.tag
         , a.key_tracking_source
         , a.bi_key_partnerapplication
         , a.bi_key_venue_country
         , a.bi_key_dns_country
         , a.dns_ip
         , a.bi_key_dns_ip_country
         , a.bi_key_dns_iplocation
         , a.ssid
         , a.flag_autodiscovered_venue
         , a.bi_key_access_session_pricing_type
         , a.bi_key_access_operator
         , a.ssid_mac
		 , a.bi_key_productpackage
		 , a.package_expire_time
		 , a.package_expire_dt
		 , a.key_entitlement_usage
		 , a.tax_rate
		 , a.bi_key_tax_location_country
		 , a.ikey_tax_context
    from TEMP_FINAL as a
        left outer join dat.access_session b 
            on (b.id_session = a.id_session)
    where b.id_session is NULL
    ;
    GET DIAGNOSTICS ct = ROW_COUNT;
    RAISE NOTICE 'Rows inserted to %.%: %', upper(dst_schema), upper(dst_tab), ct;
    ret.ins_ct = ct;
    -- FAILSAFE: check ins_ct + upd_ct = base_ct
    if ret.ins_ct+ret.upd_ct != ct_base then
        RAISE EXCEPTION 'Insert count (%) + update count (%) != base_ct (%) !' ,ret.ins_ct, ret.upd_ct, ct_base;
    end if;
    
    -- log batch 
    ct = etl.log_batch(batch_id
                      , dst_schema||'.'||dst_tab
                      , NULL
                      , ret.ins_ct
                      , ret.upd_ct
                      , NULL
                      , NULL);
    
    return ret;
end;
$$
language plpgsql volatile;
ALTER FUNCTION staging.po_map_access_session(batch_id integer) OWNER TO gpadmin;
--/
