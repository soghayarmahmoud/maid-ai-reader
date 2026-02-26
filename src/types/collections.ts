export interface User {
  id: string;
  email: string;
  phone: string;
  displayName: string;
  photoUrl?: string;
  role: 'customer' | 'maid' | 'admin';
  address?: Address;
  fcmToken?: string; // For push notifications
  createdAt: Date;
  updatedAt: Date;
}

export interface Maid {
  id: string;
  userId: string;
  services: string[]; // ['cleaning', 'laundry', 'cooking']
  hourlyRate: number;
  rating: number;
  totalReviews: number;
  availability: Availability[];
  isVerified: boolean;
  idDocumentUrl?: string;
  bio?: string;
  status: 'available' | 'busy' | 'offline';
}

export interface Booking {
  id: string;
  customerId: string;
  maidId: string;
  service: string;
  address: Address;
  scheduledDate: Date;
  duration: number; // in hours
  totalPrice: number;
  status: 'pending' | 'confirmed' | 'in-progress' | 'completed' | 'cancelled';
  paymentStatus: 'pending' | 'paid' | 'refunded';
  notes?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface Review {
  id: string;
  bookingId: string;
  customerId: string;
  maidId: string;
  rating: number; // 1-5
  comment?: string;
  createdAt: Date;
}

export interface Service {
  id: string;
  name: string;
  description: string;
  basePrice: number;
  duration: number; // estimated hours
  icon?: string;
}

export interface Address {
  street: string;
  city: string;
  state: string;
  zipCode: string;
  coordinates?: {
    lat: number;
    lng: number;
  };
}

export interface Availability {
  dayOfWeek: number; // 0-6 (Sunday-Saturday)
  startTime: string; // "09:00"
  endTime: string;   // "17:00"
}

export interface Payment {
  id: string;
  bookingId: string;
  customerId: string;
  amount: number;
  method: 'card' | 'cash' | 'wallet';
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  transactionId?: string;
  createdAt: Date;
}
