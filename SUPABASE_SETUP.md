# Setup Supabase untuk Authentication

## Masalah yang Ditemukan

1. **Error Schema Cache**: "Could not find the table 'public.users' in the schema cache"
   - Ini terjadi karena Supabase PostgREST perlu refresh schema cache setelah membuat tabel baru
   
2. **RLS Policy**: Data tidak masuk karena RLS Policy terlalu ketat
   
3. **Foreign Key Constraint**: Jika ada foreign key constraint yang belum dikonfigurasi

## Solusi: Setup RLS Policy di Supabase

### ⚠️ LANGKAH PENTING: Refresh Schema Cache

**Sebelum setup RLS, pastikan refresh schema cache terlebih dahulu!**

1. Buka Supabase Dashboard
2. Pilih project Anda
3. Klik **Settings** (ikon gear) di sidebar kiri
4. Klik **API** di menu settings
5. Scroll ke bawah, cari section **Schema Cache**
6. Klik tombol **Refresh Schema Cache** atau **Reload Schema**
7. Tunggu beberapa detik sampai selesai

Ini akan menyelesaikan error "Could not find the table 'public.users' in the schema cache"

### Langkah 1: Buka SQL Editor di Supabase Dashboard

1. Login ke Supabase Dashboard Anda
2. Pilih project Anda
3. Klik **SQL Editor** di sidebar kiri
4. Buat **New Query**

### Langkah 2: Pastikan Tabel `users` Terhubung dengan `auth.users`

Jalankan SQL berikut untuk memastikan foreign key sudah benar:

```sql
-- Cek apakah foreign key sudah ada
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
FROM 
    information_schema.table_constraints AS tc 
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name='users';
```

### Langkah 3: Setup Foreign Key (Jika Belum Ada)

Jika foreign key belum ada, jalankan:

```sql
-- Tambah foreign key dari users.id ke auth.users.id
ALTER TABLE public.users
ADD CONSTRAINT users_id_fkey 
FOREIGN KEY (id) 
REFERENCES auth.users(id) 
ON DELETE CASCADE;
```

### Langkah 4: Setup RLS Policy

Hapus semua policy yang ada dan buat yang baru:

```sql
-- Hapus semua policy yang ada (jika ada)
DROP POLICY IF EXISTS "Users can insert own data" ON public.users;
DROP POLICY IF EXISTS "Users can view own data" ON public.users;
DROP POLICY IF EXISTS "Users can update own data" ON public.users;
DROP POLICY IF EXISTS "Users can delete own data" ON public.users;

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Policy untuk INSERT (user bisa insert data sendiri saat sign up)
CREATE POLICY "Enable insert for authenticated users"
ON public.users
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Policy untuk SELECT (user bisa melihat data sendiri)
CREATE POLICY "Enable select for authenticated users"
ON public.users
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- Policy untuk UPDATE (user bisa update data sendiri)
CREATE POLICY "Enable update for authenticated users"
ON public.users
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);
```

### Langkah 5: Buat Trigger untuk Auto-Create User Profile (OPSIONAL)

Jika Anda ingin profil user otomatis dibuat saat sign up, buat trigger:

```sql
-- Function untuk membuat user profile otomatis
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email)
  VALUES (NEW.id, NEW.email)
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger yang dipanggil setelah user dibuat di auth.users
CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**CATATAN:** Jika Anda menggunakan trigger ini, Anda perlu menonaktifkan policy INSERT di atas, atau ubah policy menjadi:

```sql
-- Policy untuk INSERT menggunakan service role (untuk trigger)
CREATE POLICY "Enable insert via trigger"
ON public.users
FOR INSERT
TO service_role
WITH CHECK (true);
```

### Langkah 6: Alternatif - Nonaktifkan RLS Sementara (UNTUK TESTING SAJA)

**PERINGATAN:** Jangan gunakan ini di production! Hanya untuk testing.

```sql
-- Nonaktifkan RLS sementara untuk testing
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
```

Setelah testing berhasil, aktifkan kembali RLS dan gunakan policy di atas.

## Verifikasi

Setelah setup selesai:

1. Coba registrasi user baru dari aplikasi
2. Cek di Supabase Dashboard → Table Editor → `users` 
3. Data user seharusnya sudah muncul

## Troubleshooting

### Error: "new row violates row-level security policy"
- Pastikan RLS Policy sudah dibuat dengan benar
- Pastikan user sudah authenticated saat insert
- Cek apakah policy INSERT sudah aktif

### Error: "foreign key constraint"
- Pastikan `id` di tabel `users` sesuai dengan `id` di `auth.users`
- Pastikan foreign key constraint sudah dibuat

### Error: "duplicate key value"
- Email atau username sudah terdaftar
- Coba gunakan email/username yang berbeda

## Kontak Support

Jika masih ada masalah, kirimkan:
1. Error message lengkap dari aplikasi
2. Screenshot dari Supabase Dashboard (Table Editor dan SQL Editor)
3. Log dari Supabase Logs

