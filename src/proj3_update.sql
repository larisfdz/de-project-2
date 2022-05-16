INSERT
	INTO
	public.shipping_country_rates (
shipping_country,
	shipping_country_base_rate)
SELECT
	DISTINCT shipping_country,
	shipping_country_base_rate
FROM
	shipping
;

INSERT
	INTO
	public.shipping_agreement
SELECT
	DISTINCT
(regexp_split_to_array(vendor_agreement_description, E'\\:+'))[1] :: INT AS agreement_id,
	(regexp_split_to_array(vendor_agreement_description, E'\\:+'))[2] AS agreement_number,
	(regexp_split_to_array(vendor_agreement_description, E'\\:+'))[3] :: NUMERIC (14,
	2) AS agreement_rate,
	(regexp_split_to_array(vendor_agreement_description, E'\\:+'))[4] :: NUMERIC (14,
	3) AS agreement_commission
FROM
	public.shipping
;

INSERT
	INTO
	public.shipping_transfer (
transfer_type,
	transfer_model,
	shipping_transfer_rate)
SELECT
	DISTINCT
(regexp_split_to_array(shipping_transfer_description, E'\\:+'))[1] AS transfer_type,
	(regexp_split_to_array(shipping_transfer_description, E'\\:+'))[2] AS transfer_model,
	shipping_transfer_rate
FROM
	public.shipping
;

INSERT
	INTO
	public.shipping_info
SELECT
	DISTINCT 
sh.shippingid,
	sh.vendorid,
	sh.payment_amount,
	sh.shipping_plan_datetime,
	t.id AS transfer_type_id,
	shc.id AS shipping_country_id,
	(regexp_split_to_array(sh.vendor_agreement_description, E'\\:+'))[1] :: INT4 AS agreement_id
FROM
	public.shipping sh
JOIN public.shipping_transfer t ON
	(regexp_split_to_array(sh.shipping_transfer_description, E'\\:+'))[1] = t.transfer_type
	AND 
							(regexp_split_to_array(sh.shipping_transfer_description, E'\\:+'))[2] = t.transfer_model
JOIN public.shipping_country_rates shc ON
	sh.shipping_country = shc.shipping_country
;

INSERT
	INTO
	public.shipping_status
WITH start_dt AS (
	SELECT
		DISTINCT s.shippingid,
		MAX(s.state_datetime) AS shipping_start_fact_datetime
	FROM
		public.shipping s
	WHERE
		s.state = 'booked'
	GROUP BY
		s.shippingid
),
	end_dt AS (
	SELECT
		DISTINCT s.shippingid,
		MAX(s.state_datetime) AS shipping_end_fact_datetime
	FROM
		public.shipping s
	WHERE
		s.state = 'recieved'
	GROUP BY
		s.shippingid
),
	latest_dt AS (
	SELECT
		s.shippingid,
		s.status,
		s.state,
		s.state_datetime,
		MAX(s.state_datetime) OVER (PARTITION BY s.shippingid) AS latest_st
	FROM
		public.shipping s
)
SELECT
	DISTINCT 
ldt.shippingid,
	ldt.status,
	CASE
		WHEN ldt.state = 'recieved' THEN 'received'
		ELSE ldt.state
	END AS state,
	sdt.shipping_start_fact_datetime,
	edt.shipping_end_fact_datetime
FROM
	latest_dt ldt
LEFT JOIN start_dt sdt ON
	ldt.shippingid = sdt.shippingid
LEFT JOIN end_dt edt ON
	ldt.shippingid = edt.shippingid
WHERE
	ldt.state_datetime = ldt.latest_st
;
