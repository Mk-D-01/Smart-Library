import { createClient, SupabaseClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY!;

export const db: SupabaseClient = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Initialize database (for Supabase, this mainly validates connection)
export const initializeDatabase = async () => {
  try {
    // Test connection by checking library_config table
    const { data, error } = await db.from('library_config').select('*').limit(1);
    
    if (error) {
      console.error('❌ Supabase connection error:', error);
      throw error;
    }
    
    console.log('✅ Supabase database connected successfully');
    
    // Ensure library config exists
    if (!data || data.length === 0) {
      const { error: insertError } = await db
        .from('library_config')
        .upsert({
          id: 1,
          total_seats: 100,
          occupied_seats: 0,
          last_updated: new Date().toISOString()
        });
      
      if (insertError) {
        console.error('❌ Error inserting library config:', insertError);
        throw insertError;
      }
      
      console.log('✅ Initial library configuration inserted');
    }
    
    console.log('🚀 Database initialized with Smart Library schema');
  } catch (error) {
    console.error('❌ Error initializing database:', error);
    throw error;
  }
};

export const closeDatabase = () => {
  // Supabase client doesn't need explicit closing
  console.log('⏹️ Database connection closed');
};

export default db;
