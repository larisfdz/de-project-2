CREATE OR REPLACE VIEW shipping_datamart AS
SELECT
	DISTINCT 
shs.shippingid,
	shi.vendorid,
	sht.transfer_type,
	EXTRACT(DAY
FROM
	shs.shipping_end_fact_datetime-shs.shipping_start_fact_datetime) AS full_day_at_shipping,
	CASE
		WHEN shs.shipping_end_fact_datetime > shi.shipping_plan_datetime THEN 1
		ELSE 0
	END AS is_delay,
	CASE
		WHEN shs.status = 'finished' THEN 1
		ELSE 0
	END AS is_shipping_finish,
	CASE
		WHEN shs.shipping_end_fact_datetime > shi.shipping_plan_datetime THEN
		EXTRACT(DAY
	FROM
		shs.shipping_end_fact_datetime - shi.shipping_plan_datetime)
		ELSE 0
	END AS delay_day_at_shipping,
	shi.payment_amount,
	shi.payment_amount * (shcr.shipping_country_base_rate + sha.agreement_rate + sht.shipping_transfer_rate) AS vat,
	shi.payment_amount * sha.agreement_commission AS profit
FROM
	public.shipping_status shs
LEFT JOIN public.shipping_info shi ON
	shs.shippingid = shi.shippingid
LEFT JOIN public.shipping_transfer sht ON
	shi.transfer_type_id = sht.id
LEFT JOIN public.shipping_country_rates shcr ON
	shi.shipping_country_id = shcr.id
LEFT JOIN public.shipping_agreement sha ON
	shi.agreementid = sha.agreementid;
