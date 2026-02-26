import { FirestoreService } from './firebaseService';
import { Maid } from '../types/collections';

const COLLECTION = 'maids';

export const MaidService = {
  async register(data: Omit<Maid, 'id' | 'rating' | 'totalReviews' | 'isVerified'>) {
    return FirestoreService.create(COLLECTION, {
      ...data,
      rating: 0,
      totalReviews: 0,
      isVerified: false,
    });
  },

  async getAvailable(service: string) {
    return FirestoreService.query(COLLECTION, 'status', '==', 'available');
  },

  async updateRating(maidId: string, newRating: number) {
    const maid = await FirestoreService.get(COLLECTION, maidId) as Maid;
    if (!maid) return;

    const totalRating = maid.rating * maid.totalReviews + newRating;
    const newTotal = maid.totalReviews + 1;

    await FirestoreService.update(COLLECTION, maidId, {
      rating: totalRating / newTotal,
      totalReviews: newTotal,
    });
  },
};
