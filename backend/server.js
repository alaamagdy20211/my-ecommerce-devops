// import express from 'express';
// import path from 'path';
// import mongoose from 'mongoose';
// import bodyParser from 'body-parser';
// import config from './config.js';
// import userRoute from './routes/userRoute.js';
// import productRoute from './routes/productRoute.js';
// import orderRoute from './routes/orderRoute.js';
// import uploadRoute from './routes/uploadRoute.js';
// import { fileURLToPath } from 'url';

// // const __filename = fileURLToPath(import.meta.url);
// // const __dirname = path.dirname(__filename);

// // const mongodbUrl = config.MONGODB_URL;
// // mongoose
// //   .connect(mongodbUrl, {
// //     useNewUrlParser: true,
// //     useUnifiedTopology: true,
// //     useCreateIndex: true,
// //   })
// //   .catch((error) => console.log(error.reason));

// // const app = express();
// // app.use(bodyParser.json());
// // app.use('/api/uploads', uploadRoute);
// // app.use('/api/users', userRoute);
// // app.use('/api/products', productRoute);
// // app.use('/api/orders', orderRoute);
// // app.get('/api/config/paypal', (req, res) => {
// //   res.send(config.PAYPAL_CLIENT_ID);
// // });
// // app.use('/uploads', express.static(path.join(__dirname, '/../uploads')));
// // app.use(express.static(path.join(__dirname, '/../frontend/build')));
// // app.get('*', (req, res) => {
// //   res.sendFile(path.join(`${__dirname}/../frontend/build/index.html`));
// // });

// // // app.listen(config.PORT, () => {
// // //   console.log('Server started at http://localhost:5000');
// // // });
// // app.listen(5000, "0.0.0.0")
// // app.get("/", (req, res) => {
// //   res.send("OK");
// // });

// const app = express();
// app.use(express.json());

// app.get("/health", (req, res) => {
//   res.status(200).send("OK");
// });

// // API routes
// app.use('/api/uploads', uploadRoute);
// app.use('/api/users', userRoute);
// app.use('/api/products', productRoute);
// app.use('/api/orders', orderRoute);

// app.get('/api/config/paypal', (req, res) => {
//   res.send(config.PAYPAL_CLIENT_ID);
// });

// app.use('/uploads', express.static(path.join(__dirname, '/../uploads')));
// app.use(express.static(path.join(__dirname, '/../frontend/build')));

// app.get('*', (req, res) => {
//   res.sendFile(path.join(__dirname, '/../frontend/build/index.html'));
// });


import express from 'express';
import path from 'path';
import mongoose from 'mongoose';
import bodyParser from 'body-parser';
import config from './config.js';

import userRoute from './routes/userRoute.js';
import productRoute from './routes/productRoute.js';
import orderRoute from './routes/orderRoute.js';
import uploadRoute from './routes/uploadRoute.js';

import { fileURLToPath } from 'url';

// ✅ FIX __dirname for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ---------------- APP ----------------
const app = express();

app.use(express.json());
app.use(bodyParser.json());

// ---------------- HEALTH CHECK (ALB) ----------------
app.get("/health", (req, res) => {
  res.status(200).send("OK");
});

// ---------------- MONGODB ----------------
mongoose
  .connect(config.MONGODB_URL)
  .then(() => console.log("MongoDB connected"))
  .catch((err) => console.log("Mongo error:", err));

// ---------------- ROUTES ----------------
app.use('/api/uploads', uploadRoute);
app.use('/api/users', userRoute);
app.use('/api/products', productRoute);
app.use('/api/orders', orderRoute);

app.get('/api/config/paypal', (req, res) => {
  res.send(config.PAYPAL_CLIENT_ID);
});

// ---------------- STATIC FILES ----------------
app.use('/uploads', express.static(path.join(__dirname, '/../uploads')));
// app.use(express.static(path.join(__dirname, '/../frontend/build')));

// // ---------------- FRONTEND FALLBACK ----------------
// app.get('*', (req, res) => {
//   res.sendFile(path.join(__dirname, '/../frontend/build/index.html'));
// });

// ---------------- START SERVER ----------------
app.listen(5000, "0.0.0.0", () => {
  console.log("Server running on port 5000");
});