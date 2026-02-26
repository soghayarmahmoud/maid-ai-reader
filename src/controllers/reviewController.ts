import { Request, Response } from 'express';
import { ReviewService } from '../services/reviewService';

export const ReviewController = {
  async create(req: Request, res: Response) {
    try {
      const id = await ReviewService.create(req.body);
      res.status(201).json({ id, message: 'Review created' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async getByMaid(req: Request, res: Response) {
    try {
      const reviews = await ReviewService.getByMaid(req.params.maidId);
      res.json(reviews);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },
};
