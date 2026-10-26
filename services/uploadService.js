const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const UPLOADS_DIR = path.join(__dirname, '..', 'public', 'uploads');
const MAX_FILE_SIZE = parseInt(process.env.MAX_UPLOAD_SIZE_BYTES || '5242880', 10); // 5MB default

// Ensure upload directory exists
if (!fs.existsSync(UPLOADS_DIR)) {
  fs.mkdirSync(UPLOADS_DIR, { recursive: true });
}

class UploadService {
  /**
   * Validate magic bytes of a buffer to verify true image type
   */
  static detectImageType(buffer) {
    if (!buffer || buffer.length < 12) return null;

    // JPEG: FF D8 FF
    if (buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) {
      return { ext: 'jpg', mime: 'image/jpeg' };
    }

    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (
      buffer[0] === 0x89 &&
      buffer[1] === 0x50 &&
      buffer[2] === 0x4e &&
      buffer[3] === 0x47 &&
      buffer[4] === 0x0d &&
      buffer[5] === 0x0a &&
      buffer[6] === 0x1a &&
      buffer[7] === 0x0a
    ) {
      return { ext: 'png', mime: 'image/png' };
    }

    // GIF: GIF87a or GIF89a
    const gifHeader = buffer.toString('ascii', 0, 6);
    if (gifHeader === 'GIF87a' || gifHeader === 'GIF89a') {
      return { ext: 'gif', mime: 'image/gif' };
    }

    // WEBP: RIFF....WEBP
    const riff = buffer.toString('ascii', 0, 4);
    const webp = buffer.toString('ascii', 8, 12);
    if (riff === 'RIFF' && webp === 'WEBP') {
      return { ext: 'webp', mime: 'image/webp' };
    }

    return null;
  }

  /**
   * Save a base64 encoded image string or buffer securely
   * @param {string|Buffer} input - base64 string (with or without data URI prefix) or Buffer
   * @param {string} prefix - filename prefix (e.g. 'insp', 'port')
   */
  static async saveImage(input, prefix = 'img') {
    if (!input) {
      throw new Error('No image payload provided');
    }

    let buffer;
    if (Buffer.isBuffer(input)) {
      buffer = input;
    } else if (typeof input === 'string') {
      // Check for base64 data URI: data:image/png;base64,xxxx
      const matches = input.match(/^data:([A-Za-z-+/]+);base64,(.+)$/);
      if (matches) {
        buffer = Buffer.from(matches[2], 'base64');
      } else {
        // Plain base64 or URL
        if (input.startsWith('http://') || input.startsWith('https://')) {
          // If already a valid remote URL, accept as-is
          return input;
        }
        buffer = Buffer.from(input, 'base64');
      }
    } else {
      throw new Error('Invalid image input format');
    }

    // Validate file size
    if (buffer.length > MAX_FILE_SIZE) {
      throw new Error(`Image size (${(buffer.length / (1024 * 1024)).toFixed(2)}MB) exceeds maximum limit of ${(MAX_FILE_SIZE / (1024 * 1024)).toFixed(1)}MB`);
    }

    // Validate true image type by header bytes
    const detected = this.detectImageType(buffer);
    if (!detected) {
      throw new Error('Invalid image file format. Only JPEG, PNG, WebP, and GIF images are permitted.');
    }

    // Safe sanitized filename
    const safePrefix = prefix.replace(/[^a-zA-Z0-9_-]/g, '');
    const randomHex = crypto.randomBytes(8).toString('hex');
    const filename = `${safePrefix}_${Date.now()}_${randomHex}.${detected.ext}`;
    const filePath = path.join(UPLOADS_DIR, filename);

    // Write file securely
    await fs.promises.writeFile(filePath, buffer, { mode: 0o644 });

    // Return static URL path
    return `/uploads/${filename}`;
  }
}

module.exports = UploadService;
