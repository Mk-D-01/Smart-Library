const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Middleware
app.use(cors({
  origin: ['http://localhost:8080', 'http://127.0.0.1:8080'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With', 'Cache-Control', 'Pragma']
}));
app.use(express.json());

// Handle preflight requests
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', req.headers.origin || '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With, Cache-Control, Pragma');
  res.header('Access-Control-Allow-Credentials', 'true');
  res.sendStatus(200);
});

// Helper functions
async function getLibraryStatus() {
  try {
    const { data, error } = await supabase
      .from('library_config')
      .select('*')
      .eq('id', 1)
      .single();
    
    if (error || !data) {
      // Return default config if none exists
      return {
        totalSeats: 400,
        occupiedSeats: 0,
        availableSeats: 400,
        occupancyPercentage: 0
      };
    }
    
    const occupiedSeats = data.occupied_seats || 0;
    const totalSeats = data.total_seats || 400;
    const availableSeats = totalSeats - occupiedSeats;
    const occupancyPercentage = Math.round((occupiedSeats / totalSeats) * 100);
    
    return {
      totalSeats,
      occupiedSeats,
      availableSeats,
      occupancyPercentage
    };
  } catch (error) {
    console.error('Error getting library status:', error);
    return {
      totalSeats: 400,
      occupiedSeats: 0,
      availableSeats: 400,
      occupancyPercentage: 0
    };
  }
}

async function updateOccupiedSeats(isEntry) {
  try {
    const currentStatus = await getLibraryStatus();
    const newOccupiedSeats = isEntry ? 
      currentStatus.occupiedSeats + 1 : 
      Math.max(0, currentStatus.occupiedSeats - 1);
    
    const { error } = await supabase
      .from('library_config')
      .update({ 
        occupied_seats: newOccupiedSeats,
        last_updated: new Date().toISOString()
      })
      .eq('id', 1);
    
    if (error) {
      console.error('Error updating occupied seats:', error);
      return false;
    }
    
    return true;
  } catch (error) {
    console.error('Error updating occupied seats:', error);
    return false;
  }
}

// Test endpoint for debugging
app.get('/api/test', (req, res) => {
  res.json({
    success: true,
    message: 'Backend is working!',
    timestamp: new Date().toISOString(),
    origin: req.headers.origin
  });
});

// Routes
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Smart Library Management System API',
    version: '1.0.0',
    endpoints: {
      status: '/api/status',
      scan: '/api/scan',
      studentsInside: '/api/students-inside',
      scanLogs: '/api/scan-logs',
      health: '/api/health'
    }
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    success: true,
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/api/status', async (req, res) => {
  try {
    const status = await getLibraryStatus();
    res.json({
      success: true,
      data: status
    });
  } catch (error) {
    console.error('Error in /api/status:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch library status'
    });
  }
});

