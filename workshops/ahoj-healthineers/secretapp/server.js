const express = require('express');
const app = express();
const PORT = 8080;

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Success!</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
          color: white;
        }
        .container {
          text-align: center;
          background: rgba(255, 255, 255, 0.1);
          padding: 50px;
          border-radius: 20px;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
          backdrop-filter: blur(10px);
          max-width: 600px;
        }
        h1 {
          font-size: 3em;
          margin: 0 0 20px 0;
          animation: bounce 1s ease infinite;
        }
        p {
          font-size: 1.5em;
          line-height: 1.6;
          margin: 20px 0;
        }
        .emoji {
          font-size: 4em;
          animation: wave 2s ease-in-out infinite;
          display: inline-block;
        }
        @keyframes bounce {
          0%, 100% { transform: translateY(0); }
          50% { transform: translateY(-10px); }
        }
        @keyframes wave {
          0%, 100% { transform: rotate(0deg); }
          25% { transform: rotate(20deg); }
          75% { transform: rotate(-20deg); }
        }
        .highlight {
          background: rgba(255, 255, 255, 0.2);
          padding: 5px 10px;
          border-radius: 5px;
          font-weight: bold;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🎉 SUCCESS! 🎉</h1>
        <p>Congratulations! You successfully fixed the bug!</p>
        <div class="emoji">🙋</div>
        <p><span class="highlight">Raise your hand!</span></p>
        <p>If you're among the first, you'll get a T-shirt! 👕</p>
      </div>
    </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.status(200).send('OK');
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`SecretApp running on port ${PORT}`);
});
