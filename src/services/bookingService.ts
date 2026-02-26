import { db } from '../config/firebase';
import { Booking } from '../types/collections';
import { MessagingService, FirestoreService } from './firebaseService';

const COLLECTION = 'bookings';

export const BookingService = {
  async create(data: Omit<Booking, 'id' | 'createdAt' | 'updatedAt'>) {
    const booking = {
      ...data,
      status: 'pending',
      paymentStatus: 'pending',
      createdAt: new Date(),
      updatedAt: new Date(),
    };
    const id = await FirestoreService.create(COLLECTION, booking);
    
    // Notify maid
    const maid = await FirestoreService.get('users', data.maidId);
    if (maid?.fcmToken) {
      await MessagingService.sendToDevice(
        maid.fcmToken,
        'New Booking Request',
        `You have a new ${data.service} booking`
      );
    }
    return id;
  },

  async getByCustomer(customerId: string) {
    return FirestoreService.query(COLLECTION, 'customerId', '==', customerId);
  },

  async getByMaid(maidId: string) {
    return FirestoreService.query(COLLECTION, 'maidId', '==', maidId);
  },

  async updateStatus(id: string, status: Booking['status']) {
    await FirestoreService.update(COLLECTION, id, { status, updatedAt: new Date() });
  },
};
