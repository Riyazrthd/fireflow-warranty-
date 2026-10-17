-- ============================================
-- Updated FireFlow Warranty - Supabase Schema
-- Includes Insurance, Pump Serial, and Feedback
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. CUSTOMERS
CREATE TABLE IF NOT EXISTS customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NOT NULL,
    po_date DATE,                -- Added for PO Date tracking on Customer
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. CATEGORIES
CREATE TABLE IF NOT EXISTS categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TRUCKS (Updated with Insurance & Pump fields)
CREATE TABLE IF NOT EXISTS trucks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    po_no TEXT NOT NULL,
    po_date DATE,                -- Added for PO AT GLANCE & Cost Center Automation
    tender_type TEXT NOT NULL,
    pump_make TEXT NOT NULL,
    pump_lpm TEXT,
    pump_sr_no TEXT,             -- Added for Warranty.html
    foam_capacity TEXT,
    water_capacity TEXT,
    chassis_make TEXT NOT NULL,
    model_no TEXT NOT NULL,
    delivery_date DATE NOT NULL,
    warranty_months INTEGER DEFAULT 12,
    insurance_policy_no TEXT,    -- Added for Insurance Tracking
    insurance_company TEXT,      -- Added for Insurance Tracking
    insurance_expiry_date DATE,  -- Added for Insurance Tracking
    cost_center_status TEXT DEFAULT 'Not Generated', -- Added for 7-Day Cost Center KPI
    po_at_glance_generated_at TIMESTAMPTZ,
    submitted_to_accounts_at TIMESTAMPTZ,
    cost_center_created_at TIMESTAMPTZ,
    oc_no TEXT,                  -- Added for OC Number Tracking
    oc_date DATE,                -- Added for OC Date Tracking
    cost_center_no TEXT,         -- Added for Cost Center in Tally Tracking
    created_at TIMESTAMPTZ DEFAULT NOW()
);



-- 4. COMPLAINTS
CREATE TABLE IF NOT EXISTS complaints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    truck_id UUID NOT NULL REFERENCES trucks(id) ON DELETE CASCADE,
    complaint_id TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    date_received DATE NOT NULL,
    mode TEXT DEFAULT 'Mail',
    reported_by TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Open' CHECK (status IN ('Open', 'Resolved')),
    diagnosis TEXT,
    closed_by TEXT,
    closed_date DATE,
    remarks TEXT,
    resolved_at TIMESTAMPTZ,
    delay_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. FEEDBACKS (New table for Reviews tab)
CREATE TABLE IF NOT EXISTS feedbacks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    feedback_text TEXT NOT NULL,
    feedback_date DATE NOT NULL,
    person_name TEXT,
    contact_number TEXT,
    mode TEXT DEFAULT 'Telephonic',
    rating INTEGER DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. WARRANTY COSTS
