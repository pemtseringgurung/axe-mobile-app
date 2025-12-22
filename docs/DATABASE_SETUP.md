# Supabase Database Setup for Budget Management

Run these SQL commands in your Supabase SQL Editor:

## 1. Categories Table (predefined spending categories)

```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL,
    is_default BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, icon, color) VALUES
    ('Food & Dining', 'fork.knife', '#FF6B6B'),
    ('Transportation', 'car.fill', '#4ECDC4'),
    ('Shopping', 'bag.fill', '#45B7D1'),
    ('Entertainment', 'tv.fill', '#96CEB4'),
    ('Bills & Utilities', 'bolt.fill', '#FFEAA7'),
    ('Health', 'heart.fill', '#DDA0DD'),
    ('Travel', 'airplane', '#74B9FF'),
    ('Education', 'book.fill', '#A29BFE'),
    ('Personal Care', 'sparkles', '#FD79A8'),
    ('Other', 'ellipsis.circle.fill', '#636E72');
```

## 2. Budgets Table (user's monthly budgets per category)

```sql
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(10,2) NOT NULL,
    month INTEGER NOT NULL, -- 1-12
    year INTEGER NOT NULL,
    rollover_enabled BOOLEAN DEFAULT false,
    rollover_amount DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, category_id, month, year)
);

-- Enable RLS
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- Users can only see/edit their own budgets
CREATE POLICY "Users can view own budgets" ON budgets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own budgets" ON budgets
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own budgets" ON budgets
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own budgets" ON budgets
    FOR DELETE USING (auth.uid() = user_id);
```

## 3. Transactions Table (for future use)

```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    category_id UUID REFERENCES categories(id),
    amount DECIMAL(10,2) NOT NULL,
    description TEXT,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions" ON transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own transactions" ON transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own transactions" ON transactions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own transactions" ON transactions
    FOR DELETE USING (auth.uid() = user_id);
```

## 4. Enable public read for categories

```sql
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories" ON categories
    FOR SELECT USING (true);
```
