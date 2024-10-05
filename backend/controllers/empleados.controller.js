import { getConnection } from "../database/connection";
import sql from 'mssql';

export const ListarEmpleados = async (req, res) => {
    try {
        const {varBuscar, NamePostByUser, PostInIP} = req.body;

        console.log(varBuscar);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InBuscar', sql.NVarChar, varBuscar)
        .input('InPostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.listarEmpleados');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json(result.recordset);
        } else {
            res.status(400).json({msg: 'Error al obtener los empleados'});
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const InsertarEmpleado = async (req, res) => {
    try {
        const {id, nombre, puesto, NamePostByUser, PostInIP} = req.body;

        console.log(id);
        console.log(nombre);
        console.log(puesto);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('IndocumIdentidad', sql.Int, id)
        .input('Innombre', sql.NVarChar, nombre)
        .input('InIdPuesto', sql.Int, puesto)
        .input('InNamePostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.insertEmpleado');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Empleado insertado correctamente'});
            console.log('Empleado insertado correctamente');
        } else if (result.output.OutResultCode == 50004) {
            res.status(400).json({msg: 'Ya existe un empleado con ese ID'});
            console.log('Ya existe un empleado con ese ID');
        } else if (result.output.OutResultCode == 50005) {
            res.status(401).json({msg: 'Ya existe un empleado con ese nombre'});
            console.log('Ya existe un empleado con ese nombre');
        } else {
            res.status(402).json({msg: 'Error al insertar el empleado'});
            console.log('Error al insertar el empleado');
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const EliminarEmpleado = async (req, res) => {
    try {
        const {id, NamePostByUser, PostInIP} = req.body;

        console.log(id);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InvalorDocIdent', sql.Int, id)
        .input('InNamePostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.deletEmpleado');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Empleado eliminado correctamente'});
            console.log('Empleado eliminado correctamente');
        } else if (result.output.OutResultCode == 50012) {
            res.status(400).json({msg: 'No existe un empleado con ese ID'});
            console.log('No existe un empleado con ese ID');
        } else {
            res.status(401).json({msg: 'Error al eliminar el empleado'});
            console.log('Error al eliminar el empleado');
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const ActualizarEmpleado = async (req, res) => {
    try {
        const {id, nuevoId, nombre, puesto, NamePostByUser, PostInIP} = req.body;

        console.log(id);
        console.log(nombre);
        console.log(puesto);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InvalorDocIdent', sql.Int, id)
        .input('InNuevoDocIdent', sql.Int, nuevoId)
        .input('Innombre', sql.NVarChar, nombre)
        .input('InidPuesto', sql.Int, puesto)
        .input('InNamePostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.updateEmpleado');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Empleado actualizado correctamente'});
            console.log('Empleado actualizado correctamente');
        } else if (result.output.OutResultCode == 50007) {
            res.status(400).json({msg: 'Empleado con mismo nombre ya existe en actualización'});
            console.log('Empleado con mismo nombre ya existe en actualización');
        } else if (result.output.OutResultCode == 50006) {
            res.status(401).json({msg: 'Empleado con mismo ID ya existe en actualización'});
            console.log('Empleado con mismo ID ya existe en actualización');
        } else if (result.output.OutResultCode == 50012) {
            res.status(402).json({msg: 'No existe un empleado con ese ID'});
            console.log('No existe un empleado con ese ID');
        }   else {
            res.status(401).json({msg: 'Error al actualizar el empleado'});
            console.log('Error al actualizar el empleado');
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const ConsultarEmpleado = async (req, res) => {
    try {
        const {id, NamePostByUser, PostInIP} = req.body;

        console.log(id);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InvalorDocIdent', sql.Int, id)
        .input('InNamePostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.consultEmpleado');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            var data = {
                recordset: result.recordset,
                msg: 'Empleado obtenido correctamente'
            }
            res.status(200).json(data);
            console.log(result.recordset)
        } else if (result.output.OutResultCode == 50012) {
            res.status(400).json({msg: 'El empleado no existe'});
        } else {
            res.status(401).json({msg: 'Error al obtener el empleado'});
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const ConsultarMovimientosEmpleado = async (req, res) => {
    try {
        const {id, NamePostByUser, PostInIP} = req.body;

        console.log(id);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InvalorDocIdent', sql.Int, id)
        .input('InNamePostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.consultMovim');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            var data = {
                recordset: result.recordset,
                msg: 'Movimientos obtenidos correctamente'
            }
            res.status(200).json(data);
            console.log(result.recordset)
        } else if (result.output.OutResultCode == 50012) {
            res.status(400).json({msg: 'El empleado no existe'});
        } else {
            res.status(401).json({msg: 'Error al obtener los movimientos del empleado'});
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const InsertarMovimiento = async (req, res) => {
    try{
        const {nombreEmpl, nombreMov, fecha, monto, NamePostByUser, PostInIP} = req.body;

        console.log(nombreEmpl);
        console.log(nombreMov);
        console.log(fecha);
        console.log(monto);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InNombreEmpleado', sql.NVarChar, nombreEmpl)
        .input('InNombreMovimiento', sql.NVarChar, nombreMov)
        .input('InFecha', sql.Date, fecha)
        .input('InMonto', sql.Int, monto)
        .input('InPostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIp', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.insertMovimiento');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Movimiento realizado correctamente'});
            console.log('Movimiento insertado correctamente');
        } else if (result.output.OutResultCode == 50011) {
            res.status(400).json({msg: 'El monto es mayor al saldo de vacaciones del empleado'});
            console.log('El monto es mayor al saldo de vacaciones del empleado');
        } else {
            res.status(400).json({msg: 'Error al insertar el movimiento'});
            console.log('Error al insertar el movimiento');
        }


    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const IntentoInsertarMovimiento = async (req, res) => {
    try{
        const {nombreEmpl, nombreMov, monto, NamePostByUser, PostInIP} = req.body;

        console.log(nombreEmpl);
        console.log(nombreMov);
        console.log(monto);
        console.log(NamePostByUser);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InNombreEmpleado', sql.NVarChar, nombreEmpl)
        .input('InNombreMovimiento', sql.NVarChar, nombreMov)
        .input('InMonto', sql.Int, monto)
        .input('InPostByUser', sql.NVarChar, NamePostByUser)
        .input('InPostInIp', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.IntentoInsertMovimiento');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Movimiento cancelado correctamente'});
            console.log('Movimiento insertado correctamente');
        } else {
            res.status(400).json({msg: 'Error al cancelar el movimiento'});
            console.log('Error al insertar el movimiento');
        }


    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }
}

export const Login = async (req, res) => {
    try{
        const {user, password, PostInIP} = req.body;

        console.log(user);
        console .log(password);
        console.log(PostInIP);

        const pool = await getConnection();
        const result = await pool.request()
        .input('InuserName', sql.NVarChar, user)
        .input('InuserPassword', sql.NVarChar, password)
        .input('InNamePostByUser', sql.NVarChar, '')
        .input('InPostInIP', sql.NVarChar, PostInIP)
        .output('OutResultCode', sql.Int, 0)
        .execute('sistemaEmpleadosTP2.dbo.loginUser');

        console.log(result.output.OutResultCode);
        if(result.output.OutResultCode == 0){
            res.status(200).json({msg: 'Login correcto'});
            console.log('Login correcto');
        } else if (result.output.OutResultCode == 50003) {
            res.status(400).json({msg: 'Login deshabilitado'});
            console.log('Login deshabilitado');
        } else if (result.output.OutResultCode == 50002) {
            res.status(401).json({msg: 'Contraseña incorrecta'});
            console.log('Contraseña incorrecta');
        } else if (result.output.OutResultCode == 50001) {
            res.status(402).json({msg: 'Usuario no existe'});
            console.log('Usuario no existe');
        } else {
            res.status(403).json({msg: 'Error al hacer login'});
            console.log('Error al hacer login');
        }
    } catch (error) {
        console.log(error);
        res.status(500).json({msg: 'Internal Server Error'});
    }

}