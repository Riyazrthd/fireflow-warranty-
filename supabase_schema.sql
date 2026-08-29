-- ==============================================================================
-- 🚒 FIREFLOW WARRANTY & COMMISSIONING PORTAL - UNIVERSAL SUPABASE SQL SCRIPT
-- ==============================================================================
-- Works seamlessly on BOTH fresh databases AND existing Supabase projects!
-- Prevents type conflict errors (UUID vs TEXT) and automatically creates/upgrades
-- all tables, columns, indexes, RLS policies, Realtime publications, and views.
-- ==============================================================================

-- 1. ENABLE REQUIRED EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ==============================================================================
-- 2. CREATE / UPGRADE MASTER TABLES SAFELY
-- ==============================================================================

-- ── 2.1 CUSTOMERS TABLE ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.customers (
    id TEXT PRIMARY KEY DEFAULT ('CUST-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    name TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    address TEXT,
    po_date DATE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Safely add missing columns to customers if table already existed
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS contact_person TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS address TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS po_date DATE;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());
ALTER TABLE public.customers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- ── 2.2 CATEGORIES TABLE ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.categories (
    id TEXT PRIMARY KEY DEFAULT ('CAT-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 6))),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS name TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;

-- ── 2.3 TRUCKS / FLEET VEHICLES TABLE ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.trucks (
    id TEXT PRIMARY KEY DEFAULT ('TRK-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    customer_id TEXT,
    po_no TEXT NOT NULL,
    po_date DATE,
    tender_type TEXT NOT NULL,
    chassis_make TEXT,
    model_no TEXT,
    chassis_sr_no TEXT,
    engine_sr_no TEXT,
    battery_sr_no TEXT,
    registration_no TEXT,
    pump_make TEXT,
    pump_lpm NUMERIC,
    pump_sr_no TEXT,
    pto_make TEXT,
    pto_sr_no TEXT,
    water_capacity NUMERIC DEFAULT 0,
    foam_capacity NUMERIC DEFAULT 0,
    delivery_date DATE,
    commissioning_date DATE,
    warranty_months INTEGER DEFAULT 24,
    warranty_expiry_date DATE,
    status TEXT DEFAULT 'In Warranty',
    total_km NUMERIC DEFAULT 0,
    operating_hours NUMERIC DEFAULT 0,
    insurance_policy_no TEXT,
    insurance_company TEXT,
    insurance_expiry_date DATE,
    cost_center_status TEXT DEFAULT 'Not Generated',
    po_at_glance_generated_at TIMESTAMPTZ,
    submitted_to_accounts_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Safely add missing columns to trucks if table already existed
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS customer_id TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS po_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS po_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS tender_type TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS chassis_make TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS model_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS chassis_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS engine_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS battery_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS registration_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS pump_make TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS pump_lpm NUMERIC;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS pump_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS pto_make TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS pto_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS water_capacity NUMERIC DEFAULT 0;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS foam_capacity NUMERIC DEFAULT 0;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS delivery_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS commissioning_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS warranty_months INTEGER DEFAULT 24;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS warranty_expiry_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'In Warranty';
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS total_km NUMERIC DEFAULT 0;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS operating_hours NUMERIC DEFAULT 0;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS insurance_policy_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS insurance_company TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS insurance_expiry_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS cost_center_status TEXT DEFAULT 'Not Generated';
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS po_at_glance_generated_at TIMESTAMPTZ;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS submitted_to_accounts_at TIMESTAMPTZ;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS uhp_pump_make TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS uhp_pump_lpm TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS uhp_pump_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS dcp_capacity TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS dcp_hpt_due_date DATE;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS dcp_sr_no TEXT;
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());
ALTER TABLE public.trucks ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- ── 2.4 COMPLAINTS / SERVICE DESK TICKETS TABLE ──────────────────────────────
CREATE TABLE IF NOT EXISTS public.complaints (
    id TEXT PRIMARY KEY DEFAULT ('CMP-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    complaint_id TEXT NOT NULL UNIQUE,
    truck_id TEXT,
    customer_id TEXT,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    date_received DATE DEFAULT CURRENT_DATE NOT NULL,
    mode TEXT DEFAULT 'Customer Portal',
    reported_by TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    status TEXT DEFAULT 'Open' NOT NULL,
    priority TEXT DEFAULT 'Medium',
    closed_by TEXT,
    closed_date DATE,
    resolved_at TIMESTAMPTZ,
    diagnosis TEXT,
    delay_reason TEXT,
    remarks TEXT,
    attachment_url TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- Safely add missing columns to complaints
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS complaint_id TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS truck_id TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS customer_id TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS date_received DATE DEFAULT CURRENT_DATE;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS mode TEXT DEFAULT 'Customer Portal';
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS reported_by TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS contact_phone TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS contact_email TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Open';
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS priority TEXT DEFAULT 'Medium';
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS closed_by TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS closed_date DATE;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS resolved_at TIMESTAMPTZ;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS diagnosis TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS delay_reason TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS attachment_url TEXT;
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());
ALTER TABLE public.complaints ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- ── 2.5 COMMISSIONING & OPERATOR TRAINING CERTIFICATES ───────────────────────
CREATE TABLE IF NOT EXISTS public.commissioning_certificates (
    id TEXT PRIMARY KEY DEFAULT ('CERT-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    certificate_no TEXT NOT NULL UNIQUE,
    truck_id TEXT,
    customer_id TEXT,
    po_no TEXT NOT NULL,
    commissioning_date DATE NOT NULL,
    commissioning_engineer TEXT NOT NULL,
    customer_rep_name TEXT,
    customer_rep_designation TEXT,
    questions JSONB DEFAULT '[]'::JSONB,
    training_days JSONB DEFAULT '[]'::JSONB,
    trainees JSONB DEFAULT '[]'::JSONB,
    handover_statement TEXT,
    signatures JSONB DEFAULT '{}'::JSONB,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS certificate_no TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS truck_id TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS customer_id TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS po_no TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS commissioning_date DATE;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS commissioning_engineer TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS customer_rep_name TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS customer_rep_designation TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS questions JSONB DEFAULT '[]'::JSONB;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS training_days JSONB DEFAULT '[]'::JSONB;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS trainees JSONB DEFAULT '[]'::JSONB;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS handover_statement TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS signatures JSONB DEFAULT '{}'::JSONB;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());
ALTER TABLE public.commissioning_certificates ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- ── 2.6 CUSTOMER REVIEWS & FEEDBACK ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.feedbacks (
    id TEXT PRIMARY KEY DEFAULT ('FB-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    customer_id TEXT,
    truck_id TEXT,
    rating NUMERIC DEFAULT 5,
    feedback_text TEXT NOT NULL,
    feedback_date DATE DEFAULT CURRENT_DATE,
    feedback_category TEXT DEFAULT 'General Support',
    person_name TEXT,
    contact_number TEXT,
    mode TEXT DEFAULT 'Customer Portal',
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS customer_id TEXT;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS truck_id TEXT;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS rating NUMERIC DEFAULT 5;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS feedback_text TEXT;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS feedback_date DATE DEFAULT CURRENT_DATE;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS feedback_category TEXT DEFAULT 'General Support';
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS person_name TEXT;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS contact_number TEXT;
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS mode TEXT DEFAULT 'Customer Portal';
ALTER TABLE public.feedbacks ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- ── 2.7 PREVENTIVE MAINTENANCE (PM) SCHEDULES ────────────────────────────────
CREATE TABLE IF NOT EXISTS public.pm_schedules (
    id TEXT PRIMARY KEY DEFAULT ('PM-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    truck_id TEXT,
    service_name TEXT NOT NULL,
    scheduled_date DATE NOT NULL,
    completed_date DATE,
    status TEXT DEFAULT 'Pending',
    engineer_name TEXT,
    service_report_url TEXT,
    checklist JSONB DEFAULT '[]'::JSONB,
    remarks TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- ==============================================================================
-- 3. CAPA (CORRECTIVE & PREVENTIVE ACTION) TABLES
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.capas (
    id TEXT PRIMARY KEY DEFAULT ('CAPA-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_number TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    source_type TEXT DEFAULT 'Customer Complaint',
    problem_statement TEXT NOT NULL,
    containment_actions TEXT,
    target_date DATE,
    assigned_to TEXT,
    status TEXT DEFAULT 'Open',
    risk_level TEXT DEFAULT 'Medium',
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.capa_complaints (
    id TEXT PRIMARY KEY DEFAULT ('CC-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_id TEXT NOT NULL,
    complaint_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.capa_5why (
    id TEXT PRIMARY KEY DEFAULT ('WHY-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_id TEXT NOT NULL,
    why_number INTEGER NOT NULL,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    root_cause_identified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.capa_5m1e (
    id TEXT PRIMARY KEY DEFAULT ('FISH-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_id TEXT NOT NULL,
    category TEXT NOT NULL,
    finding TEXT NOT NULL,
    impact TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.capa_actions (
    id TEXT PRIMARY KEY DEFAULT ('ACT-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_id TEXT NOT NULL,
    action_type TEXT NOT NULL,
    action_description TEXT NOT NULL,
    responsible_person TEXT NOT NULL,
    target_date DATE NOT NULL,
    completion_date DATE,
    verification_status TEXT DEFAULT 'Pending',
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.capa_audit_log (
    id TEXT PRIMARY KEY DEFAULT ('AUD-' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 8))),
    capa_id TEXT NOT NULL,
    action TEXT NOT NULL,
    changed_by TEXT NOT NULL,
    old_value JSONB,
    new_value JSONB,
    changed_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- ==============================================================================
-- 4. SYSTEM CONFIGURATION & AUDIT TRAILS
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.system_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    description TEXT,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.activity_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT,
    details JSONB DEFAULT '{}'::JSONB,
    performed_by TEXT DEFAULT 'System',
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- ==============================================================================
-- 5. HIGH-SPEED INDEXES
-- ==============================================================================

CREATE INDEX IF NOT EXISTS idx_trucks_po_no ON public.trucks(po_no);
CREATE INDEX IF NOT EXISTS idx_trucks_chassis_sr_no ON public.trucks(chassis_sr_no);
CREATE INDEX IF NOT EXISTS idx_trucks_pump_sr_no ON public.trucks(pump_sr_no);
CREATE INDEX IF NOT EXISTS idx_complaints_complaint_id ON public.complaints(complaint_id);
CREATE INDEX IF NOT EXISTS idx_complaints_status ON public.complaints(status);
CREATE INDEX IF NOT EXISTS idx_complaints_date_received ON public.complaints(date_received DESC);
CREATE INDEX IF NOT EXISTS idx_certs_po_no ON public.commissioning_certificates(po_no);

-- ==============================================================================
-- 6. AUTOMATED TIMESTAMP UPDATE TRIGGER
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::TEXT, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_customers_updated_at ON public.customers;
CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_trucks_updated_at ON public.trucks;
CREATE TRIGGER trg_trucks_updated_at BEFORE UPDATE ON public.trucks FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trg_complaints_updated_at ON public.complaints;
CREATE TRIGGER trg_complaints_updated_at BEFORE UPDATE ON public.complaints FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ==============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commissioning_certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pm_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capa_complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capa_5why ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capa_5m1e ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capa_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.capa_audit_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any to prevent duplication errors
DROP POLICY IF EXISTS "Allow public select on customers" ON public.customers;
DROP POLICY IF EXISTS "Allow public insert on customers" ON public.customers;
DROP POLICY IF EXISTS "Allow public update on customers" ON public.customers;
DROP POLICY IF EXISTS "Allow public delete on customers" ON public.customers;

DROP POLICY IF EXISTS "Allow public select on categories" ON public.categories;
DROP POLICY IF EXISTS "Allow public insert on categories" ON public.categories;

DROP POLICY IF EXISTS "Allow public select on trucks" ON public.trucks;
DROP POLICY IF EXISTS "Allow public insert on trucks" ON public.trucks;
DROP POLICY IF EXISTS "Allow public update on trucks" ON public.trucks;
DROP POLICY IF EXISTS "Allow public delete on trucks" ON public.trucks;

DROP POLICY IF EXISTS "Allow public select on complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow public insert on complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow public update on complaints" ON public.complaints;
DROP POLICY IF EXISTS "Allow public delete on complaints" ON public.complaints;

DROP POLICY IF EXISTS "Allow public select on certificates" ON public.commissioning_certificates;
DROP POLICY IF EXISTS "Allow public insert on certificates" ON public.commissioning_certificates;
DROP POLICY IF EXISTS "Allow public update on certificates" ON public.commissioning_certificates;

DROP POLICY IF EXISTS "Allow public select on feedbacks" ON public.feedbacks;
DROP POLICY IF EXISTS "Allow public insert on feedbacks" ON public.feedbacks;

DROP POLICY IF EXISTS "Allow public select on pm_schedules" ON public.pm_schedules;
DROP POLICY IF EXISTS "Allow public insert on pm_schedules" ON public.pm_schedules;
DROP POLICY IF EXISTS "Allow public update on pm_schedules" ON public.pm_schedules;

DROP POLICY IF EXISTS "Allow public all on capas" ON public.capas;
DROP POLICY IF EXISTS "Allow public all on capa_complaints" ON public.capa_complaints;
DROP POLICY IF EXISTS "Allow public all on capa_5why" ON public.capa_5why;
DROP POLICY IF EXISTS "Allow public all on capa_5m1e" ON public.capa_5m1e;
DROP POLICY IF EXISTS "Allow public all on capa_actions" ON public.capa_actions;
DROP POLICY IF EXISTS "Allow public all on capa_audit_log" ON public.capa_audit_log;

DROP POLICY IF EXISTS "Allow public select on system_settings" ON public.system_settings;
DROP POLICY IF EXISTS "Allow public all on activity_logs" ON public.activity_logs;

-- Create Clean Universal Policies
CREATE POLICY "Allow public select on customers" ON public.customers FOR SELECT USING (true);
CREATE POLICY "Allow public insert on customers" ON public.customers FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on customers" ON public.customers FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on customers" ON public.customers FOR DELETE USING (true);

CREATE POLICY "Allow public select on categories" ON public.categories FOR SELECT USING (true);
CREATE POLICY "Allow public insert on categories" ON public.categories FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public select on trucks" ON public.trucks FOR SELECT USING (true);
CREATE POLICY "Allow public insert on trucks" ON public.trucks FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on trucks" ON public.trucks FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on trucks" ON public.trucks FOR DELETE USING (true);

CREATE POLICY "Allow public select on complaints" ON public.complaints FOR SELECT USING (true);
CREATE POLICY "Allow public insert on complaints" ON public.complaints FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on complaints" ON public.complaints FOR UPDATE USING (true);
CREATE POLICY "Allow public delete on complaints" ON public.complaints FOR DELETE USING (true);

CREATE POLICY "Allow public select on certificates" ON public.commissioning_certificates FOR SELECT USING (true);
CREATE POLICY "Allow public insert on certificates" ON public.commissioning_certificates FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on certificates" ON public.commissioning_certificates FOR UPDATE USING (true);

CREATE POLICY "Allow public select on feedbacks" ON public.feedbacks FOR SELECT USING (true);
CREATE POLICY "Allow public insert on feedbacks" ON public.feedbacks FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public select on pm_schedules" ON public.pm_schedules FOR SELECT USING (true);
CREATE POLICY "Allow public insert on pm_schedules" ON public.pm_schedules FOR INSERT WITH CHECK (true);
CREATE POLICY "Allow public update on pm_schedules" ON public.pm_schedules FOR UPDATE USING (true);

CREATE POLICY "Allow public all on capas" ON public.capas FOR ALL USING (true);
CREATE POLICY "Allow public all on capa_complaints" ON public.capa_complaints FOR ALL USING (true);
CREATE POLICY "Allow public all on capa_5why" ON public.capa_5why FOR ALL USING (true);
CREATE POLICY "Allow public all on capa_5m1e" ON public.capa_5m1e FOR ALL USING (true);
CREATE POLICY "Allow public all on capa_actions" ON public.capa_actions FOR ALL USING (true);
CREATE POLICY "Allow public all on capa_audit_log" ON public.capa_audit_log FOR ALL USING (true);

CREATE POLICY "Allow public select on system_settings" ON public.system_settings FOR SELECT USING (true);
CREATE POLICY "Allow public all on activity_logs" ON public.activity_logs FOR ALL USING (true);

-- ==============================================================================
-- 8. SUPABASE REALTIME REPLICATION
-- ==============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'complaints'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.complaints;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'feedbacks'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.feedbacks;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'trucks'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.trucks;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'commissioning_certificates'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.commissioning_certificates;
    END IF;
END $$;


-- ==============================================================================
-- 9. ANALYTICS VIEWS
-- ==============================================================================

CREATE OR REPLACE VIEW public.vw_complaints_master AS
SELECT 
    c.id,
    c.complaint_id,
    c.category,
    c.description,
    c.date_received,
    c.mode,
    c.reported_by,
    c.contact_phone,
    c.contact_email,
    c.status,
    c.priority,
    c.closed_by,
    c.closed_date,
    c.resolved_at,
    c.diagnosis,
    c.delay_reason,
    c.remarks,
    c.created_at,
    (CURRENT_DATE - c.date_received::DATE) AS aging_days,
    cust.name AS customer_name,
    cust.address AS customer_address,
    cust.phone AS customer_phone,
    trk.po_no,
    trk.tender_type,
    trk.chassis_make,
    trk.chassis_sr_no,
    trk.pump_make,
    trk.pump_sr_no
FROM public.complaints c
LEFT JOIN public.trucks trk ON c.truck_id::TEXT = trk.id::TEXT
LEFT JOIN public.customers cust ON (c.customer_id::TEXT = cust.id::TEXT OR trk.customer_id::TEXT = cust.id::TEXT);

CREATE OR REPLACE VIEW public.vw_fleet_warranty_summary AS
SELECT 
    trk.id,
    trk.po_no,
    trk.po_date,
    trk.tender_type,
    trk.chassis_make,
    trk.chassis_sr_no,
    trk.pump_make,
    trk.pump_sr_no,
    trk.delivery_date,
    trk.warranty_months,
    (trk.delivery_date + (COALESCE(trk.warranty_months, 24) || ' months')::INTERVAL)::DATE AS calculated_warranty_expiry,
    ((trk.delivery_date + (COALESCE(trk.warranty_months, 24) || ' months')::INTERVAL)::DATE - CURRENT_DATE) AS days_remaining,
    CASE 
        WHEN ((trk.delivery_date + (COALESCE(trk.warranty_months, 24) || ' months')::INTERVAL)::DATE >= CURRENT_DATE) THEN 'In Warranty'
        ELSE 'Expired'
    END AS warranty_status,
    cust.id AS customer_id,
    cust.name AS customer_name,
    cust.contact_person,
    cust.phone AS customer_phone,
    cust.email AS customer_email,
    cust.address AS customer_address
FROM public.trucks trk
LEFT JOIN public.customers cust ON trk.customer_id::TEXT = cust.id::TEXT;

-- ==============================================================================
-- 10. INITIAL SEED DATA
-- ==============================================================================

INSERT INTO public.categories (name, description) VALUES
('Fabrication', 'Superstructure, lockers, shutters, ladder gantry, tank welding'),
('Chassis/Engine', 'Engine PTO, transmission, suspension, brakes, steering, electrical chassis'),
('Fire Pump', 'Waterous / Godiva / Firefly pump, priming system, mechanical seal, impeller'),
('Electrical', 'Siren, lightbar, beacon, warning lights, control panel wiring, relays'),
('Plumbing/Valves', 'Delivery valves, suction inlet, tank-to-pump, monitor plumbing, bypass valve'),
('Foam System', 'Around-the-pump proportioner, inductor, foam barrel, ratio controller'),
('Hydraulics', 'High pressure reel, PTO engagement cylinder, hydraulic monitor control'),
('Painting/Finishing', 'PU paint, reflective chevron vinyl, anti-corrosion coating, badging'),
('Other', 'General miscellaneous maintenance or customer inquiry')
ON CONFLICT (name) DO NOTHING;

INSERT INTO public.system_settings (key, value, description) VALUES
('app_config', '{
    "app_name": "FireFlow Warranty & Field Commissioning Portal",
    "company_name": "Indus Fire Safety Private Limited",
    "helpline_phone": "+91 93139 27647",
    "support_email": "customercare@indusfire.com",
    "emergency_dispatch_email": "operations@indusfire.com"
}'::JSONB, 'Primary application settings and contact endpoints')
ON CONFLICT (key) DO NOTHING;

-- ==============================================================================
-- END OF UNIVERSAL SCRIPT
-- ==============================================================================
