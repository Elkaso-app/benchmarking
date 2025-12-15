CREATE TABLE IF NOT EXISTS benchmarking.orders (
order_id BIGINT PRIMARY KEY,
invoice_image TEXT[] NOT NULL DEFAULT '{}',
created_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_orders_created_at
ON benchmarking.orders (created_at);

CREATE TABLE IF NOT EXISTS benchmarking.invoice_items (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
order_id BIGINT NOT NULL,
item_name TEXT NOT NULL,
qty NUMERIC(14,4),
uom TEXT,
unit_price NUMERIC(14,4),
net_price NUMERIC(14,4),
llm TEXT NOT NULL, -- e.g. 'gpt_4', 'gpt4omin'
created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_invoice_items_order_id
ON benchmarking.invoice_items (order_id);

CREATE UNIQUE INDEX IF NOT EXISTS uq_invoice_items_dedupe
ON benchmarking.invoice_items (order_id, item_name, qty, uom, unit_price, net_price);

CREATE INDEX IF NOT EXISTS idx_invoice_items_created_at
ON benchmarking.invoice_items (created_at);

I created those two table
the first one has data now
we need to build a script that take restaurant id and do something like :
SELECT id as "order_id",invoice_image , created_at FROM orders
WHERE
restaurant_id = ID AND
created_at >= '2025-10-01 00:00:00'
AND invoice_image IS NOT NULL
AND not in benchmarking.invoice_items ...

and foreach order there maybe on of more invoice you should either download it or send dirctly to llm to extract the items a

then insert the items in
benchmarking.invoice_items

same of what we did , but now from db and insert in db

don't insert in db unless you have the items all the invoices of one order
example : in case the order has 3 invoices , you can insert in db if you done from the 3 invoices

In the script we will hardcode ids of the target restaurant and the start date
so make those two static for now

the db connection in .env now
LOCAL_DB_HOST=
LOCAL_DB_PORT=
LOCAL_DB_NAME=
LOCAL_DB_USER=
LOCAL_DB_PASSWORD=
