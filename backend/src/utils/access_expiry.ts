// Utility functions for student access expiry logic

// Degree duration mapping (in years)
const DEGREE_DURATIONS: Record<string, number> = {
  'BTech': 4,
  'MBA': 2,
  'BBA': 3,
  'BPharma': 4,
  'BSc': 3,
  'MSc': 2,
  'BCA': 3,
  'MCA': 2,
};

/**
 * Calculate access expiry date based on admission date and degree
 * Rule: Always expires on June 30 of the final year
 * 
 * @param admissionDate - ISO date string (e.g., '2025-06-15')
 * @param degree - Degree program name
 * @returns ISO date string of expiry date
 */
export const calculateAccessExpiryDate = (
  admissionDate: string,
  degree: string
): string => {
  try {
    const duration = DEGREE_DURATIONS[degree];
    if (!duration) {
      console.warn(`Unknown degree: ${degree}, defaulting to 4 years`);
      return calculateAccessExpiryDate(admissionDate, 'BTech');
    }

    const admissionYear = new Date(admissionDate).getFullYear();
    const expiryYear = admissionYear + duration;
    
    // Always set expiry to June 30 of the final year
    return `${expiryYear}-06-30`;
  } catch (error) {
    console.error('Error calculating access expiry date:', error);
    throw new Error(`Invalid admission date format: ${admissionDate}`);
  }
};

/**
 * Check if a student's access has expired
 * 
 * @param expiryDate - ISO date string
 * @returns true if expired, false if still valid
 */
export const isAccessExpired = (expiryDate: string): boolean => {
  try {
    const today = new Date();
    const expiry = new Date(expiryDate);
    return today > expiry;
  } catch (error) {
    console.error('Error checking access expiry:', error);
    return false; // Allow access if error occurs
  }
};

/**
 * Get days remaining until access expiry
 * 
 * @param expiryDate - ISO date string
 * @returns Number of days remaining, or negative if expired
 */
export const daysUntilExpiry = (expiryDate: string): number => {
  try {
    const today = new Date();
    const expiry = new Date(expiryDate);
    const diffTime = expiry.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  } catch (error) {
    console.error('Error calculating days until expiry:', error);
    return 0;
  }
};

/**
 * Format expiry information for display
 * 
 * @param expiryDate - ISO date string
 * @returns Formatted message about access status
 */
export const getAccessExpiryMessage = (expiryDate: string): string => {
  const days = daysUntilExpiry(expiryDate);
  
  if (days < 0) {
    return `Your library access expired ${Math.abs(days)} days ago`;
  } else if (days === 0) {
    return 'Your library access expires today';
  } else if (days <= 7) {
    return `Your library access expires in ${days} days`;
  } else {
    return `Your library access expires on ${expiryDate}`;
  }
};
