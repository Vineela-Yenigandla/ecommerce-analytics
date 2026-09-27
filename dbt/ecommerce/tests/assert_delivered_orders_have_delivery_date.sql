{{ config(severity='warn') }}

-- DATA QUALITY ISSUE (known, accepted)
--
-- An order marked 'delivered' should have a delivery timestamp.
-- 8 of 99,441 orders (0.008%) in the Olist source breach this.
--
-- Severity is 'warn' rather than 'error': the volume is immaterial and the
-- defect originates upstream, so blocking the pipeline would cost more than
-- it protects. The test remains so the count is visible every run -- if it
-- grows, the source has regressed and we investigate.

select order_id, order_status, delivered_at
from {{ ref('fct_orders') }}
where order_status = 'delivered'
  and delivered_at is null
