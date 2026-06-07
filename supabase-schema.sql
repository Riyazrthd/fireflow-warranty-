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
    insurance_expiry_date DATE, -- Added for Insurance Tracking
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
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Default Categories
INSERT INTO categories (name) VALUES
    ('Chassis/Engine Issue'), ('Water Pump/Pump System'),
    ('PTO/Driveline'), ('Electrical/Siren/Lights'),
    ('Body Work/Locker/Tank'), ('Foam System/Proportioner'),
    ('Monitor/Nozzles')
ON CONFLICT (name) DO NOTHING;

-- 7. Security Policies
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE trucks ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedbacks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for customers" ON customers FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for categories" ON categories FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for trucks" ON trucks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for complaints" ON complaints FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for feedbacks" ON feedbacks FOR ALL USING (true) WITH CHECK (true);