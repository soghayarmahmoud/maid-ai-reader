import { FirestoreService } from './firebaseService';
import { BookingService } from './bookingService';

interface Payment {
  id: string;
  bookingId: string;
  customerId: string;
  amount: number;
  method: 'card' | 'cash' | 'wallet';
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  transactionId?: string;
  createdAt: Date;
}

const COLLECTION = 'payments';

export const PaymentService = {
  async create(data: Omit<Payment, 'id' | 'status' | 'createdAt'>) {
    const payment = {
      ...data,
      status: 'pending',
      createdAt: new Date(),
    };
    return FirestoreService.create(COLLECTION, payment);
  },

  async complete(paymentId: string, transactionId: string) {
    const payment = await FirestoreService.get(COLLECTION, paymentId) as Payment;
    
    await FirestoreService.update(COLLECTION, paymentId, {
      status: 'completed',
      transactionId,
    });

    // Update booking payment status
    await FirestoreService.update('bookings', payment.bookingId, {
      paymentStatus: 'paid',
    });
  },

  async refund(paymentId: string) {
    const payment = await FirestoreService.get(COLLECTION, paymentId) as Payment;
    
    await FirestoreService.update(COLLECTION, paymentId, { status: 'refunded' });
    await FirestoreService.update('bookings', payment.bookingId, {
      paymentStatus: 'refunded',
    });
  },

  async getByBooking(bookingId: string) {
    return FirestoreService.query(COLLECTION, 'bookingId', '==', bookingId);
  },
};
