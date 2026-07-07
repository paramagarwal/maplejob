const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

/**
 * 1. onUserSignup: Triggers when a new user account is created in Firebase Auth.
 * Automatically provisions a Firestore profile document under `/users/{uid}` with role: 'candidate'.
 */
exports.onUserSignup = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;
  
  const userRef = db.collection('users').doc(uid);
  
  const initialProfile = {
    uid: uid,
    email: email || '',
    fullName: displayName || '',
    phone: '',
    role: 'candidate', // default role
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    dob: '',
    gender: '',
    address: '',
    resumeUrl: '',
    resumeName: '',
    linkedinUrl: '',
    skills: [],
    education: []
  };

  try {
    await userRef.set(initialProfile, { merge: true });
    console.log(`Successfully provisioned candidate profile for user: ${uid}`);
  } catch (error) {
    console.error(`Error provisioning candidate profile for user ${uid}:`, error);
  }
});

/**
 * 2. onApplicationSubmit: Triggers when a new job application document is created in Firestore.
 * Simulates sending confirmation email (logs details) and automatically schedules screening actions.
 */
exports.onApplicationSubmit = functions.firestore
  .document('applications/{appId}')
  .onCreate(async (snapshot, context) => {
    const appData = snapshot.data();
    const { applicantName, applicantEmail, jobTitle, department } = appData;

    console.log(`New application received! ID: ${context.params.appId}`);
    console.log(`Applicant: ${applicantName} <${applicantEmail}>`);
    console.log(`Position: ${jobTitle} (${department})`);

    try {
      // Create a notification for the candidate confirmation
      const notifRef = db.collection('users').doc(appData.applicantId).collection('notifications');
      await notifRef.add({
        title: 'Application Received',
        message: `Thank you for applying to the "${jobTitle}" position. Our team is currently reviewing your resume!`,
        type: 'info',
        isRead: false,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log(`Auto-confirmation notification written for applicant: ${appData.applicantId}`);
    } catch (error) {
      console.error('Error in onApplicationSubmit background trigger:', error);
    }
  });
