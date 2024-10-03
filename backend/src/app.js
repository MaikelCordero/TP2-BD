import express from 'express';
import config from './config';
import empleadosRoutes from '../routes/empleados.routes';

const cors = require('cors');
const app = express();

//settings
app.set('port', config.port);

//middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({extended: false}));

app.use('/api',empleadosRoutes)

export default app;