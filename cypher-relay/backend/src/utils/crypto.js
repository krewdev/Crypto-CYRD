const crypto = require('crypto');
const CryptoJS = require('crypto-js');

/**
 * Verify QR code data format and signature
 * Expected format: CYRD:cardId:amount:chain:timestamp:signature
 */
function verifyQRCodeData(qrData) {
  try {
    const parts = qrData.split(':');
    if (parts.length !== 6 || parts[0] !== 'CYRD') {
      return null;
    }
    
    const [prefix, cardId, amount, chain, timestamp, signature] = parts;
    
    // Verify timestamp is not too old (5 minutes)
    const qrTimestamp = parseInt(timestamp);
    const now = Date.now();
    if (now - qrTimestamp > 5 * 60 * 1000) {
      return null;
    }
    
    // Verify signature
    const dataToSign = `${prefix}:${cardId}:${amount}:${chain}:${timestamp}`;
    const expectedSignature = generateQRSignature(dataToSign);
    
    if (signature !== expectedSignature) {
      return null;
    }
    
    return {
      cardId,
      amount: parseFloat(amount),
      chain,
      timestamp: qrTimestamp
    };
  } catch (error) {
    return null;
  }
}

/**
 * Generate signature for QR code data
 */
function generateQRSignature(data) {
  const secret = process.env.QR_SIGNATURE_SECRET || 'default-secret-change-in-production';
  return crypto
    .createHmac('sha256', secret)
    .update(data)
    .digest('hex')
    .substring(0, 16); // Use first 16 chars for shorter QR codes
}

/**
 * Hash QR code for database storage
 */
function hashQRCode(qrData) {
  return crypto
    .createHash('sha256')
    .update(qrData)
    .digest('hex');
}

/**
 * Generate a new QR code for a card
 */
function generateQRCode(cardId, amount, chain) {
  const timestamp = Date.now();
  const dataToSign = `CYRD:${cardId}:${amount}:${chain}:${timestamp}`;
  const signature = generateQRSignature(dataToSign);
  return `${dataToSign}:${signature}`;
}

/**
 * Encrypt sensitive data
 */
function encrypt(text, key = process.env.ENCRYPTION_KEY) {
  return CryptoJS.AES.encrypt(text, key).toString();
}

/**
 * Decrypt sensitive data
 */
function decrypt(ciphertext, key = process.env.ENCRYPTION_KEY) {
  const bytes = CryptoJS.AES.decrypt(ciphertext, key);
  return bytes.toString(CryptoJS.enc.Utf8);
}

/**
 * Generate a secure random token
 */
function generateSecureToken(length = 32) {
  return crypto.randomBytes(length).toString('hex');
}

/**
 * Hash a password
 */
function hashPassword(password) {
  const salt = crypto.randomBytes(16).toString('hex');
  const hash = crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
  return `${salt}:${hash}`;
}

/**
 * Verify a password
 */
function verifyPassword(password, storedHash) {
  const [salt, hash] = storedHash.split(':');
  const verifyHash = crypto.pbkdf2Sync(password, salt, 10000, 64, 'sha512').toString('hex');
  return hash === verifyHash;
}

module.exports = {
  verifyQRCodeData,
  generateQRSignature,
  hashQRCode,
  generateQRCode,
  encrypt,
  decrypt,
  generateSecureToken,
  hashPassword,
  verifyPassword
};