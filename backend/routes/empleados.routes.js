import { Router } from "express";
import { ListarEmpleados, InsertarEmpleado, EliminarEmpleado, ActualizarEmpleado, ConsultarEmpleado, 
    ConsultarMovimientosEmpleado, InsertarMovimiento, IntentoInsertarMovimiento, Login
} from "../controllers/empleados.controller";

const router = Router();

router.post('/ListarEmpleados', ListarEmpleados);
router.post('/InsertarEmpleado', InsertarEmpleado);
router.delete('/EliminarEmpleado', EliminarEmpleado);
router.put('/ActualizarEmpleado', ActualizarEmpleado);
router.put('/VerEmpleado', ConsultarEmpleado);
router.put('/ConsultarMovimientosEmpleado', ConsultarMovimientosEmpleado);
router.post('/InsertarMovimiento', InsertarMovimiento);
router.post('/IntentoInsertarMovimiento', IntentoInsertarMovimiento);
router.post('/Login', Login);



export default router;