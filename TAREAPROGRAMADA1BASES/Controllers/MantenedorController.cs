using Microsoft.AspNetCore.Mvc;
using TAREAPROGRAMADA1BASES.Datos;
using TAREAPROGRAMADA1BASES.Models;




namespace TAREAPROGRAMADA1BASES.Controllers
{
    public class MantenedorController : Controller
    {

            EmpleadoDatos _EmpleadoDatos = new EmpleadoDatos();


        //La vista mostrará una lista de empleados
        public IActionResult listar()
        {
            var oLista = _EmpleadoDatos.Listar();


            return View(oLista);
        }


        //Mostrará la vista de nuestro formulario html
        public IActionResult Guardar() {
        
            return View();
        }


        [HttpPost]
        //Recibe un objeto y lo guarda en la BD
        public IActionResult Guardar(EmpleadoModel oEmpleado)
        {
            // Validar si el nombre ya existe en la base de datos
            if (_EmpleadoDatos.ExisteNombre(oEmpleado.Nombre))
            {
                ModelState.AddModelError("Nombre", "El nombre ya está registrado");
            }

            // Validar si la identidad ya existe en la base de datos
            if (_EmpleadoDatos.ExisteIdentidad(oEmpleado.IDENTIDAD))
            {
                ModelState.AddModelError("IDENTIDAD", "La identificación ya está registrada");
            }

            // Verificar si el modelo es válido
            if (!ModelState.IsValid)
            {
                // Si hay errores, volver a cargar la vista con los mensajes de error
                return View(oEmpleado);
            }

            // Si no hay errores, proceder con el guardado
            var respuesta = _EmpleadoDatos.Guardar(oEmpleado);
            if (respuesta)
                return RedirectToAction("listar");
            else
                return View(oEmpleado);
        }

        public IActionResult DEV()
        {
            return View();
        }



    }
}
