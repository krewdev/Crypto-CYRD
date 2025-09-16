const { Card } = require('../src/models');
const { generateQRCode, hashQRCode } = require('../src/utils/crypto');
const QRCode = require('qrcode');
const fs = require('fs').promises;
const path = require('path');
const { v4: uuidv4 } = require('uuid');

async function generateCards() {
  // Parse command line arguments
  const args = process.argv.slice(2);
  const count = parseInt(args.find(arg => arg.startsWith('--count'))?.split('=')[1] || '10');
  const value = parseFloat(args.find(arg => arg.startsWith('--value'))?.split('=')[1] || '25');
  const chain = args.find(arg => arg.startsWith('--chain'))?.split('=')[1] || 'polygon';
  
  console.log(`Generating ${count} cards with value $${value} on ${chain}...`);
  
  const cards = [];
  const outputDir = path.join(__dirname, '../../output/cards');
  
  // Create output directory
  await fs.mkdir(outputDir, { recursive: true });
  
  for (let i = 0; i < count; i++) {
    const cardId = `TEST-${Date.now()}-${i.toString().padStart(4, '0')}`;
    const qrData = generateQRCode(cardId, value, chain);
    const qrCodeHash = hashQRCode(qrData);
    
    // Create card in database
    const card = await Card.create({
      cardId,
      qrCodeHash,
      value,
      tokenAmount: value, // 1:1 with USD
      nativeChain: chain,
      metadata: {
        batch: 'test-batch',
        generated: new Date().toISOString()
      }
    });
    
    // Generate QR code image
    const qrCodePath = path.join(outputDir, `${cardId}.png`);
    await QRCode.toFile(qrCodePath, qrData, {
      width: 512,
      margin: 2,
      color: {
        dark: '#000000',
        light: '#FFFFFF'
      }
    });
    
    // Generate card HTML
    const cardHtml = `
<!DOCTYPE html>
<html>
<head>
    <title>Cypher Relay Card - ${cardId}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: #f5f5f5;
        }
        .card {
            background: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
            border-radius: 20px;
            padding: 40px;
            color: white;
            text-align: center;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            max-width: 400px;
        }
        .logo {
            font-size: 48px;
            margin-bottom: 20px;
        }
        .title {
            font-size: 32px;
            font-weight: bold;
            margin-bottom: 10px;
        }
        .value {
            font-size: 64px;
            font-weight: bold;
            margin: 20px 0;
        }
        .qr-container {
            background: white;
            padding: 20px;
            border-radius: 15px;
            display: inline-block;
            margin: 20px 0;
        }
        .qr-code {
            width: 256px;
            height: 256px;
        }
        .card-id {
            font-size: 14px;
            opacity: 0.8;
            margin-top: 20px;
            font-family: monospace;
        }
        .instructions {
            font-size: 16px;
            margin-top: 20px;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="logo">🔐</div>
        <div class="title">Cypher Relay Card</div>
        <div class="value">$${value}</div>
        <div class="qr-container">
            <img src="${cardId}.png" alt="QR Code" class="qr-code">
        </div>
        <div class="instructions">
            Scan with Relay Vault app to redeem
        </div>
        <div class="card-id">Card ID: ${cardId}</div>
    </div>
</body>
</html>
    `;
    
    const htmlPath = path.join(outputDir, `${cardId}.html`);
    await fs.writeFile(htmlPath, cardHtml);
    
    cards.push({
      cardId,
      value,
      chain,
      qrCodePath,
      htmlPath,
      qrData
    });
    
    console.log(`Generated card ${i + 1}/${count}: ${cardId}`);
  }
  
  // Generate index file
  const indexHtml = `
<!DOCTYPE html>
<html>
<head>
    <title>Cypher Relay Test Cards</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            padding: 40px;
            background: #f5f5f5;
        }
        h1 {
            color: #6366F1;
        }
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }
        .card-link {
            background: white;
            padding: 20px;
            border-radius: 10px;
            text-decoration: none;
            color: #333;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.2s;
        }
        .card-link:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }
        .card-id {
            font-weight: bold;
            color: #6366F1;
        }
        .card-value {
            font-size: 24px;
            margin: 10px 0;
        }
        .card-chain {
            font-size: 14px;
            color: #666;
        }
    </style>
</head>
<body>
    <h1>Cypher Relay Test Cards</h1>
    <p>Generated ${count} test cards for development</p>
    <div class="cards-grid">
        ${cards.map(card => `
            <a href="${card.cardId}.html" class="card-link">
                <div class="card-id">${card.cardId}</div>
                <div class="card-value">$${card.value}</div>
                <div class="card-chain">Chain: ${card.chain}</div>
            </a>
        `).join('')}
    </div>
</body>
</html>
  `;
  
  await fs.writeFile(path.join(outputDir, 'index.html'), indexHtml);
  
  // Save cards data as JSON
  await fs.writeFile(
    path.join(outputDir, 'cards.json'),
    JSON.stringify(cards, null, 2)
  );
  
  console.log(`\n✅ Successfully generated ${count} cards!`);
  console.log(`📁 Output directory: ${outputDir}`);
  console.log(`🌐 Open ${path.join(outputDir, 'index.html')} to view cards`);
}

// Run if called directly
if (require.main === module) {
  generateCards()
    .then(() => process.exit(0))
    .catch(error => {
      console.error('Error generating cards:', error);
      process.exit(1);
    });
}

module.exports = { generateCards };