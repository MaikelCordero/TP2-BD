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
        .input('varBuscar', sql.NVarChar, varBuscar)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.listarEmpleados');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
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
        .input('documIdentidad', sql.Int, id)
        .input('nombre', sql.NVarChar, nombre)
        .input('IdPuesto', sql.Int, puesto)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.insertEmpleado');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            res.status(200).json({msg: 'Empleado insertado correctamente'});
            console.log('Empleado insertado correctamente');
        } else if (result.output.OutResult == 50004) {
            res.status(400).json({msg: 'Ya existe un empleado con ese ID'});
            console.log('Ya existe un empleado con ese ID');
        } else if (result.output.OutResult == 50005) {
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
        .input('valorDocIdent', sql.Int, id)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.deletEmpleado');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            res.status(200).json({msg: 'Empleado eliminado correctamente'});
            console.log('Empleado eliminado correctamente');
        } else if (result.output.OutResult == 50012) {
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
        .input('valorDocIdent', sql.Int, id)
        .input('NuevoDocIdent', sql.Int, nuevoId)
        .input('nombre', sql.NVarChar, nombre)
        .input('idPuesto', sql.Int, puesto)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.updateEmpleado');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            res.status(200).json({msg: 'Empleado actualizado correctamente'});
            console.log('Empleado actualizado correctamente');
        } else if (result.output.OutResult == 50007) {
            res.status(400).json({msg: 'Empleado con mismo nombre ya existe en actualización'});
            console.log('Empleado con mismo nombre ya existe en actualización');
        } else if (result.output.OutResult == 50006) {
            res.status(401).json({msg: 'Empleado con mismo ID ya existe en actualización'});
            console.log('Empleado con mismo ID ya existe en actualización');
        } else if (result.output.OutResult == 50012) {
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
        .input('valorDocIdent', sql.Int, id)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.consultEmpleado');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            var data = {
                recordset: result.recordset,
                msg: 'Empleado obtenido correctamente'
            }
            res.status(200).json(data);
            console.log(result.recordset)
        } else if (result.output.OutResult == 50012) {
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
        .input('valorDocIdent', sql.Int, id)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.consultMovim');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            var data = {
                recordset: result.recordset,
                msg: 'Movimientos obtenidos correctamente'
            }
            res.status(200).json(data);
            console.log(result.recordset)
        } else if (result.output.OutResult == 50012) {
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
        .input('nombreEmpl', sql.NVarChar, nombreEmpl)
        .input('nombreMov', sql.NVarChar, nombreMov)
        .input('Fecha', sql.Date, fecha)
        .input('Monto', sql.Int, monto)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.insertMovimiento');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            res.status(200).json({msg: 'Movimiento realizado correctamente'});
            console.log('Movimiento insertado correctamente');
        } else if (result.output.OutResult == 50011) {
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
        .input('nombreEmpl', sql.NVarChar, nombreEmpl)
        .input('nombreMov', sql.NVarChar, nombreMov)
        .input('Monto', sql.Int, monto)
        .input('NamePostByUser', sql.NVarChar, NamePostByUser)
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.IntentoInsertMovimiento');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
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
        .input('userName', sql.NVarChar, user)
        .input('userPassword', sql.NVarChar, password)
        .input('NamePostByUser', sql.NVarChar, '')
        .input('PostInIP', sql.NVarChar, PostInIP)
        .output('OutResult', sql.Int, 0)
        .execute('PROYECT2JF.dbo.loginUser');

        console.log(result.output.OutResult);
        if(result.output.OutResult == 0){
            res.status(200).json({msg: 'Login correcto'});
            console.log('Login correcto');
        } else if (result.output.OutResult == 50003) {
            res.status(400).json({msg: 'Login deshabilitado'});
            console.log('Login deshabilitado');
        } else if (result.output.OutResult == 50002) {
            res.status(401).json({msg: 'Contraseña incorrecta'});
            console.log('Contraseña incorrecta');
        } else if (result.output.OutResult == 50001) {
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