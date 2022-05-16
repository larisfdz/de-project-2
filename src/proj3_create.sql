CREATE TABLE public.shipping_country_rates (
id SERIAL PRIMARY KEY,
shipping_country TEXT,
shipping_country_base_rate NUMERIC(14,
3)
);
--CREATE INDEX id ON public.d_products (productid);

CREATE TABLE public.shipping_agreement (
agreementid INT PRIMARY KEY,
agreement_number TEXT,
agreement_rate NUMERIC (14,
2),
agreement_commission NUMERIC (14,
3)
);

CREATE TABLE public.shipping_transfer (
id SERIAL PRIMARY KEY,
transfer_type TEXT,
transfer_model TEXT,
shipping_transfer_rate NUMERIC(14,
3)
);

CREATE TABLE public.shipping_info (
shippingid INT8 PRIMARY KEY,
vendorid INT8,
payment_amount NUMERIC(14,
2),
shipping_plan_datetime TIMESTAMP,
transfer_type_id INT4,
shipping_country_id INT4,
agreementid INT4,
FOREIGN KEY (transfer_type_id) REFERENCES shipping_transfer(id) ON
UPDATE
	CASCADE,
	FOREIGN KEY (shipping_country_id) REFERENCES shipping_country_rates(id) ON
	UPDATE
		CASCADE,
		FOREIGN KEY (agreementid) REFERENCES shipping_agreement(agreementid) ON
		UPDATE
			CASCADE
);

CREATE TABLE public.shipping_status (
shippingid INT8 PRIMARY KEY,
status TEXT,
state TEXT,
shipping_start_fact_datetime TIMESTAMP,
shipping_end_fact_datetime TIMESTAMP
);



