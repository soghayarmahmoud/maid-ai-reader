import { FirestoreService } from './firebaseService';
import { MaidService } from './maidService';
import { Review } from '../types/collections';

const COLLECTION = 'reviews';

export const ReviewService = {
  async create(data: Omit<Review, 'id' | 'createdAt'>) {
    const review = {
      ...data,
      createdAt: new Date(),
    };
    const id = await FirestoreService.create(COLLECTION, review);
    
    // Update maid rating
    await MaidService.updateRating(data.maidId, data.rating);
    
    return id;
  },

  async getByMaid(maidId: string) {
    return FirestoreService.query(COLLECTION, 'maidId', '==', maidId);
  },

  async getByCustomer(customerId: string) {
    return FirestoreService.query(COLLECTION, 'customerId', '==', customerId);
  },
};
