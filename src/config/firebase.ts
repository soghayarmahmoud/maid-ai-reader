import * as admin from 'firebase-admin';
import * as path from 'path';

const serviceAccountPath = path.join(
  __dirname,
  '../../maid1-37922-firebase-adminsdk-fbsvc-01dbb7ae1e.json'
);

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccountPath),
    storageBucket: 'maid1-37922.appspot.com',
  });
}

// Firestore Database
export const db = admin.firestore();

// Authentication
export const auth = admin.auth();

// Cloud Storage
export const storage = admin.storage().bucket();

// Cloud Messaging
export const messaging = admin.messaging();

export default admin;
