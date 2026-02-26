import { Request, Response } from 'express';
import { PaymentService } from '../services/paymentService';

export const PaymentController = {
  async create(req: Request, res: Response) {
    try {
      const id = await PaymentService.create(req.body);
      res.status(201).json({ id, message: 'Payment initiated' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async complete(req: Request, res: Response) {
    try {
      await PaymentService.complete(req.params.id, req.body.transactionId);
      res.json({ message: 'Payment completed' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async refund(req: Request, res: Response) {
    try {
      await PaymentService.refund(req.params.id);
      res.json({ message: 'Payment refunded' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },
};
