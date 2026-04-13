-- ============================================================
-- DEVMA APP — Supabase SQL Schema
-- Exécuter dans l'éditeur SQL de ton projet Supabase
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── PROFILES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL DEFAULT '',
  email TEXT,
  avatar_url TEXT,
  university TEXT DEFAULT 'FAST — Université de Parakou',
  field TEXT DEFAULT 'Licence Mathématiques Fondamentales',
  role TEXT DEFAULT 'member' CHECK (role IN ('member','admin','initiator')),
  skills TEXT[] DEFAULT '{}',
  bio TEXT,
  points INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name, email, university, field, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'university', 'FAST — Université de Parakou'),
    COALESCE(NEW.raw_user_meta_data->>'field', ''),
    'member'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Increment points function
CREATE OR REPLACE FUNCTION increment_points(user_id UUID, points_to_add INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE profiles SET points = points + points_to_add WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ── EVENTS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  emoji TEXT DEFAULT '📅',
  date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  location TEXT,
  max_participants INTEGER,
  tag TEXT DEFAULT 'Événement',
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS event_registrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES events(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  registered_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- ── HACKATHONS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS hackathons (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  theme TEXT,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  max_team_size INTEGER DEFAULT 4,
  status TEXT DEFAULT 'upcoming' CHECK (status IN ('upcoming','ongoing','finished')),
  prizes JSONB DEFAULT '[]',
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS hackathon_teams (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  hackathon_id UUID REFERENCES hackathons(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  members UUID[] DEFAULT '{}',
  project_title TEXT,
  project_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── COURSES ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT DEFAULT '📚',
  level TEXT DEFAULT 'Débutant' CHECK (level IN ('Débutant','Intermédiaire','Avancé')),
  category TEXT,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS course_modules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  video_url TEXT,
  duration_minutes INTEGER DEFAULT 30,
  order_index INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS user_course_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE CASCADE,
  completed_modules INTEGER DEFAULT 0,
  progress_percent INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- ── QUIZZES ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quizzes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  category TEXT,
  difficulty TEXT DEFAULT 'Débutant',
  points_reward INTEGER DEFAULT 20,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]',
  correct_index INTEGER NOT NULL,
  explanation TEXT,
  order_index INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  score INTEGER DEFAULT 0,
  total_questions INTEGER,
  points_earned INTEGER DEFAULT 0,
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── PROJECTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS projects (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  emoji TEXT DEFAULT '🚀',
  stack TEXT[] DEFAULT '{}',
  status TEXT DEFAULT 'Idée' CHECK (status IN ('Idée','En cours','Terminé')),
  github_url TEXT,
  demo_url TEXT,
  created_by UUID REFERENCES profiles(id),
  team_members UUID[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── ANNOUNCEMENTS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS announcements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT,
  tag TEXT DEFAULT 'Info',
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── RESOURCES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS resources (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  url TEXT NOT NULL,
  category TEXT,
  description TEXT,
  added_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── AI CONVERSATIONS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ai_conversations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  title TEXT DEFAULT 'Nouvelle conversation',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ai_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  conversation_id UUID REFERENCES ai_conversations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user','model')),
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ── ROW LEVEL SECURITY ────────────────────────────────────────
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE hackathons ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;

-- Profiles: visible to all authenticated, editable by owner
CREATE POLICY "profiles_select" ON profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Events: visible to all, created by admin/initiator
CREATE POLICY "events_select" ON events FOR SELECT TO authenticated USING (true);
CREATE POLICY "events_insert" ON events FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

-- Event registrations
CREATE POLICY "registrations_select" ON event_registrations FOR SELECT TO authenticated USING (true);
CREATE POLICY "registrations_insert" ON event_registrations FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- Hackathons: visible to all
CREATE POLICY "hackathons_select" ON hackathons FOR SELECT TO authenticated USING (true);

-- Courses & modules: visible to all
CREATE POLICY "courses_select" ON courses FOR SELECT TO authenticated USING (true);
CREATE POLICY "progress_all" ON user_course_progress FOR ALL TO authenticated USING (auth.uid() = user_id);

-- Quizzes
CREATE POLICY "quizzes_select" ON quizzes FOR SELECT TO authenticated USING (true);
CREATE POLICY "attempts_all" ON quiz_attempts FOR ALL TO authenticated USING (auth.uid() = user_id);

-- Projects
CREATE POLICY "projects_select" ON projects FOR SELECT TO authenticated USING (true);
CREATE POLICY "projects_insert" ON projects FOR INSERT TO authenticated WITH CHECK (auth.uid() = created_by);

-- Announcements
CREATE POLICY "announcements_select" ON announcements FOR SELECT TO authenticated USING (true);

-- Resources
CREATE POLICY "resources_select" ON resources FOR SELECT TO authenticated USING (true);

-- AI
CREATE POLICY "ai_conv_all" ON ai_conversations FOR ALL TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "ai_msg_all" ON ai_messages FOR ALL TO authenticated USING (
  conversation_id IN (SELECT id FROM ai_conversations WHERE user_id = auth.uid())
);

-- ── SEED DATA ─────────────────────────────────────────────────
INSERT INTO events (title, emoji, date, location, tag, description) VALUES
  ('Session Python débutant', '🐍', NOW() + INTERVAL '6 days', 'Salle B204', 'Formation', 'Introduction à Python pour les débutants. Variables, boucles, fonctions.'),
  ('Hackathon DevMa #1', '🎯', NOW() + INTERVAL '13 days', 'Campus FAST', 'Hackathon', 'Premier hackathon officiel DevMa. Thème : Agriculture & Tech en Afrique de l''Ouest. 24h de code.'),
  ('Atelier Git & GitHub', '🔧', NOW() + INTERVAL '21 days', 'En ligne', 'Atelier', 'Maîtrise le versioning avec Git et GitHub. Branches, pull requests, collaboration.');

INSERT INTO courses (title, description, icon, level, category, order_index) VALUES
  ('Python Fondamentaux', 'Variables, boucles, fonctions et POO', '🐍', 'Débutant', 'Python', 1),
  ('HTML/CSS/JavaScript', 'Bases du développement web front-end', '🌐', 'Débutant', 'Web', 2),
  ('Flutter & Dart', 'Apps mobiles cross-platform avec Flutter', '📱', 'Intermédiaire', 'Mobile', 3),
  ('Bases de données SQL', 'PostgreSQL, requêtes avancées et optimisation', '🗄️', 'Intermédiaire', 'Data', 4),
  ('Data Science avec Python', 'Pandas, NumPy, matplotlib, scikit-learn', '📊', 'Avancé', 'Data', 5),
  ('Cryptographie & Sécurité', 'Algorithmes, protocoles modernes et bonnes pratiques', '🔐', 'Avancé', 'Sécurité', 6);

INSERT INTO quizzes (title, description, category, difficulty, points_reward) VALUES
  ('Python — Les bases', 'Teste tes connaissances sur les fondamentaux Python', 'Python', 'Débutant', 20),
  ('Git & Versionning', 'Maîtrises-tu Git ? Commandes, branches, merge...', 'DevOps', 'Débutant', 20),
  ('SQL Bases', 'SELECT, WHERE, JOIN — les fondamentaux SQL', 'Data', 'Intermédiaire', 30),
  ('Algorithmique', 'Tri, recherche et complexité', 'Algo', 'Avancé', 50);

INSERT INTO announcements (title, content, tag) VALUES
  ('Hackathon DevMa #1 — Inscriptions ouvertes !', 'Les inscriptions pour notre premier hackathon officiel sont maintenant ouvertes. Thème : Agriculture & Tech en Afrique de l''Ouest. Équipes de 2 à 4 personnes.', 'Événement'),
  ('Nouveau module disponible : Cryptographie & Sécurité', 'Un nouveau module de 8 séances sur la cryptographie vient d''être ajouté. Il couvre les algorithmes classiques, les protocoles modernes et les meilleures pratiques.', 'Apprentissage'),
  ('Bienvenue à DevMa !', 'Le club de codage DevMa est officiellement lancé sur le campus FAST. Rejoignez-nous et participez aux prochains événements.', 'Communauté');
