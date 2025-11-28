-- Setup tabel journal_entries untuk menyimpan catatan mood
-- Jalankan script ini di Supabase SQL Editor

-- Buat tabel journal_entries
CREATE TABLE IF NOT EXISTS public.journal_entries (
  id TEXT PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  mood INTEGER NOT NULL CHECK (mood >= 1 AND mood <= 5),
  note TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  CONSTRAINT journal_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Buat index untuk mempercepat query
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id ON public.journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_created_at ON public.journal_entries(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;

-- Policy: User hanya bisa melihat journal entries miliknya sendiri
CREATE POLICY "Users can view own journal entries"
  ON public.journal_entries
  FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: User hanya bisa insert journal entries untuk dirinya sendiri
CREATE POLICY "Users can insert own journal entries"
  ON public.journal_entries
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: User hanya bisa update journal entries miliknya sendiri
CREATE POLICY "Users can update own journal entries"
  ON public.journal_entries
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Policy: User hanya bisa delete journal entries miliknya sendiri
CREATE POLICY "Users can delete own journal entries"
  ON public.journal_entries
  FOR DELETE
  USING (auth.uid() = user_id);

-- Function untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_journal_entries_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger untuk auto-update updated_at
CREATE TRIGGER update_journal_entries_updated_at_trigger
  BEFORE UPDATE ON public.journal_entries
  FOR EACH ROW
  EXECUTE FUNCTION update_journal_entries_updated_at();

-- Grant permissions untuk anon dan authenticated roles
GRANT SELECT, INSERT, UPDATE, DELETE ON public.journal_entries TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.journal_entries TO anon;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';