CREATE TABLE IF NOT EXISTS warranty_costs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    complaint_id UUID NOT NULL REFERENCES complaints(id) ON DELETE CASCADE UNIQUE,
    truck_id UUID NOT NULL REFERENCES trucks(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    labour_cost NUMERIC(12,2) DEFAULT 0,
    parts_cost NUMERIC(12,2) DEFAULT 0,
    travel_cost NUMERIC(12,2) DEFAULT 0,
    other_cost NUMERIC(12,2) DEFAULT 0,
    total_cost NUMERIC(12,2) DEFAULT 0,
    cost_status TEXT NOT NULL DEFAULT 'NOT ENTERED' CHECK (cost_status IN ('NOT ENTERED', 'DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED')),
    cost_coverage TEXT NOT NULL DEFAULT 'Warranty Covered' CHECK (cost_coverage IN ('Warranty Covered', 'Out of Warranty', 'Goodwill', 'Chargeable', 'Under Review')),
    cost_remarks TEXT,
    cost_recorded_by TEXT,
    cost_recorded_at TIMESTAMPTZ DEFAULT NOW(),
    cost_submitted_by TEXT,
    cost_submitted_at TIMESTAMPTZ,
    cost_approved_by TEXT,
    cost_approved_at TIMESTAMPTZ,
    cost_rejected_by TEXT,
    cost_rejected_at TIMESTAMPTZ,
    cost_rejection_reason TEXT,
    parts_detail JSONB DEFAULT '[]'::jsonb,
    labour_detail JSONB DEFAULT '[]'::jsonb,
    travel_detail JSONB DEFAULT '[]'::jsonb,
    other_detail JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. WARRANTY COST AUDIT
CREATE TABLE IF NOT EXISTS warranty_cost_audit (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    warranty_cost_id UUID REFERENCES warranty_costs(id) ON DELETE CASCADE,
    complaint_id UUID REFERENCES complaints(id) ON DELETE CASCADE,
    action TEXT NOT NULL,
    old_data JSONB,
    new_data JSONB,
    reason TEXT,
    performed_by TEXT NOT NULL,
    performed_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Default Categories
INSERT INTO categories (name) VALUES
    ('Chassis/Engine Issue'), ('Water Pump/Pump System'),
    ('PTO/Driveline'), ('Electrical/Siren/Lights'),
    ('Body Work/Locker/Tank'), ('Foam System/Proportioner'),
    ('Monitor/Nozzles')
ON CONFLICT (name) DO NOTHING;

-- 9. Security Policies
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE trucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE warranty_costs ENABLE ROW LEVEL SECURITY;
ALTER TABLE warranty_cost_audit ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for customers" ON customers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for categories" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for trucks" ON trucks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for complaints" ON complaints FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for feedbacks" ON feedbacks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for warranty_costs" ON warranty_costs FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for warranty_cost_audit" ON warranty_cost_audit FOR ALL USING (true) WITH CHECK (true);


-- 10. TRAINING QUESTIONS MASTER
CREATE TABLE IF NOT EXISTS training_questions (
    id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    question TEXT NOT NULL,
    details TEXT,
    display_order INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE training_questions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow all for training_questions" ON training_questions;
CREATE POLICY "Allow all for training_questions" ON training_questions FOR ALL USING (true) WITH CHECK (true);

INSERT INTO training_questions (id, category, question, details, display_order, active) VALUES
    ('Q_1', 'Chassis & Driveline', 'Chassis Pre-Drive Orientation & Pneumatic Air Brake Buildup Test', 'Pre-drive checks, air brake pressure charging time, ABS indicator, and steering clearance.', 1, true),
    ('Q_2', 'PTO & Transmission', 'Pneumatic PTO Engagement & Safety Interlock Verification', 'Neutral interlock, parking brake interlock, PTO engagement indicator lamp, and emergency override.', 2, true),
    ('Q_3', 'Fire Pump Operations', 'Centrifugal Fire Pump Stationary Pumping & RPM Governor Acceleration', 'Rated speed discharge test, engine speed governor response, pressure gauge calibration.', 3, true),
    ('Q_4', 'Priming & Suction', 'Suction Lift & Deep Water Priming Test (Vacuum Pull Time)', 'Vacuum build-up within 25-30s from open reservoir/hydrant, primer automatic disengagement.', 4, true),
    ('Q_5', 'High & Low Pressure', 'Twin-Pressure (LP / HP) Changeover & Thermal Relief Valve (TRV)', 'High-pressure hosereel rewind, fog gun nozzle test, TRV temperature discharge at 48°C.', 5, true),
    ('Q_6', 'Foam Proportioning', 'Around-The-Pump (ATP) Foam Induction & Ratio Selector (3% / 6%)', 'AFFF/AR-AFFF foam tank selector, proportioning ratio verification, and post-operation clean water flush.', 6, true),
    ('Q_7', 'Monitor Turret', 'Roof / Bumper Fire Monitor 360° Rotation & Fog-to-Jet Stream Control', 'Elevation travel, horizontal swivel rotation, spray pattern nozzle, and travel transport locking pins.', 7, true),
    ('Q_8', 'Emergency Warning', 'Multi-Pattern LED Lightbar, PA System & Electronic Siren Tone Tests', 'Wail, yelp, hi-lo tones, microphone clarity, scene lighting mast, and master battery isolator.', 8, true),
    ('Q_9', 'Locker & Tools', 'Equipment Locker Inventory Verification & Tool Mounting Security', 'Delivery hoses Type-B, diffuser branch pipes, SCBA brackets, suction wrenches, and roll-up shutter locks.', 9, true)
ON CONFLICT (id) DO NOTHING;
