# Supabase Backend Setup for Customer Registry

## 1. Run the Schema

1. Go to [Supabase Dashboard](https://supabase.com/dashboard) and open your project
2. Navigate to **SQL Editor**
3. Copy the contents of `supabase-schema.sql` and run it

## 2. API Keys

The Customer Registry uses these credentials (configured in the HTML):

- **URL:** `https://zlyvxfkykpjacezfcqum.supabase.co`
- **Key:** Your publishable/anon key from **Project Settings → API**

> If you get auth errors, replace the key in `Customer Registry.html` with the **anon public** key from Supabase Dashboard (Settings → API → Project API keys). It typically starts with `eyJ...`.

## 3. Table Schemas (Reference)

| Table       | Purpose                               |
|------------|----------------------------------------|
| customers  | Client organizations (name, address, contact, etc.) |
| trucks     | Fire tenders linked to customers (PO, chassis, pump, warranty) |
| complaints | Support tickets linked to trucks (Open/Resolved) |
| categories | Complaint categories (configurable)    |

## 4. APIs Used by the Frontend

- `GET`  – Fetch customers, trucks, complaints, categories
- `POST` – Insert new records (customers, trucks, complaints, categories)
- `PATCH` – Update complaints (resolve tickets)
- `DELETE` – Remove customers, trucks, complaints, categories
- Realtime – Subscriptions for live updates when data changes
