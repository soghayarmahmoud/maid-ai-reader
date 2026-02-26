import { db, auth, storage, messaging } from '../config/firebase';

// ============ FIRESTORE ============
export const FirestoreService = {
  // Create document
  async create(collection: string, data: object, id?: string) {
    if (id) {
      await db.collection(collection).doc(id).set(data);
      return id;
    }
    const doc = await db.collection(collection).add(data);
    return doc.id;
  },

  // Get document
  async get(collection: string, id: string) {
    const doc = await db.collection(collection).doc(id).get();
    return doc.exists ? { id: doc.id, ...doc.data() } : null;
  },

  // Query documents
  async query(collection: string, field: string, operator: FirebaseFirestore.WhereFilterOp, value: any) {
    const snapshot = await db.collection(collection).where(field, operator, value).get();
    return snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
  },

  // Update document
  async update(collection: string, id: string, data: object) {
    await db.collection(collection).doc(id).update(data);
  },

  // Delete document
  async delete(collection: string, id: string) {
    await db.collection(collection).doc(id).delete();
  },
};

// ============ AUTHENTICATION ============
export const AuthService = {
  // Create user
  async createUser(email: string, password: string, displayName?: string) {
    return auth.createUser({ email, password, displayName });
  },

  // Verify ID token
  async verifyToken(idToken: string) {
    return auth.verifyIdToken(idToken);
  },

  // Get user by ID
  async getUser(uid: string) {
    return auth.getUser(uid);
  },

  // Set custom claims (roles)
  async setRole(uid: string, role: 'customer' | 'maid' | 'admin') {
    await auth.setCustomUserClaims(uid, { role });
  },
};

// ============ STORAGE ============
export const StorageService = {
  // Upload file
  async upload(filePath: string, destination: string): Promise<string> {
    await storage.upload(filePath, { destination });
    const file = storage.file(destination);
    await file.makePublic();
    return `https://storage.googleapis.com/${storage.name}/${destination}`;
  },

  // Delete file
  async delete(destination: string) {
    await storage.file(destination).delete();
  },
};

// ============ MESSAGING ============
export const MessagingService = {
  // Send to single device
  async sendToDevice(token: string, title: string, body: string, data?: object) {
    return messaging.send({
      token,
      notification: { title, body },
      data: data as Record<string, string>,
    });
  },

  // Send to topic (e.g., all maids in an area)
  async sendToTopic(topic: string, title: string, body: string) {
    return messaging.send({
      topic,
      notification: { title, body },
    });
  },
};
