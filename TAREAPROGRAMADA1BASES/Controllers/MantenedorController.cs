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

            if (!ModelState.IsValid)
                return View();

            var respuesta = _EmpleadoDatos.Guardar(oEmpleado);
            if (respuesta)
                return RedirectToAction("listar");
            else 
                return View();
        }

        public IActionResult DEV()
        {
            return View();
        }
    }
}
