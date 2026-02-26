import { Request, Response } from 'express';
import { BookingService } from '../services/bookingService';

export const BookingController = {
  async create(req: Request, res: Response) {
    try {
      const bookingId = await BookingService.create(req.body);
      res.status(201).json({ id: bookingId, message: 'Booking created' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async getByCustomer(req: Request, res: Response) {
    try {
      const bookings = await BookingService.getByCustomer(req.params.customerId);
      res.json(bookings);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async getByMaid(req: Request, res: Response) {
    try {
      const bookings = await BookingService.getByMaid(req.params.maidId);
      res.json(bookings);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async updateStatus(req: Request, res: Response) {
    try {
      await BookingService.updateStatus(req.params.id, req.body.status);
      res.json({ message: 'Status updated' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },
};
