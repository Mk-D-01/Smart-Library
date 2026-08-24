import path from 'path';
import dotenv from 'dotenv';

process.env.NODE_ENV = 'test';

dotenv.config({
  path: path.resolve(__dirname, '../../.env'),
});

process.env.SUPABASE_URL = process.env.SUPABASE_URL || 'https://placeholder-project.supabase.co';
process.env.SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY || 'placeholder-service-key';
process.env.SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'placeholder-anon-key';

