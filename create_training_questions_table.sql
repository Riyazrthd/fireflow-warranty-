-- ==============================================================================
-- 🚒 FIREFLOW WARRANTY & COMMISSIONING PORTAL
-- STANDALONE MIGRATION: COMMISSIONING & OPERATOR TRAINING QUESTIONS MASTER
-- ==============================================================================
-- Run this script in your Supabase project SQL Editor:
-- https://supabase.com/dashboard/project/zlyvxfkykpjacezfcqum/sql
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Create table if not exists
CREATE TABLE IF NOT EXISTS public.training_questions (
    id TEXT PRIMARY KEY DEFAULT ('Q_' || UPPER(SUBSTRING(gen_random_uuid()::TEXT, 1, 6))),
    category TEXT NOT NULL,
    question TEXT NOT NULL,
    details TEXT,
    display_order INTEGER DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW()) NOT NULL
);

-- 2. Safely add missing columns if table already existed
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS question TEXT;
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS details TEXT;
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0;
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS active BOOLEAN DEFAULT TRUE;
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());
ALTER TABLE public.training_questions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::TEXT, NOW());

-- 3. Indexes for fast sorting and querying
CREATE INDEX IF NOT EXISTS idx_training_questions_order ON public.training_questions(display_order);
CREATE INDEX IF NOT EXISTS idx_training_questions_active ON public.training_questions(active);

-- 4. Enable Row Level Security (RLS) and permissive access policies
ALTER TABLE public.training_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public all on training_questions" ON public.training_questions;
CREATE POLICY "Allow public all on training_questions" ON public.training_questions FOR ALL USING (true) WITH CHECK (true);

-- 5. Realtime publication (enables instant multi-device syncing)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'training_questions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.training_questions;
    END IF;
EXCEPTION
    WHEN OTHERS THEN NULL;
END $$;

-- 6. Seed initial 10 standard commissioning questions
INSERT INTO public.training_questions (id, category, question, details, display_order, active)
VALUES
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
