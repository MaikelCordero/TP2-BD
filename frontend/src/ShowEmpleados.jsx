import React,{useEffect, useState} from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';
import withReactContent from 'sweetalert2-react-content';
import { show_alerta } from './functions';

function ShowEmpleados() {
    const api = 'http://localhost:5000/api'
    const [empleados, setEmpleados] = useState([]);
    const [id, setId] = useState('');
    const [newId, setNewId] = useState('');
    const [name, setName] = useState('');
    const [newName, setNewName] = useState('');
    const [operation,setOperation]= useState(1);
    const [title,setTitle]= useState('');
    const [filtro, setFiltro]= useState('');
    const [puesto, setPuesto]= useState(0);
    const [NamePostByUser, setNamePostByUser]= useState('roger44');
    const [PostInIP, setPostInIP]= useState('');
    const [consulta, setConsulta]= useState([]);
    const [saldo, setSaldo]= useState('');
    const [historial, setHistorial]= useState([]);
    const [fecha, setFecha]= useState('');
    const [user, setUser]= useState('');
    const [monto, setMonto]= useState('');
    const [movimiento, setMovimiento]= useState('');
    const [userName, setUserName]= useState('');
    const [password, setPassword]= useState('');
    const [prueba, setPrueba]= useState('');
    const nameVal = /^[a-zA-Z\s]+$/;
    const idVal = /^[0-9]+$/;

    useEffect(() => {
        fetch("https://checkip.amazonaws.com/").then(res => res.text()).then(data => setPostInIP(data)).catch(error => console.log(error));
        getEmpleados();
        getFecha();
    }, [])

const loginUser = async (userName,password) => {
    await axios.post(
        `${api}/Login`,
        {
            user: userName,
            password,
            PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta);
        setUser(respuesta);
        setUserName('');
        setPassword('');
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 402){
            show_alerta(msj, 'warning')
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const getFecha = () => {
    var fecha = new Date();
    var anio = fecha.getFullYear();
    var hoy = fecha.getDate();
    var mes = fecha.getMonth() + 1;
    var tiempoTranscurrido = Date.now();
    var hoy = new Date(tiempoTranscurrido);

    
    console.log(hoy.toISOString());
    setFecha(hoy.toISOString());
    return;
}

const getEmpleados = async () => {
    await axios.post(
        `${api}/ListarEmpleados`,
        {
            varBuscar: filtro,
            NamePostByUser: NamePostByUser,
            PostInIP: PostInIP
        },
        {
        headers: {
            'Content-Type': 'application/json'
        }
        }
    ).then(function(respuesta){
        setEmpleados(respuesta.data);
        console.log(respuesta.data);
        console.log(empleados);
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const filtrar = async (e) =>{
    getEmpleados();
}

const openModal = (op,id, name) =>{
    setId('');
    setName('');
    setNewId('');
    setNewName('');
    setConsulta([]);
    setSaldo('');
    setHistorial([]);
    setMonto('');
    setMovimiento('');
    setOperation(op);
    if(op === 1){
        setTitle('Registrar Empleado');
    }
    else if(op === 2){
        setTitle('Editar Empleado');
        setId(id);
        setName(name);
    }
    else if(op === 3){
        setTitle('Ver Empleado');
        setId(id);
        var parametros={id:id, NamePostByUser:NamePostByUser.trim(), PostInIP:PostInIP.trim()};
        var url = `${api}/VerEmpleado`;
        ConsultarEmpleado(parametros,url);
    }
    else if(op === 4){
        setTitle('Historial de Empleado');
        setId(id);
        var parametros={id:id, NamePostByUser:NamePostByUser.trim(), PostInIP:PostInIP.trim()};
        var url = `${api}/VerEmpleado`;
        ConsultarEmpleado(parametros,url);
        url = `${api}/ConsultarMovimientosEmpleado`;
        ConsultarHistorial(parametros,url);
    }
    else if(op === 5){
        setTitle('Insertar Movimiento');
        setId(id);
        var parametros={id:id, NamePostByUser:NamePostByUser.trim(), PostInIP:PostInIP.trim()};
        var url = `${api}/VerEmpleado`;
        ConsultarEmpleado(parametros,url);
    }
}

const validar = () => {
    var parametros;
    var url;
    if(name.trim() === ''){
        show_alerta('Escribe el nombre del empleado','warning');
    }
    else if(id === ''){
        show_alerta('Escribe la identificación del producto','warning');
    }
    else{
        if(operation === 1){
            if (!idVal.test(id)) {
                show_alerta('La identificación debe ser un número','warning');
                return;
            }
            if (!nameVal.test(name)) {
                show_alerta('El nombre debe ser solo letras','warning');
                return;
            }
            if(puesto == 0){
                show_alerta('Selecciona un puesto','warning');
                return;
            }
            parametros= {id:id.trim(),name:name.trim(),puesto:puesto.trim(), NamePostByUser:NamePostByUser.trim(), PostInIP:PostInIP.trim()};
            url = `${api}/InsertarEmpleado`;
            InsertarEmpleado(parametros,url);
        } else if (operation === 2){
            if (newId === '') {
                show_alerta('Escribe la nueva identificación del empleado','warning');
                return;
            }
            if (newName === '') {
                show_alerta('Escribe el nuevo nombre del empleado','warning');
                return;
            }
            if (!idVal.test(newId)) {
                show_alerta('La identificación debe ser un número','warning');
                return;
            }
            if (!nameVal.test(name)) {
                show_alerta('El nombre debe ser solo letras','warning');
                return;
            }
            if(puesto == 0){
                show_alerta('Selecciona un puesto','warning');
                return;
            }
            console.log(id);
            console.log(newId);
            console.log(name);
            console.log(newName);
            parametros={id:id, newId:newId, name:newName.trim(), puesto:puesto.trim(), NamePostByUser:NamePostByUser.trim(), PostInIP:PostInIP.trim()};
            url = `${api}/ActualizarEmpleado`; 
            ActualizarEmpleado(parametros,url);
        } 
    }
}

const InsertarMovimiento = async(parametros, url) => {
    await axios.post(
        url,
        {
            nombreEmpl: parametros.name,
            nombreMov: parametros.movimiento,
            fecha: parametros.fecha,
            monto: parametros.monto,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.data);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
            document.getElementById('btnCerrar').click();
        }
    }).catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const IntentoInsertarMovimiento = async(parametros, url) => {
    await axios.post(
        url,
        {
            nombreEmpl: parametros.name,
            nombreMov: parametros.movimiento,
            monto: parametros.monto,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.data);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
            document.getElementById('btnCerrar').click();
        }
    }).catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else {
            show_alerta(msj,'warning');
            console.log(error);
        }
    });
}


const ConsultarEmpleado = async(parametros, url) => {
    await axios.put(
        url,
        {
            id: parametros.id,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.data);
        setConsulta(respuesta.data.recordset);
        setId(respuesta.data.recordset[0].ValorDocumentoIdentidad);
        setName(respuesta.data.recordset[0].Nombre);
        setPuesto(respuesta.data.recordset[0].Puesto);
        setSaldo(respuesta.data.recordset[0].SaldoVacaciones);
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const ConsultarHistorial = async(parametros, url) => {
    await axios.put(
        url,
        {
            id: parametros.id,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.data);
        setHistorial(respuesta.data.recordset);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
            document.getElementById('btnCerrar').click();
        }
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const ActualizarEmpleado = async(parametros, url) => {
    await axios.put(
        url,
        {
            id: parametros.id,
            nuevoId: parametros.newId,
            nombre: parametros.name,
            puesto: parametros.puesto,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.statusText);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
            document.getElementById('btnCerrar').click();
        }
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const InsertarEmpleado = async(parametros, url) => {
    await axios.post(
        url,
        {
            id: parametros.id,
            nombre: parametros.name,
            puesto: parametros.puesto,
            NamePostByUser: parametros.NamePostByUser,
            PostInIP: parametros.PostInIP
        },
        {
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.statusText);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
            document.getElementById('btnCerrar').click();
        } 
    })
    .catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const deleteEmpleado= (id, name) =>{
    const MySwal = withReactContent(Swal);
    MySwal.fire({
        title:'¿Seguro de eliminar el empleado '+name+' ?',
        icon: 'question',text:'No se podrá dar marcha atrás',
        showCancelButton:true,confirmButtonText:'Si, eliminar',cancelButtonText:'Cancelar'
    }).then((result) =>{
        if(result.isConfirmed){
            setId(id);
            EliminarEmpleado(id);
        }
        else{
            show_alerta('El empleado NO fue eliminado','info');
        }
    });
}

const EliminarEmpleado = async(id) => {
    await axios.delete(
        `${api}/EliminarEmpleado`,
        {
            data: {
                id: id,
                NamePostByUser: NamePostByUser,
                PostInIP: PostInIP
            },
            headers: {
                'Content-Type': 'application/json'
            }
        }
    ).then(function(respuesta){
        console.log(respuesta.statusText);
        var tipo;
        var msj = respuesta.data.msg;
        if(respuesta.statusText === 'OK'){
            tipo = 'success';
            show_alerta(msj, tipo);
            getEmpleados();
        }
    }). catch(function(error){
        var msj = error.response.data.msg;
        if(error.response.status === 400){
            show_alerta(msj,'warning');
        }
        else if(error.response.status === 401){
            show_alerta(msj,'warning');
        }
        else{
            show_alerta(msj,'error');
            console.log(error);
        }
    });
}

const handleSubmit = async (event) => {
    event.preventDefault();
    console.log(userName);
    console.log(password);
    loginUser(
        userName.trim(),
        password.trim()
    );
}

const renderLogin = () => (
    <div className='login template d-flex justify-content-center align-items-center vh-100 bg-primary'>
        <div className='form-container p-5 rounded bg-white'>
            <form onSubmit={handleSubmit}>
                <div className='mb-3'>
                    <h3 className='text-center'>Iniciar Sesión</h3>
                    <div className='input-group mb-2'>
                        <span className='input-group-text'><i className='fa-solid fa-user'></i></span>
                        <input type='text' id='Usuario' className='form-control' placeholder='Usuario' value={userName}
                        onChange={(e)=> setUserName(e.target.value)}></input>
                    </div>
                    <div className='input-group mb-2'>
                        <span className='input-group-text'><i className='fa-solid fa-key'></i></span>
                        <input type='password' id='Password' className='form-control' placeholder='Contraseña' value={password}
                        onChange={(e)=> setPassword(e.target.value)}></input>
                    </div>
                    <div className='d-grid'>
                        <button className='btn btn-primary'>Iniciar Sesión</button>
                    </div>
                </div>
            </form>
        </div>
    </div>
)

const renderEmpleados = () => (
    <div>
        <div className='container-fluid'>
                    <div className='row'>
                        <div className='col-12'>
                            <h2 className='text-center mt-3'>Empleados</h2>
                        </div>
                    </div>
                    <div className='input-group mb-3'>
                        <input type='text' id='Filtro' className='form-control' placeholder='Filtro' value={filtro}
                        onChange={e => setFiltro(e.target.value)}></input>
                        <button onClick={filtrar} className='btn btn-primary'>
                            <i className='fa-solid fa-filter'></i>
                        </button>
                    </div>
                    <div className='row mt-3'>
                        <div className='col-12'>
                            <div className='table-responsive'>
                                <table className='table table-bordered'>
                                    <thead>
                                        <tr><th>NOMBRE</th><th>EDITAR</th><th>ELIMINAR</th><th>VER</th><th>HISTORIAL</th><th>MOVIMIENTOS</th></tr>
                                    </thead>
                                    <tbody className='table-group-divider'>
                                        {empleados.map( (empleado)=>(
                                            <tr key={empleado.ValorDocumentoIdentidad}>
                                                <td>{empleado.Nombre}</td>
                                                <td>
                                                    <button onClick={() => openModal(2,empleado.ValorDocumentoIdentidad,empleado.Nombre)}
                                                        className='btn btn-warning' data-bs-toggle='modal' data-bs-target='#modalUpdateEmpleados'>
                                                        <i className='fa-solid fa-edit'></i>
                                                    </button>
                                                </td>
                                                <td>
                                                    <button onClick={()=>deleteEmpleado(empleado.ValorDocumentoIdentidad,empleado.Nombre)} className='btn btn-danger'>
                                                        <i className='fa-solid fa-trash'></i>
                                                    </button>
                                                </td>
                                                <td>
                                                    <button onClick={()=>openModal(3, empleado.ValorDocumentoIdentidad,empleado.Nombre)} 
                                                    className='btn btn-info' data-bs-toggle='modal' data-bs-target='#modalVerEmpleados'>
                                                        <i className='fa-solid fa-eye'></i>
                                                    </button>
                                                </td>
                                                <td>
                                                    <button onClick={()=>openModal(4, empleado.ValorDocumentoIdentidad,empleado.Nombre)} 
                                                    className='btn btn-success' data-bs-toggle='modal' data-bs-target='#modalListarMovimientos'>
                                                        <i className='fa-solid fa-clipboard'></i>
                                                    </button>
                                                </td>
                                                <td>
                                                    <button onClick={()=>openModal(5, empleado.ValorDocumentoIdentidad,empleado.Nombre)} 
                                                    className='btn btn-secondary' data-bs-toggle='modal' data-bs-target='#modalInsertarMovimiento'>
                                                        <i className='fa-solid fa-user-plus'></i>
                                                    </button>
                                                </td>
                                            </tr>
                                        ))
                                        }
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div className='row mt-3'>
                        <div className='col-md-4 offset-md-4'>
                            <div className= 'btn-group w-100' role='group'>
                                <button onClick={()=> openModal(1)} className='btn btn-dark' data-bs-toggle='modal' data-bs-target='#modalInsertarEmpleados'>
                                    <i className='fa-solid fa-circle-plus'></i> Añadir
                                </button>
                                <button onClick={()=> setUser('')} className='btn btn-primary'>
                                    <i className='fa-solid fa-sign-out'></i> Salir
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='modalInsertarEmpleados' className='modal fade' aria-hidden='true'>
                    <div className='modal-dialog'>
                        <div className='modal-content'>
                            <div className='modal-header'>
                                <label className='h5'>{title}</label>
                                <button type='button' className='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
                            </div>
                            <div className='modal-body'>
                                <input type='hidden' id='id'></input>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-book'></i></span>
                                    <input type='text' id='ID' className='form-control' placeholder='ID' value={id}
                                    onChange={(e)=> setId(e.target.value)}></input>
                                </div>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-user'></i></span>
                                    <input type='text' id='Nombre' className='form-control' placeholder='Nombre' value={name}
                                    onChange={(e)=> setName(e.target.value)}></input>
                                </div>
                                <div className='select-group mb-3'>
                                    <select id='Puesto' className='form-select' value={puesto}	onChange={(e)=> setPuesto(e.target.value)}>
                                        <option value='0'>Selecciona un puesto</option>
                                        <option value='1'>Cajero</option>
                                        <option value='2'>Camarero</option>
                                        <option value='3'>Cuidador</option>
                                        <option value='4'>Conductor</option>
                                        <option value='5'>Asistente</option>
                                        <option value='6'>Recepcionista</option>
                                        <option value='7'>Fontanero</option>
                                        <option value='8'>Niñera</option>
                                        <option value='9'>Conserje</option>
                                        <option value='10'>Albañil</option>
                                    </select>
                                </div>
                                <div className='d-grid col-6 mx-auto'>
                                    <button onClick={() => validar()} className='btn btn-success'>
                                        <i className='fa-solid fa-floppy-disk'></i> Guardar
                                    </button>
                                </div>
                            </div>
                            <div className='modal-footer'>
                                <button type='button' id='btnCerrar' className='btn btn-secondary' data-bs-dismiss='modal'>Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='modalUpdateEmpleados' className='modal fade' aria-hidden='true'>
                    <div className='modal-dialog'>
                        <div className='modal-content'>
                            <div className='modal-header'>
                                <label className='h5'>{title}</label>
                                <button type='button' className='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
                            </div>
                            <div className='modal-body'>
                                <input type='hidden' id='id'></input>
                                <div className='label-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-book'></i></span>
                                    <input type='text' id='ID' className='form-control' placeholder='ID' value={id}
                                    onChange={(e)=> setPrueba(e.target.value)}></input>
                                </div>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-book'></i></span>
                                    <input type='text' id='ID' className='form-control' placeholder='ID' value={newId}
                                    onChange={(e)=> setNewId(e.target.value)}></input>
                                </div>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-user'></i></span>
                                    <input type='text' id='Nombre' className='form-control' placeholder='Nombre' value={name}
                                    onChange={(e)=> setPrueba(e.target.value)}></input>
                                </div>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-user'></i></span>
                                    <input type='text' id='Nombre' className='form-control' placeholder='Nombre' value={newName}
                                    onChange={(e)=> setNewName(e.target.value)}></input>
                                </div>
                                <div className='select-group mb-3'>
                                    <select id='Puesto' className='form-select' value={puesto}	onChange={(e)=> setPuesto(e.target.value)}>
                                        <option value='0'>Selecciona un puesto</option>
                                        <option value='1'>Cajero</option>
                                        <option value='2'>Camarero</option>
                                        <option value='3'>Cuidador</option>
                                        <option value='4'>Conductor</option>
                                        <option value='5'>Asistente</option>
                                        <option value='6'>Recepcionista</option>
                                        <option value='7'>Fontanero</option>
                                        <option value='8'>Niñera</option>
                                        <option value='9'>Conserje</option>
                                        <option value='10'>Albañil</option>
                                    </select>
                                </div>
                                <div className='d-grid col-6 mx-auto'>
                                    <button onClick={() => validar()} className='btn btn-success'>
                                        <i className='fa-solid fa-floppy-disk'></i> Guardar
                                    </button>
                                </div>
                            </div>
                            <div className='modal-footer'>
                                <button type='button' id='btnCerrar' className='btn btn-secondary' data-bs-dismiss='modal'>Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='modalVerEmpleados' className='modal fade' aria-hidden='true'>
                    <div className='modal-dialog'>
                        <div className='modal-content'>
                            <div className='modal-header'>
                                <label className='h5'>{title}</label>
                                <button type='button' className='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
                            </div>
                            <div className='row mt-3'>
                                <div className='col-12 col-lg-8 offset-0 offset-lg-2'>
                                    <div className='table-responsive'>
                                        <table className='table table-bordered'>
                                            <thead>
                                                <tr><th>ID</th><th>NOMBRE</th><th>PUESTO</th><th>SALDO</th></tr>
                                            </thead>
                                            <tbody className='table-group-divider'>
                                                {consulta.map( (atributo)=>(
                                                    <tr key={atributo.id}>
                                                        <td>{atributo.ValorDocumentoIdentidad}</td>
                                                        <td>{atributo.Nombre}</td>
                                                        <td>{atributo.Puesto}</td>
                                                        <td>{atributo.SaldoVacaciones}</td>
                                                    </tr>
                                                ))
                                                }
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div className='modal-footer'>
                                <button type='button' id='btnCerrar' className='btn btn-secondary' data-bs-dismiss='modal'>Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='modalListarMovimientos' className='modal fade' aria-hidden='true'>
                    <div className='modal-dialog'>
                        <div className='modal-content'>
                            <div className='modal-header'>
                                <label className='h5'>{title}</label>
                                <button type='button' className='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
                            </div>
                            <div className='row mt-3'>
                                <div className='col-12 col-lg-8 offset-0 offset-lg-2'>
                                    <div className='table-responsive'>
                                        <table className='table table-bordered'>
                                            <thead>
                                                <tr><th>ID</th><th>NOMBRE</th><th>PUESTO</th><th>SALDO</th></tr>
                                            </thead>
                                            <tbody className='table-group-divider'>
                                                {consulta.map( (atributo)=>(
                                                    <tr key={atributo.id}>
                                                        <td>{atributo.ValorDocumentoIdentidad}</td>
                                                        <td>{atributo.Nombre}</td>
                                                        <td>{atributo.Puesto}</td>
                                                        <td>{atributo.SaldoVacaciones}</td>
                                                    </tr>
                                                ))
                                                }
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div className='row mt-3'>
                                <div className='col-12 col-lg-8 offset-0 offset-lg-2'>
                                    <div className='table-responsive'>
                                        <table className='table table-bordered'>
                                            <thead>
                                                <tr><th>FECHA</th><th>NOMBRE</th><th>MONTO</th><th>SALDO</th><th>USUARIO</th><th>IP</th><th>POST-TIME</th></tr>
                                            </thead>
                                            <tbody className='table-group-divider'>
                                                {historial.map( (movimiento)=>(
                                                    <tr key={movimiento.id}>
                                                        <td>{movimiento.Fecha}</td>
                                                        <td>{movimiento.Nombre}</td>
                                                        <td>{movimiento.Monto}</td>
                                                        <td>{movimiento.NuevoSaldo}</td>
                                                        <td>{movimiento.IdPostByUser}</td>
                                                        <td>{movimiento.PostInIP}</td>
                                                        <td>{movimiento.PostTime}</td>
                                                    </tr>
                                                ))
                                                }
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div className='modal-footer'>
                                <button type='button' id='btnCerrar' className='btn btn-secondary' data-bs-dismiss='modal'>Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
                <div id='modalInsertarMovimiento' className='modal fade' aria-hidden='true'>
                    <div className='modal-dialog'>
                        <div className='modal-content'>
                            <div className='modal-header'>
                                <label className='h5'>{title}</label>
                                <button type='button' className='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>
                            </div>
                            <div className='modal-body'>
                                <div className='row mt-3'>
                                    <div className='col-12 col-lg-8 offset-0 offset-lg-2'>
                                        <div className='table-responsive'>
                                            <table className='table table-bordered'>
                                                <thead>
                                                    <tr><th>ID</th><th>NOMBRE</th><th>PUESTO</th><th>SALDO</th></tr>
                                                </thead>
                                                <tbody className='table-group-divider'>
                                                    {consulta.map( (atributo)=>(
                                                        <tr key={atributo.id}>
                                                            <td>{atributo.ValorDocumentoIdentidad}</td>
                                                            <td>{atributo.Nombre}</td>
                                                            <td>{atributo.Puesto}</td>
                                                            <td>{atributo.SaldoVacaciones}</td>
                                                        </tr>
                                                    ))
                                                    }
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                                <div className='select-group mb-3'>
                                    <select id='Puesto' className='form-select' value={movimiento}	onChange={(e)=> setMovimiento(e.target.value)}>
                                        <option value=''>Selecciona un movimiento</option>
                                        <option value='Cumplir mes'>Cumplir mes</option>
                                        <option value='Bono vacacional'>Bono vacacional</option>
                                        <option value='Reversion Debito'>Reversion Debito</option>
                                        <option value='Disfrute de vacaciones'>Disfrute de vacaciones</option>
                                        <option value='Venta de vacaciones'>Venta de vacaciones</option>
                                        <option value='Reversion de Credito'>Reversion de Credito</option>
                                    </select>
                                </div>
                                <div className='input-group mb-3'>
                                    <span className='input-group-text'><i className='fa-solid fa-coins'></i></span>
                                    <input type='text' id='Monto' className='form-control' placeholder='Monto' value={monto}
                                    onChange={(e)=> setMonto(e.target.value)}></input>
                                </div>
                                <div className='d-grid col-6 mx-auto'>
                                    <button onClick={() => InsertarMovimiento({name:consulta[0].Nombre, movimiento:movimiento, 
                                        fecha:fecha, monto:monto, NamePostByUser:NamePostByUser, PostInIP:PostInIP},
                                        `${api}/InsertarMovimiento`)} className='btn btn-success' id='btnGuardar'>
                                        <i className='fa-solid fa-floppy-disk'></i> Guardar
                                    </button>
                                </div>
                                <div className='d-grid col-6 mx-auto'>
                                    <button onClick={() => IntentoInsertarMovimiento({name:consulta[0].Nombre, movimiento:movimiento, 
                                        monto:monto, NamePostByUser:NamePostByUser, PostInIP:PostInIP},
                                        `${api}/IntentoInsertarMovimiento`)} className='btn btn-danger' id='btnCancelar'>
                                        <i className='fa-solid fa-trash'></i> Cancelar
                                    </button>
                                </div>
                            </div>
                            <div className='modal-footer'>
                                <button onClick={()=>{setMovimiento('');setMonto('');}} type='button' id='btnCerrar' className='btn btn-secondary' 
                                data-bs-dismiss='modal' data-bs-target='#modalInsertarMovimiento'>Cerrar</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
)


    return (
        <div className="App">
            {
                user
                ? renderEmpleados()
                : renderLogin()
            }
        </div>
    )
}

export default ShowEmpleados