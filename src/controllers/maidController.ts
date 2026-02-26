import { Request, Response } from 'express';
import { MaidService } from '../services/maidService';
import { FirestoreService } from '../services/firebaseService';

export const MaidController = {
  async register(req: Request, res: Response) {
    try {
      const maidId = await MaidService.register(req.body);
      res.status(201).json({ id: maidId, message: 'Maid profile created' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async getAvailable(req: Request, res: Response) {
    try {
      const service = req.query.service as string;
      const maids = await MaidService.getAvailable(service);
      res.json(maids);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async getById(req: Request, res: Response) {
    try {
      const maid = await FirestoreService.get('maids', req.params.id);
      if (!maid) return res.status(404).json({ error: 'Maid not found' });
      res.json(maid);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },
};