app.post('/api/scan', async (req, res) => {
  try {
    const { studentId } = req.body;
    
    if (!studentId) {
      return res.status(400).json({
        success: false,
        error: 'Student ID is required'
      });
    }

    // Check for duplicate scan (within 5 seconds)
    const { data: lastScan } = await supabase
      .from('scan_logs')
      .select('*')
      .eq('student_id', studentId)
      .order('timestamp', { ascending: false })
      .limit(1)
      .single();
    
    if (lastScan) {
      const timeDiffMs = Date.now() - new Date(lastScan.timestamp).getTime();
      if (timeDiffMs < 5000) {
        return res.status(400).json({
          success: false,
          error: 'Duplicate scan detected. Please wait 5 seconds.'
        });
      }
    }

    // Get current student
    const { data: student, error: studentError } = await supabase
      .from('students')
      .select('*')
      .eq('id', studentId)
      .single();
    
    let isEntry = false;
    let studentData = student;
    
    if (studentError || !student) {
      // Create new student
      const { data: newStudent, error: createError } = await supabase
        .from('students')
        .insert({
          id: studentId,
          name: `Student ${studentId}`,
          email: `${studentId.toLowerCase()}@student.local`,
          current_status: 'INSIDE',
          scan_count: 1,
          created_at: new Date().toISOString()
        })
        .select()
        .single();
      
      if (createError) {
        console.error('Error creating student:', createError);
        return res.status(500).json({
          success: false,
          error: 'Failed to create student'
        });
      }
      
      studentData = newStudent;
      isEntry = true;
    } else {
      // Update existing student
      const currentScanCount = studentData.scan_count || 0;
      isEntry = currentScanCount % 2 === 0; // Even = Entry, Odd = Exit
      const newStatus = isEntry ? 'INSIDE' : 'OUTSIDE';
      
      const { error: updateError } = await supabase
        .from('students')
        .update({
          current_status: newStatus,
          scan_count: currentScanCount + 1,
          created_at: isEntry ? new Date().toISOString() : studentData.created_at
        })
        .eq('id', studentId);
      
      if (updateError) {
        console.error('Error updating student:', updateError);
        return res.status(500).json({
          success: false,
          error: 'Failed to update student'
        });
      }
    }

    // Update library occupancy
    const seatUpdated = await updateOccupiedSeats(isEntry);
    if (!seatUpdated) {
      return res.status(500).json({
        success: false,
        error: 'Failed to update library occupancy'
      });
    }

    // Log the scan
    const { error: logError } = await supabase
      .from('scan_logs')
      .insert({
        student_id: studentId,
        scan_type: isEntry ? 'ENTRY' : 'EXIT',
        timestamp: new Date().toISOString()
      });
    
    if (logError) {
      console.error('Error logging scan:', logError);
    }

    // Get updated library status
    const libraryStatus = await getLibraryStatus();

    res.json({
      success: true,
      action: isEntry ? 'ENTRY' : 'EXIT',
      student: {
        id: studentData.id,
        name: studentData.name,
        status: studentData.current_status
      },
      libraryStatus: {
        totalSeats: libraryStatus.totalSeats,
        occupiedSeats: libraryStatus.occupiedSeats,
        availableSeats: libraryStatus.availableSeats
      }
    });
    
  } catch (error) {
    console.error('Error in /api/scan:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.get('/api/students-inside', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('students')
      .select('*')
      .eq('current_status', 'INSIDE')
      .order('created_at', { ascending: false });
    
    if (error) {
      console.error('Error fetching students inside:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to fetch students'
      });
    }
    
    res.json({
      success: true,
      data: data || [],
      count: data ? data.length : 0
    });
  } catch (error) {
    console.error('Error in /api/students-inside:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.get('/api/scan-logs', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const { data, error } = await supabase
      .from('scan_logs')
      .select('*')
      .order('timestamp', { ascending: false })
      .limit(limit);
    
    if (error) {
      console.error('Error fetching scan logs:', error);
      return res.status(500).json({
        success: false,
        error: 'Failed to fetch scan logs'
      });
    }
    
    res.json({
      success: true,
      data: data || [],
      count: data ? data.length : 0
    });
  } catch (error) {
    console.error('Error in /api/scan-logs:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

app.post('/api/reset', async (req, res) => {
  try {
    // Reset all students to OUTSIDE
    const { error: studentError } = await supabase
      .from('students')
      .update({ current_status: 'OUTSIDE' })
      .neq('current_status', 'OUTSIDE');
    
    if (studentError) {
      console.error('Error resetting students:', studentError);
    }
    
    // Reset library config
    const { error: configError } = await supabase
      .from('library_config')
      .update({ 
        occupied_seats: 0,
        last_updated: new Date().toISOString()
      })
      .eq('id', 1);
    
    if (configError) {
      console.error('Error resetting library config:', configError);
    }
    
    res.json({
      success: true,
      message: 'Library system has been reset: all students OUTSIDE and occupied seats set to 0.'
    });
  } catch (error) {
    console.error('Error in /api/reset:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Smart Library API running on http://localhost:${PORT}`);
  console.log(`📚 Smart Library Management System`);
  console.log(`🏥 Health Check: http://localhost:${PORT}/api/health`);
  console.log(`🔗 Supabase URL: ${supabaseUrl}`);
});
