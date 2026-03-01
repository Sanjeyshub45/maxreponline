const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const cors = require('cors')({ origin: true });

admin.initializeApp();

// Hardcoded for simplicity as requested, but stored backend-side
const STRAVA_CLIENT_ID = '207045';
const STRAVA_CLIENT_SECRET = '21f3c66018ac7135f5de2bd6e70de0fdd4016110';
const REDIRECT_URI = 'https://us-central1-maxreponline.cloudfunctions.net/stravaCallback';

// ─── Helper: verify Firebase ID token from Authorization header ────────────
async function verifyAuth(req, res) {
    const authHeader = req.headers.authorization || '';
    const idToken = authHeader.startsWith('Bearer ') ? authHeader.split('Bearer ')[1] : null;
    if (!idToken) {
        res.status(401).json({ error: 'Missing Authorization header' });
        return null;
    }
    try {
        const decoded = await admin.auth().verifyIdToken(idToken);
        return decoded.uid;
    } catch (e) {
        res.status(401).json({ error: 'Invalid or expired ID token' });
        return null;
    }
}

// 1. Generate the Strava OAuth Link (onRequest — no App Check needed)
exports.stravaLinkUrl = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        const userId = await verifyAuth(req, res);
        if (!userId) return; // verifyAuth already sent the error response

        const url = `https://www.strava.com/oauth/authorize?client_id=${STRAVA_CLIENT_ID}&response_type=code&redirect_uri=${REDIRECT_URI}&approval_prompt=force&scope=activity:read_all&state=${userId}`;
        res.json({ url });
    });
});

// 2. Handle the OAuth Callback and Store Tokens
exports.stravaCallback = functions.https.onRequest(async (req, res) => {
    const code = req.query.code;
    const userId = req.query.state;

    if (!code || !userId) {
        return res.status(400).send('Missing code or state parameter.');
    }

    try {
        const response = await axios.post('https://www.strava.com/oauth/token', {
            client_id: STRAVA_CLIENT_ID,
            client_secret: STRAVA_CLIENT_SECRET,
            code: code,
            grant_type: 'authorization_code'
        });

        const { access_token, refresh_token, expires_at } = response.data;

        await admin.firestore().collection('users').doc(userId).update({
            strava_linked: true,
            strava_access_token: access_token,
            strava_refresh_token: refresh_token,
            strava_token_expires_at: expires_at,
        });

        return res.status(200).send(`
            <html>
            <body style="display:flex; flex-direction:column; align-items:center; justify-content:center; height:100vh; font-family:sans-serif; background-color:#1E1E1E; color:white;">
                <h1 style="color:#FFD60A;">Successfully Linked Strava!</h1>
                <p>You may now close this window and return to the MaxRep app.</p>
            </body>
            </html>
        `);
    } catch (error) {
        console.error('Strava Callback Error:', error.response?.data || error.message);
        return res.status(500).send('Authentication failed.');
    }
});

// Helper to refresh token if expired
async function getValidAccessToken(userId) {
    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    if (!userDoc.exists) return null;

    const data = userDoc.data();
    if (!data.strava_refresh_token) return null;

    const now = Math.floor(Date.now() / 1000);
    if (data.strava_token_expires_at && data.strava_token_expires_at > now + 300) {
        return data.strava_access_token;
    }

    // Token expired, refresh it
    try {
        const response = await axios.post('https://www.strava.com/oauth/token', {
            client_id: STRAVA_CLIENT_ID,
            client_secret: STRAVA_CLIENT_SECRET,
            grant_type: 'refresh_token',
            refresh_token: data.strava_refresh_token,
        });

        const { access_token, refresh_token, expires_at } = response.data;

        await admin.firestore().collection('users').doc(userId).update({
            strava_access_token: access_token,
            strava_refresh_token: refresh_token,
            strava_token_expires_at: expires_at,
        });

        return access_token;
    } catch (error) {
        console.error('Token Refresh Error:', error.response?.data || error.message);
        return null;
    }
}

// 3. Fetch Today's Walking Stats (onRequest — no App Check needed)
exports.fetchTodayWalk = functions.https.onRequest((req, res) => {
    cors(req, res, async () => {
        const userId = await verifyAuth(req, res);
        if (!userId) return;

        const accessToken = await getValidAccessToken(userId);
        if (!accessToken) {
            return res.json({ distance_km: 0, pace_str: '0:00' });
        }

        try {
            const now = new Date();
            const midnight = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            const afterTimestamp = Math.floor(midnight.getTime() / 1000);

            const response = await axios.get(
                `https://www.strava.com/api/v3/athlete/activities?after=${afterTimestamp}`,
                { headers: { Authorization: `Bearer ${accessToken}` } }
            );

            const activities = response.data;
            let totalDistanceMeters = 0;
            let totalMovingTimeSeconds = 0;

            for (const activity of activities) {
                if (activity.type === 'Walk') {
                    totalDistanceMeters += (activity.distance || 0);
                    totalMovingTimeSeconds += (activity.moving_time || 0);
                }
            }

            if (totalDistanceMeters === 0) {
                return res.json({ distance_km: 0, pace_str: '0:00' });
            }

            const distanceKm = totalDistanceMeters / 1000;
            const totalMinutes = totalMovingTimeSeconds / 60;
            const paceMinPerKm = totalMinutes / distanceKm;

            const paceMins = Math.floor(paceMinPerKm);
            const paceSecs = Math.round((paceMinPerKm - paceMins) * 60);
            const paceStr = `${paceMins}:${paceSecs.toString().padStart(2, '0')}`;

            return res.json({ distance_km: distanceKm, pace_str: paceStr });
        } catch (error) {
            console.error('Strava Fetch Error:', error.response?.data || error.message);
            return res.status(500).json({ error: 'Failed to fetch tracking data.' });
        }
    });
});
