import { Router } from 'express';
import { AuthController } from '../controllers/authController';
import { BookingController } from '../controllers/bookingController';
import { MaidController } from '../controllers/maidController';
import { ReviewController } from '../controllers/reviewController';
import { PaymentController } from '../controllers/paymentController';
import { authenticate, authorize } from '../middleware/authMiddleware';

const router = Router();

// Auth routes
router.post('/auth/register', AuthController.register);
router.get('/auth/verify', AuthController.verifyToken);

// Booking routes
router.post('/bookings', authenticate, BookingController.create);
router.get('/bookings/customer/:customerId', authenticate, BookingController.getByCustomer);
router.get('/bookings/maid/:maidId', authenticate, BookingController.getByMaid);
router.patch('/bookings/:id/status', authenticate, BookingController.updateStatus);

// Maid routes
router.post('/maids', authenticate, MaidController.register);
router.get('/maids', MaidController.getAvailable);
router.get('/maids/:id', MaidController.getById);

// Review routes
router.post('/reviews', authenticate, ReviewController.create);
router.get('/reviews/maid/:maidId', ReviewController.getByMaid);

// Payment routes
router.post('/payments', authenticate, PaymentController.create);
router.patch('/payments/:id/complete', authenticate, PaymentController.complete);
router.patch('/payments/:id/refund', authenticate, authorize('admin'), PaymentController.refund);

export default router;
