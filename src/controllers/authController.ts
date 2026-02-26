import { Request, Response } from 'express';
import { AuthService, FirestoreService } from '../services/firebaseService';
import { User } from '../types/collections';

export const AuthController = {
  async register(req: Request, res: Response) {
    try {
      const { email, password, displayName, phone, role } = req.body;

      const firebaseUser = await AuthService.createUser(email, password, displayName);
      await AuthService.setRole(firebaseUser.uid, role);

      const user: Omit<User, 'id'> = {
        email,
        phone,
        displayName,
        role,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await FirestoreService.create('users', user, firebaseUser.uid);

      res.status(201).json({ uid: firebaseUser.uid, message: 'User created' });
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  },

  async verifyToken(req: Request, res: Response) {
    try {
      const token = req.headers.authorization?.split('Bearer ')[1];
      if (!token) return res.status(401).json({ error: 'No token provided' });

      const decoded = await AuthService.verifyToken(token);
      res.json({ uid: decoded.uid, role: decoded.role });
    } catch (error: any) {
      res.status(401).json({ error: 'Invalid token' });
    }
  },
};
